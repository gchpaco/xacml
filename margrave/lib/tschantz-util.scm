(module tschantz-util mzscheme
  
  (require (lib "list.ss") 
           (lib "etc.ss"))
  
  (provide (all-defined))
   

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; printing
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (define (printf-through format-string elem . rst)
    (apply printf (cons format-string (cons elem rst)))
    elem)
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; strings
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  (define (repeat-string number str)
    (if (zero? number)
        ""
        (string-append str (repeat-string (sub1 number) str))))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; symbols
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  (define (symbol<=? lSymbol rSymbol)
    (string<=? (symbol->string lSymbol) (symbol->string rSymbol)))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; map-like
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;; (a * list[a] -> b) * list[a] -> list[b]
  (define (to-each funct lst)
    (map (lambda (a) 
           (funct a (filter (lambda (b) 
                              (equal? a b)) 
                            lst)))
         lst))


  ;; (a * b * c ... -> d) * list[list[a], list[b], list[c], ...] -> list[d]
  ;;(define (cross-help prod lst-lst)
  ;;  (if (empty? lst-lst)
  ;;     '()
  ;;      (cross2 a-list (cross lst-lst)))
  
  ;; (a * b -> c) * list[a] * list[b] -> list[c]
  (define (cross prod a-lst b-lst)
    ;(printf "cross a-lst = ~a~n b-lst = ~a~n" a-lst b-lst)
    (if (empty? a-lst)
        '()
        (let [ [ret (append (map (lambda (b) (prod (car a-lst) b)) b-lst)
                            (cross prod (cdr a-lst) b-lst))] ]
          ;(printf "cross ret = ~a~n" ret)
          ret)))
  
  ;; skips it self
  ;; assume communitive prod
  ;; (a b c d) => (ab ac ad bc bd cd)
  ;; () => ()
  ;; (a) => ()
  (define (skipping-self-cross prod lst)
    (if (empty? lst)
        '()
        (append (cross prod (list (car lst)) (cdr lst))
                (skipping-self-cross prod (cdr lst)))))

  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; lists
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;;;;;;;;;;;;;;;;;
  ;; accessors
  ;;;;;;;;;;;;;;;;;
  
   ;; gets nth element, starts at 1 (not 0).
  (define (get-element n list)
    (cond [(<= n 0) (error 'get-element "no 0th or lower element to get")]
          [(empty? list) (error 'get-element "list is too small to get requested element")]
          [(= n 1) (car list)]
          [else (get-element (- n 1) (cdr list))]))
 
  
  ;; (a -> bool) * list[a] -> a | #f
  ;; returns the first element of lst such that
  ;; pred? is true for that element
  ;; or #f if no element of lst makes pred? true
  (define (find-first-st pred? lst)
    (cond [(empty? lst) #f]
          [(pred? (car lst)) (car lst)]
          [else (find-first-st pred? (cdr lst))]))
  
  ;; a * list[list[a]] -> list[a] | #f
  ;; returns the first list that has name as its first value 
  (define (get-list-headed-by name lst)
    ;;(printf "~n>>> name ~a~n lst: ~a~n" name lst)
    (find-first-st (lambda (x) (eqv? (car x) name)) lst))
  
  
  ;;;;;;;;;;;;;;;;;
  ;; predicates
  ;;;;;;;;;;;;;;;;;

  ;; a * list[a] * (a * a-> bool) -> bool
  ;; member can do this
  (define (member? element list equal?)
    (ormap (lambda (l) (equal? element l)) list))

  
  ;; Makes sure that the symbols in lst is in the same order as
  ;; those in order.  This does not require that all in order
  ;; are in lst.
  ;; For example, (a b c) (b c) is ok
  ;;              (a b c) (a c) is ok
  ;;              (a b c) () is ok
  ;;              (a b c) (c) is ok
  ;;              (a b c) (c a) is not
  ;;              (a b c) (d) is not
  ;;              (a b c) (b b) is ok
  ;;              (a b c) (b c b) is not
  (define in-order? 
    (opt-lambda (order lst [fail-funct (lambda (failed-on) #f)])
      (if (empty? lst)
          true
          (let [ [rest-of-order (member (first lst) order)] ]
            (if rest-of-order
                (in-order? rest-of-order (rest lst) fail-funct)
                (fail-funct (first lst)))))))
  
  
  ;;;;;;;;;;;;;;;;;
  ;; constructors
  ;;;;;;;;;;;;;;;;;

  ;; (a * a -> bool) * list[a] * list[a] -> list[a]
  ;; return ll appended to rl 
  ;; with only one copy of elements that ll and rl have in common
  ;; assuming that ll has no repeats and rl has no repeats.
  (define (disjoint-combine equ? ll rl)
    (if (empty? ll)
        rl
        (if (member? (car ll) rl equ?)
            (disjoint-combine equ? (cdr ll) rl)
            (cons (car ll) (disjoint-combine equ? (cdr ll) rl)))))
    
  (define (list-intersection equ? l-l r-l)
    (if (empty? l-l)
        '()
        (if (member? (car l-l) r-l equ?)
            (cons (car l-l) (list-intersection equ? (cdr l-l) r-l))
            (list-intersection equ? (cdr l-l) r-l))))
 
  
  (define (remove-last lst)
    (reverse (rest (reverse lst))))

  
  (define (remove-symbol-and-all-before sym lst)
    (let [ [temp (member sym lst)] ]
      (if temp
          (rest temp)
          false)))

  
  ;; list[list[a]] -> list[list[a]]
  ;; Given a list of lists, 
  ;; it will return a list contining all lists
  ;; that contin one and only one element from 
  ;; each of the given inner lists
  (define (one-from-each lst-lst)
    (cond [(null? lst-lst) '()]
          [(null? (cdr lst-lst)) (map list (car lst-lst))]
          [else (let [ [rest-lst-lst (one-from-each (cdr lst-lst))] ]
                  (apply append (map (lambda (elem) (map (lambda (rest-lst) (cons elem rest-lst))
                                                         rest-lst-lst))
                                     (car lst-lst))))]))

 ; list[a] -> list[list[a]]
(define (every-combination lst)
  (if (empty? lst)
      '(())
      (let [ [ec (every-combination (cdr lst))] ]
        (append ec (map (lambda (x) (cons (car lst) x)) ec)))))

  ;; list[a] -> list[list[list[a]]]
  (define (every-combination-pair lst)
    (if (empty? lst)
        '((() ()))
        (let [ [ec (every-combination-pair (cdr lst))] ]
          (append (map (lambda (x) (cons (cons (car lst) (first x)) (list (second x)) )) ec)
                  (map (lambda (x) (cons (first x) (list (cons (car lst) (second x))))) ec)))))

  
  
  (define (insert-between-elements inserted lst)
    (cond [(or (empty? lst) (empty? (rest lst)))
           lst]
          [(cons (first lst) 
                 (cons inserted
                       (insert-between-elements inserted (rest lst))))]))


    
  
  
  
 
  
  

            
    
  ;; returns false if the sym is not in the lst
  ;; member can do this.
  ;(define (remove-all-before-symbol sym lst)
  ;  (if (empty? lst)
  ;      false
  ;      (if (symbol=? sym (first lst))
  ;          lst
  ;          (remove-all-before-symbol sym (rest lst)))))
    
  
  
    
  
  
  )

;;
;; Tests
;;

;(require tschantzUtil)

   ;;should return true
;(and (in-order? '(a b c) '(b c))
;       (in-order? '(a b c) '(a c))
;       (in-order? '(a b c) '(c))
;       (in-order? '(a b c) '())
;       (not (in-order? '(a b c) '(c a)))
;       (not (in-order? '(a b c) '(d)))
;       (in-order? '(a b c) '(b b))
;       (not (in-order? '(a b c) '(b c b))))
;  
;(in-order? '(a b c) '(c a) (lambda (failed-on) (error "not in order")))

;  
;  (skipping-self-cross string-append (list "a" "b" "c" "d"))
;  (skipping-self-cross string-append (list "a" "b"))
;  (skipping-self-cross string-append (list "a"))
;  (skipping-self-cross string-append '())

;(one-from-each '((1 2) (a b)))
;(one-from-each '((1 2) ()))
;(one-from-each '())

;(cross + '(1) '())



;;(elim-equals '(1 2 1 2) =)
;;(elim-equals '(1 2 1 3 3) =)

;(every-combination '(1 2 3))
;(every-combination-pair '(1 2 3))

;(cross * '(1 2 4) '(3 5))
;(cross cons '(1 2 4) '(a b))
;(cross cons '(1 2 4) (cross cons '(a b) '(()) ))
;(cross cons '(x y z) (cross cons '(a b) (cross cons '(1 2 4) '(()) )))
;(cross cons '(x y z) (cross cons '(a b) (cross cons '() '(()) )))
;(cross append '() (cross append '() '()))
;(cross append '((a b)) (cross append '((1 2) (4 5)) '(()) ))


;(combine '((1 2 3) (4 5 6) (1))
;(combine '())
;(combine '(()))