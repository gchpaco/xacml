/*
 * Created on Apr 25, 2005
 */
package org.sigwinch.xacml.output.sat;

import org.sigwinch.xacml.tree.VariableReference;

/**
 * @author graham
 */
public class Not implements BooleanFormula {
    BooleanFormula formula;

    /**
     * @param reference
     */
    public Not(BooleanFormula reference) {
        formula = reference;
    }

    @Override
    public String toString() {
        return "(not " + formula.toString() + ")";
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object obj) {
        if (obj instanceof Not) {
            Not obj2 = (Not) obj;
            return formula.equals(obj2.formula);
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
        return '!' ^ formula.hashCode();
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#negate()
     */
    public BooleanFormula negate() {
        return formula;
    }

    public BooleanFormula simplify() {
        if (formula instanceof Not) {
            Not not = (Not) formula;
            return not.formula.simplify();
        } else if (formula == BooleanFormula.TRUE) {
            return BooleanFormula.FALSE;
        } else if (formula == BooleanFormula.FALSE) {
            return BooleanFormula.TRUE;
        } else {
            return new Not(formula.simplify());
        }
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#convertToCNF()
     */
    public BooleanFormula convertToCNF() {
        if (formula instanceof Not) {
            Not not = (Not) formula;
            return not.formula.convertToCNF();
        } else if (formula instanceof And) {
            And and = (And) formula;
            BooleanFormula[] results = and.objects.clone();
            for (int i = 0; i < results.length; i++) {
                results[i] = results[i].negate();
            }
            return new Or(results).convertToCNF();
        } else if (formula instanceof Or) {
            Or or = (Or) formula;
            BooleanFormula[] results = or.objects.clone();
            for (int i = 0; i < results.length; i++) {
                results[i] = results[i].negate();
            }
            return new And(results).convertToCNF();
        } else if (formula instanceof Equivalence) {
            return formula.convertToCNF().negate().convertToCNF();
        } else if (formula instanceof Implication) {
            return formula.convertToCNF().negate().convertToCNF();
        } else
            return this;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#visit(org.sigwinch.xacml.output.sat.FormulaVisitor)
     */
    public void visit(FormulaVisitor impl) {
        impl.visitNot(this);
    }

    public boolean isInCNF() {
        return formula instanceof VariableReference;
    }

}

// arch-tag: Not.java Apr 25, 2005 5:09:57 PM
