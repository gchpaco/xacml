module misc/B_example

// begin library

sig List [t] {
  first: t,
  rest : option List [t]
}

static sig ListOps [t] {
  append: List[t] -> t -> List [t]
}

fact appendDef [t] { 
  all l: List [t], elt: t {
    l.(ListOps[t].append)[elt].first = l.first
    no l.rest => {
    	l.(ListOps[t].append)[elt].rest.first = elt
	no l.(ListOps[t].append)[elt].rest.rest
	} ,
        l.(ListOps[t].append)[elt].rest = l.rest.(ListOps[t].append)[elt]
  }
}

// end library

sig Student {}
sig Grade   {}

sig StudentGrade {
  st: Student,
  gr: Grade
}  

sig State {
  db: List [StudentGrade]  
}

fun register (pre, post: State, s: Student, g: Grade) {
  some sg: StudentGrade {
    sg.st = s
    sg.gr = g
    post.db = pre.db.(ListOps[StudentGrade].append)[sg]
		}
}

run register for 3