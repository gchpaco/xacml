module misc/marksweepgc

// a node in the heap
sig Node {}

sig HeapState {
  left, right : Node ->? Node,
  marked : set Node,
  freeList : option Node
}

det fun HeapState.clearMarks( ) : HeapState {
  // clear marked set 
  no result.marked
  // left and right fields are unchanged
  result.left = this.left
  result.right = this.right
}

// how we would write the mark function if we
// supported recursion (maybe?)
// the issue is, each mark of a node affects the
// recursive calls, so we need a new HeapState
// for each actual marking, right?  punting on
// this for now
/*
det fun HeapState.mark(root : Node) : HeapState {
  if (root !in this.marked) then {
    root in result.marked
    if (some this.left[root]) then mark(this, this.left[root], result)
    if (some this.right[root]) then mark(this, this.right[root], result)
  }
  result.left = this.left
  result.right = this.right
}
*/

// simulate the recursion of the mark() function using transitive closure
det fun HeapState.reachable(n: Node) : set Node {
  result = n + n.^(this.left) + n.^(this.right)
}

det fun HeapState.mark(from : Node) : HeapState {
  result.marked = this..reachable(from)
  result.left = this.left
  result.right = this.right
}

// complete hack to simulate behavior of code to set freeList
det fun HeapState.setFreeList(): HeapState {
  // especially hackish
  result.freeList.*(result.left) in (Node - this.marked)
  all n: Node |
    (n !in this.marked) => { 
      no result.right[n]
      result.left[n] in (result.freeList.*(result.left))
      n in result.freeList.*(result.left)
    } else {
      result.left[n] = this.left[n]
      result.right[n] = this.right[n]
    }
  result.marked = this.marked
}

det fun HeapState.GC(root : Node) : HeapState {
  result = this..clearMarks()..mark(root)..setFreeList()
}

assert Soundness1 {
  all h, h' : HeapState, root : Node |
    h' = h..GC(root) => 
      all live : h..reachable(root) | {
        h'.left[live] = h.left[live]
        h'.right[live] = h.right[live]
      }
}

assert Soundness2 {
  all h, h' : HeapState, root : Node |
    h' = h..GC(root) => 
      no h'..reachable(root) & h'..reachable(h'.freeList)
}

assert Completeness {
  all h, h' : HeapState, root : Node |
    h' = h..GC(root) => 
      (Node - h'..reachable(root)) in h'..reachable(h'.freeList)
}

check Soundness1 for 3
check Soundness2 for 3
check Completeness for 3