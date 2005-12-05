/*
 * Created on May 29, 2005
 */
package org.sigwinch.xacml.output.sat;


/**
 * @author graham
 */
public class SetVariableEncoding extends VariableEncoding {

    /**
     * @param baseName
     * @param multiplicity
     */
    public SetVariableEncoding (String baseName, int multiplicity) {
        super (buildNamesFor (baseName, multiplicity), multiplicity, baseName);
    }
    
    public BooleanFormula address (int i) {
        return names[i];
    }
}


// arch-tag: SetVariableEncoding.java May 29, 2005 2:14:43 AM
