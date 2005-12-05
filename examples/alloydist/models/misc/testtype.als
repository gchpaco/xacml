module misc/t1

sig A {}

sig B {
  a: A 
}

sig C extends B {
  d: A,
  e: d.~B$a
}

sig X[t] {
   f0: t
}

sig X1[t] {
   f1: t,
   f2: X[t] -- test comments
}


sig X2 {
   f2: X1[A]
}

sig X3[t] extends X1[t] {
   f3: C
}

fun F0 (arg1: X1[A], arg2: X1[B], arg3: arg2.f2) {}
fun F1 (arg1: X2, arg2: arg1.f2.f2.f0, arg3: X1[X1[B]], arg4: arg3.f2.f0.f1, arg5: arg3.f2.f0.f2.f0) {}
fun F2 (arg1: X3[A], arg2: arg1.f2.f0, arg3: arg1.f3.e) {}

fun F3 [s,t] ( a : s -> t ) {
  some p : X1[s] | no p.f2.f0
}

fact FA1 {
  all r : X1[A] -> X[A] | r..F3()
}

sig P[s,t] {}

fun F4 [t] () { some P[X[A],B] }


