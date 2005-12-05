package org.sigwinch.xacml.transformers;

import org.sigwinch.xacml.tree.Deny;
import org.sigwinch.xacml.tree.Error;
import org.sigwinch.xacml.tree.Permit;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.Scope;
import org.sigwinch.xacml.tree.SimplePredicate;
import org.sigwinch.xacml.tree.TransformerImpl;
import org.sigwinch.xacml.tree.Tree;
import org.sigwinch.xacml.tree.Triple;



/**
 * TripleFormer.java
 *
 *
 * Created: Sat Nov  8 02:16:05 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class TripleFormer extends TransformerImpl {
    public TripleFormer() {
	
    }

    /**
     * Turn Permits into triples.
     *
     * @param permit a <code>Permit</code> node
     * @return corresponding triple
     */
    @Override
    public Tree walkPermit(Permit permit) {
	return new Triple (SimplePredicate.TRUE, SimplePredicate.FALSE,
			   SimplePredicate.FALSE);
    }

    /**
     * Turn Denies into triples.
     *
     * @param deny a <code>Deny</code> node
     * @return corresponding triple
     */
    @Override
    public Tree walkDeny(Deny deny) {
	return new Triple (SimplePredicate.FALSE, SimplePredicate.TRUE,
			   SimplePredicate.FALSE);
    }
    
    
    /**
     * Turn Scope into a triple.
     *
     * @param scope a <code>Scope</code> node
     * @return corresponding triple
     */
    @Override
    public Tree walkScope(Scope scope) {
	// okay, so errors should be above scopes, and duplicate
	// scopes are folded together, and so scopes should be
	// absolutely at the bottom of the tree.
	if (! (scope.getChild () == Permit.PERMIT ||
	       scope.getChild () == Deny.DENY))
	    System.err.println (scope);
	assert scope.getChild () == Permit.PERMIT ||
	    scope.getChild () == Deny.DENY;
	Tree probablytriple = scope.getChild ().transform (this);
	if (! (probablytriple instanceof Triple))
	    System.err.println (probablytriple);
	Triple triple = (Triple) probablytriple;
	// unnecessary but what the hell
	Predicate predicate = scope.getCondition ().transform (this);
	return new Triple (triple.getPermit ().andWith (predicate),
			   triple.getDeny ().andWith (predicate),
			   triple.getError ().andWith (predicate));
    }

    /**
     * Turn Error nodes into triples.
     *
     * @param error an <code>Error</code> node
     * @return corresponding triple
     */
    @Override
    public Tree walkError(Error error) {
	// This should absolutely never fail, because we've previously
	// moved errors down to the bottom of the tree, only just
	// above Scopes and Permit/Deny all of which get turned into
	// Triples here.
	Triple triple = (Triple) error.getChild ().transform (this);
	// unnecessary but what the hell
	Predicate predicate = error.getCondition ().transform (this);
	Predicate not = predicate.not ();
	return new Triple (triple.getPermit ().andWith (not),
			   triple.getDeny ().andWith (not),
			   triple.getError ().orWith (predicate));
    }
    
}
/* arch-tag: 921A3708-11D4-11D8-8057-000A95A2610A
 */
