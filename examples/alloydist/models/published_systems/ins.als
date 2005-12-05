// spec by SK
// modified by DJ to incorporate new features: static sig, sig-facts, shorter keywords (disj)
// probably won't compile right now because of <=> operator

module published_systems/ins

sig Attribute {}
sig Value {}
sig Record {}

static sig Wildcard extends Value {}

sig AVTree {
        values: set Value,
        attributes: set Attribute,
        root: values - Wildcard,
        av: attributes !->+ (values - root),
        va: (values - Wildcard) !-> attributes}
        {
				// values (and attributes) of tree are those reachable from root
        values = root.*(va.av) }

sig Query extends AVTree {} {all a:attributes | one a.av}

sig DB extends AVTree {
        records : set Record,
        recs: (values - root) +-> records,
        lookup : Query -> (values -> records)}
        {Wildcard !in db.values}

fact AddInvariants {
        all db: DB | with db {
                // dom operator is illegal, a domain() function should be used
                // all v: values - dom va | some v.recs // Add3, leaf values must contain some record(s)
                all v: values | no v.recs & v.^(~av.~va).recs // Add4, records lowest possible
                all a: attributes | all disj v1, v2: a.av | some rr = *(va.av).recs | no v1.rr & v2.rr}}  // Add5

fun DB::Get(r : Record) : Query {
        with result {
               // removed 'with this |' from before 'r' for temporary parsing
               values = with this | r.~recs.*(~av.~va)
               attributes = result.values.~(this.av)
               root = this.root
               all a : attributes| a.~va = a.~(this.va)
               all v : values | v.~av = v.~(this.av)}}

fun Conforms (db: DB, q: Query, r: Record) {
        // added '&&' after p.va, parsing problem
        some p = db..Get(r) { q.va in p.va
                                          (q.av - Attribute -> Wildcard) in p.av}}

fun indSubset(db : DB, q : Query, r : set Record, v : Value) {
        with db | all a : v.(q.va) | (a.(q.av) in a.av => r in (a.(q.av)).(q.lookup)) &&
                                               (a.(q.av) = WildCard => r in a.av.*(va.av).rec)}

fun DB::Lookup(q : Query): set Record {
        with this {
               all v : Value | not v.(q.va) in v.va => no v.(q.lookup)
               all v : Value | all a : v.(q.va) | a.(q.av) != WildCard && not a.(q.va) in a.va 
                                                            => no v.(q.lookup)
               all v : Value - WildCard | no v.(q.va) => v.(q.lookup) = v.*(va.av).rec
               all v : Value | some v.(q.va) => indSubset(this,q,v.(q.lookup),v) &&
                                                                no r : Record - v.(q.lookup) | indSubset(this,q,v.(q.lookup) + r, v)
               result = root.(q.lookup) }}

assert CorrectLookup {
        all db : DB | all q : Query | all r : Record | 
                           Conforms (db,q,r) <=> r in db..Lookup(q)}

fun DB::Add(adv:Query, r:Record):DB {
        // restricted version - only advertisements with fresh attributes and values added
        no this.attributes & adv.attributes
        this.values & adv.values = this.root
        this.root = adv.root     // not much point in having different roots
        Wildcard !in adv.values
        r !in this.records
        with result {
                values = this.values + adv.values
                attributes = this.attributes + adv.attributes
                root = this.root
                av = this.av + adv.av
                va = this.va + adv.va
                // again, removing 'dom' from before va for parsing
                recs = this.recs + (values - va) -> r}}
                // lookup needs not be constrained!!
// can't have receiver or arguments for assertions
/*assert DB::MonotonicAdd(q,adv:Query, r:Record){
         this::Lookup(q) in this::Add(adv,r)::Lookup(q)}*/

fun Query::RemoveWildCard():Query{
        with result {
               values = this.values - Wildcard
               attributes = this.attributes - Wildcard.~(this.av)
               root = this.root
               av = this.av - Attribute -> Wildcard
               va = this.va - Value -> Wildcard.~(this.av)}}
assert MissingAttributeAsWildcard{
        all db : DB | all q : Query | db..Lookup(q) = db..Lookup(q..RemoveWildCard())}
