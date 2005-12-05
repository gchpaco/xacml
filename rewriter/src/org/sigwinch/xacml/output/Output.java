package org.sigwinch.xacml.output;

import org.sigwinch.xacml.tree.Tree;

/**
 * Output.java
 * 
 * 
 * Created: Tue Dec 23 22:18:28 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */

public interface Output {
    public void preamble(Tree tree);

    public void write(Tree tree);

    public void postamble();
}
/*
 * arch-tag: FEB616EA-35D8-11D8-B121-000A957284DA
 */
