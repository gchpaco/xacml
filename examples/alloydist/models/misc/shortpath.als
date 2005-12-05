module misc/shortpath

///////////////////////////////////////////
// Module: models/graphs
//
// Models the shortest-path computation
// in a directed graph.
///////////////////////////////////////////

open misc/graphs
open std/seq
open std/ord

sig Path [t] extends Seq [t] {
   graph: Graph[t]
}
{
  // all e: t|  SeqNext(this, e) in e.(graph.adj)
  all i: SeqInds(this) |
   i.(Ord[SeqIdx].next).seqElems in
   i.seqElems.(graph.adj)
}








