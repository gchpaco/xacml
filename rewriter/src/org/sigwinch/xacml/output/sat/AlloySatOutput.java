/*
 * Created on May 28, 2005
 */
package org.sigwinch.xacml.output.sat;

import java.io.PrintWriter;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;

import org.sigwinch.xacml.output.Output;
import org.sigwinch.xacml.tree.Tree;
import org.sigwinch.xacml.tree.Triple;
import org.sigwinch.xacml.tree.VariableReference;

/**
 * @author graham
 */
public class AlloySatOutput implements Output {
    PrintWriter stream;
    double slop;
    private int vars;
    private HashMap<Object, Integer> var2num;
    private SatVisitor sat;
    private TreeSet<BooleanFormula> formulae;
    private Triple lastTree;

    public AlloySatOutput (PrintWriter stream, double slop) {
        this.stream = stream;
        this.slop = slop;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.Output#preamble(org.sigwinch.xacml.tree.Tree)
     */
    public void preamble (Tree tree) {
        sat = new SatVisitor ();
        sat.setMultiplicity ((int) slop);
        vars = 0;
        var2num = new HashMap<Object, Integer> ();
        formulae = new TreeSet<BooleanFormula> (new SatVisitor.FormulaComparator ());
        lastTree = null;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.Output#write(org.sigwinch.xacml.tree.Tree)
     */
    public void write (Tree tree) {
        tree.walk (sat);
        BooleanFormula formula = sat.computeFormula ();
        formula.visit (new FormulaImpl () {
            @Override
            public void visitVariable (VariableReference var) {
                super.visitVariable (var);
                putVariable (var);
            }
            @Override
            public void visitTrue (BooleanFormula.True t) {
                super.visitTrue (t);
                putVariable (t);
            }
            @Override
            public void visitFalse (BooleanFormula.False f) {
                super.visitFalse (f);
                putVariable (f);
            }
            private void putVariable (Object var) {
                if (!var2num.containsKey (var)) {
                    var2num.put (var, new Integer (++vars));
                }
            }
        });
        if (formula instanceof And)
            formulae.addAll (Arrays.asList (((And) formula).objects));
        else
            formulae.add (formula);
        if (tree instanceof Triple) {
            Triple triple = (Triple) tree;
            if (lastTree == null)
                lastTree = triple;
            else {
                formulae.add (sat.generateImplications (lastTree, triple));
                lastTree = triple;
            }
        }
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.Output#postamble()
     */
    public void postamble () {
        BooleanFormula [] allFormulae = formulae.toArray (new BooleanFormula [] {});
        And full = new And (allFormulae);
        int variables [] = new int [] { 0 };
        Map<BooleanFormula, Integer> variableMap = new TreeMap<BooleanFormula, Integer> (new SatVisitor.FormulaComparator ());
        BooleanFormula converted = StructurePreservingConverter.convert(full);
        BooleanFormula cnf = converted.convertToCNF();
        int [][] array = StructurePreservingConverter.asArray (cnf, variables, variableMap);

        //BooleanFormula simpleFull = full.simplify ();
        //stream.println ("c " + full + "\nc ==> " + simpleFull 
        //                    + "\nc ==> " + converted
        //                    + "\nc ==> " + cnf);
        for (Iterator iter = variableMap.keySet().iterator (); iter.hasNext ();) {
            VariableReference variable = (VariableReference) iter.next ();
            stream.println ("c " + variable + " == " + variableMap.get (variable));
        }
        stream.println ("p cnf " + variables[0] + " " + array.length);

        for (int i = 0; i < array.length; i++) {
            for (int j = 0; j < array[i].length; j++) {
                if (j != 0) stream.print (' ');
                stream.print (array[i][j]);
            }
            stream.println (" 0");
        }
    }

}

// arch-tag: AlloySatOutput.java May 28, 2005 12:32:37 AM
