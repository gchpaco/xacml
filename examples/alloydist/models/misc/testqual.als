module misc/testqual

sig A {
  part a, b : A -> A
}

fun SomeState (part c, d : set A) { # A = 2 }

run SomeState for 3 