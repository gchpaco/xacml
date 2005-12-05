package org.sigwinch.xacml.parser;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.ConstantValuePredicate;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * Parse AttributeValue elements.  Currently we just extract the contents.
 *
 * <p>
 * Created: Wed Oct 22 13:45:24 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class AttributeValueParser extends ExpressionParser {
    public AttributeValueParser() {
	
    }

    @Override
    public Predicate parseElement (Element e) {
	String type = getXACMLAttribute (e, "DataType");
	StringBuffer value = new StringBuffer ();
	Node child = e.getFirstChild ();
	while (child != null) {
	    if (child.getNodeType () == Node.TEXT_NODE ||
		child.getNodeType () == Node.CDATA_SECTION_NODE)
		value.append (child.getNodeValue ());
	    child = child.getNextSibling ();
	}
	return new ConstantValuePredicate (type, value.toString ().trim ());
    }
}
/* arch-tag: ACD2B0A2-04D0-11D8-B578-000A95A2610A
 */
