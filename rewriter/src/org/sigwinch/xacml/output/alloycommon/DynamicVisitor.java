package org.sigwinch.xacml.output.alloycommon;

import org.sigwinch.xacml.tree.VisitorImpl;
import java.util.Map;
import org.sigwinch.xacml.tree.EnvironmentalPredicate;
import java.util.Set;
import java.util.HashSet;



/**
 * DynamicVisitor.java
 *
 *
 * Created: Sun Nov 23 21:09:46 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class DynamicVisitor extends VisitorImpl {
    Map<String, Integer> map;
    Set<Integer> alreadySeen;
    public DynamicVisitor(Map<String, Integer> map) {
	this.map = map;
	this.alreadySeen = new HashSet<Integer> ();
    } // DynamicVisitor constructor

    public void incrementType (String name) {
	if (! map.containsKey (name))
	    map.put (name, new Integer (0));
	map.put (name, 
		 new Integer (map.get (name).intValue () + 1));
    }

    /**
     * Pull out types used for environmental predicates.
     *
     * @param environmentalPredicate an <code>EnvironmentalPredicate</code>
     */
    @Override
    public void walkEnvironmentalPredicate (EnvironmentalPredicate
					    environmentalPredicate) {
	if (alreadySeen.contains (new Integer
				  (environmentalPredicate.getUniqueId ())))
	    return;
	alreadySeen.add (new Integer (environmentalPredicate.getUniqueId ()));
	incrementType (environmentalPredicate.getShortName ());
    }
    
} // DynamicVisitor
