/*
 * Created on May 22, 2005
 */
package org.sigwinch.xacml.output.sat;

import org.sigwinch.xacml.tree.VariableReference;

/**
 * @author graham
 */
public abstract class VariableEncoding {
    VariableReference[] names;
    int multiplicity;
    int length;
    String baseName;

    /**
     * @param namesFor
     * @param multiplicity
     * @param baseName
     */
    protected VariableEncoding (VariableReference[] namesFor, int multiplicity, String baseName) {
        names = namesFor;
        this.baseName = baseName;
        this.multiplicity = multiplicity;
        length = BooleanCombinations.binaryLog(multiplicity);
    }
    
    protected VariableEncoding (String baseName, int multiplicity) {
        length = BooleanCombinations.binaryLog (multiplicity);
        this.multiplicity = multiplicity;
        this.baseName = baseName;
        names = buildNamesFor (baseName, length);
    }

    static protected VariableReference [] buildNamesFor (String baseName, int len) {
        VariableReference [] n = new VariableReference[len];
        for (int i = 0; i < n.length; i++) {
            n[i] = new VariableReference (baseName + "_" + i);
        }
        return n;
    }

    /**
     * @return return the number of values this variable can take
     */
    public int getSize () {
        return multiplicity;
    }

    public VariableReference[] getNames () {
        return names;
    }

    /**
     * @return base string for this encoding
     */
    public String getBase () {
        // not actually good here
        return baseName;
    }

    public abstract BooleanFormula address (int i);
}

// arch-tag: VariableEncoding.java May 22, 2005 2:07:57 AM
