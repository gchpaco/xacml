package org.sigwinch.xacml.tree;
import java.util.Hashtable;
import java.io.StringWriter;
import java.io.PrintWriter;

/**
 * Predicate.java
 *
 *
 * Created: Tue Oct 21 22:48:44 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
abstract public class Predicate {
    final int index;
    static int generatedIndices;
    public static Hashtable type2string, function2string;
    static {
	type2string = new Hashtable ();
	type2string.put ("http://www.w3.org/2001/XMLSchema#string",
			 "String");
	type2string.put ("http://www.w3.org/2001/XMLSchema#integer",
			 "Integer");
	type2string.put ("http://www.w3.org/2001/XMLSchema#date",
			 "Date");
	type2string.put ("http://www.w3.org/2001/XMLSchema#boolean",
			 "Bool");
	type2string.put ("http://www.w3.org/TR/2002/WD-xquery-operators" +
			 "-20020816#yearMonthDuration",
			 "YearMonthDuration");
	// TODO: fill in rest
	function2string = new Hashtable ();
    }
    
    public Predicate() {
	index = generatedIndices++;
    }

    /**
     * Gets the value of index
     *
     * @return the value of index
     */
    public int getIndex()  {
	return this.index;
    }

    public static void reset ()
    {
	generatedIndices = 0;
	ConstantValuePredicate.reset ();
	EnvironmentalPredicate.reset ();
    }
    
    public Predicate andWith (Predicate other) {
	if (other == SimplePredicate.TRUE)
	    return this;
	else if (other == SimplePredicate.FALSE)
	    return other;
	else
	    return new AndPredicate (this, other);
    }
    public Predicate orWith (Predicate other) {
	if (other == SimplePredicate.TRUE)
	    return other;
	else if (other == SimplePredicate.FALSE)
	    return this;
	else
	    return new OrPredicate (this, other);
    }
    public Predicate not () {
	String notString = "urn:oasis:names:tc:xacml:1.0:function:not";
	return new FunctionCallPredicate (notString,
					  new Predicate[] { this });
    }
    public boolean isFunction ()
    {
	return false;
    }
    abstract public void walk (Visitor v);
    abstract public Predicate transform (Transformer t);

    public String toString ()
    {
	StringWriter stream = new StringWriter ();
	this.walk (new LispOutputVisitor (new PrintWriter (stream)));
	return stream.toString ();
    }
}
/* arch-tag: 66E65B2D-0453-11D8-9755-000A95A2610A
 */
