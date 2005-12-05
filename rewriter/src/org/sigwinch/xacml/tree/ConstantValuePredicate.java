package org.sigwinch.xacml.tree;
import java.util.HashMap;


/**
 * A predicate that represents a constant value--say a string.
 *
 *
 * Created: Wed Oct 22 13:54:44 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class ConstantValuePredicate extends Predicate {
    static final HashMap<String, Integer> val2num;
    static int current;
    final int uniqueId;
    String type, value;
    public ConstantValuePredicate(String t, String v) {
	type = t; value = v;
	if (!val2num.containsKey (v))
	    val2num.put (v, new Integer (current++));
	uniqueId = val2num.get (v).intValue ();
    }

    static {
	val2num = new HashMap<String, Integer> ();
	reset ();
    }

    public static void reset ()
    {
	val2num.clear ();
	current = 0;
    }

    /**
     * Return a short name corresponding to the type of this value.
     *
     * @return the type of this predicate
     */
    public String getShortName () {
	String shortName = type2string.get (type);
	if (shortName == null)
	    return type;
    return shortName;
    }

    /**
     * Gets the value of type
     *
     * @return the value of type
     */
    public String getType()  {
	return this.type;
    }

    /**
     * Sets the value of type
     *
     * @param argType Value to assign to this.type
     */
    public void setType(String argType) {
	this.type = argType;
    }

    /**
     * Gets the value of value
     *
     * @return the value of value
     */
    public String getValue()  {
	return this.value;
    }

    /**
     * Sets the value of value
     *
     * @param argValue Value to assign to this.value
     */
    public void setValue(String argValue) {
	this.value = argValue;
    }

    public int getUniqueId () { return uniqueId; }

    @Override
    public boolean isFunction () { return true; }
    @Override
    public void walk (Visitor v)
    {
	v.walkConstantValuePredicate (this);
    }
    @Override
    public Predicate transform (Transformer t)
    {
	return t.walkConstantValuePredicate (this);
    }

    @Override
    public boolean equals (Object o)
    {
	if (! (o instanceof ConstantValuePredicate)) return false;
	ConstantValuePredicate c = (ConstantValuePredicate) o;
	return type.equals (c.getType ()) && value.equals (c.getValue ());
    }

    @Override
    public int hashCode ()
    {
	return type.hashCode () ^ value.hashCode ();
    }
}
/* arch-tag: FADA1E63-04D1-11D8-BB75-000A95A2610A
 */
