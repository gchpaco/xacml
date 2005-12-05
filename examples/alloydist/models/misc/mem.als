module misc/mem

//
// Model of multi-level cache memory
//

sig Val { }
sig Addr { }
sig Mem {
   addrs: set Addr,
   contents: addrs ->! Val
}

fact MemoriesDisjoint {
  all m1, m2: Mem |
    m1 != m2 => no m1.addrs & m2.addrs
  one Addr
  one Val
}

assert CheckSmth {
   { a: Addr, v: Val | some Mem->a->v } = Addr->Val
}

fun SomeState ( ) { # Mem = 2 }

check CheckSmth for 2
//run SomeState for 2
