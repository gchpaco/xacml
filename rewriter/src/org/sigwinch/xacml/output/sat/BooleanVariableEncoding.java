/*
 * Created on May 28, 2005
 */
package org.sigwinch.xacml.output.sat;

import org.sigwinch.xacml.tree.VariableReference;

/**
 * @author graham
 */
public class BooleanVariableEncoding extends VariableEncoding {
    public BooleanVariableEncoding (VariableReference name) {
        super (new VariableReference [] { name }, 1, name.toString ());
    }

    @Override
    public BooleanFormula address (int i) {
        assert i == 0: "tried to address a Boolean variable with " + i;
        return names[0];
    }

}


// arch-tag: BooleanVariableEncoding.java May 28, 2005 1:59:13 AM
