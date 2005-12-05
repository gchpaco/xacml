module misc/testgraphs

open misc/graphs

sig Id { }

fun SomeState ( ) { some Graph[Id].root }

fact { # Id = 3 }

fact [t] { one Graph[t] }

run SomeState for 4