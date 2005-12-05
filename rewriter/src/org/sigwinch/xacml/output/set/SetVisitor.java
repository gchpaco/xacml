package org.sigwinch.xacml.output.set;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.HashMap;

import org.sigwinch.xacml.output.CodeVisitor;
import org.sigwinch.xacml.tree.*;

/**
 * SetVisitor.java
 * 
 * 
 * Created: Sat Dec 20 01:51:36 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class SetVisitor extends CodeVisitor {
    class PrecedencePair {
        String reference;

        int precedence;

        PrecedencePair(String reference, int precedence) {
            this.reference = reference;
            this.precedence = precedence;
        }

        @Override
        public String toString() {
            return reference;
        }

        static final int EQ = 0;

        static final int UNION = EQ + 1;

        static final int MINUS = UNION; // Yes, funky

        static final int INTERSECT = UNION + 1;

        static final int DOT = INTERSECT + 1;

        static final int NOT = DOT + 1;

        static final int VARIABLE = NOT + 1;
    }

    class PrecedenceMap extends HashMap<Predicate, PrecedencePair> {
        /**
         * 
         */
        private static final long serialVersionUID = 7136505735853358893L;

        String textOf(Predicate p) {
            return get(p).toString();
        }

        int precedenceOf(Predicate p) {
            return get(p).precedence;
        }

        void setTextFor(Predicate p, String text, int precedence) {
            put(p, new PrecedencePair(text, precedence));
        }
    }

    StringWriter functions, facts;

    PrintWriter fa;

    PrecedenceMap map;

    int count, triples;

    public SetVisitor() {
        super(null);
        this.functions = new StringWriter();
        this.stream = new PrintWriter(functions);
        this.facts = new StringWriter();
        this.fa = new PrintWriter(facts);
        this.map = new PrecedenceMap();
        this.count = 0;
        this.triples = 0;
    }

    @Override
    public void outputStart() {
        stream.println("one sig Functions {");
    }

    @Override
    public void outputEnd() {
        stream.println("}");
    }

    public String getFunctions() {
        return functions.toString();
    }

    public String getFacts() {
        return facts.toString();
    }

    public int getTriples() {
        return triples;
    }

    void maybeWalk(Predicate p) {
        if (!map.containsKey(p))
            p.walk(this);
    }

    String binaryFunction(String function, Predicate first, Predicate second,
            Predicate context, int precedence) {
        return maybeWrap(first, context, precedence) + " " + function + " "
                + maybeWrap(second, context, precedence);
    }

    String binaryFunction(String function, Predicate first, Predicate second,
            int precedence) {
        return maybeWrap(first, precedence) + " " + function + " "
                + maybeWrap(second, precedence);
    }

    String maybeWrap(Predicate p, Predicate context, int contextPrecedence) {
        if (p.getClass() == context.getClass())
            return map.textOf(p);
        return maybeWrap(p, contextPrecedence);
    }

    String maybeWrap(Predicate p, int contextPrecedence) {
        if (map.precedenceOf(p) > contextPrecedence)
            return map.textOf(p);
        return "(" + map.textOf(p) + ")";
    }

    @Override
    public void walkVariableReference(VariableReference ref) {
        map.setTextFor(ref, ref.getName(), PrecedencePair.VARIABLE);
    }

    /**
     * Given a set representation, TRUE represents the entire environmental set,
     * and FALSE represents the empty set.
     * 
     * @param simplePredicate
     *            a <code>SimplePredicate</code> value
     */
    @Override
    public void walkSimplePredicate(SimplePredicate simplePredicate) {
        if (simplePredicate == SimplePredicate.TRUE)
            map.setTextFor(simplePredicate, "E", PrecedencePair.VARIABLE);
        else
            map.setTextFor(simplePredicate, "none", PrecedencePair.UNION);
    }

    /**
     * Output code for testing sole sets.
     * 
     * @param solePredicate
     *            a <code>SolePredicate</code> value
     */
    @Override
    public void walkSolePredicate(SolePredicate solePredicate) {
        maybeWalk(solePredicate.getSet());
        int expr = count++;
        fa.print("sig S");
        fa.print(expr);
        fa.print(" extends E {} { one ");
        fa.print(maybeWrap(solePredicate.getSet(), PrecedencePair.UNION));
        fa.println(" }");
        map.setTextFor(solePredicate, "S" + expr, PrecedencePair.VARIABLE);
    }

    /**
     * Output code for an existential predicate.
     * 
     * @param pred
     *            an <code>ExistentialPredicate</code> value
     */
    @Override
    public void walkExistentialPredicate(ExistentialPredicate pred) {
        SetExistentialFV v = new SetExistentialFV(this, pred);
        v.visitFunction(pred.getFunction(), new Predicate[] {
                new VariableReference("x"), pred.getAttribute() }, pred
                .getIndex());
    }

    /**
     * Write code for anded predicates; this is just set intersection for us.
     * 
     * @param andPredicate
     *            an <code>AndPredicate</code>
     */
    @Override
    public void walkAndPredicate(AndPredicate andPredicate) {
        maybeWalk(andPredicate.getLeft());
        maybeWalk(andPredicate.getRight());
        map.setTextFor(andPredicate, binaryFunction("&",
                andPredicate.getLeft(), andPredicate.getRight(), andPredicate,
                PrecedencePair.INTERSECT), PrecedencePair.INTERSECT);
    }

    /**
     * Write code for ored predicates; this happens to be set union for our
     * representation.
     * 
     * @param orPredicate
     *            an <code>OrPredicate</code>
     */
    @Override
    public void walkOrPredicate(OrPredicate orPredicate) {
        maybeWalk(orPredicate.getLeft());
        maybeWalk(orPredicate.getRight());
        map.setTextFor(orPredicate, binaryFunction("+", orPredicate.getLeft(),
                orPredicate.getRight(), orPredicate, PrecedencePair.UNION),
                PrecedencePair.UNION);
    }

    /**
     * Write code for environmental predicates; this is just a variable
     * reference, really.
     * 
     * @param env
     *            an <code>EnvironmentalPredicate</code>
     */
    @Override
    public void walkEnvironmentalPredicate(EnvironmentalPredicate env) {
        map.setTextFor(env, "env" + env.getUniqueId(), PrecedencePair.VARIABLE);
    }

    /**
     * Write code for constant value predicates; this is again just a variable
     * reference.
     * 
     * @param con
     *            a <code>ConstantValuePredicate</code>
     */
    @Override
    public void walkConstantValuePredicate(ConstantValuePredicate con) {
        map.setTextFor(con, "S.static" + con.getUniqueId(), PrecedencePair.DOT);
    }

    /**
     * Output the code for the given function call.
     * 
     * @param functionCallPredicate
     *            a <code>FunctionCallPredicate</code>
     */
    @Override
    public void walkFunctionCallPredicate(
            FunctionCallPredicate functionCallPredicate) {
        SetFunctionVisitor v = new SetFunctionVisitor(this,
                functionCallPredicate);
        v.visitFunction(functionCallPredicate);
    }

    /**
     * Output the code for a triple node
     * 
     * @param triple
     *            a <code>Triple</code>
     */
    @Override
    public void walkTriple(Triple triple) {
        maybeWalk(triple.getPermit());
        maybeWalk(triple.getDeny());
        maybeWalk(triple.getError());
        fa.print("one sig T");
        fa.print(triples++);
        fa.println(" extends Triple {} {");
        fa.print("\tpermit = ");
        fa.println(maybeWrap(triple.getPermit(), PrecedencePair.EQ));
        fa.print("\tdeny = ");
        fa.println(maybeWrap(triple.getDeny(), PrecedencePair.EQ));
        fa.print("\terror = ");
        fa.println(maybeWrap(triple.getError(), PrecedencePair.EQ));
        fa.println("}");
    }

    class SetExistentialFV extends FunctionVisitorImpl {
        ExistentialPredicate predicate;

        SetExistentialFV(Visitor visitor, ExistentialPredicate predicate) {
            super(visitor);
            this.predicate = predicate;
        }

        @Override
        public void visitEquality(Predicate first, Predicate second) {
            maybeWalk(predicate.getBag());
            maybeWalk(predicate.getAttribute());
            int expr = count++;
            fa.print("sig S");
            fa.print(expr);
            fa.print(" extends E {} { ");
            fa.print(binaryFunction("in", predicate.getAttribute(), predicate
                    .getBag(), PrecedencePair.EQ));
            fa.println(" }");
            map.setTextFor(predicate, "S" + expr, PrecedencePair.VARIABLE);
        }

        @Override
        public void visitDefault(String string, Predicate[] arguments) {
            // only allowed weird function
            assert string.equals(xacmlprefix + "xpath-node-match") : string
                    + " is not xpath-node-match";
            maybeWalk(predicate.getBag());
            maybeWalk(predicate.getAttribute());
            String functionName = "expr" + count++;
            printFunction(functionName, "E", "Bool", "xpathnodematch ("
                    + map.textOf(predicate.getAttribute()) + ", "
                    + map.textOf(predicate.getBag()) + ")");

            int expr = count++;
            fa.print("sig S");
            fa.print(expr);
            fa.print(" extends E {} { this.(Functions.");
            fa.print(functionName);
            fa.println(") = True }");
            map.setTextFor(predicate, "S" + expr, PrecedencePair.VARIABLE);
        }
    }

    class SetFunctionVisitor extends FunctionVisitorImpl {
        FunctionCallPredicate func;

        SetFunctionVisitor(Visitor visitor, FunctionCallPredicate f) {
            super(visitor);
            func = f;
        }

        void visitBinaryFunction(String function, Predicate first,
                Predicate second, int precedence) {
            maybeWalk(first);
            maybeWalk(second);
            int expr = count++;
            fa.print("sig S");
            fa.print(expr);
            fa.print(" extends E {} { ");
            fa.print(binaryFunction(function, first, second, precedence));
            fa.println(" }");
            map.setTextFor(func, "S" + expr, PrecedencePair.VARIABLE);
        }

        @Override
        public void visitEquality(Predicate first, Predicate second) {
            visitBinaryFunction("=", first, second, PrecedencePair.EQ);
        }

        @Override
        public void visitSetEquality(Predicate first, Predicate second) {
            visitBinaryFunction("=", first, second, PrecedencePair.EQ);
        }

        /**
         * Output code for the bag size function.
         * 
         * @param predicate
         *            bag
         */
        @Override
        public void visitSize(Predicate predicate) {
            maybeWalk(predicate);
            String functionName = "expr" + count++;
            printFunction(functionName, "E", "Integer", "size of "
                    + map.textOf(predicate));
            map.setTextFor(func, "this.(Functions." + functionName + ")",
                    PrecedencePair.DOT);
        }

        /**
         * Write out code for testing whether one set is included in another. We
         * use auxiliary sets for this.
         */
        @Override
        public void visitInclusion(Predicate left, Predicate right) {
            visitBinaryFunction("in", left, right, PrecedencePair.EQ);
        }

        @Override
        public void visitSubset(Predicate first, Predicate second) {
            visitBinaryFunction("in", first, second, PrecedencePair.EQ);
        }

        @Override
        public void visitAtLeastOne(Predicate first, Predicate second) {
            maybeWalk(first);
            maybeWalk(second);
            int expr = count++;
            fa.print("sig S");
            fa.print(expr);
            fa.print(" extends E {} { some ");
            fa.print(binaryFunction("&", first, second,
                    PrecedencePair.INTERSECT));
            fa.println(" }");
            map.setTextFor(func, "S" + expr, PrecedencePair.VARIABLE);
        }

        @Override
        public void visitIntersection(Predicate first, Predicate second) {
            maybeWalk(first);
            maybeWalk(second);
            map.setTextFor(func, binaryFunction("&", first, second, func,
                    PrecedencePair.INTERSECT), PrecedencePair.INTERSECT);
        }

        @Override
        public void visitUnion(Predicate first, Predicate second) {
            maybeWalk(first);
            maybeWalk(second);
            map.setTextFor(func, binaryFunction("+", first, second, func,
                    PrecedencePair.UNION), PrecedencePair.UNION);
        }

        @Override
        public void visitLessThan(Predicate first, Predicate second) {
            maybeWalk(first);
            maybeWalk(second);
            int expr = count++;
            fa.print("sig S");
            fa.print(expr);
            fa.print(" extends E {} { types.lt (");
            fa.print(map.textOf(first));
            fa.print(", ");
            fa.print(map.textOf(second));
            fa.println(") }");
            map.setTextFor(func, "S" + expr, PrecedencePair.VARIABLE);
        }

        @Override
        public void visitLessThanOrEqual(Predicate first, Predicate second) {
            maybeWalk(first);
            maybeWalk(second);
            int expr = count++;
            fa.print("sig S");
            fa.print(expr);
            fa.print(" extends E {} { types.lte (");
            fa.print(map.textOf(first));
            fa.print(", ");
            fa.print(map.textOf(second));
            fa.println(") }");
            map.setTextFor(func, "S" + expr, PrecedencePair.VARIABLE);
        }

        @Override
        public void visitGreaterThan(Predicate first, Predicate second) {
            maybeWalk(first);
            maybeWalk(second);
            int expr = count++;
            fa.print("sig S");
            fa.print(expr);
            fa.print(" extends E {} { types.gt (");
            fa.print(map.textOf(first));
            fa.print(", ");
            fa.print(map.textOf(second));
            fa.println(") }");
            map.setTextFor(func, "S" + expr, PrecedencePair.VARIABLE);
        }

        @Override
        public void visitGreaterThanOrEqual(Predicate first, Predicate second) {
            maybeWalk(first);
            maybeWalk(second);
            int expr = count++;
            fa.print("sig S");
            fa.print(expr);
            fa.print(" extends E {} { types.gte (");
            fa.print(map.textOf(first));
            fa.print(", ");
            fa.print(map.textOf(second));
            fa.println(") }");
            map.setTextFor(func, "S" + expr, PrecedencePair.VARIABLE);
        }

        @Override
        public void visitAnd(Predicate[] arguments) {
            assert arguments.length > 0;
            maybeWalk(arguments[0]);
            StringBuffer text = new StringBuffer();
            text
                    .append(maybeWrap(arguments[0], func,
                            PrecedencePair.INTERSECT));
            for (int i = 1; i < arguments.length; i++) {
                maybeWalk(arguments[i]);
                text.append(" & ");
                text.append(maybeWrap(arguments[i], func,
                        PrecedencePair.INTERSECT));
            }
            map.setTextFor(func, text.toString(), PrecedencePair.INTERSECT);
        }

        @Override
        public void visitOr(Predicate[] arguments) {
            assert arguments.length > 0;
            maybeWalk(arguments[0]);
            StringBuffer text = new StringBuffer();
            text.append(maybeWrap(arguments[0], func, PrecedencePair.UNION));
            for (int i = 1; i < arguments.length; i++) {
                maybeWalk(arguments[i]);
                text.append(" + ");
                text
                        .append(maybeWrap(arguments[i], func,
                                PrecedencePair.UNION));
            }
            map.setTextFor(func, text.toString(), PrecedencePair.UNION);
        }

        @Override
        public void visitNot(Predicate predicate) {
            maybeWalk(predicate);
            map.setTextFor(func, "E - "
                    + maybeWrap(predicate, func, PrecedencePair.MINUS),
                    PrecedencePair.MINUS);
        }

        /**
         * Write code for set creation functions.
         */
        @Override
        public void visitSetCreation(Predicate predicate) {
            maybeWalk(predicate);
            map.setTextFor(func, map.textOf(predicate), map
                    .precedenceOf(predicate));
        }

        @Override
        public void visitDefault(String function, Predicate[] arguments) {
            for (int i = 0; i < arguments.length; i++)
                maybeWalk(arguments[i]);
            String functionName = "expr" + count++;
            StringBuffer comment = new StringBuffer();
            comment.append(function);
            comment.append(" (");
            comment.append(map.textOf(arguments[0]));
            for (int i = 1; i < arguments.length; i++) {
                comment.append(", ");
                comment.append(map.textOf(arguments[i]));
            }
            comment.append(")");
            printFunction(functionName, "E", "Type", comment.toString());
            map.setTextFor(func, "this.(Functions." + functionName + ")",
                    PrecedencePair.DOT);
        }
    }
}
/*
 * arch-tag: 1C0139D6-32D2-11D8-AEDA-000A957284DA
 */
