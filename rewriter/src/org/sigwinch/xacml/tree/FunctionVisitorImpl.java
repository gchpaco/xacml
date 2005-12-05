package org.sigwinch.xacml.tree;




/**
 * Default implementation of FunctionVisitor that just walks subnodes.
 *
 *
 * Created: Mon Nov 17 18:01:16 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class FunctionVisitorImpl extends FunctionVisitor {
    protected Visitor visitor;
    public FunctionVisitorImpl(Visitor visitor) {
	this.visitor = visitor;
    }
    
    // Implementation of org.sigwinch.xacml.tree.FunctionVisitor

    /**
     * Walk the subnodes of this function.
     *
     * @param predicate a <code>Predicate</code> value
     */
    public void visitSize(Predicate predicate) {
	predicate.walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicate a <code>Predicate</code> value
     * @param predicate1 a <code>Predicate</code> value
     */
    public void visitInclusion(Predicate predicate, Predicate predicate1) {
	predicate.walk (visitor);
	predicate1.walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicate a <code>Predicate</code> value
     */
    public void visitSetCreation(Predicate predicate) {
	predicate.walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicate a <code>Predicate</code> value
     * @param predicate1 a <code>Predicate</code> value
     */
    public void visitEquality(Predicate predicate, Predicate predicate1) {
	predicate.walk (visitor);
	predicate1.walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicate a <code>Predicate</code> value
     * @param predicate1 a <code>Predicate</code> value
     */
    public void visitIntersection(Predicate predicate, Predicate predicate1) {
	predicate.walk (visitor);
	predicate1.walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicate a <code>Predicate</code> value
     * @param predicate1 a <code>Predicate</code> value
     */
    public void visitUnion(Predicate predicate, Predicate predicate1) {
	predicate.walk (visitor);
	predicate1.walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicate a <code>Predicate</code> value
     * @param predicate1 a <code>Predicate</code> value
     */
    public void visitSubset(Predicate predicate, Predicate predicate1) {
	predicate.walk (visitor);
	predicate1.walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicate a <code>Predicate</code> value
     * @param predicate1 a <code>Predicate</code> value
     */
    public void visitAtLeastOne(Predicate predicate, Predicate predicate1) {
	predicate.walk (visitor);
	predicate1.walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicate a <code>Predicate</code> value
     * @param predicate1 a <code>Predicate</code> value
     */
    public void visitSetEquality(Predicate predicate, Predicate predicate1) {
	predicate.walk (visitor);
	predicate1.walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicate a <code>Predicate</code> value
     * @param predicate1 a <code>Predicate</code> value
     */
    public void visitGreaterThan(Predicate predicate, Predicate predicate1) {
	predicate.walk (visitor);
	predicate1.walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicate a <code>Predicate</code> value
     * @param predicate1 a <code>Predicate</code> value
     */
    public void visitGreaterThanOrEqual(Predicate predicate, Predicate predicate1) {
	predicate.walk (visitor);
	predicate1.walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicate a <code>Predicate</code> value
     * @param predicate1 a <code>Predicate</code> value
     */
    public void visitLessThan(Predicate predicate, Predicate predicate1) {
	predicate.walk (visitor);
	predicate1.walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicate a <code>Predicate</code> value
     * @param predicate1 a <code>Predicate</code> value
     */
    public void visitLessThanOrEqual(Predicate predicate, Predicate predicate1) {
	predicate.walk (visitor);
	predicate1.walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicateArray a <code>Predicate[]</code> value
     */
    public void visitAnd(Predicate[] predicateArray) {
	for (int i = 0; i < predicateArray.length; i++)
	    predicateArray[i].walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicateArray a <code>Predicate[]</code> value
     */
    public void visitOr(Predicate[] predicateArray) {
	for (int i = 0; i < predicateArray.length; i++)
	    predicateArray[i].walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param predicate a <code>Predicate</code> value
     */
    public void visitNot(Predicate predicate) {
	predicate.walk (visitor);
    }

    /**
     * Walk the subnodes of this function.
     *
     * @param string function name
     * @param predicateArray a <code>Predicate[]</code> value
     */
    public void visitDefault(String string, Predicate[] predicateArray) {
	for (int i = 0; i < predicateArray.length; i++)
	    predicateArray[i].walk (visitor);
    }
    
}
/* arch-tag: 1B6CFD76-196B-11D8-BF3E-000A95A2610A
 */
