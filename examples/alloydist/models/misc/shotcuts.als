module misc/Shotcuts

// Primite types
sig STRING {}
sig INT {}

// signatures for all classes in the blessed meta-model
sig Class{
  className: STRING
}

sig Attribute{
  attrName: STRING
}

sig DefaultValue{
  attrValue: INT
}

sig Behavior{}

// A subclass extends its superclass  (is there multiple inheritance
// in the blessed model?)  How would we handle it?
sig InitialState extends Behavior{}



// signature for the attributes relation
sig attributesRel {
    from: Class,
    to: Attribute
}

// each attributeRel atom represents a unique pairing
fact { all c: Class, a: Attribute | 
         sole(c.~attributesRel$from & a.~attributesRel$to) }

// zero or one multiplicity on the from end
fact { all a: Attribute | sole a.~attributesRel$to.attributesRel$from }

// signature for the default relation
sig defaultRel {
    from: Attribute,
    to: DefaultValue
}

// each defaultRel atom represents a unique pairing
fact { all a: Attribute, v: DefaultValue |
         sole (a.~defaultRel$from & v.~defaultRel$to) }

// zero or one multiplicity on the to end
fact { all a: Attribute | sole a.~defaultRel$from.defaultRel$to }


// signature for the behavior relation
sig behaviorRel {
    from: Class,
    to: Behavior
}


// each behaviorRel atom represents a unique pairing
fact { all c: Class, b: Behavior |
         sole (c.~behaviorRel$from & b.~behaviorRel$to) }

// exactly one multiplicity on both ends
fact { all c: Class | one c.~behaviorRel$from.behaviorRel$to }

fact { all b: Behavior | one b.~behaviorRel$to.behaviorRel$from }


fun SomeClassMultAttributes() {
    some a1: Attribute | some a2: Attribute | a1 != a2 &&
      some (a1.~attributesRel$to.attributesRel$from & 
            a2.~attributesRel$to.attributesRel$from)
}

fun SomeAttributesSameDefault() {
    some a1: Attribute | some a2: Attribute | a1 != a2 &&
      some (a1.~defaultRel$from.defaultRel$to &
            a2.~defaultRel$from.defaultRel$to )
}

fun SomeAttributeNoDefault() {
    some Attribute - DefaultValue.~defaultRel$to.defaultRel$from
}
      
fun Both() {
   SomeClassMultAttributes() &&  SomeAttributesSameDefault() }

fun AllThree() {
    Both() && SomeAttributeNoDefault()
}

// the derived name attribute is modeled by "retrofiting" InitialState
// (A Micromodularity Mechanism, p. 7)
sig InitialStateWithName extends InitialState {
    name: STRING
}{
    name = this.~behaviorRel$to.behaviorRel$from.Class$className
}

fact { InitialState in InitialStateWithName }

// signature for the derived InitialValue class
sig InitialValue {
    attrName: STRING,
    attrValue: INT
}

// the joins predicate
fun joins(a: Attribute, r: defaultRel, v: DefaultValue) {
    a in r.defaultRel$from &&
    v in r.defaultRel$to 
}


// the join function
fun join(a: Attribute, r: defaultRel, v: DefaultValue) : InitialValue {
    a in r.defaultRel$from &&
    v in r.defaultRel$to &&
    result.attrName = a.attrName &&
    result.attrValue = v.attrValue    
}

fact { all a1, a2: Attribute | all r1, r2: defaultRel | 
         all v1, v2: DefaultValue |
           join(a1, r1, v1) = join(a2, r2, v2) =>
	     a1 = a2 && r1 = r2 && v1 = v2 }

fact { all i: InitialValue | 
         some a: Attribute, r: defaultRel, v: DefaultValue |
           join(a, i, r, v) }

fact { 1 > 2 } 
 

// run Both for 3

run AllThree for 3
