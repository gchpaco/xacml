module misc/testskolem

sig A[t] {
  f: t
}

fact [t] {
  some x: t | 
    no y: A[t] | y.f = x
}

fun SomeState [t] () { some A[t] }

run SomeState for 3