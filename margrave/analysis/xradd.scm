;; uses the RADD module to provide an ADD module
;; customized for XACML anaysis.  It provides ways
;; of mapping XACML constructs to ADD varblies.
;; Provides a way to map matches (subtarget, attrId, attrValues) and 
;; equalities (subtarget, attrId, subtarget, attrId) to nodes of the MTBDD
;; and the other way around.
(module xradd mzscheme
  
  (require "../add/radd.scm"
           (lib "list.ss")
           (lib "etc.ss")
           "../lib/tschantz-util.scm"
           "../lib/errorf.scm"
           "matcheq.scm"
           (prefix srfi: (lib "1.ss" "srfi")))
  
  (provide set-matcheq!
           get-equality-add
           get-match-add
           get-matcheq-add
           get-all-attrValues
           get-all-real-attrValues
           get-all-attrId
           get-matcheq-creation-list
           reset
           print-xradd
           print-xrcadd
           print-xrcadd-changes
           xradd->rawDnf
           xradd->namedDnf
           namedDnf->string
           (all-from-except "../add/radd.scm" new-var-add))
  
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; The Data 
  ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  
  
  
  ;;
  ;; seting up the mapping
  ;;
  
  
  (define subtarget-names '(Subject Resource Action Environment))
  (define (is-subtarget-name? subtarget)
    (srfi:member subtarget subtarget-names symbol=?))
  
  ;; how we define the keys.
  ;; note that it has the required propertity that 
  ;; (symbolPair->key a b) is equal to (symbolPair->key b a)
  (define (symbolPair->key lSymbol rSymbol)
    (if (symbol<=? lSymbol rSymbol)
        (list lSymbol rSymbol)
        (list rSymbol lSymbol)))
  ;(swindle:symbol-append lSymbol '< rSymbol)
  ;(swindle:symbol-append rSymbol '< lSymbol)))
  ;hacking '< part
  
  
  (define equality-subtargetSubtarget-keys 
    (srfi:delete-duplicates (cross symbolPair->key subtarget-names subtarget-names)
                            (lambda (l r) (and (symbol=? (first l) (first r))
                                               (symbol=? (second l) (second r))))))
  
  ;; the dyantic data structs
  ;; these are given tempory values for now
  ;; the function reset will set them to real values.
  (define creation-list 'temp)  
  (define match-table 'temp)
  (define equality-table 'temp)
  (define var2matcheq-table 'temp)
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Public Functions
  ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  (define (reset)
    (clear-memory)
    ;; lists all the matcheqs made from oldest first to newest last
    (set! creation-list '())
    ;; root table for all match tables
    (set! match-table (make-hash-table 'equal))
    ;; proprogate the table with each subtarget
    (map (lambda (subtarget) (hash-table-put! match-table subtarget (make-hash-table 'equal)))
         subtarget-names)
    ;; invarent: there exists an enter in the correct subtarget table for every attrId seen
    ;;  even if it was never used in a match (used only in an equality).
    ;; root table for all equality tables
    (set! equality-table (make-hash-table 'equal))
    ;; proprogate the table with each subtarget pair keys
    (map (lambda (subtargetSubtarget) (hash-table-put! equality-table subtargetSubtarget (make-hash-table 'equal)))
         equality-subtargetSubtarget-keys)
    ;; from var to a match or an equality
    (set! var2matcheq-table (make-hash-table 'equal)))
  
  ;; call reset to initalize the tables to the correct values.
  (reset)
  
  ;;
  ;; mutators
  ;;
  
  
  
  
  ;; Should only be called once at the begain of the file before any policies are loaded or any AVCs made.
  (define (set-matcheq! a-matcheq-list)
    ;(printf "set-matcheq! seting to ~a" a-matcheq-list) 
    (let [ [b-matcheq-list (srfi:delete-duplicates a-matcheq-list 
                                                   (lambda (l r)
                                                     (cond [(and (equality? l) (equality? r))
                                                            (equality=? l r)]
                                                           [(and (match? l) (match? r))
                                                            (match=? l r)]
                                                           [else false])))]]
      (map (lambda (matcheq)
             (cond [(equality? matcheq) (make-equality-add! matcheq)]
                   [(match? matcheq) (make-match-add! matcheq)]
                   [else (errorf "Internal Error: Required either a equality or a match.  Got a ~s" matcheq)]))
           b-matcheq-list)
      (set-universe! (produce-equality-contraints b-matcheq-list))))
  
  
  
  ;;
  ;; accessors
  ;;
  
  
  
  ;;  - xacml-new-var : manager -> 0-1-ADD
  ;;    returns 0-1-ADD for a new variable.  The order in which you create
  ;;    vars determines the variable ordering in the ADD.  Note that the
  ;;    package will not associate names with variables -- you need to do
  ;;    that in your scheme code.
  (define get-match-add
    (case-lambda
      [(match) 
       (get-match-add (match-subtarget match)
                      (match-attrId match)
                      (match-attrValue match))]
      [(subtarget attrId attrValue)
       (let [ [add (match->var subtarget attrId attrValue)] ]
         (if add
             add
             (errorf "No node exists for ~a, ~a, ~a.  Since no node exists for this, none of the policies loaded included a match statement for it.  Load all the policies before making any queries." subtarget attrId attrValue)))]))
  
  
  
  (define get-equality-add
    (case-lambda
      [(equality) 
       (get-equality-add (equality-lSubtarget equality)
                         (equality-lAttrId equality)
                         (equality-rSubtarget equality)
                         (equality-rAttrId equality))]
      [(lSubtarget lAttrId rSubtarget rAttrId)
       (let [ [add (equality->var lSubtarget lAttrId rSubtarget rAttrId)] ]
         (if add
             add
             (errorf "No var exists for ~a, ~a = ~a, ~a" lSubtarget lAttrId rSubtarget rAttrId)))]))
  
  
  
  (define (get-matcheq-add matcheq)
    (cond [(match? matcheq) (get-match-add matcheq)]
          [(equality? matcheq) (get-equality-add matcheq)]
          [else (error 'get-matcheq-add "Must be given a match or equality; given: ~s." matcheq)]))
  
  (define (get-matcheq-creation-list)
    creation-list)
  
  
  ;; -> list[list[attrId]]
  ;; subtarget -> list[attrId]
  ;; returns all the attrIds found for a subtarget
  (define get-all-attrId
    (case-lambda 
      [() (map get-all-attrId subtarget-names)]
      [(subtarget) (hash-table-map (hash-table-get match-table subtarget)
                                   (lambda (key val) key))]))
  
  ;; subtarget * attrId -> list[attrVal]
  ;; subtarget -> list[pair(attrId, list[attrVal])]
  ;; -> list[list[pair(attrId, list[attrVal])]]
  ;; returns all the attrValues found for a subtarget's attrId
  (define get-all-attrValues 
    (case-lambda
      [() (map get-all-attrValues subtarget-names)]
      [(subtarget) (map (lambda (attrId) (list attrId (get-all-attrValues subtarget attrId)))
                        (get-all-attrId subtarget))]
      [(subtarget attrId) (hash-table-map (hash-table-get (hash-table-get match-table subtarget) attrId)
                                          (lambda (key val) key))]))
  
  (define (get-all-real-attrValues . args)
    (filter (lambda (value) (not (eq? value 'OTHER)))
            (apply get-all-attrValues args)))
  
  
  
  (define (state->string)
    (letrec [ [->string-help (lambda (c-l num)     ;; list[match] * num -> string
                               (if (empty? c-l)
                                   ""
                                   (let [ [elem (car c-l)] ]
                                     (string-append " "
                                                    (number->string num) 
                                                    ":" 
                                                    (if (match? elem) (match->string elem) (equality->string elem))
                                                    "\n"
                                                    (->string-help (rest c-l) (add1 num))))))]
              [num-list (lambda (cur-num end-num infix)
                          (if (> cur-num end-num)
                              ""
                              (string-append (number->string (remainder cur-num 10))
                                             infix
                                             (num-list (add1 cur-num) end-num infix))))] ]
      
      (let [ [num-entries (length creation-list)] ]
        (string-append (->string-help creation-list 1) 
                       "\n" 
                       (repeat-string 9 " ")
                       (num-list 1 (quotient num-entries 10) (repeat-string 9 " "))
                       "\n"
                       (num-list 1 num-entries "")))))
  
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Helper functions
  ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  
  ;;
  ;; Setting up the universe
  ;;
  
  
  ;; should take the xadd and pull out its equality nodes, rather than just using them all as below.
  ;; note that this will break the singlton constrant thing in some cases.
  ;; (and (implies     (or (and x=a y=a) (and x=b y=b)) x=y)
  ;;      (implies x=y (or (and x=a y=a) (and x=b y=b) (and x=o y=c) (and x=o y=o))))
  (define (make-equality-constraint equality-struct)
    (let* [ [badd-implies (lambda (l r) (badd-or (badd-not l) r))]
            [lSubtarget (equality-lSubtarget equality-struct)]
            [lAttrId (equality-lAttrId equality-struct)]
            [lAttrValues (get-all-real-attrValues lSubtarget lAttrId)]
            [rSubtarget (equality-rSubtarget equality-struct)]
            [rAttrId (equality-rAttrId equality-struct)]
            [rAttrValues (get-all-real-attrValues rSubtarget rAttrId)]
            [commonValues (srfi:lset-intersection symbol=? lAttrValues rAttrValues)]
            [equalityVar (equality->var lSubtarget lAttrId rSubtarget rAttrId)]
            [constrant-of-commonValues (foldr badd-or 
                                              (badd-false)
                                              (map (lambda (common-value) ; (and x=a y=a)
                                                     (badd-and (match->var lSubtarget lAttrId common-value)
                                                               (match->var rSubtarget rAttrId common-value)))
                                                   commonValues))] ]
      (badd-and
       (badd-implies constrant-of-commonValues 
                     equalityVar)                    
       (badd-implies equalityVar
                     (badd-or (badd-or constrant-of-commonValues
                                       (badd-and (match->var lSubtarget lAttrId 'OTHER)
                                                 (match->var rSubtarget rAttrId 'OTHER)))
                              (badd-or (foldr badd-or 
                                              (badd-false)
                                              (map (lambda (noncommon-value) ; (and x=a y=o)
                                                     (badd-and (match->var lSubtarget lAttrId noncommon-value)
                                                               (match->var rSubtarget rAttrId 'OTHER)))
                                                   (srfi:lset-difference symbol=? lAttrValues commonValues)))
                                       (foldr badd-or 
                                              (badd-false)
                                              (map (lambda (noncommon-value) ; (and x=o y=a)
                                                     (badd-and (match->var lSubtarget lAttrId 'OTHER)
                                                               (match->var rSubtarget rAttrId noncommon-value)))
                                                   (srfi:lset-difference symbol=? rAttrValues commonValues)))))))))
  
  
  
  (define (produce-equality-contraints matcheq-list)
    ;(printf "pec over ~s from ~a~n" 
    ;        (filter equality? (get-matcheq-creation-list))
    ;        (get-matcheq-creation-list))
    (foldr badd-and
           (badd-true)
           (map make-equality-constraint
                (filter equality? matcheq-list) )))
  
  
  
  ;;
  ;; helping
  ;; mutators
  ;; adding more things of which to keep track.
  ;;
  
  (define make-match-add!
    (case-lambda
      [(match) 
       (make-match-add! (match-subtarget match)
                        (match-attrId match)
                        (match-attrValue match))]
      [(subtarget attrId attrValue)
       (let [ [add (match->var subtarget attrId attrValue)] ]
         (if add
             add
             (let [ [nadd (new-var-add)] ]
               (put-match! subtarget attrId attrValue nadd)
               nadd)))]))
  
  
  (define make-equality-add!
    (case-lambda
      [(equality) 
       (make-equality-add! (equality-lSubtarget equality)
                           (equality-lAttrId equality)
                           (equality-rSubtarget equality)
                           (equality-rAttrId equality))]
      [(lSubtarget lAttrId rSubtarget rAttrId)
       (let [ [add (equality->var lSubtarget lAttrId rSubtarget rAttrId)] ]
         (if add
             add
             (let [ [nadd (new-var-add)] ]
               (put-equality! lSubtarget lAttrId rSubtarget rAttrId nadd)
               nadd)))]))
  
  
  
  (define (get-or-make-attrId-table subtarget attrId)
    (let [ [subtarget-table (hash-table-get match-table subtarget)] ]
      (hash-table-get subtarget-table
                      attrId 
                      (lambda () ; excuted for new attrIds
                        (let [ [new-attrId-table (make-hash-table 'equal)] ]
                          (hash-table-put! subtarget-table attrId new-attrId-table)
                          (let [ [other-var (new-var-add)] ; make a node for OTHER
                                 [other-match (make-match subtarget attrId 'OTHER)] ]
                            (hash-table-put! new-attrId-table 'OTHER other-var) 
                            (set! creation-list (append creation-list (list other-match)))
                            (hash-table-put! var2matcheq-table other-var other-match))
                          ;(hash-table-put! var2match-table var match))) ; mct why was this here?
                          new-attrId-table)))))
  
  ;; sym * sym * sym * var ->
  (define (put-match! subtarget attrId attrValue var)
    ;(printf "~n>> put-match! ~a, ~a, ~a into ~a" subtarget attrId attrValue creation-list)
    ; make the other mappings
    (let [ [match (make-match subtarget attrId attrValue)] ]
      (set! creation-list (append creation-list (list match)))
      (hash-table-put! var2matcheq-table var match))
    ; make the (subtarget * attrId * value) to var mapping
    (hash-table-put! (get-or-make-attrId-table subtarget attrId) attrValue var))
  
  ;; sym * sym * sym * sym * var ->
  ;; note that this also adds tables to the match-table so that all attrIds are stored in the match table
  (define (put-equality! lSubtarget lAttrId rSubtarget rAttrId var)
    ;(printf "~n>> put-equality! ~a, ~a = ~a, ~a into ~a" lSubtarget lAttrId rSubtarget rAttrId creation-list)
    (let [ [subtargetSubtarget-table (hash-table-get equality-table (symbolPair->key lSubtarget rSubtarget))] ]
      (hash-table-put! subtargetSubtarget-table (symbolPair->key lAttrId rAttrId) var))
    (let [ [equality (make-equality lSubtarget lAttrId rSubtarget rAttrId)] ]
      (set! creation-list (append creation-list (list equality)))
      (hash-table-put! var2matcheq-table var equality))
    (get-or-make-attrId-table lSubtarget lAttrId)
    (get-or-make-attrId-table rSubtarget rAttrId))
  
  
  
  ;;
  ;; helping
  ;; accessors
  ;;
  
  
  ;; sym * sym * sym -> var | #f
  (define (match->var subtarget attrId attrValue)
    ;(printf "~n>> match->var: ~a, ~a, ~a" subtarget attrId attrValue)
    (let [ [attrId-table (hash-table-get (hash-table-get match-table subtarget) attrId (lambda () #f))] ]
      (if attrId-table
	  (hash-table-get attrId-table attrValue (lambda () #f))
	  #f)))
  
  
  ;; sym * sym * sym * sym -> var | #f
  ;; returns the var for the given equality
  ;; if none exists, false is returned.
  (define (equality->var lSubtarget lAttrId rSubtarget rAttrId)
    (hash-table-get (hash-table-get equality-table (symbolPair->key lSubtarget rSubtarget))
                    (symbolPair->key lAttrId rAttrId)
                    (lambda () #f)))
  
  
  ;; var -> match | #f
  (define (var->matcheq var) 
    (hash-table-get var2matcheq-table var (lambda () #f)))
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Output
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  (define (print-xradd xradd)
    (display (state->string))
    (newline)
    (print-xadd xradd))
  
  (define (print-xrcadd xrcadd)
    (display (state->string))
    (newline)
    (print-cadd xrcadd))
  
  (define (print-xrcadd-changes xrcadd)
    (display (state->string))
    (newline)
    (print-cadd-changes xrcadd))
  
  (define (xradd->rawDnf policy)
    (add->rawDnf policy))
  
  (define (xradd->namedDnf policy)
    (rawDnf->namedDnf (xradd->rawDnf policy)))
   
    ;; rewDnf -> namedDnf    where
    ;; rawDnf = list[rawDdPath] = list[(list[sym], dec)]    and
    ;; namedDnf = list[matcheqDdPath] = list[(list[matcheqConstraint], dec)] = list[(pair[matcheq, bool], dec)]
    (define (rawDnf->namedDnf raw-dnf)
      (map (lambda (raw-dnf-term)
             (list
              (filter (lambda (x) x) ;; remove dont care constraints that are represented as #f
                      (map (lambda (val matcheq)                             
                             (cond [(symbol=? val 'True) (make-matcheqConstraint matcheq
                                                                                 #t)]
                                   [(symbol=? val 'False) (make-matcheqConstraint matcheq
                                                                                  #f)]                                   
                                   [(symbol=? val 'DontCare) #f]
                                   [else (error 'raw-dnf->named-dnf 
                                                "a value in the raw-dnf is unknown.  That value is: ~a" 
                                                val)])) 
                           (first raw-dnf-term)
                           (get-matcheq-creation-list)))
              (second raw-dnf-term)))
           raw-dnf))
  
  (define (namedDnf->string namedDnf)
    (string-append "\n[[\n"
                   (apply string-append 
                          (insert-between-elements "\n\n" 
                                                   (map matcheqDdPath->string namedDnf)))
                   "\n]]\n"))
                   

      
  )
