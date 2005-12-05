package org.sigwinch.xacml.transformers;

import org.sigwinch.xacml.tree.DenyOverridesRule;
import org.sigwinch.xacml.tree.FirstApplicableRule;
import org.sigwinch.xacml.tree.OnlyOneRule;
import org.sigwinch.xacml.tree.PermitOverridesRule;
import org.sigwinch.xacml.tree.Predicate;
import org.sigwinch.xacml.tree.TransformerImpl;
import org.sigwinch.xacml.tree.Tree;
import org.sigwinch.xacml.tree.Triple;

/**
 * TriplePropagator.java
 * 
 * 
 * Created: Sun Nov 9 03:44:32 2003
 * 
 * @author <a href="mailto:graham@sigwinch.org">Graham Hughes</a>
 * @version 1.0
 */
public class TriplePropagator extends TransformerImpl {
    public TriplePropagator() {

    }

    /**
     * Perform triple propagation through <code>p</code>.
     * 
     * @param p
     *            a <code>PermitOverridesRule</code> node
     * @return new triple
     */
    @Override
    public Tree walkPermitOverridesRule(PermitOverridesRule p) {
        PermitOverridesRule rule = (PermitOverridesRule) super
                .walkPermitOverridesRule(p);
        assert rule.getLeft() instanceof Triple
                && rule.getRight() instanceof Triple;
        Triple left = (Triple) rule.getLeft();
        Triple right = (Triple) rule.getRight();
        Predicate s1 = left.getPermit();
        Predicate s2 = right.getPermit();
        Predicate r1 = left.getDeny();
        Predicate r2 = right.getDeny();
        Predicate t1 = left.getError();
        Predicate t2 = right.getError();
        return new Triple(s1.orWith(s2).andWith(t1.orWith(t2).not()), (r1
                .andWith(s2.orWith(t2).not())).orWith(r2.andWith(s1.orWith(t1)
                .not())), t1.orWith(t2));
    }

    /**
     * Perform triple propagation through <code>d</code>.
     * 
     * @param d
     *            a <code>DenyOverridesRule</code> node
     * @return new triple
     */
    @Override
    public Tree walkDenyOverridesRule(DenyOverridesRule d) {
        DenyOverridesRule rule = (DenyOverridesRule) super
                .walkDenyOverridesRule(d);
        assert rule.getLeft() instanceof Triple
                && rule.getRight() instanceof Triple;
        Triple left = (Triple) rule.getLeft();
        Triple right = (Triple) rule.getRight();
        Predicate s1 = left.getPermit();
        Predicate s2 = right.getPermit();
        Predicate r1 = left.getDeny();
        Predicate r2 = right.getDeny();
        Predicate t1 = left.getError();
        Predicate t2 = right.getError();
        return new Triple((s1.andWith(r2.orWith(t2).not())).orWith(s2
                .andWith(r1.orWith(t1).not())), r1.orWith(r2).andWith(
                t1.orWith(t2).not()), t1.orWith(t2));
    }

    /**
     * Perform triple propagation through <code>o</code>.
     * 
     * @param o
     *            an <code>OnlyOneRule</code> node
     * @return new triple
     */
    @Override
    public Tree walkOnlyOneRule(OnlyOneRule o) {
        OnlyOneRule rule = (OnlyOneRule) super.walkOnlyOneRule(o);
        assert rule.getLeft() instanceof Triple
                && rule.getRight() instanceof Triple;
        Triple left = (Triple) rule.getLeft();
        Triple right = (Triple) rule.getRight();
        Predicate s1 = left.getPermit();
        Predicate s2 = right.getPermit();
        Predicate r1 = left.getDeny();
        Predicate r2 = right.getDeny();
        Predicate t1 = left.getError();
        Predicate t2 = right.getError();
        return new Triple(s1.orWith(s2).andWith(
                s1.andWith(s2).orWith(t1).orWith(t2).not()), r1.orWith(r2)
                .andWith(r1.andWith(r2).orWith(t1).orWith(t2).not()), t1
                .orWith(t2).orWith(s1.andWith(s2)).orWith(r1.andWith(r2)));
    }

    /**
     * Perform triple propagation through <code>f</code>.
     * 
     * @param f
     *            a <code>FirstApplicableRule</code> node
     * @return new triple
     */
    @Override
    public Tree walkFirstApplicableRule(FirstApplicableRule f) {
        FirstApplicableRule rule = (FirstApplicableRule) super
                .walkFirstApplicableRule(f);
        assert rule.getLeft() instanceof Triple
                && rule.getRight() instanceof Triple;
        Triple left = (Triple) rule.getLeft();
        Triple right = (Triple) rule.getRight();
        Predicate s1 = left.getPermit();
        Predicate s2 = right.getPermit();
        Predicate r1 = left.getDeny();
        Predicate r2 = right.getDeny();
        Predicate t1 = left.getError();
        Predicate t2 = right.getError();
        return new Triple(s1.orWith(s2.andWith(r1.orWith(t1).not())), r1
                .orWith(r2.andWith(s1.orWith(t1).not())), t1.orWith(t2
                .andWith(s1.orWith(r1).not())));
    }

}
/*
 * arch-tag: 194C9C13-12AA-11D8-8529-000A95A2610A
 */
