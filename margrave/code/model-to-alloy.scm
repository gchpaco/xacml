;; model-to-alloy.scm
;;
;; Functions to print an alloy representation of structs created by
;; xacml-to-model.scm's build-policy function.
;; See model-structs.scm for definitions of the relevant structs.
;; In comments, model-struct:policy-model will be referred to as policy-model,
;; model-struct:subject will be subject, etc.

(include "ast.scm")

(module ast-to-alloy mzscheme
  
  (provide ast->alloy)
  (require (prefix ast: ast)
           (lib "list.ss")
           (lib "etc.ss"))
  
  (define out (current-input-port))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; general utils
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; output: string -> void
  ;; Prints formatted string to file.  "out" is defined in whatever file calls
  ;; print-policy-model (e.g. fractured.scm) 
  (define (output str)
    (fprintf out str)
    (fprintf out "~n")) 
  
  ;; output: string -> void
  ;; Prints formatted string to standard out or interpreter window.  Used for debugging.
  ;(define (output str)
  ;  (printf str)
  ;  (printf "~n"))
  
  ;; delete-duplicates: listof a -> listof a
  ;; Given a list, returns a list of the same elements but without repetition.
  ;; Uses "member", which uses "equal?" for element comparison
  (define (delete-duplicates s)
    (cond ( (empty? s) s)
          (else (cond ( (member (car s) (cdr s)) (delete-duplicates (cdr s)))
                      (else (cons (car s) (delete-duplicates (cdr s))))))))
  
  ;; lst->string: listof String -> String
  ;; Returns a string of words, where each word is an element of the input list 
  (define (lst->string lst)
    (cond ( (empty? lst) "")
          (else (string-append (car lst) (lst->string (cdr lst))))))
  
  ;; elements->list-string: String listof String -> String 
  ;; Returns a string of words, where each word is an element of lst
  ;; 	and the words are divided by punc
  ;; For example, (elements->list-string ", " '("1" "2" "3")) returns 
  ;; 	"1, 2, 3"
  (define (elements->list-string punc lst) 
    (cond ( (empty? lst) "")
          (else
           (let ( (punc-strings (cons (car lst) 
                                      (map (lambda (x) (string-append punc x)) (cdr lst)))))
             (lst->string punc-strings)))))
  
  ;; breaker to make alloy models a bit more readable
  (define breaker "~n--...............................................~n")
  
  (define (vspace) (output ""))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; printing functions 
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;; ast * [string | port] ->
  ;; If no second argument is supplied, the current-output-port is used.
  (define ast->alloy 
    (opt-lambda (ast [output (current-output-port)])
      (cond [(string? output) (ast->alloy ast (open-output-file output))]
            [(port? output) (begin
                              (set! out output)
                              (print-policy-model ast))])))
  
  ;; print-policy-model: policy-model -> void
  ;; Calls print functions on the various parts of a policy model
  (define (print-policy-model pm)
    (print-module pm)
    (print-sigs pm)
    (output breaker)
    (print-facts pm)
    (output breaker)
    ; (print-funs pm)
    (output breaker))
  
  ;; print-module: policy-model -> void
  ;; Prints the first line of an alloy policy
  (define (print-module pm)
    (output (string-append "module " (ast:policy-name pm)))
    (output ""))
  
  ;; print-sigs: policy-model -> void
  ;; prints alloy lines defining various signatures
  (define (print-sigs pm)
    (print-subject-sigs pm)
    (print-resource-sigs pm)
    (print-action-sigs pm)
    (print-number-sigs pm)
    (print-rule-sigs pm)
    (print-person-sigs pm))
  
  ;; print-subject-sigs: policy-model -> void
  ;; prints the Subject signature lines
  (define (print-subject-sigs pm)
    (let ( (sl (ast:policy-subjects pm)))
      (output "sig Subject{}")
      (let ( (values (values->list-string subject-AttributeValue sl)))
        (output (string-append "static part sig " values " extends Subject{}~n"))))) 
  
  ;; print-resource-sigs: policy-model -> void
  ;; prints the Resource signature lines
  (define (print-resource-sigs pm)
    (let ( (sl (policy-model-resources-list pm)))
      (output "sig Resource{}")
      (let ( (values (values->list-string resource-AttributeValue sl)))
        (output (string-append "static part sig " values " extends Resource{}~n")))))
  
  ;; print-action-sigs: policy-model -> void      
  ;; prints the Action signature lines
  (define (print-action-sigs pm)
    (let ( (sl (policy-model-actions-list pm)))
      (output "sig Action{}")
      (let ( (values (values->list-string action-AttributeValue sl)))
        (output (string-append "static part sig " values " extends Action{}~n")))))
  
  ;; values->list-string: (sra -> String) listof sra -> String 
  ;; sra stands for subject|resource|action
  ;; Returns a string representing all sra AttributeValues in the policy
  (define (values->list-string proc lst)
    (elements->list-string ", " (delete-duplicates (map proc lst))))
  
  ;; types->list-string: (sra -> String) listof sra -> String
  ;; sra stands for subject|resource|action
  ;; Returns a string representing all sra AttributeDesignators in the policy
  (define (types->list-string proc lst)
    (elements->list-string ", " (delete-duplicates (map proc lst))))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; number functions
  ;; these deal with faking a number system in alloy
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;; gen-num-string: Int -> String
  ;; Returns a string of the form "s1, s2, ..., sN" where N is max.
  (define (gen-num-string max)
    (cond ( (= max 0) "")
          ( (= max 1) (string-append "s" (number->string max)))
          (else
           (string-append (gen-num-string (sub1 max)) ", s" (number->string max)))))
  
  ;; print-pred-facts: Int -> void
  ;; prints number precedence facts for all sN where N <= max
  (define (print-pred-facts max)
    (cond ( (= max 1) (output "fact {s1.pred = none[Number]}") )
          ( (> max 1) 
            (print-pred-facts (sub1 max))
            (let ( (x (number->string max)) (w (number->string (sub1 max))))
              (output (string-append "fact {s" x ".pred = s" w " + s" w ".pred}"))))))
  
  ;; print-number-sigs: policy-model -> void
  ;; prints Number signatures
  (define (print-number-sigs pm)
    (output "sig Number{pred: set Number}")
    (output (string-append "part sig "
                           (gen-num-string (length (policy-model-rules-list pm)))
                           " extends Number{}~n")))
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;; print-rule-sigs: policy-model -> void
  ;; prints Rule signatures  
  (define (print-rule-sigs pm) 
    (output "sig Rule{subjects: set Subject, resources: set Resource, actions: set Action, number:Number, effect: Effect}~n")
    (output "sig Effect{}")
    (output "static part sig Permit, Deny extends Effect{}~n"))
  
  ;; print-person-sigs; policy-model -> void
  ;; prints Person signatures
  (define (print-person-sigs pm)
    (output "sig Person{identities: set Subject}~n"))
  
  ;; print-facts: policy-model -> void
  ;; prints whatever facts we've hardcoded (see below)
  (define (print-facts pm)
    (print-number-facts pm)
    (output breaker)
    (print-general-facts pm)
    (output breaker)
    (print-rule-facts pm))
  
  ;; print-number-facts: policy-model -> void
  ;; prints some hardcoded facts about numbers
  (define (print-number-facts pm)
    (print-pred-facts (length (policy-model-rules-list pm)))
    (output "")
    (output "fun num_before( before_m:Number, before_n:Number) {before_m in before_n.pred}")
    )
  
  ;; print-general-facts: policy-model -> void
  ;; prints hardcoded facts 
  (define (print-general-facts pm)
    (output "fun before(bRule1:Rule, bRule2:Rule) 
                {num_before(bRule1.number, bRule2.number)}")
    (vspace)
    (output "-- no two rules can have the same number")
    (output "fact rule_uniqueness 
                 {all ru_rule1:Rule | no ru_rule2:Rule-ru_rule1 | ru_rule2.number = ru_rule1.number}")
    (vspace)
    (output "fun subjectOfRule(subject:Subject, rule:Rule)
        {some x:Subject | x in subject && x in rule.subjects}")
    (output "fun subjectOfPerson(subject:Subject, person:Person)
        {some y:Subject | y in subject && y in person.identities}")
    (output "fun resourceOfRule(resource:Resource, rule:Rule)
        {some z:Resource | z in resource && z in rule.resources}")
    (output "fun actionOfRule(role:Action, rule:Rule)
        {some w:Action | w in role && w in rule.actions}")
    (output breaker)
    (output "fun Performable(p:Person, res:Resource, act:Action)
        {some r:Rule |  r.effect = Permit &&
                        resourceOfRule(res, r) &&
                        actionOfRule(act, r) &&
                        (some sub:Subject | sub in r.subjects && sub in p.identities)}")
    (vspace)
    (output "fun PerformableWithOrder(p:Person, res:Resource, act:Action)
        {some rule1:Rule |  rule1.effect = Permit &&
                            resourceOfRule(res, rule1) &&
                            actionOfRule(act, rule1) &&
                            (some sub:Subject | sub in rule1.subjects && sub in p.identities) &&
                            (all rule2:Rule-rule1 | ( resourceOfRule(res, rule2) && 
                                                      actionOfRule(act, rule2) &&
                                                      (some sub2:Subject | sub2 in rule2.subjects && sub2 in p.identities) ) =>
                                                    before(rule1, rule2) ) }")
    (vspace)
    (output "fun NotPerformable(p:Person, res:Resource, act:Action)
        {some r:Rule |  r.effect = Deny && 
                        resourceOfRule(res, r) &&
                        actionOfRule(act, r) &&
                        (some sub:Subject | sub in r.subjects && sub in p.identities)}")
    (vspace)
    (output "fun NotPerformableWithOrder(p:Person, res:Resource, act:Action)
        {some rule1:Rule |  rule1.effect = Deny &&
                            resourceOfRule(res, rule1) &&
                            actionOfRule(act, rule1) &&
                            (some sub:Subject | sub in rule1.subjects && sub in p.identities) &&
                            (all rule2:Rule-rule1 | ( resourceOfRule(res, rule2) && 
                                                      actionOfRule(act, rule2) &&
                                                      (some sub2:Subject | sub2 in rule2.subjects && sub2 in p.identities) ) =>
                                                    before(rule1, rule2) ) }")
    )
  
  ;; make-rule-name: Int -> String
  ;; e.g. 7 -> "R7"
  (define (make-rule-name num)
    (string-append "R" (number->string num)))
  
  ;; make-rule-num: Int -> String
  ;; e.g. 6 -> "s6"
  (define (make-rule-num num)
    (string-append "s" (number->string num)))
  
  ;; print-rule-facts:policy-model -> void
  ;; prints facts about rules (calls print-rule-fact on 
  ;; each rule in the policy-model)
  (define (print-rule-facts pm)
    (let ( (rules (policy-model-rules-list pm))
           (rule-count 1))
      (letrec ( (print-rule-facts-h 
                 (lambda (rules count)
                   (cond ( (not (empty? rules))
                           (print-rule-fact (car rules) count)
                           (print-rule-facts-h (cdr rules) (add1 count)))))))
        (print-rule-facts-h rules rule-count))))
  
  ;; print-rule-fact: rule-model Int -> void    
  ;; prints a fact for a rule.
  (define (print-rule-fact rule count)
    (let* ( (name (make-rule-name count))
            (num (make-rule-num count))
            (sub (get-rule-subject-reqs rule name))
            (res (get-rule-resource-reqs rule name))
            (act (get-rule-action-reqs rule name)))
      (output (string-append 
               "fact {some " name ":Rule | ~n"
               (cond ( (not (equal? "" sub))
                       (string-append
                        "                      " sub))
                     (else (string-append 
                            "                      " name ".subjects = Subject && ~n")))
               (cond ( (not (equal? "" res))
                       (string-append
                        "                      " res))
                     (else (string-append
                            "                      " name ".resources = Resource && ~n")))
               (cond ( (not (equal? "" act))
                       (string-append
                        "                      " act))
                     (else (string-append
                            "                      " name ".actions = Action && ~n")))
               "                      " name ".number = " num " && ~n"
               "                      " name ".effect = " (rule-model-effect rule) "}"
               breaker))))
  
  
  
  ;;-------- subjects
  
  ;; get-rule-subject-reqs: rule-model String -> String
  ;; returns a string to be used in a rule fact
  (define (get-rule-subject-reqs rule name)
    (let ( (subjects (map subject-AttributeValue (rule-model-subjects-list rule))))
      (cond ( (empty? subjects) "")
            (else (let ( (formatted-subjects (elements->list-string " + " subjects)))
                    (string-append name ".subjects = " formatted-subjects " && ~n"))))))
  
  ;; subject-elt-req->string: String String -> String
  ;; returns a string to be used in a rule fact
  (define (subject-elt-req->string value name)
    (string-append "subjectOfRule(" value ", " name ") "))
  
  
  ;;-------- resources
  
  ;; get-rule-resource-reqs rule-model String -> String
  ;; returns a string to be used in a rule fact
  (define (get-rule-resource-reqs rule name)
    (let ( (resources (map resource-AttributeValue (rule-model-resources-list rule))))
      (cond ( (empty? resources) "")
            (else (let ( (formatted-resources (elements->list-string " + " resources)))
                    (string-append name ".resources = " formatted-resources " && ~n"))))))
  
  ;; resource-elt-req->string: String String -> String
  ;; returns a string to be used in a rule fact
  (define (resource-elt-req->string value name)
    (string-append "resourceOfRule("value", "name") ")) 
  
  
  ;;-------- actions
  
  ;; get-rule-action-reqs: rule-model String -> String
  ;; returns a string to be used in a rule fact
  (define (get-rule-action-reqs rule name)
    (let ( (actions (map action-AttributeValue (rule-model-actions-list rule))))
      (cond ( (empty? actions) "")
            (else (let ( (formatted-actions (elements->list-string " + " actions)))
                    (string-append name ".actions = " formatted-actions " && ~n"))))))
  
  ;; action-elt-req->string: String String -> String
  ;; returns a string to be used in a rule fact
  (define (action-elt-req->string value name)
    (string-append "actionOfRule("value", "name") "))
  
  
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; tests
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(define m (build-policy sxml-policy))
;(define rules (policy-model-rules-list m))
;(print-subject-sigs m)
;(print-facts m)
;(print-policy-model m)
;(print-policy-model (build-policy sxml-policy))

