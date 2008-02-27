(module ast2xacml mzscheme
  
  (provide write-xacml)
  
  (require "xacml-ast.scm"
           "../lib/errorf.scm"
           (lib "list.ss")
           (lib "etc.ss")
           (prefix xml: (lib "xml.ss" "xml"))
           (prefix swindle: (lib "swindle.ss" "swindle")))
  
  (define elem list)
  (define atrlst list)
  (define atr list)
  (define (add-content elem-tag-atrlst-content content)
    (append elem-tag-atrlst-content content))
  
  
  ;; name is 'Subject, 'Resource, 'Action, or 'Enivironment.
  (define (match->xacml name match)
    (elem (swindle:symbol-append name 'Match)
          (atrlst (atr 'MatchId "urn:oasis:names:tc:xacml:1.0:function:string-equal"))
          (attributeValue->xacml (match-attributeValue match))
          (attribute->xacml (match-attribute match))))
  
  (define (attributeValue->xacml attrVal)
    (elem 'AttributeValue
          (atrlst (atr 'DataType "http://www.w3.org/2001/XMLSchema#string"))
          (symbol->string (attributeValue-value attrVal))))
  
  (define (attribute->xacml attr)
    (elem (swindle:symbol-append (attribute-subtarget attr) 'AttributeDesignator)
          (atrlst (atr 'AttributeId (symbol->string (attribute-id attr)))
                  (atr 'DataType "http://www.w3.org/2001/XMLSchema#string"))))
  
  ;; name is 'Subject, 'Resource, 'Action, or 'Environment.
  (define (subtarget->xacml name subtarget)
    (cond [(equal? subtarget '() ) (errorf "Impossible Subtarget Rearched")] ; always false
          [(equal? subtarget '(()) ) (void)] ; always true, no content, skip
          [else (add-content (elem (swindle:symbol-append name 's) ; ( (m m m) (m m) )
                                   (atrlst))
                             (map (lambda (match-lst)
                                    (add-content (elem name
                                                       (atrlst))
                                                 (map (lambda (match) 
                                                        ;(printf ">>> ~s" (match->xacml name match))
                                                        (match->xacml name match))
                                                      match-lst)))
                                  subtarget))]))
  
  (define (law->target-xacml ast)
    (add-content (elem 'Target
                       (atrlst))
                 (filter (swindle:negate void?)
                         (list (subtarget->xacml 'Subject (policy-subjects ast)) 
                               (subtarget->xacml 'Resource (policy-resources ast))
                               (subtarget->xacml 'Action (policy-actions ast))
                               (subtarget->xacml 'Environment (policy-environments ast))))))
  
  (define (expression->xacml exp)
    (cond [(attribute? exp) (attribute->xacml exp)]
          [(attributeValue? exp) (attributeValue->xacml exp)]
          [(application? exp) (application->xacml exp)]))
  
  (define (application->xacml app)
    (add-content (elem 'Apply 
                       (atrlst (atr 'FunctionId (application-functionName app))))
                 (map expression->xacml (application-args app))))
  
  
  (define (condition->xacml condition)
    (cond [(void? condition) #f]
          [(application? condition) (elem 'Condition 
                                          (atrlst) 
                                          (application->xacml condition))]))
  
  
  (define (law->xacml ast)
    (cond [(policySet? ast) 
           (add-content (elem 'PolicySet
                              (atrlst (atr 'PolicySetId (policySet-name ast))
                                      (atr 'PolicyCombiningAlgId (policySet-pca ast)))
                              (law->target-xacml ast))
                        (map law->xacml (policySet-compoundLawList ast)))]
          [(policy? ast) 
           (add-content (elem 'Policy
                              (atrlst (atr 'PolicyId (policy-name ast))
                                      (atr 'RuleCombiningAlgId (policy-rca ast)))
                              (law->target-xacml ast))
                        (map law->xacml (policy-ruleList ast)))]
          [(rule? ast)
           (let [ [condition (condition->xacml (rule-condition ast))] ]
             ;(printf "~n condition: ~s~n" condition)
             (if condition 
                 (elem 'Rule
                       (atrlst (atr 'RuleId (rule-name ast))
                               (atr 'Effect (symbol->string (rule-effect ast))))
                       (law->target-xacml ast)
                       condition)
                 (elem 'Rule
                       (atrlst (atr 'RuleId (rule-name ast))
                               (atr 'Effect (symbol->string (rule-effect ast))))
                       (law->target-xacml ast))))]))
                 
  
  (define write-xacml 
    (opt-lambda (ast [file (current-output-port)])
      ;(printf "~n~n~n~n write-xacml: ~s ~n~n~n" (law->xacml ast))
      (cond [(port? file) (xml:write-xml/content (xml:xexpr->xml (law->xacml ast)) file)]
            [(string? file) (let [ [port (open-output-file file)] ]
                              (write-xacml ast port)
                              (close-output-port port))])))
  
  
  
  )

