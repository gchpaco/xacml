package org.sigwinch.xacml;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.sigwinch.xacml.output.Output;
import org.sigwinch.xacml.output.alloycnf.AlloyCNFOutput;
import org.sigwinch.xacml.output.sat.AlloySatOutput;
import org.sigwinch.xacml.output.set.AlloySetOutput;
import org.sigwinch.xacml.parser.AbstractParser;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import org.sigwinch.xacml.tree.Tree;
import org.sigwinch.xacml.transformers.*;
import org.sigwinch.xacml.tree.PermitOverridesRule;
import org.apache.commons.cli.*;

/**
 * Rewriter.java
 * 
 * 
 * Created: Tue Oct 21 18:14:33 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class Rewriter {
    static Options options;

    static {
        options = new Options();
        options.addOption("s", "size", true,
                "The expected number of elements per set "
                        + "in the environment (default 2)");
        options.addOption("h", "help", false, "This help screen");
        options.addOption("S", "style", true,
                "Which style of output to use (predicate, set, sat)");
        options
                .addOption("t", "type", true,
                        "Which properties to test subsumption for (combination of p, d, e)");
        options
                .addOption(
                        "r",
                        "roundtrip",
                        false,
                        "Whether to automatically run the analyzer and report results (only works for sat now)");
    }

    DocumentBuilder builder;

    public Rewriter() {
        try {
            builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        } catch (javax.xml.parsers.ParserConfigurationException e) {
            System.err.println("Couldn't find a parser: got this instead");
            System.err.println(e.toString());
            e.printStackTrace();
            System.exit(1);
        }
    }

    /**
     * Return a valid tree from the contents of <code>filename</code>.
     * 
     * @param filename
     *            File containing XACML to be parsed
     * @return Tree corresponding to the given specification
     */
    Tree parseFile(String filename) {
        try {
            Document tree = builder.parse(filename);
            Element root = tree.getDocumentElement();
            return AbstractParser.parse(root);
        } catch (org.xml.sax.SAXException e) {
            System.err.println("Error parsing " + filename + ": " + e);
            return null;
        } catch (java.io.IOException e) {
            System.err.println("Error parsing " + filename + ": " + e);
            return null;
        }
    }

    static Tree readFile(String file) {
        return new Rewriter().parseFile(file);
    }

    private static Tree transformTree(Tree t) {
        if (t == null)
            return t;
        t = t.transform(new DuplicateRemover());
        t = t.transform(new Propagator());
        t = t.transform(new DuplicateRemover());
        t = t.transform(new TripleFormer());
        t = t.transform(new TriplePropagator());
        return t;
    }

    static void usage() {
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp("java org.sigwinch.xacml.Rewriter <file> "
                + "[<potential derivation>]", options);
    }

    public static void main(String[] argv) throws IOException {
        CommandLineParser parser = new GnuParser();

        CommandLine line = null;
        try {
            line = parser.parse(options, argv);
        } catch (ParseException e) {
            System.out.println("Unexpected exception: " + e);
            System.exit(2);
        }

        if (line.hasOption("h") || line.getArgs().length == 0) {
            usage();
            System.exit(0);
        }

        OutputConfiguration configuration = new OutputConfiguration();
        try {
            if (line.hasOption("s"))
                configuration.setSlop(Double.parseDouble(line
                        .getOptionValue("s")));
        } catch (NumberFormatException e) {
            usage();
            System.exit(1);
        }

        File tempFile = null;
        Output output;
        String outputType;
        boolean roundTrip = false;
        if (line.hasOption("r"))
            roundTrip = true;
        if (line.hasOption("S"))
            outputType = line.getOptionValue("S");
        else
            outputType = "sat";
        if (roundTrip && !outputType.equals("sat")) {
            usage();
            System.exit(1);
        }
        if (line.hasOption("t")) {
            String flags = line.getOptionValue("t");
            if (flags.contains("p"))
                configuration.setPermit(true);
            if (flags.contains("d"))
                configuration.setDeny(true);
            if (flags.contains("e"))
                configuration.setError(true);
        } else {
            configuration.setPermit(true);
            configuration.setDeny(true);
            configuration.setError(true);
        }
        PrintWriter writer;
        if (roundTrip) {
            tempFile = File.createTempFile("xacml", ".cnf");
            tempFile.deleteOnExit();
            writer = new PrintWriter(tempFile);
        } else
            writer = new PrintWriter(System.out);
        if (outputType.equals("predicate")) {
            output = new AlloyCNFOutput(writer, configuration);
        } else if (outputType.equals("set")) {
            output = new AlloySetOutput(writer, configuration);
        } else {
            output = new AlloySatOutput(writer, configuration);
        }
        String[] args = line.getArgs();

        long start = System.currentTimeMillis();
        Tree trees[] = new Tree[args.length];
        for (int i = 0; i < args.length; i++)
            trees[i] = readFile(args[i]);
        long end = System.currentTimeMillis();
        System.err.println("IO in " + (end - start) + " ms");

        start = System.currentTimeMillis();
        for (int i = 0; i < args.length; i++)
            trees[i] = transformTree(trees[i]);
        end = System.currentTimeMillis();
        System.err.println("Tree transformations in " + (end - start) + " ms");

        start = System.currentTimeMillis();
        // This is junk just to combine the trees for unified processing
        Tree unified;
        if (args.length == 1)
            unified = trees[0];
        else
            unified = new PermitOverridesRule(trees[0], trees[1]);

        output.preamble(unified);
        for (int i = 0; i < args.length; i++)
            output.write(trees[i]);
        output.postamble();
        writer.flush();
        end = System.currentTimeMillis();
        System.err.println("Output in " + (end - start) + " ms");
        if (roundTrip)
            output.roundTripOn(tempFile);
    }
}
/*
 * arch-tag: 1F1F1230-042D-11D8-93F8-000A95A2610A
 */
