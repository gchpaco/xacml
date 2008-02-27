;;
;; provides a restricted ADD (RADD) implementation.
;;
;; One can view a ADD as a representation of a set of vectors of 0s and 1s.
;; That is, a ADD is an element of the set P({0, 1}^*) (the set of sets of
;; vectors of 0s and 1s) where P is the power set operator and S^* is the
;; set of vectors (or strings or sequences) of elements from S.
;; 
;; Due to the way the ADD module is implemented, all the ADDs from this
;; module may be viewed as a set of 0-1 vectors of some set length n.
;; That is, it is an element of the set P({0, 1}^n) where S^n is hte 
;; set of vectors of length n with entries drawn from S.
;;
;; The RADD package provides a way to further limit the set from which
;; ADDs are drawn.  That is, all RADDs are elements of U = P(S) where 
;; S is a subset of {0, 1}^n.
;;

;; ADDs with a restricted universe

(module radd mzscheme
  
  (provide (all-defined))
  
  ;(require-for-syntax (prefix addd: add)) ;; breaks things since it uses the old fake bindings instead of the real loaded ones.
  
  (require (prefix add: "add.scm"))

  ;;;;
  ;;; the universe
  ;;;;
  (define universe-bdd 'temp) ;; will be set by clear-memory
  
  (define (get-universe)
    universe-bdd)
  
  (define (set-universe! bdd)
    (set! universe-bdd bdd))
  

  
  
  ;; resets the universe to true and clears all nodes from the manger
  (define (clear-memory)
    (add:clear-memory)
    (set! universe-bdd (add:badd-true)))
      
  (clear-memory)
  
  ;;;;;;
  ;;; Constants
  ;;;;;;
  
  ;; The BDD for the false (0) constant
  (define badd-false add:badd-false)
  
  ;; The BDD for the true (1) constant
  (define badd-true add:badd-true)  
  
  
  ;; The XADD for the permit constant
  (define permit-term add:permit-term)
  
  ;; The XADD for the deny constant
  (define deny-term add:deny-term)
  
  ;; The XADD for the not applicable constant
  (define na-term add:na-term)
  
  
;  ;;  - xacml-new-var : manager -> 0-1-ADD
;  ;;    returns 0-1-ADD for a new variable.  The order in which you create
;  ;;    vars determines the variable ordering in the ADD.  Note that the
;  ;;    package will not associate names with variables -- you need to do
;  ;;    that in your scheme code.
;  (define get-match-var 
;    (case-lambda
;      [(match)
;       (add:bdd-and (add:get-match-var match) universe-bdd)]
;      [(subtarget attrId attrValue)
;       (add:bdd-and (add:get-match-var subtarget attrId attrValue) universe-bdd)]))
;  
;  (define make-match-var 
;    (case-lambda
;      [(match)
;       (add:bdd-and (add:make-match-var match) universe-bdd)]
;      [(subtarget attrId attrValue)
;       (add:bdd-and (add:make-match-var subtarget attrId attrValue) universe-bdd)]))
;  
;  ;; Same as get-match-var but rather for a varible for an equality statement.
;  ;; (i.e. an overlap predicate in a conditional statement)
;  (define get-equality-var 
;    (case-lambda
;      [(equality)
;       (add:bdd-and (add:get-equality-var equality) universe-bdd)]
;      [(lSubtarget lAttrId rSubtarget rAttrId)
;       (add:bdd-and (add:get-equality-var lSubtarget lAttrId rSubtarget rAttrId) universe-bdd)]))
;  
;  (define make-equality-var 
;    (case-lambda
;      [(equality)
;       (add:bdd-and (add:make-equality-var equality) universe-bdd)]
;      [(lSubtarget lAttrId rSubtarget rAttrId)
;       (add:bdd-and (add:make-equality-var lSubtarget lAttrId rSubtarget rAttrId) universe-bdd)]))
;  
  
  
  ;; returns a BADD holding all elements of the universe such that a new-var is true.
  (define (new-var-add)
    (add:badd-and universe-bdd (add:new-var)))
    ;(add:assume-xadd universe-bdd (add:new-var)))
                 
  
  ;;;;
  ;; radd operations
  ;;
  
  (define (add-equal? l r)
    (add:add-equal? l r))
  
  (define cudd-constrain-add add:cudd-constrain-add)
  ;;
  ;; BDD operations
  ;;
  
  ;;  - xacml-and : 0-1-ADD 0-1-ADD manager -> 0-1-ADD
  ;;    Logical and on 0-1-ADDs
  (define (badd-and l r)
    (add:badd-and (add:badd-and l r) universe-bdd))
  
  ;;
  ;;  - xacml-or : 0-1-ADD 0-1-ADD manager -> 0-1-ADD
  ;;    Logical or on 0-1-ADDs
  (define (badd-or l r)
    (add:badd-and (add:badd-or l r) universe-bdd))
  
  ;;
  ;;  - xacml-not : 0-1-ADD manager -> 0-1-ADD
  ;;    Logical negation of 0-1-ADD
  (define (badd-not bdd)
    (add:badd-and (add:badd-not bdd) universe-bdd))
  
  
  ;;
  ;; XADD operations
  ;;
  
  ;;  - xacml-augment-rule : 0-1-ADD XADD manager -> XADD
  ;;    The first argument is a logical expression on variables forming
  ;;    conditions on a rule.  The second argument is an existing rule
  ;;    (could be permit/deny/na in the simplest case).  Returns an XADD
  ;;    for the rule augmented with the given conditions.
  ;;  
  (define (augment-rule target body)
    (add:assume-xadd universe-bdd (add:augment-rule target body)))
  
  
  
  ;;  - combine-permit-override : XADD XADD manager -> XADD
  ;;    Combines two XADDs into a policy using permit-override.  The first
  ;;    XADD will override the second if no permit occurs.
  ;;
  (define (build-permit-override child-list)
    (add:assume-xadd universe-bdd (add:build-permit-override child-list)))
  
  ;;  - combine-deny-override : XADD XADD manager -> XADD
  ;;    Combines two XADDs into a policy using deny-override.  The first
  ;;    XADD will override the second if no deny occurs.
  ;;
  (define (build-deny-override child-list)
    (add:assume-xadd universe-bdd (add:build-deny-override child-list)))
  
  
  
  ;;  - combine-first-applicable : XADD XADD manager -> XADD
  ;;    Combines two XADDs into a policy using first-applicable.  The first
  ;;    XADD applies before the second.
  ;;
  (define (build-first-applicable child-list)
    (add:assume-xadd universe-bdd (add:build-first-applicable child-list)))
  
  ;; cudd-add-constrain : add 0-1add manager -> add
  ;; Not for general use, use constrain-add instead
  ;; unless you really know what you are doing.
  ;;(define (cudd-constrain-add bdd add)
  ;;  (cudd-add-constrain add bdd dd-manager))
  
  ;;   - xadd-assume : XADD 0-1ADD manager -> XADD
  ;;    restricts XADD to the condition given in the 0-1ADD, sending cases
  ;;    that don't match condition to EC
  (define (assume-xadd bdd xadd)
    (add:assume-xadd universe-bdd (add:assume-xadd bdd xadd)))
  
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
    (add:compare-xadds policy1 policy2))
    
  
  
  
  ;; ADD term -> BDD
  (define (add-restrict-to add term)
    (add:badd-and (add:add-restrict-to add term) universe-bdd))
  
  
  ;; bdd -> list[bool]
  ;; returns a list of bool in the same order as the vars are created
  ;; (i.e. first made first listed) where a #t means that that var
  ;; is always false and a #f means otherwise.
  (define (get-always-false bdd)
    (add:get-always-false bdd))
    
  
  (define (get-always-true bdd)
    (add:get-always-true bdd))

  
  (define (get-always-dc bdd)
    (add:get-always-dc bdd))
    
  
  ;;> Could you write a function that takes an XADD and combines the Not
  ;;> Applicable and Deny terminal into one Deny terminal to produce an ADD with
  ;;> only Permit and Deny terminals?  Ask Shriram about viewing output for why
  ;;> we want to do this.
  (define (na-to-deny xadd)
    (add:na-to-deny xadd))
  
  
  (define (add->rawDnf policy)
    (add:add->rawDnf policy))
    
  
  
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
    ;(display "R")
    (add:print-xadd xadd))

  
  ;;- xacml-change-print : CADD mgr -> void
  ;; like-xacml-print, but prints CADDs instead of ADDs 
  (define (print-cadd cadd)
    ;(display "R")
    (add:print-cadd cadd))
    
  
  
  (define (print-cadd-changes cadd)
    ;(display "R")
    (add:print-cadd-changes cadd))
    
  
  (define (print-radd-memory-use add)
    (add:print-add-memory-use add))
  
  )