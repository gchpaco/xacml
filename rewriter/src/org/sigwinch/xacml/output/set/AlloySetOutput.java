package org.sigwinch.xacml.output.set;

import java.io.PrintWriter;
import java.util.Iterator;
import java.util.TreeMap;

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
    double slop;
    TreeMap instances;
    public AlloySetOutput(PrintWriter stream, double slop) {
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
	stream.println ("\tpermit : lone E,");
	stream.println ("\tdeny : lone E,");
	stream.println ("\terror : lone E");
	stream.println ("}");
	stream.println ("abstract sig Type {}");

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
	    if (key.equals ("Bool")) continue; // bool loaded from util/bool
	
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
	SetVisitor setv = new SetVisitor ();
	setv.start ();
	tree.walk (setv);
	setv.end ();
	stream.print (setv.getFunctions ());
	stream.print (setv.getFacts ());
	trees = setv.getTriples ();
    }

    public void write (Tree tree) {
    }

    public void postamble () {
	if (trees >= 2) {
	    stream.println ("assert Subset {");
	    stream.println ("\tT0.permit in T1.permit");
	    stream.println ("\tT0.deny in T1.deny");
	    stream.println ("\tT0.error in T1.error");
	    stream.println ("}");
	}
	for (int i = 0; i < trees; i++) {
	    stream.println ("pred T" + i + "OK () {");
	    stream.println ("\tsome T" + i + ".permit or some T" + i +
			    ".deny or some T" + i + ".error");
	    stream.println ("}");
	}
	for (int i = 0; i < trees; i++) {
	    stream.print ("run T" + i + "OK for ");
	    writeTypes ();
	    stream.println ();
	}
	if (trees >= 2) {
	    stream.print ("check Subset for ");
	    writeTypes ();
	    stream.println ();
	}
    }

    private void writeTypes () {
	stream.print (Math.max ((int) slop, 1));
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
    }
    
    public void output (Tree tree) {
	preamble (tree);
	write (tree);
	postamble ();
    }
}
/* arch-tag: 3CB86A24-35D9-11D8-9CEA-000A957284DA
 */
