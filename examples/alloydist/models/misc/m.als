module m
sig A {g: option X'}
sig X {}
sig X' extends X {f: A}
assert E {~X$f = A$g && X in A.~f => X in X'}
check E
