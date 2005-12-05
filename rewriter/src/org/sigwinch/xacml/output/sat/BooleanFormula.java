/*
 * Created on Apr 25, 2005
 */
package org.sigwinch.xacml.output.sat;

/**
 * @author graham
 */
public interface BooleanFormula {
    public BooleanFormula negate();

    public void visit(FormulaVisitor impl);

    public BooleanFormula simplify();

    public BooleanFormula convertToCNF();

    public boolean isInCNF();
}

// arch-tag: BooleanFormula.java Apr 25, 2005 2:13:50 PM
