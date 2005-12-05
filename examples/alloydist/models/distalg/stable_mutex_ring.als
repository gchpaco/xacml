// Dijkstra's K-state mutual exclusion algorithm
// for a ring
// First proof using Alloy!!!

// Original paper describing the algorithm:
// [1] E.W.Dijkstra, "Self-Stabilizing Systems in Spite of Distributed Control",
// Comm. ACM, vol. 17, no. 11, pp. 643-644, Nov. 1974

// Proof of algorithm's correctness:
// [2] E.W.Dijkstra, "A Belated Proof of Self-Stabilization",
// in Distributed Computing, vol. 1, no. 1, pp. 5-6, 1986

// SMV analysis of this algorithm is described in:
// [3] "Symbolic Model Checking for Self-Stabilizing Algorithms",
// by Tatsuhiro Tsuchiya, Shini'ichi Nagano, Rohayu Bt Paidi, and Tohru Kikuno,
// in IEEE Transactions on Parallel and Distributed Systems,
// vol. 12, no. 1, January 2001

// Use stable_mutex_ring.cst for visualization.

// Description of algorithm (adapted from [3]):

// Consider a distributed system that consists of n processes connected in the
// form of a ring.  We assume the state-reading model in which processes can
// directly read the state of their neighbors.  We define _privilege_ of a process
// as its ability to change its current state.  This ability is based on a Boolean
// predicate that consists of its current state and the state of one of its
// neighboring processes.

// We then define the legitimate states as those in which the following two properties hold:
// 1) exactly one process has a privilege, and 2) every process will eventually have
// a privilege.  These properties correspond to a form of mutual exclusion, because the
// privileged process can be regarded as the only process that is allowed in its critical
// section.

// In the K-state algorithm, the state of each process is in {0,1,2,...,K-1}, where
// K is an integer larger than or equal to n.  For any process p_i, we use the symbols
// S and L to denote its state and the state of its neighbor p_{i-1}, respectively,
// and process p_0 is treated differently from all other processes.  The K-state
// algorithm is described below.

// * process p_0: if (L=S) { S := (S+1) mod K; }
// * process P_i(i=1,...,n-1): if (L!=S) { S:=L; }

module distalg/stable_mutex_ring

open std/ord
open std/util

sig Process {
  rightNeighbor: Process
}

sig Val {
  nextVal : Val//,
  //rot : Val !->! Val
}

/*fact {
  all vstart: Val | {
     vstart.(Ord[Val].first.rot) = vstart
     all vshift: Val - Ord[Val].first |
        vstart.(vshift.rot) =
            (vstart.(OrdPrev(vshift).rot)).nextVal  
  }

}*/

fact MoreValThanProcess {
  # Val > # Process
}

fact DefineRings {
  Ring(Process$rightNeighbor)
  Ring(Val$nextVal)
  //Val$nextVal = Ord[Val].next + (Ord[Val].last -> Ord[Val].first)
}

sig Tick {
  val: Process ->! Val,
  runs: set Process,    // processes scheduled to run on this tick
  // for visualization
  priv: set Process  // the set of priviledged processes on this tick
}
{
  priv = { p : Process | Privileged(p, this) }
}

static sig FirstProc extends Process {
}


det fun FirstProcTrans(curVal, neighborVal : Val): Val {
  result = if (curVal = neighborVal) then curVal.nextVal else curVal
}

det fun RestProcTrans(curVal, neighborVal : Val): Val {
  result = if (curVal != neighborVal) then neighborVal else curVal
}

fact LegalTrans {
  all tp : Tick - Ord[Tick].last |
    let tn = OrdNext(tp) | {
        all p: Process |
           let curVal = tp.val[p], neighborVal = tp.val[p.rightNeighbor], newVal = tn.val[p] | {
                p !in tp.runs => newVal = curVal else {
                   p = FirstProc => 
                       newVal = FirstProcTrans(curVal, neighborVal) 
                   else
                       newVal = RestProcTrans(curVal, neighborVal)
                }  
          }
      }
}

fun TickTrans(tp, tn : Tick) {
  all p : Process |
    let curVal = tp.val[p], neighborVal = tp.val[p.rightNeighbor], newVal = tn.val[p] | {
                   p = FirstProc => 
                       newVal = FirstProcTrans(curVal, neighborVal) 
                   else
                       newVal = RestProcTrans(curVal, neighborVal)
    }
}
fun Privileged(p : Process, t : Tick) {
  // whether this process can enter its critical section
  // on this tick
  p = FirstProc =>
    t.val[p] = t.val[p.rightNeighbor]
  else 
    t.val[p] != t.val[p.rightNeighbor]
}

fun IsomorphicStates(val1, val2: Process ->! Val) {
   some processMap: Process !->! Process,
        valMap: Val !->! Val | {
       FirstProc.processMap = FirstProc
       all p: Process, v: Val |  {
          p->v in val1 iff (p.processMap) -> (v.valMap) in val2
       }
       all v1,v2: Val | v1->v2 in Val$nextVal iff (v1.valMap) ->  (v2.valMap) in Val$nextVal
       all p1,p2: Process | p1->p2 in Process$rightNeighbor
               iff (p1.processMap) ->  (p2.processMap) in Process$rightNeighbor
   }
}

/*fun SimilarStates(val1, val2: Process ->! Val) {
  some t1, t2 : Tick, shift: Val |
    all p : Process, v: Val | 
      p->v in val1 iff (p->(v.(shift.rot))) in val2
}*/

/*fun doShift(v, shift : Val) : Val {
  result = { v' : Val | v' = plus(v,minus(shift, Ord[Val].first)) }
}

fun plus(v : Val, i : Int) : Val {
 // let real_i = int i |
    result = { x: Val | # between(v,x) = int i }
}

fun between(v1, v2: Val) : set Val {
  result = if (v1 = v2)
             then none[Val]
             else if OrdGT(v2,v1)
               then OrdNexts(v1) & OrdPrevs(v2) + v2
               else (Val - (OrdNexts(v1) & OrdPrevs(v2) + v1))
}

fun minus(v1, v2 : Val) : Int {
   result = Int # between(v2,v1)
} */

fun BadSafetyTrace ( ) {
  // Find a trace that goes into a loop
  // containing a bad tick, i.e. a tick
  // at which two distinct processes
  // try to run their critical sections
  // simultaneously.  In such a trace the
  // algorithm never "stabilizes".
  let lt = Ord[Tick].last |
    some t : Tick - lt | {
      //IsomorphicStates(ft.val, lt.val)
      t.val = lt.val
      Process in (OrdNexts(t) + t - lt).runs
      some badTick : OrdNexts(t) + t |
        BadTick(badTick)
    }
}

fun BadTick(badTick : Tick) {
      // Two different processes simultaneously
      // try to run their critical sections at this tick
      some disj p1 , p2 : Process | {
        Privileged(p1, badTick)
        Privileged(p2, badTick)
      }
}

assert Closure {
  not BadTick(Ord[Tick].first) =>
    all t : Tick |
      not BadTick(t)
}

fun TwoPrivileged ( ) {
  BadTick(Ord[Tick].first)
  some disj p1, p2 : Process, t1, t2 : Tick - Ord[Tick].first | {
    Privileged(p1,t1)
    Privileged(p2,t2)
  }
}

fun TraceWithoutLoop ( ) {
  all disj t1, t2 : Tick | {
    t1.val != t2.val
  //sole { t : Tick | one t.val[Process] }
  //(t2 in OrdNexts(t1) && (t2 != OrdNext(t1))) => !TickTrans(t1,t2)
  }
  //all t : Tick | BadTick(t)
}

fun TraceShorterThanMaxSimpleLoop ( ) {
  Ord[Tick].first.val = Ord[Tick].last.val
  all t : Tick - Ord[Tick].first - Ord[Tick].last |
    !(t.val = Ord[Tick].first.val)
}

//run TraceShorterThanMaxSimpleLoop for 7 but 2Process, 3Val
//run TwoPrivileged for 5 but 3Process, 4Val



//check Closure for 5 but 5Process, 6Val
//run BadSafetyTrace for 16 but 3Process, 4Val
run TraceWithoutLoop for 21 but 4Process, 5Val


