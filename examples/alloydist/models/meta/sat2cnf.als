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

module meta/sat2cnf

open std/ord
open std/util

   /////////////////////////////////
  // DAG structure: representing //
 // a well-formed Boolean DAG   //
/////////////////////////////////

// a Boolean variable
sig Var { }

// a Boolean literal
sig Lit {
   var: Var
}

// literals are partitioned into positive and negative.
sig PosLit extends Lit { }
sig NegLit extends Lit { }
fact {
   Lit = PosLit + NegLit
   no PosLit & NegLit
}

// a Boolean formula node.  we're modeling
// a single instance of a Boolean DAG.
sig BoolNode {
   // children of the boolean node.  note that order
   // does not matter.  it just so happens that all
   // boolean operations that we use are associative and
   // commutative.
   children: set BoolNode
}

static sig BoolRoot extends BoolNode { }

fact DAGRules {
   IsDAG(BoolNode$children)
   // the root has no parent, and every Node
   // is reachable from the root
   no BoolRoot.~children
   BoolNode in BoolRoot.*children
}

sig LitNode extends BoolNode {
   lit: Lit
} {
   no children
}

sig AndOrNode extends BoolNode {
}

sig AndNode extends AndOrNode { }
sig OrNode extends AndOrNode { }

sig NotNode extends BoolNode { }
{ one children }

sig StandardNode extends BoolNode { }

fact {
  StandardNode = LitNode + NotNode + AndNode + OrNode
  no LitNode & (NotNode + AndNode + OrNode)
  no NotNode & (AndNode + OrNode)
  no AndNode & OrNode
}

// define switchable constants

sig NonstandardNode extends BoolNode { }

fact {
   BoolNode = StandardNode + NonstandardNode
   no StandardNode & NonstandardNode
   NonstandardNode = SwitchSetterNode + SwitchableConstNode
   no SwitchSetterNode & SwitchableConstNode
}

sig Switch { }
sig Bit { }

sig SwitchSetterNode extends NonstandardNode {
   switchSet: Switch,  // the switch set by this node
   trueBits: set Bit   // bits set to true by this node
} {
  one children
}

fact {
  // a well-formedness constraint on the DAG:
  // descendants of a switch node do not set the same switch again
  all switchSetterNode: SwitchSetterNode |
     no descendant: switchSetterNode.^children |
       descendant in SwitchSetterNode && descendant.switchSet = switchSetterNode.switchSet
}

sig SwitchableConstNode extends NonstandardNode {
   switchRead: Switch,  // the switch value checked by this switchable constant
   bit: Bit             // the bit (in switchRead) checked by this switchable constant
}{
  no children
}

fact {
   // a well-formedness constraint on the DAG:
   // switchable constants refer only to switches that have already been set
   // by switch setters higher up in the DAG
   all switchableConstNode: SwitchableConstNode |
      some switchSetterNode: switchableConstNode.^~children |
         switchSetterNode.switchSet = switchableConstNode.switchRead
}

///// end description of DAG //////

//
// CNF clause sets
// 

sig CNFClause {
  literals: set Lit
}

// grounding-out is done by visiting each node of the DAG and then
// its children -- possibly visiting a given node several times.
// the following signature models one visit to a given node.


sig Visit {
  // the Node we visited
  visitedNode: BoolNode,
  childVisits: set Visit
}

fact {
  all v: Visit | {
      v.childVisits.visitedNode = v.visitedNode.children
      all child: v.visitedNode.children | 
           one childVisit: v.childVisits | childVisit.visitedNode = child
  }

  all v: Visit | v !in v.^childVisits
}

static sig RootVisit extends Visit {
}{
  visitedNode = BoolRoot
}

fact { Visit = RootVisit.*Visit$childVisits }

fun SomeState ( ) {  }

run SomeState for 4

