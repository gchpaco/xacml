package org.sigwinch.xacml.tree;

import java.io.PrintWriter;

/**
 * Write to the given stream a Lispy representation of the output.
 * 
 * 
 * Created: Sun Nov 9 04:19:58 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class LispOutputVisitor implements Visitor {
    /** Stream to output to. */
    final PrintWriter stream;

    /**
     * Number of temporary variables generated so far. Important for uniqueness.
     */
    int variables;

    public LispOutputVisitor(PrintWriter stream) {
        this.stream = stream;
        variables = 0;
    }

    /**
     * Gets the value of stream
     * 
     * @return the value of stream
     */
    public PrintWriter getStream() {
        return this.stream;
    }

    /**
     * Gets the value of variables
     * 
     * @return the value of variables
     */
    public int getVariables() {
        return this.variables;
    }

    // Implementation of org.sigwinch.xacml.tree.Visitor

    /**
     * Write "deny" to <code>stream</code>.
     * 
     * @param deny
     *            a <code>Deny</code> node
     */
    public void walkDeny(Deny deny) {
        stream.print("deny");
    }

    /**
     * Write "permit" to <code>stream</code>.
     * 
     * @param permit
     *            a <code>Permit</code> value
     */
    public void walkPermit(Permit permit) {
        stream.print("permit");
    }

    /**
     * Write <code>error</code> in a Lispy way to <code>stream</code>.
     * 
     * @param error
     *            an <code>Error</code> node
     */
    public void walkError(Error error) {
        stream.print("(error ");
        error.getChild().walk(this);
        stream.print(" ");
        error.getCondition().walk(this);
        stream.print(")");
    }

    /**
     * Write <code>error</code> in a Lispy way to <code>stream</code>.
     * 
     * @param scope
     *            a <code>Scope</code> node
     */
    public void walkScope(Scope scope) {
        stream.print("(scope ");
        scope.getChild().walk(this);
        stream.print(" ");
        scope.getCondition().walk(this);
        stream.print(")");
    }

    /**
     * Write <code>triple</code> in a Lispy way to <code>stream</code>.
     * 
     * @param triple
     *            a <code>Triple</code> node
     */
    public void walkTriple(Triple triple) {
        stream.print("(triple ");
        triple.getPermit().walk(this);
        stream.print(" ");
        triple.getDeny().walk(this);
        stream.print(" ");
        triple.getError().walk(this);
        stream.print(")");
    }

    /**
     * Write <code>permitOverridesRule</code> in a Lispy way to
     * <code>stream</code>.
     * 
     * @param permitOverridesRule
     *            a <code>PermitOverridesRule</code> node
     */
    public void walkPermitOverridesRule(PermitOverridesRule permitOverridesRule) {
        stream.print("(permit-overrides ");
        Tree rule = permitOverridesRule;
        while (rule instanceof PermitOverridesRule) {
            PermitOverridesRule p = (PermitOverridesRule) rule;
            p.getLeft().walk(this);
            stream.print(" ");
            rule = p.getRight();
        }
        rule.walk(this);
        stream.print(")");
    }

    /**
     * Write <code>denyOverridesRule</code> in a Lispy way to
     * <code>stream</code>.
     * 
     * @param denyOverridesRule
     *            a <code>DenyOverridesRule</code> node
     */
    public void walkDenyOverridesRule(DenyOverridesRule denyOverridesRule) {
        stream.print("(deny-overrides ");
        Tree rule = denyOverridesRule;
        while (rule instanceof DenyOverridesRule) {
            DenyOverridesRule d = (DenyOverridesRule) rule;
            d.getLeft().walk(this);
            stream.print(" ");
            rule = d.getRight();
        }
        rule.walk(this);
        stream.print(")");
    }

    /**
     * Write <code>onlyOneRule</code> in a Lispy way to <code>stream</code>.
     * 
     * @param onlyOneRule
     *            an <code>OnlyOneRule</code> node
     */
    public void walkOnlyOneRule(OnlyOneRule onlyOneRule) {
        stream.print("(only-one ");
        Tree rule = onlyOneRule;
        while (rule instanceof OnlyOneRule) {
            OnlyOneRule o = (OnlyOneRule) rule;
            o.getLeft().walk(this);
            stream.print(" ");
            rule = o.getRight();
        }
        rule.walk(this);
        stream.print(")");
    }

    /**
     * Write <code>firstApplicableRule</code> in a Lispy way to
     * <code>stream</code>.
     * 
     * @param firstApplicableRule
     *            a <code>FirstApplicableRule</code> node
     */
    public void walkFirstApplicableRule(FirstApplicableRule firstApplicableRule) {
        stream.print("(first-applicable ");
        Tree rule = firstApplicableRule;
        while (rule instanceof FirstApplicableRule) {
            FirstApplicableRule f = (FirstApplicableRule) rule;
            f.getLeft().walk(this);
            stream.print(" ");
            rule = f.getRight();
        }
        rule.walk(this);
        stream.print(")");
    }

    private void walkAnds(Predicate p) {
        if (p instanceof AndPredicate) {
            AndPredicate a = (AndPredicate) p;
            walkAnds(a.getLeft());
            stream.print(" ");
            a.getRight().walk(this);
        } else {
            p.walk(this);
        }
    }

    /**
     * Write <code>andPredicate</code> in a Lispy way to <code>stream</code>.
     * 
     * @param andPredicate
     *            an <code>AndPredicate</code> node
     */
    public void walkAndPredicate(AndPredicate andPredicate) {
        stream.print("(and ");
        walkAnds(andPredicate.getLeft());
        stream.print(" ");
        andPredicate.getRight().walk(this);
        stream.print(")");
    }

    /**
     * Write <code>constantValuePredicate</code> in a Lispy way to
     * <code>stream</code>.
     * 
     * @param constantValuePredicate
     *            a <code>ConstantValuePredicate</code> node
     */
    public void walkConstantValuePredicate(
            ConstantValuePredicate constantValuePredicate) {
        stream.print("(");
        stream.print(constantValuePredicate.getShortName());
        stream.print(" \"");
        stream.print(constantValuePredicate.getValue());
        stream.print("\")");
    }

    /**
     * Write <code>environmentalPredicate</code> in a Lispy way to
     * <code>stream</code>.
     * 
     * @param environmentalPredicate
     *            an <code>EnvironmentalPredicate</code> node
     */
    public void walkEnvironmentalPredicate(
            EnvironmentalPredicate environmentalPredicate) {
        stream.print("(e ");
        stream.print(environmentalPredicate.getUniqueId());
        stream.print(")");
    }

    /**
     * Write <code>existentialPredicate</code> in a Lispy way to
     * <code>stream</code>.
     * 
     * @param existentialPredicate
     *            an <code>ExistentialPredicate</code> node
     */
    public void walkExistentialPredicate(
            ExistentialPredicate existentialPredicate) {
        int myvar = variables++;
        stream.print("(for-some (x");
        stream.print(myvar);
        stream.print(" ");
        existentialPredicate.getBag().walk(this);
        stream.print(") ");
        new FunctionCallPredicate(existentialPredicate.getFunction(),
                new Predicate[] { new VariableReference("x" + myvar),
                        existentialPredicate.getAttribute() }).walk(this);
        stream.print(")");
    }

    /**
     * Write <code>functionCallPredicate</code> in a Lispy way to
     * <code>stream</code>.
     * 
     * @param functionCallPredicate
     *            a <code>FunctionCallPredicate</code> node
     */
    public void walkFunctionCallPredicate(
            FunctionCallPredicate functionCallPredicate) {
        LispFunctionVisitor v = new LispFunctionVisitor(this);
        v.visitFunction(functionCallPredicate);
    }

    private void walkOrs(Predicate p) {
        if (p instanceof OrPredicate) {
            OrPredicate o = (OrPredicate) p;
            walkAnds(o.getLeft());
            stream.print(" ");
            o.getRight().walk(this);
        } else {
            p.walk(this);
        }
    }

    /**
     * Write <code>orPredicate</code> in a Lispy way to <code>stream</code>.
     * 
     * @param orPredicate
     *            an <code>OrPredicate</code> node
     */
    public void walkOrPredicate(OrPredicate orPredicate) {
        stream.print("(or ");
        walkOrs(orPredicate.getLeft());
        stream.print(" ");
        orPredicate.getRight().walk(this);
        stream.print(")");
    }

    /**
     * Write <code>simplePredicate</code> in a Lispy way to
     * <code>stream</code>.
     * 
     * @param simplePredicate
     *            a <code>SimplePredicate</code> node
     */
    public void walkSimplePredicate(SimplePredicate simplePredicate) {
        if (simplePredicate == SimplePredicate.TRUE)
            stream.print("t");
        else
            stream.print("nil");
    }

    /**
     * Write <code>solePredicate</code> in a Lispy way to <code>stream</code>.
     * 
     * @param solePredicate
     *            a <code>SolePredicate</code> node
     */
    public void walkSolePredicate(SolePredicate solePredicate) {
        stream.print("(sole ");
        solePredicate.getSet().walk(this);
        stream.print(")");
    }

    /**
     * Write <code>variableReference</code> in a Lispy way to
     * <code>stream</code>.
     * 
     * @param variableReference
     *            a <code>VariableReference</code> node
     */
    public void walkVariableReference(VariableReference variableReference) {
        stream.print(variableReference.getName());
    }

    class LispFunctionVisitor extends FunctionVisitor {
        LispOutputVisitor visitor;

        LispFunctionVisitor(LispOutputVisitor visitor) {
            this.visitor = visitor;
        }

        // Implementation of org.sigwinch.xacml.tree.FunctionVisitor

        /**
         * Write the size functions to <code>stream</code>
         * 
         * @param predicate
         *            predicate to find size of
         */
        @Override
        public void visitSize(Predicate predicate) {
            stream.print("(size ");
            predicate.walk(visitor);
            stream.print(")");
        }

        /**
         * Write the inclusion functions to <code>stream</code>
         * 
         * @param element
         *            element
         * @param set
         *            set to test
         */
        @Override
        public void visitInclusion(Predicate element, Predicate set) {
            stream.print("(in-p");
            element.walk(visitor);
            stream.print(" ");
            set.walk(visitor);
            stream.print(")");
        }

        /**
         * Write the set creation functions to <code>stream</code>.
         * 
         * @param predicate
         *            singleton to wrap in a set
         */
        @Override
        public void visitSetCreation(Predicate predicate) {
            stream.print("(set ");
            predicate.walk(visitor);
            stream.print(")");
        }

        /**
         * Write the equality functions to <code>stream</code>.
         * 
         * @param first
         *            first value to compare
         * @param second
         *            second value to compare
         */
        @Override
        public void visitEquality(Predicate first, Predicate second) {
            stream.print("(= ");
            first.walk(visitor);
            stream.print(" ");
            second.walk(visitor);
            stream.print(")");
        }

        /**
         * Write the intersection methods to <code>stream</code>.
         * 
         * @param first
         *            first set
         * @param second
         *            second set
         */
        @Override
        public void visitIntersection(Predicate first, Predicate second) {
            stream.print("(intersection ");
            first.walk(visitor);
            stream.print(" ");
            second.walk(visitor);
            stream.print(")");
        }

        /**
         * Write the union methods to <code>stream</code>.
         * 
         * @param first
         *            first set
         * @param second
         *            second set
         */
        @Override
        public void visitUnion(Predicate first, Predicate second) {
            stream.print("(union ");
            first.walk(visitor);
            stream.print(" ");
            second.walk(visitor);
            stream.print(")");
        }

        /**
         * Write the subset methods to <code>stream</code>.
         * 
         * @param first
         *            first set
         * @param second
         *            second set
         */
        @Override
        public void visitSubset(Predicate first, Predicate second) {
            stream.print("(subset-p ");
            first.walk(visitor);
            stream.print(" ");
            second.walk(visitor);
            stream.print(")");
        }

        /**
         * Write the at least one methods to <code>stream</code>.
         * 
         * @param first
         *            first set
         * @param second
         *            second set
         */
        @Override
        public void visitAtLeastOne(Predicate first, Predicate second) {
            stream.print("(/= (intersection ");
            first.walk(visitor);
            stream.print(" ");
            second.walk(visitor);
            stream.print(") '())");
        }

        /**
         * Write the set equality methods to <code>stream</code>.
         * 
         * @param first
         *            first set
         * @param second
         *            second set
         */
        @Override
        public void visitSetEquality(Predicate first, Predicate second) {
            stream.print("(and (subset-p ");
            first.walk(visitor);
            stream.print(" ");
            second.walk(visitor);
            stream.print(") (subset-p ");
            second.walk(visitor);
            stream.print(" ");
            first.walk(visitor);
            stream.print("))");
        }

        /**
         * Write the greater-than methods to <code>stream</code>.
         * 
         * @param first
         *            first arithmetic value
         * @param second
         *            second arithmetic value
         */
        @Override
        public void visitGreaterThan(Predicate first, Predicate second) {
            stream.print("(> ");
            first.walk(visitor);
            stream.print(" ");
            second.walk(visitor);
            stream.print(")");
        }

        /**
         * Write the greater-than-or-equal methods to <code>stream</code>.
         * 
         * @param first
         *            first arithmetic value
         * @param second
         *            second arithmetic value
         */
        @Override
        public void visitGreaterThanOrEqual(Predicate first, Predicate second) {
            stream.print("(>= ");
            first.walk(visitor);
            stream.print(" ");
            second.walk(visitor);
            stream.print(")");
        }

        /**
         * Write the less-than methods to <code>stream</code>.
         * 
         * @param first
         *            first arithmetic value
         * @param second
         *            second arithmetic value
         */
        @Override
        public void visitLessThan(Predicate first, Predicate second) {
            stream.print("(< ");
            first.walk(visitor);
            stream.print(" ");
            second.walk(visitor);
            stream.print(")");
        }

        /**
         * Write the less-than-or-equal methods to <code>stream</code>.
         * 
         * @param first
         *            first arithmetic value
         * @param second
         *            second arithmetic value
         */
        @Override
        public void visitLessThanOrEqual(Predicate first, Predicate second) {
            stream.print("(<= ");
            first.walk(visitor);
            stream.print(" ");
            second.walk(visitor);
            stream.print(")");
        }

        /**
         * Write and to <code>stream</code>.
         * 
         * @param arguments
         *            predicates to combine
         */
        @Override
        public void visitAnd(Predicate[] arguments) {
            stream.print("(and");
            for (int i = 0; i < arguments.length; i++) {
                stream.print(" ");
                arguments[i].walk(visitor);
            }
            stream.print(")");
        }

        /**
         * Write or to <code>stream</code>.
         * 
         * @param arguments
         *            predicates to combine
         */
        @Override
        public void visitOr(Predicate[] arguments) {
            stream.print("(or");
            for (int i = 0; i < arguments.length; i++) {
                stream.print(" ");
                arguments[i].walk(visitor);
            }
            stream.print(")");
        }

        /**
         * Write not to <code>stream</code>.
         * 
         * @param predicate
         *            a <code>Predicate</code>
         */
        @Override
        public void visitNot(Predicate predicate) {
            stream.print("(not ");
            predicate.walk(visitor);
            stream.print(")");
        }

        /**
         * Write unnamed functions to <code>stream</code>.
         * 
         * @param string
         *            function
         * @param arguments
         *            arguments
         */
        @Override
        public void visitDefault(String string, Predicate[] arguments) {
            stream.print("(");
            stream.print(string);
            for (int i = 0; i < arguments.length; i++) {
                stream.print(" ");
                arguments[i].walk(visitor);
            }
            stream.print(")");
        }

    }
}
/*
 * arch-tag: 0CD45411-12AF-11D8-8CED-000A95A2610A
 */
