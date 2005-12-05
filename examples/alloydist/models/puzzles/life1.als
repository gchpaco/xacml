//
// John Conway's Game of Life
//
// Model by BillThies <thies@mit.edu>, Manu Sridharan <msridhar@mit.edu>
//

module life

open std/ord

sig Point {
  right: option Point,
  below: option Point
}

fact Acyclic {
  all p: Point | p !in p.^(right + below)
}

static sig Root extends Point {}

fact InnerSquaresCommute {
  all p: Point {
    p.below.right = p.right.below
    some p.below && some p.right => some p.below.right
  }
}

fact TopRow {
  all p: Point - Root | no p.~below => # p.*below = # Root.*below
}

fact Connected {
  Root.*(right + below) = Point
}

fun Square() {
  # Root.*right = # Root.*below
}

//run Square for 6Point, 3State

fun Rectangle() {}

sig State {
  live : set Point
}

fun Neighbors(p : Point) : set Point {
  result = p.right + p.right.below + p.below
              + p.below.~right + p.~right 
              + p.~right.~below + p.~below +
              p.~below.right
}

fun LiveNeighborsInState(p : Point, s : State) : set Point {
  result = Neighbors(p) & s.live
}

fun Trans(pre, post: State, p : Point) {
   let preLive = LiveNeighborsInState(p,pre) |
    // dead cell w/ 3 live neighbors becomes live
    (p !in pre.live && # preLive = 3) =>
    p in post.live
  else (
    // live cell w/ 2 or 3 live neighbors stays alive
    (p in pre.live && (# preLive = 2 || # preLive = 3)) =>
      p in post.live else p !in post.live
    )
}

fact ValidTrans {
  all pre : State - Ord[State].last |
    let post = OrdNext(pre) |
      all p : Point |
        Trans(pre,post,p)
}

fun AllPoints() {
  univ[Point] in Point
}

run AllPoints for 12Point,3State
