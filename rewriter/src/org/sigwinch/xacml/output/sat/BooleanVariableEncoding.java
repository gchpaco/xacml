/*
 * Created on May 28, 2005
 */
package org.sigwinch.xacml.output.sat;

import java.util.HashMap;
import java.util.Map;

import org.sigwinch.xacml.tree.VariableReference;

/**
 * @author graham
 */
public class BooleanVariableEncoding extends VariableEncoding {
    private BooleanVariableEncoding(VariableReference name) {
        super(new VariableReference[] { name }, 1, name.toString());
    }

    @Override
    public BooleanFormula address(int i) {
        assert i == 0 : "tried to address a Boolean variable with " + i;
        return names[0];
    }
    
    static final private Map<VariableReference, VariableEncoding> cache = new HashMap<VariableReference, VariableEncoding>();

    public static VariableEncoding retrieve(VariableReference var) {
        if (!cache.containsKey(var))
            cache.put(var, new BooleanVariableEncoding(var));
        return cache.get(var);
    }

}

// arch-tag: BooleanVariableEncoding.java May 28, 2005 1:59:13 AM
