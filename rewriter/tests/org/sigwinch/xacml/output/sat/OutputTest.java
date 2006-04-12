/*
 * Created on May 28, 2005
 */
package org.sigwinch.xacml.output.sat;

import java.io.PrintWriter;
import java.io.StringWriter;

import junit.framework.TestCase;

import org.sigwinch.xacml.OutputConfiguration;
import org.sigwinch.xacml.tree.ConstantValuePredicate;
import org.sigwinch.xacml.tree.EnvironmentalPredicate;
import org.sigwinch.xacml.tree.FunctionCallPredicate;
import org.sigwinch.xacml.tree.FunctionVisitor;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.SimplePredicate;
import org.sigwinch.xacml.tree.Triple;

/**
 * @author graham
 */
public class OutputTest extends TestCase {

    private StringWriter stream;

    private AlloySatOutput out;

    private FunctionCallPredicate stringIn;

    private ConstantValuePredicate booleanConstant;

    private FunctionCallPredicate intEqual;

    public static void main(String[] args) {
        junit.textui.TestRunner.run(OutputTest.class);
    }

    @Override
    protected void setUp() {
        // ConstantValuePredicate a = new ConstantValuePredicate
        // ("http://www.w3.org/2001/XMLSchema#string", "a");
        // ConstantValuePredicate b = new ConstantValuePredicate
        // ("http://www.w3.org/2001/XMLSchema#string", "b");
        EnvironmentalPredicate baz = new EnvironmentalPredicate(
                "http://www.w3.org/2001/XMLSchema#string", "baz");
        stream = new StringWriter();
        out = new AlloySatOutput(new PrintWriter(stream),
                new OutputConfiguration(2.0, true, true, true));
        String xp = FunctionVisitor.xacmlprefix;
        Predicate.reset();
        ConstantValuePredicate frobConstant = new ConstantValuePredicate(
                "frob", "quux");
        EnvironmentalPredicate frobSet = new EnvironmentalPredicate("frob",
                "foo");
        stringIn = new FunctionCallPredicate(xp + "string-is-in",
                new Predicate[] { frobConstant, frobSet });
        booleanConstant = new ConstantValuePredicate(
                "http://www.w3.org/2001/XMLSchema#boolean", "barnux");
        intEqual = new FunctionCallPredicate(
                xp + "integer-equal",
                new Predicate[] {
                        new FunctionCallPredicate(xp + "string-bag-size",
                                new Predicate[] { baz }),
                        new ConstantValuePredicate(
                                "http://www.w3.org/2001/XMLSchema#integer", "2") });
        /*
         * t = new Triple (stringIn .andWith (SimplePredicate.TRUE) .andWith
         * (new FunctionCallPredicate (xp + "string-equal", new Predicate []
         * {new ConstantValuePredicate ("http://www.w3.org/2001/XMLSchema#date",
         * "fred"), new ConstantValuePredicate
         * ("http://www.w3.org/TR/2002/WD-xquery-" +
         * "operators-20020816#yearMonthDuration", "barney") })) .andWith
         * (booleanConstant) .andWith (new FunctionCallPredicate (xp +
         * "string-equal", new Predicate [] {a, b})) .andWith (intEqual),
         * SimplePredicate.TRUE, SimplePredicate.FALSE);
         */
    }

    protected void shutDown() {
        Predicate.reset();
    }

    public void testSmallOutput() {
        Triple t = new Triple(booleanConstant, SimplePredicate.TRUE,
                SimplePredicate.FALSE);
        out.preamble(t);
        out.write(t);
        out.postamble();
        assertEquals("c clause_1 == 1\n" + "c clause_2 == 3\n"
                + "c const_barnux == 5\n" + "c t_d_0 == 4\n" + "c t_e_0 == 2\n"
                + "c t_p_0 == 6\n" + "p cnf 6 6\n" + "-1 -2 0\n" + "-1 3 0\n"
                + "-1 4 0\n" + "-3 -5 6 0\n" + "-3 -6 5 0\n" + "1 0\n", stream
                .toString());
    }

    public void testMediumOutput() {
        Triple t = new Triple(intEqual, booleanConstant, stringIn);
        out.preamble(t);
        out.write(t);
        out.postamble();
        assertTrue(stream.toString().indexOf("p cnf ") != -1);
    }

    public void testImplications() {
        Triple first = new Triple(booleanConstant, stringIn,
                SimplePredicate.FALSE);
        Triple second = new Triple(SimplePredicate.TRUE, booleanConstant,
                SimplePredicate.FALSE);
        out.preamble(null);
        out.write(first);
        out.write(second);
        out.postamble();
        assertEquals("c clause_1 == 1\n" + "c clause_10 == 9\n"
                + "c clause_11 == 10\n" + "c clause_2 == 5\n"
                + "c clause_3 == 6\n" + "c clause_4 == 7\n"
                + "c clause_5 == 2\n" + "c clause_6 == 12\n"
                + "c clause_7 == 17\n" + "c clause_8 == 18\n"
                + "c clause_9 == 11\n" + "c const_barnux == 14\n"
                + "c const_quux_0 == 19\n" + "c env_foo_0 == 20\n"
                + "c env_foo_1 == 21\n" + "c t_d_0 == 13\n" + "c t_d_1 == 15\n"
                + "c t_e_0 == 3\n" + "c t_e_1 == 4\n" + "c t_p_0 == 16\n"
                + "c t_p_1 == 8\n" + "p cnf 21 30\n" + "-1 -2 0\n"
                + "-1 -3 0\n" + "-1 -4 0\n" + "-1 5 0\n" + "-1 6 0\n"
                + "-1 7 0\n" + "-1 8 0\n" + "-9 -10 -11 2 0\n"
                + "-5 -12 13 0\n" + "-5 -13 12 0\n" + "-6 -14 15 0\n"
                + "-6 -15 14 0\n" + "-7 -14 16 0\n" + "-7 -16 14 0\n"
                + "-12 17 18 0\n" + "-17 -19 0\n" + "-17 12 0\n" + "-17 20 0\n"
                + "-18 12 0\n" + "-18 19 0\n" + "-18 21 0\n" + "-19 -21 18 0\n"
                + "-20 17 19 0\n" + "-15 11 0\n" + "-4 9 0\n" + "-8 10 0\n"
                + "9 3 0\n" + "10 16 0\n" + "11 13 0\n" + "1 0\n", stream
                .toString());
    }

}

// arch-tag: OutputTest.java May 28, 2005 12:57:51 AM
