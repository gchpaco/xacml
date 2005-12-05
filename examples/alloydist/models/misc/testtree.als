module misc/testtree

open misc/graphs

sig Person { }

fact { one Tree[Person] && one Graph[Person] }
fun SomeState ( ) {  }

run SomeState for 2