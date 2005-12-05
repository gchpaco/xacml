package org.sigwinch.xacml.output;

import java.io.PrintWriter;

import org.sigwinch.xacml.tree.VisitorImpl;

/**
 * CodeVisitor.java
 * 
 * 
 * Created: Mon Jan 12 23:01:19 2004
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public abstract class CodeVisitor extends VisitorImpl {
    protected String lastComment;

    protected PrintWriter stream;

    protected CodeVisitor(PrintWriter stream) {
        this.stream = stream;
    }

    public void start() {
        lastComment = null;
        outputStart();
    }

    public void end() {
        if (lastComment != null) {
            if (lastComment.equals("")) {
                stream.println();
            } else {
                stream.print(" // ");
                stream.println(lastComment);
            }
        }
        outputEnd();
    }

    abstract protected void outputStart();

    protected void outputEnd() {
        stream.println("}");
    }

    protected void printConstant(String id, String name, String comment) {
        if (lastComment != null) {
            if (lastComment.equals("")) {
                stream.println(",");
            } else {
                stream.print(", // ");
                stream.println(lastComment);
            }
        }
        lastComment = comment;
        stream.print("\t");
        stream.print(id);
        stream.print(" : one ");
        stream.print(name);
    }

    protected void printSet(String id, String name, String comment) {
        if (lastComment != null) {
            if (lastComment.equals("")) {
                stream.println(",");
            } else {
                stream.print(", // ");
                stream.println(lastComment);
            }
        }
        lastComment = comment;
        stream.print("\t");
        stream.print(id);
        stream.print(" : some ");
        stream.print(name);
    }

    protected void printFunction(String functionName, String from, String to,
            String comment) {
        if (lastComment != null) {
            if (lastComment.equals("")) {
                stream.println(",");
            } else {
                stream.print(", // ");
                stream.println(lastComment);
            }
        }
        lastComment = comment;
        stream.print("\t");
        stream.print(functionName);
        stream.print(" : ");
        stream.print(from);
        stream.print(" -> ");
        stream.print(to);
    }
}
/*
 * arch-tag: 4CF1630C-4596-11D8-B030-000A957284DA
 */
