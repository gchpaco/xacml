module mywork/ord

//
// Definition of total order.
// This signature template lets you impose a total order
// on a given basic type.  It defines the first and last elements
// and the next/prev relation.
//

static sig Ord [t] {
   first, last: t,
   next, prev: t->t
}
{
  t = univ[t]
  prev = ~next
  one first
  one last
  no first.prev
  no last.next
  all elem: t |
    ((no elem.prev && no elem.next) ||
     (
      (elem = first || one elem.prev)  &&
      (elem = last || one elem.next) &&
      (elem !in elem.^next)
     ))
  t in first.*next
}

fun OrdPrev [t] (elem: t): option t { result = elem.(Ord[t].prev) }
fun OrdNext [t] (elem: t): option t { result = elem.(Ord[t].next) }
fun OrdNexts [t] (elem: t): set t { result = elem.^(Ord[t].next) }
fun OrdPrevs [t] (elem: t): set t { result = elem.^(Ord[t].prev) }
fun OrdLT [t] (e1, e2: t) { e1 in OrdPrevs(e2) }
fun OrdGT [t] (e1, e2: t) { e1 in OrdNexts(e2) }
fun OrdLE [t] (e1, e2: t) { e1=e2 || OrdLT(e1,e2) }
fun OrdGE [t] (e1, e2: t) { e1=e2 || OrdGT(e1,e2) }





