package org.sigwinch.xacml.output;

import junit.framework.*;

import org.sigwinch.xacml.tree.VariableReference;
import java.io.StringWriter;
import java.io.PrintWriter;
import org.sigwinch.xacml.tree.FunctionVisitor;
import org.sigwinch.xacml.tree.FunctionCallPredicate;
import org.sigwinch.xacml.tree.Predicate;

/**
 * UnhandledTest.java Created: Mon Nov 17 18:06:24 2003
 * 
 * @author Graham Hughes
 * @version
 */

public class UnhandledTest extends TestCase {
    VariableReference a, b, c;

    UnhandledVisitor out;

    StringWriter stream;

    public static Test suite() {
        return new TestSuite(UnhandledTest.class);
    }

    protected void reset() {
        stream = new StringWriter();
        out = new UnhandledVisitor(new PrintWriter(stream));
        Predicate.reset();
    }

    @Override
    protected void setUp() {
        a = new VariableReference("a");
        b = new VariableReference("b");
        c = new VariableReference("c");
        reset();
    }

    public void testNullOutput() {
        out.start();
        a.walk(out);
        out.end();
        assertEquals("one sig X {\n" + "}\n", stream.toString());
    }

    public void testFunctionsOutput() {
        String xp = FunctionVisitor.xacmlprefix;
        out.start();
        new FunctionCallPredicate("foo", new Predicate[] { a, b, c }).walk(out);
        out.end();
        out.start();
        new FunctionCallPredicate(xp + "string-bag-size", new Predicate[] { a })
                .walk(out);
        out.end();
        out.start();
        new FunctionCallPredicate(xp + "string-greater-than", new Predicate[] {
                a, b }).walk(out);
        out.end();
        out.start();
        new FunctionCallPredicate(xp + "string-greater-than-or-equal",
                new Predicate[] { a, b }).walk(out);
        out.end();
        out.start();
        new FunctionCallPredicate(xp + "string-less-than", new Predicate[] { a,
                b }).walk(out);
        out.end();
        out.start();
        new FunctionCallPredicate(xp + "string-less-than-or-equal",
                new Predicate[] { a, b }).walk(out);
        out.end();
        assertEquals("one sig X {\n" + "\texpr0 : one Bool // foo\n"
                + "}\none sig X {\n" + "\texpr1 : one Integer // " + xp
                + "string-bag-size\n" + "}\none sig X {\n"
                + "\texpr2 : one Bool // " + xp + "string-greater-than\n"
                + "}\none sig X {\n" + "\texpr3 : one Bool // " + xp
                + "string-greater-than-or-equal\n" + "}\none sig X {\n"
                + "\texpr4 : one Bool // " + xp + "string-less-than\n"
                + "}\none sig X {\n" + "\texpr5 : one Bool // " + xp
                + "string-less-than-or-equal\n" + "}\n", stream.toString());
    }

    public void testRepeatedFunction() {
        out.start();
        FunctionCallPredicate fp = new FunctionCallPredicate("foo",
                new Predicate[] { a, b, c });
        fp.walk(out);
        fp.walk(out);
        out.end();
        assertEquals("one sig X {\n" + "\texpr0 : one Bool // foo\n" + "}\n",
                stream.toString());
    }
}
