/*
Basic notions

Two object references, called the view and the backing, are related by a view mechanism when changes to the backing
are automatically propagated to the view. Note that the state of a view need not be a projection of the state of the backing;
the keySet method of Map, for example, produces two view relationships, and for the one in which the map is modified by
changes to the key set, the value of the new map cannot be determined from the key set. Note that in the iterator view
mechanism, the iterator is by this definition the backing object, since changes are propagated from iterator to collection
and not vice versa. Oddly, a reference may be a view of more than one backing: there can be two iterators on the same
collection, eg. A reference cannot be a view under more than one view type.

A reference is made dirty when it is a backing for a view with which it is no longer
related by the view invariant. This usually happens when a view is modified, either
directly or via another backing. For example, changing a collection directly when it has an
iterator invalidates it, as does changing the collection through one iterator when there are others.

More work is needed if we want to model more closely the failure of an iterator when its collection is invalidated.

As a terminological convention, when there are two complementary view relationships, we will give them types t and t'. For 
example, KeySetView propagates from map to set, and KeySetView' propagates from set to map.

Errors eliminated using tool
-- must start in state in which view invariants hold
-- cannot have KeySetView' but not KeySetView
-- result in i.left missing from next function
*/

module views
open std/ord
sig Ref {}
sig Object {}

-- t->b->v in views when v is view of type t of backing b
-- dirty contains refs that have been invalidated
sig State {
	refs: set Ref,
	obj: refs ->! Object,
	views: ViewType -> refs -> refs,
	dirty: set refs
--	, anyviews: Ref -> Ref -- for visualization
	}
-- {anyviews = ViewType.views}

disj sig Map extends Object {
	keys: set Ref,
	map: keys ->! Ref
	}{all s: State |	keys + Ref.map in s.refs}
disj sig MapRef extends Ref {}
fact {MapRef.State::obj in Map}

disj sig Iterator extends Object {
	left, done: set Ref,
	last: option done
	}{all s: State | done + left + last in s.refs}
disj sig IteratorRef extends Ref {}
fact {IteratorRef.State::obj in Iterator}

disj sig Set extends Object {
	elts: set Ref
	}{all s: State | elts in s.refs}
disj sig SetRef extends Ref {}
fact {SetRef.State::obj in Set}

sig ViewType {}
static part sig KeySetView, KeySetView', IteratorView extends ViewType {}
fact ViewTypes {
	KeySetView.State::views in MapRef -> SetRef
	KeySetView'.State::views in SetRef -> MapRef
	IteratorView.State::views in IteratorRef -> SetRef
	all s: State | KeySetView.s::views = ~(KeySetView'.s::views)
	}

-- mods is refs modified directly or by view mechanism
-- doesn't handle possibility of modifying an object and its view at once?
-- should we limit frame conds to non-dirty refs?
fun modifies (pre, post: State, rs: set Ref) {
	let vr = ViewType.pre::views, mods = rs.*vr {
		all r: pre.refs - mods | r.pre::obj = r.post::obj
		all b: mods, v: pre.refs, t: ViewType |
			b->v in t.pre::views => viewFrame (t, v.pre::obj, v.post::obj, b.post::obj)
		post.dirty = pre.dirty +
			{b: pre.refs | some v: Ref, t: ViewType |
					b->v in t.pre::views && !viewFrame (t, v.pre::obj, v.post::obj, b.post::obj)
			}
		}
	}

fun allocates (pre, post: State, rs: set Ref) {
	no rs & pre.refs
	post.refs = pre.refs + rs
	}

-- models frame condition that limits change to view object from v to v' when backing object changes to b'
fun viewFrame (t: ViewType, v, v', b': Object) {
	t in KeySetView => v'.elts = dom (b'.map)
	t in KeySetView' => b'.elts = dom (v'.map)
	t in KeySetView' => domRestrict (b'.elts, v.map) = domRestrict (b'.elts, v'.map)
	t in IteratorView => v'.elts = b'.left + b'.done
	}

fun domRestrict [S,T] (s: set S, r: S -> T): S -> T {
	result = r & (s->T)
	}
fun dom [S,T] (r: S -> T): set S {
	result = r.T
	}

fun MapRef::keySet (pre, post: State): SetRef {
	result.post::obj.elts = dom (this.pre::obj.map)
	modifies (pre, post, none[Ref])
	allocates (pre, post, result)
	post.views = pre.views + KeySetView->this->result + KeySetView'->result->this
	}

fun MapRef::put (pre, post: State, k, v: Ref) {
	this.post::obj.map = this.pre::obj.map ++ k->v
	modifies (pre, post, this)
	allocates (pre, post, none[Ref])
	post.views = pre.views
	}

fun SetRef::iterator (pre, post: State): IteratorRef {
	let i = result.post::obj {
		i.left = this.pre::obj.elts
		no i.done + i.last
		}
	modifies (pre,post,none[Ref])
	allocates (pre, post, result)
	post.views = pre.views + IteratorView->result->this
	}

fun IteratorRef::remove (pre, post: State) {
	let	i = this.pre::obj, i' = this.post::obj {
		i'.left = i.left
		i'.done = i.done - i.last
		no i'.last
		}
	modifies (pre,post,this)
	allocates (pre, post, none[Ref])
	pre.views = post.views
	}

fun IteratorRef::next (pre, post: State): Ref {
	let	i = this.pre::obj, i' = this.post::obj {
		result in i.left
		i'.left = i.left - result
		i'.done = i.done + result
		i'.last = result
		}
	modifies (pre, post, this)
	allocates (pre, post, none[Ref])
	pre.views = post.views
	}

fun IteratorRef::hasNext (s: State) {
	some this.s::obj.left
	}

assert zippishOK {
	all
		ks, vs: SetRef,
		m: MapRef,
		ki, vi, k, v: Ref,
		s0: Ord[State].first,
		s1: OrdNext(s0),
		s2: OrdNext(s1),
		s3: OrdNext(s2),
		s4: OrdNext(s3),
		s5: OrdNext(s4),
		s6: OrdNext(s5),
		s7: OrdNext(s6) |
	{
		precondition (s0, ks, vs, m)
		no s0.dirty
		ks..iterator (ki, s0, s1)
		vs..iterator (vi, s1, s2)
		ki..hasNext (s2)
		vi..hasNext (s2)
		ki..next (k, s2, s3)  
		vi..next (v, s3, s4)
		m..put (s4, s5, k, v)
		ki..remove (s5, s6)
		vi..remove (s6, s7)
	}
	=> no State.dirty
	}

fun precondition (pre: State, ks, vs, m: Ref) {
-- all these conditions and other errors discovered in scope of 6 but 8,3
	-- in initial state, must have view invariants hold
	(all t: ViewType, b, v: pre.refs |
		b->v in t.pre::views => viewFrame (t, v.pre::obj, v.pre::obj, b.pre::obj))
	-- sets are not aliases
--	ks != vs
	-- sets are not views of map
--	no (ks+vs)->m & ViewType.pre::views
	-- no iterator currently on either set
--	no Ref->(ks+vs) & ViewType.pre::views
	}

check zippishOK for 6 but 8 State, 3 ViewType

-- experiment with controlling heap size
fact {all s: State | #s.obj < 5}
