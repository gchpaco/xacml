package org.sigwinch.xacml.tree;

import org.sigwinch.xacml.tree.Tree;



/**
 * Triple.java
 *
 *
 * Created: Sat Nov  8 02:08:05 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class Triple extends Tree {
    Predicate permit, deny, error;
    public Triple(Predicate permit, Predicate deny, Predicate error) {
	this.permit = permit;
	this.deny = deny;
	this.error = error;
    }
    
    /**
     * Gets the value of permit
     *
     * @return the value of permit
     */
    public Predicate getPermit()  {
	return this.permit;
    }

    /**
     * Sets the value of permit
     *
     * @param argPermit Value to assign to this.permit
     */
    public void setPermit(Predicate argPermit) {
	this.permit = argPermit;
    }

    /**
     * Gets the value of deny
     *
     * @return the value of deny
     */
    public Predicate getDeny()  {
	return this.deny;
    }

    /**
     * Sets the value of deny
     *
     * @param argDeny Value to assign to this.deny
     */
    public void setDeny(Predicate argDeny) {
	this.deny = argDeny;
    }

    /**
     * Gets the value of error
     *
     * @return the value of error
     */
    public Predicate getError()  {
	return this.error;
    }

    /**
     * Sets the value of error
     *
     * @param argError Value to assign to this.error
     */
    public void setError(Predicate argError) {
	this.error = argError;
    }

    public boolean isFunction () { return true; }
    public void walk (Visitor v)
    {
	v.walkTriple (this);
    }
    public Tree transform (Transformer t)
    {
	return t.walkTriple (this);
    }

    public boolean equals (Object o)
    {
	if (! (o instanceof Triple)) return false;
	Triple t = (Triple) o;
	return permit.equals (t.getPermit ()) &&
	    deny.equals (t.getDeny ()) &&
	    error.equals (t.getError ());
    }

    public int hashCode ()
    {
	return permit.hashCode () ^ deny.hashCode () ^ error.hashCode ();
    }
}
/* arch-tag: 761458EE-11D3-11D8-8FA8-000A95A2610A
 */
