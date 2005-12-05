package org.sigwinch.xacml.tree;

/**
 * FirstApplicableRule.java
 *
 *
 * Created: Tue Oct 21 20:06:05 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class FirstApplicableRule extends Tree {
    Tree left, right;
    public FirstApplicableRule(Tree l, Tree r) {
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

    @Override
    public void walk (Visitor v)
    {
	v.walkFirstApplicableRule (this);
    }
    @Override
    public Tree transform (Transformer t)
    {
	return t.walkFirstApplicableRule (this);
    }

    @Override
    public boolean equals (Object o)
    {
	if (! (o instanceof FirstApplicableRule)) return false;
	FirstApplicableRule f = (FirstApplicableRule) o;
	return left.equals (f.getLeft ()) && right.equals (f.getRight ());
    }

    @Override
    public int hashCode ()
    {
	return left.hashCode () ^ right.hashCode () ^ "odivide".hashCode ();
    }
}
/* arch-tag: ADD4A907-043C-11D8-A688-000A95A2610A
 */
