/*
 * Created on May 29, 2005
 */
package org.sigwinch.xacml.output.sat;

import java.util.ArrayList;
import java.util.HashSet;
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
    public ScalarVariableEncoding (VariableReference[] namesFor,
                                   int multiplicity) {
        super (namesFor, multiplicity, namesFor[0].toString ());
    }
    /**
     * @param baseName
     * @param multiplicity
     */
    public ScalarVariableEncoding (String baseName, int multiplicity) {
        super (baseName, multiplicity);
    }
    /**
     * 
     */
    public Set disallowIllegals () {
        HashSet illegals = new HashSet ();
        for (int i = multiplicity; i < 1 << names.length; i++) {
            BooleanFormula[] clauses = new BooleanFormula[names.length];
            for (int j = 0; j < clauses.length; j++) {
                if ((i & (1 << j)) > 0)
                    clauses[j] = names[j];
                else
                    clauses[j] = names[j].negate ();
            }
            illegals.add (new Not (new And (clauses)));
        }
        return illegals;
    }
    /**
     * @param i
     * @return a Boolean formula that represents the <code>i</code> th value
     *         of this variable
     */
    public BooleanFormula address (int i) {
        assert 0 <= i && i < multiplicity: i + " is not between 0 and " + multiplicity;
        ArrayList components = new ArrayList ();
        for (int j = 0; j < length; j++) {
            int index = 1 << j;
            if ((i & index) > 0)
                components.add (names[j]);
            else
                components.add (names[j].negate ());
        }
        return new And (
                        (BooleanFormula[]) components
                                                     .toArray (new BooleanFormula[] {}));
    }

}


// arch-tag: ScalarVariableEncoding.java May 29, 2005 2:29:49 AM
