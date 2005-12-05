package org.sigwinch.xacml.output.alloycnf;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.HashMap;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

import org.sigwinch.xacml.tree.*;
import org.sigwinch.xacml.tree.Error;

/**
 * ToplevelOutputTest.java
 * 
 * 
 * Created: Sat Nov 15 23:02:54 2003
 * 
 * @author Graham Hughes
 * @version 0.1
 */

public class ToplevelOutputTest extends TestCase {
    VariableReference a, b, c;
    OutputVisitor out;
    StringWriter stream;
    HashMap map;

    public static Test suite() {
	return new TestSuite(OutputTest.class);
    }

    protected void reset () {
	stream = new StringWriter ();
	map = new HashMap ();
	out = new OutputVisitor (new PrintWriter (stream), 0, map);
	map.put (a, "a");
	map.put (b, "b");
	map.put (c, "c");
	Predicate.reset ();
    }
    
    protected void setUp() {
	a = new VariableReference ("a");
	b = new VariableReference ("b");
	c = new VariableReference ("c");
	reset ();
    }
    
    public void testTriples () {
	new Triple (a, b, c).walk (out);
	new Triple (a, b, c).walk (out);
	assertEquals ("one sig T0 extends Triple {} {\n" +
		      "\tpermit = a\n" +
		      "\tdeny = b\n" +
		      "\terror = c\n" +
		      "}\n" +
		      "one sig T1 extends Triple {} {\n" +
		      "\tpermit = a\n" +
		      "\tdeny = b\n" +
		      "\terror = c\n" +
		      "}\n",
		      stream.toString ());
	reset ();
	map.put (new ExistentialPredicate (FunctionVisitor.xacmlprefix + 
					   "string-equal", b, 
					   a), "FROBOTZ");
	new Triple (a, b, 
		    new ExistentialPredicate (FunctionVisitor.xacmlprefix + 
					      "string-equal", b, 
					      a)).walk (out);
	assertEquals ("one sig T0 extends Triple {} {\n" +
		      "\tpermit = a\n" +
		      "\tdeny = b\n" +
		      "\terror = FROBOTZ\n" +
		      "}\n", stream.toString ());
	reset ();
	map.put (new FunctionCallPredicate
		 (FunctionVisitor.xacmlprefix + "not",
		  new Predicate [] {
		      new ExistentialPredicate
		      (FunctionVisitor.xacmlprefix + "string-equal", b, 
		       a)}), "QUUX");
	new Triple (a, b, 
		    new FunctionCallPredicate
		    (FunctionVisitor.xacmlprefix + "not",
		     new Predicate [] {
			 new ExistentialPredicate
			 (FunctionVisitor.xacmlprefix + "string-equal", b, 
			  a)})).walk (out);
	assertEquals ("one sig T0 extends Triple {} {\n" +
		      "\tpermit = a\n" +
		      "\tdeny = b\n" +
		      "\terror = QUUX\n" +
		      "}\n", stream.toString ());
    }

    public void testInvalidRules () {
	Triple t = new Triple (a, b, c);
	try {
	    Permit.PERMIT.walk (out);
	    fail ("Didn't throw an error!");
	} catch (IllegalArgumentException e) {
	}
	try {
	    Deny.DENY.walk (out);
	    fail ("Didn't throw an error!");
	} catch (IllegalArgumentException e) {
	}
	try {
	    new Scope (t, a).walk (out);
	    fail ("Didn't throw an error!");
	} catch (IllegalArgumentException e) {
	}
	try {
	    new Error (t, a).walk (out);
	    fail ("Didn't throw an error!");
	} catch (IllegalArgumentException e) {
	}
	try {
	    new PermitOverridesRule (t, t).walk (out);
	    fail ("Didn't throw an error!");
	} catch (IllegalArgumentException e) {
	}
	try {
	    new DenyOverridesRule (t, t).walk (out);
	    fail ("Didn't throw an error!");
	} catch (IllegalArgumentException e) {
	}
	try {
	    new OnlyOneRule (t, t).walk (out);
	    fail ("Didn't throw an error!");
	} catch (IllegalArgumentException e) {
	}
	try {
	    new FirstApplicableRule (t, t).walk (out);
	    fail ("Didn't throw an error!");
	} catch (IllegalArgumentException e) {
	}
    }
}
