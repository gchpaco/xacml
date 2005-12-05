package org.sigwinch.xacml.transformers;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

import org.sigwinch.xacml.tree.*;
import org.sigwinch.xacml.tree.Error;

/**
 * ScopePropogationTest.java
 * 
 * 
 * Created: Fri Nov 7 20:48:24 2003
 * 
 * @author Graham Hughes
 * @version
 */

public class ScopePropogationTest extends TestCase {
    VariableReference a, b;

    public static Test suite() {
        return new TestSuite(ScopePropogationTest.class);
    }

    @Override
    protected void setUp() {
        a = new VariableReference("a");
        b = new VariableReference("b");
    }

    public void testThroughErrors() {
        Tree tree = new Scope(new Error(Deny.DENY, b), a);
        Tree expectedResult = new Error(new Scope(Deny.DENY, a),
                new AndPredicate(b, a));
        assertEquals(expectedResult, tree.transform(new Propagator()));
    }

    public void testThroughPermit() {
        Tree tree = new Scope(
                new PermitOverridesRule(Deny.DENY, Permit.PERMIT), a);
        Tree expectedResult = new PermitOverridesRule(new Scope(Deny.DENY, a),
                new Scope(Permit.PERMIT, a));
        assertEquals(expectedResult, tree.transform(new Propagator()));
    }

    public void testThroughDeny() {
        Tree tree = new Scope(new DenyOverridesRule(Deny.DENY, Permit.PERMIT),
                a);
        Tree expectedResult = new DenyOverridesRule(new Scope(Deny.DENY, a),
                new Scope(Permit.PERMIT, a));
        assertEquals(expectedResult, tree.transform(new Propagator()));
    }

    public void testThroughFirst() {
        Tree tree = new Scope(
                new FirstApplicableRule(Deny.DENY, Permit.PERMIT), a);
        Tree expectedResult = new FirstApplicableRule(new Scope(Deny.DENY, a),
                new Scope(Permit.PERMIT, a));
        assertEquals(expectedResult, tree.transform(new Propagator()));
    }

    public void testThroughOnly() {
        Tree tree = new Scope(new OnlyOneRule(Deny.DENY, Permit.PERMIT), a);
        Tree expectedResult = new OnlyOneRule(new Scope(Deny.DENY, a),
                new Scope(Permit.PERMIT, a));
        assertEquals(expectedResult, tree.transform(new Propagator()));
    }

    public void testDeepness() {
        Tree tree = new OnlyOneRule(new Scope(new PermitOverridesRule(
                Deny.DENY, Permit.PERMIT), a), Deny.DENY);
        Tree expectedResult = new OnlyOneRule(new PermitOverridesRule(
                new Scope(Deny.DENY, a), new Scope(Permit.PERMIT, a)),
                Deny.DENY);
        assertEquals(expectedResult, tree.transform(new Propagator()));
    }

    public void testRealExample() {
        SimplePredicate p = SimplePredicate.TRUE;
        Tree tree = new Scope(new DenyOverridesRule(new Scope(new Error(
                new Scope(new Scope(Permit.PERMIT, p), p), p), p), new Scope(
                new DenyOverridesRule(new Error(new Scope(new Scope(
                        Permit.PERMIT, p), p), p),
                        new DenyOverridesRule(new Error(new Scope(new Scope(
                                Permit.PERMIT, p), p), p), new Scope(Deny.DENY,
                                p))), p)), p);
        Tree expectedResult = new DenyOverridesRule(new Error(new Scope(
                Permit.PERMIT, p), p), new DenyOverridesRule(new Error(
                new Scope(Permit.PERMIT, p), p), new DenyOverridesRule(
                new Error(new Scope(Permit.PERMIT, p), p), new Scope(Deny.DENY,
                        p))));
        assertEquals(expectedResult, tree.transform(new Propagator())
                .transform(new DuplicateRemover()));
    }
}
