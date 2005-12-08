/*
 * Created on May 30, 2005
 */
package org.sigwinch.xacml.output.sat;

import org.sigwinch.xacml.tree.VariableReference;
import static org.sigwinch.xacml.output.sat.StructurePreservingConverter.rawConvert;
import static org.sigwinch.xacml.output.sat.PrimitiveBoolean.TRUE;

import junit.framework.TestCase;

/**
 * @author graham
 */
public class StructurePreservingConversionTest extends TestCase {

    private VariableReference a;

    private VariableReference b;

    private VariableReference var1;

    private VariableReference var2;

    private VariableReference var3;

    public static void main(String[] args) {
        junit.textui.TestRunner.run(StructurePreservingConversionTest.class);
    }

    @Override
    protected void setUp() {
        a = new VariableReference("a");
        b = new VariableReference("b");
        var1 = new VariableReference("clause_1");
        var2 = new VariableReference("clause_2");
        var3 = new VariableReference("clause_3");
    }

    public void testSimpleConverter() {
        And formula = new And(new VariableReference("a").negate(),
                new VariableReference("b"));
        int[][] result = StructurePreservingConverter.toArray(formula);
        assertArraysEqual(new int[][] { { -1, -2 }, { -2, 3 }, { 2 } }, result);
    }

    public void testAnd() {
        BooleanFormula formula = new And(new And(a, b), new And(b, a));
        BooleanFormula expected = new And(new And(new Implication(var1,
                new And(var2, var3)), new And(new Implication(var2, new And(a,
                b)), TRUE, TRUE), new And(new Implication(var3, new And(b, a)),
                TRUE, TRUE)), var1);
        assertEquals(expected, rawConvert(formula));
    }

    public void testOr() {
        BooleanFormula formula = new Or(new And(a, b), new And(b, a));
        BooleanFormula expected = new And(new And(new Implication(var1, new Or(
                var2, var3)), new And(new Implication(var2, new And(a, b)),
                TRUE, TRUE), new And(new Implication(var3, new And(b, a)),
                TRUE, TRUE)), var1);
        assertEquals(expected, rawConvert(formula));
    }

    public void testEquiv() {
        BooleanFormula formula = new Equivalence(new And(a, b), new And(b, a));
        BooleanFormula expected = new And(new And(new Implication(var3,
                new Equivalence(var1, var2)), new And(new Implication(var1,
                new And(a, b)), TRUE, TRUE), new And(new Implication(var2,
                new And(b, a)), TRUE, TRUE), new And(new Implication(new And(a,
                b), var1), TRUE, TRUE), new And(new Implication(new And(b, a),
                var2), TRUE, TRUE)), var3);
        assertEquals(expected, rawConvert(formula));
    }

    public void testImplies() {
        BooleanFormula formula = new Implication(new And(a, b), new And(b, a));
        BooleanFormula expected = new And(new And(new Implication(var3,
                new Implication(var1, var2)), new And(new Implication(new And(
                a, b), var1), TRUE, TRUE), new And(new Implication(var2,
                new And(b, a)), TRUE, TRUE)), var3);
        assertEquals(expected, rawConvert(formula));
    }

    public void testNegAnd() {
        BooleanFormula formula = new And(new And(a, b), new And(b, a)).negate();
        BooleanFormula expected = new And(new And(new Implication(new And(var2,
                var3), var1), new And(new Implication(new And(a, b), var2),
                TRUE, TRUE), new And(new Implication(new And(b, a), var3),
                TRUE, TRUE)), var1.negate());
        assertEquals(expected, rawConvert(formula));
    }

    public void testNegOr() {
        BooleanFormula formula = new Or(new And(a, b), new And(b, a)).negate();
        BooleanFormula expected = new And(new And(new Implication(new Or(var2,
                var3), var1), new And(new Implication(new And(a, b), var2),
                TRUE, TRUE), new And(new Implication(new And(b, a), var3),
                TRUE, TRUE)), var1.negate());
        assertEquals(expected, rawConvert(formula));
    }

    public void testNegEquiv() {
        BooleanFormula formula = new Equivalence(new And(a, b), new And(b, a))
                .negate();
        BooleanFormula expected = new And(new And(new Implication(
                new Equivalence(var1, var2), var3), new And(new Implication(
                new And(a, b), var1), TRUE, TRUE), new And(new Implication(
                new And(b, a), var2), TRUE, TRUE), new And(new Implication(
                var1, new And(a, b)), TRUE, TRUE), new And(new Implication(
                var2, new And(b, a)), TRUE, TRUE)), var3.negate());
        assertEquals(expected, rawConvert(formula));
    }

    public void testNegImplies() {
        BooleanFormula formula = new Implication(new And(a, b), new And(b, a))
                .negate();
        BooleanFormula expected = new And(new And(new Implication(
                new Implication(var1, var2), var3), new And(new Implication(
                var1, new And(a, b)), TRUE, TRUE), new And(new Implication(
                new And(b, a), var2), TRUE, TRUE)), var3.negate());
        assertEquals(expected, rawConvert(formula));
    }

    public void testNegations() {
        BooleanFormula formula = new Implication(new And(a, b).negate(),
                new And(b, a)).negate();
        BooleanFormula expected = new And(new And(new Implication(
                new Implication(var1.negate(), var2), var3), new And(
                new Implication(new And(a, b), var1), TRUE, TRUE), new And(
                new Implication(new And(b, a), var2), TRUE, TRUE)), var3
                .negate());
        assertEquals(expected, rawConvert(formula));
    }

    public void testEquivalences() {
        BooleanFormula formula = new Equivalence(new VariableReference("a"),
                new VariableReference("b"));
        int[][] result = StructurePreservingConverter.toArray(formula);
        assertArraysEqual(new int[][] { { -1, -2, 3 }, { -3, -2, 1 }, { 2 } },
                result);
        result = StructurePreservingConverter.toArray(formula.negate());
        assertArraysEqual(new int[][] { { -1 }, { -2, -3, 1 }, { 2, 3, 1 } },
                result);
    }

    private void assertArraysEqual(int[][] model, int[][] result) {
        assertEquals("# of clauses differ: " + model.length + " "
                + result.length, model.length, result.length);
        for (int i = 0; i < result.length; i++) {
            assertEquals("# of subclauses differ for row " + i + ": "
                    + model[i].length + " " + result[i].length,
                    model[i].length, result[i].length);
            for (int j = 0; j < result[i].length; j++) {
                assertEquals("variables differ at " + i + "," + j + ": "
                        + model[i][j] + " " + result[i][j], model[i][j],
                        result[i][j]);
                assertTrue("variable is zero at " + i + "," + j,
                        result[i][j] != 0);
            }
        }
    }

}

// arch-tag: StructurePreservingConversionTest.java May 30, 2005 2:21:06 AM
