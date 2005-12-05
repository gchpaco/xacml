module distalg/msgs

open models/ticks

sig Node{
  visible: Tick -> Msg,
  sent: Tick -> Msg,
  read: Tick -> Msg
}

sig Msg{
  mFrom: scalar Node,
  mTo: scalar Node
}

fact InitNetworkInv{
  no Node.visible[firstTick]
}

fact ReliableDelivery{
  all t: Tick, n: Node { 
     (n.visible[t.nextTick] = n.visible[t] + (Node.sent[t] & n.~mTo) - n.read[t])
     // messages sent by a node on a tick
     // are from that node
     n.sent[t].mFrom in n  
  }
}

fact BasicDelivery{
  all t: Tick, n: Node {
     (n.visible[t.nextTick] = n.visible[t] + (Node.sent[t] & n.~mTo) - n.read[t])
     // messages sent by a node on a tick
     // are from that node
     n.sent[t].mFrom in n  
  }
}
	
