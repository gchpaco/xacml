package org.sigwinch.xacml.output.alloycommon;

import java.io.PrintWriter;
import java.util.Hashtable;

import org.sigwinch.xacml.output.CodeVisitor;
import org.sigwinch.xacml.tree.ConstantValuePredicate;

/**
 * ConstantVisitor.java
 * 
 * 
 * Created: Mon Nov 17 17:48:22 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class ConstantVisitor extends CodeVisitor {
    Hashtable<Integer, Boolean> indexesSeen;

    public ConstantVisitor(PrintWriter stream) {
        super(stream);
        indexesSeen = new Hashtable<Integer, Boolean>();
    }

    @Override
    public void outputStart() {
        stream.println("one sig S {");
    }

    /**
     * Output the constant information for use with Alloy.
     * 
     * @param constantValuePredicate
     *            a <code>ConstantValuePredicate</code>
     */
    @Override
    public void walkConstantValuePredicate(
            ConstantValuePredicate constantValuePredicate) {
        if (indexesSeen.containsKey(new Integer(constantValuePredicate
                .getUniqueId())))
            return;
        printConstant("static" + constantValuePredicate.getUniqueId(),
                constantValuePredicate.getShortName(), constantValuePredicate
                        .getValue());
        indexesSeen.put(new Integer(constantValuePredicate.getUniqueId()),
                Boolean.TRUE);
    }

}
/*
 * arch-tag: 4CC5EC01-1969-11D8-AB5D-000A95A2610A
 */
