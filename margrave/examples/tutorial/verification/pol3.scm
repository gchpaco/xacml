(include "setup.scm")
(define prePol_3 (load-xacml-policy "../xacml-code/xacmlA/RPSlist.xml"))
(test-suit1
 (constrain-policy-disjoint (list (make-avc 'Subject 'role 'Faculty)
                                  (make-avc 'Subject 'role 'Student))
                            (make-singleton-named-attribute 'Action 'command
                                                            (make-singleton-named-attribute 'Resource 'resource-class
                                                                                            prePol_3))))