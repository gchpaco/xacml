// direct specification of a distributed
// spanning tree algorithm over arbitrary
// network topologies
//
// description of algorithm: each process has a 
// parent and a level, both of which are initally
// null.  a distinct root node exists at which the
// algorithm starts.  in the first step, the root
// assigns itself the level of zero and sends its
// level to its neighbors.  subsequently, if a node
// reads a message with level k, it sets its level
// to k+1, records the sender of the message as its
// parent, and sends the level k+1 to its neighbors.  
// once a node has set its level and parent, it ignores
// subsequent messages.  eventually, the parent pointers
// will form a spanning tree, rooted at Root.  
//
// we model communication through a state-reading model, in which 
// nodes can directly read the state of their neighbors.  messages
// are not explicity modelled.  this makes no difference for this
// algorithm since once a node sends a message, the state of the node 
// stays the same as the contents of the message.  

module distalg/opt_spantree

open std/ord
open std/util

sig Process {
  adj : set Process 
}

static disj sig Root extends Process {
}

// intuitively, the depth level at which
// a process resides in the spanning tree,
// with the root at level zero
sig Lvl {
}

fact {
  // adj is symmetric
  Process$adj = ~Process$adj
}

fact {
  // topology is connected
  Process in Root.*adj
}

sig State {
  // the set of processes which execute in this state.
  // used to allow flexibility in how many processes
  // run simultaneously
  runs : set Process,
  // the level of a process in this state
  lvl: Process ->? Lvl,
  // who the process thinks is its parent in this state.
  // the parent pointers should eventually become 
  // the spanning tree
  parent: Process ->? Process
}

fun Init( ) {
  // initially, the lvl and parent fields are blank
  let fs = Ord[State].first | {
    no fs.lvl
    no fs.parent
  }
}

// simple NOP transition
fun TRNop(p : Process, pre, post: State) {
  pre.lvl[p] = post.lvl[p]
  pre.parent[p] = post.parent[p]
}

// preconditions for a process to actually act
// in a certain pre-state
// used to preclude stalling of entire system
// for no reason (see TransIfPossible)
fun TRActPreConds(p : Process, pre : State) {
  // can't already have a level
  no pre.lvl[p]
  // must have a neighbor with a set level so
  // p can read it
  // Root doesn't need to read value from a 
  // neighbor
  (p = Root || some pre.lvl[p.adj])
}

// transition which changes state of a process
fun TRAct(p : Process, pre, post : State) {
  // can't already have a level
  no pre.lvl[p]
  (p = Root) => {
    // the root sets its level to 
    // 0, and has no parent pointer
    post.lvl[p] = Ord[Lvl].first
    no post.parent[p]
  } else {
    // choose some adjacent process
    // whose level is already set
    some adjProc: p.adj |
      let nLvl = pre.lvl[adjProc] | {
        some nLvl
        // p's parent is the adjacent
        // process, and p's level is one greater than 
        // the level of the adjacent process (since 
        // its one level deeper)
        post.lvl[p] = OrdNext(nLvl)
        post.parent[p] = adjProc
      }
  }
}
    
fun Trans(p : Process, pre, post : State) {
  TRAct(p, pre, post) ||
  TRNop(p, pre, post)
}

fact TransIfPossible {
  // all processes do a nop transition in some
  // state only when no process can act because
  // preconditions are not met
  all s : State - Ord[State].last |
    (all p : Process | TRNop(p, s, OrdNext(s))) =>
      (all p : Process | !TRActPreConds(p,s))
}

fact LegalTrans {
  Init()
  all s : State - Ord[State].last |
    let s' = OrdNext(s) | {
      all p : Process |
        p in s.runs => Trans(p, s, s') else TRNop(p,s,s')
    }
}

fun PossTrans(s, s' : State) {
  all p : Process | Trans(p,s,s')
}

fun SpanTreeAtState(s : State) {
  // all processes reachable through inverted parent pointers
  // from root (spanning)
  Process in Root.*~(s.parent)
  // parent relation is a tree (DAG)
  // we only need to check the DAG condition since there can 
  // be at most one parent for a process (constrained by
  // multiplicity)
  IsDAG(~(s.parent))
}

// show a run that produces a spanning tree
fun SuccessfulRun( ) {
  univ[Process] in Process
  some s : State | SpanTreeAtState(s)
}

// show a trace without a loop
fun TraceWithoutLoop( ) {
  all disj s, s' : State | {
    !EquivStates(s, s')
    (s' in OrdNexts(s) && (s' != OrdNext(s))) => !PossTrans(s,s')
  }
  all s: State | !SpanTreeAtState(s)
  //!SpanTreeAtState(Ord[State].last)
}

// defines equivalent states
fun EquivStates(s, s' : State) {
  s.lvl = s'.lvl
  s.parent = s'.parent
}

// show a trace that violates liveness
fun BadLivenessTrace( ) {
  // two different states equivalent (loop)
  some disj s, s' : State | EquivStates(s, s')
  all s : State | !SpanTreeAtState(s)
  
  
}

// check that once spanning tree is constructed,
// it remains
assert Closure {
  all s : State - Ord[State].last |
    SpanTreeAtState(s) => (s.parent = OrdNext(s).parent)
}
    
// note that for the worst case topology and choice
// of root, the scope of Lvl must equal the scope
// of Process
sRun : run SuccessfulRun for 6 but 4State
run TraceWithoutLoop for 8 but 9State    
//run BadLivenessTrace for 5 but 7State   
//check Closure for 5 but 7State



