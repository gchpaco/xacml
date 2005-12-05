package org.sigwinch.xacml.tree;

/**
 * OnlyOneRule.java
 *
 *
 * Created: Tue Oct 21 20:06:27 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class OnlyOneRule extends Tree {
    Tree left, right;
    public OnlyOneRule(Tree l, Tree r) {
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
	v.walkOnlyOneRule (this);
    }
    public Tree transform (Transformer t)
    {
	return t.walkOnlyOneRule (this);
    }

    public boolean equals (Object o)
    {
	if (! (o instanceof OnlyOneRule)) return false;
	OnlyOneRule r = (OnlyOneRule) o;
	return left.equals (r.getLeft ()) && right.equals (r.getRight ());
    }

    public int hashCode ()
    {
	return left.hashCode () ^ right.hashCode () ^ "otimes".hashCode ();
    }
}
/* arch-tag: BB085CA5-043C-11D8-964A-000A95A2610A
 */
