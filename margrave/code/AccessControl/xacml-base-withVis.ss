(load-relative "xacml-base.ss")

(module xacml-base-withVis mzscheme
  
  (require (lib "14.ss" "srfi")
           (lib "list.ss")
           xacml-base)
  
  (provide (all-defined)
           (all-from xacml-base))
  
  
  ;; char-set -> symbol
  ;; convert the value of a terminal of an add represented as a charset into an english symbol
  (define (char-set-number-to-authorization ans)
    (let ( (eq (lambda (num1 list2) (char-set= (string->char-set (number->string num1)) list2))))
      (cond [(eq DENY_VAL ans) 'D]
            [(eq PERMIT_VAL ans) 'P]
            [(eq NA_VAL ans) 'N]
            [(eq PP_VAL ans) 'PP]
            [(eq PN_VAL ans) 'PN]
            [(eq PD_VAL ans) 'PD]
            [(eq NP_VAL ans) 'NP]
            [(eq NN_VAL ans) 'NN]
            [(eq ND_VAL ans) 'ND]
            [(eq DP_VAL ans) 'DP]
            [(eq DN_VAL ans) 'DN]
            [(eq DD_VAL ans) 'DD]
            [(eq 0 ans) 'F]
            [(eq 1 ans) 'T]
            [else (error 'char-set-number-to-authorization "unknown constant value: ~a to c ~a or d ~a " ans)])))
  
  ;; A dnf is a list of dnf-terms
  (define-struct rawDnfTerm (valueList ;; a list of 'True 'False 'DontCare
                             decision)) ;; a decision 'Permit, 'Deny 'NotApplicable
  
  ;; int resList charList -> resList 'authorization
  ;; takes existing string-to-var conversions and makes next, ending with an authorization conversion when whitespace is hit
  ;; note that variable count is 0-bound in this structure
  ;; assumption that in the input file, there is a space before the authorization
  (define (string-to-rawDnfTerm-helper count resList lineList)
    (let ( (hd (car lineList)) (tl (cdr lineList)) (count2 (+ 1 count)))
      (cond [(char-whitespace? hd) (make-rawDnfTerm (reverse resList) (char-set-number-to-authorization  (list->char-set(cdr tl))))]
            [(char=? hd #\-) (string-to-rawDnfTerm-helper count2 (cons 'DontCare resList) tl)]
            [(char=? hd #\0) (string-to-rawDnfTerm-helper count2 (cons 'False resList) tl)]
            [(char=? hd #\1) (string-to-rawDnfTerm-helper count2 (cons 'True resList) tl)]
            [else (error 'string-to-rawDnfTerm-helper "unrecognized character in file: ~a" hd)])))
  
  ;; charList -> 
  ;; takes a string from a CUDD output file and converts it to the form (0 1 -1) 'authorization
  (define (string-to-rawDnfTerm line)
    (string-to-rawDnfTerm-helper 0 empty line))
  
  ;; add manager -> list[rawDnfTerm]
  ;; convert an add to a list of the form ( ((0 1 -1) 'authorization) ... )
  (define (add-to-rawDnf add mgr)
    (run-with-temp-file
     (lambda (temp-file-name)
       (print-minterms add mgr temp-file-name)
       (with-input-from-file temp-file-name
         (lambda ()
           (let loop() 
             (let ([line (read-line)])
               (if (eof-object? line)
                   empty
                   (cons (begin (string-to-rawDnfTerm (string->list line))) (loop))))))))))
  
  )