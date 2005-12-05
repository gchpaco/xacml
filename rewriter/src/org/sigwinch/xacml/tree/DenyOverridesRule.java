package org.sigwinch.xacml.tree;

/**
 * DenyOverridesRule.java
 *
 *
 * Created: Tue Oct 21 20:05:38 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class DenyOverridesRule extends Tree {
    Tree left, right;
    public DenyOverridesRule(Tree l, Tree r) {
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
	v.walkDenyOverridesRule (this);
    }
    public Tree transform (Transformer t)
    {
	return t.walkDenyOverridesRule (this);
    }

    public boolean equals (Object o)
    {
	if (! (o instanceof DenyOverridesRule)) return false;
	DenyOverridesRule d = (DenyOverridesRule) o;
	return left.equals (d.getLeft ()) && right.equals (d.getRight ());
    }

    public int hashCode ()
    {
	return left.hashCode () ^ right.hashCode () ^ "ominus".hashCode ();
    }
}
/* arch-tag: 9E9FC940-043C-11D8-A334-000A95A2610A
 */
