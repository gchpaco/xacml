/*
 * Created on May 23, 2005
 */
package org.sigwinch.xacml.output.sat;

import junit.framework.TestCase;

/**
 * @author graham
 */
public class BooleanCombinationsTest extends TestCase {

    public void testBinaryLog() {
        assertEquals(1, BooleanCombinations.binaryLog(0));
        assertEquals(1, BooleanCombinations.binaryLog(1));
        assertEquals(3, BooleanCombinations.binaryLog(5));
        assertEquals(3, BooleanCombinations.binaryLog(8));
        assertEquals(5, BooleanCombinations.binaryLog(17));
    }

}

// arch-tag: BooleanCombinationsTest.java May 23, 2005 3:22:59 PM
