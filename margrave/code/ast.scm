;;
;; This is a set of asts for converting xacml to a scheme data sturture called ast.
;;
;; Warning: Only tested with case sensitivity on (see the manu Language->Choose Language and check details out)
;;

(include "tschantzUtil.scm")

(module ast mzscheme
  (require (lib "etc.ss") (lib "list.ss")) ; for opt-lambda
  (provide (all-defined))
  
  (define-struct ast ())
  
  ;; - a string representing policy's Rule-Combining Algorithm
  ;;	(its RuleCombiningAlgId value)
  ;; - a list of subject structs (see below) which represent the Subject elements
  ;;    	found in the Target element of the XACML source
  ;; - a list of resource structs (see above)
  ;; - a list of action structs
  ;; - a list of rule structs (see below) which represent the Rule elements found
  ;;  	in the XACML source 
  ;;
  ;; If there is a need to represent additional components of XACML, this struct
  ;; must be expanded to represent those components
  (define-struct (law ast) (name
                            subjects ;; list[list[match]]
                            resources
                            actions))
  
  
  (define-struct (compoundLaw law) (ca
                                    lawList))
  (define compoundLaw-name law-name)
  (define compoundLaw-subjects law-subjects)
  (define compoundLaw-resources law-resources)
  (define compoundLaw-actions law-actions)
    
  (define-struct (policy compoundLaw) ())
  (define policy-name compoundLaw-name)
  (define policy-subjects compoundLaw-subjects)
  (define policy-resources compoundLaw-resources)
  (define policy-actions compoundLaw-actions)
  (define policy-rca compoundLaw-ca)
  (define policy-ruleList compoundLaw-lawList)
  
  (define-struct (policySet compoundLaw) ())
  (define policySet-name compoundLaw-name)
  (define policySet-subjects compoundLaw-subjects)
  (define policySet-resources compoundLaw-resources)
  (define policySet-actions compoundLaw-actions)
  (define policySet-pca compoundLaw-ca)
  (define policySet-compoundLawList compoundLaw-lawList)
  
  
  ;; rule represents the relevant portions of an XACML rule
  ;; XACML information represented in the rule consists of
  ;; - a string representing the rule's name
  ;; 	(its RuleId value in the XACML source)
  ;; - a string representing the rule's effect
  ;; 	(its Effect value)
  ;; - a string representing a unique number assigned to the rule
  ;;	during the execution of ast:make-policy
  ;; 	In the current implementation, this string begins with "s"
  ;;	followed by some number of digits
  ;; - a list of subject structs (see below) which represent the 
  ;; 	Subject elements found in the Target element of the current
  ;;	rule in the XACML source
  ;; - a list of resource structs (see above)
  ;; - a list of action structs (see above)
  (define-struct (rule law) (effect))
  (define rule-name law-name)
  (define rule-subjectList law-subjects)
  (define rule-resourceList law-resources)
  (define rule-actionList law-actions)
  
  ;number
  
  
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
  (define-struct match (subtarget ;; symbol: name of the subtarget in which the match was found
                        id ;; symbol: AttributeId is actually a xml:attribute of a _AttributeDesignator
                        value)) ;; symbol: attributeValue is actually xml:data from <AttributeValue>
                            
  ;DataType))
  
;  (define-struct (subject-match attribute) ())
;  (define subject-match-attributeValue attribute-attributeValue)
;  (define subject-match-attributeId attribute-attributeId)
;  
;  (define-struct (resource-match attribute) ())
;  (define resource-match-attributeValue attribute-attributeValue)
;  (define resource-match-attributeId attribute-attributeId)
;  
;  (define-struct (action-match attribute) ())
;  (define action-match-attributeValue attribute-attributeValue)
;  (define action-match-attributeId attribute-attributeId)
  
  
  ;  (define-struct subject (AttributeValue
  ;                          SubjectAttributeDesignator))
  ;  ;; see comments for subject
  ;  (define-struct resource (AttributeValue
  ;                           ResourceAttributeDesignator))
  ;  ;; see comments for subject
  ;  (define-struct action (AttributeValue
  ;                         ActionAttributeDesignator))
  
  (define-struct (request ast) (subject
                                  resource
                                  action))
  
  
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
                                                (ast->string (ast->string (policySet-compoundLawList ast))))]

                                [(policy? ast)
                                 (string-append "Policy-Model\n"
                                                start "name: " (ast->string (policy-name ast)) "\n"
                                                start "rca : " (ast->string (policy-rca ast)) "\n"                                          
                                                start "subj: " (ast->string (policy-subjects ast)) "\n"
                                                start "res : " (ast->string (policy-resources ast)) "\n"
                                                start "act : " (ast->string (policy-actions ast)) "\n"
                                                (ast->string (ast->string (policy-ruleList ast))))]
                                [(rule? ast)
                                 (string-append start "Rule-Model\n"
                                                start "name: " (ast->string (rule-name ast)) "\n"
                                                start "efct: " (ast->string (rule-effect ast)) "\n"
                                                start "subj: " (ast->string (rule-subjectList ast)) "\n"
                                                start "res : " (ast->string (rule-resourceList ast)) "\n"
                                                start "act : " (ast->string (rule-actionList ast)) "\n")]
                                [(match? ast)
                                 (string-append "\\" (symbol->string (match-subtarget ast)) ":" (symbol->string (match-id ast)) " = " (symbol->string (match-value ast)) "\\")]
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




  ;;;;;;;
  ;; Tests
  ;;;;;;;
;(require (prefix ast: ast)
;         (prefix xacml2ast: xacml2ast))

;(define pfile "xacml_test_cases/simple_policy1.xml")  
;(define pfile "xacml_test_cases/simple_policy2.xml")
;(define pfile "xacml_test_cases/simple_policy3.xml")
;(define pfile "xacml_test_cases/simple_policy4.xml")
;(define pfile "xacml_test_cases/test_continue_05.xml")
;(define pfile "xacml_test_cases/test_continue_10.xml")
;(define pfile "xacml_test_cases/test_continue_16.xml")
;(define pfile "xacml_test_cases/continue_policy2.xml")
;(define pfile "xacml_test_cases/test_continue_policy2.xml")

;(define m (xacml2ast:xacml->ast pfile))
;(display (ast:ast->string m))


