
module meta/CommonBooleanDefs

open std/bool

// a Boolean variable
sig Var { }

// a Boolean literal
sig Lit {
   var: Var
}

// literals are partitioned into positive and negative.
part sig PosLit, NegLit extends Lit { }

// a complete assignment, gives all variables truth values
sig Assignment {
   varVal: Var ->! Bool
}

fun IsTrueLit(lit: Lit, a: Assignment) {
   (lit in PosLit && a.varVal[lit.var]=True) ||
   (lit in NegLit && a.varVal[lit.var]=False)
}
fun IsFalseLit(lit: Lit, a: Assignment) { !IsTrueLit(lit,a) }

det fun AllPossibleAssignments(vars: set Var): set Assignment {
   all assignVal: vars ->! Bool | some a: result | a.varVal = assignVal
}

fun Test ( ) {
   Assignment = AllPossibleAssignments(Var)
   univ[Var] in Var
}

run Test for 1 but 2 Bool, 3 Var, 8 Assignment

