package org.sigwinch.xacml.output.alloycnf;

import java.io.PrintWriter;
import java.util.Map;

import org.sigwinch.xacml.tree.*;
import org.sigwinch.xacml.tree.Error;

/**
 * Output.java
 * 
 * 
 * Created: Sat Nov 15 22:55:41 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class OutputVisitor extends VisitorImpl {
    PrintWriter stream;

    int triples;

    Map map;

    public OutputVisitor(PrintWriter stream, int triples, Map map) {
        this.stream = stream;
        this.triples = triples;
        this.map = map;
    }

    public int getTriples() {
        return triples;
    }

    // Implementation of org.sigwinch.xacml.tree.Visitor

    /**
     * Describe <code>walkDeny</code> method here.
     * 
     * @param deny
     *            a <code>Deny</code> value
     */
    @Override
    public void walkDeny(Deny deny) {
        throw new IllegalArgumentException("Deny not supported for Alloy");
    }

    /**
     * Describe <code>walkPermit</code> method here.
     * 
     * @param permit
     *            a <code>Permit</code> value
     */
    @Override
    public void walkPermit(Permit permit) {
        throw new IllegalArgumentException("Permit not supported for Alloy");
    }

    /**
     * Describe <code>walkError</code> method here.
     * 
     * @param error
     *            an <code>Error</code> value
     */
    @Override
    public void walkError(Error error) {
        throw new IllegalArgumentException("Error not supported for Alloy");
    }

    /**
     * Describe <code>walkScope</code> method here.
     * 
     * @param scope
     *            a <code>Scope</code> value
     */
    @Override
    public void walkScope(Scope scope) {
        throw new IllegalArgumentException("Scope not supported for Alloy");
    }

    /**
     * Describe <code>walkTriple</code> method here.
     * 
     * @param triple
     *            a <code>Triple</code> value
     */
    @Override
    public void walkTriple(Triple triple) {
        stream.print("one sig T");
        stream.print(triples++);
        stream.println(" extends Triple {} {");
        stream.print("\tpermit = ");
        stream.print(map.get(triple.getPermit()));
        stream.print("\n\tdeny = ");
        stream.print(map.get(triple.getDeny()));
        stream.print("\n\terror = ");
        stream.print(map.get(triple.getError()));
        stream.print("\n}\n");
    }

    /**
     * Describe <code>walkPermitOverridesRule</code> method here.
     * 
     * @param permitOverridesRule
     *            a <code>PermitOverridesRule</code> value
     */
    @Override
    public void walkPermitOverridesRule(PermitOverridesRule permitOverridesRule) {
        throw new IllegalArgumentException(
                "Permit-overrides not supported for Alloy");
    }

    /**
     * Describe <code>walkDenyOverridesRule</code> method here.
     * 
     * @param denyOverridesRule
     *            a <code>DenyOverridesRule</code> value
     */
    @Override
    public void walkDenyOverridesRule(DenyOverridesRule denyOverridesRule) {
        throw new IllegalArgumentException(
                "Deny-overrides not supported for Alloy");
    }

    /**
     * Describe <code>walkOnlyOneRule</code> method here.
     * 
     * @param onlyOneRule
     *            an <code>OnlyOneRule</code> value
     */
    @Override
    public void walkOnlyOneRule(OnlyOneRule onlyOneRule) {
        throw new IllegalArgumentException("Only-one not supported for Alloy");
    }

    /**
     * Describe <code>walkFirstApplicableRule</code> method here.
     * 
     * @param firstApplicableRule
     *            a <code>FirstApplicableRule</code> value
     */
    @Override
    public void walkFirstApplicableRule(FirstApplicableRule firstApplicableRule) {
        throw new IllegalArgumentException(
                "First-applicable not supported for Alloy");
    }
}
/*
 * arch-tag: E917BD5B-1801-11D8-84EE-000A95A2610A
 */
