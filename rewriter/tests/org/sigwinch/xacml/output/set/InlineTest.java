package org.sigwinch.xacml.output.set;
import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

import org.sigwinch.xacml.tree.*;
import org.sigwinch.xacml.tree.Error;

/**
 * InlineTest.java
 * 
 * 
 * Created: Sat Dec 20 01:34:28 2003
 * 
 * @author Graham Hughes
 * @version
 */

public class InlineTest extends TestCase {
    VariableReference a, b, c;
    SetVisitor out;
    final String xp = FunctionVisitor.xacmlprefix;

    public static Test suite() {
	return new TestSuite(InlineTest.class);
    }

    protected void reset () {
	out = new SetVisitor ();
	Predicate.reset ();
    }

    @Override
    protected void setUp() {
	a = new VariableReference ("a");
	b = new VariableReference ("b");
	c = new VariableReference ("c");
	reset ();
    }
    
    public void testTrivialStuff () {
	out.start ();
	new Triple (SimplePredicate.TRUE,
		    SimplePredicate.FALSE,
		    b).walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n}\n", out.getFunctions ());
	assertEquals ("one sig T0 extends Triple {} {\n" +
		      "\tpermit = E\n" +
		      "\tdeny = none\n" +
		      "\terror = b\n" +
		      "}\n", out.getFacts ());
    }

    public void testAnd () {
	out.start ();
	new Triple (a.andWith (b),
		    b.andWith (c),
		    a.andWith (b).andWith (c)).walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n}\n", out.getFunctions ());
	assertEquals ("one sig T0 extends Triple {} {\n" +
		      "\tpermit = a & b\n" +
		      "\tdeny = b & c\n" +
		      "\terror = a & b & c\n" +
		      "}\n", out.getFacts ());
    }

    public void testOr () {
	out.start ();
	new Triple (a.orWith (b),
		    b.orWith (c),
		    a.orWith (b).orWith (c)).walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n}\n", out.getFunctions ());
	assertEquals ("one sig T0 extends Triple {} {\n" +
		      "\tpermit = a + b\n" +
		      "\tdeny = b + c\n" +
		      "\terror = a + b + c\n" +
		      "}\n", out.getFacts ());
    }

    public void testOrderOfOperations () {
	out.start ();
	new Triple (a.orWith (b).andWith (c),
		    a.andWith (b).orWith (c),
		    a.andWith (b).orWith (c).andWith (a)).walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n}\n", out.getFunctions ());
	assertEquals ("one sig T0 extends Triple {} {\n" +
		      "\tpermit = (a + b) & c\n" +
		      "\tdeny = a & b + c\n" +
		      "\terror = (a & b + c) & a\n" +
		      "}\n", out.getFacts ());
    }

    public void testReferences () {
	out.start ();
	new Triple (new EnvironmentalPredicate ("string", "foo"),
		    new ConstantValuePredicate ("string", "foo"),
		    SimplePredicate.FALSE).walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n}\n", out.getFunctions ());
	assertEquals ("one sig T0 extends Triple {} {\n" +
		      "\tpermit = env0\n" +
		      "\tdeny = S.static0\n" +
		      "\terror = none\n" +
		      "}\n", out.getFacts ());
    }

    public void testSole () {
	out.start ();
	new Triple (new SolePredicate (SimplePredicate.TRUE),
		    new SolePredicate (SimplePredicate.TRUE),
		    SimplePredicate.FALSE).walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n}\n", out.getFunctions ());
	assertEquals ("sig S0 extends E {} { one E }\n" +
		      "one sig T0 extends Triple {} {\n" +
		      "\tpermit = S0\n" +
		      "\tdeny = S0\n" +
		      "\terror = none\n" +
		      "}\n", out.getFacts ());
    }

    public void testStupidFunction () {
	out.start ();
	new FunctionCallPredicate ("foo", new Predicate [] { a, b, c })
	    .andWith (new FunctionCallPredicate ("foo",
						 new Predicate [] { a, b, c }))
	    .orWith (new FunctionCallPredicate ("bar",
						new Predicate [] { b }))
	    .walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n" +
		      "\texpr0 : E -> Type, // foo (a, b, c)\n" +
		      "\texpr1 : E -> Type // bar (b)\n" +
		      "}\n",
		      out.getFunctions ());
	assertEquals ("", out.getFacts ());
    }

    public void testEqualsFunction () {
	out.start ();
	new Triple (new FunctionCallPredicate
		    (xp + "string-equal",
		     new Predicate [] { SimplePredicate.TRUE,
					SimplePredicate.FALSE }),
		    new FunctionCallPredicate (xp + "string-set-equals",
					       new Predicate [] { a, b }),
		    SimplePredicate.TRUE).walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n}\n", out.getFunctions ());
	assertEquals ("sig S0 extends E {} { E = none }\n" + 
		      "sig S1 extends E {} { a = b }\n" +
		      "one sig T0 extends Triple {} {\n" +
		      "\tpermit = S0\n" +
		      "\tdeny = S1\n" +
		      "\terror = E\n" +
		      "}\n", out.getFacts ());
    }

    public void testSizeFunction () {
	out.start ();
	new Triple (new FunctionCallPredicate (xp + "string-bag-size",
					       new Predicate [] { a }),
		    new FunctionCallPredicate (xp + "string-bag-size",
					       new Predicate [] { b }),
		    SimplePredicate.FALSE).walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n" +
		      "\texpr0 : E -> Integer, // size of a\n" +
		      "\texpr1 : E -> Integer // size of b\n" +
		      "}\n",
		      out.getFunctions ());
	assertEquals ("one sig T0 extends Triple {} {\n" +
		      "\tpermit = this.(Functions.expr0)\n" +
		      "\tdeny = this.(Functions.expr1)\n" +
		      "\terror = none\n" +
		      "}\n", out.getFacts ());
    }

    public void testInclusionFunction () {
	out.start ();
	new Triple (new FunctionCallPredicate (xp + "string-is-in",
					       new Predicate [] { a, b }),
		    new FunctionCallPredicate (xp + "string-is-in",
					       new Predicate [] { b, c }),
		    SimplePredicate.FALSE).walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n}\n", out.getFunctions ());
	assertEquals ("sig S0 extends E {} { a in b }\n" +
		      "sig S1 extends E {} { b in c }\n" +
		      "one sig T0 extends Triple {} {\n" +
		      "\tpermit = S0\n" +
		      "\tdeny = S1\n" +
		      "\terror = none\n" +
		      "}\n", out.getFacts ());
    }

    public void testSetCreationFunction () {
	out.start ();
	new Triple (new FunctionCallPredicate
		    (xp + "string-bag",
		     new Predicate [] {
			new FunctionCallPredicate (xp + "string-bag-size",
						   new Predicate [] { a })
		    }),
		    SimplePredicate.TRUE,
		    SimplePredicate.TRUE).walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n" +
		      "\texpr0 : E -> Integer // size of a\n" +
		      "}\n",
		      out.getFunctions ());
	assertEquals ("one sig T0 extends Triple {} {\n" +
		      "\tpermit = this.(Functions.expr0)\n" +
		      "\tdeny = E\n" +
		      "\terror = E\n" +
		      "}\n", out.getFacts ());
    }

    public void testSetManipulationFunctions () {
	out.start ();
	new Triple (new FunctionCallPredicate (xp + "string-intersection",
					       new Predicate [] { a, b })
		    .andWith (new FunctionCallPredicate
			      (xp + "integer-union",
			       new Predicate [] { a, b })),
		    new FunctionCallPredicate (xp + "double-subset",
					       new Predicate [] { a, b }),
		    new FunctionCallPredicate (xp + 
					       "date-at-least-one-member-of",
					       new Predicate [] { a, b }))
	    .walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n}\n", out.getFunctions ());
	assertEquals ("sig S0 extends E {} { a in b }\n" +
		      "sig S1 extends E {} { some a & b }\n" +
		      "one sig T0 extends Triple {} {\n" +
		      "\tpermit = (a & b) & (a + b)\n" +
		      "\tdeny = S0\n" +
		      "\terror = S1\n" +
		      "}\n", out.getFacts ());
    }

    public void testArithmeticFunctions () {
	out.start ();
	new Triple (new FunctionCallPredicate (xp +
					       "string-greater-than",
					       new Predicate [] { a, b })
		    .andWith (new FunctionCallPredicate
			      (xp + "string-greater-than-or-equal",
			       new Predicate [] { a, b })),
		    new FunctionCallPredicate (FunctionVisitor.xacmlprefix +
					       "string-less-than",
					       new Predicate [] { a, b }),
		    new FunctionCallPredicate (FunctionVisitor.xacmlprefix +
					       "string-less-than-or-equal",
					       new Predicate [] { a, b }))
	    .walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n}\n", out.getFunctions ());
	assertEquals ("sig S0 extends E {} { types.gt (a, b) }\n" +
		      "sig S1 extends E {} { types.gte (a, b) }\n" +
		      "sig S2 extends E {} { types.lt (a, b) }\n" +
		      "sig S3 extends E {} { types.lte (a, b) }\n" +
		      "one sig T0 extends Triple {} {\n" +
		      "\tpermit = S0 & S1\n" +
		      "\tdeny = S2\n" +
		      "\terror = S3\n" +
		      "}\n", out.getFacts ());
    }

    public void testLogicalFunctions () {
	out.start ();
	new Triple (new FunctionCallPredicate (xp + "and",
					       new Predicate [] { a, b, c }),
		    new FunctionCallPredicate (xp + "or",
					       new Predicate [] { a, b, c }),
		    new FunctionCallPredicate (xp + "not",
					       new Predicate [] { a }))
	    .walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n}\n", out.getFunctions ());
	assertEquals ("one sig T0 extends Triple {} {\n" +
		      "\tpermit = a & b & c\n" +
		      "\tdeny = a + b + c\n" +
		      "\terror = E - a\n" +
		      "}\n", out.getFacts ());
    }

    public void testExistential () {
	out.start ();
	new ExistentialPredicate (xp + "string-equal",
				  b, a).walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n}\n", out.getFunctions ());
	assertEquals ("sig S0 extends E {} { b in a }\n",
		      out.getFacts ());
	reset ();
	out.start ();
	new ExistentialPredicate (xp + "xpath-node-match",
				  b, a).walk (out);
	out.end ();
	assertEquals ("one sig Functions {\n" +
		      "\texpr0 : E -> Bool // xpathnodematch (b, a)\n" +
		      "}\n",
		      out.getFunctions ());
	assertEquals ("sig S1 extends E {} { this.(Functions.expr0) " +
		      "= True }\n",
		      out.getFacts ());
    }
    
    public void testNullStuff () {
	out.start ();
	Deny.DENY.walk (out);
	Permit.PERMIT.walk (out);
	new Scope (Deny.DENY, a).walk (out);
	new Error (Deny.DENY, a).walk (out);
	SimplePredicate.TRUE.walk (out);
	SimplePredicate.FALSE.walk (out);
	new EnvironmentalPredicate ("string", "foo").walk (out);
	new ConstantValuePredicate ("string", "foo").walk (out);
	out.end ();
	assertEquals (out.getFunctions (), "one sig Functions {\n}\n");
	assertEquals (out.getFacts (), "");
    }
}
// arch-tag: BB83F7DE-32CF-11D8-8724-000A957284DA
