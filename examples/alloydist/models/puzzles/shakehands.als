module models/shakehands

sig Person {
   spouse: Person,
   shakes: set Person
}{
  spouse != this
  no (this + spouse) & shakes
}

fact BasicConstraints {
   univ[Person] in Person
   Person$spouse = ~Person$spouse
   Person$shakes = ~Person$shakes
}

fun HandshakeCountsDifferent () {
   some Host: Person | {
      all disj p1, p2: Person - Host | # p1.shakes != # p2.shakes
   }
}

run HandshakeCountsDifferent for 8


