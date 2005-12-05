package org.sigwinch.xacml.tree;

/**
 * Tree walker for XACML trees.
 * 
 * 
 * Created: Fri Nov 7 00:10:39 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */

public interface Visitor {
    // Base nodes
    public void walkDeny(Deny d);

    public void walkPermit(Permit p);

    // Scoping and error nodes
    public void walkError(Error e);

    public void walkScope(Scope s);

    // Shorthand nodes
    public void walkTriple(Triple t);

    // Combination nodes
    public void walkPermitOverridesRule(PermitOverridesRule r);

    public void walkDenyOverridesRule(DenyOverridesRule r);

    public void walkOnlyOneRule(OnlyOneRule r);

    public void walkFirstApplicableRule(FirstApplicableRule r);

    // Predicates
    public void walkAndPredicate(AndPredicate p);

    public void walkConstantValuePredicate(ConstantValuePredicate p);

    public void walkEnvironmentalPredicate(EnvironmentalPredicate p);

    public void walkExistentialPredicate(ExistentialPredicate p);

    public void walkFunctionCallPredicate(FunctionCallPredicate p);

    public void walkOrPredicate(OrPredicate p);

    public void walkSimplePredicate(SimplePredicate p);

    public void walkSolePredicate(SolePredicate p);

    public void walkVariableReference(VariableReference v);
}
/*
 * arch-tag: E100CEE0-10F9-11D8-A37F-000A95A2610A
 */
