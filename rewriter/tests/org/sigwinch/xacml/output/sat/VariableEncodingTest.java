package org.sigwinch.xacml.output.sat;

import java.util.Arrays;

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
        String[] foo = { "f" };
        String[] bar = { "b" };
        boolean[] t = { true };
        boolean[] f = { false };
        VariableEncoding.Value value = VariableEncoding.decode(bar, t);
        assertTrue(value.getType() instanceof BooleanVariableEncoding);
        assertSame(value.getType(), VariableEncoding.decode(bar, t).getType());
        assertNotSame(value.getType(), VariableEncoding.decode(foo, t)
                .getType());
        assertSame(value.getType(), VariableEncoding.decode(bar, f).getType());
        assertEquals(value, VariableEncoding.decode(bar, t));
        assertFalse(value.equals(VariableEncoding.decode(bar, f)));
        assertEquals("b", value.getBase());
        assertEquals(true, value.getValue());
        
        String[] foos = { "foo_0", "foo_1", "foo_2", "foo_3" };
        String[] bars = { "bar_0", "bar_1", "bar_2", "bar_3" };
        boolean[] values = { false, true, false, true };
        boolean[] fs = { false, false, false, false };
        
        // This demonstrates that the name f is reserved for boolean variables
        assertTrue(VariableEncoding.decode(
                new String[] { "f_0", "f_1", "f_2", "f_3" }, values).getType() instanceof BooleanVariableEncoding);
        
        value = VariableEncoding.decode(bars, values);
        assertTrue(value.getType() instanceof ScalarVariableEncoding);
        assertSame(value.getType(), VariableEncoding.decode(bars, values).getType());
        assertNotSame(value.getType(), VariableEncoding.decode(foos, fs)
                .getType());
        assertSame(value.getType(), VariableEncoding.decode(bars, fs).getType());
        assertEquals(value, VariableEncoding.decode(bars, values));
        assertFalse(value.equals(VariableEncoding.decode(bars, fs)));
        assertEquals("bar", value.getBase());
        assertEquals(10, value.getValue());
        
        String[] foo2s = { "foo__0", "foo__1", "foo__2", "foo__3" };
        String[] bar2s = { "bar__0", "bar__1", "bar__2", "bar__3" };
        SetVariableEncoding.retrieve("foo_", 4);
        SetVariableEncoding.retrieve("bar_", 4);
        value = VariableEncoding.decode(bar2s, values);
        assertTrue(value.getType() instanceof SetVariableEncoding);
        assertSame(value.getType(), VariableEncoding.decode(bar2s, values).getType());
        assertNotSame(value.getType(), VariableEncoding.decode(foo2s, fs)
                .getType());
        assertSame(value.getType(), VariableEncoding.decode(bar2s, fs).getType());
        assertEquals(value, VariableEncoding.decode(bar2s, values));
        assertFalse(value.equals(VariableEncoding.decode(bar2s, fs)));
        assertEquals("bar_", value.getBase());
        assertTrue(Arrays.equals(values, (boolean[]) value.getValue ()));
    }
}
