//
// Model of sat2cnf conversion
//
// Given a Boolean DAG, whose nodes include the standard Literal, AND, OR, NOT, ConstTrue, ConstFalse nodes,
// plus nonstandard nodes (SwitchSetter, SwitchableConstant, Cache), create a
// CNF formula (set of clauses) equivalent to the Boolean DAG.
//
// This model checks that the conversion algorithm yields a CNF equivalent to the original
// Boolean DAG -- that is, any assignment to the original Boolean variables (at the leaves
// of the DAG) forces the original DAG and the CNF to the same Boolean value.
//
// Questions to: ilya_shl@mit.edu
//

module meta/BasicBooleanDag

open std/bool
open std/util
open std/seq
open meta/CommonBooleanDefs

//===============================//
// DAG structure: representing   //
// a well-formed Boolean DAG     //
//===============================//

// a Boolean formula node.  we're modeling
// a single instance of a Boolean DAG.
sig BoolNode {
   // children of the boolean node.  note that order
   // does not matter.  it just so happens that all
   // boolean operations that we use are associative and
   // commutative.
   children: set BoolNode,
   childSeq: Seq[BoolNode]
}{
  SeqElems(childSeq) = children
}

fun BoolNode::BoolChildAt(i: SeqIdx): option BoolNode { result = this.childSeq..SeqAt(i) }

fact DAGRules {
   IsDAG(BoolNode$children)
}

disj sig LitNode extends BoolNode {
   lit: Lit
} {
   no children
}

disj sig AndOrNode extends BoolNode {
}

disj sig AndNode extends AndOrNode { }
disj sig OrNode extends AndOrNode { }

disj sig NotNode extends BoolNode { }
{ one children }

fun StdNodesOnly ( ) {
   BoolNode = LitNode + NotNode + OrNode + AndNode
}

fun NoEmptyAndOrs() {
   all n: AndOrNode | # n.children > 2
}

//===============================//
// DAG evaluation: evaluating
// the DAG for a particular
// Assignment
//===============================//

sig DAGEval {
   assign: Assignment,
   trueNodes: set BoolNode
}{
   all n: BoolNode {
      n in LitNode => (n in trueNodes iff IsTrueLit(n.lit, assign))
      n in NotNode => (n in trueNodes iff n.children in (BoolNode - trueNodes))
      n in AndNode => (n in trueNodes iff n.children in trueNodes)
      n in OrNode => (n !in trueNodes iff n.children in (BoolNode - trueNodes))
   }
}

fun IsTrueDAG(a: Assignment, root: BoolNode) { some e: DAGEval | e.assign = a && root in e.trueNodes }
fun IsFalseDAG(a: Assignment, root: BoolNode) { some e: DAGEval | e.assign = a && root !in e.trueNodes }

fun UnsatDAG ( ) {
   some root : BoolNode, as: set Assignment {
       as = AllPossibleAssignments(Var)
       all a: as | IsFalseDAG(a, root)
   }
   StdNodesOnly()
   NoEmptyAndOrs()
}

//run UnsatDAG for 1 but 2 Bool, 4 BoolNode, 4 Assignment, 4 DAGEval, 2 Var, 4 Lit