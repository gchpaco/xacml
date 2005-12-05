/*
 * Created on May 31, 2005
 */
package org.sigwinch.xacml.output.sat;

/**
 * @author graham
 */
public class Implication implements BooleanFormula {
    BooleanFormula left, right;

    /**
     * @param left
     * @param right
     */
    public Implication(BooleanFormula left, BooleanFormula right) {
        super();
        this.left = left;
        this.right = right;
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        return "(=> " + left + " " + right + ")";
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object obj) {
        if (obj instanceof Implication) {
            Implication obj2 = (Implication) obj;
            return obj2.left.equals(left) && obj2.right.equals(right);
        }
        return super.equals(obj);
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        return '>' ^ left.hashCode() ^ right.hashCode();
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#negate()
     */
    public BooleanFormula negate() {
        return new Not(this);
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#visit(org.sigwinch.xacml.output.sat.FormulaVisitor)
     */
    public void visit(FormulaVisitor impl) {
        impl.visitImplication(this);
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#simplify()
     */
    public BooleanFormula simplify() {
        BooleanFormula l = left.simplify();
        BooleanFormula r = right.simplify();
        if (l == PrimitiveBoolean.TRUE)
            return r;
        else if (r == PrimitiveBoolean.TRUE)
            return PrimitiveBoolean.TRUE;
        else if (l == PrimitiveBoolean.FALSE)
            return PrimitiveBoolean.TRUE;
        else if (r == PrimitiveBoolean.FALSE)
            return l.negate().simplify();
        else
            return new Implication(l, r);
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#convertToCNF()
     */
    public BooleanFormula convertToCNF() {
        return new Or(left.negate(), right).convertToCNF();
    }

    public boolean isInCNF() {
        return false;
    }

}

// arch-tag: Implication.java May 31, 2005 9:27:12 PM
