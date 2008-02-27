(include "setup.scm")

;; Since we added a new property to check,
;; we need a new test-suit.
;; policy * [bool] -> bool
(define (test-suit2 policy)
    (let [ [test1-result (test-suit1 policy)] ]
      
      (printf "> Pr_4: ")
      (let [ [result4 (Pr_4 policy)] ]
            (if result4
                (printf "Passed Pr_4~n")
                (begin
                  (printf "FAILED Pr_4~n Counter-example:~n")
                  (print-avc (find-Pr_4-counter-example policy))))
        (and test1-result result4))))

(define prePol_6 (load-xacml-policy "../xacml-code/xacmlD/RPSlist.xml"))

(define Pol_6
  (constrain-policy-disjoint 
   (list (make-avc 'Subject 'role 'Faculty)
         (make-avc 'Subject 'role 'Student))
   (make-singleton-named-attribute 'Action 'command
                                   (make-singleton-named-attribute 'Resource 'resource-class
                                                                   prePol_6))))

(test-suit2 Pol_6)

;; Below we include the defination and testing a new policy that is
;; Pol_6 with addition constrains.  We can define more than one
;; policy during a single run of Margrave so long as all the xacml files
;; are loaded at once.  Here we do not need to load any more xacml files,
;; so all is fine.
(printf "------------------ Pol_7 ------------------------~n~n")

(define Pol_7 (constrain-policy-disjoint (list  (make-avc 'Subject 'role 'Faculty)  
                                                (make-avc 'Subject 'role 'FacultyFamily))
                                         Pol_6))

(test-suit2 Pol_7)
