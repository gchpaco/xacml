package org.sigwinch.xacml.output.alloycommon;

import junit.framework.*;

import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.VariableReference;
import java.io.StringWriter;
import java.io.PrintWriter;
import org.sigwinch.xacml.tree.ConstantValuePredicate;

/**
 * ConstantTest.java
 * 
 * 
 * Created: Mon Nov 17 17:46:16 2003
 * 
 * @author Graham Hughes
 * @version
 */

public class ConstantTest extends TestCase {
    VariableReference a, b, c;

    ConstantVisitor out;

    StringWriter stream;

    public static Test suite() {
        return new TestSuite(ConstantTest.class);
    }

    protected void reset() {
        Predicate.reset();
        stream = new StringWriter();
        out = new ConstantVisitor(new PrintWriter(stream));
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
        assertEquals("one sig S {\n" + "}\n", stream.toString());
    }

    public void testWillOutput() {
        out.start();
        ConstantValuePredicate cv = new ConstantValuePredicate(
                "http://www.w3.org/2001/XMLSchema#string", "foo");
        cv.walk(out);
        assertEquals(0, cv.getUniqueId());
        out.end();
        assertEquals("one sig S {\n" + "\tstatic0 : one String // foo\n"
                + "}\n", stream.toString());
    }

    public void testRepeatedOutput() {
        out.start();
        ConstantValuePredicate cv = new ConstantValuePredicate(
                "http://www.w3.org/2001/XMLSchema#string", "foo");
        assertEquals(0, cv.getUniqueId());
        cv.walk(out);
        cv.walk(out);
        out.end();
        assertEquals("one sig S {\n" + "\tstatic0 : one String // foo\n"
                + "}\n", stream.toString());
    }
}
