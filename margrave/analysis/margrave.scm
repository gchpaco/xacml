;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                        ;;
;;                   MARGRAVE                             ;;
;;                                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   VERSION 2                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Note: This file uses a hacked version of the LAML SchemeDoc system
;; (see http://www.cs.auc.dk/~normark/schemedoc/ for the normal version).
;; The !, !!, and !!! found in comments may be ignored: 
;; they are used for auto generation of documentation.
;; The comment lines starting with "." and then a word (e.g. ".type")
;; are also used with SchemeDoc.
;; Some comments also contain HTML tags, which are used for formatting only.
;; You should view the comments online at 
;; www.cs.brown.edu/research/plt/software/margrave/schemedocs,
;; rather than trying to understand these marked up comments.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; !!!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; .title Margrave Query Functions
;; .author Kathi Fisler (WPI), Shriram Krishnamurthi (Brown University), Leo A. Meyerovich (Brown University), and Michael Carl Tschantz (Brown University)
;;
;; <p> VERSION 2
;; 
;; <p> This is the main Scheme file for Margrave.  This file holds most the functions you will need 
;; to ask queries about AVCs, policies, and comparisons as well as to 
;; to make AVCs and comparisons, and load XACML policy files.  It loads the other required functions.
;;
;; <p> To use Margrave, make a query file that loads this file and the module 
;; this file holds as follows:                             <br>
;;                                                         <br>
;; (require "[path]/Margrave/analysis/margrave.scm)        <br>
;;                                                         <br>
;; where "[path]" is the path to where you installed Margrave.
;;
;; .source-destination-delta ../../web/documentation/schemedocs/
;; .documentation-commenting-style documentation-mark
;; .keep-syntactical-comment-file true
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; !
;; The module holding query functions.  Use the Scheme command "(require \"Margrave/analysis/margrave.scm\")" to include it in your query files.
(module margrave mzscheme
  
  (require (lib "etc.ss")                            ; helper functions
           (lib "list.ss")                           ; helper functions
           (prefix srfi: (lib "1.ss" "srfi"))        ; helper functions
           (prefix util: "../lib/tschantz-util.scm")
           "xradd.scm"                               ; working with adds
           (prefix load: "policy-loader.scm")              ; for syntax
           (prefix matcheq: "matcheq.scm")           ; some data structs
           "invariants.scm"                                ; some helpers
           )
  
  
  ;(require-for-syntax "policy-loader.scm"
  ;                    "xradd.scm")
  
  (provide (all-defined))
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Constants
  ;;
  
  ;; !
  ;; A list of constants (symbols) used for the decisions.
  ;; This include 'P for permit, 'D for deny, 'N for not applicable, and 'E for excluded by constraint
  (define list-of-decision-const (list 'P 'D 'N 'E))
  
  ;; !
  ;; A list of constants that represent all the possible terminals in a comparison
  ;; that correspond to a change.  For example, 'PD corresponds to the change "Permit goes to Deny".
  ;; Note that "changes" like 'PP (permit stays permit) are not in the list since these "changes"
  ;; are not really changes.
  (define list-of-change-const (list 'PD 'PN 'PE 'DP 'DN 'DE 'NP 'ND 'NE 'EP 'ED 'EN))
  
  ;; !
  ;; Like the list-of-change-const, but only list those changes that will change the
  ;; behavior of the PEP.  For example, 'ND (not applicable goes to deny) is not in this
  ;; list despite being in list-of-change-const since the PEP must reject any request 
  ;; that yields either not applicable or deny, so the PEP will do the same thing either way.
  (define list-of-real-change-const (list 'PD 'PN 'PE 'DP 'DE 'NP 'NE 'EP 'ED 'EN))
  
  
  ;; A rSet is a BADD representation of a set of requests
  ;; A Policy is a XADD representation of a XACML policy.
  ;; Note by BADD, I really mean a 0-1-ADD
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Loading XACML files.
  ;; There are three ways to load XACML policies into Margrave.  Only one
  ;; of these ways may be used in any one program due to memory sharing and
  ;; assumptions that Margrave use to create a bounded universe of requests.
  ;; 
  ;; You must load all the XACML policies that are to be used before using any
  ;; of the other Margrave functions.
  ;; Use load-xacml-policy if you only have one policy total to load during the
  ;; the entire run of the program.  Use either load-xacml-policies or 
  ;; load-xacml-policies-list if you would like to load more than one.
  ;; If you are loading more than one, you must load them all in one
  ;; application of load-xacml-policies or load-xacml-policies-list.
  ;;
  
  ;; !
  ;; .type (string | ast) -> policy
  ;; Returns one XACML policy ADD after loading it.
  ;; Only use if you have exactly one XACML policy to 
  ;; load during the entire run of the program.
  (define (load-xacml-policy policy)
    (first (load-xacml-policies policy)))
  
  
  ;; !
  ;; .type (string | ast)* -> (listof policy)
  ;; Returns a list of policies given 
  ;; some number of policies locations (either file paths or abstract syntax trees).
  (define (load-xacml-policies . policies)
    (set-matcheq! (foldr (lambda (f r) (append (load:glean-matcheq f) r))
                         '()
                         policies))
    (map load:ast-or-file->xradd policies))
  
  ;; !
  ;; .type SYNTAX
  ;; Syntax that binds identifiers to policies within its body.
  ;; The identifies are not bound out side of the bind-xacml-policies's body.
  ;; Furthermore, the values to which they are bound (policy ADDs) and any other
  ;; ADD values made within the body, cannot be used outside the body.
  ;; For example, using set! to bind a policy ADD to an identifier that is
  ;; in scope outside of the body, will result in unspecified behavior.
  ;; <p> For example:
  ;; <pre>
  ;; (let-xacml-policies [ [pol1 "file1.xml"]
  ;;                        [pol2 ast2]
  ;;                        [pol3 "file3.xml"] ]
  ;;    body-expr_1
  ;;    body-expr_2
  ;;    $...
  ;;    body-expr_n)
  ;; </pre>
  ;; .form (let-xacml-policies ( [name loc] ...) body ...))
  ;(define let-xacml-policies 2) ; hack for schemedocs, real def/n below
  (define-syntax (let-xacml-policies stx)
    (syntax-case stx ()
      [(let-xacml-policies [ [name loc] ...] body ...)
       (syntax/loc stx 
         (begin
           (set-matcheq! (foldr (lambda (f r)
                                  (append (load:glean-matcheq f) r))
                                '()
                                (list loc ...)))
           (let [ [name (load:ast-or-file->xradd loc)] ...]
             body ...)
           (reset)))]))
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; 
  ;; Creating AVCs.
  ;; Functions for creating attribute value constraints.
  ;;
  
  ;; !
  ;; The constant true AVC.
  (define (avc-true)
    (badd-true))
  
  ;; !
  ;; The constant false AVC.
  (define (avc-false)
    (badd-false))
  
  ;; !
  ;; .type (| (sym sym sym -> avc) (sym sym sym sym -> avc) (string -> avc))
  ;; .sem (lambda (s i v) {(s, i, v)})
  ;; .form (make-avc subtarget attributeId value)
  ;; .form (make-avc lSubtarget lAttributeId rSubtarget rAttributeId)
  ;; .form (make-avc product-string)
  ;; Creates an AVC with the given attribute assignments.
  ;; If three symbols are given, it assigns the value given as the third argument,
  ;; to the attribute given as the second in the subtarget (namespace) given as the first.
  ;; This can be seen as representing the set of requests in which the given attribute has 
  ;; the given value.<br>
  ;; If four symbols are given, it returns the AVC in which the attribute of the first two arguments
  ;; shares a value with the attribute given in the second two.  This can be seen as the set of
  ;; requests in which the two given attributes have value in common.<br>
  ;; If just a string is given, then that string will create the AVC in which for each '1'
  ;; in the string the variable in that position will be true; each '0', false; each '-',
  ;; a don't care (i.e., it will include both those with and without it).  This is mostly
  ;; only useful for pasting in lines from the command print-avc and creating an AVC
  ;; represents that one minterm.
  (define make-avc 
    (case-lambda
      [(product-string)
       (if (string? product-string)
           (let [[prod-lst (string->list product-string)]
                 [creat-lst (get-matcheq-creation-list)]]
             (if (= (length prod-lst) (length creat-lst))
                 (avc-and* (map (lambda (matcheq choice) 
                                  (cond [(char=? choice #\1) (get-matcheq-add matcheq)]
                                        [(char=? choice #\0) (avc-not (get-matcheq-add matcheq))]
                                        [(char=? choice #\-) avc-true]
                                        [else (error 'make-avc "A product list can only contain the chars '1', '0', and '-'; given: ~s" choice)]))
                                creat-lst
                                prod-lst))
                 (error 'make-avc "A product list must have exactly one entry (character) for every variable.  Thus, this one should have ~s, but has ~s instead." (length creat-lst) (length prod-lst))))
           (error 'make-avc "If make-avc is used with only one argument, it must be a product string; given: ~s." product-string))]
      [(subtarget attrId attrValue)
       (get-match-add subtarget attrId attrValue)]
      [(l-subtarget l-attrId r-subtarget r-attrId)
       (get-equality-add l-subtarget l-attrId r-subtarget r-attrId)]))
  
  
  ;; !
  ;; Returns the AVC that contains exactly one request,
  ;; specifically the request that has only the given attribute value
  ;; associated with the given attribute id in the given
  ;; subtarget, and no other associations.
  (define (make-avc-singleton subtarget attrId attrValue)
    (avc-and (make-avc subtarget attrId attrValue)
             (avc-not (avc-or* (map (lambda (attrVal) (make-avc subtarget attrId attrVal))
                                    (filter (lambda (attrVal) 
                                              (not (eq? attrVal attrValue)))
                                            (get-all-attrValues subtarget attrId)))))))
  
  ;; !
  ;; Given a match, it will return the corresponding AVC.
  ;; Note that (make-avc aSubtarget anAttrId anAttrValue) does return
  ;; the same AVC as (match->avc (make-match aSubtarget anAttrId anAttrValue))
  (define (match->avc match)
    (make-avc (matcheq:match-subtarget match) (matcheq:match-attrId match) (matcheq:match-attrValue match)))
  
  ;; !
  ;; Like make-avc-singleton but takes a match instead.
  (define (match->avc-singleton . match-list)
    (avc-and (avc-and* (map match->avc match-list))
             (avc-and* 
              (map avc-not
                   (map match->avc (filter (lambda (x) 
                                             (and (matcheq:match? x) 
                                                  (not (srfi:member x match-list matcheq:match=?)))) 
                                           (get-matcheq-creation-list)))))))
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; AVC Connectives.
  ;; These mirror the Boolean connectives.
  ;; One might find it easier to think of these as set operations
  ;; where each AVC is a set of requests or matches.
  ;; For example, avc-or may be thought of as a union.
  ;;
  
  ;; !
  ;; .type avc -> avc
  ;; .sem (lambda (rs) {r in Req | r not in rs})
  ;; Returns that complement of the given AVC.
  (define (avc-not avc)
    (badd-not avc))
  
  ;; !
  ;; .type avc* -> avc
  ;; .sem (lambda (rs rs') {r in Req | r in rs or r in rs'})
  ;; Returns the union of the given AVCs.
  ;; .internal-references "list version" "avc-or*"
  (define (avc-or . l)           
    (avc-or* l))
  
  ;; !
  ;; .type (listof avc) -> avc
  ;; Like avc-or but takes a list of AVCs.
  ;; .internal-references "non-list version" "avc-or"
  (define (avc-or* l)
    (foldr badd-or (badd-false) l)) 
  
  ;; !
  ;; .type avc* -> avc
  ;; .sem (lambda (rs rs') {r in Req | r in rs and r in rs'})
  ;; Returns the intersection of the given AVCs.
  ;; .internal-references "list version" "avc-and*"
  (define (avc-and . l)
    (avc-and* l))
  
  ;; !
  ;; .type (listof avc) -> avc
  ;; Like avc-and but takes a list of AVCs.
  ;; .internal-references "non-list version" "avc-and"
  (define (avc-and* l)
    (foldr badd-and (badd-true) l))
  
  ;; !
  ;; .type avc avc -> avc
  ;; Returns the avc that implies if an element is in if-avc, then it is in else-avc.
  ;; The set of avc that are in else-avc or not in if-avc.
  ;; .internal-references "closely related" "avc-difference"
  (define (avc-implies if-avc else-avc)
    (avc-or else-avc (avc-not if-avc)))
  
  ;; !
  ;; .type avc avc -> avc
  ;; .sem (lambda (rs rs') {r in Req | r in rs and r not in rs'})
  ;; Returns the AVC that is the difference between base-avc and removed-avc.
  ;; Removes the elements of removed-avc from base-avc.
  ;; {x in base-avc | x not in removed-avc} = base-avc intersect (compl removed-avc)
  ;; .internal-references "closely related" "avc-implies"
  (define (avc-difference base-avc removed-avc)
    (avc-and base-avc (avc-not removed-avc)))
  
  
  ;; !
  ;; .type avc* -> avc
  ;; Produces the AVC that holds all requests that fall into
  ;; no more than one of the AVCs given.
  ;; .internal-references "list version" "disjoint-set*"
  (define (disjoint-set . avc-list)
    (disjoint-set* avc-list))
  
  ;; !
  ;; .type (listof avc) -> avc
  ;; Produces the AVC that holds all requests that fall into
  ;; no more than one of the AVCs given in the list.
  ;; .internal-references "non-list version" "disjoint-set"
  (define (disjoint-set* avc-list)
    (avc-not (avc-or* (util:skipping-self-cross avc-and 
                                                avc-list))))
  
  ;; !
  ;; .type avc* -> avc
  ;; Produces the AVC that holds all requests that fall into
  ;; exactly one of the AVCs given.
  ;; .internal-references "list version" "partition-set*"
  (define (partition-set . avc-list)
    (partition-set* avc-list))
  
  ;; !
  ;; .type (listof avc) -> avc
  ;; Produces the AVC that holds all requests that fall into
  ;; exactly one of the AVCs given in the list.
  ;; .internal-references "non-list version" "partition-set"
  (define (partition-set* avc-list)
    (avc-and (disjoint-set* avc-list)
             (avc-or* avc-list)))
  
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Predicates over AVCs.
  ;; These check for basic properties of AVCs.
  ;;
  
  ;; !
  ;; .type avc -> bool
  ;; .sem (lambda (rs) 1 iff rs = {})
  ;; Returns true iff the given AVC is the constant false.
  ;; One can view such an AVC as being empty.
  (define (avc-false? avc)
    (avc-equal? avc (badd-false)))
  
  ;; !
  ;; .type avc avc -> bool
  ;; .sem (lambda (rs rs') ((rset-subset? rs rs') and (rset-subset? rs' rs)))
  ;; Returns true iff the two given AVCs are equal.
  (define (avc-equal? l r)
    (add-equal? l r))
  
  
  ;; !
  ;; .type avc avc -> bool
  ;; .sem (lambda (rs rs') 1 iff all r in rs, r in rs') 
  ;; Returns true iff l implies r.
  ;; That is, returns true when l holds all the match sets that r holds (and maybe some more).
  ;; One can view this as returning true iff l is a subset of r.
  (define (avc-implication? l r)
    (avc-equal? (avc-and l r) l))
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; 
  ;; Other Predicates.
  ;;
  
  ;; !
  ;; .type policy policy -> bool
  ;; Tests for the equality of two policies.
  (define (policy-equal? l r)
    (add-equal? l r))
  
  ;; ! 
  ;; .type comparison comparison -> bool
  ;; Test for the equality of two comparisons.
  (define (comparison-equal? l r)
    (add-equal? l r))
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Creating Comparisons.
  ;;
  
  ;; !
  ;; .type policy policy -> comparison
  ;; Compares two policies.
  ;; Given two policies, it will merge
  ;; the two policies into a comparison that
  ;; will list all of the differences between the two
  ;; policies.  The comparison will be done in the 
  ;; order in which the policies are provided.
  ;; <br>For example:<br> (compare p1 p2) where p1 denies all requests and p2 permits all requests that would yield a comparison in which everything is mapped to 'DP, the symbol for "deny goes to permits".
  (define (compare-policies policy1 policy2)
    (compare-xadds policy1 policy2))
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Quantification.
  ;; Performs quantification over a match.
  ;;
  
  ;; !
  ;; .type avc match* -> avc
  ;; .sem (lambda (rs st i v) {r in Req | (or (r union {(st, i, v)} in rs) (r - {(st, i, v)} in rs))})
  ;; Makes a BADD badd into E b in bool such that badd[avc -> b].
  ;; Existential quantification over an avc:
  ;; does there exist a value for this match (has it or does not have it)
  ;; such that true is yielded. Maybe a better name would be "don't-care-out-match".
  ;; .internal-references "list version" "there-exists-for*"
  (define (there-exists-for avc . match-list)
    (there-exists-for* avc match-list))
  
  ;; !
  ;; .type avc (listof match) -> avc
  ;; Makes the given AVC into E b in bool s.t. badd[avc -> b]
  ;; Existential quantification over an avc,
  ;; does there exist a value for this match (has it or does not have it)
  ;; such that true is yielded.
  ;; .internal-references "non-list version" "there-exists-for"
  (define (there-exists-for* avc match-list)
    (if (empty? match-list)
        avc
        (there-exists-for* (badd-or (cudd-constrain-add (match->avc (car match-list)) avc)
                                    (cudd-constrain-add (avc-not (match->avc (car match-list))) avc))
                           (cdr match-list))))
  
  ;; !
  ;; .type avc match* -> avc
  ;; Like there-exits-for, but performs the for-all* operation.
  ;; .internal-references "list version" "for-all*"
  (define (for-all avc . match-list)
    (for-all* avc match-list))
  
  ;; !
  ;; .type avc (listof match) -> avc
  ;; Universal quantification over an avc.
  ;; .internal-references "non-list version" "for-all"
  (define (for-all* avc match-list)
    (if (empty? match-list)
        avc
        (for-all* (badd-and (cudd-constrain-add (match->avc (car match-list)) avc)
                            (cudd-constrain-add (avc-not (match->avc (car match-list))) avc))
                  (cdr match-list))))
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; 
  ;; Evaluating Requests.
  ;; These allow Margrave to act as a PDP or to view things as a PEP does.
  ;;
  
  ;; !
  ;; .type policy -> policy
  ;; .sem (lambda (p) (lambda (r in Req) (if ((p r) = 'P) 'P 'D)))
  ;; The way the policy is enforced by a PEP
  ;; (with NA being treated as a deny)
  (define (PEP-view policy)
    (na-to-deny policy))
  
  ;; !
  ;; .type policy * avc -> decision
  ;; Takes a policy and a request and yields the response a PDP would yield.  
  ;; .returns A symbol, either 'P, 'D, 'N, 'E, for permit, deny, not applicable, or excluded by constraint, respectively.
  ;; .precondition The avc should be an exact avc, i.e., an avc that contains only one distinguishable request.
  (define (PDP policy request)
    (cond [(avc-implication? request (restrict-policy-to-dec 'P policy)) 'P]
          [(avc-implication? request (restrict-policy-to-dec 'D policy)) 'D]
          [(avc-implication? request (restrict-policy-to-dec 'N policy)) 'N]
          [(avc-implication? request (restrict-policy-to-dec 'E policy)) 'E]
          [else (error 'PDP "insufficient information provided in the avc to determine its decision.  (i.e., the avc given includes requests that are mapped to different decisions)")]))
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Restriction.
  ;; Get the AVC that corresponds to the terminal in which you are interested from a policy or comparison.
  ;; If for example you would like to know which requests are mapped to 'P (permit) in a policy named Pol,
  ;; you can restrict the policy to 'P with (restrict-policy-to-dec 'P Pol).  This will yield the AVC that
  ;; holds all the requests that would yield 'P.
  ;;
  
  ;; !
  ;; .type policy decision -> avc
  ;; .sem (lambda (p d) {r in Req | (p r) = d})
  ;; Get the AVC that corresponds to the terminal in which you are interested from a policy or comparison.
  ;; .parameter "decision" "Should be 'P for Permit, 'D for Deny, 'N for NotApplicable, and 'E for ExcludedByConstraint"
  (define (restrict-policy-to-dec decision policy)
    (add-restrict-to policy decision))
  
  ;; !
  ;; .type comparison decision -> avc
  ;; .sem (lambda (comp chg) = {r in Req | (comp r) = chg})
  ;; Get the AVC that corresponds to the terminal in which you are interested from a policy or comparison.
  ;; .parameter "change" "Should be one of the symbols of the form XY where X and Y each P, D, N, or E.  The change of PD, for example, means a change from permit to deny."
  (define (restrict-comparison-to-change change comparison)
    (add-restrict-to comparison change))
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Constraining Policies.
  ;; Rule some requests out of consideration by introducing environment constraints.
  ;;
  
  ;; !
  ;; .type policy avc -> policy
  ;; .sem (lambda (p rs) (lambda (r in Req) (if (r in rs) then p(r) else 'EC)))
  ;; Constrain a policy to a given request-set.
  ;; All requests that are not in the request-set are mapped to EC.
  (define (constrain-policy request-set policy)
    (assume-xadd request-set policy))
  
  ;; !
  ;; .type (listof avc) policy -> policy
  ;; .sem (lambda (p rss) (lambda (r in Req) (if (there exists rs,rs' in rss s.t. r in rs and r in rs' and rs != rs') then 'EC else (p r))))
  ;; returns the policy that applies if only one of the 
  ;; listed avcs is possible at once.
  (define (constrain-policy-disjoint avc-list policy)
    (constrain-policy (disjoint-set* avc-list) policy))
  
  ;; !
  ;; .type (listof avc) policy -> policy
  ;; like disjoint, but all requests must lay in one of the give avcs.
  ;; .internal-references "" "constrain-policy-disjoint"
  (define (constrain-policy-partition avc-list policy)
    (constrain-policy (partition-set* avc-list) policy))
  
  ;; !
  ;; .type subtarget sym policy -> policy
  ;; Makes the attribute only associated with values named in the loaded policies.
  ;; Rules out the possibility of having the attribute id associated with
  ;; values that are not named (given) in any of the loaded policies.  These values are represented
  ;; by one special value: OTHER.  Removes the possibility of that attribute
  ;; having the special value of OTHER.  Maybe a better name for this function would be
  ;; make-named-values-only-attribute.
  (define (make-named-attribute subtarget attrId policy)
    (constrain-policy (avc-not (make-avc subtarget attrId 'OTHER))
                      policy))
  
  ;; !
  ;; .type subtarget sym policy -> policy
  ;; .sem (lambda (p st i) (lambda (r in Req) (if (there exists (st, i, v), (st, i, v') in r s.t. v != v') 'EC (p r)))) 
  ;; make-nonmulti-attribute will constrain out any request that associates more than one attribute value 
  ;; with the given attribute id.  
  ;; Also constrains out the possibility of the special value OTHER being associates with the given attribute id.
  ;; OTHER is constrained out since OTHER actually stands for any natural number of other values, not just one.
  ;; <br>For example:<br> You know that every request will have at most one value associated with the resource-id attribute so place a make-nonmulti-attribute constraint on the policy Pol with "(make-nonmulti-attribute 'Resource 'resource-id Pol)".
  ;; .internal-references "list version" "make-nonmulti-attribute*"
  ;; .internal-references "implies" "make-named-attribute"
  (define (make-nonmulti-named-attribute subtarget attrId policy)
    (constrain-policy (avc-not (make-avc subtarget attrId 'OTHER))
                      (constrain-policy-disjoint (map (lambda (attrVal) (make-avc subtarget attrId attrVal))
                                                      (get-all-real-attrValues subtarget attrId))
                                                 policy)))
  
  ;; !
  ;; .type (listof (pair subtarget sym)) policy -> policy
  ;; .internal-references "non-list version" "make-nonmulti-attribute"
  ;; .internal-references "implies" "make-named-attribute"
  (define (make-nonmulti-named-attribute* list-s-id policy)
    (foldl (lambda (s-id new-policy) (make-nonmulti-named-attribute (first s-id) (second s-id) new-policy)) 
           policy 
           list-s-id))
  
  ;; !
  ;; .type policy subtarget sym -> policy
  ;; make-single-valued-attribute will constrain out any request that does not associate exactly one attribute value 
  ;; with the given attribute id.  
  ;; Also constrains out the possibility of the special value OTHER being associates with the given attribute id.
  ;; OTHER is constrained out since OTHER actually stands for any positive number of other values, not just one.
  ;; <br>For example:<br> You know that every request will have exactly one value associates with the resource-id attribute so place a make-nonmulti-attribute constraint on the policy Pol with "(make-singleton-attribute 'Resource 'resource-id Pol)".
  ;; .internal-references "list version" "make-singleton-attribute*"
  ;; .internal-references "implies" "make-named-attribute"
  (define (make-singleton-named-attribute subtarget attrId policy)
    (constrain-policy (avc-not (make-avc subtarget attrId 'OTHER))
                      (constrain-policy-partition (map (lambda (attrVal) (make-avc subtarget attrId attrVal))
                                                       (get-all-real-attrValues subtarget attrId))
                                                  policy)))
  
  ;; !
  ;; .type (listof (pair subtarget sym)) policy -> policy
  ;; .internal-references "non-list version" "make-singleton-attribute"
  ;; .internal-references "implies" "make-named-attribute"
  (define (make-singleton-named-attribute* list-s-id policy)
    (foldl (lambda (s-id new-policy) (make-singleton-named-attribute (first s-id) (second s-id) new-policy)) 
           policy 
           list-s-id)) 
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Reducing AVCs.
  ;; Reduce an AVC to the parts in which you are interested.
  ;; 
  
  ;; !
  ;; .type subtarget attrId avc -> avc
  ;; .sem (lambda (rs st i) {r in Req | there exists r' in rs s.t. {(st, i, v) in r} = {(st, i, v) in r'}})
  ;; Returns an AVC representing all the combinations of attribute values found 
  ;; for the given attribute in the given AVC.
  (define (present-combo-attrValues subtarget attrId avc)
    (there-exists-for* avc 
                       (filter (lambda (match)
                                 (and (matcheq:match? match)
                                      (not (and (eq? subtarget (matcheq:match-subtarget match))
                                                (eq? attrId (matcheq:match-attrId match))))))
                               (get-matcheq-creation-list))))
  
  ;; !
  ;; .type subtarget attrId terminal (| policy comparison) -> avc
  ;; Returns an AVC representing all the combination of attribute values found 
  ;; for the given attribute in the given comparison that are involved in the given change.
  ;; .internal-references "list version" "get-combo-attrVal-involved-in*"
  (define (get-combo-attrVal-involved-in subtarget attrId change cadd)
    (get-combo-attrVal-involved-in* subtarget attrId (list change) cadd))
  
  ;; !
  ;; .type subtarget attrId (listof terminal) (| policy comparison) -> avc
  ;; Returns an AVC representing all the combination of attribute values found 
  ;; for the given attribute in the given comparison that are involved in any of the given changes.
  ;; .internal-references "non-list version" "get-combo-attrVal-involved-in"
  (define (get-combo-attrVal-involved-in* subtarget attrId change-list cadd)
    (if (empty? change-list)
        (badd-false)
        (avc-or (present-combo-attrValues subtarget attrId (restrict-comparison-to-change (car change-list) cadd))
                (get-combo-attrVal-involved-in* subtarget attrId (cdr change-list) cadd))))
  
  ;; !
  ;; .type cadd subtarget attrId change -> avc
  ;; Returns an AVC representing all the combination of attribute values found 
  ;; for the given attribute in the given comparison that are involved in a change
  ;; .internal-references "list of \"changes\"" "list-of-change-const"
  (define (get-combo-attrVal-involved-in-change subtarget attrId cadd)
    (get-combo-attrVal-involved-in* subtarget attrId list-of-change-const cadd))
  
  ;; !
  ;; .type cadd subtarget attrId change -> avc
  ;; Returns an AVC representing all the combination of attribute values found 
  ;; for the given attribute in the given comparison that are involved in a change 
  ;; that can effect the action taken by a PEP:
  ;; .internal-references "list of \"real changes\"" "list-of-real-change-const"
  (define (get-combo-attrVal-involved-in-real-change subtarget attrId cadd)
    (get-combo-attrVal-involved-in* subtarget attrId list-of-real-change-const cadd))
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Test Functions.
  ;;
  ;; These functions are for testing properties of an AVC.   These functions mirror the predicates over AVCs.  
  ;; If a predicate holds, they return true.  Otherwise, they yield counter-examples in the form of an AVC.  
  ;; If an optional fail-func is provided, they will call the fail-func with the counter-examples 
  ;; if the predicate fails to hold (instead of just returning the counter-examples). 
  ;; 
  ;; These functions are useful in testing a large number of properties since you can have the return value
  ;; of true be ignored while having the fail-func print out which test failed and the counter-example.
  ;;
  
  ;; !
  ;; .type (avc -> #t | avc) | (avc (avc -> a) -> #t | a)
  ;; If the AVC is not false it calls the fail-func with the given AVC, else true is returned. 
  ;; (If the AVC is not false, it is itself a counter-example.)
  ;; The default fail-func is the identity function, so by default, the non-false AVC is returned.
  ;; .internal-references "mirrored predicate" "avc-false?"
  (define avc-false-test
    (opt-lambda (avc [fail-func (lambda (x) x)])
      (if (avc-false? avc)
          #t
          (fail-func avc))))
  
  ;; !
  ;; .type (avc -> #t | avc) | (avc (avc -> a) -> #t | a)
  ;; If the AVC is false it calls the fail-func with the given AVC, else true is returned. 
  ;; (If the AVC is false, it is itself a counter-example.)
  ;; The default fail-func is the identity function, so by default, the false AVC is returned.
  (define avc-not-empty-test 
    (opt-lambda (avc [fail-func (lambda (x) x)])
      (if (avc-false? avc)
          (fail-func avc)
          #t)))
  ;; !
  ;; .type (avc avc -> #t | avc) | (avc avc (avc -> a) -> #t | a)
  ;; If the two AVCs are equal it calls the fail-func with the difference of the two AVCs, 
  ;; else true is returned.
  ;; The default fail-func is the identity function, so by default, the difference AVC is returned.
  ;; .internal-references "mirrored predicate" "avc-equal?"
  (define avc-equal-test
    (opt-lambda (l r [fail-func (lambda (x y) (cons x y))])
      (if (avc-equal? l r)
          #t
          (fail-func (avc-difference l r) (avc-difference r l)))))
  
  ;; !
  ;; .type (avc avc -> #t | avc) | (avc avc (avc -> a) -> #t | a)
  ;; If the first AVC does not imply the second AVC, the fail-func is called with the difference of the two AVCs,
  ;; else true is returned.
  ;; The default fail-func is the identity function, so by default, the difference AVC is returned.
  ;; .internal-references "mirrored predicate" "avc-implication?"
  (define avc-implication-test
    (opt-lambda (l r [fail-func (lambda (x) x)])
      (if (avc-implication? l r)
          #t
          (fail-func (avc-difference l r)))))
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Output.
  ;; Functions for printing string representations of AVCs, policies, and comparisons.
  ;;
  ;; The functions print-avc print-policy print-comparison and print-comparison-changes
  ;; all print string representations ADDs to standard output.  Since each node in an ADD
  ;; has a number corresponding to its place in the ordering of nodes, they all print
  ;; the ADD with nodes in order and numbered by that number.  First, a list of these nodes 
  ;; is printed in order giving to what match each node corresponds.  Second, list of rows are 
  ;; printed.  Each row consists of list of "0"s, "1"s, and "-"s.  The "0"s correspond to the
  ;; false (or else) branch of the node whose number is equal to the column number of that symbol
  ;; (see the column key at the top of the print out).  The "1"s correspond to the true (then) branches
  ;; and the "-"s to don't-care.  Each row ends in a terminal.  A sequence of matches that fit the pattern
  ;; of "0"s, "1"s, "-"s in a row is mapped to the terminal at the end of the row.
  ;;
  ;; For example,
  ;; <pre>
  ;; 1:/Resource, resource-class, paper/ 
  ;; 2:/Resource, , review/
  ;; 3:/
  ;; 12  
  ;; {
  ;; 00 N
  ;; 01 P
  ;; 1- D
  ;;
  ;; }
  ;; </pre>
  ;; states that a request without the attribute match of resource-class to paper or to review will 
  ;; receive NotApplicable, one with just the match of resource-class to review will be Permitted,
  ;; and one with a match of resource-class to paper will be Denied regardless whether it matches
  ;; review or not.
  ;;
  
  
  ;; !
  ;; .type avc ->
  ;; .form (print-avc avc)
  ;; Prints an AVC to the standard output port.
  ;; .returns void
  (define print-avc print-xradd)
  
  ;; !
  ;; .type policy ->
  ;; .form (print-policy policy)
  ;; Prints a policy to the standard output port.
  ;; .returns void
  (define print-policy print-xradd)
  
  
  ;; !
  ;; .type comparison ->
  ;; .form (print-comparison comparison)
  ;; Prints a comparison to the standard output port.
  ;; .returns void
  (define print-comparison print-xrcadd)
  
  ;; !
  ;; .type comparison ->
  ;; .form (print-comparison-changes comparison)
  ;; Prints only the parts of a comparison that deal with changes to the standard output port.
  ;; .returns void
  (define print-comparison-changes print-xrcadd-changes)
  
  ;; !
  ;; .type xradd ->
  ;; Prints a XRADD in a different more verbose format.
  ;; Note that it takes a long time and great deal of memory.
  ;; Thus, it is best to only use on "small" XRADDs,
  ;; i.e., ones with few disjuncts (rows when printed with the above methods).
 (define (print-with-names xradd)
   (printf "~a" (namedDnf->string (xradd->namedDnf xradd))))
  
  
  ;; !
  ;; .type -> (listof (listof attrId))
  ;; .form (get-all-attrIds)
  ;; return a list of lists, where the first list is for subjects, 
  ;; the second for resources, the third for actions.
  ;; Each of these lists holds all the attribute ids found in that subtarget
  ;; in one of the policies loaded.
  (define get-all-attributeIds get-all-attrId)
 
  
  ;; !
  ;; .type -> (listof (listof (pairof attrId, (listof attrValues))))
  ;; .form (get-all-attrValues)
  ;; return a list of lists, where the first list is for subjects, 
  ;; the second for resources, the third for actions.
  ;; Each these lists hold pairs. 
  ;; The first element of each pair is an attribute id 
  ;; and second is a list of all the values associated with that attribute id 
  ;; somewhere in one of policies loaded.
  (define get-all-attributeValues get-all-attrValues)
  
  ;; !
  ;; Returns a list of all the ADD variables made from the parsed policies.
  (define (get-all-vars) 
    (map matcheq:matcheq->string (get-matcheq-creation-list)))
  ;   (list (get-all-attrValues)
  ;        (track
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;
  ;; 
  ;; Extracting Invariants
  ;;
  
  
  
  ;; !
  ;; Given an AVC it will print what constraints on that AVC
  ;; always does not hold.
  (define (print-always-false-vars avc)
    (printf "~a~n" (map matcheq:matcheq->string (get-always-false-matcheqs avc))))
  
  ;; !
  ;; Given an AVC it will print what constraints on that AVC
  ;; always hold.
  (define (print-always-true-vars avc)
    (printf "~a~n" (map matcheq:matcheq->string (get-always-true-matcheqs avc))))
  
  ;; !
  ;; Given an AVC it will print what constraints on that AVC
  ;; are always irrelevant.  I.e., those which are always "don't cares"
  ;; <p><b>This function seems to broken.</b>
  (define (print-always-irrelevant-vars avc)
    (printf "~a~n" (map matcheq:matcheq->string (get-always-irrelevant-matcheqs avc))))
  
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; 
  ;; Measuring Performance.
  ;;
  
  ;; !
  ;; Prints the memory usage and size of the ADDs.
  ;; Does not give all memory use.  Only that which 
  ;; is being used by the AVC in the underlying CUDD implementation.
  ;; <p>Prints to the terminal (not DrScheme).
  (define print-add-resource-use print-radd-memory-use)
  
  
  ;  
  ;  
  ;  
  ;  
  ;  
  ;; .type subtarget * sym -> list[avc]
  ;; returns a list of sets where
  ;; each set is the set of requests
  ;; one of the attrValues associated with the attrId
  ;(define (attrValue-set-list subtarget attrId)
  ;  (map (lambda (attrVal) (make-avc subtarget attrId attrVal))
  ;       (get-all-attrValues subtarget attrId)))
  
  
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;; Not Planned for Release 1 of Version 2 ;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  
  
  
  ;  
  ;  ;; badd -> list[match]
  ;  ;; given a badd, it returns those matches (subtarget, attrId, attrValue)
  ;  ;;  found in the set to be true or don't care.
  ;  ;; If the BDD is the 0 (empty set) BDD, '() is returned
  ;  ;; since as no elements are present, no matches should be either.
  ;  ;; This might be considered wrong by some
  ;  (define (get-present-matches badd)
  ;    (if (add-equal? badd (badd-false))
  ;        '()
  ;        (filter (lambda (x) x)
  ;                (map (lambda (match in) (if in
  ;                                            #f
  ;                                            match))
  ;                     (filter matcheq:match? (get-matcheq-creation-list))
  ;                     (get-always-false badd)))))
  ;  ;(get-always-false-matches badd)))
  ;  
  ;  
  ;  ;; badd -> list[sym]
  ;  ;; returns all the attrValues that are present for that subtarget attrId
  ;  (define (get-present-attrValues subtarget attrId badd)
  ;    (map matcheq:match-attrValue 
  ;         (filter (lambda (match) (and (eq? (matcheq:match-subtarget match) subtarget)
  ;                                      (eq? (matcheq:match-attrId match) attrId)))
  ;                 (get-present-matches badd))))
  ;  
  ;  
  ;  
  ;  
  ;  ;; cadd subtarget attrId change* -> list[sym]
  ;  (define (get-attrVal-involved-in cadd subtarget attrId . change-list)
  ;    (get-attrVal-involved-in* cadd subtarget attrId change-list))
  ;  
  ;  ;; cadd subtarget attrId list[change] -> list[sym]
  ;  (define (get-attrVal-involved-in* cadd subtarget attrId change-list)
  ;    (if (empty? change-list)
  ;        '()
  ;        (util:disjoint-combine eq?
  ;                               (get-present-attrValues (add-restrict-to cadd (car change-list)) subtarget attrId)
  ;                               (get-attrVal-involved-in* cadd subtarget attrId (cdr change-list)))))
  ;  
  ;  ;; cadd subtarget attrId change -> list[sym]
  ;  (define (get-attrVal-involved-in-change subtarget attrId cadd)
  ;    (get-attrVal-involved-in* cadd subtarget attrId list-of-change-const))
  ;  
  ;  
  ;  (define (get-attrVal-involved-in-real-change subtarget attrId cadd)
  ;    (get-attrVal-involved-in* cadd subtarget attrId list-of-real-change-const))
  ;  
  ;  
  ;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;  ;;
  ;  ;; Finding Invariants in an AVC
  ;  ;;
  ;  
  ;  
  ;  (define-struct invariants (alwaysTrue  ; list[match]
  ;                             alwaysFalse
  ;                             alwaysDc))
  ;  
  ;  (define (avc-invariants avc)
  ;    ;(printf "~n false ones: ~a~n" (get-always-false-matches avc))
  ;    (make-invariants (get-always-true-matches avc)
  ;                     (get-always-false-matches avc)
  ;                     (get-always-dc-matches avc)))
  ;  
  ;  (define (invariants->string invariants)
  ;    (string-append 
  ;     "always true: " (foldr string-append "" (map matcheq:match->string (invariants-alwaysTrue invariants))) "\n"
  ;     "always false: " (foldr string-append "" (map matcheq:match->string (invariants-alwaysFalse invariants))) "\n"
  ;     "always dc: " (foldr string-append "" (map matcheq:match->string (invariants-alwaysDc invariants)))))
  ;  
  ;  ;; policy -> list[invariants]
  ;  (define (policy-invariants policy)
  ;    (list (avc-invariants (restrict-policy-to-dec 'P policy))
  ;          (avc-invariants (restrict-policy-to-dec 'D policy))
  ;          (avc-invariants (restrict-policy-to-dec 'N policy))))
  ;  
  ;  ;; list[invariants] -> string
  ;  (define (policy-invariants->string i-l)
  ;    (string-append "Permit\n" (invariants->string (first i-l))
  ;                   "\nDeny\n" (invariants->string (second i-l))
  ;                   "\nNA\n" (invariants->string (third i-l))))
  ;  
  ;  ;; policy -> list[invariants]
  ;  (define (comparison-invariants comparison)
  ;    (list (avc-invariants (restrict-comparison-to-change 'PP comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'PD comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'PN comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'PE comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'DP comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'DD comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'DN comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'DE comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'NP comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'ND comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'NN comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'NE comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'EP comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'ED comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'EN comparison))
  ;          (avc-invariants (restrict-comparison-to-change 'EE comparison))))
  ;  
  ;  
  ;  (define (comparison-invariants->string i-l)
  ;    (string-append "PP\n"   (invariants->string (util:get-element 1 i-l))
  ;                   "\nPD\n" (invariants->string (util:get-element 2 i-l))
  ;                   "\nPN\n" (invariants->string (util:get-element 3 i-l))
  ;                   "\nPE\n" (invariants->string (util:get-element 4 i-l))
  ;                   "\nDP\n" (invariants->string (util:get-element 5 i-l))
  ;                   "\nDD\n" (invariants->string (util:get-element 6 i-l))
  ;                   "\nDN\n" (invariants->string (util:get-element 7 i-l))
  ;                   "\nDE\n" (invariants->string (util:get-element 8 i-l))
  ;                   "\nNP\n" (invariants->string (util:get-element 9 i-l))
  ;                   "\nND\n" (invariants->string (util:get-element 10 i-l))
  ;                   "\nNN\n" (invariants->string (util:get-element 11 i-l))
  ;                   "\nNE\n" (invariants->string (util:get-element 12 i-l))
  ;                   "\nEP\n" (invariants->string (util:get-element 13 i-l))
  ;                   "\nED\n" (invariants->string (util:get-element 14 i-l))
  ;                   "\nEN\n" (invariants->string (util:get-element 15 i-l))
  ;                   "\nEE\n" (invariants->string (util:get-element 16 i-l))))
  ;  
  
  )