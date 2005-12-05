package org.sigwinch.xacml.tree;

import org.sigwinch.xacml.tree.Predicate;
import java.util.HashMap;

/**
 * EnvironmentalPredicate.java Created: Tue Nov 4 13:52:37 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes </a>
 * @version 1.0
 */
public class EnvironmentalPredicate extends Predicate {
    static final HashMap<String, Integer> id2num;
    static int current;
    final int uniqueId;
    String type, id;
    boolean force;

    public EnvironmentalPredicate (String t, String i) {
        type = t;
        id = i;
        this.force = false;
        if (!id2num.containsKey (i))
            id2num.put (i, new Integer (current++));
        uniqueId = id2num.get (i).intValue ();
    }

    public EnvironmentalPredicate (String t, String i, boolean force) {
        type = t;
        id = i;
        this.force = force;
        if (!id2num.containsKey (i))
            id2num.put (i, new Integer (current++));
        uniqueId = id2num.get (i).intValue ();
    }

    static {
        id2num = new HashMap<String, Integer> ();
        reset ();
    }

    public static void reset () {
        id2num.clear ();
        current = 0;
    }

    /**
     * Gets the value of type
     * 
     * @return the value of type
     */
    public String getType () {
        return this.type;
    }

    /**
     * Sets the value of type
     * 
     * @param argType
     *            Value to assign to this.type
     */
    public void setType (String argType) {
        this.type = argType;
    }

    /**
     * Gets the value of id
     * 
     * @return the value of id
     */
    public String getId () {
        return this.id;
    }

    /**
     * Sets the value of id
     * 
     * @param argId
     *            Value to assign to this.id
     */
    public void setId (String argId) {
        this.id = argId;
    }

    public int getUniqueId () {
        return uniqueId;
    }

    public String getShortName () {
        String shortName = type2string.get (type);
        if (shortName == null)
            return type;
        return shortName;
    }

    @Override
    public boolean isFunction () {
        return true;
    }

    @Override
    public void walk (Visitor v) {
        v.walkEnvironmentalPredicate (this);
    }

    @Override
    public Predicate transform (Transformer t) {
        return t.walkEnvironmentalPredicate (this);
    }

    @Override
    public boolean equals (Object o) {
        if (!(o instanceof EnvironmentalPredicate))
            return false;
        EnvironmentalPredicate e = (EnvironmentalPredicate) o;
        return type.equals (e.getType ()) && id.equals (e.getId ());
    }

    @Override
    public int hashCode () {
        return type.hashCode () ^ id.hashCode ();
    }
}
/*
 * arch-tag: 37923A4A-0F11-11D8-AB4C-000A95A2610A
 */
