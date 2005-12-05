/*
 * Created on May 30, 2005
 */
package org.sigwinch.xacml.output.sat;

import org.sigwinch.xacml.tree.VariableReference;

import junit.framework.TestCase;

/**
 * @author graham
 */
public class StructurePreservingConversionTest extends TestCase {

    private VariableReference a;

    private VariableReference b;

    public static void main(String[] args) {
        junit.textui.TestRunner.run(StructurePreservingConversionTest.class);
    }

    @Override
    protected void setUp() {
        a = new VariableReference("a");
        b = new VariableReference("b");
    }

    public void testAnd() {
        And formula = new And(a.negate(), b);
        VariableReference var = new VariableReference("clause_1");
        BooleanFormula conversion = StructurePreservingConverter
                .convert(formula);
        assertEquals(
                new And(new Implication(var, new And(a.negate(), b)), var),
                conversion);
        conversion = StructurePreservingConverter.convert(formula.negate());
        assertEquals(new And(new Implication(new And(a.negate(), b), var), var
                .negate()), conversion);
    }

    public void testOr() {
        Or formula = new Or(a.negate(), b);
        VariableReference var = new VariableReference("clause_1");
        BooleanFormula conversion = StructurePreservingConverter
                .convert(formula);
        assertEquals(new And(new Implication(var, new Or(a.negate(), b)), var),
                conversion);
        conversion = StructurePreservingConverter.convert(formula.negate());
        assertEquals(new And(new Implication(new Or(a.negate(), b), var), var
                .negate()), conversion);
    }

    public void testEquivalence() {
        Equivalence formula = new Equivalence(a.negate(), b);
        VariableReference var = new VariableReference("clause_1");
        BooleanFormula conversion = StructurePreservingConverter
                .convert(formula);
        assertEquals(new And(new Implication(var,
                new Equivalence(a.negate(), b)), var), conversion);
        conversion = StructurePreservingConverter.convert(formula.negate());
        assertEquals(new And(new Implication(new Equivalence(a.negate(), b),
                var), var.negate()), conversion);
    }

    public void testImplication() {
        Implication formula = new Implication(a.negate(), b);
        VariableReference var = new VariableReference("clause_1");
        BooleanFormula conversion = StructurePreservingConverter
                .convert(formula);
        assertEquals(new And(new Implication(var,
                new Implication(a.negate(), b)), var), conversion);
        conversion = StructurePreservingConverter.convert(formula.negate());
        assertEquals(new And(new Implication(new Implication(a.negate(), b),
                var), var.negate()), conversion);
    }

    public void testSimpleConverter() {
        And formula = new And(new VariableReference("a").negate(),
                new VariableReference("b"));
        int[][] result = StructurePreservingConverter.toArray(formula);
        assertArraysEqual(new int[][] { { -1, -2 }, { -2, 3 }, { 2 } }, result);
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
