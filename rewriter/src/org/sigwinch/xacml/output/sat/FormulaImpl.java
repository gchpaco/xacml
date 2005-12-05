/*
 * Created on May 28, 2005
 */
package org.sigwinch.xacml.output.sat;

import org.sigwinch.xacml.output.sat.BooleanFormula.False;
import org.sigwinch.xacml.output.sat.BooleanFormula.True;
import org.sigwinch.xacml.tree.VariableReference;

public abstract class FormulaImpl implements FormulaVisitor {

    public void visitAnd(And and) {
        for (int i = 0; i < and.objects.length; i++) {
            and.objects[i].visit(this);
        }
    }

    public void visitFalse(False f) {
    }

    public void visitNot(Not not) {
        not.formula.visit(this);
    }

    public void visitOr(Or or) {
        for (int i = 0; i < or.objects.length; i++) {
            or.objects[i].visit(this);
        }
    }

    public void visitTrue(True t) {
    }

    public void visitVariable(VariableReference ref) {
    }

    public void visitEquivalence(Equivalence equivalence) {
        equivalence.left.visit(this);
        equivalence.right.visit(this);
    }

    public void visitImplication(Implication implication) {
        implication.left.visit(this);
        implication.right.visit(this);
    }
}

// arch-tag: FormulaImpl.java May 28, 2005 12:48:48 AM
