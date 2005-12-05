package org.sigwinch.xacml.tree;
import junit.framework.*;
import java.io.StringWriter;
import org.sigwinch.xacml.tree.VariableReference;
import java.io.PrintWriter;
import org.sigwinch.xacml.tree.SimplePredicate;
import org.sigwinch.xacml.tree.EnvironmentalPredicate;
import org.sigwinch.xacml.tree.ConstantValuePredicate;

/**
 * LispOutputTest.java
 * 
 * 
 * Created: Sat Nov 15 23:02:54 2003
 * 
 * @author Graham Hughes
 * @version 0.1
 */

public class LispOutputTest extends TestCase {
    VariableReference a, b, c;
    LispOutputVisitor out;
    StringWriter stream;

    public static Test suite() {
	return new TestSuite(LispOutputTest.class);
    }

    protected void reset () {
	stream = new StringWriter ();
	out = new LispOutputVisitor (new PrintWriter (stream));
    }

    @Override
    protected void setUp() {
	reset ();
	a = new VariableReference ("a");
	b = new VariableReference ("b");
	c = new VariableReference ("c");
    }
    
    public void testWalkVariableReference () {
	a.walk (out);
	assertEquals ("a", stream.toString ());
    }
    
    public void testWalkSimple () {
	SimplePredicate.TRUE.walk (out);
	assertEquals ("t", stream.toString ());
	reset ();
	SimplePredicate.FALSE.walk (out);
	assertEquals ("nil", stream.toString ());
    }

    public void testSole () {
	new SolePredicate (a).walk (out);
	assertEquals ("(sole a)", stream.toString ());
    }

    public void testWalkEnvironment () {
	new EnvironmentalPredicate ("string", "foo").walk (out);
	assertEquals ("(e 0)", stream.toString ());
    }

    public void testWalkConstant () {
	new ConstantValuePredicate ("string", "foo").walk (out);
	assertEquals ("(string \"foo\")", stream.toString ());
    }

    public void testOrPredicate () {
	a.orWith (b).orWith (c).walk (out);
	assertEquals ("(or a b c)", stream.toString ());
    }

    public void testAndPredicate () {
	a.andWith (b).andWith (c).walk (out);
	assertEquals ("(and a b c)", stream.toString ());
    }
}
