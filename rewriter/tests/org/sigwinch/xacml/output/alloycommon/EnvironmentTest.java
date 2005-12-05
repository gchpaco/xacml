package org.sigwinch.xacml.output.alloycommon;

import junit.framework.*;

import org.sigwinch.xacml.tree.VariableReference;
import java.io.StringWriter;
import java.io.PrintWriter;
import org.sigwinch.xacml.tree.EnvironmentalPredicate;

/**
 * EnvironmentTest.java
 * 
 * 
 * Created: Mon Nov 17 16:39:35 2003
 * 
 * @author Graham Hughes
 * @version 1.0
 */

public class EnvironmentTest extends TestCase {
    VariableReference a, b, c;

    EnvironmentVisitor out;

    StringWriter stream;

    public static Test suite() {
        return new TestSuite(EnvironmentTest.class);
    }

    protected void reset() {
        stream = new StringWriter();
        out = new EnvironmentVisitor(new PrintWriter(stream));
    }

    @Override
    protected void setUp() {
        reset();
        a = new VariableReference("a");
        b = new VariableReference("b");
        c = new VariableReference("c");
    }

    public void testNullOutput() {
        out.start();
        a.walk(out);
        out.end();
        assertEquals("one sig E {\n" + "}\n", stream.toString());
    }

    public void testWillOutput() {
        out.start();
        new EnvironmentalPredicate("http://www.w3.org/2001/XMLSchema#string",
                "foo").walk(out);
        out.end();
        assertEquals("one sig E {\n" + "\tenv0 : some String // foo\n" + "}\n",
                stream.toString());
    }

    public void testRepeatedOutput() {
        out.start();
        EnvironmentalPredicate ev = new EnvironmentalPredicate(
                "http://www.w3.org/2001/XMLSchema#string", "foo");
        ev.walk(out);
        ev.walk(out);
        out.end();
        assertEquals("one sig E {\n" + "\tenv0 : some String // foo\n" + "}\n",
                stream.toString());
    }
}
