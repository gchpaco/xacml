module MedicoExample
open xacml/xacml
open xacml/rules
open xacml/attributes
open std/bool

/* attributes from environment */
static sig ENVIRONMENT {
	subject_id : scalar RFC822Name
}

/* static constants */
static sig MEDICO extends RFC822Name {}

static sig R1 extends Rule {}
fact R1Conditions {
	R1.intention = Permit
	(ENVIRONMENT.subject_id = MEDICO) => R1.valid = True,
	R1.valid = False
	R1.conditions = True
}

static sig P1 extends DenyOverrides {}
fact P1Conditions {
	P1.valid = True
	P1.subpolicies = R1
}

fun PossibleToSatisfy () {
	P1.effect = Permit
}

fun NotTotal () {
	P1.effect = NotApplicable
}

fun PossibleToDeny () {
	P1.effect = Deny
}

assert ImpossibleToError {
	P1.effect != Indeterminate
}

run PossibleToSatisfy for 2 but 4 Result, 2 Bool
run NotTotal for 2 but 4 Result, 2 Bool
run PossibleToDeny for 4 but 4 Result, 2 Bool
check ImpossibleToError for 4 but 4 Result, 2 Bool