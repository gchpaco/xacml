module lockingTrace

// Processes
sig Process {}

// Locks
sig Mutex {}

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

  // **********************************************************************
  // the process must not have any lock with higher order than m
  no x:Mutex | some o:MutexOrder | x in p.s::holds && greater_than(x, m, o)
  // **********************************************************************
   
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
      (some p: Process, m: Mutex | s' = GrabMutex(s,p,m))
      ||
      (some p: Process, m: Mutex | s' = ReleaseMutex(s,p,m))
    )
}


// *****************************************************************
// a signature that puts the Mutexes in ascending total order
// *****************************************************************
static sig MutexOrder {
  mutexes: set Mutex,
  smallest: mutexes,
  largest:  mutexes,
  next_M:   (mutexes - largest) !->! (mutexes - smallest)
}{
  // mutexes are totally ordered
  smallest.*next_M =  mutexes

  // all mutexes are ordered by MutexOrder
  all m:Mutex | m in mutexes
}

// *****************************************************************
// function for verifying Mutex m1 has greater order index than m2
// *****************************************************************
fun greater_than(m1:Mutex, m2:Mutex, o:MutexOrder){

    // if m1 is greater than m2, then m2 can reach m1 by transitive    
    // closure of next_M
    m1 in m2.^(o.next_M)
}


//  ****************************************************************
// Functions/Assertions for testing
// *****************************************************************

assert NoDeadlock {
  some Process =>
  all x:StateTrace | some p:Process | no p.((x.last)::(x.state).waits)
}

fun SomeWait () {
  some x:StateTrace | some t:x.ticks | some (x.state)[t].waits
}

// Makes sure there is a case where all Mutexes are used
fun AllUsed() {
  all m:Mutex | some s:State | !IsFree(s, m)     
}

// Check that a process can acquire more than one mutexes
fun MoreThanOne(){
  some p:Process | some m1:Mutex | some m2:Mutex | some s:State |
  m1 in p.(s.holds) && m2 in p.(s.holds) && !(m1 = m2)
}


// *****************************************************************
// Executable commands for testing
// *****************************************************************
check NoDeadlock for 2 but 6State, 6Tick

check NoDeadlock for 2 but 5State, 5Tick

check NoDeadlock for 3 but 7State, 7Tick

run SomeWait for 2 but 5State, 5Tick

run SomeWait for 3

run SomeWait for 4

run SomeWait for 5

run AllUsed for 2 but 3State, 3Tick

run AllUsed for 2 but 5State, 5Tick

run MoreThanOne for 2 but 3State, 3Tick


