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
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

import org.sigwinch.xacml.OutputConfiguration;
import org.sigwinch.xacml.output.Output;
import org.sigwinch.xacml.output.sat.VariableEncoding.Value;
import org.sigwinch.xacml.tree.Tree;
import org.sigwinch.xacml.tree.Triple;
import org.sigwinch.xacml.tree.VariableReference;

import util.Pair;

/**
 * @author graham
 */
public class AlloySatOutput implements Output {
    PrintWriter stream;

    private int vars;

    private HashMap<Object, Integer> var2num;

    private SatVisitor sat;

    private TreeSet<BooleanFormula> formulae;

    private Triple lastTree;

    private Map<BooleanFormula, Integer> variableMap;

    private OutputConfiguration configuration;

    public AlloySatOutput(PrintWriter stream, OutputConfiguration configuration) {
        this.stream = stream;
        this.configuration = configuration;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.sigwinch.xacml.output.Output#preamble(org.sigwinch.xacml.tree.Tree)
     */
    public void preamble(Tree tree) {
        sat = new SatVisitor();
        sat.setMultiplicity((int) configuration.getSlop());
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
                formulae.add(sat.generateImplications(lastTree, triple, configuration));
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
	if (configuration.isVerbose())
	    System.out.println("Formula: " + full.simplify());
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
        long start = System.currentTimeMillis();
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
                if (strings.length > 1 && !strings[0].equals("")) {
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
        long end = System.currentTimeMillis();
        if (isValid)
            System.out.println("Subsumption valid: " + (end - start) + " ms");
        else {
            System.out.println("Subsumption invalid: " + (end - start) + " ms:");
            ArrayList<Pair<String, Boolean>> variables = new ArrayList<Pair<String,Boolean>> ();
            for (Map.Entry<BooleanFormula, Integer> entry : variableMap.entrySet()) {
                String key = entry.getKey ().toString ();
                // the internal clauses are boring
                if (key.startsWith("clause_"))
                    continue;
                if (exceptions.contains(entry.getValue()))
                    variables.add(Pair.make(key, true));
                else if (exceptions.contains(-entry.getValue()))
                    variables.add(Pair.make(key, false));
                else
                    System.out.println("[ " + key + " not mentioned? ]");
            }
            Collections.sort(variables, new Comparator<Pair<String, Boolean>> () {
                public int compare(Pair<String, Boolean> arg0, Pair<String, Boolean> arg1) {
                    String base0 = VariableEncoding.baseNameOf(arg0.first);
                    String base1 = VariableEncoding.baseNameOf(arg1.first);
                    if (base0 == null) {
                        if (base1 == null)
                            return 0;
                        return -1;
                    }
                    if (base1 == null)
                        return 1;
                    return base0.compareTo(base1);
                }
            });
            // goal is to gather the string and booleans for all consecutive
            // pairs with the same base, unless that base is null; if it is
            // null, register each individually.
            ArrayList<String> currentStrings = new ArrayList<String>();
            ArrayList<Boolean> currentBooleans = new ArrayList<Boolean>();
            boolean queueing = false;
            String lastBase = null;
            for (Pair<String, Boolean> pair : variables) {
                String currentBase = VariableEncoding.baseNameOf(pair.first);
                if (queueing) {
                    // queueing => lastBase != null
                    if (currentBase == null || !currentBase.equals(lastBase)) {
                        outputData(currentStrings, currentBooleans);
                        currentStrings = new ArrayList<String>();
                        currentBooleans = new ArrayList<Boolean>();
                        if (currentBase == null) {
                            queueing = false;
                            outputData(Collections.singletonList(pair.first),
                                    Collections.singletonList(pair.second));
                        } else {
                            queueing = true;
                            currentStrings.add(pair.first);
                            currentBooleans.add(pair.second);
                        }
                        lastBase = currentBase;
                    } else {
                        currentStrings.add(pair.first);
                        currentBooleans.add(pair.second);
                    }
                } else {
                    if (currentBase == null) {
                        queueing = false;
                        outputData(Collections.singletonList(pair.first),
                                Collections.singletonList(pair.second));
                    } else {
                        queueing = true;
                        currentStrings.add(pair.first);
                        currentBooleans.add(pair.second);
                    }
                }
            }
            if (queueing)
                outputData (currentStrings, currentBooleans);
        }
    }

    private void outputData(List<String> strings, List<Boolean> booleans) {
        String[] strs = strings.toArray(new String[strings.size()]);
        Boolean[] bbools = booleans.toArray(new Boolean[booleans.size()]);
        boolean[] bools = new boolean[bbools.length];
        for (int i = 0; i < bools.length; i++) {
            bools[i] = bbools[i];
        }
        Value value = VariableEncoding.decode(strs, bools);
        System.out.println(value);
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
