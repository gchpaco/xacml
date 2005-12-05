package org.sigwinch.xacml.parser;

import org.sigwinch.xacml.parser.ExpressionParser;
import org.w3c.dom.Element;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.EnvironmentalPredicate;
import org.sigwinch.xacml.tree.SimplePredicate;
import org.sigwinch.xacml.tree.FunctionCallPredicate;
import org.sigwinch.xacml.tree.ConstantValuePredicate;


/**
 * AttributeSelectorParser.java
 *
 *
 * Created: Tue Nov  4 18:45:07 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class AttributeSelectorParser extends ExpressionParser {
    public AttributeSelectorParser() {
	
    }

    /**
     * Parse AttributeSelector node.
     *
     * @param element AttributeSelector node to parse
     * @return predicate corresponding to its contents
     */
    public Predicate parseElement(Element element) {
	String type = getXACMLAttribute (element, "DataType");
	String id = getXACMLAttribute (element, "RequestContextPath");
	boolean force = false;
	if (getXACMLAttribute (element, "MustBePresent").equals ("True"))
	    force = true;

	return new EnvironmentalPredicate (type, id, force);
    }

    /**
     * Comb <code>element</code> for error conditions.  These are
     * basically impossible unless the <code>MustBePresent</code>
     * attribute is true.
     *
     * @param element an <code>Element</code> node
     * @return resulting predicate
     */
    public Predicate parseForError(Element element) {
	boolean force = false;
	if (getXACMLAttribute (element, "MustBePresent").equals ("True"))
	    force = true;
	if (!force)
	    return SimplePredicate.TRUE;

	String type = getXACMLAttribute (element, "DataType");
	String id = getXACMLAttribute (element, "RequestContextPath");
	String bagsize = (String) type2bagsize.get (type);
	return new FunctionCallPredicate
	    ("urn:oasis:names:tc:xacml:1.0:function:integer-equal",
	     new Predicate [] {
		new FunctionCallPredicate
		(bagsize,
		 new Predicate [] {
		    new EnvironmentalPredicate (type, id)
		}),
		new ConstantValuePredicate 
		("http://www.w3.org/2001/XMLSchema#integer", "1")
	    }).not ();
    }
}
/* arch-tag: 18E26E40-0F3A-11D8-B489-000A95A2610A
 */
