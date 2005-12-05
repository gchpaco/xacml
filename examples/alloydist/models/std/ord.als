module std/ord

//
// IMPORTANT: DO NOT EDIT THIS FILE!!!
//
// The Alloy Analyzer assumes that this particular file,
// std/ord.als, has the exact form that comes with the
// distribution, and speeds up analysis on this assumption.
//
// Feel free to copy this file to another name, rename
// the signature, and modify the copy.
//

//
// sig Ord: Definition of total order.
//
// This signature template lets you impose a total order
// on a given basic type.  It defines the first and last elements
// and the next/prev relation.  The next relation maps each element
// except the last to the next element, and maps the last element
// to the empty set; analogously for prev.
//
// To use total orders, include the line

// open std/ord

// at the top of your model.  Then, just instantiate the Ord[] template
// with the basic type you want to order.  E.g. if you have declared

// sig State { ... }

// then
//    Ord[State].first, of type State, is the first element
//    Ord[State].last, of type State,  is the last element
//    Ord[State].next, of type State->State, is the "next element" relation
//    Ord[State].prev, of type State->State, is the "previous element" relation
//
// Note that there is exactly one total order for each basic type (i.e.
// the Ord signature template is declared "static").  If you need more than
// one total order for a basic type, make a copy of this file, rename
// the Ord signature and remove the static designator.
//
// Besides including the "open std/ord" line, you don't need to declare
// anywhere that you want to order one or more of your basic types --
// simply using Ord[State] somewhere in your model will cause Ord[State]
// to be instantiated.
//
// Convenience functions are provided to make orders easier to user:
// e.g. OrdNext(x) is the immediate successor of x in the total order
// on the basic type of x (if x is a singleton); analogously for
// OrdPrev(x).  OrdNexts(x) is the set of higher-numbered elements
// in the total order: OrdNexts(Ord[State]$last) is empty.

// *Important note*: Using Ord[State] anywhere in your model automatically
// adds the constraint State=univ[State], i.e. requiring any solution
// to have as many State atoms as the analysis scope allows.  This is somewhat
// unnatural (since this constrains your relation State, rather than the
// order relations declared here).  It is required for the special analyzer
// support for total orders (described below).

// SPECIAL ANALYZER SUPPORT FOR ord.als:
//
// - faster analysis: all fields of Ord can be
//   set to constant values before the analysis.
//   E.g. if State has scope 3 i.e. has atoms {State_0,State_1,State_2},
//   and Ord[State] has scope 1 (as it should since it is static),
//   we can set

//  Ord[State]$first = { <Ord[State]_0, State_0> }
//  Ord[State]$last  = { <Ord[State]_0, State_2> }
//  Ord[State]$next  = { <Ord[State]_0, State_0, State_1>,
//                       <Ord[State]_0, State_1, State_2> }
//  Ord[State]$prev  = { <Ord[State]_0, State_1, State_0>,
//                       <Ord[State]_0, State_2, State_1> }

// In other words, if the Alloy model being analyzed has any solution,
// it has one in which the fields of Ord (for each basic type) have
// the values outlined above -- so we can just as well set them to these
// values immediately, greatly reducing the search space.
//
// - order values correspond to the order of atoms: because the
// fields of Ord are set by the analyzer as shown above, you're guaranteed
// that the atoms of State will be ordered in their natural atom order,
// i.e. {State_0}.next is {State_1}, etc.  If you defined your own
// total orders, you might get a solution in which State_2 is the first
// atom, followed by State_0 and then State_1 -- much harder to read
// than the natural order of State_0,State_1,State2.

// If you use this module you're guaranteed a sensible total order
// definition -- it is surprisingly easy to get the axioms for
// total order wrong if you write them from scratch.

// Visualization suggestion: you might want to use the "projection"
// feature of visualization if you use total orders -- especially
// if you have a sequence of States of a system.  After doing
// Tools|Visualize, click on Customize, then on Type, and check
// the "project" box next to the State basic type.  Then go to Variable
// tab and uncheck the visualization of fields of Ord[State].  Then
// click on "Generate graph" at the bottom.  You will then have a separate
// screen for each State of your system, and be able to step through
// the states in sequence.

//
// Examples of use: distalg/dijkstra.als, puzzles/hanoi.als
// Questions to: ilya_shl@mit.edu
//

static sig Ord [t] {
   first, last: t,
   next, prev: t -> t
}
{
  // the unnatural constraint: require t to use
  // all atoms allowed by the analysis scope.
  // this is to let the analyzer optimize the analysis
  // by setting all fields of each instantiation of Ord
  // to predefined values:
  // e.g. by setting 'last' to the highest
  // atom of t and by setting 'next' to {<T0,T1>,<T1,T2>,...<Tn-1,Tn>}
  // where n is the scope of t.
  // we require t=univ[t] in order to preserve the constraint
  // that Ord[t].last is a subset of t and the domain and range of
  // Ord[t].next lie inside t.
  t = univ[t]

  // constraints that actually define the total order
  prev = ~next
  one first
  one last
  no first.prev
  no last.next
  (
   // either t has exactly one atom,
   // which has no predecessor or successor...
   (one t && no t.prev && no t.next) ||
   // or...
    all elem: t | {
      // ...each element (except the first) has one predecessor, and...
      (elem = first || one elem.prev)
      // ...each element (except the last) has one successor, and...
      (elem = last || one elem.next)
      // ...there are no cycles
      (elem !in elem.^next)
    }
  )
  // all elements of t are totally ordered
  t in first.*next
}

// return the predecessor of elem, or empty set if elem is the first element
fun OrdPrev [t] (elem: t): option t { result = elem.(Ord[t].prev) }
// return the successor of elem, or empty set of elem is the last element
fun OrdNext [t] (elem: t): option t { result = elem.(Ord[t].next) }

// return elements after elem in the ordering
fun OrdPrevs [t] (elem: t): set t { result = elem.^(Ord[t].prev) }
// return elements prior to elem in the ordering
fun OrdNexts [t] (elem: t): set t { result = elem.^(Ord[t].next) }

// two-element comparison functions

fun OrdLT [t] (e1, e2: t) { e1 in OrdPrevs(e2) }
fun OrdGT [t] (e1, e2: t) { e1 in OrdNexts(e2) }
fun OrdLE [t] (e1, e2: t) { e1=e2 || OrdLT(e1,e2) }
fun OrdGE [t] (e1, e2: t) { e1=e2 || OrdGT(e1,e2) }





