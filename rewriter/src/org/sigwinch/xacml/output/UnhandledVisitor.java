package org.sigwinch.xacml.output;

import java.io.PrintWriter;
import java.util.HashSet;

import org.sigwinch.xacml.tree.ExistentialPredicate;
import org.sigwinch.xacml.tree.FunctionCallPredicate;
import org.sigwinch.xacml.tree.FunctionVisitorImpl;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.VariableReference;
import org.sigwinch.xacml.tree.Visitor;



/**
 * UnhandledVisitor.java
 *
 *
 * Created: Mon Nov 17 18:09:03 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class UnhandledVisitor extends CodeVisitor {
    HashSet<Integer> indexesSeen;
    public UnhandledVisitor(PrintWriter stream) {
	super (stream);
	indexesSeen = new HashSet<Integer> ();
    }

    @Override
    public void outputStart () {
	stream.println ("one sig X {");
    }

    @Override
    public void walkExistentialPredicate (ExistentialPredicate 
					  existentialPredicate) {
	UnhandledFunctionVisitor v = 
	    new UnhandledFunctionVisitor (this);
	v.visitFunction (existentialPredicate.getFunction (),
			 new Predicate [] {
			     new VariableReference
			     ("x" + existentialPredicate.getIndex ()),
			     existentialPredicate.getAttribute ()
			 }, existentialPredicate.getIndex ());
    }

    /**
     * Walk the given function call.
     *
     * @param functionCallPredicate a <code>FunctionCallPredicate</code>
     */
    @Override
    public void walkFunctionCallPredicate (FunctionCallPredicate 
					   functionCallPredicate) {
	UnhandledFunctionVisitor v = 
	    new UnhandledFunctionVisitor (this);
	v.visitFunction (functionCallPredicate);
    }
    
    class UnhandledFunctionVisitor extends FunctionVisitorImpl {
	UnhandledFunctionVisitor (Visitor visitor) {
	    super (visitor);
	}

	/**
	 * Handle bag-size functions.
	 *
	 * @param predicate a <code>Predicate</code> value
	 */
    @Override
	public void visitSize(Predicate predicate) {
	    outputFunction ("Integer");
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
	    outputFunction ("Bool");
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
	    outputFunction ("Bool");
	}

	/**
	 * Handle less-than
	 *
	 * @param predicate a <code>Predicate</code> value
	 * @param predicate1 a <code>Predicate</code> value
	 */
    @Override
	public void visitLessThan(Predicate predicate, Predicate predicate1) {
	    outputFunction ("Bool");
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
	    outputFunction ("Bool");
	}
	
	/**
	 * Handle the unhandled methods.
	 *
	 * @param string function name
	 * @param arguments function arguments
	 */
    @Override
	public void visitDefault(String string, Predicate[] arguments) {
	    outputFunction ("Bool"); // not guaranteed, we punt
	}
	
	void outputFunction (String returnType) {
	    if (indexesSeen.contains (new Integer (index)))
		return;
	    printConstant ("expr" + index, returnType, name);
	    indexesSeen.add (new Integer (index));
	}
    }
}
/* arch-tag: 30BAA7FA-196C-11D8-96E8-000A95A2610A
 */
