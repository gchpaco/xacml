;; include the definations of the properties so that we do not need to retype them.
(include "setup.scm")

;; Load the XACML policy into Margrave.  Below is the path to the base (top-most) policy of the XACML policy.
(test-suit1 (load-xacml-policy "../xacml-code/xacmlA/RPSlist.xml"))

;; At this point we tested the policy and saw that we need to apply some constraints.
;; Normally one would just edit the above statement and rerun the code to do this, 
;; but for this tutorial we must be in it a new file.  Go on to pol2.scm to see it.