;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   MARGRAVE                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Note: This file uses LAML SchemeDoc system (http://www.cs.auc.dk/~normark/schemedoc/).
;; The !, !!, and !!! found in comments may be ignored; 
;; they are used for auto generation of documantation.
;; The comment lines starting with "." and then a word (e.g. ".type") are also used with SchemeDoc.
;; Some comments also contain HTML tags, which are used for formatting only.
;; You should view the comments online at www.cs.brown.edu/research/plt/software/margrave/schemedocs,
;; rather than trying to understand this marked up comments.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; !!!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; .title Margrave Query Functions
;; .author Kathi Fisler (WPI), Shriram Krishnamurthi (Brown University), Leo A. Meyerovich (Brown University), and Michael Carl Tschantz (Brown University)
;;
;;
;; 
;; This is the main Scheme file for Margrave.  This file holds most the functions you will need 
;; to ask queries about AVCs, policies, and comparisions as well as to 
;; to make AVCs and comparisons, and load XACML policy files.  It loads the other required functions.
;;
;; To use Margrave, make a query file that loads this file and the module 
;; this file holds as follows:                             <br>
;;                                                         <br>
;; (load-relative "[path]/Margrave/code/Margrave.scm)      <br>
;; (require margrave)                                      <br>
;;                                                         <br>
;; where "[path]" is the path to where you installed Margrave.
;; 
;; .source-destination-delta ../../../../../../pro/web/web/people/mtschant/margrave/schemedocs/
;; .documentation-commenting-style documentation-mark
;; .keep-syntactical-comment-file true
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(read-case-sensitive #t)

(load-relative "xacml-to-ast.scm")
(load-relative "ast-to-add.scm")
(load-relative "add.scm")
(load-relative "var-tracker.scm")
(load-relative "tschantzUtil.scm")

;; !
;; The module holding query functions.  Use the Scheme command "(require margrave)" to include it in your query files.
(module margrave mzscheme

  (require (lib "etc.ss")                    ; helper functions
           (lib "list.ss")                   ; helper functions
           (prefix xacml2ast: xacml-to-ast)  ; parsing
           (prefix ast2add: ast-to-add)      ; make adds
           (prefix util: tschantzUtil)       ; helper functions
           add                               ; working with adds
           (prefix track: var-tracker))      ; tracking nodes of adds
  
  (provide (all-defined))
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Constants
  ;;
  
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
  ;; that yeilds either not appliacable or deny, so the PEP will do the same thing either way.
  (define list-of-real-change-const (list 'PD 'PN 'PE 'DP 'DE 'NP 'NE 'EP 'ED 'EN))
  
  
  ;; A rSet is a BDD representation of a set of requests
  ;; A Policy is a XADD representation of a XACML policy.
  ;; Note by BDD, I really mean a 0-1-ADD
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Parsing in XACML files.
  ;;
  
  ;; !
  ;; .type string * string * [bool] -> policy
  ;; 
  ;; allows parsing in one step.
  ;; .comment the only function to use anything from the xacml2ast or ast2add modules
  (define load-xacml-policy
    (opt-lambda (dir file [verbose? #f])
      (ast2add:ast->add (xacml2ast:xacml->ast (string-append dir file) dir verbose?))))
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; 
  ;; Creating AVCs.
  ;; Functions for creating attribute value constraints.
  ;;
  
  
  ;; !
  ;; .type sym sym sym [bool] -> avc
  ;; .sem (lambda (s i v) {(s, i, v)})
  ;; a set of requests including all
  ;; requests that have the given attrValue assigned to the given attrId 
  ;; in the given subtarget.
  (define (make-avc subtarget attrId attrValue)
    (make-var subtarget attrId attrValue))
  
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
                                            (track:get-all-attrValues subtarget attrId)))))))
  
  ;; !
  ;; Given a match, it will return the corresponding AVC.
  ;; Note that (make-avc aSubtarget anAttrId anAttrValue) does return
  ;; the same AVC as (match->avc (make-match aSubtarget anAttrId anAttrValue))
  (define (match->avc match)
    (make-avc (track:match-subtarget match) (track:match-attrId match) (track:match-attrValue match)))
  
  ;; !
  ;; Like make-avc-singleton but takes a match instead.
  (define (match->avc-singleton . match-list)
    (avc-and (avc-and* (map match->avc match-list))
             (avc-and* 
              (map avc-not
                   (map match->avc (filter (lambda (x) 
                                             (not (util:member? x match-list track:match=?))) 
                                           (track:get-match-creation-list)))))))
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; AVC Connectives.
  ;; These mirror the boolean connectives.
  ;; One might find it easier to think of these as set opperations
  ;; where each AVC is a set of requests or matches.
  ;; For example, avc-or may be thought of as a union.
  ;;
  
  ;; !
  ;; .type avc -> avc
  ;; .sem (lambda (rs) {r in Req | r not in rs})
  ;; Returns that complement of the given AVC.
  (define (avc-not avc)
    (bdd-not avc))
  
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
    (foldr bdd-or bdd-false l)) 
  
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
    (foldr bdd-and bdd-true l))
  
  
  ;; !
  ;; .type avc avc -> avc
  ;; .sem (lambda (rs rs') {r in Req | r in rs and r not in rs'})
  ;; Returns the AVC that is the difference between l and r.
  ;; {x in l | x not in r} = l intersect (compl r)
  (define (avc-difference l r)
    (avc-and l (avc-not r)))
  
  
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
    (avc-equal? avc bdd-false))
  
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
  ;; Makes bdd into E b in bool such that bdd[avc -> b].
  ;; Existance quantification over an avc:
  ;; does there exist a value for this match (has it or does not have it)
  ;; such that true is yielded. Maybe a better name would be "don't-care-out-match".
  ;; .internal-references "list version" "there-exists-for*"
  (define (there-exists-for avc . match-list)
    (there-exists-for* avc match-list))
  
  ;; !
  ;; .type avc (listof match) -> avc
  ;; Makes the given AVC into E b in bool s.t. bdd[avc -> b]
  ;; Existance quantification over an avc,
  ;; does there exist a value for this match (has it or does not have it)
  ;; such that true is yielded.
  ;; .internal-references "non-list version" "there-exists-for"
  (define (there-exists-for* avc match-list)
    (if (empty? match-list)
        avc
        (there-exists-for* (bdd-or (cudd-constrain-add (match->avc (car match-list)) avc)
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
        (for-all* (bdd-and (cudd-constrain-add (match->avc (car match-list)) avc)
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
  ;; .returns A symbol, either 'P, 'D, 'N, 'E, for permit, deny, not applicable, or excluded by constraint, respectivily.
  ;; .precondition The avc should be an exact avc, i.e., an avc that contains only one distinguishable request.
  (define (PDP policy request)
    (cond [(avc-implication? request (restrict-policy-to-dec 'P policy)) 'P]
          [(avc-implication? request (restrict-policy-to-dec 'D policy)) 'D]
          [(avc-implication? request (restrict-policy-to-dec 'N policy)) 'N]
          [(avc-implication? request (restrict-policy-to-dec 'E policy)) 'E]
          [else (error 'PDP "insufficent information provided in the avc to determine its decision.  (i.e., the avc given includes requests that are mapped to different decisions)")]))
  
  
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
  (define (restrict-policy-to-dec decision policy)
    (add-restrict-to policy decision))
  
  ;; !
  ;; .type comparison decision -> avc
  ;; .sem (lambda (comp chg) = {r in Req | (comp r) = chg})
  ;; Get the AVC that corresponds to the terminal in which you are interested from a policy or comparison.
  (define (restrict-comparision-to-change change comparision)
    (add-restrict-to comparision change))
  
  
  ;; !!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Constraining Policies.
  ;; Rule some requests out of consideration by introducing environment contraints.
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
  ;; like disjoint, but all requests must lay in one
  ;; .internal-references "" "constrain-policy-disjoint"
  (define (constrain-policy-partition avc-list policy)
    (constrain-policy (partition-set* avc-list) policy))
  
  ;; !
  ;; .type policy subtarget sym -> policy
  ;; .sem (lambda (p st i) (lambda (r in Req) (if (there exists (st, i, v), (st, i, v') in r s.t. v != v') 'EC (p r)))) 
  ;; .precondition might be load senitive.  To avoid problems, make sure you load all the XACML files before using this function.
  ;; make nonmulti-attribute : must have one or zero and no more
  ;; <br>For example:<br> You know that every request will have at most one value associated with the resource-id attribute so place a make-nonmulti-attribute constraint on the policy Pol with "(make-nonmulti-attribute 'Resource 'resource-id Pol)".
  ;; .internal-references "list version" "make-nonmulti-attribute*"
  (define (make-nonmulti-attribute subtarget attrId policy)
    (constrain-policy-disjoint (map (lambda (attrVal) (make-avc subtarget attrId attrVal))
                                    (track:get-all-attrValues subtarget attrId))
                               policy))
  
  ;; !
  ;; .type (listof (pair subtarget sym)) policy -> policy
  ;; .internal-references "non-list version" "make-nonmulti-attribute"
  (define (make-nonmulti-attribute* list-s-id policy)
    (foldr (lambda (s-id new-policy) (make-nonmulti-attribute (first s-id) (second s-id) new-policy)) 
           policy 
           list-s-id)) 
  
  ;; !
  ;; .type policy subtarget sym -> policy
  ;; .precondition might be time senitive
  ;; make single-valued attribute : must have exactly one
  ;; <br>For example:<br> You know that every request will have exactly one value assocated with the resource-id attribute so place a make-nonmulti-attribute contraint on the policy Pol with "(make-nonmulti-attribute 'Resource 'resource-id Pol)".
  ;; .internal-references "list version" "make-singleton-attribute*"
  (define (make-singleton-attribute subtarget attrId policy)
    (constrain-policy-partition (map (lambda (attrVal) (make-avc subtarget attrId attrVal))
                                     (track:get-all-attrValues subtarget attrId))
                                policy))
  ;; !
  ;; .type (listof (pair subtarget sym)) policy -> policy
  ;; .internal-references "non-list version" "make-singleton-attribute"
  (define (make-singleton-attribute* list-s-id policy)
    (foldr (lambda (s-id new-policy) (make-singleton-attribute (first s-id) (second s-id) new-policy)) 
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
  (define (present-combo-attrValues subtarget attrId avc)
    (there-exists-for* avc 
                       (filter (lambda (match) 
                                 (not (and (eq? subtarget (track:match-subtarget match))
                                           (eq? attrId (track:match-attrId match)))))
                               (track:get-match-creation-list))))
  
  ;; !
  ;; .type subtarget attrId termial (| policy comparision) -> avc
  ;; .internal-references "list version" "make-singleton-attribute*"
  (define (get-combo-attrVal-involved-in subtarget attrId change cadd)
    (get-combo-attrVal-involved-in* subtarget attrId (list change) cadd))
  
  ;; !
  ;; .type subtarget attrId (listof termial) (| policy comparision) -> avc
  ;; .internal-references "non-list version" "make-singleton-attribute"
  (define (get-combo-attrVal-involved-in* subtarget attrId change-list cadd)
    (if (empty? change-list)
        bdd-false
        (avc-or (present-combo-attrValues subtarget attrId (restrict-comparision-to-change (car change-list) cadd))
                (get-combo-attrVal-involved-in* subtarget attrId (cdr change-list) cadd))))
  
  ;; !
  ;; .type cadd subtarget attrId change -> avc
  (define (get-combo-attrVal-involved-in-change subtarget attrId cadd)
    (get-combo-attrVal-involved-in* subtarget attrId list-of-change-const cadd))
  
  ;; !
  ;; .type cadd subtarget attrId change -> avc
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
  ;; of true be ignorged while having the fail-func print out which test failed and the counter-example.
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
  ;; printed.  Each row consists of list of "0"s, "1"s, and "-"s.  The "0"s correpond to the
  ;; false (or else) branch of the node whose number is equal to the column number of that symbol
  ;; (see the column key at the top of the print out).  The "1"s correspond to the true (then) branches
  ;; and the "-"s to don't-care.  Each row ends in a terminal.  A sequence of matchs that fit the pattern
  ;; of "0"s, "1"s, "-"s in a row is mapped to the terminal at the end of the row.
  ;;
  ;; For example,
  ;; <pre>
  ;; 1:/Resource, resource-class, paper/ 2:/Resource, resource-class, review/
  ;; 12  
  ;; {
  ;; 00 N
  ;; 01 P
  ;; 1- D
  ;;
  ;; }
  ;; </pre>
  ;; states that a request without the attribute match of resource-class to paper or to review will 
  ;; recieve NotApplicable, one with just the match of resource-class to review will be Permitted,
  ;; and one with a match of resource-class to paper will be Denied regardless whether it matches
  ;; review or not.
  ;;
  
  
  ;; !
  ;; .type avc ->
  ;; .form (print-avc avc)
  ;; Prints an AVC to the standard output port.
  ;; .returns void
  (define print-avc print-xadd)
  
  ;; !
  ;; .type policy ->
  ;; .form (print-policy policy)
  ;; Prints a policy to the standard output port.
  ;; .returns void
  (define print-policy print-xadd)
  
  
  ;; !
  ;; .type comparison ->
  ;; .form (print-comparison comparison)
  ;; Prints a comparison to the standard output port.
  ;; .returns void
  (define print-comparison print-cadd)
  
  ;; !
  ;; .type comparison ->
  ;; .form (print-comparison-changes comparison)
  ;; Prints only the parts of a comparison that deal with changes to the standard output port.
  ;; .returns void
  (define print-comparison-changes print-cadd-changes)
  
  
  
  (define-struct constraint (subtarget
                             attrId
                             attrValue
                             isMember?))
  
  (define-struct namedDnfTerm (constraintList  ;; a list of 'True 'False 'DontCare
                               decision)) ;; a decision 'Permit, 'Deny 'NotApplicable
  
  
  
  
  ;; rawDnf = list[rawDnfTerm] = list[(list[sym], dec)] -> namedDnf = list[namedDnfTerm] = list[(list[constraint], dec)] = list[(list[(sym, sym, sym, bool)], dec)]
  (define (rawDnf->namedDnf raw-dnf)
    (map (lambda (raw-dnf-term)
           (make-namedDnfTerm (filter (lambda (x) x)
                                      (map (lambda (val match) 
                                             (cond [(symbol=? val 'True) (make-constraint (track:match-subtarget match)
                                                                                          (track:match-attrId match)
                                                                                          (track:match-attrValue match)
                                                                                          #t)] 
                                                   
                                                   [(symbol=? val 'False) (make-constraint (track:match-subtarget match)
                                                                                           (track:match-attrId match)
                                                                                           (track:match-attrValue match)
                                                                                           #f)]
                                                   [(symbol=? val 'DontCare) #f]
                                                   [else (error 'raw-dnf->named-dnf 
                                                                "a value in the raw-dnf is unknown.  That value is: ~a" 
                                                                val)])) 
                                           (rawDnfTerm-valueList raw-dnf-term)
                                           (track:get-match-creation-list)))
                              (rawDnfTerm-decision raw-dnf-term)))
         raw-dnf))
  
  (define (constraint->string constraint)
    (let [ [term (if (constraint-isMember? constraint)
                     "+"
                     "-")] ]
      (string-append term
                     (symbol->string (constraint-subtarget constraint))
                     ", "
                     (symbol->string (constraint-attrId constraint))
                     ", "
                     (symbol->string (constraint-attrValue constraint))
                     term)))
  
  (define (namedDnfTerm->string named-dnf-term)
    (string-append (foldr string-append "" (map constraint->string (namedDnfTerm-constraintList named-dnf-term)))
                   " => "
                   (symbol->string (namedDnfTerm-decision named-dnf-term))))
  
  
  (define (namedDnf->string named-dnf)
    (foldr (lambda (term rest) (string-append term "~n" rest))
           ""
           (map namedDnfTerm->string named-dnf)))
  
  (define (policy->namedDnf-string policy)
    (namedDnf->string (rawDnf->namedDnf (add->rawDnf policy))))
  
  ;; !
  ;; .type policy ->
  ;; Another string representation of a policy that is printed to standard output.
  ;; .returns void
  (define (print-policy-as-namedDnf policy)
    (map (lambda (named-dnf-term) 
           (printf "~a~n" (namedDnfTerm->string named-dnf-term)))
         (rawDnf->namedDnf (add->rawDnf policy))))
  
  
  ;; !
  ;; .type -> (listof (listof attrId))
  ;; .form (get-all-attrIds)
  ;; return a list of lists, where the first list is for subjects, 
  ;; the second for resources, the third for actions.
  ;; Each of these lists holds all the attribute ids found in that subtarget
  ;; in one of the policies loaded.
  (define get-all-attrIds track:get-all-attrId)

  ;; !
  ;; .type -> (listof (listof (pairof attrId, (listof attrValues))))
  ;; .form (get-all-attrValues)
  ;; return a list of lists, where the first list is for subjects, 
  ;; the second for resources, the third for actions.
  ;; Each these lists hold pairs. 
  ;; The first element of each pair is an attribute id 
  ;; and second is a list of all the values assocated with that attribute id 
  ;; somewhere in one of policies loaded.
  (define get-all-attrValues track:get-all-attrValues)
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Not Planned for Release 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  
  
  
  
  ;;;;;;;;;;;;;;;;;;;;;
  ;; 
  ;; Extracting Infomation
  ;;
  
  
  ;; .type subtarget * sym -> list[avc]
  ;; returns a list of sets where
  ;; each set is the set of requests
  ;; one of the attrValues associated with the attrId
  (define (attrValue-set-list subtarget attrId)
    (map (lambda (attrVal) (make-avc subtarget attrId attrVal))
         (track:get-all-attrValues subtarget attrId)))
  
  
  
  ; list[bool] -> list[match]
  (define (get-indicated-matchs indicator)
    ;(printf "get-indicated-matchs: ~a" (foldr string-append "" (map (lambda (b) (if b "t" "f")) indicator)))
    (filter (lambda (x) x)
            (map (lambda (match in) (if in
                                        match
                                        #f))
                 (track:get-match-creation-list) 
                 indicator)))
  
  (define (get-always-false-matches bdd)
    (get-indicated-matchs (get-always-false bdd)))
  
  (define (get-always-true-matches bdd)
    (get-indicated-matchs (get-always-true bdd)))
  
  (define (get-always-dc-matches bdd)
    (get-indicated-matchs (get-always-dc bdd)))
  
  ;; bdd -> list[match]
  ;; given a bdd, it returns those matches (subtarget, attrId, attrValue)
  ;;  found in the set to be true or don't care.
  ;; If the BDD is the 0 (empty set) BDD, '() is returned
  ;; since as no elements are present, no matches should be either.
  ;; This might be considered wrong by some
  (define (get-present-matches bdd)
    (if (add-equal? bdd bdd-false)
        '()
        (filter (lambda (x) x)
                (map (lambda (match in) (if in
                                            #f
                                            match))
                     (track:get-match-creation-list) 
                     (get-always-false bdd)))))
  ;(get-always-false-matches bdd)))
  
  
  ;; bdd -> list[sym]
  ;; returns all the attrValues that are present for that subtarget attrId
  (define (get-present-attrValues subtarget attrId bdd)
    (map track:match-attrValue 
         (filter (lambda (match) (and (eq? (track:match-subtarget match) subtarget)
                                      (eq? (track:match-attrId match) attrId)))
                 (get-present-matches bdd))))
  
  
  
  
  ;; cadd subtarget attrId change* -> list[sym]
  (define (get-attrVal-involved-in cadd subtarget attrId . change-list)
    (get-attrVal-involved-in* cadd subtarget attrId change-list))
  
  ;; cadd subtarget attrId list[change] -> list[sym]
  (define (get-attrVal-involved-in* cadd subtarget attrId change-list)
    (if (empty? change-list)
        '()
        (util:disjoint-combine eq?
                               (get-present-attrValues (add-restrict-to cadd (car change-list)) subtarget attrId)
                               (get-attrVal-involved-in* cadd subtarget attrId (cdr change-list)))))
  
  ;; cadd subtarget attrId change -> list[sym]
  (define (get-attrVal-involved-in-change subtarget attrId cadd)
    (get-attrVal-involved-in* cadd subtarget attrId list-of-change-const))
  
  
  (define (get-attrVal-involved-in-real-change subtarget attrId cadd)
    (get-attrVal-involved-in* cadd subtarget attrId list-of-real-change-const))
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;
  ;; Finding Invariants in an AVC
  ;;
  
  
  (define-struct invariants (alwaysTrue  ; list[match]
                             alwaysFalse
                             alwaysDc))
  
  (define (avc-invariants avc)
    ;(printf "~n false ones: ~a~n" (get-always-false-matches avc))
    (make-invariants (get-always-true-matches avc)
                     (get-always-false-matches avc)
                     (get-always-dc-matches avc)))
  
  (define (invariants->string invariants)
    (string-append 
     "always true: " (foldr string-append "" (map track:match->string (invariants-alwaysTrue invariants))) "\n"
     "always false: " (foldr string-append "" (map track:match->string (invariants-alwaysFalse invariants))) "\n"
     "always dc: " (foldr string-append "" (map track:match->string (invariants-alwaysDc invariants)))))
  
  ;; policy -> list[invariants]
  (define (policy-invariants policy)
    (list (avc-invariants (restrict-policy-to-dec 'P policy))
          (avc-invariants (restrict-policy-to-dec 'D policy))
          (avc-invariants (restrict-policy-to-dec 'N policy))))
  
  ;; list[invariants] -> string
  (define (policy-invariants->string i-l)
    (string-append "Permit\n" (invariants->string (first i-l))
                   "\nDeny\n" (invariants->string (second i-l))
                   "\nNA\n" (invariants->string (third i-l))))
  
  ;; policy -> list[invariants]
  (define (comparision-invariants comparision)
    (list (avc-invariants (restrict-comparision-to-change 'PP comparision))
          (avc-invariants (restrict-comparision-to-change 'PD comparision))
          (avc-invariants (restrict-comparision-to-change 'PN comparision))
          (avc-invariants (restrict-comparision-to-change 'PE comparision))
          (avc-invariants (restrict-comparision-to-change 'DP comparision))
          (avc-invariants (restrict-comparision-to-change 'DD comparision))
          (avc-invariants (restrict-comparision-to-change 'DN comparision))
          (avc-invariants (restrict-comparision-to-change 'DE comparision))
          (avc-invariants (restrict-comparision-to-change 'NP comparision))
          (avc-invariants (restrict-comparision-to-change 'ND comparision))
          (avc-invariants (restrict-comparision-to-change 'NN comparision))
          (avc-invariants (restrict-comparision-to-change 'NE comparision))
          (avc-invariants (restrict-comparision-to-change 'EP comparision))
          (avc-invariants (restrict-comparision-to-change 'ED comparision))
          (avc-invariants (restrict-comparision-to-change 'EN comparision))
          (avc-invariants (restrict-comparision-to-change 'EE comparision))))
  
  
  (define (comparision-invariants->string i-l)
    (string-append "PP\n" (invariants->string (util:get-element 1 i-l))
                   "\nPD\n" (invariants->string (util:get-element 2 i-l))
                   "\nPN\n" (invariants->string (util:get-element 3 i-l))
                   "\nPE\n" (invariants->string (util:get-element 4 i-l))
                   "\nDP\n" (invariants->string (util:get-element 5 i-l))
                   "\nDD\n" (invariants->string (util:get-element 6 i-l))
                   "\nDN\n" (invariants->string (util:get-element 7 i-l))
                   "\nDE\n" (invariants->string (util:get-element 8 i-l))
                   "\nNP\n" (invariants->string (util:get-element 9 i-l))
                   "\nND\n" (invariants->string (util:get-element 10 i-l))
                   "\nNN\n" (invariants->string (util:get-element 11 i-l))
                   "\nNE\n" (invariants->string (util:get-element 12 i-l))
                   "\nEP\n" (invariants->string (util:get-element 13 i-l))
                   "\nED\n" (invariants->string (util:get-element 14 i-l))
                   "\nEN\n" (invariants->string (util:get-element 15 i-l))
                   "\nEE\n" (invariants->string (util:get-element 16 i-l))))
  
  )