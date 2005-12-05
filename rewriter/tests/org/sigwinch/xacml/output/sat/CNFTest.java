/*
 * Created on May 25, 2005
 */
package org.sigwinch.xacml.output.sat;

import org.sigwinch.xacml.tree.VariableReference;

import junit.framework.TestCase;

/**
 * @author graham
 */
public class CNFTest extends TestCase {

    private VariableReference a;
    private VariableReference b;
    private VariableReference c;

    @Override
    public void setUp () {
        a = new VariableReference ("a");
        b = new VariableReference ("b");
        c = new VariableReference ("c");
    }

    public static void main (String[] args) {
        junit.textui.TestRunner.run (CNFTest.class);
    }

    public void testTrueFalse () {
        assertEquals (BooleanFormula.TRUE, BooleanFormula.TRUE.convertToCNF ());
        assertEquals (BooleanFormula.FALSE,
                      BooleanFormula.FALSE.convertToCNF ());
    }

    public void testVariables () {
        assertEquals (a, a.convertToCNF ());
    }

    public void testNot () {
        assertEquals (a.negate (), a.negate ().convertToCNF ());
        assertEquals (a, new Not (new Not (a)).convertToCNF ());
        assertEquals (a,
                      new Not (new Not (new Not (new Not (a)))).convertToCNF ());
    }

    public void testAnd () {
        BooleanFormula formula = new And (a, b);
        assertEquals (formula, formula.convertToCNF ());
        assertEquals (new And (new BooleanFormula[] { a, b, c }),
                      new And (formula, c).convertToCNF ());
        assertEquals (new And (new BooleanFormula[] { a, b, c }),
                      new And (new Not (new Not (formula)), c).convertToCNF ());
        assertEquals (new And (new BooleanFormula[] { a, b, c }),
                      new And (formula, new Not (new Not (c))).convertToCNF ());
        assertEquals (new And (new Or (a, c), new Or (b, c)),
                      new Or (formula, c).convertToCNF ());
        assertEquals (new And (new Or (a, c), new Or (b, c)),
                      new Or (c, formula).convertToCNF ());
    }

    public void testOr () {
        BooleanFormula formula = new Or (a, b);
        assertEquals (formula, formula.convertToCNF ());
        assertEquals (new Or (new BooleanFormula[] { a, b, c }),
                      new Or (formula, c).convertToCNF ());
        assertEquals (new Or (new BooleanFormula[] { a, b, c }),
                      new Or (new Not (new Not (formula)), c).convertToCNF ());
        assertEquals (new Or (new BooleanFormula[] { a, b, c }),
                      new Or (formula, new Not (new Not (c))).convertToCNF ());
        assertEquals (new And (formula, b),
                      new And (formula, b).convertToCNF ());
        assertEquals (new And (formula, b),
                      new And (b, formula).convertToCNF ());
    }

    public void testDeMorgans () {
        assertEquals (new Or (a.negate (), b.negate ()),
                      new And (a, b).negate ().convertToCNF ());
        assertEquals (new And (a.negate (), b.negate ()),
                      new Or (a, b).negate ().convertToCNF ());
    }

    public void testSanity () {
        BooleanFormula formula = new Or (
                                         new Equivalence (BooleanFormula.TRUE,
                                                          b).negate (),
                                         new Implication (
                                                          new And (
                                                                   a,
                                                                   new Equivalence (
                                                                                    a,
                                                                                    b)),
                                                          c));
        BooleanFormula result = formula.convertToCNF ();
        assert result.isInCNF();
    }

}

// arch-tag: CNFTest.java May 25, 2005 3:13:57 AM
