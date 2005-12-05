module misc/testseq

open std/seq

sig Id { }

fun SomeState ( ) {
  some id: Id, s1, s2: Seq[Id] |
     s2 = s1..SeqAdd(id)
}

assert Sanity {
   all s1, s2: Seq[Id] |
     (some id: Id - s1..SeqElems() | 
        (s2..SeqElems() = s1..SeqElems() + id)) =>
     some id: Id | s2 = s1..SeqAdd(id)
}

run SomeState for 3
check Sanity for 2

