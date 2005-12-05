// model of Peterson's algorithm for mutual exclusion for
// n processes
//
// names kept similar to murphi spec to make correspondence
// clear

module distalg/peterson

open std/ord

sig pid {
}

sig priority {
}

fact {
  # priority = # pid + 1
}

sig label_t {}

// here subtyping would help
static part sig L0, L1, L2, L3, L4 extends label_t {}

sig State {
  P: pid -> label_t,
  Q: pid -> priority,
  turn: priority -> pid,
  localj: pid -> priority
}

fun NOPTrans(i: pid, pre, post : State) {
  post.P[i] = pre.P[i]
  post.Q[i] = pre.Q[i]
  post.localj[i] = pre.localj[i]
}

fun L0TransPre(i : pid, pre : State) {
  // precondition
  pre.P[i] = L0
}

fun L0Trans(i: pid, pre, post : State) {
  L0TransPre(i, pre)
  // localj[i] := 1
  post.localj[i] = OrdNext(Ord[priority].first)
  post.P[i] = L1
  post.Q[i] = pre.Q[i]
  // something for turn?
  post.turn = pre.turn
}

fun L1TransPre(i : pid, pre : State) {
  // precondition
  pre.P[i] = L1
}
fun L1Trans(i : pid, pre, post : State) {
  L1TransPre(i, pre)
  post.localj[i] = pre.localj[i]
  post.Q[i] = pre.localj[i]
  post.P[i] = L2
  // something for turn?
  post.turn = pre.turn
}

fun L2TransPre(i : pid, pre : State) {
  // precondition
  pre.P[i] = L2
}

fun L2Trans(i : pid, pre, post : State) {
  L2TransPre(i, pre)
  post.localj[i] = pre.localj[i]
  post.Q[i] = pre.Q[i]
  post.P[i] = L3
  post.turn[post.localj[i]] = i
  all j : priority - post.localj[i] |
    post.turn[j] = pre.turn[j]
}

fun L3TransPre(i : pid, pre : State) {
  // precondition
  pre.P[i] = L3

  ( with pre | ( all k : pid - i | 
                   OrdLT(Q[k], localj[i]) ) ||
               ( turn[localj[i]] != i ) )  
}

fun L3Trans(i : pid, pre, post : State) {
  L3TransPre(i, pre)
    post.localj[i] = OrdNext(pre.localj[i])
    OrdLT(post.localj[i], Ord[priority].last) =>
      post.P[i] = L1
    else
      post.P[i] = L4
    post.Q[i] = pre.Q[i]
    post.turn = pre.turn
}

fun L4TransPre(i : pid, pre : State) {
  // precondition
  pre.P[i] = L4
}

fun L4Trans(i : pid, pre, post : State) {
  L4TransPre(i, pre)

  post.P[i] = L0
  post.Q[i] = Ord[priority].first
  post.localj[i] = pre.localj[i]
  post.turn = pre.turn
}

fun RealTrans(i : pid, pre, post : State) {
  L0Trans(i,pre,post) ||
  L1Trans(i,pre,post) ||
  L2Trans(i,pre,post) ||
  L3Trans(i,pre,post) ||
  L4Trans(i,pre,post)
}

fun SomePre(i : pid, pre : State) {
  L0TransPre(i, pre) ||
  L1TransPre(i, pre) ||
  L2TransPre(i, pre) ||
  L3TransPre(i, pre) ||
  L4TransPre(i, pre) 
}

fact Init {
  let firstState = Ord[State].first | {
    all i : pid | {
      firstState.P[i] = L0
      firstState.Q[i] = Ord[priority].first
    }
    no firstState.turn
    no firstState.localj
  }
}

fact LegalTrans {
  all pre : State - Ord[State].last |
    let post = OrdNext(pre) | {
      /*some i : pid | {
        // HACK:
        // need to specify that if some node
        // can make a non-NOP transition, it
        // does, but i can't figure out how
        // right now
        Trans(i,pre,post) && !NOPTrans(i,pre,post)
        all j : pid - i |
          NOPTrans(j,pre,post)
      }*/
      all i : pid | 
        RealTrans(i,pre,post) || NOPTrans(i,pre,post)
      (all i : pid | NOPTrans(i,pre,post)) => {
         all i : pid | !SomePre(i,pre) 
         post.turn = pre.turn
      }
    }
}

assert Safety {
  all disj i1, i2 : pid, s : State |
    not (s.P[i1] = L4 && s.P[i2] = L4)
}

assert NotStuck {
  all pre : State - Ord[State].last |
    let post = OrdNext(pre) |
      some i : pid |
        RealTrans(i, pre, post) && !NOPTrans(i,pre,post)
}

fun TwoRun ( ) {
  some disj s1, s2: State, disj i1, i2: pid | {
    s1.P[i1] = L4 
    s2.P[i2] = L4
  }
}

fun ThreeRun ( ) {
  some disj s1, s2, s3: State, disj i1, i2, i3: pid | {
    s1.P[i1] = L4 
    s2.P[i2] = L4
    s3.P[i3] = L4
  }
}


// 2 pids requires 8 states
// 3 pids requires 16 states
run TwoRun for 13 but 3pid,4priority,5label_t

// haven't run this one successfully yet
//run ThreeRun for 19 but 3pid,4priority,5label_t

// how many states do we need for this to match murphi?
check Safety for 10 but 2pid,3priority,5label_t

// this assertion is trivial because of the hack described above
//check NotStuck for 10 but 2pid,3priority,5label_t