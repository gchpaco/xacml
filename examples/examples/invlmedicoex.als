module InvolvedMedicoExample
open xacml/xacml
open xacml/rules
open xacml/attributes
open std/bool

/* attributes from environment */
static sig ENVIRONMENT {
	namespace : scalar String,
	xpath : scalar String,
	action : scalar String,
	policynumber : set String,
	patientnumber : set String,
	parentguardian : set String,
	claimedguardian : set String,
	dateofbirth : set Date,
	dateConditionSatisfied : scalar Bool,
	role : scalar String,
	xpathConditionSatisfied : scalar Bool,
	physicianId : set String,
	primaryCarePhysician : set String
}

/* static constants */
static disj sig MEDICONAMESPACE, MD_RECORD, READ extends String {}
static disj sig PHYSICIAN, WRITE, ADMINISTRATOR extends String {}

static disj sig R1 extends Rule {}
fact R1Conditions {
	R1.intention = Permit
	(ENVIRONMENT.namespace = MEDICONAMESPACE &&
	 ENVIRONMENT.xpath = MD_RECORD) => R1.valid = True,
	R1.valid = False
	not (one ENVIRONMENT.policynumber) => no R1.conditions,
	not (one ENVIRONMENT.patientnumber) => no R1.conditions,
	ENVIRONMENT.policynumber = ENVIRONMENT.patientnumber 
		=> R1.conditions = True,
	R1.conditions = False
}

static disj sig R2 extends Rule {}
fact R2Conditions {
	R2.intention = Permit
	(ENVIRONMENT.namespace = MEDICONAMESPACE &&
	 ENVIRONMENT.xpath = MD_RECORD &&
	 ENVIRONMENT.action = READ) => R2.valid = True,
	R2.valid = False
	not (one ENVIRONMENT.parentguardian) => no R2.conditions,
	not (one ENVIRONMENT.claimedguardian) => no R2.conditions,
	not (one ENVIRONMENT.dateofbirth) => no R2.conditions,
	(ENVIRONMENT.parentguardian = ENVIRONMENT.claimedguardian &&
	 ENVIRONMENT.dateConditionSatisfied = True)
	 	=> R2.conditions = True,
	R2.conditions = False
}

static disj sig P1 extends DenyOverrides {}
static disj sig R3 extends Rule {}
fact P1Conditions {
	P1.subpolicies = R3
	(ENVIRONMENT.namespace = MEDICONAMESPACE &&
	 ENVIRONMENT.xpath = MD_RECORD) => P1.valid = True,
	P1.valid = False
}
fact R3Conditions {
	R3.intention = Permit
	(ENVIRONMENT.role = PHYSICIAN &&
         ENVIRONMENT.xpathConditionSatisfied = True &&
	 ENVIRONMENT.action = WRITE) => R3.valid = True,
	R3.valid = False
	not (one ENVIRONMENT.physicianId) => no R3.conditions,
	not (one ENVIRONMENT.primaryCarePhysician) => no R3.conditions,
	(ENVIRONMENT.physicianId = ENVIRONMENT.primaryCarePhysician)
		=> R3.conditions = True,
	R3.conditions = False
}

static disj sig R4 extends Rule {}
fact R4Conditions {
	R4.intention = Deny
	(ENVIRONMENT.role = ADMINISTRATOR &&
	 ENVIRONMENT.namespace = MEDICONAMESPACE &&
	 ENVIRONMENT.xpathConditionSatisfied = True &&
	 (ENVIRONMENT.action = READ ||
	  ENVIRONMENT.action = WRITE)) => R4.valid = True,
	R4.valid = False
	R4.conditions = True
}

static disj sig P2, P3 extends DenyOverrides {}
fact P2Conditions {
	P2.subpolicies = P1 + P3
	(ENVIRONMENT.namespace = MEDICONAMESPACE) => P2.valid = True,
	P2.valid = False
}
fact P3Conditions {
	P3.subpolicies = R1 + R2 + R4
	P3.valid = True
}

fun SometimesValid () {
	P2.valid = True
}

fun PossibleToSatisfy () {
	P2.effect = Permit
}

fun NotTotal () {
	P2.effect = NotApplicable
}

fun PossibleToDeny () {
	P2.effect = Deny
}

assert ImpossibleToError {
	P2.effect != Indeterminate
}

run SometimesValid for 7 but 4 Result, 2 Bool, 10 Attribute
run PossibleToSatisfy for 7 but 4 Result, 2 Bool, 10 Attribute
run NotTotal for 7 but 4 Result, 2 Bool, 10 Attribute
run PossibleToDeny for 7 but 4 Result, 2 Bool, 10 Attribute
check ImpossibleToError for 7 but 4 Result, 2 Bool, 10 Attribute