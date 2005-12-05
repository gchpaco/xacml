module distalg/spantree

open std/ord
open distalg/messaging

sig Lvl { }

sig STNode extends Node {
   adj: set Node
} {
  this !in adj
}

fact {
   STNode$adj = ~STNode$adj
}

static sig STRoot extends STNode { }

fact { STNode in STRoot.*adj }

sig STNodeState extends NodeState {
   lvl: option Lvl,
   parent: option STNode
}

sig STMsg extends Msg {
   lvl: Lvl
}

fun InitialSTNodeState(ns: STNodeState) {
   no ns.lvl
   no ns.parent
}

fun TrNOP(self: STNode, pre, post: STNodeState, sees, reads, sends: set STMsg) {
   no reads && no sends && pre=post
}

fun TrActHelper(self: STNode, pre, post: STNodeState, gotLvl: Lvl,
                gotParent: option STNode, sends: set STMsg) {
   // precondition: process only acts if it does not know its level yet.
   // if it does, it ignores all messages.
   no pre.lvl
   // postconditions:
   // record the given level and parent in the process's state.
   post.lvl = gotLvl
   post.parent = gotParent
   // tell neighbors our level
   sends.to = (self.adj - gotParent) && sends.lvl = gotLvl
   # sends =< # (self.adj - gotParent)
}

fun TrAct(self: STNode, pre, post: STNodeState, sees, reads, sends: set STMsg) {
   self = STRoot => {
      no reads
      TrActHelper(self, pre, post, Ord[Lvl].first, none[STNode], sends)
   } else {
      some m: sees | {
         reads = m
         TrActHelper(self, pre, post, OrdNext(m.lvl), m.from, sends)
      }
   }
}

sig STTick extends Tick {
}

fun Transition(self: STNode, pre, post: STNodeState, sees, reads, sends: set STMsg) {
   
   TrAct(self, pre, post, sees, reads, sends) ||
   (!TrAct(self, pre, post, sees, reads, sends)  &&
    TrNOP(self, pre, post, sees, reads, sends))
}

fact ValidTrace {
   all n: STNode | {
      InitialSTNodeState(Ord[Tick].first.state[n])
      all t: STTick - Ord[Tick].last | {
         Transition(n, t.state[n], OrdNext(t).state[n], t.visible[n],
                    t.read[n], t.sent[n])
      }
   } 
}

fact CleanUpViz {
   STNode = Node
   STMsg = Msg
   STTick = Tick
   univ[Msg] in Msg
}

fun GetSomeTree ( ) {
   # Node > 1
   some t: STTick | SpanTreeAtTick(t)
}

fun BadLivenessTrace () {
  all t: STTick | ! SpanTreeAtTick(t)
  Loop()
}

fun Loop () {
  all n: STNode |
    let lastTick = Ord[Tick].last |
      some prevTick: STTick - lastTick |
        Transition(n, lastTick.state[n], prevTick.state[n],
                   lastTick.visible[n], lastTick.read[n], lastTick.sent[n])
}

assert Liveness {
  NoLostMessages() => ! BadLivenessTrace()
}

assert NoCycles {
   all t: STTick, n: STNode |
      n !in n.^~(t.state.parent)
}

fun SpanTreeAtTick(t: STTick) {
      STNode in STRoot.*~(t.state.parent)
}

run BadLivenessTrace for 2 but 1Msg, 3Tick
run GetSomeTree for 4
check NoCycles for 5 but 8 Msg
check Liveness for 5


