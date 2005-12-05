
//
// Model for exploring subsignature instantiation in Alloy
//

module meta/subinst

open std/ord

sig Ints {}

sig seq [t] {
   elems: Ints ->? t
}

sig BasicType {
}

sig TemplateArg { }

sig SignatureTemplate {
   args: seq[TemplateArg]
}

sig Signature extends BasicType {
   extendedFrom: set Signature
}

fact { no s: Signature | s in s.^(Signature$extendedFrom) }

sig TemplateInstance extends Signature {
   instFrom: SignatureTemplate,
   instArgs: seq[BasicType]
}

sig RelationType {
   basicTypes: seq[BasicType] 
}

sig Field {
   fieldType: RelationType
}

sig SigWithFields extends Signature {
}



fact { BasicType = Signature }




///////////////////////////////////////////////////////////////////////

fun SomeState ( ) { some s: TemplateInstance | # s.instArgs.elems = 2 }

run SomeState for 2
















