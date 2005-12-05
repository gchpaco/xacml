package org.sigwinch.xacml.transformers;
import junit.framework.*;
import org.sigwinch.xacml.tree.PermitOverridesRule;
import org.sigwinch.xacml.tree.Triple;
import org.sigwinch.xacml.tree.SimplePredicate;
import org.sigwinch.xacml.tree.FirstApplicableRule;
import org.sigwinch.xacml.tree.DenyOverridesRule;
import org.sigwinch.xacml.tree.OnlyOneRule;
import org.sigwinch.xacml.tree.VariableReference;
import org.sigwinch.xacml.tree.Tree;

/**
 * TriplePropagationTest.java
 * 
 * 
 * Created: Sun Nov  9 03:29:11 2003
 * 
 * @author Graham Hughes
 * @version
 */

public class TriplePropagationTest extends TestCase {
    VariableReference a, b, c, d, e, f;
    
    public static Test suite() {
	return new TestSuite(TriplePropagationTest.class);
    }
    
    protected void setUp() {
	a = new VariableReference ("a");
	b = new VariableReference ("b");
	c = new VariableReference ("c");
	d = new VariableReference ("d");
	e = new VariableReference ("e");
	f = new VariableReference ("f");
    }
    
    public void testThroughPermit () {
	Tree tree = 
	    new PermitOverridesRule (new Triple (a, b, c),
				     new Triple (d, e, f));
	Tree expectedResult =
	    new Triple (a.orWith (d).andWith (c.orWith (f).not ()),
			(b.andWith (d.orWith (f).not ()))
			.orWith (e.andWith (a.orWith (c).not ())),
			c.orWith (f));
	assertEquals (expectedResult, 
		      tree.transform (new TriplePropagator ()));
    }
    
    public void testThroughDeny () {
	Tree tree = 
	    new DenyOverridesRule (new Triple (a, b, c),
				   new Triple (d, e, f));
	Tree expectedResult =
	    new Triple ((a.andWith (e.orWith (f).not ()))
			.orWith (d.andWith (b.orWith (c).not ())),
			b.orWith (e).andWith (c.orWith (f).not ()),
			c.orWith (f));
	assertEquals (expectedResult, 
		      tree.transform (new TriplePropagator ()));
    }
    
    public void testThroughOne () {
	Tree tree = 
	    new OnlyOneRule (new Triple (a, b, c),
			     new Triple (d, e, f));
	Tree expectedResult =
	    new Triple (a.orWith (d).andWith (a.andWith (d).orWith (c)
					      .orWith (f).not ()),
			b.orWith (e).andWith (b.andWith (e).orWith (c)
					      .orWith (f).not ()),
			c.orWith (f).orWith (a.andWith (d))
			.orWith (b.andWith (e)));
	assertEquals (expectedResult, 
		      tree.transform (new TriplePropagator ()));
    }
    
    public void testThroughFirst () {
	Tree tree = 
	    new FirstApplicableRule (new Triple (a, b, c),
				     new Triple (d, e, f));
	Tree expectedResult =
	    new Triple (a.orWith (d.andWith (b.orWith (c).not ())),
			b.orWith (e.andWith (a.orWith (c).not ())),
			c.orWith (f.andWith (a.orWith (b).not ())));
	assertEquals (expectedResult, 
		      tree.transform (new TriplePropagator ()));
    }

    public void testWithNegatives () {
	SimplePredicate nil = SimplePredicate.FALSE;
	Tree tree =
	    new DenyOverridesRule (new Triple (a, nil, b),
				   new Triple (nil, c, nil));
	/*    new Triple ((a.andWith (c.not ()))
			.orWith (nil),
			nil.orWith (c).andWith (b.orWith (nil).not ()),
			b.orWith (nil)); */
	Tree expectedResult =
	    new Triple ((a.andWith (c.not ())), c.andWith (b.not ()), b);
	assertEquals (expectedResult,
		      tree.transform (new TriplePropagator ()));
    }

    public void testElementaryOperations () {
	SimplePredicate t = SimplePredicate.TRUE;
	SimplePredicate nil = SimplePredicate.FALSE;
	assertEquals (a, a.orWith (nil));
	assertEquals (a, nil.orWith (a));
	assertEquals (t, a.orWith (t));
	assertEquals (t, t.orWith (a));
	assertEquals (a, a.andWith (t));
	assertEquals (a, t.andWith (a));
	assertEquals (nil, a.andWith (nil));
	assertEquals (nil, nil.andWith (a));
	assertEquals (t, nil.not ());
	assertEquals (nil, t.not ());
	assertEquals (a.andWith (b).orWith (nil),
		      a.andWith (b));
	assertEquals (a.andWith (b).orWith (t),
		      t);
	assertEquals (a.orWith (b).andWith (t),
		      a.orWith (b));
	assertEquals (a.orWith (b).andWith (nil),
		      nil);

	assertEquals (a.andWith (c.orWith (nil).not ()),
		      a.andWith (c.not ()));
	assertEquals (nil.andWith (nil.orWith (b).not ()),
		      nil);
	assertEquals ((a.andWith (c.orWith (nil).not ()))
		      .orWith (nil.andWith (nil.orWith (b).not ())),
		      (a.andWith (c.not ())));
	assertEquals (nil.orWith (c).andWith (b.orWith (nil).not ()),
		      c.andWith (b.not ()));
	assertEquals (b.orWith (nil), b);
    }
}
