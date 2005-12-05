module puzzles/hanoi

//
// Towers of Hanoi model
//
// Description of problem (from http://www.cut-the-knot.com/recurrence/hanoi.html)

// The Tower of Hanoi puzzle was invented by the French mathematician
// Edouard Lucas in 1883. We are given a tower of eight disks,
// initially stacked in decreasing size on one of
// three pegs. The objective is to transfer the entire tower to one of
// the other pegs, moving only one disk at a time and never a larger one onto a smaller.

// The Alloy model below is written so that a solution to the model is a complete
// sequence of valid moves solving an instance of the problem.  We define constraints
// for the initial state (all discs on left stake), the final state (all discs on right stake),
// and each pair of adjacent states (the top disc is moved from one stake to another,
// not putting larger discs on smaller discs), and let Alloy Analyzer solve for the
// sequence of states satisfying these constraints.  Since each adjacent pair of states
// is constrained to be related by a single move, it is easy to see the sequence of moves
// once you have the sequence of states.

// For n discs, 2^n states are needed for a solution (including the initial state and the final state).

// Performance: currently, the problem can be solved for up to 5 discs; this takes several
// minutes with the Chaff solver.

// Questions to: ilya_shl@mit.edu

open std/ord

sig Stake { }

sig Disc { }

// sig State: the complete state of the system --
// which disc is on which stake.  An solution is a
// sequence of states.
sig State {
  on: Disc ->! Stake  // _each_ disc is on _exactly one_ stake
  // note that we simply record the set of discs on each stake --
  // the implicit assumption is that on each stake the discs
  // on that stake are ordered by size with smallest disc on top
  // and largest on bottom, as the problem requires.
}


fun State::discsOnStake(stake: Stake): set Disc {
  // compute the set of discs on the given stake in this state.
  // ~(this::on) map the stake to the set of discs on that stake.
  result = stake.~(this::on)
}

fun State::topDisc(stake: Stake): option Disc {
  // compute the top disc on the given stake, or the empty set
  // if the stake is empty
  result = { d: this..discsOnStake(stake) | this..discsOnStake(stake) in OrdNexts(d)+d }
}

det fun State::Move( fromStake, toStake: Stake): State {
   // Describes the operation of moving the top disc from stake fromStake
   // to stake toStake.  This function is defined implicitly but is
   // nevertheless deterministic, i.e. the result state is completely
   // determined by the initial state and fromStake and toStake; hence
   // the "det" modifier above.  (It's important to use the "det" modifier
   // to tell the Alloy Analyzer that the function is in fact deterministic.)

   let d = this..topDisc(fromStake) | {
      // all discs on toStake must be larger than d,
      // so that we can put d on top of them
      this..discsOnStake(toStake) in OrdNexts(d)
      // after, the fromStake has the discs it had before, minus d
      result..discsOnStake(fromStake) = this..discsOnStake(fromStake) - d
      // after, the toStake has the discs it had before, plus d
      result..discsOnStake(toStake) = this..discsOnStake(toStake) + d
      // the remaining stake afterwards has exactly the discs it had before
      let otherStake = Stake - fromStake - toStake |
	result..discsOnStake(otherStake) = this..discsOnStake(otherStake)
   }
}

fun Game ( ) {
   // there is a leftStake that has all the discs at the beginning,
   // and a rightStake that has all the discs at the end
   Disc in Ord[State].first..discsOnStake(Ord[Stake].first)
   some finalState: State | Disc in finalState..discsOnStake(Ord[Stake].last)

   // each adjacent pair of states are related by a valid move of one disc
   all preState: State - Ord[State].last | 
       let postState=OrdNext(preState) |
          some fromStake: Stake | {
             // must have at least one disk on fromStake to be able to move
             // a disc from fromStake to toStake
             some preState..discsOnStake(fromStake)
             // post- results from pre- by making one disc move
             some toStake: Stake | postState=preState..Move(fromStake, toStake)
          }
}

fun Game2 ( ) {
   // there is a leftStake that has all the discs at the beginning,
   // and a rightStake that has all the discs at the end
   Disc in Ord[State].first..discsOnStake(Ord[Stake].first)
   some finalState: State | Disc in finalState..discsOnStake(Ord[Stake].last)

   // each adjacent pair of states are related by a valid move of one disc
   all preState: State - Ord[State].last | 
       let postState=OrdNext(preState) |
          some fromStake: Stake | 
             let d = preState..topDisc(fromStake) | {
               // must have at least one disk on fromStake to be able to move
               // a disc from fromStake to toStake
               some preState..discsOnStake(fromStake)
               postState..discsOnStake(fromStake) = preState..discsOnStake(fromStake) - d
               some toStake: Stake | {
                 // post- results from pre- by making one disc move
                 preState..discsOnStake(toStake) in OrdNexts(d)
                 postState..discsOnStake(toStake) = preState..discsOnStake(toStake) + d
                // the remaining stake afterwards has exactly the discs it had before
                let otherStake = Stake - fromStake - toStake |
	           postState..discsOnStake(otherStake) = preState..discsOnStake(otherStake)
                }
             }
      }

smallgame : run Game2 for 1 but 3 Stake, 3 Disc, 8 State
//run Game for 1 but 3 Stake, 5 Disc, 32 State
