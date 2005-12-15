/*
 * Created on May 29, 2005
 */
package org.sigwinch.xacml.output.sat;

import java.util.HashMap;
import java.util.Map;

/**
 * @author graham
 */
public class SetVariableEncoding extends VariableEncoding {

    /**
     * @param baseName
     * @param multiplicity
     */
    public SetVariableEncoding(String baseName, int multiplicity) {
        super(buildNamesFor(baseName, multiplicity), multiplicity, baseName);
    }

    @Override
    public BooleanFormula address(int i) {
        return names[i];
    }

    static final private Map<String, Map<Integer, SetVariableEncoding>> cache = new HashMap<String, Map<Integer, SetVariableEncoding>>();

    public static SetVariableEncoding retrieve(String var, int i) {
        if (!cache.containsKey(var))
            cache.put(var, new HashMap<Integer, SetVariableEncoding> ());
        if (!cache.get(var).containsKey(i))
            cache.get(var).put(i, new SetVariableEncoding(var, i));
        return cache.get(var).get(i);
    }

    public static Constructor getConstructor() {
        return new Constructor() {
            public VariableEncoding constructType(String basename, int length) {
                return SetVariableEncoding.retrieve(basename, length);
            };

            public Object constructValue(boolean[] values) {
                return values;
            };
        };
    }
}

// arch-tag: SetVariableEncoding.java May 29, 2005 2:14:43 AM
