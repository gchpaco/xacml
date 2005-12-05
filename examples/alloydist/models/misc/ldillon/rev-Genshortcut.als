
module GenShortCut

// Primitive classes
sig STRING {}
sig INT {}

sig Generalization {
  subClass: set Class,
  superClass: Class
}

sig Class {
  className: STRING,
  attributes: set Attribute, // aggregates zero or more Attribute's
  behavior: Behavior // associates each Class with one Behavior
}

// ~Class$attributes associates each Attribute with zero or one Classes
fact { all a: Attribute | sole a.~attributes }

// ~Class$behavior associates each Behavior with one Class
fact { all b: Behavior | one b.~behavior }

sig Attribute {
  attrName: STRING,
  default: option DefaultValue // aggregates zero or one DefaultValue's
}

// no multiplicity fact needed for Attribute$~default

sig DefaultValue {
  attrValue: INT
}


sig Behavior {}

sig InitialState extends Behavior {}

// the derived /name attribute is modelled by "retrofiting" InitialState
// (A Micromodularity Mechanism, p. 7)
sig InitialStateWithName extends InitialState {
    name: STRING
}{
    name = this.~behavior.className
}

fact { InitialState in InitialStateWithName }


// the derived InitialValue class is modelled by a signature
// whose atoms denote related pairs
// a representation mapping maintains the mapping of related pairs to
// InitialValue atoms 
sig InitialValue {
    attrName: STRING,
    attrValue: INT,
    rep: Attribute -> DefaultValue // pair represented by this InitialValue 
}{
    // this InitialValue represents exactly one pair
    one rep &&  
    // this InitialValue derives its attributes from objects in this pair
    all a: Attribute | all v: DefaultValue | (
      ( (a->v) in rep ) => ( attrName = a.Attribute$attrName &&
                             attrValue = v.DefaultValue$attrValue)
    )
}

// each pair in default is represented by exactly one InitialValue and
// a pair is represented by an InitialValue only if it is in default
fact{ all a: Attribute | all v: DefaultValue | 
        ((a->v) in Attribute$default => 
                            one { i: InitialValue | (a->v) in rep[i] },
	                    no  { i: InitialValue | (a->v) in rep[i] })
}

// Arbitrarily choose one of the role classes to retrofit with 
// a derived relation and with a representation association (for easy
// navigation).  To encode the representation association in Alloy, 
// it is curried.
sig ClassWithAttributesClosure extends Class {
   attributesClosure: set Attribute,
   attributesClosureRep: Attribute -> Class -> Attribute
}{
   (all a:Attribute | attributesClosureRep[a] =
     { c2:Class, a2:Attribute | 
        (c2->a2) in Class$attributes &&
        c2 in this.*(~Generalization$subClass.Generalization$superClass) &&
        a2 in a })
   &&
   attributesClosure = 
     { a:Attribute | some a & Class.(attributesClosureRep[a]) }
//     this.*(~Generalization$subClass.Generalization$superClass).Class$attributes
}

fact {Class in ClassWithAttributesClosure}


sig InitialStateWithValueAssignment extends InitialState {
  valueAssignment: set InitialValue,
  valueAssignmentRep: InitialValue -> Class -> Attribute
}{
  (all i:InitialValue | valueAssignmentRep[i] =
    { c:Class, a:Attribute | (c->a) in Class$attributesClosure &&
                             c in this.~behavior &&
			     a in (i.rep).DefaultValue } )
  &&
  valueAssignment = { i: InitialValue | 
    ( some (i.rep).DefaultValue & Class.(valueAssignmentRep[i])) }
}


fact { InitialState in InitialStateWithValueAssignment }

// generate some interesting models

fun NoGeneralizationCycle () {
   no c:Class | c in c.^(~subClass.superClass)
}

fun SomeClassAttribute () { some Class && some Attribute }

fun AttributesWithSameDefault ()
  { some v: DefaultValue | not sole v.~default }

fun AttributesWithNoDefault ()
  { some a: Attribute | no a.default }

fun AttributesBoth () 
  { AttributesWithSameDefault() && AttributesWithNoDefault() }

fun ClassWithMultAttributes ()
  { some c: Class | not sole c.attributes }

fun All()
  { AttributesBoth() && ClassWithMultAttributes() && some InitialState
    && not sole Generalization
    && not sole InitialStateWithValueAssignment$valueAssignment
    // we only care about default values that are aggregated
    && (all v: DefaultValue | some v.~default)
    // no need for default values to have the same attrValue
    && (all n: INT | sole n.~DefaultValue$attrValue)
    // there shouldn't be any circularity in the inheritance hierarchy
    && NoGeneralizationCycle()
    // we only care about generalizations with subclasses
    && (all g: Generalization | some g.subClass)
    // we want each generalization to represented atmost once
    && (all c1, c2: Class | sole c1.~subClass & c2.~superClass)
    // some attribute should be inherited
    && some 
     Generalization.superClass.attributes - Generalization.subClass.attributes
}

fun ViolateAssumption()
  { // some initial state has some attribute for which there is no
    // initial value
    some InitialState.~behavior.attributes - 
           InitialState.valueAssignment.rep.DefaultValue
    &&
    // lets make is slightly interesting
    ( some Attribute.default ) &&
    ( some b: InitialState | not sole b.valueAssignment )
  }

// run AttributesBoth for 3

run All for 3 but 4Class

// run ViolateAssumption for 3




