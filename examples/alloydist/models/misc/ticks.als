module misc/ticks

sig Tick{
  //do we have a hook for inverse relation prevTick?
  nextTick: option Tick,
  //  prevTick = ~nextTick
  prevTick: option Tick
}
{//condition that the nextTick relation is ordered
  isOrdered(Tick$nextTick)
}


static sig firstTick extends Tick{}
{
  no prevTick
}

static sig lastTick extends Tick{}
{
  no nextTick
}

fact oneOfEach { one firstTick && one lastTick && Tick$prevTick = ~Tick$nextTick }

fun isOrdered [t] (rel: t -> t) {
  (no tk: t | tk.rel = tk) &&
  (some ft, lt: t | (
    (no ft.~rel && no lt.rel) &&
    (all tk: t | ((tk != ft => one tk.~rel) &&
                 (tk != lt => one tk.rel)))  &&
       # { tk2: t | tk2 in ft.*rel } = # t &&
       lt.*~rel = t 
 ))
}

fun SomeTicksThere ( ) { Tick = univ[Tick] }

run SomeTicksThere for 5