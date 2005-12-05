package org.sigwinch.xacml.output.alloycnf;
import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

import org.sigwinch.xacml.tree.*;
import org.sigwinch.xacml.tree.Error;

public class BreakdownTest extends TestCase {
    VariableReference a, b, c;
    BreakdownVisitor out;
    final String xp = FunctionVisitor.xacmlprefix;

    public static Test suite() {
	return new TestSuite(BreakdownTest.class);
    }

    protected void reset () {
	out = new BreakdownVisitor ();
	Predicate.reset ();
    }

    @Override
    protected void setUp() {
	a = new VariableReference ("a");
	b = new VariableReference ("b");
	c = new VariableReference ("c");
	reset ();
    }

    public void testNullStuff () {
	Deny.DENY.walk (out);
	Permit.PERMIT.walk (out);
	new Scope (Deny.DENY, a).walk (out);
	new Error (Deny.DENY, a).walk (out);
	new Triple (a, b, c).walk (out);
	SimplePredicate.TRUE.walk (out);
	SimplePredicate.FALSE.walk (out);
	new EnvironmentalPredicate ("string", "foo").walk (out);
	new ConstantValuePredicate ("string", "foo").walk (out);
	assertEquals (out.getDecls (), "");
	assertEquals (out.getFacts (), "");
    }

    public void testAnd () {
	a.andWith (b).walk (out);
	b.andWith (c).walk (out);
	a.andWith (b).andWith (c).walk (out);
	out.end ();
	assertEquals ("\tand0 : one Bool,\n" +
		      "\tand1 : one Bool,\n" +
		      "\tand2 : one Bool\n",
		      out.getDecls ());
	assertEquals ("\tX.and0 = And (a, b)\n" +
		      "\tX.and1 = And (b, c)\n" +
		      "\tX.and2 = And (X.and0, c)\n",
		      out.getFacts ());
    }

    public void testOr () {
	a.orWith (b).walk (out);
	b.orWith (c).walk (out);
	a.orWith (b).orWith (c).walk (out);
	out.end ();
	assertEquals ("\tor0 : one Bool,\n" +
		      "\tor1 : one Bool,\n" +
		      "\tor2 : one Bool\n",
		      out.getDecls ());
	assertEquals ("\tX.or0 = Or (a, b)\n" +
		      "\tX.or1 = Or (b, c)\n" +
		      "\tX.or2 = Or (X.or0, c)\n",
		      out.getFacts ());
    }

    public void testSole () {
	new SolePredicate (a).walk (out);
	out.end ();
	assertEquals ("\tsole0 : one Bool\n",
		      out.getDecls ());
	assertEquals ("\tX.sole0 = if (sole a) then True else False\n",
		      out.getFacts ());
    }

    public void testReferences () {
	new EnvironmentalPredicate ("string", "foo")
	    .andWith (new ConstantValuePredicate ("string", "foo"))
	    .walk (out);
	out.end ();
	assertEquals ("\tand0 : one Bool\n",
		      out.getDecls ());
	assertEquals ("\tX.and0 = And (E.env0, S.static0)\n",
		      out.getFacts ());
    }

    public void testStupidFunction () {
	new FunctionCallPredicate ("foo", new Predicate [] { a, b, c })
	    .andWith (new FunctionCallPredicate ("foo",
						 new Predicate [] { a, b, c }))
	    .orWith (new FunctionCallPredicate ("foo",
						new Predicate [] { b }))
	    .walk (out);
	out.end ();
	assertEquals ("\texpr0 : one Bool, // foo\n" +
		      "\tand1 : one Bool,\n" +
		      "\texpr2 : one Bool, // foo\n" +
		      "\tor3 : one Bool\n",
		      out.getDecls ());
	assertEquals ("\tX.and1 = And (X.expr0, X.expr0)\n" +
		      "\tX.or3 = Or (X.and1, X.expr2)\n",
		      out.getFacts ());
    }

    public void testEqualsFunction () {
	new FunctionCallPredicate (xp + "string-equal",
				   new Predicate [] { SimplePredicate.TRUE,
						      SimplePredicate.FALSE })
	    .walk (out);
	new FunctionCallPredicate (xp + "string-set-equals",
				   new Predicate [] { a, b })
	    .walk (out);
	out.end ();
	assertEquals ("\texpr0 : one Bool,\n" +
		      "\texpr1 : one Bool\n",
		      out.getDecls ());
	assertEquals ("\tX.expr0 = Eq (True, False)\n" +
		      "\tX.expr1 = Eq (a, b)\n",
		      out.getFacts ());
    }

    public void testSizeFunction () {
	new FunctionCallPredicate (xp + "string-bag-size",
				   new Predicate [] { a })
	    .walk (out);
	out.end ();
	assertEquals ("\texpr0 : one Integer // " + xp +
		      "string-bag-size\n",
		      out.getDecls ());
	assertEquals ("", out.getFacts ());
    }

    public void testInclusionFunction () {
	new FunctionCallPredicate (FunctionVisitor.xacmlprefix +
				   "string-is-in",
				   new Predicate [] { a, b })
	    .walk (out);
	out.end ();
	assertEquals ("\texpr0 : one Bool\n",
		      out.getDecls ());
	assertEquals ("\tX.expr0 = In (a, b)\n", 
		      out.getFacts ());
    }

    public void testSetCreationFunction () {
	new FunctionCallPredicate
	    (FunctionVisitor.xacmlprefix + "string-bag",
	     new Predicate [] {
		 new FunctionCallPredicate (FunctionVisitor.xacmlprefix +
					    "string-bag-size",
					    new Predicate [] { a })
	     })
	    .walk (out);
	out.end ();
	assertEquals ("\texpr0 : one Integer // " + xp + 
		      "string-bag-size\n",
		      out.getDecls ());
	assertEquals ("", out.getFacts ());
    }

    public void testSetManipulationFunctions () {
	new FunctionCallPredicate (xp + "string-intersection",
				   new Predicate [] { a, b })
	    .walk (out);
	new FunctionCallPredicate (xp + "integer-union",
				   new Predicate [] { a, b })
	    .walk (out);
	new FunctionCallPredicate (xp + "double-subset",
				   new Predicate [] { a, b })
	    .walk (out);
	new FunctionCallPredicate (xp + "date-at-least-one-member-of",
				   new Predicate [] { a, b })
	    .walk (out);
	out.end ();
	assertEquals ("\texpr0 : some String,\n" +
		      "\texpr1 : some Integer,\n" +
		      "\texpr2 : one Bool,\n" +
		      "\texpr3 : one Bool\n",
		      out.getDecls ());
	assertEquals ("\tX.expr0 = a & b\n" +
		      "\tX.expr1 = a + b\n" +
		      "\tX.expr2 = In (a, b)\n" +
		      "\tX.expr3 = AtLeastOne (a, b)\n",
		      out.getFacts ());
    }

    public void testArithmeticFunctions () {
	new FunctionCallPredicate (FunctionVisitor.xacmlprefix +
				   "string-greater-than",
				   new Predicate [] { a, b })
	    .walk (out);
	new FunctionCallPredicate (FunctionVisitor.xacmlprefix +
				   "string-greater-than-or-equal",
				   new Predicate [] { a, b })
	    .walk (out);
	new FunctionCallPredicate (FunctionVisitor.xacmlprefix +
				   "string-less-than",
				   new Predicate [] { a, b })
	    .walk (out);
	new FunctionCallPredicate (FunctionVisitor.xacmlprefix +
				   "string-less-than-or-equal",
				   new Predicate [] { a, b })
	    .walk (out);
	out.end ();
	assertEquals ("\texpr0 : one Bool,\n" +
		      "\texpr1 : one Bool,\n" +
		      "\texpr2 : one Bool,\n" +
		      "\texpr3 : one Bool\n",
		      out.getDecls ());
	assertEquals ("\tX.expr0 = if types.gt (a, b) then True else False\n" +
		      "\tX.expr1 = if types.gte (a, b) then True else False\n" +
		      "\tX.expr2 = if types.lt (a, b) then True else False\n" +
		      "\tX.expr3 = if types.lte (a, b) then True else False\n",
		      out.getFacts ());
    }

    public void testLogicalFunctions () {
	new FunctionCallPredicate (FunctionVisitor.xacmlprefix + "and",
				   new Predicate [] { a, b, c })
	    .walk (out);
	new FunctionCallPredicate (FunctionVisitor.xacmlprefix + "or",
				   new Predicate [] { a, b, c })
	    .walk (out);
	new FunctionCallPredicate (FunctionVisitor.xacmlprefix + "not",
				   new Predicate [] { a })
	    .walk (out);
	out.end ();
	assertEquals ("\tand0 : one Bool,\n" +
		      "\tand1 : one Bool,\n" +
		      "\tor2 : one Bool,\n" +
		      "\tor3 : one Bool,\n" +
		      "\tnot4 : one Bool\n",
		      out.getDecls ());
	assertEquals ("\tX.and0 = And (a, b)\n" +
		      "\tX.and1 = And (X.and0, c)\n" +
		      "\tX.or2 = Or (a, b)\n" +
		      "\tX.or3 = Or (X.or2, c)\n" +
		      "\tX.not4 = BoolNot (a)\n",
		      out.getFacts ());
    }

    public void testExistential () {
	new ExistentialPredicate (xp + "string-equal",
				  b, a).walk (out);
	new FunctionCallPredicate
	    (xp + "not",
	     new Predicate [] {
		 new ExistentialPredicate (xp + "string-equal",
					   b, a)
	     }).walk (out);
	new ExistentialPredicate (xp + "xpath-node-match",
				  b, a).walk (out);
	out.end ();
	assertEquals ("\tenv0 : some String,\n" +
		      "\texpr1 : one Bool,\n" +
		      "\tnot2 : one Bool,\n" +
		      "\tenv3 : some String, // " + xp + "xpath-node-match\n" +
		      "\texpr4 : one Bool\n",
		      out.getDecls ());
	assertEquals ("\tall x: X.env0 | x in a && Eq (x, b) = True\n" +
		      "\tX.expr1 = if (some X.env0) then True else False\n" +
		      "\tX.not2 = BoolNot (X.expr1)\n" +
		      "\tX.env3 in a\n" +
		      "\tX.expr4 = if (some X.env3) then True else False\n",
		      out.getFacts ());
    }

    public void testTriple () {
	new Triple (a.andWith (b), c, c).walk (out);
	new Triple (a.andWith (b), c, c).walk (out);
	out.end ();
	assertEquals ("Hash codes should be same",
		      Integer.toString (a.andWith (b).hashCode ()),
		      Integer.toString (a.andWith (b).hashCode ()));
	assertEquals ("\tand0 : one Bool\n",
		      out.getDecls ());
	assertEquals ("\tX.and0 = And (a, b)\n",
		      out.getFacts ());
    }
}
