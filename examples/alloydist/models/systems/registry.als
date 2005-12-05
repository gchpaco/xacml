module Registry
sig Property {covers: set Property}
sig Resource {}
sig DB {
	resources: set Resource,
	props: resources ->+ Property
	}

fact CoversPartialOrder {
	all p,q,r: Property {
		p in p.covers // reflexive
		q in p.covers && r in q.covers => r in p.covers		// transitive
		p in q.covers && q in p.covers => p = q				// antisymmetric
		}
	}

fun DB.Lookup (query: set Property): set Resource {
	result = { r: this.resources | query in r.this::props.covers}
	}

fun DB.Register (r: Resource, ps: set Property): DB {
	result.resources = this.resources + r
	result::props = this::props + r -> ps
	}


assert RegisterMonotonic {
	all db: DB, r: Resource, ps: set Property, q: set Property |
		db..Lookup (q) in db..Register (r,ps)..Lookup (q)
	}


assert GetAll {
	all db: DB, q: set Property | no q => db..Lookup (q) = db.resources
	}

assert RegisterCovers {
	all db: DB, r: Resource, ps: set Property, q: set Property |
		db..Register (r,ps)..Lookup (q) = db..Register (r,ps.covers)..Lookup (q)
	}

// query need not be non-empty

// RegisterCovers requires covers to be refl and transitive

// explain that purpose is minimal constraints for reasonable properties
