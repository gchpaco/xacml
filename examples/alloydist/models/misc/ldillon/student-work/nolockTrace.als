module nolockTrace

// Processes
sig Process {}

// Locks
sig Mutex {}

// MutexList (a list of ordered mutexes)
static sig MutexList {
  mutexes: set Mutex,
  first: mutexes,
  last: mutexes,
  prev: (mutexes-first) !->! (mutexes-last)
}{
  last.*prev = mutexes
}

// States keep track of the locks that a process holds
// and the locks that a process is waiting for
sig State {
  holds, waits: Process -> Mutex
}

// Check to see if the mutex previous to m is held.
// Note that the first mutex has no previous and must
// be examined separately since HoldsPrevious should be
// trivially true when m is the first mutex in l. 
fun HoldsPrevious( s:State, p:Process, m:Mutex, l:MutexList ) {
  no (m.l::prev) || some ((p -> (p.s::holds)).(m.l::prev))
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
det fun GrabMutex( s:State, p:Process, m:Mutex, l:MutexList ):State {
  // the process must not have been stalled
  ! IsStalled(s,p)
  // the process must not have been in posession of the lock
  m !in p.s::holds
  // Must hold the previous mutex (if not the first)
  HoldsPrevious(s,p,m,l) 
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
    m.~result::waits = m.~s::waits
    m.~result::holds = m.~s::holds
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
      (some p: Process, m: MutexList.mutexes, l: MutexList | s' = GrabMutex(s,p,m,l))
      ||
      (some p: Process, m: MutexList.mutexes | s' = ReleaseMutex(s,p,m))
    )
}


assert NoDeadlock {
  some Process =>
  all x:StateTrace | some p:Process | no p.((x.last)::(x.state).waits)
}

check NoDeadlock for 2 but 5State, 5Tick

fun SomeWait () {
  some x:StateTrace | some t:x.ticks | some (x.state)[t].waits
}

fun SomeHold () {
  some x:StateTrace | some t:x.ticks | some (x.state)[t].holds
}

fun HoldAll () {
  some x:StateTrace | some t:x.ticks | one p:Process | 
  all m:Mutex | ((p -> m) in (x.state)[t].holds) &&
  (some (x.state)[t].holds)
}

fun SomeWaitHold () {
  some x:StateTrace | some t:x.ticks | 
     (some (x.state)[t].holds) && (some (x.state)[t].waits)
}

run SomeWait for 3 

run SomeWait for 3 but 3Mutex

run HoldAll for 3 but 3Mutex, 2Process

run SomeHold for 3

run SomeWait for 3 but 3Process

run SomeWaitHold for 3 but 3Mutex

