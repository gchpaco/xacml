/*
 * Created on May 30, 2005
 */
package org.sigwinch.xacml.output.sat;

/**
 * @author graham
 */
public class Equivalence implements BooleanFormula {
    BooleanFormula left, right;

    /**
     * @param left
     * @param right
     */
    public Equivalence(BooleanFormula left, BooleanFormula right) {
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
        return "(<=> " + left + " " + right + ")";
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object obj) {
        if (obj instanceof Equivalence) {
            Equivalence obj2 = (Equivalence) obj;
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
        return '=' ^ left.hashCode() ^ right.hashCode();
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
        impl.visitEquivalence(this);
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#convertToCNF()
     */
    public BooleanFormula convertToCNF() {
        return new Or(new And(left, right), new And(left.negate(), right
                .negate())).convertToCNF();
    }

    public BooleanFormula simplify() {
        BooleanFormula l = left.simplify();
        BooleanFormula r = right.simplify();
        if (l == PrimitiveBoolean.TRUE)
            return r;
        else if (r == PrimitiveBoolean.TRUE)
            return l;
        else if (l == PrimitiveBoolean.FALSE)
            return r.negate().simplify();
        else if (r == PrimitiveBoolean.FALSE)
            return l.negate().simplify();
        else
            return new Equivalence(l, r);
    }

    public boolean isInCNF() {
        return false;
    }

}

// arch-tag: Equivalence.java May 30, 2005 2:39:51 AM
