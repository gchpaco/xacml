// Huang's self-stabilizing leader-election algorithm
// for rings

module distalg/stable_ringlead

open std/ord
open std/util

sig Process {
  rightNeighbor: Process//,
  //pRot: Process !->! Process
}

/*fact {
  all pstart: Process | {
     pstart.(Ord[Process].first.pRot) = pstart
     all pshift: Process - Ord[Process].first |
        pstart.(pshift.pRot) =
            (pstart.(OrdPrev(pshift).pRot)).rightNeighbor  
  }
}*/

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
  
fact {
  Ring(Process$rightNeighbor)
  Ord[Val].next + (Ord[Val].last -> Ord[Val].first) = Val$nextVal 
  # Val = # Process
}

sig State {
  val : Process ->! Val,
  running : set Process
  // for visualization
  //leader : set Process
} {
  //leader = { p : Process | LeaderAtState(p, this) }
}

fact {
  no Ord[State].last.running
}

fun LeadersAtState(t : State) : set Process {
  result = { p : Process | LeaderAtState(p,t) }
}

fun LeaderAtState(p : Process, t : State) { ValAtState(p,t) = Ord[Val].first }

fun ValAtState(p : Process, t : State) : Val { result = t.val[p] }

fun LeftValAtState(p : Process, t : State) : Val { result = t.val[p.~rightNeighbor] }

fun RightValAtState(p : Process, t : State) : Val { result = t.val[p.rightNeighbor] }

fun XAtState(p : Process, t : State) : Int {
  result = g(LeftValAtState(p,t),ValAtState(p,t))
}

fun YAtState(p : Process, t : State) : Int {
  result = g(ValAtState(p,t),RightValAtState(p,t))
}

fun g(a, b : Val) : Int {
  result = Int if (a = b) then (# Val) else int minus(b,a)
--  result = if (a = b) then Int (# Val) else minus(b,a)
}

fun minus(v1, v2 : Val) : Int {
  result = Int if (v1 = v2) 
               then 0  
               else if OrdGT(v1, v2) 
                 then (# (OrdNexts(v2) & OrdPrevs(v1) + v1))
                 else (# (Val - (OrdNexts(v1) & OrdPrevs(v2) + v1)))
} 

fun Trans(oldVal : Val, x, y : Int) : Val {
  result = if ((int x = int y && int y = # Val) ||
               (int x < int y)) then oldVal.nextVal else oldVal
}

fun OneAtATimeTrans( ) {
  all tp: State - Ord[State].last |
    let tn = OrdNext(tp) |
      some p : Process | {
        tp.running = p
        TransHelper(p,tp,tn)
        all other : Process - p |
          ValAtState(other,tn) = ValAtState(other,tp)
      }
}

fun DDaemonTrans( ) {
  all tp: State - Ord[State].last |
    let tn = OrdNext(tp) | {
      some tp.running
      all p : tp.running | TransHelper(p,tp,tn)
      all other : Process - tp.running |
        ValAtState(other,tn) = ValAtState(other,tp)
    }
}
  
fun TransHelper(p : Process, tp, tn : State) {
        let oldVal = ValAtState(p, tp),
            newVal = ValAtState(p, tn),
            x = XAtState(p, tp),
            y = YAtState(p,tp) | 
          newVal = Trans(oldVal, x, y)

}

fun StateTrans(s, s' : State) {
  all p : Process |
    TransHelper(p, s, s') || ValAtState(p,s) = ValAtState(p,s')
}



fun CBadLivenessTrace ( ) {
  OneAtATimeTrans( )
  BadLivenessHelper( )
}

fun DBadLivenessTrace ( ) {
  DDaemonTrans( )
  BadLivenessHelper( )
}

fun BadLivenessHelper( ) {
  let ls = Ord[State].last |
    some s : State - ls | {
      s.val = ls.val
      // fair
      Process in (OrdNexts(s) + s - ls).running
    }
    all s : State | ! Legit(s)
  }

fun CTraceWithoutLoop ( ) {
  OneAtATimeTrans( )
  all disj t, t' : State |
    t.val != t'.val
  //all s : State | ! Legit(s)
    //!SimilarStates(t.val, t'.val)
    //!Isomorphic(t.val, t'.val)
}

fun DTraceWithoutLoop ( ) {
  DDaemonTrans( ) 
  all disj t, t' : State | {
    t.val != t'.val
    (t' in OrdNexts(t) && t' != OrdNext(t)) => !StateTrans(t,t')
  }
  all t : State | !Legit(t)
}

/*fun SimilarStates(val1, val2: Process ->! Val) {
  some shift: Val, pshift: Process |
    all p : Process, v: Val | 
      p->v in val1 iff ((p.(pshift.pRot))->(v.(shift.rot))) in val2
}*/

fun ConvergingRun ( ) {
  OneAtATimeTrans( )
  !Legit(Ord[State].first)
  some t : State | Legit(t)
}

fun OnlyFairLoops( ) {
  OneAtATimeTrans( )
  all s, s' : State |
   (s' in OrdNexts(s) && s'.val = s.val) =>
     let loopStates = (OrdNexts(s) & OrdPrevs(s')) + s + s' |
       Process in loopStates.running
}

assert CMustConverge {
  OnlyFairLoops( ) => some s : State | Legit(s)
}

fun Legit (s : State) {
  one LeadersAtState(s)
  all p : Process | {
    int XAtState(p,s) < # Val
    int YAtState(p,s) < # Val
  } 
  all p, p' : Process | {
    int XAtState(p,s) = int XAtState(p',s)
    int YAtState(p,s) = int YAtState(p',s)
  }
}
    
  
//run ConvergingRun for 3 but 4State      
//run TraceWithoutLoop for 5 but 12State
//run DTraceWithoutLoop for 3 but 4State
//run DBadLivenessTrace for 3 but 4State
run CTraceWithoutLoop for 3 but 5State
//run CBadLivenessTrace for 4 but 5State
//check LegitOneLeader for 4 but 1State
//check CMustConverge for 3 but 4State  