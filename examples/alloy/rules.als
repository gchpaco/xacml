module xacml/rules
open xacml/xacml
open std/bool

sig Rule extends Element {
	intention: scalar Result,
	conditions: option Bool
}

fact NoOtherElements {
	all e:Element { e in Rule || e in Policy }
	no (Rule & Policy)
}

fact RuleIntentions { all r:Rule | r.intention = Permit || r.intention = Deny }
fact RuleConditionApplies { all r:Rule {
	r.valid = False => r.effect = NotApplicable,
	(no r.conditions) => r.effect = Indeterminate,
	r.conditions = True => r.effect = r.intention,
	r.effect = NotApplicable
} }

fun IndeterminateRulesExist () {
	some r:Rule { r.effect = Indeterminate }
	some r:Rule { r.effect = NotApplicable }
	some r:Rule { r.effect = Permit }
	some r:Rule { r.effect = Deny }
}

run IndeterminateRulesExist for 4 but 4 Result, 2 Bool