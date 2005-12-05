/*
An Alloy model of the Paul Simon (1973) song:
One Man's Ceiling Is Another Man's Floor
Daniel Jackson, 11/14/01

A toy to illustrate the basic structure of an Alloy model.
Perhaps the smallest example that uses all kinds of 
paragraph!

Simon said "One Man's Ceiling Is Another Man's Floor".
Does it follow that "One Man's Floor Is Another Man's Ceiling"?
To see why not, check the assertion BelowToo. With an additional
constraint (NoSharing), it does follow: the assertion BelowToo'
has no counterexamples.
*/

module samples/CeilingsAndFloors
sig Platform {}
sig Man {ceiling, floor: Platform}
fact {all m: Man | some n: Man | Above (n,m)}
fun Above (m, n: Man) {m.floor = n.ceiling}
assert BelowToo {all m: Man | some n: Man | Above (m,n)}
check BelowToo for 2

fun NoSharing (){no disj m, n: Man | m.floor = n.floor || m.ceiling = n.ceiling}
assert BelowToo' {NoSharing() => all m: Man | some n: Man | Above (m,n)}
check BelowToo' for 6
