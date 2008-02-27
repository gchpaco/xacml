(module xacml-cudd mzscheme
  
  (require (lib "foreign.ss")
           (lib "etc.ss"))
  
  (unsafe!)
  
  (provide  make-dd-manager
            xacml-new-var
            xacml-permit
            xacml-deny
            xacml-na
            xacml-ec
            xacml-augment-rule
            combine-permit-override
            combine-deny-override
            combine-first-applicable
            xacml-and
            xacml-or
            xacml-not
            print-minterms
            xacml-false
            xacml-true
            cudd-add-constrain
            xadd-assume
            cudd-add-restrict-interval
            xacml-change-merge
            xacml-support-indices
            xacml-equal?
            xadd-na-to-deny
            add-size
            total-number-of-vars
            total-memory-use)
            
            
  
  (define c-lib (ffi-lib (build-path (this-expression-source-directory) "xacmlCudd")))
  ;(define c-lib (ffi-lib "xacmlCudd"))
  
  ;(define _DdManager _pointer) ; A _DdManager is a pointer to the C type DdManager
  ;(define _DdNode _pointer)    ; same as above
  
  (define-cpointer-type _DdManager)
  (define-cpointer-type _DdNode)
  (define-cpointer-type _ADD _DdNode)
  
  ;; A 0-1 ADD as CUDD calls them (i.e., a ADD with only two terminals: the int 1 and the int 0).  
  ;; Not the a real BDD for techecal reasons
  (define-cpointer-type _BADD _ADD) 
  
  ;; A ADD with terminals for permit, deny, not applicable, and excluded by contraint
  (define-cpointer-type _XADD _ADD)
  
  ;; A ADD with terminals for permit to permit, permit to deny, ...
  (define-cpointer-type _CADD _ADD)

  
  (define make-dd-manager
    (get-ffi-obj "Xacml_make_dd_manager" c-lib
                 (_fun -> _DdManager)))
  
  (define xacml-new-var
    (get-ffi-obj "Cudd_addNewVar" c-lib
                 (_fun _DdManager -> _BADD)))
  
  (define xacml-permit
    (get-ffi-obj "XACML_ADD_PERMIT_CONST" c-lib
                 (_fun _DdManager -> _XADD)))
  
  (define xacml-deny
    (get-ffi-obj "XACML_ADD_DENY_CONST" c-lib
                 (_fun _DdManager -> _XADD)))
  
  (define xacml-na
    (get-ffi-obj "XACML_ADD_NA_CONST" c-lib
                 (_fun _DdManager -> _XADD)))
  
  (define xacml-ec
    (get-ffi-obj "XACML_ADD_EC_CONST" c-lib
                 (_fun _DdManager -> _XADD)))
  
  (define xacml-augment-rule 
    (get-ffi-obj "Xacml_ADD_Augment_Rule" c-lib
                 (_fun _DdManager _BADD _XADD -> _XADD)))
  
  (define combine-permit-override
    (get-ffi-obj  "Xacml_ADD_PermitOverride" c-lib
                  (_fun _DdManager _XADD _XADD -> _XADD)))
  
  
  (define combine-deny-override
    (get-ffi-obj  "Xacml_ADD_DenyOverride" c-lib
                  (_fun _DdManager _XADD _XADD -> _XADD)))
  
  
  (define combine-first-applicable
    (get-ffi-obj  "Xacml_ADD_FirstApplicable" c-lib
                  (_fun _DdManager _XADD _XADD -> _XADD)))
  
  (define xacml-and
    (get-ffi-obj "Xacml_ADD_LogicalAnd"  c-lib
                 (_fun _DdManager _BADD _BADD -> _BADD)))
  
  (define xacml-or
    (get-ffi-obj "Xacml_ADD_LogicalOr"  c-lib
                 (_fun _DdManager _BADD _BADD -> _BADD)))
  
  (define xacml-not
    (get-ffi-obj "Xacml_ADD_LogicalNot"  c-lib
                 (_fun _DdManager _BADD -> _BADD)))
  
  (define print-minterms
    (get-ffi-obj "Xacml_print_minterms" c-lib
                 (_fun _DdManager _DdNode _string -> _void)))
  
  (define xacml-false
    (get-ffi-obj "Cudd_ReadZero" c-lib
                 (_fun _DdManager -> _BADD))) ; a BDD since arithmic 0 is not the same as logical 0 (false)
  
  (define xacml-true
    (get-ffi-obj "Cudd_ReadOne" c-lib
                 (_fun _DdManager -> _BADD))) ; actually, this is also a BDD since logical 1 (true) and arithmic 1 are the same
    
  (define cudd-add-constrain
    (get-ffi-obj "Cudd_addConstrain" c-lib
                 (_fun _DdManager _BADD _BADD -> _BADD)))
  ;  mgn * to be contrainted * contriant -> contrainted
  
  (define xadd-assume
    (get-ffi-obj "Xacml_XADD_Assume" c-lib
                 (_fun _DdManager _XADD _BADD -> _XADD)))
  
  
  (define cudd-add-restrict-interval
   (get-ffi-obj "Xacml_bdd_add_interval" c-lib
                (_fun _DdManager _ADD _int _int -> _BADD)))
  
  (define xacml-change-merge
    (get-ffi-obj "Xacml_ADD_ChangeMerge" c-lib
                 (_fun _DdManager _XADD _XADD -> _CADD)))
  
  (define total-number-of-vars
    (get-ffi-obj "Cudd_ReadSize" c-lib
                 (_fun _DdManager -> _int)))
  
  ;(define xacml-support-indices-help
    ;(get-ffi-obj "Xacml_support_indices" c-lib
    ;             (_fun _DdManager _DdNode _int -> _scheme))) ; thats a scheme list for output
  
  (define (xacml-support-indices dd n i)
    (let* [ [list-length (total-number-of-vars dd)] 
            [funct (get-ffi-obj "Xacml_support_indicies" c-lib
                                (_fun _DdManager _DdNode _int -> (_list o _bool list-length)))] ]
            (funct dd n i)))
  
  (define xacml-equal?
    (get-ffi-obj "Xacml_bdd_equal" c-lib
                 (_fun _DdNode _DdNode -> _bool)))
  
  (define xadd-na-to-deny
    (get-ffi-obj "Xacml_NAtoDeny" c-lib
                 (_fun _DdManager _XADD -> _XADD)))
  
  ;(define xacml-stats
  ;  (get-ffi-obj "Cudd_Print_Stats" c-lib
  ;               (_fun _DdManager _DdNode -> _void)))
  
  ;; the number of nodes
  (define add-size
    (get-ffi-obj "Cudd_DagSize" c-lib
                 (_fun _ADD -> _int)))
  
  ;; in bytes
  (define  total-memory-use
    (get-ffi-obj "Cudd_ReadMemoryInUse" c-lib
                 (_fun _DdManager -> _ulong)))
  
 
  )