;(load "xacml-base.ss")

;(include "tschantzUtil.scm")
(include "ast.scm")
;(include "set.scm")
;(include "binding.scm")
(include "add.scm")



(module ast-to-add mzscheme
  (provide (all-defined))
  
  (require add
           (prefix ast: ast) 
           (prefix util: tschantzUtil) 
           ;(prefix set: constraint-set) 
           ;(prefix bind: set-binding)
           (lib "list.ss") 
           (lib "etc.ss"))

  ;; law -> XADD
  ;; takes a law of an xacml policy
  ;; and returns a ADD form of it
  (define (ast->add law)
    (cond [(ast:rule? law) 
           (augment-rule (process-target law) 
                         (cond [(eq? (ast:rule-effect law) 'Deny) deny-term]
                               [(eq? (ast:rule-effect law) 'Permit) permit-term]
                               [else (error 'ast->add "illegal rule effect" (ast:rule-effect law))]))]
          [(ast:policy? law)
           (let [ [rca (ast:policy-rca law)] 
                  [children (map ast->add (ast:policy-ruleList law))] ]
             (augment-rule (process-target law)
                           (cond [(or (equal? rca
                                           "urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable")
                                      (equal? rca "first-applicable"))                                  
                                  (build-first-applicable children)]
                                 [(or (equal? rca 
                                             "urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:deny-overrides")
                                      (equal? rca "deny-overrides"))
                                  (build-deny-override children)]
                                 [(or (equal? rca
                                           "urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:permit-overrides")
                                      (equal? rca "permit-overrides"))
                                  (build-permit-override children)]
                                 [else 
                                  (error rca "is an unsurported rca")])))]
          [(ast:policySet? law)
           (let [ [pca (ast:policySet-pca law)] 
                  [children (map ast->add (ast:policySet-compoundLawList law))] ]
             (augment-rule (process-target law)
                           (cond [(or (equal? pca
                                           "urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:first-applicable")
                                      (equal? pca "first-applicable"))                                  
                                  (build-first-applicable children)]
                                 [(or (equal? pca 
                                             "urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:deny-overrides")
                                      (equal? pca "deny-overrides"))
                                  (build-deny-override children)]
                                 [(or (equal? pca
                                           "urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:permit-overrides")
                                      (equal? pca "permit-overrides"))
                                  (build-permit-override children)]
                                 [else 
                                  (error pca "is an unsurported pca")])))]
          [else
           (error 'ast->add "given neither a rule nor a policy nor a policySet when those are the only two types of models that can be done.  Given: ~a" law)]))
  
  (define (process-target law)
    (bdd-and (process-subtarget (ast:law-subjects law))
             (bdd-and (process-subtarget (ast:law-resources law))
                      (process-subtarget (ast:law-actions law)))))
  
  ;; list-list-match -> BDD
  (define (process-subtarget subt)
    (foldr bdd-or 
           bdd-false 
           (map (lambda (match-list) (foldr bdd-and bdd-true (map build-node match-list)))
                subt)))
  
  (define (build-node match)
    (make-var (ast:match-subtarget match)
              (ast:match-id match)
              (ast:match-value match)))

)