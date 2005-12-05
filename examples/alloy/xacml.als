module xacml/xacml
open std/util
open std/ord
open std/bool

sig Result {}
static part sig Permit, Deny, NotApplicable, Indeterminate extends Result {}

sig Element {
	valid: scalar Bool,
	effect: scalar Result
}
sig Policy extends Element {
	subpolicies: set Element
} {
	IsTree (Policy$subpolicies)
	no subpolicies => effect = NotApplicable
}

part sig PermitOverrides, DenyOverrides, FirstApplicable, OnlyOneApplicable extends Policy {}
fact PermitRule { all p:PermitOverrides |
	p.valid = False => p.effect = NotApplicable,
	Indeterminate in p.subpolicies.effect => p.effect = Indeterminate,
	Permit in p.subpolicies.effect => p.effect = Permit,
	Deny in p.subpolicies.effect => p.effect = Deny,
	p.effect = NotApplicable
}
fact DenyRule { all p:DenyOverrides |
	p.valid = False => p.effect = NotApplicable,
	Indeterminate in p.subpolicies.effect => p.effect = Indeterminate,
	Deny in p.subpolicies.effect => p.effect = Deny,
	Permit in p.subpolicies.effect => p.effect = Permit,
	p.effect = NotApplicable
}
fact OnlyOneRule { all p:OnlyOneApplicable |
	p.valid = False => p.effect = NotApplicable,
	Indeterminate in p.subpolicies.effect => p.effect = Indeterminate,
	p.subpolicies.effect = NotApplicable => p.effect = NotApplicable,
	((sole s:p.subpolicies | s.effect = Deny) &&
	 (no s:p.subpolicies | s.effect = Permit)) => p.effect = Deny,
	((sole s:p.subpolicies | s.effect = Permit) &&
	 (no s:p.subpolicies | s.effect = Deny)) => p.effect = Permit,
	p.effect = Indeterminate
}
fact FirstRule { all p:FirstApplicable {
	p.valid = False => p.effect = NotApplicable,
	Indeterminate in p.subpolicies.effect => p.effect = Indeterminate,
	some s:p.subpolicies {
		some p.subpolicies & OrdPrevs(s) =>
		(p.subpolicies & OrdPrevs(s)).effect = NotApplicable
		s.effect != NotApplicable
		p.effect = s.effect
	}
	(all s:p.subpolicies | s.effect = NotApplicable)
		=> p.effect = NotApplicable
} }

fun MultipleDeniesWork () {
	some p:OnlyOneApplicable {
		p.effect = Indeterminate
		p.subpolicies.effect = Deny
	}
}
fun MultiplePermitsWork () {
	some p:OnlyOneApplicable {
		p.effect = Indeterminate
		p.subpolicies.effect = Permit
	}
}
fun DenyLaterOnStillPermits () {
	some p:FirstApplicable {
		p.effect != Deny
		p.effect != Indeterminate
		Deny in p.subpolicies.effect
		NotApplicable !in p.subpolicies.effect
	}
}
assert NoBadOnlyOnes {
	no p:OnlyOneApplicable {
		p.effect = NotApplicable
		NotApplicable & p.subpolicies.effect != p.subpolicies.effect
	}
	no p:OnlyOneApplicable {
		p.effect != Indeterminate
		Indeterminate in p.subpolicies.effect
	}
}
assert FindErrors {
	/* this represents my desire to find errors over the purity of 
	 * the spec */
	all p:Policy |
	Indeterminate in p.subpolicies.effect => p.effect = Indeterminate
}
run MultipleDeniesWork for 3 but 4 Result
run MultiplePermitsWork for 3 but 4 Result
run DenyLaterOnStillPermits for 3 but 4 Result
check NoBadOnlyOnes for 8 but 4 Result
check FindErrors for 8 but 4 Result