package org.sigwinch.xacml.parser;

import org.w3c.dom.Element;
import org.sigwinch.xacml.tree.Tree;
import org.sigwinch.xacml.tree.Permit;
import org.sigwinch.xacml.tree.Deny;

/**
 * RuleParser.java
 * 
 * 
 * Created: Tue Oct 21 19:42:30 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class RuleParser extends AbstractParser {
    public RuleParser() {

    }

    /**
     * Reads the given <code>Rule</code> node and creates and returns an
     * appropriate <code>Tree</code>.
     * 
     * @param element
     *            an <code>Element</code> representing a <code>Rule</code>
     *            node
     * @return the appropriate <code>Tree</code> value
     */
    @Override
    public Tree parseElement(Element element) {
        Tree base;
        if (getXACMLAttribute(element, "Effect").equals("Permit"))
            base = Permit.PERMIT;
        else
            base = Deny.DENY;
        return maybeConditions(element, maybeScope(element, base));
    }
}
/*
 * arch-tag: 77EAF557-0439-11D8-94CF-000A95A2610A
 */