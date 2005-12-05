package org.sigwinch.xacml.tree;

/**
 * SolePredicate.java
 * 
 * 
 * Created: Mon Jan 12 16:53:57 2004
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class SolePredicate extends Predicate {
    Predicate set;

    public SolePredicate(Predicate set) {
        this.set = set;
    }

    /**
     * Get the value of set
     * 
     * @return the value of set
     */
    public Predicate getSet() {
        return this.set;
    }

    @Override
    public void walk(Visitor v) {
        v.walkSolePredicate(this);
    }

    @Override
    public Predicate transform(Transformer t) {
        return t.walkSolePredicate(this);
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof SolePredicate))
            return false;
        SolePredicate s = (SolePredicate) o;
        return s.set.equals(set);
    }

    @Override
    public int hashCode() {
        return set.hashCode() ^ '|';
    }
}
/*
 * arch-tag: 06BC3AC2-4563-11D8-9DD3-000A957284DA
 */
