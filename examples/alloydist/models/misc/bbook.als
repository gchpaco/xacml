module misc/bbook

sig Person {}
sig Date {}
sig BirthdayBook {known: set Person, date: known ->! Date}

fun add (bb, bb': BirthdayBook, p: Person, d: Date) {
	p !in bb.known && bb'.date = bb.date + p->d
	}

fun lookup (bb: BirthdayBook, p: Person, d: Date) {
	d = p.bb::date
	}
	
assert addWorks {all bb, bb': BirthdayBook, p: Person,
d, d': Date |
	add (bb, bb', p, d) && lookup (bb, p, d') => d = d'
	}
	
fact {some BirthdayBook}

//run add for 3
 check addWorks for 4
