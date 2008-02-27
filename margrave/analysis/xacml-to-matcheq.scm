
(module xacml-to-matcheq mzscheme
  
  (provide ast->matcheq-list)
  
  (require (prefix ast: "../xacml/xacml-ast.scm")
           "matcheq.scm"
           (lib "list.ss"))
  
  ;; law -> XADD
  ;; takes a law of an xacml policy
  ;; and returns a ADD form of it
  (define (ast->matcheq-list law)
    ;(printf "ast->matcheq-list: ~a~n~n" (ast:ast->string law))
    (cond [(ast:rule? law) 
           (append (target->matcheq-list law)
                   (condition->matcheq-list (ast:rule-condition law)))]
          [(ast:compoundLaw? law)
           (append (target->matcheq-list law)
                   (apply append (map ast->matcheq-list (ast:compoundLaw-lawList law))))]
          [else
           (error 'ast->matcheq-list "Given neither a rule nor a policy nor a policySet when those are the only two types of models that can be done.  Given: ~a" law)]))
  
  (define (condition->matcheq-list condition)
    (cond [(void? condition) '()] ; means that the Condition element was not used
          [(ast:application? condition) (application->matcheq-list condition)]
          [else (error 'condition->matcheq-list "If a Condition element is used, it must contain exactly one function application.")]))
  
  
  (define (application->matcheq-list application)
    (let [ [function-name (ast:application-functionName application)]
           [args (ast:application-args application)] ]
      (cond [(or (string=? function-name "urn:oasis:names:tc:xacml:1.0:function:or") 
                 (string=? function-name "urn:oasis:names:tc:xacml:1.0:function:and"))
             (apply append (map application->matcheq-list args))]
            [(string=? function-name "urn:oasis:names:tc:xacml:1.0:function:not") 
             (if (= (length args) 1)
                 (application->matcheq-list (first args))
                 (error 'application->matcheq-list "the function urn:oasis:names:tc:xacml:1.0:function:not may only take one argument; given: ~a" (length args)))]
            [(string=? function-name "urn:oasis:names:tc:xacml:1.0:function:string-equal")
             (if (= (length args) 2)
                 (attribute-equality->matcheq-list (first args) (second args))
                 (error 'application->matcheq-list "the function urn:oasis:names:tc:xacml:1.0:function:string-equal may only take one argument; given: ~a" (length args)))]
            [else 
             (error 'application->matcheq-list "A function found within a Condition is unknown.  This function is named: ~s." function-name)])))
  
  
  (define (attribute-equality->matcheq-list lhs rhs)
    (list (cond [(and (ast:attribute? lhs) (ast:attribute? rhs))
                 (make-equality (ast:attribute-subtarget lhs)
                                (ast:attribute-id lhs)
                                (ast:attribute-subtarget rhs)
                                (ast:attribute-id rhs))]
                [(and (ast:attribute? lhs) (ast:attributeValue? rhs))
                 (make-match (ast:attribute-subtarget lhs)
                             (ast:attribute-id lhs)
                             (ast:attributeValue-value rhs))]
                [(and (ast:attributeValue? lhs) (ast:attribute? rhs))
                 (make-match (ast:attribute-subtarget rhs)
                             (ast:attribute-id rhs)
                             (ast:attributeValue-value lhs))]
                [(and (ast:attributeValue? lhs) (ast:attributeValue? rhs))
                 (error 'attribute-equality->matcheq-list "The comparsion of attribute values is unneeded.")]
                [else
                 (error 'attribute-equality->matcheq-list "Only attribute designators and attribute values are allowed as arugments in an string-equal application.")])))
  
  
  (define (target->matcheq-list law)
    (append (subtarget->matcheq-list (ast:law-subjects law))
            (subtarget->matcheq-list (ast:law-resources law))
            (subtarget->matcheq-list (ast:law-actions law))
            (subtarget->matcheq-list (ast:law-environments law))))
  
  
  ;; list-list-match -> BDD
  (define (subtarget->matcheq-list subt)
    ;(printf "subtarget->matcheq-list: ~s~n" subt)
    (apply append 
           (map (lambda (match-list) (apply append (map match->matcheq-list match-list)))
                subt)))
  
  (define (match->matcheq-list match)
    (list (make-match (ast:match-subtarget match)
                      (ast:match-id match)
                      (ast:match-value match))))
  
  )