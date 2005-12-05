package org.sigwinch.xacml.output.alloycnf;

import junit.framework.*;

import org.sigwinch.xacml.tree.VariableReference;
import java.io.StringWriter;
import org.sigwinch.xacml.tree.EnvironmentalPredicate;
import java.io.PrintWriter;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.FunctionVisitor;
import org.sigwinch.xacml.tree.Triple;
import org.sigwinch.xacml.tree.SimplePredicate;
import org.sigwinch.xacml.tree.ConstantValuePredicate;
import org.sigwinch.xacml.tree.FunctionCallPredicate;
import org.sigwinch.xacml.tree.PermitOverridesRule;
import org.sigwinch.xacml.tree.ExistentialPredicate;
import org.sigwinch.xacml.tree.Tree;

/**
 * OutputTest.java
 * 
 * 
 * Created: Mon Nov 17 20:14:24 2003
 * 
 * @author Graham Hughes
 * @version
 */

public class OutputTest extends TestCase {
    VariableReference a, b, c;

    Triple t;

    String xp;

    AlloyCNFOutput out;

    StringWriter stream;

    static final String prelude;

    static {
        prelude = "module foo\n"
                + "open util/boolean\n"
                + "open util/ordering[Type] as types\n"
                + "abstract sig Triple {\n"
                + "\tpermit : one Bool,\n"
                + "\tdeny : one Bool,\n"
                + "\terror : one Bool\n"
                + "}\n"
                + "abstract sig Type {}\n"
                + "fun And (a:one Bool, b:one Bool): "
                + "one Bool {\n"
                + "\tresult = if (a = True && b = True) then True else False\n"
                + "}\n"
                + "fun Or (a:one Bool, b:one Bool): "
                + "one Bool {\n"
                + "\tresult = if (a = False && b = False) then False else True\n"
                + "}\n" + "fun Eq (a:Type, b:Type): one Bool {\n"
                + "\tresult = if (a = b) then True else False\n" + "}\n"
                + "fun In (a:Type, b:Type): one Bool {\n"
                + "\tresult = if (a in b) then True else False\n" + "}\n"
                + "fun AtLeastOne (a:Type, b:Type): one Bool {\n"
                + "\tresult = if (some (a & b)) then True else False\n" + "}\n";
    }

    public static Test suite() {
        return new TestSuite(OutputTest.class);
    }

    protected void reset() {
        stream = new StringWriter();
        out = new AlloyCNFOutput(new PrintWriter(stream), 2.0);
        Predicate.reset();
    }

    @Override
    protected void setUp() {
        a = new VariableReference("a");
        b = new VariableReference("b");
        c = new VariableReference("c");
        xp = FunctionVisitor.xacmlprefix;
        // To make sure that the element positions in the triples
        // won't change constantly, we need to reset the counts now.
        Predicate.reset();
        t = new Triple(
                new EnvironmentalPredicate("frob", "foo")
                        .andWith(a)
                        .andWith(SimplePredicate.TRUE)
                        .andWith(new ConstantValuePredicate("frob", "quux"))
                        .andWith(
                                new ConstantValuePredicate(
                                        "http://www.w3.org/2001/XMLSchema#date",
                                        "fred"))
                        .andWith(
                                new ConstantValuePredicate(
                                        "http://www.w3.org/TR/2002/WD-xquery-"
                                                + "operators-20020816#yearMonthDuration",
                                        "barney"))
                        .andWith(
                                new FunctionCallPredicate("foo",
                                        new Predicate[] { a }))
                        .andWith(
                                new FunctionCallPredicate(xp + "string-equal",
                                        new Predicate[] { a, b }))
                        .andWith(
                                new FunctionCallPredicate(
                                        xp + "integer-equal",
                                        new Predicate[] {
                                                new FunctionCallPredicate(xp
                                                        + "string-bag-size",
                                                        new Predicate[] { a }),
                                                new ConstantValuePredicate(
                                                        "http://www.w3.org/2001/XMLSchema#integer",
                                                        "2") })), b, c);
        reset();
    }

    public void testFullOutput() {
        out.output(t);
        assertEquals(prelude + "sig Date extends Type {}\n"
                + "sig Integer extends Type {}\n"
                + "sig YearMonthDuration extends Type {}\n"
                + "sig frob extends Type {}\n" + "one sig E {\n"
                + "\tenv0 : some frob // foo\n" + "}\n" + "one sig S {\n"
                + "\tstatic0 : one frob, // quux\n"
                + "\tstatic1 : one Date, // fred\n"
                + "\tstatic2 : one YearMonthDuration, // barney\n"
                + "\tstatic3 : one Integer // 2\n" + "}\n" + "one sig X {\n"
                + "\tand0 : one Bool,\n" + "\tand1 : one Bool,\n"
                + "\tand2 : one Bool,\n" + "\tand3 : one Bool,\n"
                + "\texpr4 : one Bool, // foo\n" + "\tand5 : one Bool,\n"
                + "\texpr6 : one Bool,\n" + "\tand7 : one Bool,\n"
                + "\texpr8 : one Integer, // " + xp + "string-bag-size\n"
                + "\texpr9 : one Bool,\n" + "\tand10 : one Bool\n" + "}\n"
                + "fact {\n" + "\tX.and0 = And (E.env0, a)\n"
                + "\tX.and1 = And (X.and0, S.static0)\n"
                + "\tX.and2 = And (X.and1, S.static1)\n"
                + "\tX.and3 = And (X.and2, S.static2)\n"
                + "\tX.and5 = And (X.and3, X.expr4)\n"
                + "\tX.expr6 = Eq (a, b)\n"
                + "\tX.and7 = And (X.and5, X.expr6)\n"
                + "\tX.expr9 = Eq (X.expr8, S.static3)\n"
                + "\tX.and10 = And (X.and7, X.expr9)\n" + "}\n"
                + "one sig T0 extends Triple {} {\n" + "\tpermit = X.and10\n"
                + "\tdeny = b\n" + "\terror = c\n" + "}\n", stream.toString());
    }

    public void testRepeatedOutput() {
        Tree unified = new PermitOverridesRule(t, t);
        out.preamble(unified);
        out.write(t);
        out.write(t);
        out.postamble();
        assertEquals(prelude + "sig Date extends Type {}\n"
                + "sig Integer extends Type {}\n"
                + "sig YearMonthDuration extends Type {}\n"
                + "sig frob extends Type {}\n" + "one sig E {\n"
                + "\tenv0 : some frob // foo\n" + "}\n" + "one sig S {\n"
                + "\tstatic0 : one frob, // quux\n"
                + "\tstatic1 : one Date, // fred\n"
                + "\tstatic2 : one YearMonthDuration, // barney\n"
                + "\tstatic3 : one Integer // 2\n" + "}\n" + "one sig X {\n"
                + "\tand0 : one Bool,\n" + "\tand1 : one Bool,\n"
                + "\tand2 : one Bool,\n" + "\tand3 : one Bool,\n"
                + "\texpr4 : one Bool, // foo\n" + "\tand5 : one Bool,\n"
                + "\texpr6 : one Bool,\n" + "\tand7 : one Bool,\n"
                + "\texpr8 : one Integer, // " + xp + "string-bag-size\n"
                + "\texpr9 : one Bool,\n" + "\tand10 : one Bool\n" + "}\n"
                + "fact {\n" + "\tX.and0 = And (E.env0, a)\n"
                + "\tX.and1 = And (X.and0, S.static0)\n"
                + "\tX.and2 = And (X.and1, S.static1)\n"
                + "\tX.and3 = And (X.and2, S.static2)\n"
                + "\tX.and5 = And (X.and3, X.expr4)\n"
                + "\tX.expr6 = Eq (a, b)\n"
                + "\tX.and7 = And (X.and5, X.expr6)\n"
                + "\tX.expr9 = Eq (X.expr8, S.static3)\n"
                + "\tX.and10 = And (X.and7, X.expr9)\n" + "}\n"
                + "one sig T0 extends Triple {} {\n" + "\tpermit = X.and10\n"
                + "\tdeny = b\n" + "\terror = c\n" + "}\n"
                + "one sig T1 extends Triple {} {\n" + "\tpermit = X.and10\n"
                + "\tdeny = b\n" + "\terror = c\n" + "}\n"
                + "assert Subset {\n"
                + "\t(T0.permit = True) => (T1.permit = True)\n"
                + "\t(T0.deny = True) => (T1.deny = True)\n"
                + "\t(T0.error = True) => (T1.error = True)\n" + "}\n"
                + "check Subset for 2 but 2 Bool, "
                + "2 Triple, 1 Date, 2 Integer, 1 YearMonthDuration, "
                + "3 frob, 7 Type\n", stream.toString());
    }

    public void testHiddenType() {
        reset();
        t = new Triple(
                new FunctionCallPredicate(
                        xp + "date-less-than",
                        new Predicate[] {
                                a,
                                new ConstantValuePredicate(
                                        "http://www.w3.org/2001/XMLSchema#date",
                                        "fred"), }), b, c);
        out.output(t);
        assertEquals(prelude + "sig Date extends Type {}\n" + "one sig E {\n"
                + "}\n" + "one sig S {\n" + "\tstatic0 : one Date // fred\n"
                + "}\n" + "one sig X {\n" + "\texpr0 : one Bool\n" + "}\n"
                + "fact {\n"
                + "\tX.expr0 = if types.lt (a, S.static0) then True "
                + "else False\n" + "}\n" + "one sig T0 extends Triple {} {\n"
                + "\tpermit = X.expr0\n" + "\tdeny = b\n" + "\terror = c\n"
                + "}\n", stream.toString());
    }

    public void testExistential() {
        reset();
        t = new Triple(new ExistentialPredicate(xp + "xpath-node-match", a, b),
                b, c);
        out.output(t);
        assertEquals(prelude + "one sig E {\n" + "}\n" + "one sig S {\n"
                + "}\n" + "one sig X {\n" + "\tenv0 : some String, // " + xp
                + "xpath-node-match\n" + "\texpr1 : one Bool\n" + "}\n"
                + "fact {\n" + "\tX.env0 in b\n"
                + "\tX.expr1 = if (some X.env0) then True else False\n" + "}\n"
                + "one sig T0 extends Triple {} {\n" + "\tpermit = X.expr1\n"
                + "\tdeny = b\n" + "\terror = c\n" + "}\n", stream.toString());
    }
}
