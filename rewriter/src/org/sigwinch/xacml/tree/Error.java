package org.sigwinch.xacml.tree;

/**
 * An error condition on a policy tree. In the notation, this is denoted Error (<i>T</i>,
 * <i>P</i>), where <i>T</i> is a tree and <i>P</i> is a predicate on the
 * environment.
 * 
 * <p>
 * Created: Tue Oct 21 21:15:35 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class Error extends Tree {
    Tree child;

    Predicate condition;

    public Error(Tree subnode, Predicate p) {
        child = subnode;
        condition = p;
    }

    /**
     * Gets the value of child
     * 
     * @return the value of child
     */
    public Tree getChild() {
        return this.child;
    }

    /**
     * Sets the value of child
     * 
     * @param argChild
     *            Value to assign to this.child
     */
    public void setChild(Tree argChild) {
        this.child = argChild;
    }

    /**
     * Gets the value of condition
     * 
     * @return the value of condition
     */
    public Predicate getCondition() {
        return this.condition;
    }

    /**
     * Sets the value of condition
     * 
     * @param argCondition
     *            Value to assign to this.condition
     */
    public void setCondition(Predicate argCondition) {
        this.condition = argCondition;
    }

    @Override
    public boolean isFunction() {
        return true;
    }

    @Override
    public void walk(Visitor v) {
        v.walkError(this);
    }

    @Override
    public Tree transform(Transformer t) {
        return t.walkError(this);
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof Error))
            return false;
        Error e = (Error) o;
        return child.equals(e.getChild()) && condition.equals(e.getCondition());
    }

    @Override
    public int hashCode() {
        return child.hashCode() ^ condition.hashCode() ^ 'E';
    }
}
/*
 * arch-tag: A921CCDE-0F49-11D8-84F3-000A95A2610A
 */
