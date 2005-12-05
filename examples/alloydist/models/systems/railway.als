module models/railway

sig Seg {next, overlaps: set Seg}
fact {all s: Seg | s in s.overlaps}
fact {all s1, s2: Seg | s1 in s2.overlaps => s2 in s1.overlaps}

sig Train {}
sig GateState {closed: set Seg}
sig TrainState {on: Train ->? Seg, occupied: set Seg}
fact {all x: TrainState |
	x.occupied = {s: Seg | some t: Train | t.(x.on) = s}
	}

fun Safe (x: TrainState) {all s: Seg | sole s.overlaps.~(x.on)}

fun MayMove (g: GateState, x: TrainState, ts: set Train) {
	no ts.(x.on) & g.closed
	}
	
fun TrainsMove (x, x': TrainState, ts: set Train) {
  all t: ts | t.(x'.on) in t.(x.on).next
	all t: Train - ts | t.(x'.on) = t.(x.on)
	}
	
fun GatePolicy (g: GateState, x: TrainState) {
	x.occupied.overlaps.~next in g.closed
  all s1, s2: Seg | some s1.next.overlaps & s2.next => sole (s1+s2) - g.closed
}

assert PolicyWorks {
	all x, x': TrainState, g: GateState, ts: set Train |
		{MayMove (g, x, ts)
		TrainsMove (x, x', ts)
		Safe (x)
		GatePolicy (g, x)
		} => Safe (x')
	}
	
-- has counterexample in scope of 4
check PolicyWorks for 4

fun TrainsMoveLegal (x, x': TrainState, g: GateState, ts: set Train) {
	TrainsMove (x, x', ts)
	MayMove (g, x, ts)
	GatePolicy (g, x)
	}
-- run TrainsMoveLegal for 3
