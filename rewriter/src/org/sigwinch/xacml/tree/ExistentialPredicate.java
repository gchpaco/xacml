package org.sigwinch.xacml.tree;

/**
 * ExistentialPredicate.java
 * 
 * 
 * Created: Wed Oct 22 00:31:34 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class ExistentialPredicate extends Predicate {
    String function;

    Predicate attribute, bag;

    public ExistentialPredicate(String function, Predicate a, Predicate b) {
        this.function = function;
        attribute = a;
        bag = b;
    }

    /**
     * Gets the value of attribute
     * 
     * @return the value of attribute
     */
    public Predicate getAttribute() {
        return this.attribute;
    }

    /**
     * Sets the value of attribute
     * 
     * @param argAttribute
     *            Value to assign to this.attribute
     */
    public void setAttribute(Predicate argAttribute) {
        this.attribute = argAttribute;
    }

    /**
     * Gets the value of bag
     * 
     * @return the value of bag
     */
    public Predicate getBag() {
        return this.bag;
    }

    /**
     * Sets the value of bag
     * 
     * @param argBag
     *            Value to assign to this.bag
     */
    public void setBag(Predicate argBag) {
        this.bag = argBag;
    }

    /**
     * Get the Function value.
     * 
     * @return the Function value.
     */
    public String getFunction() {
        return function;
    }

    /**
     * Set the Function value.
     * 
     * @param newFunction
     *            The new Function value.
     */
    public void setFunction(String newFunction) {
        this.function = newFunction;
    }

    @Override
    public void walk(Visitor v) {
        v.walkExistentialPredicate(this);
    }

    @Override
    public Predicate transform(Transformer t) {
        return t.walkExistentialPredicate(this);
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof ExistentialPredicate))
            return false;
        ExistentialPredicate e = (ExistentialPredicate) o;
        return function.equals(e.getFunction())
                && attribute.equals(e.getAttribute()) && bag.equals(e.getBag());
    }

    @Override
    public int hashCode() {
        return bag.hashCode() ^ attribute.hashCode() ^ function.hashCode();
    }
}
/*
 * arch-tag: C4D63DAC-0461-11D8-B357-000A95A2610A
 */
