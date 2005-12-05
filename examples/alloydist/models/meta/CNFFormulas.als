module meta/CNFFormulas

open std/bool
open meta/CommonBooleanDefs

sig CNFClause {
  literals: set Lit
} { some literals }

fun IsTrueClause(c: CNFClause, a: Assignment) { some lit: c.literals | IsTrueLit(lit, a) }
fun IsFalseClause(c: CNFClause, a: Assignment) { !IsTrueClause(c, a) }

sig CNFClauseSet {
  clauses: set CNFClause
}

fun IsTrueClauseSet(cs: CNFClauseSet, a: Assignment) { all c: cs.clauses | IsTrueClause(c, a) }
fun IsFalseClauseSet(cs: CNFClauseSet, a: Assignment) { !IsTrueClauseSet(cs,a) }

fun IsSatisfiableClauseSet(cs: CNFClauseSet) {
   some a: Assignment | IsTrueClauseSet(cs, a)
}

fun VarsInClauseSet(cs: CNFClauseSet): set Var { result = cs.clauses.literals.var }

fun IsUnsatClauseSet(cs: CNFClauseSet) {
   some as: set Assignment {
       as = AllPossibleAssignments(VarsInClauseSet(cs))
       all a: as | IsFalseClauseSet(cs, a)
   }
}

run IsSatisfiableClauseSet for 1 but 2 Bool, 3 Var, 6 Lit, 2 CNFClause
run IsUnsatClauseSet for 1 but 2 Bool, 1 Var, 2 Lit, 2 CNFClause, 2 Assignment







