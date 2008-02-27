(include "setup.scm")

;; Note that build path is another way to locate XACML policy files.
(define prePol_5 (load-xacml-policy (build-path 'up "xacml-code" "xacmlC" "RPSlist.xml")))

(test-suit1 
 (constrain-policy-disjoint 
  (list (make-avc 'Subject 'role 'Faculty)
        (make-avc 'Subject 'role 'Student))
  (make-singleton-attribute 'Action 'command
                            (make-singleton-attribute 'Resource 'resource-class
                                                      prePol_5))))
