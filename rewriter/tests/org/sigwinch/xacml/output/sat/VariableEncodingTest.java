package org.sigwinch.xacml.output.sat;

import junit.framework.TestCase;

public class VariableEncodingTest extends TestCase {

    /*
     * Test method for 'org.sigwinch.xacml.output.sat.VariableEncoding.baseNameOf(String)'
     */
    public void testBaseNameOf() {
        assertEquals ("foo_bar_42", VariableEncoding.baseNameOf("foo_bar_42_1"));
        assertNull(VariableEncoding.baseNameOf ("foo_bar_baz"));
    }
    
    public void testDecodeNames () {
        // XXX: test with empty arrays.
        // XXX: test with arrays with no base name
        String [] names = { "foo_bar_42_0", "foo_bar_42_1", "foo_bar_42_2" };
        boolean [] values = { false, true, false };
        VariableEncoding.VariablePair pair = VariableEncoding.decode (names, values);
        assertEquals ("foo_bar_42", pair.name);
        assertEquals (2, pair.value);
    }

}
