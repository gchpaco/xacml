module LyndaNetwork
open std/ord

sig Machines {
	permittedUsers : set User,
	adjacentMachines : set Machines
}
disj sig LyndaMachines, OtherMachines extends Machines {}
sig Servers extends LyndaMachines {} {
	no u:User | u.machine in Servers
}
static disj sig Firewall, FileServer, FinancialDB,
	Internet, MailServer extends Servers {}
static disj sig FinancialHub, StaffHub, StudentHub extends Servers {}

sig User {
	machine : scalar LyndaMachines
}
disj sig Student, Staff extends User {}
sig FinancialStaff extends Staff {}
fact { User = Student + Staff }

sig StaffMachines, StudentMachines, FinancialMachines
	extends Machines {} {
	all s:Machines | s in StaffMachines <=> some u:Staff | u.machine = s
	all s:Machines | s in StudentMachines <=> some u:Student | u.machine = s
	all s:Machines | s in FinancialMachines <=> some u:FinancialStaff | u.machine = s
}

fun CanTalk (machine1, machine2 : scalar Machines) {
	machine2 in machine1.*adjacentMachines
}

fun CanLogin (user : scalar User, server : scalar Machines) {
	CanTalk (user.machine, server)
	user in server.permittedUsers
}

fact LoginImpliesAccess {
	all u:User | all m:Machines | CanLogin (u, m) => CanTalk (u.machine, m)
}

fact NetworkLayout {
	all s:StudentMachines | s.adjacentMachines = StudentHub
	all s:(StaffMachines - FinancialMachines) |
		s.adjacentMachines = StaffHub
	all f:FinancialMachines |
		f.adjacentMachines = FinancialHub
	StudentHub.adjacentMachines = StudentMachines + Firewall + FileServer
	StaffHub.adjacentMachines = StaffMachines + Firewall + FileServer
	FinancialHub.adjacentMachines = FinancialMachines + StaffHub + FinancialDB
	
	no FinancialDB.adjacentMachines
	Firewall.adjacentMachines = Internet + MailServer
	no FileServer.adjacentMachines
	Internet.adjacentMachines = Firewall
	all o:OtherMachines | LyndaMachines & o.adjacentMachines = Internet
}

assert UsersCanAccessInternet {
	all u:User | CanTalk (u.machine, Internet)
}

assert StudentsCannotAccessThings {
	all s:Student {
		no m:StaffMachines | CanTalk (s.machine, m)
		! CanTalk (s.machine, FinancialDB)
		! CanLogin (s, Firewall)
		CanLogin (s, FileServer)
	}
}

assert BadStaffCannotAccessThings {
	no s:(Staff - FinancialStaff) | CanTalk (s.machine, FinancialDB)
	all f:FinancialStaff | CanLogin (f, FinancialDB)
	all s:Staff | CanLogin (s, FileServer)
	all s:Staff | CanLogin (s, MailServer)
}

assert OutsideCannotAccessThings {
	no m:OtherMachines | some lm:(LyndaMachines - Firewall - MailServer) | CanTalk (m, lm)
	no m:OtherMachines | some lm:(LyndaMachines - MailServer) | CanLogin (m.~machine, lm)
	/* Make sure that people outside can read their email */
	some m:OtherMachines | CanLogin (m.~machine, MailServer)
}

check UsersCanAccessInternet for 2 but 6 Machines
check StudentsCannotAccessThings for 2 but 6 Machines
check BadStaffCannotAccessThings for 2 but 6 Machines
check OutsideCannotAccessThings for 2 but 6 Machines