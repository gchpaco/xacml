module lockingTrace

// Processes
sig Process {}



// Locks
sig Mutex {}



// Order
sig Order {}


// MutexOrder

static sig MutexOrder{
orders: set Order,
first: orders,
last: orders,
next: (orders - first) !->! (orders - last),
prev: (orders - last) !->! (orders - first),
mutex: orders ->! Mutex
}{
first.*next = orders
last.*prev = orders

}


// States keep track of the locks that a process holds
// and the locks that a process is waiting for
sig State {
  holds, waits: Process -> Mutex
}

// In an initial state, no process holds any locks
// or is waiting for any locks
fun Initial( s:State ) {
  no s.holds + s.waits
}

// A lock is free if no process holds it
fun IsFree( s:State, m:Mutex ) {
  no (s.holds).m
}

// A process is stalled if it is waiting for a lock
fun IsStalled( s:State, p:Process ) {
  some p.s::waits
}

// result of a process trying to grab a lock
det fun GrabMutex( s:State, p:Process, m:Mutex ):State {
  // the process must not have been stalled
  ! IsStalled(s,p)
  // the process must not have been in posession of the lock
  m !in p.s::holds


// added for enforcing the resource allocation policy for deadlock avoidance


(some p.s::holds)  => 
(
all mo: MutexOrder | some o: mo.orders - mo.first | 
( (((mo.mutex) [o.mo::next]) !in p.s::holds) && 
(((mo.mutex) [o.mo::prev]) in p.s::holds) ) 
&& (m in (mo.mutex) [o])
 )

(no p.s::holds) => (all mo: MutexOrder | some o: mo.orders | m in (mo.mutex) [mo.first])

  IsFree(s,m) => {
    // if the lock was free, give it to the process
    p.result::holds = p.s::holds + m 
    no p.result::waits 
  } else {
    // otherwise, the process blocks
    p.result::holds = p.s::holds
    p.result::waits = m
  }
  // the status of other processes is not affected
  all other:Process - p | (
    other.result::holds = other.s::holds &&
    other.result::waits = other.s::waits
  )
}

// result of a process releasing a lock
det fun ReleaseMutex( s:State, p:Process, m:Mutex ):State {
  // the process must not have been stalled
  ! IsStalled(s,p)
  // the process must have been in possession of the lock
  m in p.s::holds
  // the process gives up the lock
  p.result::holds = p.s::holds - m
  // the process is not waiting for any lock
  no p.result::waits  
  no m.~s::waits => {
    // if no one was waiting for the lock
    // then no one gets it and no one is waiting for it 
    no m.~result::holds
    no m.~result::waits
  }
  else {
    // otherwise, give the lock to some process who was waiting for it
    some lucky: m.~s::waits | {
      m.~result::waits = m.~s::waits - lucky
      m.~result::holds = lucky
    }
  }
  // the status of all other locks remains the same
  all mu: Mutex - m {
    mu.~result::waits = mu.~s::waits
    mu.~result::holds = mu.~s::holds
  }
}

// "ticks" of a clock
sig Tick {}

// a single trace of the system
static sig StateTrace {
  ticks: set Tick,
  first: ticks,
  last: ticks,
  next: (ticks-last) !->! (ticks-first),
  state: ticks ->! State
}{
  // ticks is totally ordered by *next and first is the first tick
  first.*next = ticks
  // the first state is an initial state
  Initial(first.state)
  // subsequent states are the result of a process grabbing
  // or releasing a lock
  all t: ticks-last |
    some s=state[t], s'=state[t.next] | (
      (some p: Process, m: Mutex | s' = GrabMutex(s,p,m))
      ||
      (some p: Process, m: Mutex | s' = ReleaseMutex(s,p,m))
    )
}


assert NoDeadlock {
  some Process =>
  all x:StateTrace | some p:Process | no p.((x.last)::(x.state).waits)
}

check NoDeadlock for 3 but 5State, 5Tick

fun SomeWait () {
  some x:StateTrace | some t:x.ticks | some (x.state)[t].waits
}


fun SomeHold () {
  some x:StateTrace | some t:x.ticks | some (x.state)[t].holds
}

run SomeWait for 3

run SomeHold for 3

