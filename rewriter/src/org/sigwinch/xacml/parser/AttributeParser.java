package org.sigwinch.xacml.parser;

import org.sigwinch.xacml.tree.ConstantValuePredicate;
import org.sigwinch.xacml.tree.EnvironmentalPredicate;
import org.sigwinch.xacml.tree.FunctionCallPredicate;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.SimplePredicate;
import org.w3c.dom.Element;



/**
 * AttributeParser.java
 *
 *
 * Created: Tue Nov  4 13:48:10 2003
 *
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class AttributeParser extends ExpressionParser {
    public AttributeParser() {
	
    }

    /**
     * Read an attribute from an EnvironmentAttributeDesignator node
     * or the like.
     *
     * @param element XML tree containing the attribute designator
     * @return the attribute as a predicate
     */
    @Override
    public Predicate parseElement(Element element) {
	String type = getXACMLAttribute (element, "DataType");
	String id = getXACMLAttribute (element, "AttributeId");
	if (element.getNodeName().equals ("SubjectAttributeDesignator")) {
	    String category = getXACMLAttribute (element, "SubjectCategory");
	    if (category != null)
		// AAIGH!  My fingers!  They're worn down to little nubs!
		category =
		    "urn:oasis:tc:xacml:1.0:subject-category:access-subject";
	    id = category + "::" + id;
	}
	return new EnvironmentalPredicate (type, id);
    }

    /**
     * Comb <code>element</code> for error conditions.  These are
     * basically impossible unless the <code>MustBePresent</code>
     * attribute is true.
     *
     * @param element an <code>Element</code> node
     * @return resulting predicate
     */
    @Override
    public Predicate parseForError(Element element) {
	boolean force = false;
	if (getXACMLAttribute (element, "MustBePresent").equals ("True"))
	    force = true;
	if (!force)
	    return SimplePredicate.TRUE;

	String type = getXACMLAttribute (element, "DataType");
	String id = getXACMLAttribute (element, "AttributeId");
	String bagsize = type2bagsize.get (type);
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
/* arch-tag: 9A5E692C-0F10-11D8-9FFE-000A95A2610A
 */
