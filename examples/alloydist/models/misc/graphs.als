module misc/graphs

///////////////////////////////////////////
// Module: models/graphs
//
// Generic structures for defining
// graphs with nodes of any given type.
///////////////////////////////////////////

//open models/seq

sig Graph [t] {
   adj: t -> t
}

sig UGraph [t] extends Graph [t] { }
{ adj = ~ adj }


sig DAG [t] extends Graph [t] { }
{
  // for any node, if we start from that node
  // and follow graph edges, we cannot return
  // to that node
  no n: t | n in n.^adj
}

sig Forest [t] extends DAG [t] { }
{
  // each node has at most one parent
  all n: t | sole n.~adj
}

sig Tree [t] extends Forest [t] {
  root: t
}
{
  // there is a root node from which
  // all nodes are reachable
  t in root.*adj
}

fun TreeLeaves [t] (tree: Tree[t]): set t { result = { node: t | no node.(tree.adj) } }
fun TreeInnerNodes [t] (tree: Tree[t]): set t { result = t - TreeLeaves(tree) }

run TreeLeaves for 3
run TreeInnerNodes for 3


