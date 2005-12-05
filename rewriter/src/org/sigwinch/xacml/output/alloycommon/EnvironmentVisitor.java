package org.sigwinch.xacml.output.alloycommon;

import java.io.PrintWriter;
import java.util.Hashtable;

import org.sigwinch.xacml.output.CodeVisitor;
import org.sigwinch.xacml.tree.EnvironmentalPredicate;



/**
 * EnvironmentVisitor.java
 *
 *
 * Created: Mon Nov 17 16:31:58 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class EnvironmentVisitor extends CodeVisitor {
    Hashtable indexesSeen;
    public EnvironmentVisitor(PrintWriter stream) {
	super (stream);
	indexesSeen = new Hashtable ();
    }

    public void outputStart () {
	stream.println ("one sig E {");
    }

    /**
     * Output the environmental information for use with Alloy.
     *
     * @param environmentalPredicate an <code>EnvironmentalPredicate</code>
     */
    public void walkEnvironmentalPredicate (EnvironmentalPredicate 
					    environmentalPredicate) {
	if (indexesSeen.containsKey (new Integer 
				     (environmentalPredicate.getUniqueId ())))
	    return;
	printSet ("env" + environmentalPredicate.getUniqueId (),
		  environmentalPredicate.getShortName (),
		  environmentalPredicate.getId ());
	indexesSeen.put (new Integer (environmentalPredicate.getUniqueId ()),
			 Boolean.TRUE);
    }
    
}
/* arch-tag: A1182750-195E-11D8-B1BE-000A95A2610A
 */
