package org.sigwinch.xacml.tree;

import java.io.StringWriter;
import java.io.PrintWriter;

/**
 * Tree.java
 * 
 * 
 * Created: Tue Oct 21 18:22:02 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
abstract public class Tree {
    public Tree() {

    }

    public boolean isFunction() {
        return false;
    }

    abstract public void walk(Visitor v);

    abstract public Tree transform(Transformer t);

    @Override
    public String toString() {
        StringWriter stream = new StringWriter();
        this.walk(new LispOutputVisitor(new PrintWriter(stream)));
        return stream.toString();
    }
}
/*
 * arch-tag: 2931280A-042E-11D8-A3E8-000A95A2610A
 */