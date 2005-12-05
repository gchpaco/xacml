package org.sigwinch.xacml.parser;

import java.util.ArrayList;

import org.sigwinch.xacml.tree.FunctionCallPredicate;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.SimplePredicate;
import org.sigwinch.xacml.tree.SolePredicate;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * ApplyParser.java Created: Tue Nov 4 19:15:35 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes </a>
 * @version 1.0
 */
public class ApplyParser extends ExpressionParser {
    public ApplyParser () {

    }

    /**
     * Return a predicate corresponding to the Apply node at
     * <code>element</code>.
     * 
     * @param element
     *            element to parse
     * @return corresponding predicate
     */
    public Predicate parseElement (Element element) {
        String functionId = getXACMLAttribute (element, "FunctionId");
        ArrayList predicates = new ArrayList ();
        Node child = element.getFirstChild ();
        while (child != null) {
            if (child.getNodeType () == Node.ELEMENT_NODE)
                predicates.add (parseExpression ((Element) child));
            child = child.getNextSibling ();
        }
        if (oneandonlyLookup.get (functionId) != null) {
            assert predicates.size () == 1;
            return (Predicate) predicates.get (0);
        }
        return new FunctionCallPredicate (
                                          functionId,
                                          (Predicate[]) predicates
                                                                  .toArray (new Predicate[] {}));

    }

    /**
     * Return a predicate corresponding to error conditions in the tree at
     * <code>element</code>.
     * 
     * @param element
     *            element to parse
     * @return corresponding predicate
     */
    public Predicate parseForError (Element element) {
        String functionId = getXACMLAttribute (element, "FunctionId");
        Predicate p = SimplePredicate.TRUE;
        Node child = element.getFirstChild ();
        while (child != null) {
            if (child.getNodeType () == Node.ELEMENT_NODE)
                p = p.andWith (parseForError ((Element) child));
            child = child.getNextSibling ();
        }
        if (oneandonlyLookup.get (functionId) != null) {
            Predicate expression = parseExpression (element);
            return p.andWith (new SolePredicate (expression).not ());
        }
        return p;
    }

}
/*
 * arch-tag: 569E8DEE-0F3E-11D8-B20D-000A95A2610A
 */
