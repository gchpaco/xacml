module misc/bothptrs

sig A {
  mydata: B
}

sig B {
  mydata: A
}

fun SomeState ( ) { }

run SomeState for 3