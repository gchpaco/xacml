
module std/util

fun dom [t,u] (r: t->u): set t {result = r.u}
fun ran [t,u] (r: t->u): set u {result = t.r}

fun Ring [t] (r: t->t) {
  (one t || no n: t | n = n.r)
  all n: t | t in n.^r
}

fun IsDAG [t] (r: t->t) {
  all x: t | x !in x.^r
}

fun IsTree [t] (r: t->t) {
  IsDAG(r) 
  all x: t | sole x.~r
}


