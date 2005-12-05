module misc/tree

//
// Generic trees.
//
sig Tree [t] {
   children: set Tree[t]
}
{
  this !in this.^(Tree[t]$children)
  // each node has at most one parent
  sole this.~(Tree[t]$children)
}





