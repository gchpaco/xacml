module mywork/lockingOrdered

open std/ord

sig Process {}
sig Mutex {}

sig State {
  holds, waits: Process -> Mutex
}

fun Initial( s:State ) {
  no s.holds + s.waits
}

fun IsFree( s:State, m:Mutex ) {
  no (s.holds).m
}

fun IsStalled( s:State, p:Process ) {
  some p.s::waits
}

fun IsInOrder( s:State, p:Process, m:Mutex ) {
  p.s::holds in OrdPrevs(m)
}

fun GrabMutex( s, s':State, p:Process, m:Mutex ) {
  ! IsStalled(s,p)
  IsInOrder(s,p,m)
  IsFree(s,m) => {
    p.s'::holds = p.s::holds + m 
    no p.s'::waits 
  } else {
    p.s'::holds = p.s::holds
    p.s'::waits = m
  }
  all other:Process - p | (
    other.s'::holds = other.s::holds &&
    other.s'::waits = other.s::waits
  )
}

fun ReleaseMutex( s, s':State, p:Process, m:Mutex ) {
  ! IsStalled(s,p)
  m in p.s::holds
  p.s'::holds = p.s::holds - m
  no p.s'::waits  // is this really needed?
  no m.~s::waits => {
    no m.~s'::holds
    no m.~s'::waits
  }
  else {
    some lucky: m.~s::waits | {
      m.~s'::waits = m.~s::waits - lucky
      m.~s'::holds = lucky
    }
  }
  all mu: Mutex - m {
    m.~s'::waits = m.~s::waits
    m.~s'::holds = m.~s::holds
  }
}


sig Tick {}

static sig StateTrace {
  ticks: set Tick,
  first: ticks,
  last: ticks,
  next: (ticks-last) !->! (ticks-first),
  state: ticks ->! State
}{
  first.*next = ticks
  Initial(first.state)
  all t: ticks-last |
    some s=t.state, s'=t.next.state | (
      (some p: Process, m: Mutex | GrabMutex(s,s',p,m))
      ||
      (some p: Process, m: Mutex | ReleaseMutex(s,s',p,m))
    )
}

fun Deadlock () {
  some Process &&
  some x: StateTrace | all p:Process | some p.(((x.last).(x.state)).waits)
}

run Deadlock for 4

run Deadlock for 2 but 5State, 5Tick

run Deadlock for 3 but 10State, 10Tick

fun SomeHold () {
  some x:StateTrace | some p:Process | not sole (x.state[x.last]).holds[p]
}

run SomeHold for 3

