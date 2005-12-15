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
     * Test method for 'org.sigwinch.xacml.output.sat.VariableEncoding.decodeArrays(String[], boolean[])'
     */
    public void testDecodeArrays () {
        String [] names = { "foo_bar_42_0", "foo_bar_42_1", "foo_bar_42_2" };
        boolean [] values = { false, true, false };
        VariableEncoding.VariablePair pair = VariableEncoding.decodeArrays (names, values);
        assertEquals ("foo_bar_42", pair.name);
        assertEquals (2, pair.value);
        
        assertNull (VariableEncoding.decodeArrays (new String [] {}, new boolean [] {}));
        assertNull (VariableEncoding.decodeArrays (names, new boolean [] {}));
        assertNull (VariableEncoding.decodeArrays (new String [] { "foo_0", "bar_1", "baz_2" }, values));
        assertNull (VariableEncoding.decodeArrays (new String [] { "foo", "bar", "baz" }, values));
    }

    public void testDecode () {
        VariableEncoding.Value value = VariableEncoding.decode(
                new String[] { "bar" }, new boolean[] { true });
        assertTrue(value.getType () instanceof BooleanVariableEncoding);
        assertSame(value.getType (), VariableEncoding.decode(new String[] { "bar" },
                new boolean[] { true }).getType ());
        assertNotSame(value.getType (), VariableEncoding.decode(new String[] { "foo" },
                new boolean[] { true }).getType ());
        assertSame(value.getType (), VariableEncoding.decode(new String[] { "bar" },
                new boolean[] { false }).getType ());
        assertEquals (value, VariableEncoding.decode(new String[] { "bar" },
                new boolean[] { true }));
        assertFalse(value.equals(VariableEncoding.decode(new String[] { "bar" },
                new boolean[] { false })));
        assertEquals("bar", value.getBase());
        assertEquals(true, value.getValue());
    }
}
