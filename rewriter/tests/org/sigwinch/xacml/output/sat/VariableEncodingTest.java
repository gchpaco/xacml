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

    /*
     * Test method for 'org.sigwinch.xacml.output.sat.VariableEncoding.decode(String[], boolean[])'
     */
    public void testDecode () {
        String [] names = { "foo_bar_42_0", "foo_bar_42_1", "foo_bar_42_2" };
        boolean [] values = { false, true, false };
        VariableEncoding.VariablePair pair = VariableEncoding.decode (names, values);
        assertEquals ("foo_bar_42", pair.name);
        assertEquals (2, pair.value);
        
        assertNull (VariableEncoding.decode (new String [] {}, new boolean [] {}));
        assertNull (VariableEncoding.decode (names, new boolean [] {}));
        assertNull (VariableEncoding.decode (new String [] { "foo_0", "bar_1", "baz_2" }, values));
        assertNull (VariableEncoding.decode (new String [] { "foo", "bar", "baz" }, values));
    }

}
