package org.sigwinch.xacml.output.set;

import java.io.File;
import java.io.PrintWriter;
import java.util.Iterator;
import java.util.TreeMap;

import org.sigwinch.xacml.OutputConfiguration;
import org.sigwinch.xacml.output.Output;
import org.sigwinch.xacml.output.alloycommon.ConstantVisitor;
import org.sigwinch.xacml.output.alloycommon.DynamicVisitor;
import org.sigwinch.xacml.output.alloycommon.EnvironmentVisitor;
import org.sigwinch.xacml.output.alloycommon.StaticVisitor;
import org.sigwinch.xacml.tree.Tree;

/**
 * AlloySetOutput.java
 * 
 * 
 * Created: Mon Nov 17 20:18:42 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class AlloySetOutput implements Output {
    PrintWriter stream;

    int trees;

    private OutputConfiguration configuration;

    TreeMap<String, Integer> instances;

    public AlloySetOutput(PrintWriter stream, OutputConfiguration configuration) {
        this.stream = stream;
        this.trees = 0;
        this.configuration = configuration;
        this.instances = new TreeMap<String, Integer>();
    }

    public void preamble(Tree tree) {
        stream.println("module foo");
        stream.println("open util/boolean");
        stream.println("open util/ordering[Type] as types");
        stream.println("abstract sig Triple {");
        stream.println("\tpermit : lone E,");
        stream.println("\tdeny : lone E,");
        stream.println("\terror : lone E");
        stream.println("}");
        stream.println("abstract sig Type {}");

        StaticVisitor sv = new StaticVisitor(instances);
        tree.walk(sv);
        TreeMap<String, Integer> dynamics = new TreeMap<String, Integer>();
        DynamicVisitor dv = new DynamicVisitor(dynamics);
        tree.walk(dv);
        for (String key : dynamics.keySet()) {
            if (key.equals("Bool"))
                continue;

            Integer old;
            if (instances.containsKey(key))
                old = instances.get(key);
            else
                old = new Integer(0);
            Integer incr = dynamics.get(key);
            instances.put(key, new Integer((int) (old.intValue() + incr
                    .intValue()
                    * configuration.getSlop())));
        }

        for (String key : instances.keySet()) {
            if (key.equals("Bool"))
                continue; // bool loaded from util/bool

            stream.print("sig ");
            stream.print(key);
            stream.println(" extends Type {}");
        }

        EnvironmentVisitor ev = new EnvironmentVisitor(stream);
        ev.start();
        tree.walk(ev);
        ev.end();
        ConstantVisitor cv = new ConstantVisitor(stream);
        cv.start();
        tree.walk(cv);
        cv.end();
        SetVisitor setv = new SetVisitor();
        setv.start();
        tree.walk(setv);
        setv.end();
        stream.print(setv.getFunctions());
        stream.print(setv.getFacts());
        trees = setv.getTriples();
    }

    public void write(Tree tree) {
    }

    public void postamble() {
        if (trees >= 2) {
            stream.println("assert Subset {");
            if (configuration.isPermit())
                stream.println("\tT0.permit in T1.permit");
            if (configuration.isDeny())
                stream.println("\tT0.deny in T1.deny");
            if (configuration.isError())
                stream.println("\tT0.error in T1.error");
            stream.println("}");
        }
        for (int i = 0; i < trees; i++) {
            stream.println("pred T" + i + "OK () {");
            stream.println("\tsome T" + i + ".permit or some T" + i
                    + ".deny or some T" + i + ".error");
            stream.println("}");
        }
        for (int i = 0; i < trees; i++) {
            stream.print("run T" + i + "OK for ");
            writeTypes();
            stream.println();
        }
        if (trees >= 2) {
            stream.print("check Subset for ");
            writeTypes();
            stream.println();
        }
    }

    private void writeTypes() {
        stream.print(Math.max((int) configuration.getSlop(), 1));
        stream.print(" but 2 Bool, ");
        stream.print(trees);
        stream.print(" Triple");

        int total = 0;

        Iterator i = instances.keySet().iterator();
        while (i.hasNext()) {
            String key = (String) i.next();
            if (key.equals("Bool"))
                continue; // only ever two booleans
            total += instances.get(key).intValue();

            stream.print(", ");
            stream.print(instances.get(key));
            stream.print(" ");
            stream.print(key);
        }
        if (total > 0) {
            stream.print(", ");
            stream.print(total);
            stream.print(" Type");
        }
    }

    public void output(Tree tree) {
        preamble(tree);
        write(tree);
        postamble();
    }
    
    public void roundTripOn(File aFile) {
    }
}
/*
 * arch-tag: 3CB86A24-35D9-11D8-9CEA-000A957284DA
 */
