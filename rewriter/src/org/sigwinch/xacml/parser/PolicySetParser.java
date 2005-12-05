package org.sigwinch.xacml.parser;

import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.sigwinch.xacml.tree.Tree;

/**
 * PolicySetParser.java
 * 
 * 
 * Created: Tue Oct 21 21:26:28 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class PolicySetParser extends AbstractParser {
    public PolicySetParser() {

    }

    /**
     * Reads the given <code>PolicySet</code> node and creates and returns an
     * appropriate <code>Tree</code>. This reads the PolicyCombiningAlgId
     * attribute.
     * 
     * @param element
     *            an <code>Element</code> representing a
     *            <code>PolicySet</code> node
     * @return the appropriate <code>Tree</code> value
     */
    @Override
    public Tree parseElement(Element element) {
        NodeList subrules = getList(element, "Policy");
        assert subrules != null;
        assert subrules.getLength() > 0;
        Tree base = AbstractParser.parse((Element) subrules.item(subrules
                .getLength() - 1));
        for (int i = subrules.getLength() - 2; i >= 0; i--) {
            Tree leaf = AbstractParser.parse((Element) subrules.item(i));
            base = ruleToTree(
                    getXACMLAttribute(element, "PolicyCombiningAlgId"), leaf,
                    base);
        }
        return maybeScope(element, base);
    }
}
/*
 * arch-tag: EC1AE7FA-0447-11D8-9133-000A95A2610A
 */
