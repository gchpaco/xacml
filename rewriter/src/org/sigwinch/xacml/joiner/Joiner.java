package org.sigwinch.xacml.joiner;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;
import org.jdom.IllegalDataException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.Text;
import org.xml.sax.SAXException;

/**
 * Looks for PolicySetIdReference and PolicyIdReference elements in XACML specifications and snaps the links.
 * 
 * @author graham
 *
 */
public class Joiner {

    public static final String XACML_NS = "urn:oasis:names:tc:xacml:1.0:policy";

    /**
     * @param args
     */
    public static void main(String[] args) {
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setNamespaceAware(true);
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document root = null;
            Document documents[] = new Document[args.length];
            for (int i = 0; i < args.length; i++) {
                try {
                    File file = new File(args[i]);
                    documents[i] = builder.parse(file);
                    if (root == null) root = documents[i];
                } catch (SAXException e) {
                    System.err.println("Couldn't read " + args[i] + ": " + e);
                } catch (IOException e) {
                    System.err.println("Couldn't read " + args[i] + ": " + e);
                }
            }
            HashMap<String, Element> idmap = new HashMap<String, Element>();
            for (int i = 0; i < documents.length; i++) {
                if (documents[i] == null) // something that didn't load
                    continue;
                // Looking for PolicySet and Policys
                NodeList list = documents[i].getElementsByTagNameNS(XACML_NS, "PolicySet");
                for (int j = 0; j < list.getLength(); j++) {
                    Node node = list.item(j);
                    assert node.getNodeType() == Node.ELEMENT_NODE;
                    Element element = (Element) node;
                    String name = element.getAttribute("PolicySetId");
                    idmap.put(name, element);
                }
                list = documents[i].getElementsByTagNameNS(XACML_NS, "Policy");
                for (int j = 0; j < list.getLength(); j++) {
                    Node node = list.item(j);
                    assert node.getNodeType() == Node.ELEMENT_NODE;
                    Element element = (Element) node;
                    String name = element.getAttribute("PolicyId");
                    idmap.put(name, element);
                }
            }
            while (true) {
                boolean empty = true;
                NodeList list = root.getElementsByTagNameNS(XACML_NS, "PolicySetIdReference");
                if (list.getLength() > 0) empty = false;
                replaceElements(root, idmap, list);
                list = root.getElementsByTagNameNS(XACML_NS, "PolicyIdReference");
                if (list.getLength() > 0) empty = false;
                replaceElements(root, idmap, list);
                if (empty) break;
            }
            // figure out how to write that out as XML
            OutputFormat format = new OutputFormat(root);
            format.setIndenting(true);
            format.setIndent(2);
            XMLSerializer output = new XMLSerializer(System.out, format);
            output.serialize(root);
        } catch (javax.xml.parsers.ParserConfigurationException e) {
            System.err.println("Couldn't find a parser: got this instead");
            System.err.println(e.toString());
            System.exit(1);
        } catch (IOException e) {
            System.err.println("Couldn't write output: " + e);
            System.exit(1);
        }
    }

    private static void replaceElements(Document root, HashMap<String, Element> idmap, NodeList list) {
        for (int i = 0; i < list.getLength(); i++) {
            Element element = (Element) list.item(i);
            NodeList nodes = element.getChildNodes();
            StringBuilder ref = new StringBuilder();
            for (int j = 0; j < nodes.getLength(); j++) {
                Node node = nodes.item(j);
                if (node.getNodeType() != Node.TEXT_NODE)
                    throw new Error ("Not expecting children of an id reference! " + node);
                Text text = (Text) node;
                ref.append(text.getData());
            }
            String reference = ref.toString();
            if (!idmap.containsKey(reference)) {
                System.err.println("Couldn't find a source for " + reference + ": aborting");
                System.exit(1);
            }
            Node replacement = root.importNode(idmap.get(reference), true);
            Node parentNode = element.getParentNode();
            assert parentNode != null;
            parentNode.replaceChild(replacement, element);
        }
    }

}
