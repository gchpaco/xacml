;; To load Margrave.
;; You might have to change the path to where you have Margrave installed.
(require "../../../analysis/margrave.scm")

;; An example of a query over a change impact:
(define (external-grades-no-change comp)  
  (avc-false? (avc-and (get-combo-attrVal-involved-in-change 'Resource 'resource-class comp)
                       (make-avc 'Resource 'resource-class 'ExternalGrades))))

(newline)(newline)(display "===== Pol_3 vs Pol_4 =====")(newline)

(let-xacml-policies [ [prePol_3 "../xacml-code/xacmlA/RPSlist.xml"]
                      [prePol_4 "../xacml-code/xacmlB/RPSlist.xml"] ]
                    (let [ [Pol_3 (constrain-policy-disjoint 
                                   (list (make-avc 'Subject 'role 'Faculty)
                                         (make-avc 'Subject 'role 'Student))
                                   (make-singleton-named-attribute 
                                    'Action 
                                    'command
                                    (make-singleton-named-attribute
                                     'Resource
                                     'resource-class
                                     prePol_3)))]
                           [Pol_4 (constrain-policy-disjoint 
                                   (list (make-avc 'Subject 'role 'Faculty)
                                         (make-avc 'Subject 'role 'Student))
                                   (make-singleton-named-attribute 
                                    'Action 
                                    'command
                                    (make-singleton-named-attribute
                                     'Resource
                                     'resource-class
                                     prePol_4)))] ]
                      (let [ [comp3to4 (compare-policies Pol_3 Pol_4)] ]
                        ;; note that print-comparison-changes only prints the parts of the comparison 
                        ;; that have changes in it (e.g. N->P, but not N->N).  
                        ;; This will print the whole comparison: (print-comparison comp3to4)
                        (print-comparison-changes comp3to4)
                        ;; example of query over the change
                        (printf "~nquery: ~a~n" (external-grades-no-change comp3to4)))))



;;;;;;;;;;;;;;;;;;;;;;;;;
(newline)(newline)(display "===== Pol_3 vs Pol_5 =====")(newline)
(display "== fix TAs")(newline)

(let-xacml-policies [ [prePol_3 "../xacml-code/xacmlA/RPSlist.xml"]
                      [prePol_5 "../xacml-code/xacmlC/RPSlist.xml"] ]
                    (let [ [Pol_3 (constrain-policy-disjoint 
                                   (list (make-avc 'Subject 'role 'Faculty)
                                         (make-avc 'Subject 'role 'Student))
                                   (make-singleton-named-attribute 
                                    'Action 
                                    'command
                                    (make-singleton-named-attribute
                                     'Resource
                                     'resource-class
                                     prePol_3)))]
                           [Pol_5 (constrain-policy-disjoint 
                                   (list (make-avc 'Subject 'role 'Faculty)
                                         (make-avc 'Subject 'role 'Student))
                                   (make-singleton-named-attribute 
                                    'Action 
                                    'command
                                    (make-singleton-named-attribute
                                     'Resource
                                     'resource-class
                                     prePol_5)))] ]
                      (let [ [comp3to5 (compare-policies Pol_3 Pol_5)] ]
                        ;; note that print-comparison-changes only prints the parts of the comparison 
                        ;; that have changes in it (e.g. N->P, but not N->N).  
                        ;; This will print the whole comparison: (print-comparison comp3to4)
                        (print-comparison-changes comp3to5)
                        ;; example of query over the change
                        (printf "~nquery: ~a~n" (external-grades-no-change comp3to5)))))









;(newline)(newline)(display "===== Pol_5 vs Pol_6 =====")(newline)
;(display "== add FacultyFamily")(newline)
;
;(printf "loading Pol_6: ")
;(define Pol_6 (time (constrain-policy-disjoint 
;                     (list (make-avc 'Subject 'role 'Faculty)
;                           (make-avc 'Subject 'role 'Student))
;                     (make-singleton-attribute 
;                      'Action 
;                      'command
;                      (make-singleton-attribute
;                       'Resource
;                       'resource-class
;                       (load-xacml-policy "CodeD/" "RPSlist.xml"))))))
;
;(printf "comparing Pol_5 and Pol_6: ")
;(define comp5to6 (time (compare-policies Pol_5 Pol_6)))
;(print-comparison-changes comp5to6)
;;(print-add-memory-use comp5to6)
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;(newline)(newline)(display "===== Pol_5 vs Pol_7 =====")(newline)
;(display "== no fac facfam contr")(newline)
;
;(printf "loading Pol_7: ")
;(define Pol_7 (time (constrain-policy-disjoint (list  (make-avc 'Subject 'role 'Faculty)  
;                                                      (make-avc 'Subject 'role 'FacultyFamily))
;                                               Pol_6)))
;
;(printf "comparing Pol_5 and Pol_7: ")
;(define comp5to7 (time (compare-policies Pol_5 Pol_7)))
;(print-comparison-changes comp5to7)
;;(print-add-memory-use comp5to7)
