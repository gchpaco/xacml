package org.sigwinch.xacml.parser;

import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.sigwinch.xacml.tree.Tree;



/**
 * PolicyParser.java
 *
 *
 * Created: Tue Oct 21 19:43:23 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class PolicyParser extends AbstractParser {
    public PolicyParser() {
	
    }

    /**
     * Reads the given <code>Policy</code> node and creates and
     * returns an appropriate <code>Tree</code>.  This reads the
     * RuleCombiningAlgId attribute.
     *
     * @param element an <code>Element</code> representing a <code>Policy</code> node
     * @return the appropriate <code>Tree</code> value
     */
    public Tree parseElement(Element element) {
	NodeList subrules = getList (element, "Rule");
	assert subrules != null;
	assert subrules.getLength () > 0;
	Tree base = AbstractParser.parse ((Element) subrules.item (subrules.getLength () - 1));
	for (int i = subrules.getLength () - 2; i >= 0; i--) {
	    Tree leaf = AbstractParser.parse ((Element) subrules.item (i));
	    base = ruleToTree (getXACMLAttribute (element, "RuleCombiningAlgId"),
			       leaf, base);
	}
	return maybeScope (element, base);
    }
    
}
/* arch-tag: 81F7BD70-0439-11D8-A0E4-000A95A2610A
 */
