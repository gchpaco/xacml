package org.sigwinch.xacml.parser;

import java.util.HashMap;

import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.SimplePredicate;
import org.w3c.dom.Element;

/**
 * Parser for XACML expressions.
 * <p>
 * Created: Wed Oct 22 13:02:49 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes </a>
 * @version 1.0
 */
public class ExpressionParser extends XACMLParser {
    static HashMap matchingLookup;
    static HashMap<String, Boolean> oneandonlyLookup;
    static HashMap functionLookup;
    static HashMap<String, HashMap<String, ExpressionParser>> elementLookup;

    static {
        matchingLookup = new HashMap ();
        oneandonlyLookup = new HashMap<String, Boolean> ();
        oneandonlyLookup
                        .put (
                              "urn:oasis:names:tc:xacml:1.0:function:string-one-and-only",
                              Boolean.TRUE);
        oneandonlyLookup
                        .put (
                              "urn:oasis:names:tc:xacml:1.0:function:boolean-one-and-only",
                              Boolean.TRUE);
        oneandonlyLookup
                        .put (
                              "urn:oasis:names:tc:xacml:1.0:function:integer-one-and-only",
                              Boolean.TRUE);
        oneandonlyLookup
                        .put (
                              "urn:oasis:names:tc:xacml:1.0:function:double-one-and-only",
                              Boolean.TRUE);
        oneandonlyLookup
                        .put (
                              "urn:oasis:names:tc:xacml:1.0:function:time-one-and-only",
                              Boolean.TRUE);
        oneandonlyLookup
                        .put (
                              "urn:oasis:names:tc:xacml:1.0:function:date-one-and-only",
                              Boolean.TRUE);
        oneandonlyLookup
                        .put (
                              "urn:oasis:names:tc:xacml:1.0:function:dateTime-one-and-only",
                              Boolean.TRUE);
        oneandonlyLookup
                        .put (
                              "urn:oasis:names:tc:xacml:1.0:function:anyURI-one-and-only",
                              Boolean.TRUE);
        oneandonlyLookup
                        .put (
                              "urn:oasis:names:tc:xacml:1.0:function:hexBinary-one-and-only",
                              Boolean.TRUE);
        oneandonlyLookup
                        .put (
                              "urn:oasis:names:tc:xacml:1.0:function:base64Binary-one-and-only",
                              Boolean.TRUE);
        oneandonlyLookup
                        .put (
                              "urn:oasis:names:tc:xacml:1.0:function:dayTimeDuration-one-and-only",
                              Boolean.TRUE);
        oneandonlyLookup
                        .put (
                              "urn:oasis:names:tc:xacml:1.0:function:yearMonthDuration-one-and-only",
                              Boolean.TRUE);
        oneandonlyLookup
                        .put (
                              "urn:oasis:names:tc:xacml:1.0:function:x500Name-one-and-only",
                              Boolean.TRUE);
        oneandonlyLookup
                        .put (
                              "urn:oasis:names:tc:xacml:1.0:function:rfc822Name-one-and-only",
                              Boolean.TRUE);
        functionLookup = new HashMap ();
        elementLookup = new HashMap<String, HashMap<String, ExpressionParser>> ();
        HashMap<String, ExpressionParser> subtable = new HashMap<String, ExpressionParser> ();
        elementLookup.put (xacmlns, subtable);
        subtable.put ("AttributeValue", new AttributeValueParser ());
        subtable.put ("ResourceMatch", new MatchingParser ());
        subtable.put ("SubjectMatch", new MatchingParser ());
        subtable.put ("ActionMatch", new MatchingParser ());
        subtable.put ("EnvironmentAttributeDesignator", new AttributeParser ());
        subtable.put ("ResourceAttributeDesignator", new AttributeParser ());
        subtable.put ("SubjectAttributeDesignator", new AttributeParser ());
        subtable.put ("ActionAttributeDesignator", new AttributeParser ());
        subtable.put ("AttributeSelector", new AttributeSelectorParser ());
        subtable.put ("Apply", new ApplyParser ());
        subtable.put ("Condition", new ApplyParser ());
        subtable.put ("Function", new FunctionParser ());
    }

    public ExpressionParser () {

    }

    public Predicate parseElement (Element element) {
        return SimplePredicate.TRUE;
    }

    public Predicate parseForError (Element element) {
        return SimplePredicate.FALSE;
    }

    static public Predicate parseExpression (Element expression) {
        return getParser (expression).parseElement (expression);
    }

    static public Predicate parseError (Element expression) {
        return getParser (expression).parseForError (expression);
    }

    private static ExpressionParser getParser (Element expression) {
        String ns = expression.getNamespaceURI ();
        if (ns == null)
            ns = xacmlns;
        String name = expression.getNodeName ();
        ExpressionParser parser = elementLookup.get (ns).get (name);
        if (parser == null)
            parser = new ExpressionParser ();
        return parser;
    }
}
/*
 * arch-tag: B7D1A6E6-04CA-11D8-98CF-000A95A2610A
 */
