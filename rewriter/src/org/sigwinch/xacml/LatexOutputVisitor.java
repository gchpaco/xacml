package org.sigwinch.xacml;

import java.io.PrintWriter;

import org.sigwinch.xacml.tree.*;
import org.sigwinch.xacml.tree.Error;



/**
 * Write to the given stream a LaTeX coding of the given tree.
 *
 *
 * Created: Fri Nov  7 00:24:05 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class LatexOutputVisitor implements Visitor {
    /** Stream to output to. */
    final PrintWriter stream;
    /** Number of temporary variables generated so far.  Important for
     * uniqueness. */
    int variables;
    public LatexOutputVisitor(PrintWriter stream) {
	this.stream = stream;
	variables = 0;
    }

    /**
     * Gets the value of stream
     *
     * @return the value of stream
     */
    public PrintWriter getStream()  {
	return this.stream;
    }

    /**
     * Gets the value of variables
     *
     * @return the value of variables
     */
    public int getVariables()  {
	return this.variables;
    }

    void wrapParens (Tree node) {
	if (node.isFunction ())
	    node.walk (this);
	else {
	    stream.print ("(");
	    node.walk (this);
	    stream.print (")");
	}
    }
    
    void wrapParens (Predicate node) {
	if (node.isFunction ())
	    node.walk (this);
	else {
	    stream.print ("(");
	    node.walk (this);
	    stream.print (")");
	}
    }

    void printRule (String symbol, Tree left, Tree right, Tree node) {
	wrapParens (left);
	stream.print (" " + symbol + " ");
	if (node.getClass ().isInstance (right))
	    right.walk (this);
	else
	    wrapParens (right);
    }
    
    // Implementation of org.sigwinch.xacml.tree.Visitor

    /**
     * Write the given <code>Deny</code> node to <code>stream</code>.
     *
     * @param deny node to write
     */
    public void walkDeny(Deny deny) {
	stream.print ("Deny");
    }

    /**
     * Write the given <code>Permit</code> node to <code>stream</code>.
     *
     * @param permit node to write
     */
    public void walkPermit(Permit permit) {
	stream.print ("Permit");
    }

    /**
     * Write the given <code>Error</code> node to <code>stream</code>.
     *
     * @param error node to write
     */
    public void walkError(Error error) {
	stream.print ("Error (");
	error.getChild ().walk (this);
	stream.print (", ");
	error.getCondition ().walk (this);
	stream.print (")");
    }

    /**
     * Write the given <code>Scope</code> node to <code>stream</code>.
     *
     * @param scope node to write
     */
    public void walkScope(Scope scope) {
	stream.print ("Scope (");
	scope.getChild ().walk (this);
	stream.print (", ");
	scope.getCondition ().walk (this);
	stream.print (")");
    }

    /**
     * Write the given triple to <code>stream</code>.
     *
     * @param triple node to write
     */
    public void walkTriple (Triple triple) {
	stream.print ("\\langle ");
	triple.getPermit ().walk (this);
	stream.print (", ");
	triple.getDeny ().walk (this);
	stream.print (", ");
	triple.getError ().walk (this);
	stream.print (" \\rangle");
    }

    /**
     * Write the given <code>PermitOverridesRule</code> node to
     * <code>stream</code>.
     *
     * @param permitOverridesRule node to write
     */
    public void walkPermitOverridesRule
	(PermitOverridesRule permitOverridesRule) {
	printRule ("\\oplus", permitOverridesRule.getLeft (),
		   permitOverridesRule.getRight (), permitOverridesRule);
    }

    /**
     * Write the given <code>DenyOverridesRule</code> node to
     * <code>stream</code>.
     *
     * @param denyOverridesRule node to write
     */
    public void walkDenyOverridesRule(DenyOverridesRule denyOverridesRule) {
	printRule ("\\ominus", denyOverridesRule.getLeft (),
		   denyOverridesRule.getRight (), denyOverridesRule);
    }

    /**
     * Write the given <code>OnlyOneRule</code> node to <code>stream</code>.
     *
     * @param onlyOneRule node to write
     */
    public void walkOnlyOneRule(OnlyOneRule onlyOneRule) {
	printRule ("\\otimes", onlyOneRule.getLeft (),
		   onlyOneRule.getRight (), onlyOneRule);
    }

    /**
     * Write the given <code>FirstApplicableRule</code> node to
     * <code>stream</code>.
     *
     * @param firstApplicableRule node to write
     */
    public void walkFirstApplicableRule
	(FirstApplicableRule firstApplicableRule) {
	printRule ("\\oslash", firstApplicableRule.getLeft (),
		   firstApplicableRule.getRight (), firstApplicableRule);
    }

    /**
     * Write the given <code>AndPredicate</code> node to
     * <code>stream</code>.
     *
     * @param andPredicate node to write
     */
    public void walkAndPredicate(AndPredicate andPredicate) {
	wrapParens (andPredicate.getLeft ());
	stream.print (" \\wedge ");
	Predicate right = andPredicate.getRight ();
	if (right instanceof AndPredicate)
	    right.walk (this);
	else
	    wrapParens (right);
    }

    /**
     * Write the given <code>ConstantValuePredicate</code> node to
     * <code>stream</code>.
     *
     * @param constantValuePredicate node to write
     */
    public void walkConstantValuePredicate (ConstantValuePredicate 
					    constantValuePredicate) {
	stream.print (constantValuePredicate.getShortName ());
	stream.print (" (\\verb|\"");
	stream.print (constantValuePredicate.getValue ());
	stream.print ("\"|)");
    }

    /**
     * Write the given <code>EnvironmentalPredicate</code> node to
     * <code>stream</code>.
     *
     * @param environmentalPredicate node to write
     */
    public void walkEnvironmentalPredicate(EnvironmentalPredicate 
					   environmentalPredicate) {
	stream.print ("E[");
	stream.print (environmentalPredicate.getUniqueId ());
	stream.print ("]");
    }

    /**
     * Write the given <code>ExistentialPredicate</code> node to
     * <code>stream</code>.
     *
     * @param existentialPredicate node to write
     */
    public void walkExistentialPredicate(ExistentialPredicate
					 existentialPredicate) {
	int myvar = variables++;
	stream.print ("\\exists x_{");
	stream.print (myvar);
	stream.print ("} \\in ");
	wrapParens (existentialPredicate.getBag ());
	stream.print (" ");
	new FunctionCallPredicate (existentialPredicate.getFunction (),
				   new Predicate[] {
				       new VariableReference ("x_{" + myvar +
							      "}"),
				       existentialPredicate.getAttribute ()
				   }).walk (this);
    }

    /**
     * Write the given <code>FunctionCallPredicate</code> node to
     * <code>stream</code>.
     *
     * @param functionCallPredicate node to write
     */
    public void walkFunctionCallPredicate(FunctionCallPredicate
					  functionCallPredicate) {
	LatexFunctionVisitor v = new LatexFunctionVisitor (this, stream);
	v.visitFunction (functionCallPredicate);
    }

    /**
     * Write the given <code>OrPredicate</code> node to <code>stream</code>.
     *
     * @param orPredicate node to write
     */
    public void walkOrPredicate(OrPredicate orPredicate) {
	wrapParens (orPredicate.getLeft ());
	stream.print (" \\vee ");
	Predicate right = orPredicate.getRight ();
	if (right instanceof OrPredicate)
	    right.walk (this);
	else
	    wrapParens (right);
    }

    /**
     * Write the given <code>SimplePredicate</code> node to
     * <code>stream</code>.
     *
     * @param simplePredicate node to write
     */
    public void walkSimplePredicate(SimplePredicate simplePredicate) {
	if (simplePredicate == SimplePredicate.TRUE)
	    stream.print ("true");
	else
	    stream.print ("false");
    }

    /**
     * Write the given <code>SolePredicate</code> node to
     * <code>stream</code>.
     *
     * @param solePredicate node to write
     */
    public void walkSolePredicate (SolePredicate solePredicate) {
	stream.print ("|");
	solePredicate.getSet ().walk (this);
	stream.print ("| = 1");
    }

    /**
     * Write the given <code>VariableReference</code> node to
     * <code>stream</code>.
     *
     * @param variableReference node to write
     */
    public void walkVariableReference(VariableReference variableReference) {
	stream.print (variableReference.getName ());
    }

    static class LatexFunctionVisitor extends FunctionVisitor {
	LatexOutputVisitor visitor;
	PrintWriter stream;
	LatexFunctionVisitor (LatexOutputVisitor visitor, PrintWriter stream) {
	    this.visitor = visitor;
	    this.stream = stream;
	}

	// Implementation of org.sigwinch.xacml.tree.FunctionVisitor

	/**
	 * Write the size methods to <code>stream</code>.
	 *
	 * @param predicate a <code>Predicate</code> value
	 */
	@Override
    public void visitSize(Predicate predicate) {
	    stream.print ("|");
	    predicate.walk (visitor);
	    stream.print ("|");
	}

	/**
	 * Write the set inclusion methods to <code>stream</code>.
	 *
	 * @param element a <code>Predicate</code> value
	 * @param set a <code>Predicate</code> value
	 */
	@Override
    public void visitInclusion(Predicate element, Predicate set) {
	    visitor.wrapParens (element);
	    stream.print (" \\in ");
	    visitor.wrapParens (set);
	}

	/**
	 * Write the set creation functions to <code>stream</code>.
	 *
	 * @param predicate a <code>Predicate</code> value
	 */
	@Override
    public void visitSetCreation(Predicate predicate) {
	    stream.print ("\\{");
	    predicate.walk (visitor);
	    stream.print ("\\}");
	}

	/**
	 * Write the equality methods to <code>stream</code>.
	 *
	 * @param first a <code>Predicate</code> value
	 * @param second a <code>Predicate</code> value
	 */
	@Override
    public void visitEquality(Predicate first, Predicate second) {
	    visitor.wrapParens (first);
	    stream.print (" = ");
	    visitor.wrapParens (second);
	}

	/**
	 * Write the intersection functions to <code>stream</code>.
	 *
	 * @param first a <code>Predicate</code> value
	 * @param second a <code>Predicate</code> value
	 */
	@Override
    public void visitIntersection(Predicate first, Predicate second) {
	    visitor.wrapParens (first);
	    stream.print (" \\cap ");
	    visitor.wrapParens (second);
	}

	/**
	 * Write the union functions to <code>stream</code>.
	 *
	 * @param first a <code>Predicate</code> value
	 * @param second a <code>Predicate</code> value
	 */
	@Override
    public void visitUnion(Predicate first, Predicate second) {
	    visitor.wrapParens (first);
	    stream.print (" \\cup ");
	    visitor.wrapParens (second);
	}

	/**
	 * Write the subset functions to <code>stream</code>.
	 *
	 * @param first a <code>Predicate</code> value
	 * @param second a <code>Predicate</code> value
	 */
	@Override
    public void visitSubset(Predicate first, Predicate second) {
	    visitor.wrapParens (first);
	    stream.print (" \\subseteq ");
	    visitor.wrapParens (second);
	}

	/**
	 * Write the at-least-one methods to <code>stream</code>.
	 *
	 * @param first a <code>Predicate</code> value
	 * @param second a <code>Predicate</code> value
	 */
    @Override
	public void visitAtLeastOne(Predicate first, Predicate second) {
	    visitor.wrapParens (first);
	    stream.print (" \\cap ");
	    visitor.wrapParens (second);
	    stream.print (" \\neq \\nullset");
	}

	/**
	 * Write the set equality methods to <code>stream</code>.
	 *
	 * @param first a <code>Predicate</code> value
	 * @param second a <code>Predicate</code> value
	 */
    @Override
	public void visitSetEquality(Predicate first, Predicate second) {
	    stream.print ("(");
	    visitor.wrapParens (first);
	    stream.print (" \\subseteq ");
	    visitor.wrapParens (second);
	    stream.print (") \\wedge (");
	    visitor.wrapParens (second);
	    stream.print (" \\subseteq ");
	    visitor.wrapParens (first);
	    stream.print (")");
	}

	/**
	 * Write the greater-than functions to <code>stream</code>.
	 *
	 * @param first a <code>Predicate</code> value
	 * @param second a <code>Predicate</code> value
	 */
    @Override
	public void visitGreaterThan(Predicate first, Predicate second) {
	    visitor.wrapParens (first);
	    stream.print (" > ");
	    visitor.wrapParens (second);
	}

	/**
	 * Write the greater-than-or-equal methods to <code>stream</code>.
	 *
	 * @param first a <code>Predicate</code> value
	 * @param second a <code>Predicate</code> value
	 */
    @Override
	public void visitGreaterThanOrEqual(Predicate first, 
					    Predicate second) {
	    visitor.wrapParens (first);
	    stream.print (" \\geq ");
	    visitor.wrapParens (second);
	}

	/**
	 * Write the less-than functions to <code>stream</code>.
	 *
	 * @param first a <code>Predicate</code> value
	 * @param second a <code>Predicate</code> value
	 */
    @Override
	public void visitLessThan(Predicate first, Predicate second) {
	    visitor.wrapParens (first);
	    stream.print (" < ");
	    visitor.wrapParens (second);
	}

	/**
	 * Write the less-than-or-equal functions to <code>stream</code>.
	 *
	 * @param first a <code>Predicate</code> value
	 * @param second a <code>Predicate</code> value
	 */
    @Override
	public void visitLessThanOrEqual(Predicate first, Predicate second) {
	    visitor.wrapParens (first);
	    stream.print (" \\leq ");
	    visitor.wrapParens (second);
	}

	/**
	 * Write the and function to <code>stream</code>.
	 *
	 * @param arguments function arguments
	 */
    @Override
	public void visitAnd(Predicate [] arguments) {
	    for (int i = 0; i < arguments.length; i++) {
		if (i != 0) stream.print (" \\wedge ");
		visitor.wrapParens (arguments[i]);
	    }
	}

	/**
	 * Write the or function to <code>stream</code>.
	 *
	 * @param arguments function arguments
	 */
    @Override
	public void visitOr(Predicate [] arguments) {
	    for (int i = 0; i < arguments.length; i++) {
		if (i != 0) stream.print (" \\vee ");
		visitor.wrapParens (arguments[i]);
	    }
	}

	/**
	 * Write the not function to <code>stream</code>.
	 *
	 * @param predicate a <code>Predicate</code> value
	 */
    @Override
	public void visitNot(Predicate predicate) {
	    stream.print ("\\neg ");
	    visitor.wrapParens (predicate);
	}

	/**
	 * Write miscellaneous functions
	 *
	 * @param string function name
	 * @param arguments function arguments
	 */
    @Override
	public void visitDefault(String string, Predicate[] arguments) {
	    stream.print (string);
	    stream.print (" (");
	    for (int i = 0; i < arguments.length; i++) {
		if (i != 0) stream.print (", ");
		arguments[i].walk (visitor);
	    }
	    stream.print (")");
	}
    }
}
/* arch-tag: C694C2BA-10FB-11D8-ABAA-000A95A2610A
 */
