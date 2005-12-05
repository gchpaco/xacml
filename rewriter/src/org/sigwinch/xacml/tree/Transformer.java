package org.sigwinch.xacml.tree;

/**
 * Tree transformer for XACML trees.
 *
 *
 * Created: Fri Nov  7 00:10:39 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */

public interface Transformer {
    // Base nodes
    public Tree walkDeny (Deny d);
    public Tree walkPermit (Permit p);

    // Scoping and error nodes
    public Tree walkError (Error e);
    public Tree walkScope (Scope s);

    // Shorthand nodes
    public Tree walkTriple (Triple t);

    // Combination nodes
    public Tree walkPermitOverridesRule (PermitOverridesRule r);
    public Tree walkDenyOverridesRule (DenyOverridesRule r);
    public Tree walkOnlyOneRule (OnlyOneRule r);
    public Tree walkFirstApplicableRule (FirstApplicableRule r);

    // Predicates
    public Predicate walkAndPredicate (AndPredicate p);
    public Predicate walkConstantValuePredicate (ConstantValuePredicate p);
    public Predicate walkEnvironmentalPredicate (EnvironmentalPredicate p);
    public Predicate walkExistentialPredicate (ExistentialPredicate p);
    public Predicate walkFunctionCallPredicate (FunctionCallPredicate p);
    public Predicate walkOrPredicate (OrPredicate p);
    public Predicate walkSimplePredicate (SimplePredicate p);
    public Predicate walkSolePredicate (SolePredicate p);
    public Predicate walkVariableReference (VariableReference v);
}
/* arch-tag: 441582C9-110B-11D8-893C-000A95A2610A
 */
