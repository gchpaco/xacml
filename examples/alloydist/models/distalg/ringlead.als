module distalg/ringlead

open std/bool
open std/ord
open distalg/messaging

sig RingLeadNode extends Node {
   rightNeighbor: Node
} 

fact DefineRing {
  (one Node || no n: Node | n = n.rightNeighbor)
  all n: Node | Node in n.^rightNeighbor
}

sig RingLeadMsgState extends MsgState {
  id: Node
}

sig MsgViz extends Msg {
  vFrom: Node,
  vTo: set Node,
  vId: Node
} 

fact {
  MsgViz = Msg
  MsgViz$vFrom = Msg$state.MsgState$from
  MsgViz$vTo = Msg$state.MsgState$to
  MsgViz$vId = Msg$state.MsgState$id
}
  

sig RingLeadNodeState extends NodeState {
  leader: Bool
}


fun RingLeadFirstTrans (self: Node, pre, post: NodeState,
                        sees, reads, sends, needsToSend: set Msg) {
   one sends
   # needsToSend = 1
   sends.state.to = self.rightNeighbor
   sends.state.id = self
   post.leader = False
}

fact InitRingLeadState {
  all n: Node |
    Ord[Tick].first.state[n].leader = False
}

fun RingLeadRestTrans (self: Node, pre, post: NodeState,
                       sees, reads, sends, needsToSend: set Msg) {
   RingLeadTransHelper(self, sees, reads, sends, needsToSend)
   post.leader = True iff (pre.leader = True ||
                           self in reads.state.id)
}

fun RingLeadTransHelper(self: Node, sees, reads, sends, needsToSend: set Msg) {
   // we take any messages whose node ids are higher than ours,
   // and we forward them to the right neighbor.  we drop
   // all other messages.  if we get a message with our own
   // id, we're the leader.
   reads = sees

   all received: reads | 
     (received.state.id in OrdNexts(self)) => 
       one weSend: sends | (weSend.state.id = received.state.id && weSend.state.to = self.rightNeighbor)

   all weSend: sends | {
     let mID = weSend.state.id | {
       mID in OrdNexts(self)
       mID in reads.state.id
       weSend.state.to = self.rightNeighbor
     }
     //weSend.sentBecauseOf = { received : reads | received.id = weSend.id }
     //all otherWeSend: sends - weSend | otherWeSend.id != weSend.id
   }
  
   # needsToSend = # { m: reads | m.state.id in OrdNexts(self) }
}
fact RingLeadTransitions {
   all n: Node {
      all t: Tick - Ord[Tick].last | {
         t = Ord[Tick].first => 
           RingLeadFirstTrans(n, t.state[n], OrdNext(t).state[n], t.visible[n], t.read[n], t.sent[n], t.needsToSend[n]),
           RingLeadRestTrans(n, t.state[n], OrdNext(t).state[n], t.visible[n], t.read[n], t.sent[n], t.needsToSend[n])
      }
      // also constrain last tick
      RingLeadTransHelper(n, Ord[Tick].last.visible[n], Ord[Tick].last.read[n], Ord[Tick].last.sent[n], Ord[Tick].last.needsToSend[n])
   }
}

assert OneLeader {
   all t: Tick |
      sole n: Node |
         t.state[n].leader = True
}

fact CleanupViz {
  RingLeadNode = Node
  RingLeadMsgState = MsgState
  RingLeadNodeState = NodeState
}

fun SomeLeaderAtTick(t: Tick) {
  some n: Node | t.state[n].leader = True
}

fun NeverFindLeader ( ) {
  Loop()
  all t: Tick | ! SomeLeaderAtTick(t)
}

assert Liveness {
  (NoLostMessages() && NoMessageShortage()) => ! NeverFindLeader()
}

fun SomeLeader ( ) { some t: Tick | SomeLeaderAtTick(t) }

assert LeaderHighest {
  all t: Tick, n: Node |
    t.state[n].leader = True => n = Ord[Node].last
}
 
run NeverFindLeader for 1 but 3 Tick, 2 Bool, 2 NodeState
check Liveness for 3 but 6 Msg, 2 Bool, 2 NodeState
check OneLeader for 5 but 2 Bool, 2 NodeState
run SomeLeader for 2 but 3Node, 5Msg, 5Tick, 5MsgState
check LeaderHighest for 3 but 2 NodeState, 5Msg, 5MsgState, 5Tick     
  