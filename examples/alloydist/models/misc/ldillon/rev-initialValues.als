// embed a binary (non-generalization) association in the signature
//   for one of its roles:
//   - aggregations are embedded in the aggregator role
//   - otherwise, if one role has multiplicity 1 or 0-1 and the
//     other doesn't, embed it in the latter role
//   - otherwise, arbitrarily select a role to put it in (for example,
//     we could put it in the class that the user clicks on first when
//     drawing the association)
//

module initialValues

// Primitive classes
sig STRING {}
sig INT {}

sig Class {
  className: STRING,
  attributes: set Attribute, // aggregates zero or more Attribute's
  behavior: Behavior // associates each Class with one Behavior
}

// ~attributes associates each Attribute with zero or one Classes
fact { all a: Attribute | sole a.~attributes }

// ~behavior associates each Behavior with one Class
fact { all b: Behavior | one b.~behavior }

sig Attribute {
  attrName: STRING,
  default: option DefaultValue // aggregates zero or one DefaultValue's
}

// no multiplicity fact needed for ~default

sig DefaultValue {
  attrValue: INT
}


sig Behavior {}

sig InitialState extends Behavior {}

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
    rep: Attribute -> DefaultValue // the representation mapping
}{
    one rep &&
    all a: Attribute, v: DefaultValue | (
      ((a->v) in rep ) => ( attrName = a.Attribute$attrName &&
                            attrValue = v.DefaultValue$attrValue )
    )
}

fact{ all a: Attribute, v: DefaultValue | 
      ((a->v) in Attribute$default => 
                          one { i: InitialValue | (a->v) in rep[i] },
	                  no  { i: InitialValue | (a->v) in rep[i] })
}

sig InitialStateWithValueAssignment extends InitialState {
    valueAssignment: set InitialValue,
    valueAssignmentRep: InitialValue -> Class -> Attribute
}{
    (all i: InitialValue | 
       valueAssignmentRep[i] =
         { c: Class, a: Attribute | (c->a) in Class$attributes &&
                                    c in this.~Class$behavior &&
				    a in (rep[i]).DefaultValue })
    &&
    valueAssignment = 
        { i: InitialValue| 
           some rep[i].DefaultValue & Class.(valueAssignmentRep[i]) }
}

//fact { all b: InitialState |
//         b.valueAssignment = 
//           { i: InitialValue | 
//               ( some b.~behavior.attributes & (rep[i]).DefaultValue ) }
//     }

fact { InitialState in InitialStateWithValueAssignment }

// generate some interesting models

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
    && not sole InitialState.name
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

// run All for 3

run ViolateAssumption for 3




