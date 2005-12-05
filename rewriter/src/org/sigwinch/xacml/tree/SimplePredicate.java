package org.sigwinch.xacml.tree;

/**
 * SimplePredicate.java
 *
 *
 * Created: Tue Oct 21 22:50:52 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class SimplePredicate extends Predicate {
    static public final SimplePredicate TRUE;
    static public final SimplePredicate FALSE;
    boolean value;
    private SimplePredicate(boolean v) {
	value = v;
    }

    public Predicate andWith (Predicate other) {
	if (value)
	    return other;
	else
	    return this;
    }
    
    public Predicate orWith (Predicate other) {
	if (value)
	    return this;
	else
	    return other;
    }

    public Predicate not () {
	if (value)
	    return SimplePredicate.FALSE;
	else
	    return SimplePredicate.TRUE;
    }

    static {
	TRUE = new SimplePredicate (true);
	FALSE = new SimplePredicate (false);
    }

    public boolean isFunction () { return true; }
    public void walk (Visitor v)
    {
	v.walkSimplePredicate (this);
    }
    public Predicate transform (Transformer t)
    {
	return t.walkSimplePredicate (this);
    }
}
/* arch-tag: B35D52DE-0453-11D8-8949-000A95A2610A
 */
