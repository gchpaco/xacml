/*
 * Created on Apr 25, 2005
 */
package org.sigwinch.xacml.output.sat;


/**
 * @author graham
 */
public interface BooleanFormula {
    static public class True implements BooleanFormula {
        True () {
        }

        public BooleanFormula negate () {
            return FALSE;
        }

        public String toString () {
            return "true";
        }
        
        public BooleanFormula simplify () { return this; }

        public BooleanFormula convertToCNF () {
            return this;
        }
        public void visit (FormulaVisitor impl) { impl.visitTrue (this); }
        public boolean isInCNF () { return true; }
    }

    static public class False implements BooleanFormula {
        False () {
        }

        public BooleanFormula negate () {
            return TRUE;
        }

        public String toString () {
            return "false";
        }
        
        public BooleanFormula simplify () { return this; }

        public BooleanFormula convertToCNF () {
            return this;
        }
        
        public void visit (FormulaVisitor impl) { impl.visitFalse (this); }
        public boolean isInCNF () { return true; }
    }

    static BooleanFormula TRUE = new True ();
    static BooleanFormula FALSE = new False ();
    
    public BooleanFormula negate ();

    /**
     * @param impl
     */
    public void visit (FormulaVisitor impl);
    public BooleanFormula simplify ();
    public BooleanFormula convertToCNF ();

    /**
     * @return
     */
    public boolean isInCNF ();
}

// arch-tag: BooleanFormula.java Apr 25, 2005 2:13:50 PM
