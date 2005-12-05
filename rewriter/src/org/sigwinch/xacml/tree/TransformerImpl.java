package org.sigwinch.xacml.tree;




/**
 * A default implementation of the Transformer interface that walks
 * the tree, building a new one if the nodes change.  This does
 * include some nontrivial knowledge of which rules have children,
 * though.
 *
 * Created: Fri Nov  7 00:21:00 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class TransformerImpl implements Transformer {
    public TransformerImpl() {
	
    }
    
    // Implementation of org.sigwinch.xacml.tree.Transformer

    public Tree walkDeny(Deny deny) { return deny; }
    public Tree walkPermit(Permit permit) { return permit; }
    public Tree walkError(Error error) {
	Tree child = error.getChild().transform (this);
	Predicate condition = error.getCondition().transform (this);
	if (child == error.getChild () && condition == error.getCondition ())
	    return error;
    return new Error (child, condition);
    }
    public Tree walkScope(Scope scope) {
	Tree child = scope.getChild().transform (this);
	Predicate condition = scope.getCondition().transform (this);
	if (child == scope.getChild () && condition == scope.getCondition ())
	    return scope;
    return new Scope (child, condition);
    }
    public Tree walkTriple (Triple triple) {
	Predicate permit = triple.getPermit ().transform (this);
	Predicate deny = triple.getDeny ().transform (this);
	Predicate error = triple.getError ().transform (this);
	if (permit == triple.getPermit () && deny == triple.getDeny () &&
	    error == triple.getError ())
	    return triple;
    return new Triple (permit, deny, error);
    }
    public Tree walkPermitOverridesRule(PermitOverridesRule 
					permitOverridesRule) {
	Tree left = permitOverridesRule.getLeft().transform (this);
	Tree right = permitOverridesRule.getRight().transform (this);
	if (left == permitOverridesRule.getLeft () && 
	    right == permitOverridesRule.getRight ())
	    return permitOverridesRule;
    return new PermitOverridesRule (left, right);
    }
    public Tree walkDenyOverridesRule(DenyOverridesRule denyOverridesRule) {
	Tree left = denyOverridesRule.getLeft().transform (this);
	Tree right = denyOverridesRule.getRight().transform (this);
	if (left == denyOverridesRule.getLeft () && 
	    right == denyOverridesRule.getRight ())
	    return denyOverridesRule;
    return new DenyOverridesRule (left, right);
    }
    public Tree walkOnlyOneRule(OnlyOneRule onlyOneRule) {
	Tree left = onlyOneRule.getLeft().transform (this);
	Tree right = onlyOneRule.getRight().transform (this);
	if (left == onlyOneRule.getLeft () && 
	    right == onlyOneRule.getRight ())
	    return onlyOneRule;
    return new OnlyOneRule (left, right);
    }
    public Tree walkFirstApplicableRule(FirstApplicableRule 
					firstApplicableRule) {
	Tree left = firstApplicableRule.getLeft().transform (this);
	Tree right = firstApplicableRule.getRight().transform (this);
	if (left == firstApplicableRule.getLeft () && 
	    right == firstApplicableRule.getRight ())
	    return firstApplicableRule;
    return new FirstApplicableRule (left, right);
    }
    public Predicate walkAndPredicate(AndPredicate andPredicate) {
	Predicate left = andPredicate.getLeft().transform (this);
	Predicate right = andPredicate.getRight().transform (this);
	if (left == andPredicate.getLeft () && 
	    right == andPredicate.getRight ())
	    return andPredicate;
    return new AndPredicate (left, right);
    }
    public Predicate walkConstantValuePredicate(ConstantValuePredicate 
						constantValuePredicate) {
	return constantValuePredicate;
    }
    public Predicate walkEnvironmentalPredicate(EnvironmentalPredicate 
						environmentalPredicate) {
	return environmentalPredicate;
    }
    public Predicate walkExistentialPredicate(ExistentialPredicate
					      existentialPredicate) {
	Predicate bag = existentialPredicate.getBag().transform (this);
	Predicate attribute = existentialPredicate.getAttribute().transform (this);
	if (bag == existentialPredicate.getBag () && 
	    attribute == existentialPredicate.getAttribute ())
	    return existentialPredicate;
    return new ExistentialPredicate 
    (existentialPredicate.getFunction (), bag, attribute);
    }
    public Predicate walkFunctionCallPredicate(FunctionCallPredicate
					  functionCallPredicate) {
	Predicate [] args = functionCallPredicate.getArguments();
	Predicate [] newargs = new Predicate [args.length];
	for (int i = 0; i < args.length; i++)
	    newargs[i] = args[i].transform (this);
	boolean unchanged = true;
	for (int i = 0; i < args.length; i++)
	    if (newargs[i] != args[i])
		unchanged = false;
	if (unchanged)
	    return functionCallPredicate;
    return new FunctionCallPredicate
    (functionCallPredicate.getFunction (), newargs);
    }
    public Predicate walkOrPredicate(OrPredicate orPredicate) {
	Predicate left = orPredicate.getLeft().transform (this);
	Predicate right = orPredicate.getRight().transform (this);
	if (left == orPredicate.getLeft () && 
	    right == orPredicate.getRight ())
	    return orPredicate;
    return new OrPredicate (left, right);
    }
    public Predicate walkSimplePredicate(SimplePredicate simplePredicate) {
	return simplePredicate;
    }
    public Predicate walkSolePredicate (SolePredicate p) {
	Predicate set = p.getSet ().transform (this);
	if (set == p.getSet ()) return p;
    return new SolePredicate (set);
    }
    public Predicate walkVariableReference (VariableReference v) {
	return v;
    }
}
/* arch-tag: 8E0F2BB5-110B-11D8-8C88-000A95A2610A
 */
