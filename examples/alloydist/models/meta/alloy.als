
//
// (Meta-)model of Alloy models
//

module meta/alloy

open std/seq
open misc/tree

//
// sig BasicType
//
// Represents a basic type.  The most common
// basic type is a signature.  Basic types
// may also be used as placeholders for
// template arguments, and for the special
// basic type Int.
sig BasicType {
}

fact { some Tree[BasicType] }

sig RelationType {
   basicTypes: Seq[BasicType] 
}

//
// sig SigInst
//
// Represents a particular BasicType:
// a non-template signature, or a
// particular instantiation of a
// signature template.  
sig SigInst extends BasicType {
   instFrom: SigTempl,
   instWith: Seq[BasicType]
}

//
// sig SigTempl
//
// A signature template, possibly with no arguments
// (in which case it represents an ordinary signature).
//
sig SigTempl {
}

///////////////////////////////////////////////////////////////////////

fun SomeState ( ) { }

run SomeState for 2
















