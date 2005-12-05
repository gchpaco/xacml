//
// Model of how mutexes are grabbed and released
// by processes, and how Dijkstra's mutex ordering
// criterion can prevent deadlocks.
//


module distalg/dijkstra

open std/ord

sig Process {}
sig Mutex {}

sig State {
   holds, waits: Process -> Mutex
}
  

fun State.Initial () {
  no this.holds + this.waits
}
        
fun State.IsFree (m: Mutex) {
   // no process holds this mutex
   no m.~(this::holds)
   // all p: Process | m !in p.(this.holds)
}

fun State.IsStalled (p: Process) {
  some p.this::waits
}

det fun State.GrabMutex (p: Process, m: Mutex): State {
   // a process can only act if it is not 
   // waiting for a mutex
   !this..IsStalled(p)
   // can only grab a mutex we do not yet hold
   m !in p.this::holds
   this..IsFree (m) => {
      // if the mutex is free, we now hold it,
      // and do not become stalled
      p.result::holds = p.this::holds + m
      no p.result::waits
   } else {
    // if the mutex was not free,
    // we still hold the same mutexes we held,
    // and are now waiting on the mutex
    // that we tried to grab.
    p.result::holds = p.this::holds
    p.result::waits = m
  }
  all otherProc: Process - p | {
     otherProc.result::holds = otherProc.this::holds
     otherProc.result::waits = otherProc.this::waits
  }
}
        
det fun State.ReleaseMutex (p: Process, m: Mutex): State {
   !this..IsStalled(p)
   m in p.this::holds
   p.result::holds = p.this::holds - m
   no p.result::waits
   no m.~(this::waits) => {
      no m.~(result::holds)
      no m.~(result::waits)
   } else {
      some lucky: m.~(this::waits) | {
        m.~(result::waits) = m.~(this::waits) - lucky
        m.~(result::holds) = lucky
      }
   }
  all mu: Mutex - m {
    mu.~(result::waits) = mu.~(this::waits)
    mu.~(result::holds)= mu.~(this::holds)
  }
}

// for every adjacent (pre,post) pair of States,
// one action happens: either some process grabs a mutex,
// or some process releases a mutex,
// or nothing happens (have to allow this to show deadlocks)
fun GrabOrRelease () {
    Initial(Ord[State].first) &&
    (
    all pre: State - Ord[State].last | let post = OrdNext(pre) | 
       (post.holds = pre.holds && post.waits = pre.waits)
        ||
       (some p: Process, m: Mutex | post = pre..GrabMutex (p, m))
        ||
       (some p: Process, m: Mutex | post = pre..ReleaseMutex (p, m))
    
    )
}

//fact {
//   all s: State, p: Process, m: Mutex |
//        ( OrdNext(s) = s..GrabMutex(p,m) =>
//          m.^(Ord[Mutex].prev) in p.s::holds )
//}

fun Deadlock () {
         some s: State | all p: Process | some p.s::waits
}

//assert NoDeadlock {
//      no t: StateTrace | GrabOrRelease (t) && Deadlock (t)
//      }

fun GrabbedInOrder ( ) {
   all pre: State - Ord[State].last |
     let post = OrdNext(pre) |
        let had = Process.(pre.holds), have = Process.(post.holds) |
        let grabbed = have - had |
           some grabbed => grabbed in OrdNexts(had)
}

assert DijkstraPreventsDeadlocks {
   some Process && GrabOrRelease() && GrabbedInOrder() => ! Deadlock()
}


fun ShowDijkstra ( ) {
        GrabOrRelease () //&& Deadlock ()
        some State$waits
}

//run ShowDijkstra for 4


//eval ShowDijkstra using Instance1 for 2
nodeadlock : check DijkstraPreventsDeadlocks for 6
deadlock : run Deadlock for 3
