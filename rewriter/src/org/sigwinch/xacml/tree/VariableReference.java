package org.sigwinch.xacml.tree;

import org.sigwinch.xacml.output.sat.BooleanFormula;
import org.sigwinch.xacml.output.sat.FormulaVisitor;
import org.sigwinch.xacml.output.sat.Not;




/**
 * VariableReference.java
 *
 *
 * Created: Sun Nov  9 18:54:32 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class VariableReference extends Predicate implements BooleanFormula {
    String name;
    public VariableReference(String name) {
	this.name = name;
    }

    /**
     * Gets the value of name
     *
     * @return the value of name
     */
    public String getName()  {
	return this.name;
    }

    /**
     * Sets the value of name
     *
     * @param argName Value to assign to this.name
     */
    public void setName(String argName) {
	this.name = argName;
    }
    
    // Implementation of org.sigwinch.xacml.tree.Predicate
    
    /**
     * Transform this variable reference according to
     * <code>transformer</code>.
     *
     * @param transformer a <code>Transformer</code>
     * @return new predicate
     */
    @Override
    public Predicate transform(Transformer transformer) {
	return transformer.walkVariableReference (this);
    }

    /**
     * Call <code>visitor</code>'s appropriate walk method, according
     * to this node's type.
     *
     * @param visitor a <code>Visitor</code>
     */
    @Override
    public void walk(Visitor visitor) {
	visitor.walkVariableReference (this);
    }

    /**
     * All variable references are 'functions' for our purposes.
     *
     * @return true
     */
    @Override
    public boolean isFunction() {
	return true;
    }

    @Override
    public boolean equals (Object o)
    {
	if (! (o instanceof VariableReference)) return false;
	VariableReference r = (VariableReference) o;
	return r.getName ().equals (name);
    }

    @Override
    public int hashCode ()
    {
	return name.hashCode ();
    }

    /* (non-Javadoc)
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#negate()
     */
    public BooleanFormula negate () {
        return new Not (this);
    }

    /* (non-Javadoc)
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#convertToCNF()
     */
    public BooleanFormula convertToCNF () {
        return this;
    }
    
    public BooleanFormula simplify () { return this; }

    /* (non-Javadoc)
     * @see org.sigwinch.xacml.output.sat.BooleanFormula#visit(org.sigwinch.xacml.output.sat.FormulaVisitor)
     */
    public void visit (FormulaVisitor impl) {
        impl.visitVariable(this);
    }
    public boolean isInCNF () { return true; }
}
/* arch-tag: 37CE2F54-1329-11D8-9A91-000A95A2610A
 */
