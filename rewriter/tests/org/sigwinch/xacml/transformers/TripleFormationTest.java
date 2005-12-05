package org.sigwinch.xacml.transformers;
import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

import org.sigwinch.xacml.tree.Deny;
import org.sigwinch.xacml.tree.Error;
import org.sigwinch.xacml.tree.Permit;
import org.sigwinch.xacml.tree.Scope;
import org.sigwinch.xacml.tree.SimplePredicate;
import org.sigwinch.xacml.tree.Tree;
import org.sigwinch.xacml.tree.Triple;
import org.sigwinch.xacml.tree.VariableReference;

/**
 * TripleFormation.java
 * 
 * 
 * Created: Sat Nov  8 02:00:09 2003
 * 
 * @author Graham Hughes
 * @version
 */

public class TripleFormationTest extends TestCase {
    VariableReference a, b, c;
    
    public static Test suite() {
	return new TestSuite(TripleFormationTest.class);
    }

    @Override
    protected void setUp() {
	a = new VariableReference ("a");
	b = new VariableReference ("b");
	c = new VariableReference ("c");
    }
    
    public void testCreatesTriples () {
	Tree tree = new Scope (Permit.PERMIT, a);
	Tree expectedResult = new Triple (a, SimplePredicate.FALSE, 
					  SimplePredicate.FALSE);
	assertEquals (expectedResult, tree.transform (new TripleFormer ()));

	tree = new Scope (Deny.DENY, a);
	expectedResult = new Triple (SimplePredicate.FALSE, a, 
				     SimplePredicate.FALSE);
	assertEquals (expectedResult, tree.transform (new TripleFormer ()));

	tree = new Error (Deny.DENY, a);
	expectedResult = 
	    new Triple (SimplePredicate.FALSE, a.not (), a);
	assertEquals (expectedResult, tree.transform (new TripleFormer ()));
    }
    
    public void testSetsDisjoint () {
	Tree tree = new Error (new Scope (Deny.DENY, b), a);
	Tree expectedResult = 
	    new Triple (SimplePredicate.FALSE, b.andWith (a.not ()), a);
	assertEquals (expectedResult, tree.transform (new TripleFormer ()));
    }
}
