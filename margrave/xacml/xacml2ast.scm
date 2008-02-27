;; xacml-to-ast
;;
;; These are functions to read an XACML file and return a policy
;; struct (see ast)
;; Only a subset of XACML is covered; if addition or deletions to this subset are made, 
;; then the definitions of the relevant structs must also be changed.
;; The xml library (xml.ss) is used to get a Document struct representing
;; the XACML policy.  This struct is then traversed recursively.
;; Structs defined in xml.ss will be written in comments as xml:<struct name>. 
;; An example of the output of read-xml is provided in output.example
;; See the xml library documentation for information about xml structs.            
(module xacml2ast mzscheme  
  
  (require (prefix ast: "xacml-ast.scm")
           "../lib/sxml-tools.scm"
           (lib "etc.ss") 
           (lib "list.ss")
           "../lib/errorf.scm"
           "../lib/file-utils.scm"
           (prefix swindle: (lib "misc.ss" "swindle"))
           (prefix util: "../lib/tschantz-util.scm")) ;; for parsing; for local; for filter; for find-if
  
  (provide (all-defined))
  
  
  ;; The parser will remove white space from the content (e.g. <tag at="v">content</tag>, content is the content)
  ;; for any tag listed below.
  (define whitespace-does-not-matter  
    '(PolicySet Policy Rule 
                Target 
                Subjects Subject SubjectMatch 
                Resource Resources ResourceMatch 
                Action Actions ActionMatch 
                Enivironment Enivironments EnivironmentMatch 
                Request 
                Attribute
                Condition Apply)) ; new for version 2
  
  ;; .type string [bool] -> ast
  ;; converts an xacml policy stored in one the above input types into a ast.
  ;; .parameter xacml-file-name the path to the XACML file.
  ;; .parameter verbose? true if rotine parsing messages should be displayed.  Defaults to false.
  (define xacml->ast
    (opt-lambda (xacml-file-name [verbose? #f])
      (cond [(string? xacml-file-name) 
             (xacml->ast (string->path xacml-file-name) verbose?)]
            [(path? xacml-file-name)
             (let-values [ [(base name dir?) (split-path* xacml-file-name)] ]
               (let [ [ast (parse-compoundLaw (->xexpr (build-path* base name) whitespace-does-not-matter) base verbose?)] ]
                 (if verbose? (printf (ast:ast->string ast)))
                 ast))]
            [else (errorf "xacml->ast (the xacml parser) must be passed either string or a path.  Given: ~s" xacml-file-name)])))
  
  
  ;; .type ((xexpr PolicySet) | (xexpr Policy)) path bool -> ast
  (define (parse-compoundLaw xexpr path verbose?)
    (let [ [tag (get-tag xexpr)] ]
      (cond [(symbol=? tag 'PolicySet) (parse-policySet xexpr path verbose?)]
            [(symbol=? tag 'Policy) (parse-policy xexpr path verbose?)]
            [else (errorf "XACML Syntax Error: A policy or policy set was needed.  Instead ~a was found." tag)])))
  
  
  ;; .type (xexpr PolicySet) -> ast
  (define (parse-policySet policyset path verbose?)
    (if (empty? (get-content policyset))
        (errorf "XACML Syntax Error: A PolicySet without a target was found")
        (let* [ [content (remove-obligations (remove-description (get-content policyset)))]
                [target (first content)] ]
          (cond [(symbol=? (get-tag target) 'Target)
                 (begin
                   (make-sure-subtargets-in-order "PolicySet" target)
                   (ast:make-policySet (get-attribute 'PolicySetId policyset)
                                       (parse-subtarget 'Subjects target)
                                       (parse-subtarget 'Resources target)
                                       (parse-subtarget 'Actions target)
                                       (parse-subtarget 'Environments target)
                                       (get-attribute 'PolicyCombiningAlgId policyset)
                                       (map (lambda (term) (parse-subpolicySet term path verbose?))
                                            (rest content))))]
                [(symbol=? (get-tag target) 'PolicySetDefaults)
                 (errorf "Support Error: PolicySetDefaults is not supported by Margrave.")]
                [else
                 (errorf "XACML Syntax Error: A Target element was not found where needed in a PolicySet.  Instead a ~a element was found." (get-tag (first content)))]))))
  
  ;; .type ((xexpr PolicySet) | (xexpr Policy) | (xexpr PolicySetIdReference) | (xexpr PolicyIdReference)) path bool -> ast
  (define (parse-subpolicySet xexpr path verbose?)
    (let [ [tag (get-tag xexpr)] ]
      (cond [(symbol=? tag 'PolicySet) 
             (parse-policySet xexpr path verbose?)]
            [(symbol=? tag 'Policy) 
             (parse-policy xexpr path verbose?)]
            [(or (symbol=? tag 'PolicySetIdReference)
                 (symbol=? tag 'PolicyIdReference))
             (if verbose? (printf "loading ~a~n" (get-value xexpr)))
             (xacml->ast (build-path* path (string-append (get-value xexpr) ".xml")) verbose?)]
            [(or (symbol=? tag 'CombinerParameters)
                 (symbol=? tag 'PolicyCombinerParameters)
                 (symbol=? tag 'PolicySetCombinerParameters))
             (errorf "Support Error: ~a are not supported by Margrave." tag)]
            [else (errorf "XACML Syntax Error: a ~a element was found inside a PolicySet where only the PolicySet, Policy, PolicySetIdReference, PolicyIdReference, CombinerParameters, PolicyCombinerParameters, and PolicySetCombinerParameters are allowed." tag)])))
  
  
  ;; .type (xexpr Policy) -> ast
  (define (parse-policy policy path verbose?)
    (if (empty? (get-content policy))
        (errorf "XACML Syntax Error: A Policy without a target was found.")
        (let* [ [content (remove-obligations (remove-description (get-content policy)))]
                [target (first content)] ]
          (cond [(symbol=? (get-tag target) 'Target)
                 (begin 
                   (make-sure-subtargets-in-order "Policy" target)
                   (ast:make-policy (get-attribute 'PolicyId policy)
                                    (parse-subtarget 'Subjects target)
                                    (parse-subtarget 'Resources target)
                                    (parse-subtarget 'Actions target)
                                    (parse-subtarget 'Environments target)
                                    (get-attribute 'RuleCombiningAlgId policy)
                                    (map (lambda (term) (parse-subpolicy term path verbose?))
                                         (rest content))))]
                [(symbol=? (get-tag target) 'PolicyDefaults)
                 (errorf "Support Error: PolicyDefaults is not supported by Margrave.")]
                [(symbol=? (get-tag target) 'CombinerParameters)
                 (errorf "Support Error: CombinerParameters is not supported by Margrave.")]
                [else
                 (errorf "XACML Syntax Error: A Target element was not found where needed in a Policy.  Instead a ~a element was found." (get-tag (first content)))]))))
  
  ;; a lot of different things can be inside a policy.  
  ;; throw errors for all them except for rules
  ;; parse the rules.
  (define (parse-subpolicy subpolicy path verbose?)
    (cond [(symbol=? (get-tag subpolicy) 'Rule)
           (parse-rule subpolicy path verbose?)]
          [(symbol=? (get-tag subpolicy) 'CombinerParameters)
           (errorf "Support Error: CombinerParameters is not supported by Margrave.")]
          [(symbol=? (get-tag subpolicy) 'RuleCombinerParameters)
           (errorf "Support Error: RuleCombinerParameters is not supported by Margrave.")]
          [(symbol=? (get-tag subpolicy) 'VariableDefinition)
           (errorf "Support Error: VariableDefinition is not supported by Margrave.")]
          [else 
           (errorf "XACML Syntax Error: Rule was not found where needed.  Instead a ~a element was found." (get-tag subpolicy))]))
  
  ;; .type (xexpr Rule) -> ast
  (define (parse-rule rule path verbose?)
    ;(printf "parse-rule: ~a" rule)
    (make-sure-rule-in-order rule)
    (let [ [target (get-subxexpr 'Target rule)]
           [condition (get-subxexpr 'Condition rule)] ]
      (if target
          (ast:make-rule (get-attribute 'RuleId rule)
                         (parse-subtarget 'Subjects target)
                         (parse-subtarget 'Resources target)
                         (parse-subtarget 'Actions target)
                         (parse-subtarget 'Environments target)
                         (string->symbol (get-attribute 'Effect rule))
                         (parse-condition condition))
          (ast:make-rule (get-attribute 'RuleId rule)
                         '(())  ; no target give
                         '(())  ;  thus all
                         '(())  ;  requests match
                         '(())  ;  as indicated by '(())  (DNF form)
                         (string->symbol (get-attribute 'Effect rule))
                         (parse-condition condition)))))
  
  (define (parse-condition condition)
    (if condition
        (let [ [content (get-content condition)] ]
          (cond [(= (length content) 1)
                 (parse-expression (first content))]
                [else
                 (errorf "XACML Syntax Error: a condition element must include exactly one expression; given ~a; they were: ~s" (length content) content)]))
        (void))); if no condition give, represent this by void
  
  (define (parse-expression expression)
    (let [ [tag (get-tag expression)] ]
      (cond [(symbol=? tag 'Apply) (parse-apply expression)]
            [(symbol=? tag 'AttributeValue) (parse-attributeValue expression)]
            [(symbol=? tag 'SubjectAttributeDesignator) (parse-attributeDesignator 'Subject expression)]
            [(symbol=? tag 'ResourceAttributeDesignator) (parse-attributeDesignator 'Resource expression)]
            [(symbol=? tag 'ActionAttributeDesignator) (parse-attributeDesignator 'Action expression)]
            [(symbol=? tag 'EnvironmentAttributeDesignator) (parse-attributeDesignator 'Environment expression)]
            [else (errorf "Support Error: Does not support the ~a element are for Expressions" tag)])))
  
  (define (parse-apply apply)
    (ast:make-application (get-attribute 'FunctionId apply)
                          (map parse-expression (get-content apply))))
  
  
  ;(define (parse-expression-predicate expression)
  
  ;; .type (listof xexpr) -> (listof xexpr)
  ;; removes a description xexpr if at the front of the list
  (define (remove-description content) 
    (if (eq? (get-tag (first content)) 'Description)
        (rest content) ;; remove description since we don't use it.
        content))
  
  ;; .type (listof xexpr) -> (listof xexpr)
  ;; removes a obligations xexpr if at the end of the list.
  (define (remove-obligations content)
    (if (empty? (rest content))
        (if (symbol=? (get-tag (first content)) 'Obligations)
            (begin
              (printf "Support Warning: Obligations where discarded since Margrave does not handle obligations")
              '())
            content)
        (cons (first content) (remove-obligations (rest content)))))
  
  (define (subtarget-name->match-name subtarget-name)
    (cond [(symbol=? subtarget-name 'Subjects) 'Subject]
          [(symbol=? subtarget-name 'Resources) 'Resource]
          [(symbol=? subtarget-name 'Actions) 'Action]
          [(symbol=? subtarget-name 'Environments) 'Environment]
          [else (errorf 'subtarget-name-to-match-name "Unknown subtarget: ~a" subtarget-name)]))
  
  (define (make-sure-rule-in-order rule)
    (util:in-order? '(Description Target Condition)
                    (map get-tag (get-content rule))
                    (lambda (failed-on) 
                      (errorf "XACML Syntax Error: The elements of a rule are not in order or contains an illegel element.  The offending element is:~a." failed-on))))
  
  (define (make-sure-subtargets-in-order element-testing target)
    (util:in-order? '(Subjects Resources Actions Environments)
                    (map get-tag (get-content target))
                    (lambda (failed-on)
                      (errorf "XACML Syntax Error: The subtargets within a target of a ~a are out of order or contines illegel elements.  The offending element is: ~a." element-testing failed-on))))
  
  (define (parse-subtarget subtarget-name target)
    (let [ [subtarget (get-subxexpr subtarget-name target)] ]
      (if subtarget
          (let [ [content (get-content subtarget)] ]
            (if (empty? content) 
                (errorf "XACML Syntax Error: A ~a element was empty." subtarget-name)
                (map (lambda (match) 
                       (parse-ind-subtarget (subtarget-name->match-name subtarget-name) match))
                     content)))
          '(()) ))) ;returns the representation of True (i.e., that every request matches)
  
  
  
  ;; .type symbol (xexpr ind-subtarget) -> ast
  (define (parse-ind-subtarget ind-subtarget-name ind-subtarget)
    (if (symbol=? (get-tag ind-subtarget) ind-subtarget-name)
        (let [ [content (get-content ind-subtarget)] ]
          (if (empty? content)
              (errorf "XACML Sytax Error: A ~a element is empty.  It must contain at least one match element." ind-subtarget-name)
              (map (lambda (match) (parse-match ind-subtarget-name match)) content)))
        (errorf "XACML Sytax Error: A ~a element is needed.  Given a ~a element instead"  ind-subtarget-name (get-tag ind-subtarget))))
  
  
  ;; .type symbol (xexpr match) -> ast
  ;; MatchId is ignored
  (define (parse-match subtarget-name match)
    (if (symbol=? (get-tag match) (swindle:symbol-append subtarget-name 'Match))
        (let* [ [content (get-content match)]
                [length (length content)] ]
          (cond [(= length 2) (ast:make-match (parse-attributeDesignator subtarget-name (second content))
                                              (parse-attributeValue (first content)))]
                [(= length 0) (errorf 'parse-match "XACML Sytax Error: Empty match element found.")]
                [(= length 1) (errorf 'parse-match "XACML Sytax Error: Match element with only one element within it found.")]
                [else (errorf "XACML Sytax Error: Match element with more than two element within it found.")]))
        (errorf "XACML Sytax Error: A ~a element is needed.  Given a ~a element instead" (swindle:symbol-append subtarget-name 'Match) (get-tag match))))
  
  
  ;; .type symbol (xexpr match) -> ast:attribute
  ;; Does not handle the attributes DataType, Issuer, MustBePresent, or SubjectCategory (only found in SubjectAttributeDesignator).
  ;; takes subtarget name in the sigular
  (define (parse-attributeDesignator subtarget-name ad)
    (if (symbol=? (get-tag ad) (swindle:symbol-append subtarget-name 'AttributeDesignator))
        (ast:make-attribute subtarget-name
                            (string->symbol (get-attribute 'AttributeId ad)))
        (errorf "XACML Sytax Error: A ~a element is needed.  Given a ~a element instead." (swindle:symbol-append subtarget-name 'AttributeDesignator) (get-tag ad) )))
  
  ;; .type (xexpr AttributeValue) -> symbol
  ;; Does not handle non-string values
  (define (parse-attributeValue attrVal)
    (if (symbol=? (get-tag attrVal) 'AttributeValue)
        (ast:make-attributeValue (string->symbol (get-value attrVal)))
        (errorf "XACML Sytax Error: A AttributeValue element is needed.  Given a ~a element instead." (get-tag attrVal))))
  
  
  )