package org.sigwinch.xacml.parser;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.ExistentialPredicate;

/**
 * Parse matching expressions, in XACML target rules for example.
 *
 * <p>
 * Created: Wed Oct 22 13:30:25 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class MatchingParser extends ExpressionParser {
    public MatchingParser() {
	
    }

    public Predicate parseElement (Element matching) {
	String function = getXACMLAttribute (matching, "MatchId");
	// all of these are \exists x \in second argument st. first
	// argument <something> second argument.
	Predicate first = null, second = null;
	Node child = matching.getFirstChild ();
	while (child != null) {
	    if (child.getNodeType () == Node.ELEMENT_NODE) {
		if (first == null)
		    first = ExpressionParser.parseExpression ((Element) child);
		else
		    second = ExpressionParser.parseExpression ((Element) child);
	    }
	    child = child.getNextSibling ();
	}
	assert first != null;
	assert second != null;
	return new ExistentialPredicate (function, first, second);
    }
}
/* arch-tag: 95079444-04CE-11D8-8CE6-000A95A2610A
 */
