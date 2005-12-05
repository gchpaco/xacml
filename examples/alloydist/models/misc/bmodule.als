// begin library
module misc/bmodule

sig List {
 //first:  ,
 rest : option List
}

// static sig ListOps [t] {
//   append: List [t] -> t -> List [t]
// }

// fact appendDef [t] { 
//   all l: List [t], elt: t |
//     l.append [elt].first = l.first &&
//     no l.rest => {
//     	l.append[elt].rest.first = elt
// 			no l.append[elt].rest.rest
// 			} ,
//     l.append[elt].rest = l.rest.append[elt]
// }
// end library


fun SomeStud () { some List }

run SomeStud for 3

