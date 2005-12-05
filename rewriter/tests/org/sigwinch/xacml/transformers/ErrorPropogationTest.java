package org.sigwinch.xacml.transformers;
import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

import org.sigwinch.xacml.tree.Deny;
import org.sigwinch.xacml.tree.DenyOverridesRule;
import org.sigwinch.xacml.tree.Error;
import org.sigwinch.xacml.tree.FirstApplicableRule;
import org.sigwinch.xacml.tree.OnlyOneRule;
import org.sigwinch.xacml.tree.Permit;
import org.sigwinch.xacml.tree.PermitOverridesRule;
import org.sigwinch.xacml.tree.Tree;
import org.sigwinch.xacml.tree.VariableReference;

/**
 * ErrorPropogationTest.java
 * 
 * 
 * Created: Fri Nov  7 20:48:24 2003
 * 
 * @author Graham Hughes
 * @version
 */

public class ErrorPropogationTest extends TestCase {
    VariableReference a, b;
    public static Test suite() {
	return new TestSuite(ErrorPropogationTest.class);
    }
    
    protected void setUp() {
	a = new VariableReference ("a");
	b = new VariableReference ("b");
    }
    
    public void testThroughPermit () {
	Tree tree = new Error (new PermitOverridesRule (Deny.DENY,
							Permit.PERMIT),
			       a);
	Tree expectedResult =
	    new PermitOverridesRule (new Error (Deny.DENY, a), Permit.PERMIT);
	assertEquals (expectedResult, tree.transform (new Propagator ()));
    }

    public void testThroughDeny () {
	Tree tree = new Error (new DenyOverridesRule (Deny.DENY,
						      Permit.PERMIT),
			       a);
	Tree expectedResult =
	    new DenyOverridesRule (new Error (Deny.DENY, a), Permit.PERMIT);
	assertEquals (expectedResult, tree.transform (new Propagator ()));
    }

    public void testThroughFirst () {
	Tree tree = new Error (new FirstApplicableRule (Deny.DENY,
							Permit.PERMIT), a);
	Tree expectedResult =
	    new FirstApplicableRule (new Error (Deny.DENY, a), Permit.PERMIT);
	assertEquals (expectedResult, tree.transform (new Propagator ()));
    }

    public void testThroughOnly () {
	Tree tree = new Error (new OnlyOneRule (Deny.DENY, Permit.PERMIT), a);
	Tree expectedResult =
	    new OnlyOneRule (new Error (Deny.DENY, a), Permit.PERMIT);
	assertEquals (expectedResult, tree.transform (new Propagator ()));
    }

    public void testDeepness () {
	Tree tree = new OnlyOneRule (new Error (new PermitOverridesRule 
						(Deny.DENY, Permit.PERMIT), a),
				     Deny.DENY);
	Tree expectedResult =
	    new OnlyOneRule (new PermitOverridesRule (new Error (Deny.DENY, a),
						      Permit.PERMIT), 
			     Deny.DENY);
	assertEquals (expectedResult, tree.transform (new Propagator ()));
    }
}
