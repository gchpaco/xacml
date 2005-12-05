package org.sigwinch.xacml.output;

import org.sigwinch.xacml.tree.VisitorImpl;
import org.sigwinch.xacml.tree.ExistentialPredicate;
import java.io.PrintWriter;
import org.sigwinch.xacml.tree.Visitor;
import org.sigwinch.xacml.tree.FunctionVisitorImpl;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.FunctionCallPredicate;



/**
 * ExistentialVisitor.java
 *
 *
 * Created: Mon Nov 24 01:27:18 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class ExistentialVisitor extends VisitorImpl {
    PrintWriter stream;
    Visitor caller;
    boolean inverted;
    public ExistentialVisitor(Visitor caller, PrintWriter stream) {
	this.stream = stream;
	this.caller = caller;
	this.inverted = false;
    } // ExistentialVisitor constructor

    public void toggle () { inverted = ! inverted; }

    /**
     * Describe <code>walkExistentialPredicate</code> method here.
     *
     * @param existentialPredicate an <code>ExistentialPredicate</code> value
     */
    public void walkExistentialPredicate (ExistentialPredicate
					  existentialPredicate) {
	if (inverted)
	    stream.print ("all x");
	else
	    stream.print ("some x");
	stream.print (existentialPredicate.getIndex ());
	stream.print (": ");
	existentialPredicate.getBag ().walk (caller);
	stream.print (" | ");
	existentialPredicate.getAttribute ().walk (this);
    }
    
    public void walkFunctionCallPredicate (FunctionCallPredicate 
					   functionCallPredicate) {
	ExistentialFunctionVisitor v = 
	    new ExistentialFunctionVisitor (this);
	v.visitFunction (functionCallPredicate);
    }

    class ExistentialFunctionVisitor extends FunctionVisitorImpl
    {
	ExistentialFunctionVisitor (Visitor visitor)
	{
	    super (visitor);
	}

	public void visitNot (Predicate predicate)
	{
	    ((ExistentialVisitor) visitor).toggle ();
	    super.visitNot (predicate);
	}
    }
} // ExistentialVisitor
