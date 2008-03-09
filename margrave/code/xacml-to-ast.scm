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
;(load-relative "tschantzUtil.scm")
;(load-relative "sxml-tools.scm")
;(load-relative "ast.scm")

(include "tschantzUtil.scm")
(include "sxml-tools.scm")
(include "ast.scm")

(module xacml-to-ast mzscheme  

  (require (prefix ast: ast) 
           sxml-tools
           (lib "etc.ss") 
           (lib "list.ss")
           (prefix util: tschantzUtil)) ;; for parsing; for local; for filter; for find-if
  
  (provide (all-defined))
  
  
  ;; The parser will remove white space from the content (e.g. <tag at="v">content</tag>, content is the content)
  ;; for any tag listed below.
  (define whitespace-does-not-matter  
    '(PolicySet Policy Target Subjects Subject SubjectMatch Resource Resources ResourceMatch Action Actions ActionMatch Rule Request Attribute))
  
  ;; string (file name) [path] [bool] -> ast
  ;; converts an xacml policy stored in one the above input types into a ast.
  (define xacml->ast
    (opt-lambda (xacml-file-name [path "./"] [verbose? #f])
      (let [ [ast (parse-compoundLaw (->xexpr xacml-file-name whitespace-does-not-matter) path verbose?)] ]
        (if verbose? (printf (ast:ast->string ast)))
        ast)))
          
  
  ;; .type ((xexpr PolicySet) | (xexpr Policy)) path bool -> ast
  (define (parse-compoundLaw xexpr path verbose?)
    (let [ [tag (get-tag xexpr)] ]
      (cond [(symbol=? tag 'PolicySet) (parse-policySet xexpr path verbose?)]
            [(symbol=? tag 'Policy) (parse-policy xexpr path verbose?)]
            [else (error 'parse-compoundLaw "A policy or policy set was needed.  Instead ~a was found." tag)])))

  ;; .type ((xexpr PolicySet) | (xexpr Policy) | (xexpr PolicySetIdReference) | (xexpr PolicyIdReference)) path bool -> ast
  (define (parse-compoundLaw-ref xexpr path verbose?)
    (let [ [tag (get-tag xexpr)] ]
      (cond [(symbol=? tag 'PolicySet) (parse-policySet xexpr path verbose?)]
            [(symbol=? tag 'Policy) (parse-policy xexpr path verbose?)]
            [(or (symbol=? tag 'PolicySetIdReference)
                 (symbol=? tag 'PolicyIdReference))
             (if verbose? (printf "loading ~a~n" (get-value xexpr)))
             (xacml->ast (string-append path (get-value xexpr) ".xml") path verbose?)]
            [else (error 'parse-compoundLaw-ref "A policy, policy set, or a reference to one of them was needed.  Instead ~a was found." tag)])))
         
  ;; .type (xexpr PolicySet) -> ast
  (define (parse-policySet policyset path verbose?)
    (if (empty? (get-content policyset))
        (error 'parse-policy "A PolicySet without a target was found")
    (let* [ [content (remove-obligations (remove-description (get-content policyset)))]
            [target (first content)] ]
      (if (symbol=? (get-tag target) 'Target)
          (ast:make-policySet (get-attribute 'PolicySetId policyset)
                              (parse-subjects target)
                              (parse-resources target)
                              (parse-actions target)
                              (get-attribute 'PolicyCombiningAlgId policyset)
                              (map (lambda (term) (parse-compoundLaw-ref term path verbose?))
                                   (rest content)))
          (if (symbol=? (get-tag target) 'PolicySetDefaults)
              (error 'parse-policySet "Support Error: PolicySetDefaults is not supported by Margrave.")
              (error 'parse-policySet "XACML Sytax Error: Target was not found where needed.  Instead ~a was found." (get-tag (first content))))))))

  ;; .type (xexpr Policy) -> ast
  (define (parse-policy policy path verbose?)
    (if (empty? (get-content policy))
        (error 'parse-policy "A Policy without a target was found")
        (let* [ [content (remove-obligations (remove-description (get-content policy)))]
                [target (first content)] ]
          (if (symbol=? (get-tag target) 'Target)
              (ast:make-policy (get-attribute 'PolicyId policy)
                               (parse-subjects target)
                               (parse-resources target)
                               (parse-actions target)
                               (get-attribute 'RuleCombiningAlgId policy)
                               (map (lambda (term) (parse-rule term path verbose?))
                                    (rest content)))
              (if (symbol=? (get-tag target) 'PolicyDefaults)
                  (error 'parse-policy "Support Error: PolicyDefaults is not supported by Margrave.")
                  (error 'parse-policy "XACML Sytax Error: Target was not found where needed.  Instead ~a was found." (get-tag (first content))))))))
  
  ;; .type (xexpr Rule) -> ast
  (define (parse-rule rule path verbose?)
    (if (symbol=? (get-tag rule) 'Rule)
        (let* [ [content (remove-description (get-content rule))]
                [target (first content)] ]
          (if (empty? (rest content))
              (ast:make-rule (get-attribute 'RuleId rule)
                             (parse-subjects target)
                             (parse-resources target)
                             (parse-actions target)
                             (string->symbol (get-attribute 'Effect rule)))
              (if (symbol=? (get-tag (second content)) 'Condition)
                  (error 'parse-rule "Support Error: Condition is not supported by Margrave.")
                  (error 'parse-rule "XACML Sytax Error: extra elements following target in rule."))))
        (error 'parse-rule "XACML Sytax Error: Rule was not found where needed.  Instead ~a was found." (get-tag rule))))

  
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
            '()
            content)
        (cons (first content) (remove-obligations (rest content)))))

  
  ;; .type (xexpr target) -> ast
  (define (parse-subjects target)
    (let [ [subjects (first (get-content target))] ]
      (if (symbol=? (get-tag subjects) 'Subjects)
          (let [ [content (get-content subjects)] ]
            (cond [(empty? content) (error 'parse-subjects "XACML Sytax Error: Subjects element was empty.")]
                  [(and (empty? (rest content)) (symbol=? (get-tag (first content)) 'AnySubject)) '(())]
                  [else (map (lambda (match) (parse-ind-subtarget 'Subject match)) content)]))
          (error 'parse-subjects "XACML Sytax Error: Subjects element was not found where needed.  Instead ~a was found." (get-tag subjects)))))

  
   ;; .type (xexpr target) -> ast
  (define (parse-resources target)
    (let [ [resources (second (get-content target))] ]
      (if (symbol=? (get-tag resources) 'Resources)
          (let [ [content (get-content resources)] ]
            (cond [(empty? content) (error 'parse-resources "XACML Sytax Error: Resources element was empty.")]
                  [(and (empty? (rest content)) (symbol=? (get-tag (first content)) 'AnyResource)) '(())]
                  [else (map (lambda (match) (parse-ind-subtarget 'Resource match)) content)]))
          (error 'parse-resources "XACML Sytax Error: Resources element was not found where needed.  Instead ~a was found." (get-tag resources)))))

   ;; .type (xexpr target) -> ast
  (define (parse-actions target)
    (let [ [actions (third (get-content target))] ]
      (if (symbol=? (get-tag actions) 'Actions)
          (let [ [content (get-content actions)] ]
            (cond [(empty? content) (error 'parse-actions "XACML Sytax Error: Actions element was empty.")]
                  [(and (empty? (rest content)) (symbol=? (get-tag (first content)) 'AnyAction)) '(())]
                  [else (map (lambda (match) (parse-ind-subtarget 'Action match)) content)]))
          (error 'parse-actions "XACML Sytax Error: Actions element was not found where needed.  Instead ~a was found." (get-tag actions)))))

  
      
  ;; .type symbol (xexpr ind-subtarget) -> ast
  (define (parse-ind-subtarget ind-subtarget-name ind-subtarget)
    (if (symbol=? (get-tag ind-subtarget) ind-subtarget-name)
        (let [ [content (get-content ind-subtarget)] ]
          (if (empty? content)
              (error 'parse-ind-subtarget "XACML Sytax Error: ~a element is empty.  It must contain at lease one match element." ind-subtarget-name)
              (map (lambda (match) (parse-match ind-subtarget-name match)) content)))
        (error 'parse-ind-subtarget "XACML Sytax Error: A ~a element is needed.  Given a ~a element instead" ind-subtarget-name (get-tag ind-subtarget))))
    

  ;; .type symbol (xexpr match) -> ast
  ;; MatchId is ignored
  (define (parse-match subtarget-name match)
    (if (symbol=? (get-tag match) (util:symbol-append subtarget-name 'Match))
        (let* [ [content (get-content match)]
                [length (length content)] ]
          (cond [(= length 2) (ast:make-match subtarget-name 
                                              (parse-attributeDesignator subtarget-name (second content))
                                              (parse-attributeValue (first content)))]
                [(= length 0) (error 'parse-match "XACML Sytax Error: Empty match element found.")]
                [(= length 1) (error 'parse-match "XACML Sytax Error: Match element with only one element within it found.")]
                [else (error 'parse-match "XACML Sytax Error: Match element with more than two element within it found.")]))
        (error 'parse-match 
               "XACML Sytax Error: A ~a element is needed.  Given a ~a element instead" 
               (util:symbol-append subtarget-name 'Match) 
               (get-tag match))))
  
  ;; .type (xexpr AttributeValue) -> symbol
  ;; Does not handle non-string values
  (define (parse-attributeValue attrVal)
    (if (symbol=? (get-tag attrVal) 'AttributeValue)
        (string->symbol (get-value attrVal))
        (error 'parse-attributeValue "XACML Sytax Error: A AttributeValue element is needed.  Given a ~a element instead" (get-tag attrVal))))
  
  ;; .type symbol (xexpr match) -> symbol
  ;; Does not handle the attributes DataType, Issuer, MustBePresent, or SubjectCategory (only found in SubjectAttributeDesignator).
  (define (parse-attributeDesignator subtarget-name ad)
    (if (symbol=? (get-tag ad) (util:symbol-append subtarget-name 'AttributeDesignator))
        (string->symbol (get-attribute 'AttributeId ad))
        (error 'parse-attributeDesignator
               "XACML Sytax Error: A ~a element is needed.  Given a ~a element instead" 
               (util:symbol-append subtarget-name 'AttributeDesignator) 
               (get-tag ad))))
  
  
  )
