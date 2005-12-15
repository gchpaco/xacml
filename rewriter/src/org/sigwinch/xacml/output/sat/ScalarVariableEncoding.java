/*
 * Created on May 29, 2005
 */
package org.sigwinch.xacml.output.sat;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.sigwinch.xacml.tree.VariableReference;

/**
 * @author graham
 */
public class ScalarVariableEncoding extends VariableEncoding {

    /**
     * @param namesFor
     * @param multiplicity
     */
    public ScalarVariableEncoding(VariableReference[] namesFor, int multiplicity) {
        super(namesFor, multiplicity, namesFor[0].toString());
    }

    /**
     * @param baseName
     * @param multiplicity
     */
    public ScalarVariableEncoding(String baseName, int multiplicity) {
        super(baseName, multiplicity);
    }

    /**
     * 
     */
    public Set<BooleanFormula> disallowIllegals() {
        HashSet<BooleanFormula> illegals = new HashSet<BooleanFormula>();
        for (int i = multiplicity; i < 1 << names.length; i++) {
            BooleanFormula[] clauses = new BooleanFormula[names.length];
            for (int j = 0; j < clauses.length; j++) {
                if ((i & (1 << j)) > 0)
                    clauses[j] = names[j];
                else
                    clauses[j] = names[j].negate();
            }
            illegals.add(new Not(new And(clauses)));
        }
        return illegals;
    }

    /**
     * @param i
     * @return a Boolean formula that represents the <code>i</code> th value
     *         of this variable
     */
    @Override
    public BooleanFormula address(int i) {
        assert 0 <= i && i < multiplicity : i + " is not between 0 and "
                + multiplicity;
        ArrayList<BooleanFormula> components = new ArrayList<BooleanFormula>();
        for (int j = 0; j < length; j++) {
            int index = 1 << j;
            if ((i & index) > 0)
                components.add(names[j]);
            else
                components.add(names[j].negate());
        }
        return new And(components.toArray(new BooleanFormula[] {}));
    }

    static final private Map<String, Map<Integer, VariableEncoding>> cache = new HashMap<String, Map<Integer, VariableEncoding>>();

    public static VariableEncoding retrieve(String var, int i) {
        if (!cache.containsKey(var))
            cache.put(var, new HashMap<Integer, VariableEncoding> ());
        if (!cache.get(var).containsKey(i))
            cache.get(var).put(i, new ScalarVariableEncoding(var, i));
        return cache.get(var).get(i);
    }

}

// arch-tag: ScalarVariableEncoding.java May 29, 2005 2:29:49 AM
