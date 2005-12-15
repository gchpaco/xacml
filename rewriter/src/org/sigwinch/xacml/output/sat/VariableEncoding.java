/*
 * Created on May 22, 2005
 */
package org.sigwinch.xacml.output.sat;

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.sigwinch.xacml.tree.VariableReference;

/**
 * @author graham
 */
public abstract class VariableEncoding {
    public static class Value {
        private final VariableEncoding type;
        private final Object value;

        public Value(VariableEncoding type, Object value) {
            this.type = type;
            this.value = value;
        }

        public VariableEncoding getType() {
            return type;
        }

        public Object getValue() {
            return value;
        }

        public String getBase() {
            return getType ().getBase();
        }
        
        @Override
        public int hashCode() {
            return new HashCodeBuilder(3, 5).append(type).append(value).toHashCode();
        }

        @Override
        public boolean equals(Object obj) {
            if (obj instanceof Value == false) {
                return false;
            }
            if (this == obj) {
                return true;
            }
            Value rhs = (Value) obj;
            return new EqualsBuilder().append(type, rhs.type).append(value, rhs.value).isEquals();
        }
    }

    public static class VariablePair {
        public VariablePair(String string, int v) {
            name = string;
            value = v;
        }
        public final String name;
        public final int value;
    }

    VariableReference[] names;

    int multiplicity;

    int length;

    String baseName;

    /**
     * @param namesFor
     * @param multiplicity
     * @param baseName
     */
    protected VariableEncoding(VariableReference[] namesFor, int multiplicity,
            String baseName) {
        names = namesFor;
        this.baseName = baseName;
        this.multiplicity = multiplicity;
        length = BooleanCombinations.binaryLog(multiplicity);
    }

    protected VariableEncoding(String baseName, int multiplicity) {
        length = BooleanCombinations.binaryLog(multiplicity);
        this.multiplicity = multiplicity;
        this.baseName = baseName;
        names = buildNamesFor(baseName, length);
    }

    static protected VariableReference[] buildNamesFor(String baseName, int len) {
        VariableReference[] n = new VariableReference[len];
        for (int i = 0; i < n.length; i++) {
            n[i] = new VariableReference(baseName + "_" + i);
        }
        return n;
    }
    
    protected static String baseNameOf (String name) {
        if (!name.matches(".*_[0-9]+$"))
            return null;
        return name.replaceAll("_[0-9]+$", "");
    }

    /**
     * @return return the number of values this variable can take
     */
    public int getSize() {
        return multiplicity;
    }

    public VariableReference[] getNames() {
        return names;
    }

    /**
     * @return base string for this encoding
     */
    public String getBase() {
        // not actually good here
        return baseName;
    }

    public abstract BooleanFormula address(int i);

    static VariablePair decodeArrays(String[] names, boolean[] values) {
        if (names.length != values.length) return null;
        if (names.length == 0) return null;
        String basename = baseNameOf (names[0]);
        if (basename == null) return null;
        for (String name : names) {
            String base = baseNameOf (name);
            if (base == null || !base.equals(basename))
                return null;
        }
        int value = 0;
        for (int i = 0; i < values.length; i++) {
            if (values[i])
                value += 1 << i;
        }
        return new VariablePair (basename, value);
    }
    
    static final Map<String, Constructor> constructorCache = new HashMap<String, Constructor> ();

    public static Value decode(String[] strings, boolean[] bs) {
        Constructor constructor;
        String baseName;
        VariablePair pair = decodeArrays (strings, bs);
        if (pair == null) {
            assert strings.length == 1;
            assert bs.length == 1;
            constructor = BooleanVariableEncoding.getConstructor ();
            baseName = strings[0];  
        } else {
            baseName = pair.name;
            if (constructorCache.containsKey(pair.name)) {
                constructor = constructorCache.get(pair.name);
            } else {
                constructor = ScalarVariableEncoding.getConstructor();
            }
        }
        return new Value (constructor.constructType(baseName, bs.length), constructor.constructValue(bs));
    }

    public static void logAs(String string, Constructor constructor) {
        if (constructorCache.containsKey(string))
            throw new IllegalArgumentException ("Already used " + string);
        constructorCache.put (string, constructor);
    }
}

// arch-tag: VariableEncoding.java May 22, 2005 2:07:57 AM
