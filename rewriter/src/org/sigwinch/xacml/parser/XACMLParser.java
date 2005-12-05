package org.sigwinch.xacml.parser;

import java.util.HashMap;

import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/**
 * XACMLParser.java
 * 
 * 
 * Created: Wed Oct 22 13:07:16 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
abstract public class XACMLParser {
    static HashMap<String, String> type2bagsize;

    static final String xacmlns = "urn:oasis:names:tc:xacml:1.0:policy";

    static final String stringType = "http://www.w3.org/2001/XMLSchema#string";

    static final String booleanType = "http://www.w3.org/2001/XMLSchema#boolean";

    static final String integerType = "http://www.w3.org/2001/XMLSchema#integer";

    static final String doubleType = "http://www.w3.org/2001/XMLSchema#double";

    static final String timeType = "http://www.w3.org/2001/XMLSchema#time";

    static final String dateType = "http://www.w3.org/2001/XMLSchema#date";

    static final String dateTimeType = "http://www.w3.org/2001/XMLSchema#dateTime";

    static final String anyURIType = "http://www.w3.org/2001/XMLSchema#anyURIType";

    static final String hexBinaryType = "http://www.w3.org/2001/XMLSchema#hexBinary";

    static final String base64BinaryType = "http://www.w3.org/2001/XMLSchema#base64Binary";

    static final String dayTimeDurationType = "http://www.w3.org/TR/2002/WD-xquery-operators-20020816#dayTimeDuration";

    static final String yearMonthDurationType = "http://www.w3.org/TR/2002/WD-xquery-operators-20020816#yearMonthDuration";

    static final String x500NameType = "urn:oasis:names:tc:xacml:1.0:data-type:x500Name";

    static final String rfc822NameType = "urn:oasis:names:tc:xacml:1.0:data-type:rfc822Name";

    static {
        type2bagsize = new HashMap<String, String>();
        type2bagsize.put(stringType,
                "urn:oasis:names:tc:xacml:1.0:function:string-bag-size");
        type2bagsize.put(booleanType,
                "urn:oasis:names:tc:xacml:1.0:function:boolean-bag-size");
        type2bagsize.put(integerType,
                "urn:oasis:names:tc:xacml:1.0:function:integer-bag-size");
        type2bagsize.put(doubleType,
                "urn:oasis:names:tc:xacml:1.0:function:double-bag-size");
        type2bagsize.put(timeType,
                "urn:oasis:names:tc:xacml:1.0:function:time-bag-size");
        type2bagsize.put(dateType,
                "urn:oasis:names:tc:xacml:1.0:function:date-bag-size");
        type2bagsize.put(dateTimeType,
                "urn:oasis:names:tc:xacml:1.0:function:dateTime-bag-size");
        type2bagsize.put(anyURIType,
                "urn:oasis:names:tc:xacml:1.0:function:anyURI-bag-size");
        type2bagsize.put(hexBinaryType,
                "urn:oasis:names:tc:xacml:1.0:function:hexBinary-bag-size");
        type2bagsize.put(base64BinaryType,
                "urn:oasis:names:tc:xacml:1.0:function:base64Binary-bag-size");
        type2bagsize
                .put(dayTimeDurationType,
                        "urn:oasis:names:tc:xacml:1.0:function:dayTimeDuration-bag-size");
        type2bagsize
                .put(yearMonthDurationType,
                        "urn:oasis:names:tc:xacml:1.0:function:yearMonthDuration-bag-size");
        type2bagsize.put(x500NameType,
                "urn:oasis:names:tc:xacml:1.0:function:x500Name-bag-size");
        type2bagsize.put(rfc822NameType,
                "urn:oasis:names:tc:xacml:1.0:function:rfc822Name-bag-size");
    }

    protected String getXACMLAttribute(Element e, String name) {
        String result = e.getAttributeNS(xacmlns, name);
        if (result == null || result.length() == 0)
            result = e.getAttribute(name);
        return result;
    }

    protected NodeList getList(Element element, String name) {
        NodeList target = element.getElementsByTagNameNS(xacmlns, name);
        if (target == null || target.getLength() == 0)
            target = element.getElementsByTagName(name);
        return target;
    }
}
/*
 * arch-tag: 565223F6-04CB-11D8-813B-000A95A2610A
 */
