package org.sigwinch.xacml.tree;

/**
 * A scope restriction on a policy tree.  In the notation, this is
 * denoted Scope (<i>T</i>, <i>P</i>), where <i>T</i> is a tree and
 * <i>P</i> is a predicate on the environment.
 *
 * <p>
 * Created: Tue Oct 21 21:15:35 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class Scope extends Tree {
    Tree child;
    Predicate condition;
    public Scope (Tree subnode, Predicate p) {
	child = subnode;
	condition = p;
    }

    /**
     * Gets the value of child
     *
     * @return the value of child
     */
    public Tree getChild()  {
	return this.child;
    }

    /**
     * Sets the value of child
     *
     * @param argChild Value to assign to this.child
     */
    public void setChild(Tree argChild) {
	this.child = argChild;
    }

    /**
     * Gets the value of condition
     *
     * @return the value of condition
     */
    public Predicate getCondition()  {
	return this.condition;
    }

    /**
     * Sets the value of condition
     *
     * @param argCondition Value to assign to this.condition
     */
    public void setCondition(Predicate argCondition) {
	this.condition = argCondition;
    }

    public boolean isFunction () { return true; }

    public void walk (Visitor v)
    {
	v.walkScope (this);
    }
    public Tree transform (Transformer t)
    {
	return t.walkScope (this);
    }

    public boolean equals (Object o)
    {
	if (! (o instanceof Scope)) return false;
	Scope s = (Scope) o;
	return child.equals (s.getChild ()) && 
	    condition.equals (s.getCondition ());
    }
    
    public int hashCode ()
    {
	return child.hashCode () ^ condition.hashCode () ^ 'S';
    }
}
/* arch-tag: 64C7F4DE-0446-11D8-B96B-000A95A2610A
 */
