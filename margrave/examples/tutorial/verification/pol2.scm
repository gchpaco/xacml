(include "setup.scm")

;; First we must load the XACML policy.
(define prePol_2 (load-xacml-policy "../xacml-code/xacmlA/RPSlist.xml"))
;; Next we can constrain it.
(define Pol_2 (make-singleton-named-attribute 'Action 'command
                                              (make-singleton-named-attribute 'Resource 'resource-class
                                                                              prePol_2)))
;; Now contrain the the loaded policy.
;; Why not just put (load-xacml-policy "../xacml-code/xacmlA/RPSlist.xml")
;; in the place of prePol_2 (prePol_2 is not used anywhere else after all)?
;; The reason is that all the policies must be loaded before
;; any constraints can be applied.  To ensure that it is loaded
;; before any of the constraint expressions that are applied to it
;; are executed, one must load the policy outside of the constraint's
;; arguments.

;; Now we run the test suit.
(test-suit1 Pol_2)
