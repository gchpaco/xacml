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

    @Override
    public Predicate andWith (Predicate other) {
	if (value)
	    return other;
    return this;
    }

    @Override
    public Predicate orWith (Predicate other) {
	if (value)
	    return this;
    return other;
    }

    @Override
    public Predicate not () {
	if (value)
	    return SimplePredicate.FALSE;
    return SimplePredicate.TRUE;
    }

    static {
	TRUE = new SimplePredicate (true);
	FALSE = new SimplePredicate (false);
    }

    @Override
    public boolean isFunction () { return true; }
    @Override
    public void walk (Visitor v)
    {
	v.walkSimplePredicate (this);
    }
    @Override
    public Predicate transform (Transformer t)
    {
	return t.walkSimplePredicate (this);
    }
}
/* arch-tag: B35D52DE-0453-11D8-8949-000A95A2610A
 */
