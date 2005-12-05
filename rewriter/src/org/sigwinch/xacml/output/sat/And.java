/*
 * Created on Apr 25, 2005
 */
package org.sigwinch.xacml.output.sat;

import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.TreeSet;

import org.sigwinch.xacml.tree.VariableReference;

/**
 * @author graham
 */
public class And implements BooleanFormula {
    BooleanFormula[] objects;

    /**
     * @param a
     * @param b
     */
    public And (BooleanFormula a, BooleanFormula b) {
        assert a != null : "First argument is null";
        assert b != null : "Second argument is null";
        objects = new BooleanFormula[] { a, b };
    }

    /**
     * @param a
     * @param b
     */
    public And (BooleanFormula a, BooleanFormula b, BooleanFormula c) {
        assert a != null : "First argument is null";
        assert b != null : "Second argument is null";
        assert c != null : "Third argument is null";
        objects = new BooleanFormula[] { a, b, c };
    }

    /**
     * @param clauses
     */
    public And (BooleanFormula[] clauses) {
        for (int i = 0; i < clauses.length; i++) {
            assert clauses[i] != null : i + "th argument is null";
        }
        objects = clauses.clone ();
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString () {
        StringBuffer buf = new StringBuffer ();
        buf.append ("(and");
        for (int i = 0; i < objects.length; i++) {
            buf.append (" ");
            if (objects[i] == null)
                buf.append ("nil");
            else
                buf.append (objects[i].toString ());
        }
        buf.append (")");
        return buf.toString ();
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals (Object obj) {
        if (obj instanceof And) {
            And obj2 = (And) obj;
            if (obj2.objects.length != objects.length)
                return false;
            for (int i = 0; i < objects.length; i++)
                if (!objects[i].equals (obj2.objects[i]))
                    return false;
            return true;
        }
        return super.equals (obj);
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode () {
        int hash = '^';
        for (int i = 0; i < objects.length; i++)
            hash ^= objects[i].hashCode ();
        return hash;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#negate()
     */
    public BooleanFormula negate () {
        return new Not (this);
    }

    public BooleanFormula simplify () {
        // some trivial stuff first
        if (objects.length == 0)
            return BooleanFormula.FALSE;
        //      We use this set to keep the elements in a recognizable order, and as
        // a side effect to kill duplicates.
        TreeSet<BooleanFormula> elements = new TreeSet<BooleanFormula> (new SatVisitor.FormulaComparator ());
        LinkedList<BooleanFormula> toProcess = new LinkedList<BooleanFormula> (Arrays.asList (objects));
        // first, collapse Ands.
        while (!toProcess.isEmpty ()) {
            BooleanFormula head = toProcess.removeFirst ();
            head = head.simplify ();
            if (head instanceof And) {
                And and = (And) head;
                toProcess.addAll (Arrays.asList (and.objects));
            } else if (head == BooleanFormula.TRUE) {
                // can't be the only thing, because we checked that; so skip
            } else if (head == BooleanFormula.FALSE) {
                return head; // false is a short circuit for ands
            } else {
                elements.add (head.simplify ());
            }
        }
        if (elements.isEmpty ())
            // can only get here by skipping trues
            return BooleanFormula.TRUE;
        else if (elements.size () == 1)
            return elements.iterator ().next ();
        else {
            // scan for "a and not a"
            for (Iterator iter = elements.iterator (); iter.hasNext ();) {
                BooleanFormula element = (BooleanFormula) iter.next ();
                if (elements.contains (element.negate ()))
                    return BooleanFormula.FALSE;
            }
            return new And (
                            elements
                                                       .toArray (new BooleanFormula[] {}));
        }
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#convertToCNF()
     */
    public BooleanFormula convertToCNF () {
        BooleanFormula simplified = this.simplify ();
        if (simplified instanceof And) {
            And and = (And) simplified;
            // First, make a pass through the array; some of our stuff turns into Ors or Ands.
            BooleanFormula [] array = and.objects.clone ();
            boolean makeAnotherPass = false;
            for (int i = 0; i < array.length; i++) {
                array[i] = array[i].convertToCNF ();
                if (array[i] instanceof And) makeAnotherPass = true;
            }
            if (makeAnotherPass) return new And (array).convertToCNF ();
            // OK, now we know no Ands are in here, and everything is primitive.
            BooleanFormula[] result = new BooleanFormula[array.length];
            for (int i = 0; i < array.length; i++) {
                result[i] = array[i].convertToCNF ();
            }
            return new And (result).simplify ();
        }
        return simplified.convertToCNF ();
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#visit(org.sigwinch.xacml.output.sat.FormulaVisitor)
     */
    public void visit (FormulaVisitor impl) {
        impl.visitAnd (this);
    }

    public boolean isInCNF () {
        for (int i = 0; i < objects.length; i++) {
            if (!objects[i].isInCNF ())
                return false;
            if (objects[i] instanceof Not || objects[i] instanceof Or
                || objects[i] instanceof VariableReference)
                // NB: it is not okay to have true or false here, because they should have been reduced
                continue;
            return false;
        }
        return true;
    }
}

// arch-tag: And.java Apr 25, 2005 2:18:48 PM
