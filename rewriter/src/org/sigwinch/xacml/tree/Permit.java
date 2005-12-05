package org.sigwinch.xacml.tree;

/**
 * Permit.java
 * 
 * 
 * Created: Tue Oct 21 21:28:52 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class Permit extends Tree {
    public static Permit PERMIT;
    static {
        PERMIT = new Permit();
    }

    private Permit() {
    }

    @Override
    public boolean isFunction() {
        return true;
    }

    @Override
    public void walk(Visitor v) {
        v.walkPermit(this);
    }

    @Override
    public Tree transform(Transformer t) {
        return t.walkPermit(this);
    }
}
/*
 * arch-tag: 40BB296E-0448-11D8-B122-000A95A2610A
 */
