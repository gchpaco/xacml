module misc/numtest


sig A {
  r: set A
}


fun SomeState ( ) { some a: A | ((# (a.r)) > 001) }


run SomeState for 3
