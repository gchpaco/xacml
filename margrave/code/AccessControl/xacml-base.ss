
(load-relative-extension "import.so")
;(load-extension "import.so")

(module xacml-base mzscheme
  
  (require import
           (lib "file.ss"))

  (provide (all-defined)
           (all-from import))
  
  ;(define PRINT_FNAME (string-append (current-load-relative-directory) "x0print0tmp"))
  (define DENY_VAL 2)
  (define PERMIT_VAL 3)
  (define NA_VAL 4)
  (define EC_VAL 55)
  
  ;; skip 10 and 11 because look like binary strings
  ;; also make sure that no val is substring of another due to
  ;; printing method
  (define PP_VAL 5)
  (define PD_VAL 6)
  (define PN_VAL 7)
  (define DP_VAL 8)
  (define DD_VAL 9)
  (define DN_VAL 20)
  (define NP_VAL 21)
  (define ND_VAL 22)
  (define NN_VAL 23)
  (define EP_VAL 30)
  (define EN_VAL 31)
  (define ED_VAL 32)
  (define PE_VAL 33)
  (define NE_VAL 34)
  (define DE_VAL 40)
  (define EE_VAL 41)
  
  ;; convert-xacml-output/table : string assoclist -> string
  ;; consumes a minterm line from CUDD print-minterm output and
  ;;   association list of (constant string-descr) pairs and
  ;;   replaces numberic xacml constants with descriptive names
  (define (convert-xacml-output/table str subst)
    (let loop ([alst subst] [newstr str])
      (cond [(null? alst) newstr]
            [else (loop (cdr alst)
                        (regexp-replace (caar alst) newstr (cdar alst))
                        )])))
  
  ;; string->string
  ;; If the last character of the give string is a '1', it is removed.
  (define (remove-tailing-one str)
    (let [ [rev-str (reverse (string->list str))] ]
      (list->string 
       (reverse
        (if (equal? (car rev-str) #\1)
            (cdr rev-str)
            rev-str)))))
           
  
  ;; convert-xacml-output : string -> string
  ;; consumes a minterm line from CUDD print-minterm output and
  ;;   replaces numberic xacml constants with symbolic names
  (define (convert-xacml-output str)
    (remove-tailing-one 
     (convert-xacml-output/table str (list (cons (number->string DENY_VAL) "DENY")
                                           (cons (number->string PERMIT_VAL) "PERMIT")
                                           (cons (number->string NA_VAL) "NA")
                                           (cons (number->string EC_VAL) "EC")))))
  
  (define (convert-change-output str)
    (convert-xacml-output/table str (list (cons (number->string PP_VAL) "P->P")
                                          (cons (number->string PD_VAL) "P->D")
                                          (cons (number->string PN_VAL) "P->N")
                                          (cons (number->string PE_VAL) "P->E")
                                          (cons (number->string DP_VAL) "D->P")
                                          (cons (number->string DD_VAL) "D->D")
                                          (cons (number->string DN_VAL) "D->N")
                                          (cons (number->string DE_VAL) "D->E")
                                          (cons (number->string NP_VAL) "N->P")
                                          (cons (number->string ND_VAL) "N->D")
                                          (cons (number->string NN_VAL) "N->N")
                                          (cons (number->string NE_VAL) "N->E")
                                          (cons (number->string EP_VAL) "E->P")
                                          (cons (number->string ED_VAL) "E->D")
                                          (cons (number->string EN_VAL) "E->N")
                                          (cons (number->string EE_VAL) "E->E")
                                          )))
  ;; (string -> a) -> a
  ;; where the string is a file name
  ;; calls proc passing it a temp file.
  ;; The temp file is created before calling proc
  ;; and removed after calling proc.
  (define (run-with-temp-file proc)
    (let [ [temp-file-name (make-temporary-file)] ]
      (begin0 (proc temp-file-name)
              (delete-file temp-file-name))))
    
  
  ;; xacml-print/table : ADD manager (str -> str) -> void
  ;; uses intermediate file to print out minterms for an XADD
  ;; third arg is function that converts line to XACML output
  (define (xacml-print/table add mgr table-func)
    (run-with-temp-file 
     (lambda (temp-file-name)
       (print-minterms add mgr temp-file-name)
       (with-input-from-file temp-file-name
         (lambda ()
           (let loop ()
            (let ([line (read-line)])
              (if (eof-object? line)
                  (printf "~n")
                  (begin (printf "~a~n" (table-func line))
                         (loop))))))))))
  
  
  ;; xacml-print : ADD manager -> void
  ;; uses intermediate file to print out minterms for an XADD
  (define (xacml-print add mgr)
    (xacml-print/table add mgr convert-xacml-output))
  
  ;; xacml-change-print : ADD manager -> void
  ;; uses intermediate file to print out minterms for a CADD
  (define (xacml-change-print add mgr)
    (xacml-print/table add mgr convert-change-output))
  
  ;; change-line? : string -> boolean
  ;; determine whether a minterm line string reflects a change
  (define (change-line? line-str)
    (not (ormap (lambda (val) (regexp-match (number->string val) line-str))
                (list PP_VAL DD_VAL NN_VAL EE_VAL))))
  
  ;; xacml-change-only-print : ADD manager -> void
  ;; uses intermediate file to print out change minterms for a CADD
  (define (xacml-change-only-print add mgr)
    (run-with-temp-file
     (lambda (temp-file-name)
       (print-minterms add mgr temp-file-name)
       (with-input-from-file temp-file-name
         (lambda ()
           (let loop ()
             (let ([line (read-line)])
               (if (eof-object? line)
                   (printf "~n")
                   (begin (when (change-line? line)
                            (printf "~a~n" (convert-change-output line)))
                          (loop))))))))))
  
  ;; restrict-to : ADD ADD_CONST manager -> 0-1ADD
  ;; returns 0-1ADD of all cases mapping to const from original ADD
  (define (restrict-to add const mgr)
    (cudd-add-restrict-interval add const const mgr))
  
  ;; restrict-to-permit : ADD manager -> 0-1ADD
  ;; returns 0-1ADD of all permit cases from original ADD
  (define (restrict-to-permit add mgr)
    (restrict-to add PERMIT_VAL mgr))
  
  ;; restrict-to-deny : ADD manager -> 0-1ADD
  ;; returns 0-1ADD of all deny cases from original ADD
  (define (restrict-to-deny add mgr)
    (restrict-to add DENY_VAL mgr))
  
  ;; always-false-vars : ADD manager -> list[bool]
  ;; returns list of same size (and order) of number of vars in which
  ;;   true indicates that the corresponding var is always false in the ADD
  ;;   and false indicates otherwise
  (define (always-false-vars add mgr)
    (xacml-support-indices add mgr 0))
  
  ;; always-true-vars : ADD manager -> list[bool]
  ;; returns list of same size (and order) of number of vars in which
  ;;   true indicates that the corresponding var is always true in the ADD
  ;;   and false indicates otherwise
  (define (always-true-vars add mgr)
    (xacml-support-indices add mgr 1))
  
  ;; always-dc-vars : ADD manager -> list[bool]
  ;; returns list of same size (and order) of number of vars in which
  ;;   true indicates that the corresponding var is always dc in the ADD
  ;;   and false indicates otherwise
  (define (always-dc-vars add mgr)
    (xacml-support-indices add mgr 2))
  
  )