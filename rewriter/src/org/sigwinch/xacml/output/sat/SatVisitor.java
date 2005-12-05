/*
 * Created on Apr 25, 2005
 */
package org.sigwinch.xacml.output.sat;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import org.sigwinch.xacml.tree.*;

/**
 * @author graham
 */
public class SatVisitor extends VisitorImpl {
    /**
     * @author graham
     */
    public static class FormulaComparator implements Comparator {

        /*
         * (non-Javadoc)
         * 
         * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
         */
        public int compare (Object o1, Object o2) {
            BooleanFormula left = (BooleanFormula) o1;
            BooleanFormula right = (BooleanFormula) o2;
            return left.toString ().compareTo (right.toString ());
        }

    }

    /**
     * @author graham
     */
    public class SatExistentialFV extends FunctionVisitorImpl {
        ExistentialPredicate ep;

        /**
         * @param visitor
         * @param ep
         */
        public SatExistentialFV (SatVisitor visitor, ExistentialPredicate ep) {
            super (visitor);
            this.ep = ep;
        }

        public void visitDefault (String string, Predicate[] predicateArray) {
            super.visitDefault (string, predicateArray);
            // This is a noop currently, because we do no handling of xpath.
            assert string.equals (xacmlprefix + "xpath-node-match");
            setFormulaFor (ep, BooleanFormula.TRUE);
        }

        public void visitEquality (Predicate attribute, Predicate bag) {
            super.visitEquality (attribute, bag);
            VariableEncoding attr = getEncodingFor (attribute);
            VariableReference[] bagNames = getNamesFor (bag);
            assert attr.getSize () == bagNames.length : attr.getSize ()
                                                        + " is different from "
                                                        + bagNames.length;
            BooleanFormula[] clauses = new BooleanFormula[bagNames.length];
            for (int i = 0; i < clauses.length; i++) {
                clauses[i] = new Implication (attr.address (i), bagNames[i]);
            }
            setFormulaFor (ep, new And (clauses));
        }
    }

    /**
     * @author graham
     */
    public class SatFunctionVisitor extends FunctionVisitorImpl {
        FunctionCallPredicate func;

        /**
         * @param visitor
         * @param fcp
         */
        public SatFunctionVisitor (SatVisitor visitor, FunctionCallPredicate fcp) {
            super (visitor);
            func = fcp;
        }

        public void visitEquality (Predicate left, Predicate right) {
            super.visitEquality (left, right);
            VariableReference[][] allNames = getNames (left, right);
            BooleanFormula[] clauses = new BooleanFormula[allNames[0].length];
            for (int i = 0; i < clauses.length; i++) {
                clauses[i] = new Equivalence (allNames[0][i], allNames[1][i]);
            }
            setFormulaFor (func, new And (clauses));
        }

        public void visitSetEquality (Predicate left, Predicate right) {
            super.visitSetEquality (left, right);
            VariableReference[][] allNames = getNames (left, right);
            BooleanFormula[] clauses = new BooleanFormula[allNames[0].length];
            for (int i = 0; i < clauses.length; i++) {
                clauses[i] = new Equivalence (allNames[0][i], allNames[1][i]);
            }
            setFormulaFor (func, new And (clauses));
        }

        public void visitAnd (Predicate[] predicateArray) {
            super.visitAnd (predicateArray);
            BooleanFormula[] clauses = new BooleanFormula[predicateArray.length];
            for (int i = 0; i < clauses.length; i++) {
                clauses[i] = getFormulaFor (predicateArray[i]);
            }
            setFormulaFor (func, new And (clauses));
        }

        public void visitNot (Predicate predicate) {
            super.visitNot (predicate);
            setFormulaFor (func, getFormulaFor (predicate).negate ());
        }

        public void visitOr (Predicate[] predicateArray) {
            super.visitAnd (predicateArray);
            BooleanFormula[] clauses = new BooleanFormula[predicateArray.length];
            for (int i = 0; i < clauses.length; i++) {
                clauses[i] = getFormulaFor (predicateArray[i]);
            }
            setFormulaFor (func, new Or (clauses));
        }

        public void visitAtLeastOne (Predicate left, Predicate right) {
            super.visitAtLeastOne (left, right);
            VariableReference[][] allNames = getNames (left, right);
            BooleanFormula[] clauses = new BooleanFormula[allNames[0].length];
            for (int i = 0; i < clauses.length; i++) {
                clauses[i] = new And (allNames[0][i], allNames[1][i]);
            }
            setFormulaFor (func, new Or (clauses));
        }

        public void visitDefault (String string, Predicate[] predicateArray) {
            super.visitDefault (string, predicateArray);
            if (string.equals (xacmlprefix + "xpath-node-match")) {
                setFormulaFor (
                               func,
                               new VariableReference (
                                                      intern ("xpath_"
                                                              + makeNameFrom (predicateArray))));
            } else if (string.equals (xacmlprefix
                                      + "date-add-yearMonthDuration")) {
                // create a new thing of the same type as the first argument
                VariableEncoding enc = getEncodingFor (predicateArray[0]);
                setNamesFor (
                             func,
                             new ScalarVariableEncoding (
                                                         intern ("xpath_"
                                                                 + makeNameFrom (predicateArray)),
                                                         enc.getSize ()));
            } else
                throw new RuntimeException ("unsupported function " + string);
        }

        private String makeNameFrom (Predicate left, Predicate right) {
            return nameFrom (left) + "_" + nameFrom (right);
        }

        private String nameFrom (Predicate left) {
            return getEncodingFor (left).getBase ();
        }

        private String makeNameFrom (Predicate[] predicateArray) {
            StringBuffer buffer = new StringBuffer ();
            for (int i = 0; i < predicateArray.length; i++) {
                if (i != 0)
                    buffer.append ('_');
                buffer.append (nameFrom (predicateArray[i]));
            }
            return buffer.toString ();
        }

        public void visitGreaterThan (Predicate left, Predicate right) {
            super.visitGreaterThan (left, right);
            VariableEncoding l = getEncodingFor (left);
            VariableEncoding r = getEncodingFor (right);
            assert l.getSize () == r.getSize ();
            ArrayList f = new ArrayList ();
            for (int i = 0; i < l.getSize (); i++) {
                for (int j = i + 1; j < r.getSize (); j++) {
                    f.add (new And (l.address (j), r.address (i)));
                }
            }
            BooleanFormula[] clauses = (BooleanFormula[]) f
                                                           .toArray (new BooleanFormula[] {});
            setFormulaFor (func, new Or (clauses));
        }

        public void visitGreaterThanOrEqual (Predicate left, Predicate right) {
            super.visitGreaterThanOrEqual (left, right);
            VariableEncoding l = getEncodingFor (left);
            VariableEncoding r = getEncodingFor (right);
            assert l.getSize () == r.getSize ();
            ArrayList f = new ArrayList ();
            for (int i = 0; i < l.getSize (); i++) {
                for (int j = i; j < r.getSize (); j++) {
                    f.add (new And (l.address (j), r.address (i)));
                }
            }
            BooleanFormula[] clauses = (BooleanFormula[]) f
                                                           .toArray (new BooleanFormula[] {});
            setFormulaFor (func, new Or (clauses));
        }

        public void visitInclusion (Predicate left, Predicate right) {
            super.visitInclusion (left, right);
            VariableEncoding lnames = getEncodingFor (left);
            VariableReference[] rnames = getNamesFor (right);
            BooleanFormula[] clauses = new BooleanFormula[rnames.length];
            for (int i = 0; i < clauses.length; i++) {
                clauses[i] = new And (lnames.address (i), rnames[i]);
            }
            setFormulaFor (func, new Or (clauses));
        }

        public void visitIntersection (Predicate left, Predicate right) {
            super.visitIntersection (left, right);
            VariableReference[][] allNames = getNames (left, right);
            VariableEncoding enc = new SetVariableEncoding (
                                                            makeNameFrom (left,
                                                                          right)
                                                                                                                                                                                                                                                + "_intersection",
                                                            allNames[0].length);
            setNamesFor (func, enc);
            BooleanFormula[] frameClauses = new BooleanFormula[allNames[0].length];
            for (int i = 0; i < frameClauses.length; i++) {
                frameClauses[i] = new Equivalence (enc.address (i),
                                                   new And (allNames[0][i],
                                                            allNames[1][i]));
            }
            frames.add (new And (frameClauses));
        }

        public void visitLessThan (Predicate left, Predicate right) {
            super.visitLessThan (left, right);
            VariableEncoding l = getEncodingFor (left);
            VariableEncoding r = getEncodingFor (right);
            assert l.getSize () == r.getSize ();
            ArrayList f = new ArrayList ();
            for (int i = 0; i < l.getSize (); i++) {
                for (int j = i + 1; j < r.getSize (); j++) {
                    f.add (new And (l.address (i), r.address (j)));
                }
            }
            BooleanFormula[] clauses = (BooleanFormula[]) f
                                                           .toArray (new BooleanFormula[] {});
            setFormulaFor (func, new Or (clauses));
        }

        public void visitLessThanOrEqual (Predicate left, Predicate right) {
            super.visitLessThanOrEqual (left, right);
            VariableEncoding l = getEncodingFor (left);
            VariableEncoding r = getEncodingFor (right);
            assert l.getSize () == r.getSize ();
            ArrayList f = new ArrayList ();
            for (int i = 0; i < l.getSize (); i++) {
                for (int j = i; j < r.getSize (); j++) {
                    f.add (new And (l.address (i), r.address (j)));
                }
            }
            BooleanFormula[] clauses = (BooleanFormula[]) f
                                                           .toArray (new BooleanFormula[] {});
            setFormulaFor (func, new Or (clauses));
        }

        public void visitSetCreation (Predicate predicate) {
            super.visitSetCreation (predicate);
            VariableEncoding lnames = getEncodingFor (predicate);
            VariableEncoding all = new SetVariableEncoding (
                                                            nameFrom (predicate)
                                                                                                                                                                                                                                                + "_set",
                                                            lnames.getSize ());
            setNamesFor (func, all);
            BooleanFormula[] frameClauses = new BooleanFormula[all.getSize ()];
            for (int i = 0; i < frameClauses.length; i++) {
                BooleanFormula[] subclauses = new BooleanFormula[all.getSize ()];
                for (int j = 0; j < subclauses.length; j++) {
                    if (i == j)
                        subclauses[j] = all.address (j);
                    else
                        subclauses[j] = all.address (j).negate ();
                }
                frameClauses[i] = new Equivalence (lnames.address (i),
                                                   new And (subclauses));
            }
            frames.add (new And (frameClauses));
        }

        public void visitSize (Predicate predicate) {
            super.visitSize (predicate);
            VariableEncoding enc = getEncodingFor (predicate);
            String sn = intern (enc.getBase () + "_size");
            ScalarVariableEncoding all = new ScalarVariableEncoding (
                                                                     sn,
                                                                     enc
                                                                        .getSize ());
            setNamesFor (func, all);
            frames.addAll (all.disallowIllegals ());
        }

        public void visitSubset (Predicate left, Predicate right) {
            super.visitSubset (left, right);
            VariableReference[][] allNames = getNames (left, right);
            BooleanFormula[] clauses = new BooleanFormula[allNames[0].length];
            for (int i = 0; i < clauses.length; i++) {
                clauses[i] = new Implication (allNames[0][i], allNames[1][i]);
            }
            setFormulaFor (func, new And (clauses));
        }

        public void visitUnion (Predicate left, Predicate right) {
            super.visitUnion (left, right);
            VariableReference[][] allNames = getNames (left, right);
            VariableEncoding union = new SetVariableEncoding (
                                                              makeNameFrom (
                                                                            left,
                                                                            right)
                                                                                                                                                                                                                                                        + "_union",
                                                              allNames[0].length);
            setNamesFor (func, union);
            BooleanFormula[] frameClauses = new BooleanFormula[allNames[0].length];
            for (int i = 0; i < frameClauses.length; i++) {
                frameClauses[i] = new Equivalence (union.address (i),
                                                   new Or (allNames[0][i],
                                                           allNames[1][i]));
            }
            frames.add (new And (frameClauses));
        }

        private VariableReference[][] getNames (Predicate left, Predicate right) {
            VariableReference[][] allNames = new VariableReference[][] {
                                                                        getNamesFor (left),
                                                                        getNamesFor (right) };
            if (allNames[0].length != allNames[1].length)
                throw new RuntimeException ("invalid types being compared!");
            return allNames;
        }
    }

    Map scalars, sets;
    Set frames;
    int triples, multiplicity;
    private HashMap names;

    SatVisitor () {
        scalars = new HashMap ();
        sets = new HashMap ();
        names = new HashMap ();
        // This isn't the most efficient comparator I've ever had, but it's
        // quick & easy and this isn't the part that takes all the time, anyway.
        frames = new TreeSet (new FormulaComparator ());
        triples = 0;
        multiplicity = 1;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.CodeVisitor#outputStart()
     */
    protected void outputStart () {

    }

    public BooleanFormula[] getFrameConditions () {
        return (BooleanFormula[]) frames.toArray (new BooleanFormula[] {});
    }

    public BooleanFormula computeFormula () {
        BooleanFormula[] conditions = getFrameConditions ();
        if (conditions.length == 0)
            return BooleanFormula.TRUE;
        else {
            ArrayList clauses = new ArrayList ();
            for (int i = 0; i < conditions.length; i++)
                clauses.add (conditions[i]);
            return new And (
                            (BooleanFormula[]) clauses
                                                      .toArray (new BooleanFormula[] {}));
        }
    }

    /**
     * @param t
     *            triple to examine
     * @return variable name for permit branch of <code>t</code>
     */
    public VariableReference getPermitFor (Triple t) {
        return getNamesFor (t)[0];
    }

    /**
     * @param t
     *            triple to examine
     * @return variable name for deny branch of <code>t</code>
     */
    public VariableReference getDenyFor (Triple t) {
        return getNamesFor (t)[1];
    }

    /**
     * @param t
     *            triple to examine
     * @return variable name for error branch of <code>t</code>
     */
    public VariableReference getErrorFor (Triple t) {
        return getNamesFor (t)[2];
    }

    /**
     * @param predicate
     * @return Boolean formula for the given predicate
     */
    public BooleanFormula getFormulaFor (Predicate predicate) {
        BooleanFormula result = (BooleanFormula) scalars.get (predicate);
        assert result != null : predicate
                                + " was used in a Boolean context, but has no Boolean value";
        return result;
    }

    /**
     * Cache a formula representing <code>v</code> for access from
     * getFormulaFor.
     * 
     * @param v
     *            predicate
     * @param f
     *            formula
     */
    private void setFormulaFor (Predicate v, BooleanFormula f) {
        scalars.put (v, f);
    }

    /**
     * @param i
     */
    public void setMultiplicity (int i) {
        multiplicity = i;
    }

    /**
     * @param ep
     *            an environmental predicate
     * @return get a bunch of variables corresponding to the elements of the set
     *         for <code>ep</code>
     */
    public VariableReference[] getNamesFor (Object ep) {
        assert sets.containsKey (ep) : ep
                                       + " was used in a set context, but has no set value";
        VariableEncoding result = getEncodingFor (ep);
        return result.getNames ();
    }

    /**
     * @param triple
     */
    private void ensureTriple (Triple triple) {
        if (containsNameFor (triple))
            return;
        VariableReference[] elts = new VariableReference[] {
                                                            new VariableReference (
                                                                                   "t_p_"
                                                                                                                                                                                                                                                                                                                                            + triples),
                                                            new VariableReference (
                                                                                   "t_d_"
                                                                                                                                                                                                                                                                                                                                            + triples),
                                                            new VariableReference (
                                                                                   "t_e_"
                                                                                                                                                                                                                                                                                                                                            + triples) };
        triples++;
        setNamesFor (triple, new ScalarVariableEncoding (elts, multiplicity));
    }

    private boolean containsNameFor (Object obj) {
        return sets.containsKey (obj);
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.tree.Visitor#walkVariableReference(org.sigwinch.xacml.tree.VariableReference)
     */
    public void walkVariableReference (VariableReference v) {
        super.walkVariableReference (v);
        setFormulaFor (v, v);
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.tree.Visitor#walkAndPredicate(org.sigwinch.xacml.tree.AndPredicate)
     */
    public void walkAndPredicate (AndPredicate andPredicate) {
        super.walkAndPredicate (andPredicate);
        setFormulaFor (andPredicate,
                       new And (getFormulaFor (andPredicate.getLeft ()),
                                getFormulaFor (andPredicate.getRight ())));
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.tree.Visitor#walkAndPredicate(org.sigwinch.xacml.tree.AndPredicate)
     */
    public void walkOrPredicate (OrPredicate orPredicate) {
        super.walkOrPredicate (orPredicate);
        setFormulaFor (orPredicate,
                       new Or (getFormulaFor (orPredicate.getLeft ()),
                               getFormulaFor (orPredicate.getRight ())));
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.tree.Visitor#walkEnvironmentalPredicate(org.sigwinch.xacml.tree.EnvironmentalPredicate)
     */
    public void walkEnvironmentalPredicate (EnvironmentalPredicate ep) {
        super.walkEnvironmentalPredicate (ep);
        setNamesFor (ep,
                     new SetVariableEncoding (intern ("env_" + ep.getId ()),
                                              multiplicity));
    }

    public void walkExistentialPredicate (ExistentialPredicate ep) {
        super.walkExistentialPredicate (ep);
        SatExistentialFV v = new SatExistentialFV (this, ep);
        v.visitFunction (ep.getFunction (),
                         new Predicate[] { ep.getAttribute (), ep.getBag () },
                         ep.getIndex ());
    }

    /**
     * @param name
     * @return return a save and unique version of <code>name</code>
     */
    private String intern (String name) {
        String sn;
        if (names.containsKey (name))
            sn = (String) names.get (name);
        else {
            sn = makeSafe (name);
            while (names.containsValue (sn))
                sn = sn + "_";
            names.put (name, sn);
        }
        return sn;
    }

    /**
     * @param sn
     * @return return a safe version of <code>sn</code>
     */
    private String makeSafe (String sn) {
        return sn.replaceAll ("[^_A-Za-z0-9]", "_");
    }

    public void walkConstantValuePredicate (ConstantValuePredicate cvp) {
        super.walkConstantValuePredicate (cvp);
        String sn = intern ("const_" + cvp.getValue ());
        if (cvp.getShortName () == "Bool") {
            VariableReference name = new VariableReference (sn);
            setFormulaFor (cvp, name);
            setNamesFor (cvp, new BooleanVariableEncoding (name));
        } else {
            ScalarVariableEncoding encoding = new ScalarVariableEncoding (sn,
                                                                          multiplicity);
            setNamesFor (cvp, encoding);
            frames.addAll (encoding.disallowIllegals ());
        }
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.tree.Visitor#walkTriple(org.sigwinch.xacml.tree.Triple)
     */
    public void walkTriple (Triple triple) {
        ensureTriple (triple);
        super.walkTriple (triple);
        frames.add (equate (getPermitFor (triple), triple.getPermit ()));
        frames.add (equate (getDenyFor (triple), triple.getDeny ()));
        frames.add (equate (getErrorFor (triple), triple.getError ()));
    }

    private BooleanFormula equate (VariableReference variable,
                                   Predicate predicate) {
        return new Equivalence (variable, getFormulaFor (predicate));
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.tree.Visitor#walkSolePredicate(org.sigwinch.xacml.tree.SolePredicate)
     */
    public void walkSolePredicate (SolePredicate p) {
        super.walkSolePredicate (p);
        VariableReference[] allNames = getNamesFor (p.getSet ());
        BooleanFormula[] subformulae = new BooleanFormula[allNames.length];
        for (int i = 0; i < subformulae.length; i++) {
            BooleanFormula[] or = new BooleanFormula[allNames.length];
            for (int j = 0; j < or.length; j++) {
                if (i == j)
                    or[j] = allNames[j];
                else
                    or[j] = new Not (allNames[j]);
            }
            subformulae[i] = new And (or);
        }
        setFormulaFor (p, new Or (subformulae));
    }

    public void walkSimplePredicate (SimplePredicate simplePredicate) {
        super.walkSimplePredicate (simplePredicate);
        if (simplePredicate == SimplePredicate.TRUE) {
            frames.add (BooleanFormula.TRUE);
            setFormulaFor (simplePredicate, BooleanFormula.TRUE);
        } else {
            // NB: we do not use negate here, because that gets inlined. We
            // are expressing a syntactic condition on the variable named
            // "false"
            frames.add (new Not (BooleanFormula.FALSE));
            setFormulaFor (simplePredicate, BooleanFormula.FALSE);
        }
    }

    public void walkFunctionCallPredicate (
                                           FunctionCallPredicate functionCallPredicate) {
        SatFunctionVisitor v = new SatFunctionVisitor (this,
                                                       functionCallPredicate);
        v.visitFunction (functionCallPredicate);
    }

    /**
     * @param ep
     * @return class describing the variable encoding for <code>foo</code>
     */
    public VariableEncoding getEncodingFor (Object ep) {
        return (VariableEncoding) sets.get (ep);
    }

    private void setNamesFor (Object obj, VariableEncoding encoding) {
        sets.put (obj, encoding);
    }

    /**
     * @param left
     * @param right
     * @return logical formula demanding an example where what is true for left
     *         is not true in right
     */
    public BooleanFormula generateImplications (Triple left, Triple right) {
        return new And (
                        new Implication (getPermitFor (left),
                                         getPermitFor (right)),
                        new Implication (getDenyFor (left), getDenyFor (right)),
                        new Implication (getErrorFor (left),
                                         getErrorFor (right))).negate ();
    }
}

// arch-tag: SatVisitor.java Apr 25, 2005 2:02:08 PM
