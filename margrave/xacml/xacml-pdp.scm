(module xacml-pdp mzscheme
  
  (provide (all-defined))
 
  (require (prefix ast: "xacml-ast.scm")
           (prefix xacml2ast: "xacml2ast.scm")
           "../lib/errorf.scm"           
           (lib "etc.ss")
           (lib "list.ss"))
  
  
  ;; !
  ;; Each querry-funct shall take an attribute id for the namespace that that querry-funct covers
  ;; and returns either a list (bag) of values assocated with that attribute id or false.
  ;; If a list is returned, then every element of that list will be a symbol.
  ;; False will be returned iff the attribute id does not exist.
  ;; The empty list will be returned if the attribute id exists, but has no values assocated with it.
  ;; (Note that the PDP treats #f and '() the same, but it might not some day so it is better to 
  ;;  make the distingishion now.)
  ;; The function returns one of the following symbols: 'Permit, 'Deny, 'NotApplicable.
  ;; (Some day it might also return the symbol 'Indeterminate, so you might want to code with that in mind.
  ;;  Of course, by than it might also returning a stuct instead of just a symbol, so maybe not.)
  ;; .type xacml-policy -> ( querry-funct * querry-funct * querry-funct * querry-funct  -> decision )
  ;; .type xacml-policy -> ( (symbol -> (| (listof symbol) #f)) * (symbol -> (| (listof symbol) #f)) * (symbol -> (| (listof symbol) #f)) * (symbol -> (| (listof symbol) #f)) -> decision)
  (define (pdp xacml-policy)
    (cond [(string? xacml-policy) (pdp (xacml2ast:xacml->ast xacml-policy))]
          [(ast:law? xacml-policy) 
           (lambda (subject-querry resource-querry action-querry environment-querry)
             (letrec 
                 [
                  ;; Qurries
                  
                  [subtarget->querry-funct
                   (lambda (subtarget)
                     (cond [(symbol=? subtarget 'Subject) subject-querry]
                           [(symbol=? subtarget 'Resource) resource-querry]
                           [(symbol=? subtarget 'Action) action-querry]
                           [(symbol=? subtarget 'Environment) environment-querry]
                           [else (errorf "subtarget given is not a real subtarget: ~s" subtarget)]))]
                  
                  [get-values 
                   (lambda (subtarget attrId)
                     (let [ [values ((subtarget->querry-funct subtarget) attrId)] ]
                       (if values
                           values
                           '())))]
                  
                  [match-holds?
                   (lambda (subtarget attrId value)
                     (member value (get-values subtarget attrId)))]
                  
                  [overlap-holds? 
                   (lambda (lSubtar lAttrId rSubtar rAttrId)
                     (let [ [lValues (get-values lSubtar lAttrId)] 
                            [rValues (get-values rSubtar rAttrId)] ]
                       (ormap (lambda (lValue)
                                (member lValue rValues))
                              lValues)))]
                  
                  ;; Targets               
                  
                  [subtarget-holds? 
                   (lambda (subt)                  
                     (ormap (lambda (match-list) 
                              (andmap (lambda (match)
                                        (match-holds? (ast:match-subtarget match)
                                                      (ast:match-id match)
                                                      (ast:match-value match)))
                                      match-list))
                            subt))]
                  
                  [target-holds?
                   (lambda (law)
                     (and (subtarget-holds? (ast:law-subjects law))
                          (subtarget-holds? (ast:law-resources law) )
                          (subtarget-holds? (ast:law-actions law))                                 
                          (subtarget-holds? (ast:law-environments law))))]
                  
                  ;; Conditions
                  
                  [attribute-equality-holds? 
                   (lambda (lhs rhs)
                     (cond [(and (ast:attribute? lhs) (ast:attribute? rhs))
                            (overlap-holds? (ast:attribute-subtarget lhs)
                                            (ast:attribute-id lhs)
                                            (ast:attribute-subtarget rhs)
                                            (ast:attribute-id rhs))]
                           [(and (ast:attribute? lhs) (ast:attributeValue? rhs))
                            (match-holds? (ast:attribute-subtarget lhs)
                                          (ast:attribute-id lhs)
                                          (ast:attributeValue-value rhs))]
                           [(and (ast:attributeValue? lhs) (ast:attribute? rhs))
                            (match-holds? (ast:attribute-subtarget rhs)
                                          (ast:attribute-id rhs)
                                          (ast:attributeValue-value lhs))]
                           [(and (ast:attributeValue? lhs) (ast:attributeValue? rhs))
                            (symbol=? (ast:attributeValue-value lhs) (ast:attributeValue-value rhs))]
                           [else
                            (errorf "Only attribute designators and attribute values are allowed as arugments in an string-equal application.")]))]
                  
                  [application-holds? 
                   (lambda (application)
                     (let [ [function-name (ast:application-functionName application)]
                            [args (ast:application-args application)] ]
                       (cond [(string=? function-name "urn:oasis:names:tc:xacml:1.0:function:or") 
                              (ormap application-holds? args)]
                             [(string=? function-name "urn:oasis:names:tc:xacml:1.0:function:and")
                              (andmap application-holds? args)]
                             [(string=? function-name "urn:oasis:names:tc:xacml:1.0:function:not") 
                              (if (= (length args) 1)
                                  (not (application-holds? (first args)))
                                  (errorf "The function urn:oasis:names:tc:xacml:1.0:function:not may only take one argument; given: ~a" 
                                          (length args)))]
                             [(string=? function-name "urn:oasis:names:tc:xacml:1.0:function:string-equal")
                              (if (= (length args) 2)
                                  (attribute-equality-holds? (first args) (second args))
                                  (error "The function urn:oasis:names:tc:xacml:1.0:function:string-equal may only take one argument; given: ~a"
                                         (length args)))]
                             [else 
                              (errorf "A function found within a Condition is unknown.  This function is named: ~s."
                                      function-name)])))]
                  
                  [condition-holds? 
                   (lambda (rule)
                     (let [ [condition (ast:rule-condition rule)] ]
                       (cond [(void? condition) true] ; means that the Condition element was not used
                             [(ast:application? condition) (application-holds? condition)]
                             [else (errorf "If a Condition element is used, it must contain exactly one function application.")])))]  
                  
                  ;; Policy combining
                  
                  [handle-first-applicable 
                   (lambda (children)
                     (if (empty? children)
                         'NA
                         (let [ [decision (process-law (first children))] ]
                           (if (symbol=? decision 'NA)
                               (handle-first-applicable (rest children))
                               decision))))]
                  
                  [handle-deny-override
                   (lambda (children)
                     (if (empty? children)
                         'NA
                         (let [ [decision (process-law (first children))] ]
                           (cond [(symbol=? decision 'Deny) 'Deny]
                                 [(symbol=? decision 'Permit) (if (symbol=? (handle-deny-override (rest children)) 'Deny)
                                                                  'Deny
                                                                  'Permit)]
                                 [(symbol=? decision 'NA) (handle-deny-override (rest children))]))))]
                  [handle-permit-override
                   (lambda (children)
                     (if (empty? children)
                         'NA
                         (let [ [decision (process-law (first children))] ]
                           (cond [(symbol=? decision 'Permit) 'Permit]
                                 [(symbol=? decision 'Deny) (if (symbol=? (handle-deny-override (rest children)) 'Permit)
                                                                'Permit
                                                                'Deny)]
                                 [(symbol=? decision 'NA) (handle-permit-override (rest children))]))))]
                  
                  ;; Dealing with Laws
                  
                  [process-law 
                   (lambda (law)
                     (cond [(ast:rule? law) 
                            (if (and (target-holds? law) 
                                     (condition-holds? law))
                                (cond [(eq? (ast:rule-effect law) 'Deny) 'Deny]
                                      [(eq? (ast:rule-effect law) 'Permit) 'Permit]
                                      [else (errorf "Illegal rule effect: ~a" (ast:rule-effect law))])
                                'NA)]
                           [(ast:policy? law)
                            (if (target-holds? law)
                                (let [ [rca (ast:policy-rca law)] 
                                       [children (ast:policy-ruleList law)] ]
                                  (cond [(or (string=? rca "urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable")
                                             (string=? rca "first-applicable"))                                  
                                         (handle-first-applicable children)]
                                        [(or (string=? rca "urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:deny-overrides")
                                             (string=? rca "deny-overrides"))
                                         (handle-deny-override children)]
                                        [(or (string=? rca "urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:permit-overrides")
                                             (string=? rca "permit-overrides"))
                                         (handle-permit-override children)]
                                        [else 
                                         (error rca "is an unsurported rca")]))
                                'NA)]
                           [(ast:policySet? law)
                            (if (target-holds? law)
                                (let [ [pca (ast:policySet-pca law)] 
                                       [children (ast:policySet-compoundLawList law)] ]
                                  (cond [(or (string=? pca "urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:first-applicable")
                                             (string=? pca "first-applicable"))
                                         (handle-first-applicable children)]
                                        [(or (string=? pca "urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:deny-overrides")
                                             (string=? pca "deny-overrides"))
                                         (handle-deny-override children)]
                                        [(or (string=? pca "urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:permit-overrides")
                                             (string=? pca "permit-overrides"))
                                         (handle-permit-override children)]
                                        [else 
                                         (errorf "\"~a\" is an unsurported pca" pca)]))
                                'NA)]
                           [else
                            (errorf "given neither a rule nor a policy nor a policySet when those are the only two types of models that can be done.  Given: ~a" law)]))]               
                  ]
               
               (process-law xacml-policy) ))]))
  
  
  
  
  
  
  (define (pdp2 xacml-policy)
    (lambda (subject-id resource-id action-id querry)
      ((pdp xacml-policy)
       (lambda (attr-id) (querry attr-id 'of subject-id))
       (lambda (attr-id) (querry attr-id 'of resource-id))
       (lambda (attr-id) (querry attr-id 'of action-id))
       (lambda (attr-id) (querry attr-id)))))
  
  )

;;;;;;;;;;;;;;;;;;;
;; tests
;(require errorf)
;(require xacml-pdp)
;(let [[ policy (pdp "../examples/continue/policy.xml") ]]
;  (policy (lambda (id) (cond [(symbol=? id 'role) '(chair)]
;                          [(symbol=? id 'id) '(a)]
;                          [(symbol=? id 'conflicts) '(b)]
;                          [else (errorf "s~s" id)]))
;          (lambda (id) (cond [(symbol=? id 'class) '(paper)]
;                             [(symbol=? id 'id) '(b)]
;                             [else (errorf "r~s" id)]))
;          (lambda (id) (cond [(symbol=? id 'cmd) '(read)]
;                             [else (errorf "a~s" id)]))
;          (lambda (id) (cond [(symbol=? id 'mode) '(normal)]
;                             [(symbol=? id 'phase) '(pre-submission)]
;                             [else (errorf "e~s" id)]))))