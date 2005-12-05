/*
 * Created on May 23, 2005
 */
package org.sigwinch.xacml.output.sat;

import java.util.ArrayList;

import org.sigwinch.xacml.tree.ConstantValuePredicate;
import org.sigwinch.xacml.tree.FunctionCallPredicate;
import org.sigwinch.xacml.tree.Predicate;

/**
 * @author graham
 */
public class OrderingTest extends XACMLTestCase {

    /**
     * @author graham
     */
    public abstract class Closure {
        public abstract void perform(ArrayList<BooleanFormula> list,
                VariableEncoding left, VariableEncoding right);
    }

    private ConstantValuePredicate first;

    private ConstantValuePredicate second;

    private int size;

    @Override
    protected void setUp() {
        super.setUp();
        size = 4;
        out.setMultiplicity(size); // to cut down on spurious frame conditions
        first = new ConstantValuePredicate("string", "foo");
        second = new ConstantValuePredicate("string", "bar");
    }

    private void performTest(String fn, Closure closure) {
        FunctionCallPredicate lessthan = buildFunction(fn, new Predicate[] {
                first, second });
        lessthan.walk(out);
        VariableEncoding foos = out.getEncodingFor(first);
        VariableEncoding bars = out.getEncodingFor(second);
        ArrayList<BooleanFormula> formulas = new ArrayList<BooleanFormula>();
        closure.perform(formulas, foos, bars);
        BooleanFormula[] subformulae = formulas
                .toArray(new BooleanFormula[] {});
        Or expected = new Or(subformulae);
        BooleanFormula got = out.getFormulaFor(lessthan);
        if (!expected.equals(got)) {
            System.out.println("E: " + expected);
            System.out.println("G: " + got);
        }
        assertEquals(expected, got);
        assertEquals(0, out.getFrameConditions().length);
    }

    public void testLessThan() {
        performTest("string-less-than", new Closure() {
            @Override
            public void perform(ArrayList<BooleanFormula> list,
                    VariableEncoding left, VariableEncoding right) {
                for (int i = 0; i < size; i++) {
                    for (int j = i + 1; j < size; j++) {
                        list.add(new And(left.address(i), right.address(j)));
                    }
                }
            }
        });
    }

    public void testLessThanOrEquals() {
        performTest("string-less-than-or-equal", new Closure() {
            @Override
            public void perform(ArrayList<BooleanFormula> list,
                    VariableEncoding left, VariableEncoding right) {
                for (int i = 0; i < size; i++) {
                    for (int j = i; j < size; j++) {
                        list.add(new And(left.address(i), right.address(j)));
                    }
                }
            }
        });
    }

    public void testGreaterThan() {
        performTest("string-greater-than", new Closure() {
            @Override
            public void perform(ArrayList<BooleanFormula> list,
                    VariableEncoding left, VariableEncoding right) {
                for (int i = 0; i < size; i++) {
                    for (int j = i + 1; j < size; j++) {
                        list.add(new And(left.address(j), right.address(i)));
                    }
                }
            }
        });
    }

    public void testGreaterThanOrEqual() {
        performTest("string-greater-than-or-equal", new Closure() {
            @Override
            public void perform(ArrayList<BooleanFormula> list,
                    VariableEncoding left, VariableEncoding right) {
                for (int i = 0; i < size; i++) {
                    for (int j = i; j < size; j++) {
                        list.add(new And(left.address(j), right.address(i)));
                    }
                }
            }
        });
    }

}

// arch-tag: OrderingTest.java May 23, 2005 4:04:40 PM
