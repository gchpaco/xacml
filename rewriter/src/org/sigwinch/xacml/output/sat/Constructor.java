package org.sigwinch.xacml.output.sat;

public interface Constructor {
    public VariableEncoding constructType (String basename, int length);
    public Object constructValue (boolean [] values);
}
