(module invariants mzscheme

  (require "xradd.scm"
           (lib "list.ss"))
  (provide (all-defined))
  
; list[bool] -> list[match]
;  (define (get-indicated-matchs indicator)
;    ;(printf "get-indicated-matchs: ~a" (foldr string-append "" (map (lambda (b) (if b "t" "f")) indicator)))
;    (filter (lambda (x) x)
;            (map (lambda (match in) (if in
;                                        match
;                                        #f))
;                 (filter matcheq:match? (get-matcheq-creation-list))
;                 indicator)))
  
  
  (define (get-indicated-matcheqs indicator)
    (filter (lambda (x) x)
            (map (lambda (matcheq in)
                   (if in
                       matcheq
                       #f))
                 (get-matcheq-creation-list)
                 indicator)))
  
  (define (get-always-false-matcheqs bdd)
    (get-indicated-matcheqs (get-always-false bdd)))
   
  (define (get-always-true-matcheqs bdd)
    (get-indicated-matcheqs (get-always-true bdd)))
  
  (define (get-always-irrelevant-matcheqs bdd)
    (get-indicated-matcheqs (get-always-dc bdd)))
  
;  (define (get-always-false-matches bdd)
;    (get-indicated-matchs (get-always-false bdd)))
;  
;  (define (get-always-true-matches bdd)
;    (get-indicated-matchs (get-always-true bdd)))
;  
;  (define (get-always-dc-matches bdd)
;    (get-indicated-matchs (get-always-dc bdd)))
  
  )