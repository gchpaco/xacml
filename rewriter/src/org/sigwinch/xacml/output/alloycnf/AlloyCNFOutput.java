package org.sigwinch.xacml.output.alloycnf;

import java.io.PrintWriter;

import org.sigwinch.xacml.output.Output;
import org.sigwinch.xacml.output.alloycommon.ConstantVisitor;
import org.sigwinch.xacml.output.alloycommon.DynamicVisitor;
import org.sigwinch.xacml.output.alloycommon.EnvironmentVisitor;
import org.sigwinch.xacml.output.alloycommon.StaticVisitor;
import org.sigwinch.xacml.tree.Tree;
import java.util.TreeMap;
import java.util.Map;
import java.util.Iterator;



/**
 * AlloyCNFOutput.java
 *
 *
 * Created: Mon Nov 17 20:18:42 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class AlloyCNFOutput implements Output {
    PrintWriter stream;
    int trees;
    double slop;
    TreeMap instances;
    Map map;
    public AlloyCNFOutput(PrintWriter stream, double slop) {
	this.stream = stream;
	this.trees = 0;
	this.slop = slop;
	this.instances = new TreeMap ();
    }

    public void preamble (Tree tree) {
	stream.println ("module foo");
	stream.println ("open util/boolean");
	stream.println ("open util/ordering[Type] as types");
	stream.println ("abstract sig Triple {");
	stream.println ("\tpermit : one Bool,");
	stream.println ("\tdeny : one Bool,");
	stream.println ("\terror : one Bool");
	stream.println ("}");
	stream.println ("abstract sig Type {}");
	stream.println ("fun And (a:one Bool, b:one Bool): " +
			"one Bool {");
	stream.println ("\tresult = if (a = True && b = True) then True " +
			"else False");
	stream.println ("}");
	stream.println ("fun Or (a:one Bool, b:one Bool): " +
			"one Bool {");
	stream.println ("\tresult = if (a = False && b = False) then False " +
			"else True");
	stream.println ("}");
	stream.println ("fun Eq (a:Type, b:Type): one Bool {");
	stream.println ("\tresult = if (a = b) then True else False");
	stream.println ("}");
	stream.println ("fun In (a:Type, b:Type): one Bool {");
	stream.println ("\tresult = if (a in b) then True else False");
	stream.println ("}");
	stream.println ("fun AtLeastOne (a:Type, b:Type): one Bool {");
	stream.println ("\tresult = if (some (a & b)) then True else False");
	stream.println ("}");

	StaticVisitor sv = new StaticVisitor (instances);
	tree.walk (sv);
	TreeMap dynamics = new TreeMap ();
	DynamicVisitor dv = new DynamicVisitor (dynamics);
	tree.walk (dv);
	Iterator i = dynamics.keySet ().iterator ();
	while (i.hasNext ()) {
	    String key = (String) i.next ();
	    if (key.equals ("Bool")) continue;
	    
	    Integer old;
	    if (instances.containsKey (key))
		old = (Integer) instances.get (key);
	    else
		old = new Integer (0);
	    Integer incr = (Integer) dynamics.get (key);
	    instances.put (key,
			   new Integer ((int) (old.intValue () + 
					       incr.intValue () * slop)));
	}

	i = instances.keySet ().iterator();
	while (i.hasNext ()) {
	    String key = (String) i.next ();
	    if (key.equals ("Bool")) continue; // bool loaded from std/bool
	
	    stream.print ("sig ");
	    stream.print (key);
	    stream.println (" extends Type {}");
	}

	EnvironmentVisitor ev = new EnvironmentVisitor (stream);
	ev.start ();
	tree.walk (ev);
	ev.end ();
	ConstantVisitor cv = new ConstantVisitor (stream);
	cv.start ();
	tree.walk (cv);
	cv.end ();
	BreakdownVisitor bv = new BreakdownVisitor ();
	bv.start ();
	tree.walk (bv);
	bv.end ();
	map = bv.getMap ();
	stream.println ("one sig X {");
	stream.print (bv.getDecls ());
	stream.println ("}");
	stream.println ("fact {");
	stream.print (bv.getFacts ());
	stream.println ("}");
    }

    public void write (Tree tree) {
	OutputVisitor visitor = new OutputVisitor (stream, trees, map);
	tree.walk (visitor);
	trees = visitor.getTriples ();
    }

    public void postamble () {
	if (trees == 2) {
	    stream.println ("assert Subset {");
	    stream.println ("\t(T0.permit = True) => (T1.permit = True)");
	    stream.println ("\t(T0.deny = True) => (T1.deny = True)");
	    stream.println ("\t(T0.error = True) => (T1.error = True)");
	    stream.println ("}");

	    stream.print ("check Subset for ");
	    stream.print ((int) slop);
	    stream.print (" but 2 Bool, ");
	    stream.print (trees);
	    stream.print (" Triple");

	    int total = 0;

	    Iterator i = instances.keySet ().iterator();
	    while (i.hasNext ()) {
		String key = (String) i.next ();
		if (key.equals ("Bool")) continue; // only ever two booleans
		total += ((Integer) instances.get (key)).intValue ();

		stream.print (", ");
		stream.print (instances.get (key));
		stream.print (" ");
		stream.print (key);
	    }
	    if (total > 0) {
		stream.print (", ");
		stream.print (total);
		stream.print (" Type");
	    }

	    stream.println ();
	}
    }
    
    public void output (Tree tree) {
	preamble (tree);
	write (tree);
	postamble ();
    }
}
/* arch-tag: 4CE8E270-197E-11D8-8197-000A95A2610A
 */
