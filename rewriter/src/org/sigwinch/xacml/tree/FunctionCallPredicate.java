package org.sigwinch.xacml.tree;
import org.sigwinch.xacml.tree.Predicate;

/**
 * FunctionCallPredicate.java
 *
 *
 * Created: Tue Nov  4 19:29:32 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class FunctionCallPredicate extends Predicate {
    String function;
    Predicate[] arguments;
    public FunctionCallPredicate(String func, Predicate[] args) {
	function = func; arguments = args;
    }

    /**
     * Gets the value of function
     *
     * @return the value of function
     */
    public String getFunction()  {
	return this.function;
    }

    /**
     * Sets the value of function
     *
     * @param argFunction Value to assign to this.function
     */
    public void setFunction(String argFunction) {
	this.function = argFunction;
    }

    /**
     * Gets the value of arguments
     *
     * @return the value of arguments
     */
    public Predicate[] getArguments()  {
	return this.arguments;
    }

    /**
     * Sets the value of arguments
     *
     * @param argArguments Value to assign to this.arguments
     */
    public void setArguments(Predicate[] argArguments) {
	this.arguments = argArguments;
    }

    /**
     * Get the short name of the function.
     *
     * @return short name of the function
     */
    public String getShortName () {
	String shortName = (String) function2string.get (function);
	if (shortName == null)
	    return function;
	else
	    return shortName;
    }

    public boolean isFunction () { return true; }
    public void walk (Visitor v)
    {
	v.walkFunctionCallPredicate (this);
    }
    public Predicate transform (Transformer t)
    {
	return t.walkFunctionCallPredicate (this);
    }

    public boolean equals (Object o)
    {
	if (! (o instanceof FunctionCallPredicate)) return false;
	FunctionCallPredicate f = (FunctionCallPredicate) o;
	Predicate[] fargs = f.getArguments ();
	if (arguments.length != fargs.length) return false;
	boolean same = true;
	for (int i = 0; i < arguments.length; i++)
	    if (! arguments[i].equals (fargs[i]))
		same = false;
	if (! same) return false;
	return function.equals (f.getFunction ());
    }

    public int hashCode ()
    {
	int start = function.hashCode () ^ arguments.length;
	for (int i = 0; i < arguments.length; i++)
	    start ^= arguments[i].hashCode ();
	return start;
    }
}
/* arch-tag: 472A0800-0F40-11D8-B47A-000A95A2610A
 */
