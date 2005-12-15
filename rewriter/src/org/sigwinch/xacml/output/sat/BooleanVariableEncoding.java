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
    
    static final private Map<VariableReference, BooleanVariableEncoding> cache = new HashMap<VariableReference, BooleanVariableEncoding>();

    public static BooleanVariableEncoding retrieve(VariableReference var) {
        if (!cache.containsKey(var)) {
            cache.put(var, new BooleanVariableEncoding(var));
            logAs(var.getName(), getConstructor());
        }
        return cache.get(var);
    }
    public static BooleanVariableEncoding retrieve(String var) {
        return retrieve (new VariableReference (var));
    }

    public static Constructor getConstructor() {
        return new Constructor() {
            public VariableEncoding constructType(String basename, int length) {
                return BooleanVariableEncoding.retrieve(basename);
            };

            public Object constructValue(boolean[] values) {
                return values[0];
            };
        };
    }
}

// arch-tag: BooleanVariableEncoding.java May 28, 2005 1:59:13 AM
