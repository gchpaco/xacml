module misc/bmc1

open std/ord

// bit-shift register example from bmc paper

sig Bit {
}

static sig On {}

sig State {
  on: Bit ->? On
}

fun T(pre,post: State) {
  // first bit is highest-order
  all b: Bit - Ord[Bit].last |
    let next = OrdNext(b) |
      post.on[b] = pre.on[next]
  // ERROR: last bit should not be on
  some post.on[Ord[Bit].last]
}

fun Loop() {
  some st: State - Ord[State].last |
    T(Ord[State].last, st)
}

fun AllZero(st: State) {
  no Bit.st::on
}

fun BadTrace() {
  all st: State | ! AllZero(st)
  Loop()
  all pre: State - Ord[State].last |
    let post = OrdNext(pre) | 
      T(pre,post)
}

run BadTrace for 2 but 3Bit