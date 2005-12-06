package org.sigwinch.xacml.output.sat;

public enum PrimitiveBoolean implements BooleanFormula {
    FALSE {
        public BooleanFormula negate() {
            return TRUE;
        }
        
        public void visit(FormulaVisitor impl) {
            impl.visitFalse(this);
        }
        
        @Override
        public String toString() {
            return "false";
        }
    }, TRUE {
        public BooleanFormula negate() {
            return FALSE;
        }
        
        public void visit(FormulaVisitor impl) {
            impl.visitTrue(this);
        }
        
        @Override
        public String toString() {
            return "true";
        }
    };
    
    public BooleanFormula simplify() {
        return this;
    }
    
    public BooleanFormula convertToCNF() {
        return this;
    }
    
    public boolean isInCNF() {
        return true;
    }
}
