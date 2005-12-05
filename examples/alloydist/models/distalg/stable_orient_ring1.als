module distalg/stable_orient_ring1

//
// A self-stabilizing algorithm for orienting uniform rings.
// Communication model is the state-reading model.
//

open std/ord
open std/util
open std/bool

sig Process {
  rightNeighbor: Process,
  AP1, AP2: Process
}

fun leftNeighbor(p: Process): Process {
  result = p.~(Process$rightNeighbor)
}

fact {
  all p: Process {
     (p.AP1=p.rightNeighbor && p.AP2=leftNeighbor(p)) ||
     (p.AP2=p.rightNeighbor && p.AP1=leftNeighbor(p))
  }
}

fact DefineRing {
  Ring(Process$rightNeighbor)
}

sig Tick {
  runs: set Process,
  dir, S, T: Process ->! Bool,
  ring: Process -> Process
}
{
  all p: Process | p.ring = if p.dir=True then p.AP1 else p.AP2
}

fun Eq3(b1,b2,b3: Bool) { b1 = b2 && b2 = b3 }
fun Eq4(b1,b2,b3,b4: Bool) { Eq3(b1,b2,b3) && b3=b4 }
fun Not(b: Bool): Bool { result = BoolNot(b) }

fact  Transitions {
   all tp: Tick - Ord[Tick].last | let tn = OrdNext(tp) |
       all p: Process |
        let p1 = p.AP1, p2 = p.AP2, pS = tp.S, pT=tp.T, nS=tn.S, nT=tn.T |
           let S1p=p1.pS, S2p=p2.pS,
               T1p=p1.pT, T2p=p2.pT,
               S1n=p1.nS, S2n=p2.nS,
               T1n=p1.nT, T2n=p2.nT,
               Sp = p.pS, Sn=p.nS,
               Tp = p.pT, Tn=p.nT,
               dirp = p.(tp.dir), dirn = p.(tn.dir) | {
           p !in tp.runs => ( Sn = Sp && Tn = Tp && dirn = dirp ) else (
           S1p = S2p => ( Sn = Not(S1p) && Tn = True && dirn=dirp) else (
             (Eq3(S1p, Sp, Not(S2p)) &&
              Eq4(Not(T1p),Tp,T2p,True)) => 
                (Sn = Not(Sp) && Tn = False && dirn = True)
              else (
                 (Eq3(Not(S1p),Sp,S2p) && Eq4(T1p,Tp,Not(T2p),True)) =>
                 (Sn = Not(Sp) && Tn = False && dirn = False) else (
                    ((Eq3(S1p,Sp,Not(S2p)) && T1p=Tp) ||
                    (Eq3(Not(S1p),Sp,S2p) && Tp=T2p)) =>
                    (Tn = Not(Tp) && Sn=Sp && dirn=dirp) else (
                       Sn=Sp && Tn=Tp && dirn=dirp
                    )
                 )
              )
           )
         )
       }
}

fun RingAtTick(t: Tick) {
   let rng = t.ring |
      Ring(rng) || Ring(~rng)
}

assert Closure {
   // if the ring is properly oriented
   all t: Tick - Ord[Tick].last |
      RingAtTick(t) => RingAtTick(OrdNext(t))
}

fun SomeState ( ) {
   !Ring(Ord[Tick].first.ring)
   some t: Tick | Ring(t.ring)
}

run SomeState for 1 but 2 Tick, 2 Bool, 3Process
check Closure for 1 but 2 Tick, 2 Bool, 3 Process