/*
 * Created on May 28, 2005
 */
package org.sigwinch.xacml.output.sat;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.*;

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

    private Map<BooleanFormula, Integer> variableMap;

    public AlloySatOutput(PrintWriter stream, double slop) {
        this.stream = stream;
        this.slop = slop;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.Output#preamble(org.sigwinch.xacml.tree.Tree)
     */
    public void preamble(Tree tree) {
        sat = new SatVisitor();
        sat.setMultiplicity((int) slop);
        vars = 0;
        var2num = new HashMap<Object, Integer>();
        formulae = new TreeSet<BooleanFormula>(
                new SatVisitor.FormulaComparator());
        lastTree = null;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.Output#write(org.sigwinch.xacml.tree.Tree)
     */
    public void write(Tree tree) {
        tree.walk(sat);
        BooleanFormula formula = sat.computeFormula();
        formula.visit(new FormulaImpl() {
            @Override
            public void visitVariable(VariableReference var) {
                super.visitVariable(var);
                putVariable(var);
            }

            @Override
            public void visitTrue(PrimitiveBoolean t) {
                super.visitTrue(t);
                putVariable(t);
            }

            @Override
            public void visitFalse(PrimitiveBoolean f) {
                super.visitFalse(f);
                putVariable(f);
            }

            private void putVariable(Object var) {
                if (!var2num.containsKey(var)) {
                    var2num.put(var, new Integer(++vars));
                }
            }
        });
        if (formula instanceof And)
            formulae.addAll(Arrays.asList(((And) formula).objects));
        else
            formulae.add(formula);
        if (tree instanceof Triple) {
            Triple triple = (Triple) tree;
            if (lastTree == null)
                lastTree = triple;
            else {
                formulae.add(sat.generateImplications(lastTree, triple));
                lastTree = triple;
            }
        }
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.Output#postamble()
     */
    public void postamble() {
        BooleanFormula[] allFormulae = formulae
                .toArray(new BooleanFormula[] {});
        And full = new And(allFormulae);
        int variables[] = new int[] { 0 };
        variableMap = new TreeMap<BooleanFormula, Integer>(
                        new SatVisitor.FormulaComparator());
        BooleanFormula converted = StructurePreservingConverter.convert(full);
        BooleanFormula cnf = converted.convertToCNF();
        int[][] array = StructurePreservingConverter.asArray(cnf, variables,
                variableMap);

        // stream.println ("c " + converted);
        for (Iterator iter = variableMap.keySet().iterator(); iter.hasNext();) {
            VariableReference variable = (VariableReference) iter.next();
            stream
                    .println("c " + variable + " == "
                            + variableMap.get(variable));
        }
        stream.println("p cnf " + variables[0] + " " + array.length);

        for (int i = 0; i < array.length; i++) {
            for (int j = 0; j < array[i].length; j++) {
                if (j != 0)
                    stream.print(' ');
                stream.print(array[i][j]);
            }
            stream.println(" 0");
        }
    }

    public void roundTripOn(File aFile) throws IOException {
        InputStream zchaff = getClass().getResourceAsStream("/zchaff");
        File executable = File.createTempFile("zchaff", ".exe");
        executable.deleteOnExit();
        OutputStream writer = new FileOutputStream(executable);
        copyStream(zchaff, writer);
        zchaff.close();
        writer.close();
        try {
            Runtime.getRuntime().exec(
                    new String[] { "chmod", "755", executable.getAbsolutePath() }).waitFor ();
        } catch (InterruptedException e) {
        }
        boolean isValid = false;
        Set<Integer> exceptions = new HashSet<Integer> ();
        try {
            Process process = Runtime.getRuntime().exec(
                    new String[] { executable.getAbsolutePath(),
                            aFile.getAbsolutePath() });
            BufferedReader result = new BufferedReader (new InputStreamReader (process.getInputStream ()));
            while (true) {
                String line = result.readLine ();
                if (line == null) break;
                if (line.startsWith("RESULT:"))
                    isValid = line.endsWith("UNSAT");
                String[] strings = line.split ("Random Seed Used");
                if (strings.length > 1) {
                    String[] integers = strings[0].split (" ");
                    for (int i = 0; i < integers.length; i++) {
                        exceptions.add(Integer.parseInt(integers[i]));
                    }
                }
            }
            process.waitFor();
            result.close ();
        } catch (InterruptedException e) {
        }
        if (isValid)
            System.out.println("Subsumption valid");
        else {
            System.out.println("Subsumption invalid:");
            for (Map.Entry<BooleanFormula, Integer> entry : variableMap.entrySet()) {
                String key = entry.getKey ().toString ();
                // the internal clauses are boring
                if (key.startsWith ("clause_")) continue;
                if (exceptions.contains (entry.getValue()))
                    System.out.println (key);
                else if (exceptions.contains (- entry.getValue ()))
                    System.out.println ("! " + key);
                else
                    System.out.println ("[ " + key + " not mentioned? ]");
            }
        }
    }

    private void copyStream(InputStream in, OutputStream out) throws IOException {
        byte[] b = new byte[256];
        while (true) {
            int read = in.read(b);
            if (read == -1)
                break;
            out.write(b, 0, read);
        }
    }
}

// arch-tag: AlloySatOutput.java May 28, 2005 12:32:37 AM
