module xacml/attributes
open xacml/xacml
open std/bool

sig Attribute {}
disj sig RFC822Name, X500Name extends Attribute {}
disj sig String, Boolean, Integer, Double extends Attribute {}
disj sig YearMonthDuration, DayTimeDuration extends Attribute {}
disj sig Date, Time, DateTime extends Attribute {}
disj sig AnyURI extends Attribute {}
disj sig HexBinary, Base64Binary extends Attribute {}
disj sig UnrecognizedDatatype extends Attribute {}

static disj sig XACMLTrue, XACMLFalse extends Boolean {}