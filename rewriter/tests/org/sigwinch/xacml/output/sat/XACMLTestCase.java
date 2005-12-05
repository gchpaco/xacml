/*
 * Created on May 23, 2005
 */
package org.sigwinch.xacml.output.sat;

import java.util.TreeSet;

import org.sigwinch.xacml.tree.ExistentialPredicate;
import org.sigwinch.xacml.tree.FunctionCallPredicate;
import org.sigwinch.xacml.tree.FunctionVisitor;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.Triple;
import org.sigwinch.xacml.tree.VariableReference;

import junit.framework.TestCase;

/**
 * @author graham
 */
public abstract class XACMLTestCase extends TestCase {

    VariableReference a;
    VariableReference b;
    VariableReference c;
    SatVisitor out;
    static final String xp = FunctionVisitor.xacmlprefix;

    protected void reset () {
        out = new SatVisitor ();
        Predicate.reset ();
        out.setMultiplicity (3);
    }

    @Override
    protected void setUp () {
        a = new VariableReference ("a");
        b = new VariableReference ("b");
        c = new VariableReference ("c");
        reset ();
    }

    /**
     * @param f1
     * @param f2
     * @param f3
     * @param t
     */
    protected void assertTriple (BooleanFormula f1, BooleanFormula f2, BooleanFormula f3, Triple t) {
        assertTriple (f1, f2, f3, t, new BooleanFormula[] {});
    }

    protected void assertTriple (BooleanFormula f1, BooleanFormula f2, BooleanFormula f3, Triple t, BooleanFormula[] frames) {
        VariableReference permit = out.getPermitFor (t);
        VariableReference deny = out.getDenyFor (t);
        VariableReference error = out.getErrorFor (t);
        assertNotNull (permit);
        assertNotNull (deny);
        assertNotNull (error);
        TreeSet<BooleanFormula> formulas = new TreeSet<BooleanFormula> (new SatVisitor.FormulaComparator ());
        formulas.add (new Equivalence (permit, f1));
        formulas.add (new Equivalence (deny, f2));
        formulas.add (new Equivalence (error, f3));
        for (int i = 0; i < frames.length; i++) {
            formulas.add (frames[i]);
        }
        BooleanFormula [] array = formulas.toArray (new BooleanFormula [] {});
        String first = new And (array).toString ();
        String second = out.computeFormula ().toString ();
        if (!(first.equals (second))) {
            System.out.println (first);
            System.out.println (second);
        }
        assertEquals (new And (array), out.computeFormula ());
    }

    protected FunctionCallPredicate buildFunction (String function, Predicate[] predicates) {
        return new FunctionCallPredicate (xp + function, predicates);
    }

    protected ExistentialPredicate buildExistential (String function, Predicate attribute, Predicate bag) {
        return new ExistentialPredicate (xp + function, attribute, bag);
    }

    protected BooleanFormula[] buildEquivalence (BooleanFormula[] foos, BooleanFormula[] bars) {
        BooleanFormula[] equivs = new BooleanFormula[foos.length];
        for (int i = 0; i < foos.length; i++) {
            equivs[i] = new Equivalence (foos[i], bars[i]);
        }
        return equivs;
    }

}


// arch-tag: XACMLTestCase.java May 23, 2005 4:05:44 PM
