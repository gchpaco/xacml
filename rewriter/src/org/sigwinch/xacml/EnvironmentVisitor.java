package org.sigwinch.xacml;

import org.sigwinch.xacml.tree.VisitorImpl;
import org.sigwinch.xacml.tree.EnvironmentalPredicate;
import java.io.PrintWriter;

/**
 * EnvironmentVisitor.java
 * 
 * 
 * Created: Fri Nov 7 01:42:01 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class EnvironmentVisitor extends VisitorImpl {
    final PrintWriter stream;

    public EnvironmentVisitor(PrintWriter stream) {
        this.stream = stream;
    }

    /**
     * Write out the environment declarations in this node.
     * 
     * @param environmentalPredicate
     *            a reference to the environment
     */
    @Override
    public void walkEnvironmentalPredicate(
            EnvironmentalPredicate environmentalPredicate) {
        stream.print("E_");
        stream.print(environmentalPredicate.getUniqueId());
        stream.print(" (");
        stream.print(environmentalPredicate.getId());
        stream.print(") : ");
        stream.println(environmentalPredicate.getShortName());
    }

}
/*
 * arch-tag: A6EE9256-1106-11D8-92D4-000A95A2610A
 */
