module misc/geom

sig Point {
   dist: Point ->! Distance,
   between: Point ->+ Point
}

sig Distance { }

fun D(p1, p2, p3, p4: Point) {
   p1.dist[p2] = p3.dist[p4]
   p2.dist[p1] = p4.dist[p3]
   p1.dist[p2] = p4.dist[p3]
}

fun B(p1, p2, p3: Point) {
   p2 in p1.between[p3]
   p2 in p3.between[p1]
}

// Identity axiom for betweenness

fact A1 {
   all x, y: Point |
      B(x, y, x) => x = y
}

// Transitivity axiom for betweenness
fact A2 {
   all x, y, z, u: Point |
      B(x, y, u) && B(y, z, u) => B(x, y, z)
}

// Connectivity axiom for betweenness
fact A3 {
   all x, y, z, u: Point |
      B(x, y, z) && B(x, y, u) && x != y => B(x, z, u) || B(x, u, z)
}

// Reflexivity axiom for equidistance
fact A4 {
   all x, y: Point |
      D(x, y, y, x)
}

// Identity axiom for equidistance
fact A5 {
  all x, y, z: Point |
      D(x, y, z, z) => x = y
}

// Transitivity axiom for equidistance
fact A6 {
   all x, y, z, u, v, w: Point |
      D(x, y, z, u) && D(x, y, v, w) => D(z, u, v, w)
}

// Pasch's axiom
fact A7 {
   all t, x, y, z, u: Point | some v: Point |
      B(x, t, u) && B(y, u, z) => B(x, v, y) && B(z, t, v)
}

// Euclides' axiom
fact A8 {
   all t, x, y, z, u: Point | some v, w: Point |
      B(x, u, t) && B(y, u, z) && x != u => B(x, z, v) && B(x, y, w) && B(v, t, w)
}

// Five segment axiom
fact A9 {
   all x, x', y, y', z, z', u, u': Point |
      D(x, y, x', y') && D(y, z, y', z') && D(x, u, x', u') && D(y, u, y', u') &&
      B(x, y, z) && B(x', y', z') && x != y
         => D(z, u, z', u')
}

// Axiom of segment construction
//fact A10 {
//   all x, y, u, v: Point | some z: Point |
//      B(x, y, z) && D(y, z, u, v)
//}

// Lower dimension axiom
fact A11 {
   some x, y, z: Point | !B(x, y, z) && !B(y, z, x) && !B(z, x, y)
}

// Upper dimension axiom
fact A12 {
  all x, y, z, u, v: Point |
    (D(x,u,x,v) && D(y,u,y,v) && D(z,u,z,v) && u != v) 
       => (B(x,y,z) || B(y,z,x) || B(z,x,y))
}

fun Test() {
   some Point
}

run Test for 4













