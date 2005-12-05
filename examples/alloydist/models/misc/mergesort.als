module misc/mergesort

open std/ord
open std/seq

sig Value {}

static sig Recursion {
   mergesort: Seq[Value]->Seq[Value]
}

fact {
   Recursion$mergesort =
   {r: Recursion, e: Seq[Value], i, j: SeqIdx, s: Seq[Value] | MergeSort(e,i,j,s)}
}


fun ElementsSorted (elms: Seq[Value], a, b: SeqIdx) {
   (a = b) ||	// one element is always sorted
   (b in OrdNexts(a) &&
   all elm: ((OrdPrevs(b) & OrdNexts(a)) + a) |
      let nextElm = OrdNext(elm) |
	 SeqAt(nextElm) in (OrdNexts(SeqAt(elm)) + SeqAt(elm))
    )
}

// We give only the specification for this procedure, rather than
// the algorithm to implement it.
fun Merge (inElms: Seq[Value], start, split, end: SeqIdx, outElms: Seq[Value]) {
   SeqInds(outElms) = SeqInds(inElms) &&
   (ElementsSorted(inElms, start, split) &&
    ElementsSorted(inElms, OrdNext(split), end)) => {
       ElementsSorted(outElms, start, end)
   }
   else {}
}

fun MergeSort (elms: Seq[Value], start, end: SeqIdx, sorted: Seq[Value]) {
   sorted..SeqInds() = elms..SeqInds()

   // Leave all unexamined elements as they are originally.
   all i: SeqIdx | {
      i !in ((OrdPrevs(end) & OrdNexts(start)) + start + end) => {
	 sorted..SeqAt(i) = elms..SeqAt(i)
      }
   }

   // One element is already sorted.
   start = end => {
      sorted..SeqAt(start) = elms..SeqAt(start)
   }
   else {
      // We pick an index in the middle of our range. 
      some i: SeqIdx | {
	 let numPrevs = (# (OrdNexts(i) && (OrdPrevs(end) + end))) |
	 let numNexts = (# (OrdPrevs(i) && (OrdNexts(start) + start))) | {
	    ((numPrevs = numNexts) || (numPrevs + 1 = numNexts))
	     &&
	     some temp: Seq[Value] | {
		((Recursion->elms->start->i->temp) in Recursion$mergesort) &&
		((Recursion->elms->OrdNext(i)->end->temp) in Recursion$mergesort) &&
		Merge(temp, start, i, end, sorted)
	     }
	 } // end let
      } // end some
   } //end else
} //end fun
	     

	       
	 
assert CheckSorted {
   all elms: Seq[Value] | some sorted: Seq[Value] | {
       SeqIdx = elms..SeqInds()
       Value = elms..SeqElms()
       MergeSort(elms,Ord[SeqIdx].first,Ord[SeqIdx].last,sorted) => {
	  ElementsSorted(sorted, Ord[SeqIdx].first,Ord[SeqIdx].last)
       }
    }
}

