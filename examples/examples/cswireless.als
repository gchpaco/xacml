module WirelessSetup
open std/ord

sig Users {}
disj sig GoodUsers, BadUsers extends Users {}

sig MAC {}

sig AccessPoints {}

sig NetworkCard {
	user : scalar Users
}
sig WirelessCard extends NetworkCard {}

sig AcceptableWirelessMACs extends MAC {}
static sig CSTest extends AccessPoints {}

sig State {
	connectedThrough: NetworkCard ->? AccessPoints,
	macs: NetworkCard ->! MAC	
}

fact AcceptablePeopleGetInThroughCSTest {
	all s:State {
		all m:WirelessCard {
			s.macs[m] in AcceptableWirelessMACs <=> s.connectedThrough[m] = CSTest
		}
	}
}

fun ChangeMAC (c: scalar NetworkCard, m: scalar MAC, s, s': State) {
	c.(s'.macs) = m
	all n:NetworkCard | n != c => {
		s'.connectedThrough[n] = s.connectedThrough[n]
		s'.macs[n] = s.macs[n]
	}
}

fun Initialization (s: State) {
	all w:WirelessCard | s.macs[w] in AcceptableWirelessMACs <=> w.user in GoodUsers
}

fun BadPeopleConnecting () {
	some s:State | some m:WirelessCard | s.connectedThrough[m] = CSTest && m.user in BadUsers
}

fun Execution () {
	Initialization (Ord[State].first)
	all s: State - Ord[State].last | let s' = OrdNext(s) | NextState (s, s')
}

fun NextState (s, s': State) {
	some n:NetworkCard | some m:MAC | ChangeMAC (n, m, s, s')
}

fun ListCanBecomeInaccurate () {
	Execution () && BadPeopleConnecting ()
}

assert ListNeverBecomesInaccurate {
	Execution () => ! BadPeopleConnecting ()
}

fact WirelessCardsCantChange {
	all s:State | all w:WirelessCard | let s' = OrdNext(s) | s'.macs[w] = s.macs[w]
}

run ListCanBecomeInaccurate for 4 but 2 State without WirelessCardsCantChange
check ListNeverBecomesInaccurate for 4