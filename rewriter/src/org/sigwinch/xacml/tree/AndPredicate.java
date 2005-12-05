package org.sigwinch.xacml.tree;

/**
 * AndPredicate.java
 *
 *
 * Created: Wed Oct 22 00:49:22 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class AndPredicate extends Predicate {
    Predicate left, right;
    public AndPredicate(Predicate l, Predicate r) {
	left = l; right = r;
    }

    /**
     * Gets the value of left
     *
     * @return the value of left
     */
    public Predicate getLeft()  {
	return this.left;
    }

    /**
     * Sets the value of left
     *
     * @param argLeft Value to assign to this.left
     */
    public void setLeft(Predicate argLeft) {
	this.left = argLeft;
    }

    /**
     * Gets the value of right
     *
     * @return the value of right
     */
    public Predicate getRight()  {
	return this.right;
    }

    /**
     * Sets the value of right
     *
     * @param argRight Value to assign to this.right
     */
    public void setRight(Predicate argRight) {
	this.right = argRight;
    }

    public void walk (Visitor v)
    {
	v.walkAndPredicate (this);
    }

    public Predicate transform (Transformer t)
    {
	return t.walkAndPredicate (this);
    }

    public boolean equals (Object o)
    {
	if (! (o instanceof AndPredicate)) return false;
	AndPredicate a = (AndPredicate) o;
	return left.equals (a.getLeft ()) && right.equals (a.getRight ());
    }

    public int hashCode ()
    {
	return left.hashCode () ^ right.hashCode () ^ '&';
    }
}
/* arch-tag: 4212B478-0464-11D8-820E-000A95A2610A
 */
