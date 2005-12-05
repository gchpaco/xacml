module models/sharebool

//
// Model of how we can detect
// possibilities for sharing
// of Boolean subformulas.  
//
// See package alloy/sharbool.
//

//
// We model:
//
// an AST, which is a tree (not a DAG),
// with LeafIds and VarCreators;
//
// a naively grounded-out form of the AST,
// with no VarCreators but with 
//
//

open std/seq

// an AST node
sig Node {
   children: set Node
}

sig Leaf extends Node {
   leafId: LeafId
}
{
  no children
}

static sig LiftedRoot {
   
}


sig LeafId { }

fact { one Tree[Node] }

sig Template {
   instances: set Instance,
   parents: set Template,
   children: set Template
}

sig TemplInst {
   node: Node,
   template: Template,
   args: Seq[Node]
}

fact { TemplInst$node = ~ Node$templInst }

fact LeafTemplates {
   // each distinct LeafId gets
   // its own template
   all leaf: Leaf | leaf.
}

fun SomeState ( ) {  }

run SomeState for 3