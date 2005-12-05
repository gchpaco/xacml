
/*
A hunter is one one shore of a river, and has
with him a fox, a goat, and cabbages.  He has
a boat that fits one object besides the hunter
himself.  In the presense of the hunter nobody
eats anything, but if left without the hunter,
the fox will eat the goat, and the goat will
eat the cabbages.  How can the hunter
get all three possessions across the river
safely?

The solution to this model will be a sequence of states that represent
the hunter's trips across the river. We specify below constraints on how
the hunter can carry things on the boat, and what things he cannot leave
on the shore together unattended; the solver will then figure out a
sequence of states (trips) that will lead to him having transferred all
of his belongings to the other side safely.

 Model by Jesse Pavel <jpavel@mit.edu>
*/


module hunter

open std/ord

// The hunter and all his possessions will be represented as Objects.
sig Object {}

// The static keyword specifies that each subsignature will
// have only one member, and disj forces each of these
// to be disjoint from the others. Thus, we create four
// unique objects here.
static disj sig Hunter extends Object {}
static disj sig Fox extends Object {}
static disj sig Goat extends Object {}
static disj sig Cabbages extends Object {}

// Each state represents one trip by the hunter across the river,
// and the near and far relations contain the objects held on each
// side of the river, respectively.
sig State {
    near: set Object,
    far: set Object
}

// In the initial state, all objects are on the near side.
fun Initial (s: State) {
    s.far = none[Object]
    s.near = Fox + Goat + Cabbages + Hunter
}

// TransferSomething() constrains the movement of objects from a
// pre-state (from, to) to its post-state (from', to').
fun TransferSomething (from, to, from', to': set Object) {
   // There are three ways in which the Hunter can do things.

   // The hunter can take exactly one object with him across the river.
   (one item: from - Hunter |
      (to' = to + Hunter + item) &&
      (from' = from - Hunter - item))
   ||
   // Or he can make the trip by himself.
   ((to' = to + Hunter) &&
    (from' = from - Hunter))
   ||
   // Or he can just wait where he is.
   (to' = to  &&  from' = from)
}

// For each pair of subsequent states, the hunter can move
// something only from the side he is currently on.
fun MoveSomething (s, s': State) {
    Hunter in s.near => {
       TransferSomething (s.near, s.far, s'.near, s'.far)
    }
    else {
       TransferSomething (s.far, s.near, s'.far, s'.near)
    }
}

// This function represents the constraints posed
// by the problem itself, that the hunter cannot leave
// the fox and goat by themselves, or the goat and cabbages.
fun NothingGetsEaten (objs: set Object) {
    (Hunter !in objs) => {
	((Fox + Goat) !in objs) &&
        ((Goat + Cabbages) !in objs)
    } else {}
}

// We must constrain our simulation so that objects do
// not spontaneously duplicate or disappear from the world.	
fun OneOfEverything (s: State) {
   all o: Object |
      (o in (s.near + s.far)) &&
      (o in s.near => o !in s.far)
}
   

// Here we tie things together:
// The initial conditions must hold, and then for all
// pairs of subsequent states, the hunter can move something,
// making sure that nothing gets eaten on either shore, and
// that nothing violates a law of existence.
fun ValidTransitions () {
    Initial (Ord[State].first) &&
    (
    all pre: State - Ord[State].last | let post = OrdNext(pre) |
	MoveSomething (pre, post) &&
	NothingGetsEaten (post.near) && NothingGetsEaten (post.far) &&
	OneOfEverything (post)
    )
}

// The puzzle is solved if the hunter can move everything to the
// far side of the river.
fun HunterSucceeds () {
    Ord[State].last.far = (Goat + Cabbages + Fox + Hunter)
}

// Let us check how we can do this.
fun FindSolution () {
    ValidTransitions () && HunterSucceeds()
}

// It turned out to take 8 trips across the river.
run FindSolution for 8 but 4 Object
