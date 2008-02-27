;; This module just makes the xacml-base-withVis module more usable by hiding most of the state
;; from the user.  To acheive this requires the rather odd clear-memory function.
;; This module might some day become a class or unit.
;(include "cudd-import/xacml-base-with-vis.ss")
(module add mzscheme
  
  (provide (all-defined))
    
  (require (lib "list.ss")
           "cudd-import/xacml-base-with-vis.ss")
      
  (define decision-symbols (list 'P 'D 'N 'E))
  
  (define change-symbols (list 'PP 'PD 'PN 'PE 'DP 'DD 'DN 'DE 'NP 'ND 'NN 'NE 'EP 'ED 'EN 'EE))
  
  (define (sym-const->add-const term)
    (cond [(eq? term 'P) PERMIT_VAL]
          [(eq? term 'D) DENY_VAL]
          [(eq? term 'N) NA_VAL]
          [(eq? term 'E) EC_VAL]
          [(eq? term 'PP) PP_VAL]
          [(eq? term 'PD) PD_VAL]
          [(eq? term 'PN) PN_VAL]
          [(eq? term 'PE) PE_VAL]
          [(eq? term 'DP) DP_VAL]
          [(eq? term 'DD) DD_VAL]
          [(eq? term 'DN) DN_VAL]
          [(eq? term 'DE) DE_VAL]
          [(eq? term 'NP) NP_VAL]
          [(eq? term 'ND) ND_VAL]
          [(eq? term 'NN) NN_VAL]
          [(eq? term 'NE) NE_VAL]
          [(eq? term 'EP) EP_VAL]
          [(eq? term 'ED) ED_VAL]
          [(eq? term 'EN) EN_VAL]
          [(eq? term 'EE) EE_VAL]                          
          [else (error 'sym-const->add-const "Unrecongized term: ~a" term)]))
  
  ;;;;;;;;;;;;;;;;;;;;
  
  (define dd-manager 'temp)
  ;;;;;;
  ;;; Constants (w.r.t the dd-manager)
  ;;;;;;
  
  ;; The BDD for the false (0) constant  
  (define (badd-false)
    (xacml-false dd-manager))
  
  ;; The BDD for the true (1) constant
  (define (badd-true)
    (xacml-true dd-manager))  
  
  ;; The XADD for the permit constant
  (define (permit-term)
    (xacml-permit dd-manager))
  
  ;; The XADD for the deny constant
  (define (deny-term)
    (xacml-deny dd-manager))


  ;; The XADD for the not applicable constant
  (define (na-term)
    (xacml-na dd-manager))
  
  ;; The XADD for the excluded by contraint constant
  (define (ec-term)
    (xacml-ec dd-manager))
  
  (define (clear-memory)
    (set! dd-manager (make-dd-manager)))
  
  (clear-memory)
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  (define (new-var)
    (xacml-new-var dd-manager))
  
  ;;  - xacml-and : 0-1-ADD 0-1-ADD manager -> 0-1-ADD
  ;;    Logical and on 0-1-ADDs
  (define (badd-and l r)
    (xacml-and dd-manager l r))
  
  ;;
  ;;  - xacml-or : 0-1-ADD 0-1-ADD manager -> 0-1-ADD
  ;;    Logical or on 0-1-ADDs
  (define (badd-or l r)
    (xacml-or dd-manager l r))
  
  ;;
  ;;  - xacml-not : 0-1-ADD manager -> 0-1-ADD
  ;;    Logical negation of 0-1-ADD
  (define (badd-not bdd)
    (xacml-not dd-manager bdd))
  
  
  
  ;;  - xacml-augment-rule : 0-1-ADD XADD manager -> XADD
  ;;    The first argument is a logical expression on variables forming
  ;;    conditions on a rule.  The second argument is an existing rule
  ;;    (could be permit/deny/na in the simplest case).  Returns an XADD
  ;;    for the rule augmented with the given conditions.
  ;;  
  (define (augment-rule target body)
    (xacml-augment-rule dd-manager target body))
  
  
  
  ;;  - combine-permit-override : XADD XADD manager -> XADD
  ;;    Combines two XADDs into a policy using permit-override.  The first
  ;;    XADD will override the second if no permit occurs.
  ;;
  (define (build-permit-override child-list)
    (cond [(empty? child-list) (na-term)]
          [(empty? (cdr child-list)) (car child-list)]
          [else (let [[temp (build-permit-override (cdr child-list))]]
                  (combine-permit-override dd-manager
                                           temp
                                           (car child-list)))]))
  
  ;;  - combine-deny-override : XADD XADD manager -> XADD
  ;;    Combines two XADDs into a policy using deny-override.  The first
  ;;    XADD will override the second if no deny occurs.
  ;;
  (define (build-deny-override child-list)
    (cond [(empty? child-list) (na-term)]
          [(empty? (cdr child-list)) (car child-list)]
          [else (combine-deny-override dd-manager
                                       (car child-list)
                                       (build-deny-override (cdr child-list)))]))
  
  
  
  ;;  - combine-first-applicable : XADD XADD manager -> XADD
  ;;    Combines two XADDs into a policy using first-applicable.  The first
  ;;    XADD applies before the second.
  ;;
  (define (build-first-applicable child-list)
    (cond [(empty? child-list) (na-term)]
          [(empty? (cdr child-list)) (car child-list)]
          [else (combine-first-applicable dd-manager
                                          (car child-list)
                                          (build-first-applicable (cdr child-list)))]))
  
  (define (add-equal? l r)
    (xacml-equal? l r))
  
  
  ;; cudd-add-constrain : add 0-1add manager -> add
  ;; Not for general use, use constrain-add instead
  ;; unless you really know what you are doing.
  (define (cudd-constrain-add bdd add)
    (cudd-add-constrain dd-manager add bdd))
  
  ;;   - xadd-assume : XADD 0-1ADD manager -> XADD
  ;;    restricts XADD to the condition given in the 0-1ADD, sending cases
  ;;    that don't match condition to not-applicable
  (define (assume-xadd bdd xadd)
    (xadd-assume dd-manager xadd bdd))
  
  ;; XADD -> BDD
  ; - restrict-to-permit : XADD manager -> 0-1ADD
  ;    returns 0-1ADD where permit cases map to 1 and all others to 0
  ;(define (xadd-restrict-to-permit add)
  ;  (restrict-to-permit add dd-manager))
  
  ;; XADD -> BDD
  ; restrict-to-deny : XADD manager -> 0-1ADD
  ; returns 0-1ADD where deny cases map to 1 and all others to 0
  ;(define (xadd-restrict-to-deny add)
  ;  (restrict-to-deny add dd-manager))
  
  ;; XADD -> BDD
  ;(define (xadd-restrict-to-na add)
  ;  (xadd-restrict-to-na add dd-manager))
  
  ;;   - xacml-change-merge : XADD XADD manager -> CADD
  ;;    produces CADD showing merged results of given policies in order
  (define (compare-xadds policy1 policy2)
    (xacml-change-merge dd-manager policy1 policy2))
  
  
  
  ;; ADD term -> BDD
  (define (add-restrict-to add term)
    (restrict-to dd-manager add (sym-const->add-const term)))
  
  
  ;; xadd -> list[var]
  ;(define (get-present-vars add)
  ; (error 'not-done))
  
  
  ;; bdd -> list[bool]
  ;; returns a list of bool in the same order as the vars are created
  ;; (i.e. first made first listed) where a #t means that that var
  ;; is always false and a #f means otherwise.
  (define (get-always-false bdd)
    (always-false-vars dd-manager bdd))
  
  (define (get-always-true bdd)
    (always-true-vars dd-manager bdd))
  
  (define (get-always-dc bdd)
    (always-dc-vars dd-manager bdd))
  
  ;;> Could you write a function that takes an XADD and combines the Not
  ;;> Applicable and Deny terminal into one Deny terminal to produce an ADD with
  ;;> only Permit and Deny terminals?  Ask Shriram about viewing output for why
  ;;> we want to do this.
  (define (na-to-deny xadd)
    (xadd-na-to-deny dd-manager xadd))
  
  
  (define (add->rawDnf policy)
    (add-to-rawDnf dd-manager policy))
  
  
  ;;  - xacml-print : ADD manager -> true
  ;;    prints a condensed truth table showing the contents of an ADD.
  ;;    The columns follow the order of the variables from left to right.
  ;;    In a column, 0 means false, 1 means true, and - means that the
  ;;    value of the variable is irrelevant (either value satisfies the
  ;;    row).  The output is in the far right column.  0 reflects logical
  ;;    false, 1 reflects logical true and XACML constants are as they
  ;;    appear. 
  ;;
  ;;    Note that this function uses a temporary intermediate file.
  ;;
  (define (print-xadd xadd)
    ;(display "XADD")(newline)
    ;(display (track:->string))
    ;(newline)
    (display "{")(newline)
    (xacml-print dd-manager xadd)
    (display "}")(newline))
  
  ;;- xacml-change-print : CADD mgr -> void
  ;; like-xacml-print, but prints CADDs instead of ADDs 
  (define (print-cadd cadd)
    ;(display "CADD")(newline)
    ;(display (track:->string))
    ;(newline)
    (display "{")(newline)
    (xacml-change-print dd-manager cadd)
    (display "}")(newline))
  
  
  (define (print-cadd-changes cadd)
    ;(display "CADD Changes")(newline)
    ;(display (track:->string))
    ;(newline)
    (display "{")(newline)
    (xacml-change-only-print dd-manager cadd)
    (display "}")(newline))
  
  (define (print-add-memory-use add)
    (printf "Memory Usage:~n")
    (printf " Total memory usage: ~a bytes.~n" (total-memory-use dd-manager))
    (printf " Total number of vars: ~a.~n" (total-number-of-vars dd-manager))
    (printf " Number of nodes in given add: ~a.~n~n" (add-size add)))
  
  )