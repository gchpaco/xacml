(module xacml-ast mzscheme
  (require (lib "etc.ss") 
           (lib "list.ss")) ; for opt-lambda
  (provide (all-defined))
  
  (define-struct ast ())
  
  ;; Represents the core sturcture common to Rules, Policies, and PolicySets which is:
  ;; name - a string representing the name of the law (by XACML every law must have a id)
  ;; subjects - a list[list[match]] which represents the DNF of subtarget for the subject.
  ;; resources -    "                           "                         "       resource.
  ;; actions -      "                           "                         "       actions.
  ;; environments - "                           "                         "       environments.
  ;; These four list[list[match]]s have the following interpatation: 
  ;; The list[match]s are ORed together and the matches in a list are ANDed to  together.
  ;; They be may be thought of listing the acceptable subjects/resources/actions/environments
  ;; Thus, ( (m1 m2) (m3 m4) ) may be thought of as (or (and m1 m2) (and m3 m4));
  ;; ( () ) as (or (and)) = (or true) = true; and
  ;; () as (or) = false.
  ;; Finally, the interpatation of the subjects, resources, actions, and environments all together
  ;; requires ANDing them together.
  (define-struct (law ast) (name
                            subjects ;; list[list[match]]
                            resources
                            actions
                            environments))
  
  ;; Respresents what Policies and PolicySets have in common which is:
  ;; ca - a symbol which is the name of the rule or policy combining algorithm
  ;; lawList - a list[law] which holds all of the compoundLaw's children
  (define-struct (compoundLaw law) (ca
                                    lawList))
  (define compoundLaw-name law-name)
  (define compoundLaw-subjects law-subjects)
  (define compoundLaw-resources law-resources)
  (define compoundLaw-actions law-actions)
  (define compoundLaw-environments law-environments)
  
  ;; Due to the subset of XACML on which we are working, 
  ;; Policies and PolicySets may be treated as the same structure.
  ;; Thus, nothing is added to their sturtures.
  
  (define-struct (policy compoundLaw) ())
  (define policy-name compoundLaw-name)
  (define policy-subjects compoundLaw-subjects)
  (define policy-resources compoundLaw-resources)
  (define policy-actions compoundLaw-actions)
  (define policy-environments compoundLaw-environments)
  (define policy-rca compoundLaw-ca)
  (define policy-ruleList compoundLaw-lawList)
  
  (define-struct (policySet compoundLaw) ())
  (define policySet-name compoundLaw-name)
  (define policySet-subjects compoundLaw-subjects)
  (define policySet-resources compoundLaw-resources)
  (define policySet-actions compoundLaw-actions)
  (define policySet-environments compoundLaw-environments)
  (define policySet-pca compoundLaw-ca)
  (define policySet-compoundLawList compoundLaw-lawList)
  
  
  ;; Represents the relevant portions of an XACML rule 
  ;; that is not common to Policies or PolicySets, which is:
  ;; effect - a symbol representing the rule's effect
  ;; 	     (its Effect value, either 'Permit or 'Deny
  ;; conditional - a function application
  ;;               is #void if not presencent
  (define-struct (rule law) (effect
                             condition))
  (define rule-name law-name)
  (define rule-subjects law-subjects)
  (define rule-resources law-resources)
  (define rule-actions law-actions)
  (define rule-environments law-environments)
  
  ;; An XACML equality test between two attribute ids.
  ;; left-subtarget - A symbol respresenting the subtarget of the lhs attribute
  ;; left-id - a symbol respresenting the id of the attribute on the lhs
  ;; right-subtarget - A symbol respresenting the subtarget of the rhs attribute
  ;; right-id - a symbol respresenting the id of the attribute on the rhs
  ;; The equality-test is considered to have passed iff theres exists a value
  ;; assocated by the request with the left attribute that is equal to a value
  ;; assocated with the right attribute.
  ;(define-struct equality-test (left-subtarget
  ;                              left-id
  ;                              right-subtarget
  ;                              right-id))
  
  
  ;; subject  represents portions of a Subject element found in
  ;; 	the Target element of an XACML policy, or in the Target 
  ;; 	of an XACML Rule element
  ;; The information represented in this struct consists of
  ;; - a string representing the value of an AttributeValue property
  ;; 	in the XACML source
  ;; - a string representing the AttributeId value of a SubjectAttributeDesignator
  ;; 	element in the XACML source
  ;;
  ;; attribute is modeling a <Match> or <Attribute> and combining alot of different XACML tags into one
  ;; it may need to be subtyped or worse later.  It is unclear why XACML has so many tags to do this.
  ;  (define-struct match (subtarget ;; symbol: name of the subtarget in which the match was found
  ;                        id ;; symbol: AttributeId is actually a xml:attribute of a _AttributeDesignator
  ;                        value)) ;; symbol: attributeValue is actually xml:data from <AttributeValue>
  
  ;DataType))
  
  (define-struct (match ast) (attribute ;attribute-struct
                              attributeValue)) ; value-struct
  (define (match-id match)
    (attribute-id (match-attribute match)))
  (define (match-subtarget match)
    (attribute-subtarget (match-attribute match)))
  (define (match-value match)
    (attributeValue-value (match-attributeValue match)))
  
  
  (define-struct (expression ast) ())
  
  (define-struct (attribute expression) (subtarget
                                         id))
  
  (define-struct (attributeValue expression) (value))
  
  
  ;; function-name - a symbol representing the name of the function that is being applied
  ;; args - a list of argumentments, each of which is an expression
  (define-struct (application expression) (functionName
                                           args))
  
  ;; not used, but might be helpful to someone later
  (define-struct (request ast) (subject
                                resource
                                action
                                environment))
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; For output
  
  (define ast->string (opt-lambda (ast [start ""] [add "  "])
                        (cond [(string? ast)
                               ast]
                              [(symbol? ast) 
                               (symbol->string ast)]
                              [(policySet? ast)
                               (string-append "PolicySet-Model\n"
                                              start "name: " (ast->string (policySet-name ast)) "\n"
                                              start "pca : " (ast->string (policySet-pca ast)) "\n"                                          
                                              start "subj: " (ast->string (policySet-subjects ast)) "\n"
                                              start "res : " (ast->string (policySet-resources ast)) "\n"
                                              start "act : " (ast->string (policySet-actions ast)) "\n"
                                              start "env : " (ast->string (policySet-environments ast)) "\n"
                                              (ast->string (ast->string (policySet-compoundLawList ast))))]
                              
                              [(policy? ast)
                               (string-append "Policy-Model\n"
                                              start "name: " (ast->string (policy-name ast)) "\n"
                                              start "rca : " (ast->string (policy-rca ast)) "\n"                                          
                                              start "subj: " (ast->string (policy-subjects ast)) "\n"
                                              start "res : " (ast->string (policy-resources ast)) "\n"
                                              start "act : " (ast->string (policy-actions ast)) "\n"
                                              start "env : " (ast->string (policy-environments ast)) "\n"
                                              (ast->string (ast->string (policy-ruleList ast))))]
                              [(rule? ast)
                               (string-append start "Rule-Model\n"
                                              start "name: " (ast->string (rule-name ast)) "\n"
                                              start "efct: " (ast->string (rule-effect ast)) "\n"
                                              start "subj: " (ast->string (rule-subjects ast)) "\n"
                                              start "res : " (ast->string (rule-resources ast)) "\n"
                                              start "act : " (ast->string (rule-actions ast)) "\n"
                                              start "env : " (ast->string (rule-environments ast)) "\n"
                                              (if (void? (rule-condition ast))
                                                  (string-append start "no cond\n")
                                                  (string-append start "cond: " (ast->string (rule-condition ast)))))]
                              [(application? ast)
                               (string-append start "app of " (application-functionName ast) 
                                              " on " (ast->string (application-args ast)))]
                              [(match? ast)
                               (string-append "\\match " (symbol->string (match-subtarget ast)) 
                                              ":" (symbol->string (match-id ast)) 
                                              " = " (symbol->string (match-value ast)) "\\")]
                              [(attribute? ast)
                               (string-append "\\attr " (symbol->string (attribute-subtarget ast)) 
                                              ":" (symbol->string (attribute-id ast)) "\\")]
                              [(attributeValue? ast)
                               (string-append "\\value " (symbol->string (attributeValue-value ast)) "\\")]
                              [(request? ast)
                               (string-append start "Request-Model\n"
                                              start "subj: " (ast->string (request-subject ast)) "\n"
                                              start "res : " (ast->string (request-resource ast)) "\n"
                                              start "act : " (ast->string (request-action ast)) "\n")]
                              [(list? ast) 
                               (string-append "( " (foldr string-append 
                                                          ""
                                                          (map (lambda (law) (ast->string law (string-append start add) add)) ast)) " )")]
                              [else "@@@@@@@@@@@ something else"])))
  
  ;  (define show-ast (opt-lambda (ast [start ""] [add "  "])
  ;                       (cond [(policy? ast)
  ;                              (begin0
  ;                                (printf "~aPolicy-Model~n" start) 
  ;                                (printf "~aname: ~a~n" start (policy-name ast))
  ;                                (printf "~arca : ~a~n" start (policy-rca ast))
  ;                                (printf "~asubj: ~a~n" start (policy-subjectList ast))
  ;                                (printf "~ares : ~a~n" start (policy-resourceList ast))
  ;                                (printf "~aact : ~a~n" start (policy-actionList ast))
  ;                                (map (lambda (x) (show-ast x (string-append start add) add)) (policy-lawList ast))
  ;                                (printf "~n"))]
  ;                             [(rule? ast)
  ;                              (begin0
  ;                                (printf "~aRule-Model~n" start)
  ;                                (printf "~aname: ~a~n" start (rule-name ast))
  ;                                (printf "~aefct: ~a~n" start (rule-effect ast))
  ;                                (printf "~asubj: ~a~n" start (rule-subjectList ast))
  ;                                (printf "~ares : ~a~n" start (rule-resourceList ast))
  ;                                (printf "~aact : ~a~n" start (rule-actionList ast)))]
  ;                             [(request? ast)
  ;                              (begin0
  ;                                (printf "~aRequest-Model~n" start)
  ;                                (printf "~asubj: ~a~n" start (request-subject ast))
  ;                                (printf "~ares : ~a~n" start (request-resource ast))
  ;                                (printf "~aact : ~a~n" start (request-action ast)))]
  ;                             [else (printf "@@@@@@@@@@@ something else")])))
  
  )
