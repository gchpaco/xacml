
;; To include Margrave's functions in this namespace.
;; You might have to change the file path depending on where you have margrave installed.
(require "../../../analysis/margrave.scm")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Properties
;;
;;  One need not define them before loading the policies, but it
;; is helpful since this one they are all in one centeral place.
;; Note that these use some of Margrave functions that you were
;; warned not to use before loading the xacml policy (or all the policies
;; if more than one is to be used, which is not the case in this part of the tutorial).
;; We can do this since the body of the defination at not excuted (including these
;; functions) until after all the policy are loaded.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Pr_1
;; Policy -> bool
;; "There do not exist members of Student who can Assign ExternalGrades."
;; This is implimented by ensuring the no request falls into both the set of 
;; requests that include the role Student, resource-class ExternalGrades,
;; and command Assign and the set of requests that are permited.
(define (Pr_1 policy)
  (avc-false? (avc-and (restrict-policy-to-dec 'P policy)
                       (avc-and (make-avc 'Subject 'role 'Student) 
                                (make-avc 'Resource 'resource-class 'ExternalGrades)
                                (make-avc 'Action 'command 'Assign)))))

;; Policy -> avc
;; This produces all the counter-examples
;; to Pr_1.  
;; If none exist (the property holds),
;; the empty avc is returned.
(define (find-Pr_1-counter-example policy)
  (avc-and (restrict-policy-to-dec 'P policy)
           (avc-and (make-avc 'Subject 'role 'Student) 
                    (make-avc 'Resource 'resource-class 'ExternalGrades)
                    (make-avc 'Action 'command 'Assign))))

;; Pr_2
;; Policy -> bool
;; "All members of Faculty can Assign both InternalGrades and ExternalGrades."
;; This is implimented by checking to ensure that all requests that include the 
;; role Faculty, either the resouce-class InternalGrades or ExternalGrades and
;; the command Assign are within the set of permited requests
;; or is a request that does not matter (mapped to 'E).
(define (Pr_2 policy)
  (avc-implication? (avc-and (make-avc 'Subject 'role 'Faculty)
                             (avc-or (make-avc 'Resource 'resource-class 'InternalGrades)
                                     (make-avc 'Resource 'resource-class 'ExternalGrades))
                             (make-avc 'Action 'command 'Assign))
                    (avc-or (restrict-policy-to-dec 'P policy)
                            (restrict-policy-to-dec 'E policy))))

;; Policy -> avc
;; This produces all the counter-examples
;; to Pr_2.  
;; If none exist (the property holds),
;; the empty avc is returned.
(define (find-Pr_2-counter-example policy)
  (avc-difference (avc-and (make-avc 'Subject 'role 'Faculty)
                           (avc-or (make-avc 'Resource 'resource-class 'InternalGrades)
                                   (make-avc 'Resource 'resource-class 'ExternalGrades))
                           (make-avc 'Action 'command 'Assign))
                  (avc-or (restrict-policy-to-dec 'P policy)
                          (restrict-policy-to-dec 'E policy))))


;; Pr_3
;; Policy -> bool
;; "There exists no combination of roles such that a user with those roles can both
;;  Receive and Assign the resource ExternalGrades."
;; This is implimented by first getting the set of requests that can 
;; Assign ExternalGrades (assign) and the set of requests that can Receive 
;; ExternalGrades (receive).  Then we check that the intersection between the 
;; set of role combinations found in each set of requests is empty.
(define (Pr_3 policy)
  (let [ [assign (avc-and (restrict-policy-to-dec 'P policy)
                          (avc-and (make-avc 'Resource 'resource-class 'ExternalGrades) 
                                   (make-avc 'Action 'command 'Assign)))]
         [receive (avc-and (restrict-policy-to-dec 'P policy)
                           (avc-and (make-avc 'Resource 'resource-class 'ExternalGrades) 
                                    (make-avc 'Action 'command 'Receive)))] ]
    (avc-false? (avc-and (present-combo-attrValues 'Subject 'role assign)
                         (present-combo-attrValues 'Subject 'role receive)))))
;; Policy -> avc
;; This produces all the counter-examples
;; to Pr_3.  
;; If none exist (the property holds),
;; the empty avc is returned.
(define (find-Pr_3-counter-example policy)
  (let [ [assign (avc-and (restrict-policy-to-dec 'P policy)
                          (avc-and (make-avc 'Resource 'resource-class 'ExternalGrades) 
                                   (make-avc 'Action 'command 'Assign)))]
         [receive (avc-and (restrict-policy-to-dec 'P policy)
                           (avc-and (make-avc 'Resource 'resource-class 'ExternalGrades) 
                                    (make-avc 'Action 'command 'Receive)))] ]
    (avc-and (present-combo-attrValues 'Subject 'role assign)
             (present-combo-attrValues 'Subject 'role receive))))

;; Pr_4
;; Policy -> bool
;; "All members of FacultyFamily can Receive ExternalGrades."
;; This is implimented by checking to ensure that all requests that include the 
;; role FacultyFamily, the resource-class ExternalGrades and the command Assign 
;; are within the set of permited requests.
(define (Pr_4 policy)
  (avc-implication? (avc-and (make-avc 'Subject 'role 'FacultyFamily) 
                             (make-avc 'Resource 'resource-class 'ExternalGrades) 
                             (make-avc 'Action 'command 'Receive)) 
                    (avc-or (restrict-policy-to-dec 'P policy)
                            (restrict-policy-to-dec 'E policy))))
;; Policy -> avc
;; This produces all the counter-examples
;; to Pr_4.  
;; If none exist (the property holds),
;; the empty avc is returned.
(define (find-Pr_4-counter-example policy)
  (avc-difference (avc-and (make-avc 'Subject 'role 'FacultyFamily) 
                           (make-avc 'Resource 'resource-class 'ExternalGrades) 
                           (make-avc 'Action 'command 'Receive))
                  (avc-or (restrict-policy-to-dec 'P policy)
                          (restrict-policy-to-dec 'E policy))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Test Suit
;;  This just makes it easier to test all of the properties at once.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; policy * [bool] -> bool
;; Returns true if all the properties pass.
;; Else returns false.  
;; Prints out a counter-example for failed ones.
(define (test-suit1 policy)

  (printf "> Pr_1: ")
    (let [ [result1 (Pr_1 policy)] ]     
          (if result1
              (printf "Passed Pr_1~n")
              (begin
                (printf "FAILED Pr_1~n Counter-example:~n")
                (print-avc (find-Pr_1-counter-example policy))))
      
      
      (printf "> Pr_2: ")
      (let [ [result2 (Pr_2 policy)] ]
            (if result2
                (printf "Passed Pr_2~n")
                (begin
                  (printf "FAILED Pr_2~n Counter-example:~n")
                  (print-avc (find-Pr_2-counter-example policy))))
        
        (printf "> Pr_3: ")
        (let [ [result3 (Pr_3 policy)] ]
              (if result3
                  (printf "Passed Pr_3~n")
                  (begin
                    (printf "FAILED Pr_3~n Counter-example:~n")
                    (print-avc (find-Pr_3-counter-example policy))))
          
          (and result1 result2 result3)))))

