;; Some datastructs
(module matcheq mzscheme
  
  (require "../lib/errorf.scm"
           (prefix util: "../lib/tschantz-util.scm")
           (lib "list.ss"))
  
  (provide (all-defined))
  
  ;;
  ;; Custom Structures
  ;;
  
  
  (define-struct match (subtarget
			attrId
			attrValue))
  
  (define (match=? m n)
    (and (eq? (match-subtarget m) (match-subtarget n))
         (eq? (match-attrId m) (match-attrId n))
         (eq? (match-attrValue m) (match-attrValue n))))
  
  (define-struct equality (lSubtarget
                           lAttrId
                           rSubtarget
                           rAttrId))
  
  
  (define (equality=? m n)
    (and (eq? (equality-lSubtarget m) (equality-lSubtarget n))
         (eq? (equality-lAttrId m) (equality-lAttrId n))
         (eq? (equality-rSubtarget m) (equality-rSubtarget n))
         (eq? (equality-rAttrId m) (equality-rAttrId n))))
  
  
  (define (match->string match)
    (string-append "/"                    
                   (symbol->string (match-subtarget match)) 
                   ", " 
                   (symbol->string (match-attrId match)) 
                   ", " 
                   (symbol->string (match-attrValue match)) 
                   "/"))
  
  (define (equality->string equality)
    (string-append "/"                    
                   (symbol->string (equality-lSubtarget equality)) 
                   ", " 
                   (symbol->string (equality-lAttrId equality)) 
                   " = " 
                   (symbol->string (equality-rSubtarget equality)) 
                   ", " 
                   (symbol->string (equality-rAttrId equality)) 
                   "/"))
  
  (define (matcheq->string matcheq)
    (cond [(match? matcheq) (match->string matcheq)]
          [(equality? matcheq) (equality->string matcheq)]
          [else (errorf "Expects a match or an equality.  Given: ~s" matcheq)]))
  
  ;; The following are not used very often
  ;; Good for the representations of policies other than ADDs
  ;; that are used for printing.
  
  (define-struct matcheqConstraint (matcheq
                                    pos?)) ; either true or false.  True iff the constraint is a positive one.
  
  (define (matcheqConstraint->string constr)
    (let [ [term (if (matcheqConstraint-pos? constr)
                     "1"
                     "0")] ]
      (string-append term
                     " "
                     (matcheq->string (matcheqConstraint-matcheq constr)))))
  
  (define (matcheqDdPath->string dd-path)
    (string-append (apply string-append
                          (util:insert-between-elements "\n"
                                                        (map matcheqConstraint->string (first dd-path))))
                   "\n ==> \n"
                   (symbol->string (second dd-path))))
  
  
        
  
  
  )