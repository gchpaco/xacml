package org.sigwinch.xacml.transformers;

import junit.framework.*;
import org.sigwinch.xacml.tree.FirstApplicableRule;
import org.sigwinch.xacml.tree.Tree;
import org.sigwinch.xacml.tree.SimplePredicate;
import org.sigwinch.xacml.tree.Permit;
import org.sigwinch.xacml.tree.Scope;
import org.sigwinch.xacml.tree.Deny;
import org.sigwinch.xacml.tree.VariableReference;
import org.sigwinch.xacml.tree.Error;
import org.sigwinch.xacml.tree.AndPredicate;
import org.sigwinch.xacml.tree.OrPredicate;

/**
 * DuplicateResolutionTest.java
 * 
 * 
 * Created: Fri Nov 7 16:07:18 2003
 * 
 * @author Graham Hughes
 * @version
 */

public class DuplicateResolutionTest extends TestCase {
    VariableReference a, b, c;

    public static Test suite() {
        return new TestSuite(DuplicateResolutionTest.class);
    }

    @Override
    protected void setUp() {
        a = new VariableReference("a");
        b = new VariableReference("b");
        c = new VariableReference("c");
    }

    public void testDoesNoHarm() {
        Tree tree = new FirstApplicableRule(new Scope(Permit.PERMIT,
                SimplePredicate.TRUE), new Error(Deny.DENY,
                SimplePredicate.FALSE));
        assertEquals(tree, tree.transform(new DuplicateRemover()));
    }

    public void testUnifiesErrors() {
        Tree tree = new Error(new Error(Deny.DENY, a), b);
        Tree expectedResult = new Error(Deny.DENY, new OrPredicate(a, b));
        assertEquals(expectedResult, tree.transform(new DuplicateRemover()));
    }

    public void testTripleErrorUnified() {
        Tree tree = new Error(new Error(new Error(Deny.DENY, a), b), c);
        Tree expectedResult = new Error(Deny.DENY, new OrPredicate(a,
                new OrPredicate(b, c)));
        assertEquals(expectedResult, tree.transform(new DuplicateRemover()));
    }

    public void testUnifiesScopes() {
        Tree tree = new Scope(new Scope(Deny.DENY, a), b);
        Tree expectedResult = new Scope(Deny.DENY, new AndPredicate(a, b));
        assertEquals(expectedResult, tree.transform(new DuplicateRemover()));
    }

    public void testTripleScopeUnified() {
        Tree tree = new Scope(new Scope(new Scope(Deny.DENY, a), b), c);
        Tree expectedResult = new Scope(Deny.DENY, new AndPredicate(a,
                new AndPredicate(b, c)));
        assertEquals(expectedResult, tree.transform(new DuplicateRemover()));
    }

    public void testDeepness() {
        Tree tree = new Error(new Scope(new Scope(Deny.DENY, a), b), c);
        Tree expectedResult = new Error(new Scope(Deny.DENY, new AndPredicate(
                a, b)), c);
        assertEquals(expectedResult, tree.transform(new DuplicateRemover()));

        tree = new Scope(new Error(new Error(Deny.DENY, a), b), c);
        expectedResult = new Scope(new Error(Deny.DENY, new OrPredicate(a, b)),
                c);
        assertEquals(expectedResult, tree.transform(new DuplicateRemover()));
    }
}
