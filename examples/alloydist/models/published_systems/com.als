// model of COM rules from Jackson/Sullivan FSE paper
// illustrates subsig, defined fields, potential ambiguity in "with" statement

module published_systems/com

sig IID {}

fun dom [s,t] (rel: s -> t) : s {
  result = { x : s | some x.rel }
}

fun ran [s,t] (rel: s -> t) : t {
  result = { y: t | some y.~rel }
}

sig Interface {
	qi : IID ->? Interface,
  iids : set IID,
  // next two lines should use domain() or range() functions
  iidsKnown : IID,
  reaches : Interface
} {
  iidsKnown = dom(qi)
  reaches = ran(qi)
}

sig Component {
	interfaces : set Interface,
	iids : set IID,   // can't do iids = interfaces.Interface$iids
	first, identity : interfaces,
	eqs = { c : Component | c::identity = identity },
	aggregates : set Component
	}

fact IdentityAxiom {
	some unknown : IID | all c : Component | all i : c.interfaces | unknown.i::qi = c.identity
	}

fact ComponentProps {
	all c : Component | with c {
		iids = interfaces::iids			// must be :: to avoid expansion! Interface$iids?
		all i : interfaces | all x : IID | x.i::qi in interfaces
		}
	}
		
sig LegalInterface extends Interface { }
fact { all i : LegalInterface | all x : i.iidsKnown | x in x.i::qi.iids}

sig LegalComponent extends Component { }
fact { LegalComponent.interfaces in LegalInterface }

fact Reflexivity { all i : LegalInterface | i.iids in i.iidsKnown }
fact Symmetry { all i, j : LegalInterface | j in i.reaches => i.iids in j.iidsKnown }
fact Transitivity { all i, j : LegalInterface | j in i.reaches => j.iidsKnown in i.iidsKnown }

fact Aggregation {
    no c : Component | c in c.^aggregates
    all outer : Component | all inner : outer.aggregates |
      (some inner.interfaces & outer.interfaces)
      && some o: outer.interfaces | all i: inner.interfaces - inner.first | all x: Component  | x::iids.i::qi = x::iids.o::qi
    }

assert Theorem1 {
     all c: LegalComponent | all i: c.interfaces | i.iidsKnown = c.iids
     }

assert Theorem2 {
    all outer: Component | all inner : outer.aggregates |
        inner in LegalComponent => inner.iids in outer.iids
    }

assert Theorem3 {
    all outer: Component | all inner : outer.aggregates | inner in outer.eqs
    }

assert Theorem4a {
      all c1: Component, c2: LegalComponent | 
         some (c1.interfaces & c2.interfaces) => c2.iids in c1.iids
    }

assert Theorem4b {
      all c1, c2: Component | some (c1.interfaces & c2.interfaces) => c1 in c2.eqs
      }

check Theorem1 for 3
