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

}
