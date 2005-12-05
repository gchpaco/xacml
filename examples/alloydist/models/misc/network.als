module misc/network

//TICK FILE

sig Tick{
  //do we have a hook for inverse relation prevTick?
  nextTick: option Tick,
  
  prevTick: option Tick
}
{
  Tick$prevTick = ~Tick$nextTick
  //condition that the nextTick relation is ordered
  isOrdered(Tick$nextTick)		
}

fun isOrdered [t] (rel: t -> t) {}

sig firstTick extends Tick{}
{
  no prevTick
}

sig lastTick extends Tick{}
{
  no nextTick
}

//NETWORK FILE


sig Network{
  nodes: set Node,
  neighbor: Node -> Node
}


fun isReliable (net: Network){
  all t: Tick, n: net.nodes {
     (n.visible[t.nextTick] = n.visible[t] + (Node.sent[t] & n.~mTo) - n.read[t])
     // messages sent by a node on a tick
     // are from that node
     n.sent[t].mFrom in n  
  }
}

fun isUnreliable (net: Network){
  all t: Tick, n: net.nodes{
    n.visible[t] in n.visible[t.nextTick]
    n.visible[t.nextTick] + n.visible[t] in (Node.sent[t] & n.~mTo) - n.read[t]
  }
}


// NETCOMP FILE


sig Node{
  visible: Tick -> Msg,
  sent: Tick -> Msg,
  read: Tick -> Msg
}

sig Msg{
  mFrom: scalar Node,
  mTo: scalar Node
}




//RING FILE

static sig RingNetwork extends Network{
  leftNode: RingNode -> RingNode,
  rightNode: RingNode -> RingNode,
  // set of processes at each tick who think they are the leader
  leader: Tick -> RingNode
}
{
  //All nodes are of type RingNode
  Node in RingNode


  //every node has two neighbors, it's right node and left node
  all n: nodes | n.leftNode + n.rightNode = n.neighbor
  rightNode = ~ leftNode

  // force leftNode/rightNode to define a ring.
  (one Node) || (no n:Node | n = n.leftNode)
  all n: Node| Node in n.^leftNode

  // at first tick, each process sends out its own ID
  all n: Node| one m:Msg | (n.sent[firstTick] = m &&
                     m.mTo = n.rightNode &&
                     m.contents = n.id)

  // at all other ticks
  all t: Tick - firstTick, n:Node |
           (
              (n.sent[t].contents in n.visible[t].contents & n.id.^nextID) &&
              (n.sent[t].mTo in n.rightNode) &&
              (n.read[t] = n.visible[t])
           )

  // any process who gets its own ID decides it is the leader
  all t:Tick | leader[t] = { n: Node | n.id in n.visible[t].contents}
}

assert NoTwoLeaders{
  all t: Tick | one Network.leader[t] || no Network.leader[t]
}

assert SomeLeader{
  some Network.leader[Tick]
}

sig ID{
  prevID: ID,
  nextID: ID
}
{
  ID$prevID = ~ID$nextID
  isOrdered(ID$prevID)
}

sig RingNode extends Node{
  id: scalar ID
}

sig RingMsg extends Msg{
  contents: scalar ID
}
