package org.sigwinch.xacml.tree;

import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.FunctionCallPredicate;

/**
 * FunctionVisitor.java Created: Sun Nov 16 02:41:52 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes </a>
 * @version 1.0
 */

public abstract class FunctionVisitor {
    public static String xacmlprefix = "urn:oasis:names:tc:xacml:1.0:function:";

    protected String name;

    protected Predicate[] args;

    protected int index;

    public void visitFunction(FunctionCallPredicate func) {
        visitFunction(func.getFunction(), func.getArguments(), func.getIndex());
    }

    public void visitFunction(String function, Predicate[] arguments, int i) {
        this.name = function;
        this.args = arguments;
        this.index = i;
        if (function.startsWith(xacmlprefix)) {
            String rest = function.substring(xacmlprefix.length());
            if (rest.endsWith("-bag-size")) {
                assert arguments.length == 1;
                visitSize(arguments[0]);
            } else if (rest.endsWith("-is-in")) {
                assert arguments.length == 2;
                visitInclusion(arguments[0], arguments[1]);
            } else if (rest.endsWith("-greater-than")) {
                assert arguments.length == 2;
                visitGreaterThan(arguments[0], arguments[1]);
            } else if (rest.endsWith("-greater-than-or-equal")) {
                assert arguments.length == 2;
                visitGreaterThanOrEqual(arguments[0], arguments[1]);
            } else if (rest.endsWith("-less-than")) {
                assert arguments.length == 2;
                visitLessThan(arguments[0], arguments[1]);
            } else if (rest.endsWith("-less-than-or-equal")) {
                assert arguments.length == 2;
                visitLessThanOrEqual(arguments[0], arguments[1]);
            } else if (rest.endsWith("-bag")) {
                assert arguments.length == 1;
                visitSetCreation(arguments[0]);
            } else if (rest.endsWith("-equal")) {
                assert arguments.length == 2;
                visitEquality(arguments[0], arguments[1]);
            } else if (rest.endsWith("-intersection")) {
                assert arguments.length == 2;
                visitIntersection(arguments[0], arguments[1]);
            } else if (rest.endsWith("-union")) {
                assert arguments.length == 2;
                visitUnion(arguments[0], arguments[1]);
            } else if (rest.endsWith("-subset")) {
                assert arguments.length == 2;
                visitSubset(arguments[0], arguments[1]);
            } else if (rest.endsWith("-at-least-one-member-of")) {
                assert arguments.length == 2;
                visitAtLeastOne(arguments[0], arguments[1]);
            } else if (rest.endsWith("-set-equals")) {
                assert arguments.length == 2;
                visitSetEquality(arguments[0], arguments[1]);
            } else if (rest.equals("and")) {
                visitAnd(arguments);
            } else if (rest.endsWith("or")) {
                visitOr(arguments);
            } else if (rest.endsWith("not")) {
                assert arguments.length == 1;
                visitNot(arguments[0]);
            } else {
                visitDefault(function, arguments);
            }
        } else {
            visitDefault(function, arguments);
        }
    }

    protected String getType() {
        if (name.startsWith(xacmlprefix)) {
            String rest = name.substring(xacmlprefix.length());
            int dash = rest.indexOf('-');
            if (dash == -1)
                return null;
            String type = rest.substring(0, dash);
            if (type.equals("string"))
                return "http://www.w3.org/2001/XMLSchema#string";
            else if (type.equals("integer"))
                return "http://www.w3.org/2001/XMLSchema#integer";
            else if (type.equals("boolean"))
                return "http://www.w3.org/2001/XMLSchema#boolean";
            else if (type.equals("double"))
                return "http://www.w3.org/2001/XMLSchema#double";
            else if (type.equals("time"))
                return "http://www.w3.org/2001/XMLSchema#time";
            else if (type.equals("date"))
                return "http://www.w3.org/2001/XMLSchema#date";
            else if (type.equals("dateTime"))
                return "http://www.w3.org/2001/XMLSchema#dateTime";
            else if (type.equals("anyURI"))
                return "http://www.w3.org/2001/XMLSchema#anyURI";
            else if (type.equals("hexBinary"))
                return "http://www.w3.org/2001/XMLSchema#hexBinary";
            else if (type.equals("base64Binary"))
                return "http://www.w3.org/2001/XMLSchema#base64Binary";
            else if (type.equals("dayTimeDuration"))
                return "http://www.w3.org/TR/2002/WD-xquery-operators"
                        + "-20020816#dayTimeDuration";
            else if (type.equals("yearMonthDuration"))
                return "http://www.w3.org/TR/2002/WD-xquery-operators"
                        + "-20020816#yearMonthDuration";
            else if (type.equals("x500Name"))
                return "urn:oasis:names:tc:xcaml:1.0:data-type:x500Name";
            else if (type.equals("x500Name"))
                return "urn:oasis:names:tc:xcaml:1.0:data-type:rfc822Name";
            else
                return null;
        }
        return null;
    }

    public abstract void visitSize(Predicate argument);

    public abstract void visitInclusion(Predicate element, Predicate set);

    public abstract void visitSetCreation(Predicate element);

    public abstract void visitEquality(Predicate first, Predicate second);

    public abstract void visitIntersection(Predicate first, Predicate second);

    public abstract void visitUnion(Predicate first, Predicate second);

    public abstract void visitSubset(Predicate first, Predicate second);

    public abstract void visitAtLeastOne(Predicate first, Predicate second);

    public abstract void visitSetEquality(Predicate first, Predicate second);

    public abstract void visitGreaterThan(Predicate first, Predicate second);

    public abstract void visitGreaterThanOrEqual(Predicate first,
            Predicate second);

    public abstract void visitLessThan(Predicate first, Predicate second);

    public abstract void visitLessThanOrEqual(Predicate first, Predicate second);

    public abstract void visitAnd(Predicate[] arguments);

    public abstract void visitOr(Predicate[] arguments);

    public abstract void visitNot(Predicate first);

    public abstract void visitDefault(String function, Predicate[] arguments);
}
/*
 * arch-tag: 7E24A2BC-1821-11D8-B5B2-000A95A2610A
 */
