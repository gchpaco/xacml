
module systems/bart

sig Seg {next, overlaps: set Seg}
fact {all s: Seg | s in s.overlaps}
fact {all s1, s2: Seg | s1 in s2.overlaps => s2 in s1.overlaps}

sig Train {}
sig GateState {closed: set Seg}
sig TrainState {on: Train ->! Seg, occupied: set Seg}
fact {all x: TrainState |
        x.occupied = {s: Seg | some t: Train | t.(x.on) = s}
        }

fun Safe (x: TrainState) {all disj ta, tb: Train | ta.(x.on) !in tb.(x.on).overlaps}

fun MayMove (g: GateState, x: TrainState, movers: set Train) {
        no movers.(x.on) & g.closed
        }
        
fun TrainsMove (x, x': TrainState, movers: set Train) {
        all t: movers | t.(x'.on) in t.(x.on).next
        all t: Train - movers | t.(x'.on) = t.(x.on)
        }
        
fun GatePolicy (g: GateState, x: TrainState) {
--      x.occupied.overlaps.~next in g.closed
        x.occupied.~next in g.closed
  all s1, s2: Seg | some s1.next & s2.next.overlaps => sole (s1+s2 - g.closed)
}

fact {all s: Seg | sole s.next}

assert PolicyWorks {
        all x, x': TrainState, g: GateState, movers: set Train |
                {MayMove (g, x, movers)
                TrainsMove (x, x', movers)
                Safe (x)
                GatePolicy (g, x)
                } => Safe (x')
        }
        
-- has counterexample in scope of 3
policy : check PolicyWorks for 3

