module distalg/s_ringlead

//
// Leader Election on a Ring
//
// Each process has a unique ID, IDs are ordered.
// The algorithm elects the process with the highest
// ID the leader, as follows.  First, each process
// sends its own ID to its right neighbor.
// Then, whenever a process receives an ID, if the
// ID is greater than the process' own ID it forwards
// the ID to its right neighbor, otherwise does nothing.
// When a process receives its own ID that process
// is the leader.
//

open std/ord
open std/util

sig Process {
  rightNeighbor: Process
}

sig State {
  // buffer which the right neighbor can read from
  buffer: Process -> Process,
  //sends, reads: Process -> Process,
  runs: set Process,
  leader: set Process
}

fact DefineRing {
  Ring(Process$rightNeighbor)
}
  
fact InitialState {
  no Ord[State].first.buffer
  no Ord[State].first.leader
  Process in Ord[State].first.runs
}


fact CleanupLast {
  let ls=Ord[State].last |
    no ls.runs
}

/*fun ValidTransition(s, s': State) {
  all p : s.runs | TransHelper(p, s, s')
  all p: Process - s.runs | NOP(p,s,s')
  all p : Process | 
    s'.buffer[p] = (s.buffer[p] - s.reads[p.rightNeighbor]) + s.sends[p]
}*/


/*fun TransHelper(p : Process, s, s' : State) {
    // if didn't initialize, send own id
    (s = Ord[State].first) => {
      s.sends[p] = p
      no s.reads[p]
      p !in s'.leader
    } else {
      // see if there is something to read
      (some s.buffer[p.~rightNeighbor]) => {
        // pick a message
        some m : set s.buffer[p.~rightNeighbor] | {
          s.reads[p] = m
          // add to sends if greater
          s.sends[p] = { m': m | OrdGT(m',p) }//m & OrdNexts(p)
          p in s'.leader iff (p in s.leader || p in m)
        }
      } else NOP(p,s,s') // don't do anything
    }
}*/

fun ValidTrans2(s, s': State) {
  all p : s.runs | VT2Helper(p,s,s')
  all p : Process - s.runs | NOP2(p,s,s')
  NoMagicMsg(s,s')
  
}

fun NoMagicMsg(s, s' : State) {
    // no magically appearing messages
    all p : Process, m : s'.buffer[p] |
      m in s.buffer[p] || (!NOP2(p,s,s') && 
                            ((s = Ord[State].first && m = p) ||
                             (s != Ord[State].first && m in s.buffer[p.~rightNeighbor] 
                              && m !in s'.buffer[p.~rightNeighbor] && OrdGT(m,p))))
}

fun PossTrans(s, s' : State) {
  all p : Process | VT2Helper(p,s,s') || NOP2(p,s,s')
  NoMagicMsg(s,s')
}

fun VT2Helper(p : Process, s, s' : State) {
    (
      let readable=s.buffer[p.~rightNeighbor] | 
        (s = Ord[State].first) => {
          p = s'.buffer[p]
          readable in s'.buffer[p.~rightNeighbor] 
          p !in s'.leader
        } else {
          (some readable) => {
           some m : set readable | {
             m !in s'.buffer[p.~rightNeighbor]
             // nothing else gets deleted
             readable - m in s'.buffer[p.~rightNeighbor]
             { m': m | OrdGT(m',p) } /*m & OrdNexts(p)*/ in s'.buffer[p]
             p in s'.leader iff (p in s.leader || p in m)
           }
          } else NOP2(p,s,s')
        }
    )
}
/*fun ValidTrans3(s, s': State) {
  some runs' : set Process | {
    s.runs = runs'
    all p : runs' |
      let readable=s.buffer[p.~rightNeighbor] | 
        (s in Ord[State].first) => {
          p = s'.buffer[p]
          s.sends[p] = p
          readable in s'.buffer[p.~rightNeighbor] 
          no s.reads[p]
          p !in s'.leader
        } else {
          (some readable) => {
           some m : readable | {
             s.reads[p] = m
             m !in s'.buffer[p.~rightNeighbor]
             // nothing else gets deleted
             readable - m in s'.buffer[p.~rightNeighbor]
             OrdGT(m,p) => (m in s'.buffer[p] && s.sends[p] = m) else (s'.buffer[p] in s.buffer[p] && no s.sends[p])
             p in s'.leader iff (p in s.leader || p = m)
           }
          } else NOP2(p,s,s')
        }
      
    all p : Process - runs' | NOP2(p,s,s')
    // no magically appearing messages
    all p : Process, m : s'.buffer[p] |
      m in s.buffer[p] || (p in runs' && 
                            ((s = Ord[State].first && m = p) ||
                             (s != Ord[State].first && m in s.buffer[p.~rightNeighbor] 
                              && m !in s'.buffer[p.~rightNeighbor] && OrdGT(m,p))))
  }
}*/

fun NOP2(p : Process, s,s': State) {  
  p in s'.leader iff p in s.leader
  // no reads
  s.buffer[p.~rightNeighbor] in s'.buffer[p.~rightNeighbor]
  // no sends
  s'.buffer[p] in s.buffer[p]
}
    
    
/*fun NOP(p : Process, s, s' : State) {
  p in s'.leader iff p in s.leader
  no s.reads[p]
  no s.sends[p]
}*/

fun Preconds(p : Process, s : State) {
  s = Ord[State].first || some s.buffer[p.~rightNeighbor]
}

fact TransIfPossible {
  all s : State - Ord[State].last |
    (all p : Process | NOP2(p, s, OrdNext(s))) =>
      all p : Process | !Preconds(p,s)
}
  
fact LegalTrans {
  all s : State - Ord[State].last |
    let s' = OrdNext(s) |       
      ValidTrans2(s,s')
}
           
fun EquivStates(s, s': State) {
  s.buffer = s'.buffer
  s.leader = s'.leader
}

assert Safety {
  all s : State | sole s.leader
}

fun Legit(s : State) {
  one s.leader
}

fun BadLivenessTrace( ) {
  all s : State | !Legit(s)
  let ls = Ord[State].last |
    some s : State - ls | {
      EquivStates(s, ls)
      Process in (OrdNexts(s) + s).runs
    }
}

fun TraceWithoutLoop ( ) {
  all disj t1, t2 : State |
    !EquivStates(t1,t2)
  all s, s' : State | (s' in (OrdNexts(s) - OrdNext(s))) => !PossTrans(s,s')
  all s : State | !Legit(s)
}

/*assert TransEquiv {
  all s : State - Ord[State].last |
    let s' = OrdNext(s) |
      ValidTransition(s,s')
}*/

fun AltTrans ( ) {
  SomeLeader( )
}

fun SomeLeader() { some State.leader }

liveness : run BadLivenessTrace for 3 but 8State

someleader : run SomeLeader for 4 but 6State

//check Safety for 7

//run TraceWithoutLoop for 5 but 13State
//run AltTrans for 5 but 8State
