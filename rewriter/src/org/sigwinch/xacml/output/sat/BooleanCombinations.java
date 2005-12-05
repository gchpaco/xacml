/*
 * Created on May 19, 2005
 */
package org.sigwinch.xacml.output.sat;

/**
 * @author graham
 */
public class BooleanCombinations {

    /**
     * @param n
     * @return log_2 (n)
     */
    static public int binaryLog(int n) {
        if (n == 0 || n == 1)
            return 1;
        int size = 0;
        n--; // fudge because we do zero based indexing
        while (n > 0) {
            size++;
            n >>= 1;
        }
        return size;
    }

}

// arch-tag: BooleanCombinations.java May 19, 2005 6:03:32 PM
