module misc/toy
sig A {b: B}
sig B {a: A}{a.b = this}
fun f (a: A) {}
run f for 3
run f for 2