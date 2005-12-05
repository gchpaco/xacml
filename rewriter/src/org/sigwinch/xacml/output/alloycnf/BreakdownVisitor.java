package org.sigwinch.xacml.output.alloycnf;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.Map;

import org.sigwinch.xacml.output.CodeVisitor;
import org.sigwinch.xacml.tree.*;

public class BreakdownVisitor extends CodeVisitor {
    StringWriter decls, facts;
    PrintWriter d, f;
    HashMap map;
    int count;
    public BreakdownVisitor () {
	super (null);
	decls = new StringWriter ();
	facts = new StringWriter ();
	d = new PrintWriter (decls);
	f = new PrintWriter (facts);
	stream = d;
	map = new HashMap ();
	count = 0;
    }

    protected void outputStart () {}
    protected void outputEnd () {}

    public String getDecls () { return decls.toString (); }
    public String getFacts () { return facts.toString (); }
    public Map getMap () { return map; }

    void maybeWalk (Predicate p) {
	if (! map.containsKey (p))
	    p.walk (this);
    }

    public void walkVariableReference (VariableReference ref) {
	map.put (ref, ref.getName ());
    }

    public void walkSimplePredicate (SimplePredicate simple) {
	String name;
	if (simple == SimplePredicate.TRUE)
	    name = "True";
	else
	    name = "False";
	map.put (simple, name);
    }

    public void walkSolePredicate (SolePredicate solePredicate) {
	maybeWalk (solePredicate.getSet ());
	int mynum = count++;
	printConstant ("sole" + mynum, "Bool", "");
	f.print ("\tX.sole");
	f.print (mynum);
	f.print (" = if (sole ");
	f.print (map.get (solePredicate.getSet ()));
	f.println (") then True else False");
	map.put (solePredicate, "X.sole" + mynum);
    }

    public void walkAndPredicate (AndPredicate andPredicate) {
	maybeWalk (andPredicate.getLeft ());
	maybeWalk (andPredicate.getRight ());
	int mynum = count++;
	printConstant ("and" + mynum, "Bool", "");
	f.print ("\tX.and" + mynum + " = And (");
	f.print (map.get (andPredicate.getLeft ()));
	f.print (", ");
	f.print (map.get (andPredicate.getRight ()));
	f.println (")");
	map.put (andPredicate, "X.and" + mynum);
    }

    public void walkOrPredicate (OrPredicate orPredicate) {
	maybeWalk (orPredicate.getLeft ());
	maybeWalk (orPredicate.getRight ());
	int mynum = count++;
	printConstant ("or" + mynum, "Bool", "");
	f.print ("\tX.or" + mynum + " = Or (");
	f.print (map.get (orPredicate.getLeft ()));
	f.print (", ");
	f.print (map.get (orPredicate.getRight ()));
	f.println (")");
	map.put (orPredicate, "X.or" + mynum);
    }

    public void walkEnvironmentalPredicate (EnvironmentalPredicate env) {
	map.put (env, "E.env" + env.getUniqueId ());
    }

    public void walkConstantValuePredicate (ConstantValuePredicate con) {
	map.put (con, "S.static" + con.getUniqueId ());
    }

    public void walkExistentialPredicate (ExistentialPredicate pred) {
	BreakdownExistentialFV v =
	    new BreakdownExistentialFV (this, pred);
	v.visitFunction (pred.getFunction (),
			 new Predicate [] {
			     new VariableReference ("x"),
			     pred.getAttribute ()
			 }, pred.getIndex ());
	map.put (pred, "X.expr" + v.getExpr ());
    }

    public void walkTriple (Triple triple) {
	maybeWalk (triple.getPermit ());
	maybeWalk (triple.getDeny ());
	maybeWalk (triple.getError ());
    }

    public void walkFunctionCallPredicate (FunctionCallPredicate 
					   functionCallPredicate) {
	BreakdownFunctionVisitor v = 
	    new BreakdownFunctionVisitor (this, functionCallPredicate);
	v.visitFunction (functionCallPredicate);
    }

    class BreakdownExistentialFV extends FunctionVisitorImpl {
	int expr;
	ExistentialPredicate predicate;
	BreakdownExistentialFV (Visitor visitor,
				ExistentialPredicate predicate) {
	    super (visitor);
	    this.expr = -1;
	    this.predicate = predicate;
	}

	public int getExpr () { return expr; }

	void printExpr (int bagnum, int expression) {
	    f.print ("\tX.expr");
	    f.print (expression);
	    f.print (" = if (some X.env");
	    f.print (bagnum);
	    f.println (") then True else False");
	}

	public void visitEquality (Predicate first, Predicate second) {
	    maybeWalk (predicate.getBag ());
	    maybeWalk (predicate.getAttribute ());
	    String type = (String) Predicate.type2string.get (getType ());
	    int bag = count++;
	    printSet ("env" + bag, type, "");
	    expr = count++;
	    printConstant ("expr" + expr, "Bool", "");
	    f.print ("\tall x: X.env");
	    f.print (bag);
	    f.print (" | x in ");
	    f.print (map.get (predicate.getBag ()));
	    f.print (" && Eq (x, ");
	    f.print (map.get (predicate.getAttribute ()));
	    f.println (") = True");
	    printExpr (bag, expr);
	}

	public void visitDefault (String string, Predicate [] arguments) {
	    maybeWalk (predicate.getBag ());
	    int bag = count++;
	    // only allowed weird function
	    assert string.equals (xacmlprefix + "xpath-node-match") : string + " is not xpath-node-match";
	    printSet ("env" + bag, "String", name);
	    expr = count++;
	    printConstant ("expr" + expr, "Bool", "");
	    f.print ("\tX.env");
	    f.print (bag);
	    f.print (" in ");
	    f.println (map.get (predicate.getBag ()));
	    printExpr (bag, expr);
	}
    }

    class BreakdownFunctionVisitor extends FunctionVisitorImpl {
	FunctionCallPredicate func;
	BreakdownFunctionVisitor (Visitor visitor, FunctionCallPredicate f) {
	    super (visitor);
	    func = f;
	}

	public void visitSize (Predicate predicate) {
	    int mynum = count++;
	    printConstant ("expr" + mynum, "Integer", name);
	    map.put (func, "X.expr" + mynum);
	}

	void binaryFunction (String function, Predicate first, Predicate second) {
	    maybeWalk (first);
	    maybeWalk (second);
	    int mynum = count++;
	    printConstant ("expr" + mynum, "Bool", "");
	    f.print ("\tX.expr");
	    f.print (mynum);
	    f.print (" = " + function + " (");
	    f.print (map.get (first));
	    f.print (", ");
	    f.print (map.get (second));
	    f.println (")");
	    map.put (func, "X.expr" + mynum);
	}

	public void visitEquality (Predicate first, Predicate second) {
	    binaryFunction ("Eq", first, second);
	}

	public void visitSetEquality (Predicate first, Predicate second) {
	    binaryFunction ("Eq", first, second);
	}
	
	public void visitInclusion (Predicate first, Predicate second) {
	    binaryFunction ("In", first, second);
	}

	public void visitSubset (Predicate first, Predicate second) {
	    binaryFunction ("In", first, second);
	}

	public void visitAtLeastOne (Predicate first, Predicate second) {
	    binaryFunction ("AtLeastOne", first, second);
	}

	public void visitIntersection (Predicate first, Predicate second) {
	    maybeWalk (first);
	    maybeWalk (second);
	    int mynum = count++;
	    String type = (String) Predicate.type2string.get (getType ());
	    printSet ("expr" + mynum, type, "");
	    f.print ("\tX.expr");
	    f.print (mynum);
	    f.print (" = ");
	    f.print (map.get (first));
	    f.print (" & ");
	    f.println (map.get (second));
	    map.put (func, "X.expr" + mynum);
	}

	public void visitUnion (Predicate first, Predicate second) {
	    maybeWalk (first);
	    maybeWalk (second);
	    int mynum = count++;
	    String type = (String) Predicate.type2string.get (getType ());
	    printSet ("expr" + mynum, type, "");
	    f.print ("\tX.expr");
	    f.print (mynum);
	    f.print (" = ");
	    f.print (map.get (first));
	    f.print (" + ");
	    f.println (map.get (second));
	    map.put (func, "X.expr" + mynum);
	}
	
	public void visitGreaterThan (Predicate first, Predicate second) {
	    maybeWalk (first); maybeWalk (second);
	    int mynum = count++;
	    printConstant ("expr" + mynum, "Bool", "");
	    f.print ("\tX.expr");
	    f.print (mynum);
	    f.print (" = if types.gt (");
	    f.print (map.get (first));
	    f.print (", ");
	    f.print (map.get (second));
	    f.println (") then True else False");
	    map.put (func, "X.expr" + mynum);
	}

	public void visitGreaterThanOrEqual (Predicate first, 
					     Predicate second) {
	    maybeWalk (first); maybeWalk (second);
	    int mynum = count++;
	    printConstant ("expr" + mynum, "Bool", "");
	    f.print ("\tX.expr");
	    f.print (mynum);
	    f.print (" = if types.gte (");
	    f.print (map.get (first));
	    f.print (", ");
	    f.print (map.get (second));
	    f.println (") then True else False");
	    map.put (func, "X.expr" + mynum);
	}

	public void visitLessThan (Predicate first, Predicate second) {
	    maybeWalk (first); maybeWalk (second);
	    int mynum = count++;
	    printConstant ("expr" + mynum, "Bool", "");
	    f.print ("\tX.expr");
	    f.print (mynum);
	    f.print (" = if types.lt (");
	    f.print (map.get (first));
	    f.print (", ");
	    f.print (map.get (second));
	    f.println (") then True else False");
	    map.put (func, "X.expr" + mynum);
	}

	public void visitLessThanOrEqual (Predicate first, Predicate second) {
	    maybeWalk (first); maybeWalk (second);
	    int mynum = count++;
	    printConstant ("expr" + mynum, "Bool", "");
	    f.print ("\tX.expr");
	    f.print (mynum);
	    f.print (" = if types.lte (");
	    f.print (map.get (first));
	    f.print (", ");
	    f.print (map.get (second));
	    f.println (") then True else False");
	    map.put (func, "X.expr" + mynum);
	}

	public void visitAnd (Predicate [] arguments) {
	    assert arguments.length > 0;
	    maybeWalk (arguments[0]);
	    String previous = (String) map.get (arguments[0]);
	    for (int i = 1; i < arguments.length; i++) {
		maybeWalk (arguments[i]);
		int mynum = count++;
		printConstant ("and" + mynum, "Bool", "");
		f.print ("\tX.and" + mynum + " = And (");
		f.print (previous);
		f.print (", ");
		f.print (map.get (arguments[i]));
		f.println (")");
		previous = "X.and" + mynum;
	    }
	    map.put (func, previous);
	}

	public void visitOr (Predicate [] arguments) {
	    assert arguments.length > 0;
	    maybeWalk (arguments[0]);
	    String previous = (String) map.get (arguments[0]);
	    for (int i = 1; i < arguments.length; i++) {
		maybeWalk (arguments[i]);
		int mynum = count++;
		printConstant ("or" + mynum, "Bool", "");
		f.print ("\tX.or" + mynum + " = Or (");
		f.print (previous);
		f.print (", ");
		f.print (map.get (arguments[i]));
		f.println (")");
		previous = "X.or" + mynum;
	    }
	    map.put (func, previous);
	}

	public void visitNot (Predicate predicate) {
	    maybeWalk (predicate);
	    int mynum = count++;
	    printConstant ("not" + mynum, "Bool", "");
	    f.print ("\tX.not" + mynum + " = BoolNot (");
	    f.print (map.get (predicate));
	    f.println (")");
	    map.put (func, "X.not" + mynum);
	}

	public void visitDefault (String string, Predicate [] arguments) {
	    int mynum = count++;
	    printConstant ("expr" + mynum, "Bool", string);
	    map.put (func, "X.expr" + mynum);
	}
    }
}
