module std/bool

//
// Defines basic type Bool containing two atoms:
// True and False.
//

open std/ord

sig Bool {
   oppositeBoolValue: Bool
}

static part sig False, True extends Bool {
}

fact {
   False = Ord[Bool].first
   True = OrdNext(Ord[Bool].first)
   Bool$oppositeBoolValue = False->True + True->False
}

fun BoolNot(b: Bool): Bool { result = b.oppositeBoolValue }

