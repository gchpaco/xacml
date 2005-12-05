module std/seq

//
// Models of sequences of atoms of a given signature.
// To allow the sequence to contain one atom more than once,
// we define an ordered signature, SeqIdx, and represent
// sequences as maps from SeqIdx to the sequence atoms.
// Empty sequences are allowed.  Maximum length of a sequence
// is determined by the scope of SeqIdx.
//

open std/ord

sig SeqIdx {}

sig Seq [t] {
   seqElems: SeqIdx ->? t
}
{
  // Ensure that elems covers only an initial segment of SeqIdx,
  // equal to the length of the signature
  all i: SeqIdx - Ord[SeqIdx].first | some i.seqElems => some OrdPrev(i).seqElems
}

fun Seq[t]::SeqAt [t] (i: SeqIdx): option t { result = i.(this.seqElems) }
fun Seq[t]::SeqElems [t] (): set t { result = SeqIdx.(this.seqElems) }
fun Seq[t]::SeqInds [t] (): set SeqIdx { result = t.~(this.seqElems) }
fun Seq[t]::SeqIsEmpty [t] () { no SeqElems(this) }
fun Seq[t]::SeqFirst [t] (): option t { result = Ord[SeqIdx].first.(this.(Seq[t]$seqElems)) }
det fun Seq[t]::SeqRest [t] (): Seq[t] {
   all i: SeqIdx | result..SeqAt(i) = this..SeqAt(OrdNext(i))
}

/*
det fun Seq[t]::SeqAdd [t] (e: t): Seq[t] {
   all i: this..SeqInds() | result..SeqAt(i) = this..SeqAt(i)
   let nextInd = this..SeqInds().(Ord[SeqIdx].next) - this..SeqInds() | {
      result..SeqInds() = this..SeqInds() + nextInd
      result..SeqAt(nextInd) = e
      all i: SeqIdx - this..SeqInds() - nextInd | no result..SeqAt(i)
   }
}
*/

det fun SeqAdd [t] (seq: Seq[t], e: t): Seq[t] {
   all i: seq..SeqInds() | result..SeqAt(i) = seq..SeqAt(i)
   some nextInd: SeqIdx | {
      some seq.seqElems => {
	 no nextInd.seq::seqElems &&
	 some OrdPrev(nextInd).seq::seqElems
      }
      else {
      	 nextInd = Ord[SeqIdx].first
      }
        
      result..SeqInds() = seq..SeqInds() + nextInd
      result..SeqAt(nextInd) = e
      all i: SeqIdx - seq..SeqInds() - nextInd | no result..SeqAt(i)
   }
}

      
fun Seq[t]::SeqPrev [t] (e: t): option t { result = OrdPrev(e.~(this.seqElems)).(this.seqElems) }
fun Seq[t]::SeqPrevs [t] (e: t): set t { result = OrdPrevs(e.~(this.seqElems)).(this.seqElems) }
fun Seq[t]::SeqNext [t] (e: t): option t { result = OrdNext(e.~(this.seqElems)).(this.seqElems) }
fun Seq[t]::SeqNexts [t] (e: t): set t { result = OrdNexts(e.~(this.seqElems)).(this.seqElems) }

fun Seq[t]::SeqLast [t] (): option t {
  result = { e: t | e in SeqElems(this) && no SeqNext(this,e) }
}

fun Seq[t]::SeqHasDups [t] () { # SeqElems(this) < # SeqInds(this) }

// true if the sequences are identical
fun Seq[t]::SeqEquals [t] (other: Seq[t]) {
  all ind: SeqIdx | this..SeqAt(ind) = other..SeqAt(ind)
}

// true if this starts with another sequence
fun Seq[t]::SeqStartsWith [t] (other: Seq[t]) {
  all ind: other..SeqInds() | this..SeqAt(ind) = other..SeqAt(ind)
}
  
assert A1 [t] { all s : Seq[t] | s..SeqEquals(s) }

check A1 for 4
