package org.sigwinch.xacml.transformers;

import org.sigwinch.xacml.tree.DenyOverridesRule;
import org.sigwinch.xacml.tree.Error;
import org.sigwinch.xacml.tree.FirstApplicableRule;
import org.sigwinch.xacml.tree.OnlyOneRule;
import org.sigwinch.xacml.tree.PermitOverridesRule;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.Scope;
import org.sigwinch.xacml.tree.TransformerImpl;
import org.sigwinch.xacml.tree.Tree;

/**
 * Propagator.java
 * 
 * 
 * Created: Fri Nov 7 20:56:30 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class Propagator extends TransformerImpl {
    public Propagator() {

    }

    /**
     * Propogate Scope nodes down the tree.
     * 
     * @param s
     *            a <code>Scope</code> node
     * @return transformed tree
     */
    @Override
    public Tree walkScope(Scope s) {
        Scope scope = (Scope) super.walkScope(s);
        if (scope.getChild() instanceof Error) {
            Error error = (Error) scope.getChild();
            Predicate p = error.getCondition().andWith(scope.getCondition());
            return new Error(new Scope(error.getChild(), scope.getCondition())
                    .transform(this), p);
        } else if (scope.getChild() instanceof PermitOverridesRule) {
            PermitOverridesRule p = (PermitOverridesRule) scope.getChild();
            return new PermitOverridesRule(new Scope(p.getLeft(), scope
                    .getCondition()).transform(this), new Scope(p.getRight(),
                    scope.getCondition()).transform(this));
        } else if (scope.getChild() instanceof DenyOverridesRule) {
            DenyOverridesRule p = (DenyOverridesRule) scope.getChild();
            Tree t = new DenyOverridesRule(new Scope(p.getLeft(), scope
                    .getCondition()).transform(this), new Scope(p.getRight(),
                    scope.getCondition()).transform(this));
            return t;
        } else if (scope.getChild() instanceof FirstApplicableRule) {
            FirstApplicableRule p = (FirstApplicableRule) scope.getChild();
            return new FirstApplicableRule(new Scope(p.getLeft(), scope
                    .getCondition()).transform(this), new Scope(p.getRight(),
                    scope.getCondition()).transform(this));
        } else if (scope.getChild() instanceof OnlyOneRule) {
            OnlyOneRule p = (OnlyOneRule) scope.getChild();
            return new OnlyOneRule(new Scope(p.getLeft(), scope.getCondition())
                    .transform(this), new Scope(p.getRight(), scope
                    .getCondition()).transform(this));
        } else {
            return scope;
        }
    }

    /**
     * Propogate Error nodes down the tree.
     * 
     * @param e
     *            a <code>Error</code> node
     * @return transformed tree
     */
    @Override
    public Tree walkError(Error e) {
        Error error = (Error) super.walkError(e);
        if (error.getChild() instanceof PermitOverridesRule) {
            PermitOverridesRule p = (PermitOverridesRule) error.getChild();
            return new PermitOverridesRule(new Error(p.getLeft(), error
                    .getCondition()).transform(this), new Error(p.getRight(),
                    error.getCondition()).transform(this));
        } else if (error.getChild() instanceof DenyOverridesRule) {
            DenyOverridesRule p = (DenyOverridesRule) error.getChild();
            return new DenyOverridesRule(new Error(p.getLeft(), error
                    .getCondition()).transform(this), new Error(p.getRight(),
                    error.getCondition()).transform(this));
        } else if (error.getChild() instanceof FirstApplicableRule) {
            FirstApplicableRule p = (FirstApplicableRule) error.getChild();
            return new FirstApplicableRule(new Error(p.getLeft(), error
                    .getCondition()).transform(this), new Error(p.getRight(),
                    error.getCondition()).transform(this));
        } else if (error.getChild() instanceof OnlyOneRule) {
            OnlyOneRule p = (OnlyOneRule) error.getChild();
            return new OnlyOneRule(new Error(p.getLeft(), error.getCondition())
                    .transform(this), new Error(p.getRight(), error
                    .getCondition()).transform(this));
        } else
            return error;
    }

}
/*
 * arch-tag: ED338E2C-11A7-11D8-AED1-000A95A2610A
 */
