module misc/dag

//
// sig DAG: A directed acyclic graph
//
sig DAG [t] {
   children: set DAG[t]
}

