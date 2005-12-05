package org.sigwinch.xacml.transformers;

import org.sigwinch.xacml.tree.TransformerImpl;
import org.sigwinch.xacml.tree.Tree;
import org.sigwinch.xacml.tree.Error;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.Scope;

/**
 * DuplicateRemover.java Created: Fri Nov 7 16:58:30 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes </a>
 * @version 1.0
 */
public class DuplicateRemover extends TransformerImpl {
    public DuplicateRemover () {

    }

    /**
     * Check if the child is also an Error node, and if so unify them.
     * 
     * @param error
     *            an <code>Error</code> node in a tree
     * @return transformed tree
     */
    @Override
    public Tree walkError (Error error) {
        if (error.getChild () instanceof Error) {
            Error child = (Error) error.getChild ();
            // This order is important so in the case of multiply
            // nested Error nodes, the OrPredicates will accumulate to
            // the right.
            Predicate p = child.getCondition ().orWith (error.getCondition ());
            Error newerr = new Error (child.getChild (), p);
            return newerr.transform (this);
        }
        return super.walkError (error);
    }

    /**
     * Check if the child is also an Scope node, and if so unify them.
     * 
     * @param scope
     *            an <code>Scope</code> node in a tree
     * @return transformed tree
     */
    @Override
    public Tree walkScope (Scope scope) {
        if (scope.getChild () instanceof Scope) {
            Scope child = (Scope) scope.getChild ();
            // This order is important so in the case of multiply
            // nested Scope nodes, the AndPredicates will accumulate
            // to the right.
            Predicate p = child.getCondition ().andWith (scope.getCondition ());
            Scope newscope = new Scope (child.getChild (), p);
            return newscope.transform (this);
        }
        return super.walkScope (scope);
    }
}
/*
 * arch-tag: B14247CC-1186-11D8-B932-000A95A2610A
 */
