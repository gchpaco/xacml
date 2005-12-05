module misc/showbug

sig List [t] {
  first: t,
  rest : option List [t]
}

sig Data { }

fun SomeState () { some List[Data] }
run SomeState for 3
