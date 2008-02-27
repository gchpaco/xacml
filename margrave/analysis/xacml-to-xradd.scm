(module xacml-to-xradd mzscheme
  (provide ast->xradd)
    
  (require "xradd.scm"
           (prefix ast: "../xacml/xacml-ast.scm")
           "../lib/errorf.scm"
           (lib "list.ss") 
           (lib "etc.ss"))
  
  ;; law -> XADD
  ;; takes a law of an xacml policy
  ;; and returns a ADD form of it
  (define (ast->xradd law)
    ;(printf "ast->xradd\n")(sleep 1)
    (ast->add-help law))
  
  (define (ast->add-help law)
    ;(printf "ast->xradd-help\n")(sleep 1)
    (cond [(ast:rule? law) 
           (augment-rule (badd-and (process-target law) (process-condition law))
                         (cond [(eq? (ast:rule-effect law) 'Deny) (deny-term)]
                               [(eq? (ast:rule-effect law) 'Permit) (permit-term)]
                               [else (errorf "Illegal rule effect: ~a" (ast:rule-effect law))]))]
          [(ast:policy? law)
           (let [ [rca (ast:policy-rca law)] 
                  [children (map ast->add-help (ast:policy-ruleList law))] ]
             (augment-rule (process-target law)
                           (cond [(or (string=? rca
                                                "urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable")
                                      (string=? rca "first-applicable"))                                  
                                  (build-first-applicable children)]
                                 [(or (string=? rca 
                                                "urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:deny-overrides")
                                      (string=? rca "deny-overrides"))
                                  (build-deny-override children)]
                                 [(or (string=? rca
                                                "urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:permit-overrides")
                                      (string=? rca "permit-overrides"))
                                  (build-permit-override children)]
                                 [else 
                                  (error rca "is an unsurported rca")])))]
          [(ast:policySet? law)
           (let [ [pca (ast:policySet-pca law)] 
                  [children (map ast->add-help (ast:policySet-compoundLawList law))] ]
             (augment-rule (process-target law)
                           (cond [(or (string=? pca
                                                "urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:first-applicable")
                                      (string=? pca "first-applicable"))                                  
                                  (build-first-applicable children)]
                                 [(or (string=? pca 
                                                "urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:deny-overrides")
                                      (string=? pca "deny-overrides"))
                                  (build-deny-override children)]
                                 [(or (string=? pca
                                                "urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:permit-overrides")
                                      (string=? pca "permit-overrides"))
                                  (build-permit-override children)]
                                 [else 
                                  (errorf "\"~a\" is an unsurported pca" pca)])))]
          [else
           (error 'ast->add-help "given neither a rule nor a policy nor a policySet when those are the only two types of models that can be done.  Given: ~a" law)]))
  
  (define (process-condition rule)
    (let [ [condition (ast:rule-condition rule)] ]
      (cond [(void? condition) (badd-true)] ; means that the Condition element was not used
            [(ast:application? condition) (process-application condition)]
            [else (error 'process-condition "If a Condition element is used, it must contain exactly one function application.")])))
  
  
  (define (process-application application)
    (let [ [function-name (ast:application-functionName application)]
           [args (ast:application-args application)] ]
      (cond [(string=? function-name "urn:oasis:names:tc:xacml:1.0:function:or") 
             (foldl badd-or (badd-false) (map process-application args))]
            [(string=? function-name "urn:oasis:names:tc:xacml:1.0:function:and")
             (foldl badd-and (badd-true) (map process-application args))]
            [(string=? function-name "urn:oasis:names:tc:xacml:1.0:function:not") 
             (if (= (length args) 1)
                 (badd-not (process-application (first args)))
                 (error 'process-application "the function urn:oasis:names:tc:xacml:1.0:function:not may only take one argument; given: ~a" (length args)))]
            [(string=? function-name "urn:oasis:names:tc:xacml:1.0:function:string-equal")
             (if (= (length args) 2)
                 (process-attribute-equality (first args) (second args))
                 (error 'process-application "the function urn:oasis:names:tc:xacml:1.0:function:string-equal may only take one argument; given: ~a" (length args)))]
            [else 
             (error 'process-application "A function found within a Condition is unknown.  This function is named: ~s." function-name)])))
  
  
  (define (process-attribute-equality lhs rhs)
    (cond [(and (ast:attribute? lhs) (ast:attribute? rhs))
           (get-equality-add (ast:attribute-subtarget lhs)
                             (ast:attribute-id lhs)
                             (ast:attribute-subtarget rhs)
                             (ast:attribute-id rhs))]
          [(and (ast:attribute? lhs) (ast:attributeValue? rhs))
           (get-match-add (ast:attribute-subtarget lhs)
                          (ast:attribute-id lhs)
                          (ast:attributeValue-value rhs))]
          [(and (ast:attributeValue? lhs) (ast:attribute? rhs))
           (get-match-add (ast:attribute-subtarget rhs)
                          (ast:attribute-id rhs)
                          (ast:attributeValue-value lhs))]
          [(and (ast:attributeValue? lhs) (ast:attributeValue? rhs))
           (if (symbol=? (ast:attributeValue-value lhs) (ast:attributeValue-value rhs))
               (badd-true)
               (badd-false))]
          [else
           (error 'process-attribute-equality "Only attribute designators and attribute values are allowed as arugments in an string-equal application.")]))
  
  
  
  (define (process-target law)
    (badd-and (process-subtarget (ast:law-subjects law))
             (badd-and (process-subtarget (ast:law-resources law))
                      (badd-and (process-subtarget (ast:law-actions law))
                               (process-subtarget (ast:law-environments law))))))
  
  ;; list-list-match -> BDD
  (define (process-subtarget subt)
    (foldr badd-or 
           (badd-false) 
           (map (lambda (match-list) (foldr badd-and (badd-true) (map build-node match-list)))
                subt)))
  
  (define (build-node match)
      (get-match-add (ast:match-subtarget match)
                     (ast:match-id match)
                     (ast:match-value match)))
  
  )