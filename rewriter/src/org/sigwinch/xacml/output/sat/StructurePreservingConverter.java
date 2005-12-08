/*
 * Created on May 31, 2005
 */
package org.sigwinch.xacml.output.sat;

import java.util.HashMap;
import java.util.Map;

import org.sigwinch.xacml.tree.VariableReference;

/**
 * @author graham
 */
public class StructurePreservingConverter {
    /**
     * @author graham
     */
    public class NegativeVisitor implements FormulaVisitor {
        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitTrue(org.sigwinch.xacml.output.sat.BooleanFormula.True)
         */
        public void visitTrue(PrimitiveBoolean t) {
            returnWith(t);
        }

        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitFalse(org.sigwinch.xacml.output.sat.BooleanFormula.False)
         */
        public void visitFalse(PrimitiveBoolean f) {
            returnWith(f);
        }

        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitAnd(org.sigwinch.xacml.output.sat.And)
         */
        public void visitAnd(And and) {
            BooleanFormula whole = nameFor(and);
            BooleanFormula[] subclauses = new BooleanFormula[and.objects.length];
            for (int i = 0; i < subclauses.length; i++) {
                subclauses[i] = nameFor(and.objects[i]);
            }
            BooleanFormula[] results = new BooleanFormula[and.objects.length + 1];
            results[0] = new Implication(new And(subclauses), whole);
            for (int i = 0; i < and.objects.length; i++) {
                results[i + 1] = callOn(and.objects[i], neg);
            }
            returnWith(new And(results));
        }

        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitOr(org.sigwinch.xacml.output.sat.Or)
         */
        public void visitOr(Or or) {
            BooleanFormula whole = nameFor(or);
            BooleanFormula[] subclauses = new BooleanFormula[or.objects.length];
            for (int i = 0; i < subclauses.length; i++) {
                subclauses[i] = nameFor(or.objects[i]);
            }
            BooleanFormula[] results = new BooleanFormula[or.objects.length + 1];
            results[0] = new Implication(new Or(subclauses), whole);
            for (int i = 0; i < or.objects.length; i++) {
                results[i + 1] = callOn(or.objects[i], neg);
            }
            returnWith(new And(results));
        }

        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitNot(org.sigwinch.xacml.output.sat.Not)
         */
        public void visitNot(Not not) {
            returnWith(callOn(not.formula, pos));
        }

        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitVariable(org.sigwinch.xacml.tree.VariableReference)
         */
        public void visitVariable(VariableReference ref) {
            returnWith(PrimitiveBoolean.TRUE);
        }

        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitEquivalence(org.sigwinch.xacml.output.sat.Equivalence)
         */
        public void visitEquivalence(Equivalence equivalence) {
            BooleanFormula leftpos = callOn(equivalence.left, pos);
            BooleanFormula rightpos = callOn(equivalence.right, pos);
            BooleanFormula leftneg = callOn(equivalence.left, neg);
            BooleanFormula rightneg = callOn(equivalence.right, neg);
            BooleanFormula eqvname = nameFor(equivalence);
            BooleanFormula lname = nameFor(equivalence.left);
            BooleanFormula rname = nameFor(equivalence.right);
            BooleanFormula frame = new Implication(
                    new Equivalence(lname, rname), eqvname);
            returnWith(new And(new BooleanFormula[] { frame, leftneg, rightneg,
                    leftpos, rightpos }));
        }

        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitEquivalence(org.sigwinch.xacml.output.sat.Equivalence)
         */
        public void visitImplication(Implication implication) {
            BooleanFormula leftpos = callOn(implication.left, pos);
            BooleanFormula rightneg = callOn(implication.right, neg);
            BooleanFormula iname = nameFor(implication);
            BooleanFormula lname = nameFor(implication.left);
            BooleanFormula rname = nameFor(implication.right);
            BooleanFormula frame = new Implication(
                    new Implication(lname, rname), iname);
            returnWith(new And(frame, leftpos, rightneg));
        }

    }

    /**
     * @author graham
     */
    public class PositiveVisitor implements FormulaVisitor {
        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitTrue(org.sigwinch.xacml.output.sat.BooleanFormula.True)
         */
        public void visitTrue(PrimitiveBoolean t) {
            returnWith(t);
        }

        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitFalse(org.sigwinch.xacml.output.sat.BooleanFormula.False)
         */
        public void visitFalse(PrimitiveBoolean f) {
            returnWith(f);
        }

        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitAnd(org.sigwinch.xacml.output.sat.And)
         */
        public void visitAnd(And and) {
            BooleanFormula whole = nameFor(and);
            BooleanFormula[] subclauses = new BooleanFormula[and.objects.length];
            for (int i = 0; i < subclauses.length; i++) {
                subclauses[i] = nameFor(and.objects[i]);
            }
            BooleanFormula[] results = new BooleanFormula[and.objects.length + 1];
            results[0] = new Implication(whole, new And(subclauses));
            for (int i = 0; i < and.objects.length; i++) {
                results[i + 1] = callOn(and.objects[i], pos);
            }
            returnWith(new And(results));
        }

        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitOr(org.sigwinch.xacml.output.sat.Or)
         */
        public void visitOr(Or or) {
            BooleanFormula whole = nameFor(or);
            BooleanFormula[] subclauses = new BooleanFormula[or.objects.length];
            for (int i = 0; i < subclauses.length; i++) {
                subclauses[i] = nameFor(or.objects[i]);
            }
            BooleanFormula[] results = new BooleanFormula[or.objects.length + 1];
            results[0] = new Implication(whole, new Or(subclauses));
            for (int i = 0; i < or.objects.length; i++) {
                results[i + 1] = callOn(or.objects[i], pos);
            }
            returnWith(new And(results));
        }

        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitNot(org.sigwinch.xacml.output.sat.Not)
         */
        public void visitNot(Not not) {
            returnWith(callOn(not.formula, neg));
        }

        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitVariable(org.sigwinch.xacml.tree.VariableReference)
         */
        public void visitVariable(VariableReference ref) {
            returnWith(PrimitiveBoolean.TRUE);
        }

        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitEquivalence(org.sigwinch.xacml.output.sat.Equivalence)
         */
        public void visitEquivalence(Equivalence equivalence) {
            BooleanFormula leftpos = callOn(equivalence.left, pos);
            BooleanFormula rightpos = callOn(equivalence.right, pos);
            BooleanFormula leftneg = callOn(equivalence.left, neg);
            BooleanFormula rightneg = callOn(equivalence.right, neg);
            BooleanFormula eqvname = nameFor(equivalence);
            BooleanFormula lname = nameFor(equivalence.left);
            BooleanFormula rname = nameFor(equivalence.right);
            BooleanFormula frame = new Implication(eqvname, new Equivalence(
                    lname, rname));
            returnWith(new And(new BooleanFormula[] { frame, leftpos, rightpos,
                    leftneg, rightneg }));
        }

        /*
         * (non-Javadoc)
         * 
         * @see org.sigwinch.xacml.output.sat.FormulaVisitor#visitImplication(org.sigwinch.xacml.output.sat.Implication)
         */
        public void visitImplication(Implication implication) {
            BooleanFormula leftneg = callOn(implication.left, neg);
            BooleanFormula rightpos = callOn(implication.right, pos);
            BooleanFormula iname = nameFor(implication);
            BooleanFormula lname = nameFor(implication.left);
            BooleanFormula rname = nameFor(implication.right);
            BooleanFormula frame = new Implication(iname, new Implication(
                    lname, rname));
            returnWith(new And(frame, leftneg, rightpos));
        }

    }

    BooleanFormula returnValue;

    FormulaVisitor pos, neg;

    int names = 0;

    Map<BooleanFormula, VariableReference> namesSeen;

    Map<FormulaVisitor, Map<BooleanFormula, BooleanFormula>> symbolsSeen;

    /**
     * 
     */
    public StructurePreservingConverter() {
        returnValue = null;
        pos = new PositiveVisitor();
        neg = new NegativeVisitor();
        namesSeen = new HashMap<BooleanFormula, VariableReference>();
        symbolsSeen = new HashMap<FormulaVisitor, Map<BooleanFormula, BooleanFormula>>();
    }

    BooleanFormula callOn(BooleanFormula target, FormulaVisitor visitor) {
        if (!symbolsSeen.containsKey (visitor))
            symbolsSeen.put (visitor, new HashMap<BooleanFormula, BooleanFormula> ());
        if (!symbolsSeen.get (visitor).containsKey(target)) {
            target.visit(visitor);
            symbolsSeen.get(visitor).put (target, returnValue);
        }
        return symbolsSeen.get(visitor).get (target);
    }

    void returnWith(BooleanFormula target) {
        returnValue = target;
    }

    BooleanFormula nameFor(BooleanFormula expression) {
        if (expression instanceof Not) {
            Not not = (Not) expression;
            return nameFor(not.formula).negate();
        }
        if (expression instanceof VariableReference) {
            return (VariableReference) expression;
        }
        if (!namesSeen.containsKey(expression))
            namesSeen.put(expression,
                    new VariableReference("clause_" + ++names));
        return namesSeen.get(expression);
    }
    
    static public BooleanFormula rawConvert (BooleanFormula formula) {
        StructurePreservingConverter converter = new StructurePreservingConverter();
        return converter.go(formula);
    }

    static public BooleanFormula convert(BooleanFormula formula) {
        return rawConvert(formula.simplify()).simplify();
    }

    private BooleanFormula go(BooleanFormula formula) {
        return new And(callOn(formula, pos), nameFor(formula));
    }

    static public int[][] toArray(BooleanFormula formula) {
        HashMap<BooleanFormula, Integer> lookup = new HashMap<BooleanFormula, Integer>();
        int[] vars = new int[] { 0 };
        return toArray(formula, vars, lookup);
    }

    private static int[] writeRow(BooleanFormula formula,
            Map<BooleanFormula, Integer> lookup, int[] vars) {
        int[] result;
        if (formula instanceof Or) {
            Or or = (Or) formula;
            result = new int[or.objects.length];
            for (int i = 0; i < or.objects.length; i++) {
                result[i] = toNumber(or.objects[i], lookup, vars);
            }
        } else {
            result = new int[1];
            result[0] = toNumber(formula, lookup, vars);
        }
        return result;
    }

    /**
     * @param formula
     * @param lookup
     * @param vars
     * @return
     */
    private static int toNumber(BooleanFormula formula,
            Map<BooleanFormula, Integer> lookup, int[] vars) {
        if (formula instanceof Not) {
            Not not = (Not) formula;
            return -toNumber(not.formula, lookup, vars);
        } else if (lookup.containsKey(formula)) {
            return lookup.get(formula).intValue();
        } else {
            Integer num = new Integer(++vars[0]);
            lookup.put(formula, num);
            return num.intValue();
        }
    }

    /**
     * @param full
     * @param vars
     * @param variableMap
     * @return
     */
    public static int[][] toArray(BooleanFormula formula, int[] vars,
            Map<BooleanFormula, Integer> lookup) {
        // after structure preserving, do naive conversion
        return asArray(convert(formula).convertToCNF(), vars, lookup);
    }

    public static int[][] asArray(BooleanFormula cnf, int[] vars,
            Map<BooleanFormula, Integer> lookup) {
        assert cnf.isInCNF() : cnf + " is not in CNF";
        int[][] result;
        if (cnf instanceof And) {
            And and = (And) cnf;
            result = new int[and.objects.length][];
            for (int i = 0; i < and.objects.length; i++) {
                result[i] = writeRow(and.objects[i], lookup, vars);
            }
        } else {
            result = new int[1][];
            result[0] = writeRow(cnf, lookup, vars);
        }
        return result;
    }
}

// arch-tag: StructurePreservingConverter.java May 31, 2005 8:27:21 PM
