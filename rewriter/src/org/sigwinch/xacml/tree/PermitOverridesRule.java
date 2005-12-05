package org.sigwinch.xacml.tree;

/**
 * PermitOverridesRule.java
 *
 *
 * Created: Tue Oct 21 20:06:47 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class PermitOverridesRule extends Tree {
    Tree left, right;
    public PermitOverridesRule(Tree l, Tree r) {
	left = l; right = r;
    }

    /**
     * Gets the value of left
     *
     * @return the value of left
     */
    public Tree getLeft()  {
	return this.left;
    }

    /**
     * Sets the value of left
     *
     * @param argLeft Value to assign to this.left
     */
    public void setLeft(Tree argLeft) {
	this.left = argLeft;
    }

    /**
     * Gets the value of right
     *
     * @return the value of right
     */
    public Tree getRight()  {
	return this.right;
    }

    /**
     * Sets the value of right
     *
     * @param argRight Value to assign to this.right
     */
    public void setRight(Tree argRight) {
	this.right = argRight;
    }
 
    public void walk (Visitor v)
    {
	v.walkPermitOverridesRule (this);
    }
    public Tree transform (Transformer t)
    {
	return t.walkPermitOverridesRule (this);
    }

    public boolean equals (Object o)
    {
	if (! (o instanceof PermitOverridesRule)) return false;
	PermitOverridesRule p = (PermitOverridesRule) o;
	return left.equals (p.getLeft ()) && right.equals (p.getRight ());
    }

    public int hashCode ()
    {
	return left.hashCode () ^ right.hashCode () ^ "oplus".hashCode ();
    }
}
/* arch-tag: C7C59D17-043C-11D8-96BE-000A95A2610A
 */
