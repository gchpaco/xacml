package org.sigwinch.xacml.output.set;
import junit.framework.*;

import org.sigwinch.xacml.tree.VariableReference;
import java.io.StringWriter;
import org.sigwinch.xacml.tree.EnvironmentalPredicate;
import java.io.PrintWriter;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.FunctionVisitor;
import org.sigwinch.xacml.tree.Triple;
import org.sigwinch.xacml.tree.SimplePredicate;
import org.sigwinch.xacml.tree.ConstantValuePredicate;
import org.sigwinch.xacml.tree.FunctionCallPredicate;
import org.sigwinch.xacml.tree.PermitOverridesRule;
import org.sigwinch.xacml.tree.ExistentialPredicate;
import org.sigwinch.xacml.tree.Tree;

/**
 * OutputTest.java
 * 
 * 
 * Created: Mon Nov 17 20:14:24 2003
 * 
 * @author Graham Hughes
 * @version
 */

public class OutputTest extends TestCase {
    VariableReference a, b, c;
    Triple t;
    String xp;
    AlloySetOutput out;
    StringWriter stream;

    static final String prelude;

    static {
	prelude = "module foo\n" +
	    "open util/boolean\n" +
	    "open util/ordering[Type] as types\n" +
	    "abstract sig Triple {\n" +
	    "\tpermit : lone E,\n" +
	    "\tdeny : lone E,\n" +
	    "\terror : lone E\n" +
	    "}\n" +
	    "abstract sig Type {}\n";
    }
	
    public static Test suite() {
	return new TestSuite(OutputTest.class);
    }

    protected void reset () {
	stream = new StringWriter ();
	out = new AlloySetOutput (new PrintWriter (stream), 2.0);
	Predicate.reset ();
    }
    
    protected void setUp() {
	a = new VariableReference ("a");
	b = new VariableReference ("b");
	c = new VariableReference ("c");
	xp = FunctionVisitor.xacmlprefix;
	// To make sure that the element positions in the triples
	// won't change constantly, we need to reset the counts now.
	Predicate.reset ();
	t = new Triple
	    (new EnvironmentalPredicate ("frob", "foo")
	     .andWith (a)
	     .andWith (SimplePredicate.TRUE)
	     .andWith (new ConstantValuePredicate ("frob", "quux"))
	     .andWith (new ConstantValuePredicate 
		       ("http://www.w3.org/2001/XMLSchema#date", "fred"))
	     .andWith (new ConstantValuePredicate
		       ("http://www.w3.org/2001/XMLSchema#boolean", "barnux"))
	     .andWith (new ConstantValuePredicate 
		       ("http://www.w3.org/TR/2002/WD-xquery-" +
			"operators-20020816#yearMonthDuration", 
			"barney"))
	     .andWith (new FunctionCallPredicate ("foo",
						  new Predicate [] {a}))
	     .andWith (new FunctionCallPredicate (xp + "string-equal", 
						  new Predicate [] {a, b}))
	     .andWith (new FunctionCallPredicate
		       (xp + "integer-equal",
			new Predicate [] {
			   new FunctionCallPredicate (xp + "string-bag-size", 
						      new Predicate [] {a}),
			   new ConstantValuePredicate
			   ("http://www.w3.org/2001/XMLSchema#integer", "2")
		       })),
	     b, c);
	reset ();
    }
    
    public void testFullOutput () {
	out.output (t);
	assertEquals (prelude +
		      "sig Date extends Type {}\n" +
		      "sig Integer extends Type {}\n" +
		      "sig YearMonthDuration extends Type {}\n" +
		      "sig frob extends Type {}\n" +
		      "one sig E {\n" +
		      "\tenv0 : some frob // foo\n" +
		      "}\n" +
		      "one sig S {\n" +
		      "\tstatic0 : one frob, // quux\n" +
		      "\tstatic1 : one Date, // fred\n" +
		      "\tstatic2 : one Bool, // barnux\n" +
		      "\tstatic3 : one YearMonthDuration, // barney\n" +
		      "\tstatic4 : one Integer // 2\n" +
		      "}\n" +
		      "one sig Functions {\n" +
		      "\texpr0 : E -> Type, // foo (a)\n" +
		      "\texpr2 : E -> Integer // size of a\n" +
		      "}\n" +
		      "sig S1 extends E {} { a = b }\n" +
		      "sig S3 extends E {} { this.(Functions.expr2) = " +
		      "S.static4 }\n" +
		      "one sig T0 extends Triple {} {\n" +
		      "\tpermit = env0 & a & S.static0 & S.static1 & " +
		      "S.static2 & S.static3 & this.(Functions.expr0) & " + 
		      "S1 & S3\n" +
		      "\tdeny = b\n" +
		      "\terror = c\n" +
		      "}\n" +
		      "pred T0OK () {\n" +
		      "\tsome T0.permit or some T0.deny or some T0.error\n" +
		      "}\n" +
		      "run T0OK for 2 but 2 Bool, " +
		      "1 Triple, 1 Date, 2 Integer, 1 YearMonthDuration, " +
		      "3 frob, 7 Type\n", stream.toString ());
    }

    public void testRepeatedOutput () {
	Tree unified = new PermitOverridesRule (t, t);
	out.preamble (unified);
	out.write (t);
	out.write (t);
	out.postamble ();
	assertEquals (prelude + 
		      "sig Date extends Type {}\n" +
		      "sig Integer extends Type {}\n" +
		      "sig YearMonthDuration extends Type {}\n" +
		      "sig frob extends Type {}\n" +
		      "one sig E {\n" +
		      "\tenv0 : some frob // foo\n" +
		      "}\n" +
		      "one sig S {\n" +
		      "\tstatic0 : one frob, // quux\n" +
		      "\tstatic1 : one Date, // fred\n" +
		      "\tstatic2 : one Bool, // barnux\n" +
		      "\tstatic3 : one YearMonthDuration, // barney\n" +
		      "\tstatic4 : one Integer // 2\n" +
		      "}\n" +
		      "one sig Functions {\n" +
		      "\texpr0 : E -> Type, // foo (a)\n" +
		      "\texpr2 : E -> Integer // size of a\n" +
		      "}\n" +
		      "sig S1 extends E {} { a = b }\n" +
		      "sig S3 extends E {} { this.(Functions.expr2) = " +
		      "S.static4 }\n" +
		      "one sig T0 extends Triple {} {\n" +
		      "\tpermit = env0 & a & S.static0 & S.static1 & " +
		      "S.static2 & S.static3 & this.(Functions.expr0) & " +
		      "S1 & S3\n" +
		      "\tdeny = b\n" +
		      "\terror = c\n" +
		      "}\n" +
		      "one sig T1 extends Triple {} {\n" +
		      "\tpermit = env0 & a & S.static0 & S.static1 & " +
		      "S.static2 & S.static3 & this.(Functions.expr0) & " +
		      "S1 & S3\n" +
		      "\tdeny = b\n" +
		      "\terror = c\n" +
		      "}\n" +
		      "assert Subset {\n" +
		      "\tT0.permit in T1.permit\n" +
		      "\tT0.deny in T1.deny\n" +
		      "\tT0.error in T1.error\n" +
		      "}\n" +
		      "pred T0OK () {\n" +
		      "\tsome T0.permit or some T0.deny or some T0.error\n" +
		      "}\n" +
		      "pred T1OK () {\n" +
		      "\tsome T1.permit or some T1.deny or some T1.error\n" +
		      "}\n" +
		      "run T0OK for 2 but 2 Bool, " +
		      "2 Triple, 1 Date, 2 Integer, 1 YearMonthDuration, " +
		      "3 frob, 7 Type\n" +
		      "run T1OK for 2 but 2 Bool, " +
		      "2 Triple, 1 Date, 2 Integer, 1 YearMonthDuration, " +
		      "3 frob, 7 Type\n" +
		      "check Subset for 2 but 2 Bool, " +
		      "2 Triple, 1 Date, 2 Integer, 1 YearMonthDuration, " +
		      "3 frob, 7 Type\n", stream.toString ());
    }

    public void testHiddenType () {
	reset ();
	t = new Triple
	    (new FunctionCallPredicate
	     (xp + "date-less-than",
	      new Predicate [] {
		  a,
		  new ConstantValuePredicate
		  ("http://www.w3.org/2001/XMLSchema#date", "fred"),
	      }), b, c);
	out.output (t);
	assertEquals (prelude +
		      "sig Date extends Type {}\n" +
		      "one sig E {\n" +
		      "}\n" +
		      "one sig S {\n" +
		      "\tstatic0 : one Date // fred\n" +
		      "}\n" +
		      "one sig Functions {\n" +
		      "}\n" +
		      "sig S0 extends E {} { types.lt (a, S.static0) }\n" +
		      "one sig T0 extends Triple {} {\n" +
		      "\tpermit = S0\n" +
		      "\tdeny = b\n" +
		      "\terror = c\n" +
		      "}\n" +
		      "pred T0OK () {\n" +
		      "\tsome T0.permit or some T0.deny or some T0.error\n" +
		      "}\n" +
		      "run T0OK for 2 but 2 Bool, " +
		      "1 Triple, 1 Date, 1 Type\n", stream.toString ());
    }

    public void testExistential () {
	t = new Triple
	    (new ExistentialPredicate (xp + "xpath-node-match", a, b),
	     b, c);
	out.output (t);
	assertEquals (prelude +
		      "one sig E {\n" +
		      "}\n" +
		      "one sig S {\n" +
		      "}\n" +
		      "one sig Functions {\n" +
		      "\texpr0 : E -> Bool // xpathnodematch (a, b)\n" +
		      "}\n" +
		      "sig S1 extends E {} { this.(Functions.expr0) = " +
		      "True }\n" +
		      "one sig T0 extends Triple {} {\n" +
		      "\tpermit = S1\n" +
		      "\tdeny = b\n" +
		      "\terror = c\n" +
		      "}\n" +
		      "pred T0OK () {\n" +
		      "\tsome T0.permit or some T0.deny or some T0.error\n" +
		      "}\n" +
		      "run T0OK for 2 but 2 Bool, " +
		      "1 Triple\n", stream.toString ());
    }
}
