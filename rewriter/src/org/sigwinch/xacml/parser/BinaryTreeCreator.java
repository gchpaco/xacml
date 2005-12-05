package org.sigwinch.xacml.parser;

import org.sigwinch.xacml.tree.Tree;

/**
 * BinaryCommand.java
 * 
 * 
 * Created: Wed Oct 22 13:11:59 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */

public interface BinaryTreeCreator {
    public Tree go(Tree first, Tree second);
}
/*
 * arch-tag: FE9CCF54-04CB-11D8-B4A8-000A95A2610A
 */
