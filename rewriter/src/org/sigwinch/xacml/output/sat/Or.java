/*
 * Created on Apr 25, 2005
 */
package org.sigwinch.xacml.output.sat;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.TreeSet;

import org.sigwinch.xacml.tree.VariableReference;

/**
 * @author graham
 */
public class Or implements BooleanFormula {
    BooleanFormula[] objects;
    
    /**
     * @param formulas
     */
    public <X extends BooleanFormula> Or(X... formulas) {
        objects = new BooleanFormula[formulas.length];
        for (int i = 0; i < formulas.length; i++) {
            assert formulas[i] != null : i + "th argument is null";
            objects[i] = formulas[i];
        }
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        StringBuffer buf = new StringBuffer();
        buf.append("(or");
        for (int i = 0; i < objects.length; i++) {
            buf.append(" ");
            if (objects[i] == null)
                buf.append("nil");
            else
                buf.append(objects[i].toString());
        }
        buf.append(")");
        return buf.toString();
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object obj) {
        if (obj instanceof Or) {
            Or obj2 = (Or) obj;
            if (obj2.objects.length != objects.length)
                return false;
            for (int i = 0; i < objects.length; i++)
                if (!objects[i].equals(obj2.objects[i]))
                    return false;
            return true;
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
        int hash = '^';
        for (int i = 0; i < objects.length; i++)
            hash ^= objects[i].hashCode();
        return hash;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#negate()
     */
    public BooleanFormula negate() {
        return new Not(this);
    }

    public BooleanFormula simplify() {
        // some trivial stuff first
        if (objects.length == 0)
            return PrimitiveBoolean.FALSE;

        TreeSet<BooleanFormula> elements = new TreeSet<BooleanFormula>(
                new SatVisitor.FormulaComparator());
        LinkedList<BooleanFormula> toProcess = new LinkedList<BooleanFormula>(
                Arrays.asList(objects));
        // first, collapse Ors.
        while (!toProcess.isEmpty()) {
            BooleanFormula head = toProcess.removeFirst();
            head = head.simplify();
            if (head instanceof Or) {
                Or and = (Or) head;
                toProcess.addAll(Arrays.asList(and.objects));
            } else if (head == PrimitiveBoolean.FALSE) {
                // can't be alone, so skip
            } else if (head == PrimitiveBoolean.TRUE) {
                return head; // true is a short circuit for ors
            } else {
                elements.add(head.simplify());
            }
        }
        if (elements.isEmpty())
            // can only get here by skipping falses
            return PrimitiveBoolean.FALSE;
        else if (elements.size() == 1)
            return elements.iterator().next();
        else {
            // scan for "a and not a"
            for (Iterator iter = elements.iterator(); iter.hasNext();) {
                BooleanFormula element = (BooleanFormula) iter.next();
                if (elements.contains(element.negate()))
                    return PrimitiveBoolean.TRUE;
            }
            return new Or(elements.toArray(new BooleanFormula[] {}));
        }
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#convertToCNF()
     */
    public BooleanFormula convertToCNF() {
        BooleanFormula simplified = this.simplify();
        if (simplified instanceof Or) {
            Or or = (Or) simplified;
            // First, make a pass through the array; some of our stuff turns
            // into Ors or Ands.
            BooleanFormula[] array = or.objects.clone();
            boolean makeAnotherPass = false;
            for (int i = 0; i < array.length; i++) {
                array[i] = array[i].convertToCNF();
                if (array[i] instanceof Or)
                    makeAnotherPass = true;
            }
            if (makeAnotherPass)
                return new Or(array).convertToCNF();
            // OK, no ors and it's all primitives now.
            ArrayList<BooleanFormula> elements = new ArrayList<BooleanFormula>(
                    Arrays.asList(array));
            for (Iterator iter = elements.iterator(); iter.hasNext();) {
                BooleanFormula element = (BooleanFormula) iter.next();
                if (element instanceof And) {
                    And and = (And) element;
                    iter.remove();
                    BooleanFormula[] others = elements
                            .toArray(new BooleanFormula[] {});
                    BooleanFormula[] subclauses = and.objects.clone();
                    for (int i = 0; i < subclauses.length; i++) {
                        subclauses[i] = new Or(subclauses[i], new Or(others));
                    }
                    return new And(subclauses).convertToCNF();
                }
            }
            BooleanFormula[] result = elements.toArray(new BooleanFormula[] {});
            return new Or(result).simplify();
        }
        return simplified.convertToCNF();
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#visit(org.sigwinch.xacml.output.sat.FormulaVisitor)
     */
    public void visit(FormulaVisitor impl) {
        impl.visitOr(this);
    }

    public boolean isInCNF() {
        for (int i = 0; i < objects.length; i++) {
            if (!objects[i].isInCNF())
                return false;
            if (objects[i] instanceof Not
                    || objects[i] instanceof VariableReference)
                // NB: it is not okay to have true or false here, because they
                // should have been reduced
                continue;
            return false;
        }
        return true;
    }
}

// arch-tag: Or.java Apr 25, 2005 2:18:28 PM
