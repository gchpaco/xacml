package org.sigwinch.xacml.output.alloycommon;

import java.util.Map;
import org.sigwinch.xacml.tree.ConstantValuePredicate;
import org.sigwinch.xacml.tree.FunctionCallPredicate;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.VisitorImpl;
import org.sigwinch.xacml.tree.FunctionVisitorImpl;
import java.util.Set;
import java.util.HashSet;


/**
 * StaticVisitor.java
 *
 *
 * Created: Sun Nov 23 20:52:27 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class StaticVisitor extends VisitorImpl {
    Map<String, Integer> map;
    Set<Integer> alreadySeen;
    public StaticVisitor(Map<String, Integer> map) {
	this.map = map;
	this.alreadySeen = new HashSet<Integer> ();
    } // StaticVisitor constructor

    public void incrementType (String name) {
	if (! map.containsKey (name))
	    map.put (name, new Integer (0));
	map.put (name, 
		 new Integer (map.get (name).intValue () + 1));
    }

    @Override
    public void walkConstantValuePredicate (ConstantValuePredicate
					    predicate) {
	if (alreadySeen.contains (new Integer (predicate.getIndex ())))
	    return;
	alreadySeen.add (new Integer (predicate.getIndex ()));
	incrementType (predicate.getShortName ());
    }

    @Override
    public void walkFunctionCallPredicate (FunctionCallPredicate 
					   functionCallPredicate) {
	if (alreadySeen.contains (new Integer
				  (functionCallPredicate.getIndex ())))
	    return;
	alreadySeen.add (new Integer (functionCallPredicate.getIndex ()));
	StaticFunctionVisitor v = 
	    new StaticFunctionVisitor (this);
	v.visitFunction (functionCallPredicate);
    }

    class StaticFunctionVisitor extends FunctionVisitorImpl {
	StaticVisitor v;
	StaticFunctionVisitor (StaticVisitor visitor) {
	    super (visitor);
	    this.v = visitor;
	}

	/**
	 * Handle bag-size functions.
	 *
	 * @param predicate a <code>Predicate</code> value
	 */
    @Override
	public void visitSize(Predicate predicate) {
	    v.incrementType ("Integer");
	    super.visitSize (predicate);
	}

	/**
	 * Handle greater-than functions.
	 *
	 * @param predicate a <code>Predicate</code> value
	 * @param predicate1 a <code>Predicate</code> value
	 */
    @Override
	public void visitGreaterThan (Predicate predicate, 
				      Predicate predicate1) {
	    v.incrementType ("Bool");
	    super.visitGreaterThan (predicate, predicate1);
	}

	/**
	 * Handle greater-than-or-equal
	 *
	 * @param predicate a <code>Predicate</code> value
	 * @param predicate1 a <code>Predicate</code> value
	 */
    @Override
	public void visitGreaterThanOrEqual (Predicate predicate, 
					     Predicate predicate1) {
	    v.incrementType ("Bool");
	    super.visitGreaterThanOrEqual (predicate, predicate1);
	}

	/**
	 * Handle less-than
	 *
	 * @param predicate a <code>Predicate</code> value
	 * @param predicate1 a <code>Predicate</code> value
	 */
    @Override
	public void visitLessThan(Predicate predicate, Predicate predicate1) {
	    v.incrementType ("Bool");
	    super.visitLessThan (predicate, predicate1);
	}

	/**
	 * Handle less-than-or-equal
	 *
	 * @param predicate a <code>Predicate</code> value
	 * @param predicate1 a <code>Predicate</code> value
	 */
    @Override
	public void visitLessThanOrEqual (Predicate predicate, 
					  Predicate predicate1) {
	    v.incrementType ("Bool");
	    super.visitLessThanOrEqual (predicate, predicate1);
	}
	
	/**
	 * Handle the unhandled methods.
	 *
	 * @param string function name
	 * @param arguments function arguments
	 */
    @Override
	public void visitDefault(String string, Predicate[] arguments) {
	    v.incrementType ("Bool");
	    super.visitDefault (string, arguments);
	}
    }
} // StaticVisitor
