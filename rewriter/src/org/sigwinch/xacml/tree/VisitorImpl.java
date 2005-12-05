package org.sigwinch.xacml.tree;

import org.sigwinch.xacml.tree.AndPredicate;
import org.sigwinch.xacml.tree.FirstApplicableRule;
import org.sigwinch.xacml.tree.Permit;
import org.sigwinch.xacml.tree.Error;
import org.sigwinch.xacml.tree.OrPredicate;
import org.sigwinch.xacml.tree.PermitOverridesRule;
import org.sigwinch.xacml.tree.Deny;
import org.sigwinch.xacml.tree.ExistentialPredicate;
import org.sigwinch.xacml.tree.Visitor;
import org.sigwinch.xacml.tree.ConstantValuePredicate;
import org.sigwinch.xacml.tree.SimplePredicate;
import org.sigwinch.xacml.tree.FunctionCallPredicate;
import org.sigwinch.xacml.tree.EnvironmentalPredicate;
import org.sigwinch.xacml.tree.DenyOverridesRule;
import org.sigwinch.xacml.tree.Scope;
import org.sigwinch.xacml.tree.OnlyOneRule;



/**
 * A default implementation of the Visitor interface that does nothing
 * except walk the tree.  This does include some nontrivial knowledge
 * of which rules have children, though.
 *
 * Created: Fri Nov  7 00:21:00 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class VisitorImpl implements Visitor {
    public VisitorImpl() {
	
    }
    
    // Implementation of org.sigwinch.xacml.tree.Visitor

    public void walkDeny(Deny deny) {}
    public void walkPermit(Permit permit) {}
    public void walkError(Error error) {
	error.getChild().walk (this);
	error.getCondition().walk (this);
    }
    public void walkScope(Scope scope) {
	scope.getChild().walk (this);
	scope.getCondition().walk (this);
    }
    public void walkTriple(Triple triple) {
	triple.getPermit ().walk (this);
	triple.getDeny ().walk (this);
	triple.getError ().walk (this);
    }
    public void walkPermitOverridesRule(PermitOverridesRule 
					permitOverridesRule) {
	permitOverridesRule.getLeft().walk (this);
	permitOverridesRule.getRight().walk (this);
    }
    public void walkDenyOverridesRule(DenyOverridesRule denyOverridesRule) {
	denyOverridesRule.getLeft().walk (this);
	denyOverridesRule.getRight().walk (this);
    }
    public void walkOnlyOneRule(OnlyOneRule onlyOneRule) {
	onlyOneRule.getLeft().walk (this);
	onlyOneRule.getRight().walk (this);
    }
    public void walkFirstApplicableRule(FirstApplicableRule 
					firstApplicableRule) {
	firstApplicableRule.getLeft().walk (this);
	firstApplicableRule.getRight().walk (this);
    }
    public void walkAndPredicate(AndPredicate andPredicate) {
	andPredicate.getLeft().walk (this);
	andPredicate.getRight().walk (this);
    }
    public void walkConstantValuePredicate(ConstantValuePredicate 
					   constantValuePredicate) {}
    public void walkEnvironmentalPredicate(EnvironmentalPredicate 
					   environmentalPredicate) {}
    public void walkExistentialPredicate(ExistentialPredicate
					 existentialPredicate) {
	existentialPredicate.getBag ().walk (this);
	existentialPredicate.getAttribute().walk (this);
    }
    public void walkFunctionCallPredicate(FunctionCallPredicate
					  functionCallPredicate) {
	Predicate [] args = functionCallPredicate.getArguments();
	for (int i = 0; i < args.length; i++)
	    args[i].walk (this);
    }
    public void walkOrPredicate(OrPredicate orPredicate) {
	orPredicate.getLeft().walk (this);
	orPredicate.getRight().walk (this);
    }
    public void walkSimplePredicate(SimplePredicate simplePredicate) {}
    public void walkSolePredicate (SolePredicate p) {
	p.getSet ().walk (this);
    }
    public void walkVariableReference (VariableReference v) {}
}
/* arch-tag: 54760C1C-10FB-11D8-9D50-000A95A2610A
 */
