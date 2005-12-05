module meta/SwitchBooleanDag

open std/bool
open std/util
open meta/BasicBooleanDag
open meta/CommonBooleanDefs

sig Switch { }
sig Bit { }

disj sig SwitchSetterNode extends BoolNode {
   switchSet: Switch,  // the switch set by this node
   trueBits: set Bit   // bits set to true by this node
} {
  one children
}

fun SwitchAndStandardOnly() {
  BoolNode = SwitchSetterNode + SwitchableConstNode + AndNode + OrNode + LitNode + NotNode
}

fact {
  // a well-formedness constraint on the DAG:
  // descendants of a switch node do not set the same switch again
  all switchSetterNode: SwitchSetterNode |
     no descendant: switchSetterNode.^children |
       descendant in SwitchSetterNode && descendant.switchSet = switchSetterNode.switchSet
}

disj sig SwitchableConstNode extends BoolNode {
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

//============================
// Visits: model DAG traversal
//============================

// one visit to a particular node during the traversal
sig Visit {
   node: BoolNode,
   children: set Visit
}{
  children::node = node::children
  # children = # node::children
}

fact { IsTree(Visit$children) }

//=============================================================
// Evaluation rules for switch setters and switchable constants
//=============================================================

fun IsTrueSwitchableConst(v: Visit) {
  let n = v.node | {
     n in SwitchableConstNode
     n.bit in (v.^(~Visit$children).node & n.switchRead.~SwitchSetterNode$switchSet).trueBits
  }
}

sig SwitchDAGEval {
   assign: Assignment,
   trueVisits: set Visit
}{
   all v: Visit | let n = v.node {
      n in LitNode => (v in trueVisits iff IsTrueLit(n.lit, assign))
      n in NotNode => (v in trueVisits iff v.children in (Visit - trueVisits))
      n in AndNode => (v in trueVisits iff v.children in trueVisits)
      n in OrNode => (v !in trueVisits iff v.children in (Visit - trueVisits))
      n in SwitchSetterNode => (v in trueVisits iff v.children in trueVisits)
      n in SwitchableConstNode => (v in trueVisits iff IsTrueSwitchableConst(v))
   }
}

fun IsTrueSwitchDAG(a: Assignment, root: BoolNode) {
  some e: SwitchDAGEval | e.assign = a && root.~Visit$node in e.trueVisits
}
fun IsFalseSwitchDAG(a: Assignment, root: BoolNode) {
   some e: SwitchDAGEval | e.assign = a && root.~Visit$node !in e.trueVisits
}

fun UnsatSwitchDAG ( ) {
   some root: BoolNode, as: set Assignment {
       as = AllPossibleAssignments(Var)
       no root.~children
       BoolNode in root.*children
       all a: as | IsFalseSwitchDAG(a, root)
   }
   SwitchAndStandardOnly()
   NoEmptyAndOrs()
   some SwitchableConstNode
}

run UnsatSwitchDAG for 1 but 2 Bool, 2 BoolNode, 2 Assignment, 2 SwitchDAGEval, 1 Var, 2 Lit, 2 Visit
