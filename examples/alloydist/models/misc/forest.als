module misc/forest

open misc/tree
//
// Generic forest: a collection of trees
//
sig Forest [t] {
   children: set Tree[t]
}
{
  this !in this.^(Tree[t]$children)
  // each node has at most one parent
  sole this.~(Tree[t]$children)
}





