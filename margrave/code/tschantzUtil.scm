(module tschantzUtil mzscheme
  
  (require (lib "list.ss") (lib "etc.ss"))
  (provide (all-defined))
  
  ;; a * list[a] * (a * a-> bool) -> bool
  (define (member? element list equal?)
    (ormap (lambda (l) (equal? element l)) list))
  
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
  
;  (define (remove pred? list)
;    (filter (lambda (elem) (not (pred? elem))) list))
  
  ;; list[a] * (a * a -> bool) -> list[a]
  ;; removes elements that are equal from a list
  (define (elim-equals lst pred?)
    (letrec [ [elim-equals-help (lambda (seen-lst working-lst)
                               (if (empty? working-lst)
                                   seen-lst
                                   (if (member? (car working-lst) seen-lst pred?)
                                       (elim-equals-help seen-lst (cdr working-lst))
                                       (elim-equals-help (cons (car working-lst) seen-lst) (cdr working-lst)))))] ]
      (elim-equals-help '() lst)))
                                     
  
  
  
  
  
  ;; (a * b * c ... -> d) * list[a] * list[b] * list[c] ... -> list[d]
  ;;(define (cross prod . lst-lst)
  
  ;; (list[a] -> b) * list[list[a]] -> list[b]
  ;;(define (cross-list prod lst-lst))
  
  ;; (a * list[a] -> b) * list[a] -> list[b]
  (define (to-each funct lst)
    (map (lambda (a) (funct a (filter (lambda (b) (equal? a b)) lst))) lst))

 
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
  

    
  
  ;; list[list[a]] -> list[list[a]]
  ;; Given a list of lists, 
  ;; it will return a list contining all lists
  ;; that contin one and only one element from 
  ;; each of the given inner lists
  (define (one-from-each lst-lst)
    (cond [(null? lst-lst) '()]
          [(null? (cdr lst-lst)) (map list (car lst-lst))]
          [else (let [ [rest-lst-lst (one-from-each (cdr lst-lst))] ]
                  (combine (map (lambda (elem) (map (lambda (rest-lst) (cons elem rest-lst))
                                                    rest-lst-lst))
                                (car lst-lst))))]))

  
  ;; (a b c ... -> d) * list[a] * list[b] * list[c] ... -> list[d]
;;  (define (cross-map funct . lst-lst)
 ;;   (cons (funct (map car lst-lst)
  
  ;; list[list[a]] -> list[a]
  ;; Makes a list of lists one list that holds the elements of each list of the given outer list
  (define (combine a-list-list)
    (foldr (lambda (a-list out-list) (append a-list out-list)) '() a-list-list))
  
  (define (symbol-append . sym-lst)
    (symbol-append-lst sym-lst))
  (define (symbol-append-lst sym-lst)
    (cond [(empty? sym-lst) (void)]
          [(empty? (cdr sym-lst)) (car sym-lst)]
          [else (string->symbol (string-append (symbol->string (car sym-lst))
                                               (symbol->string (symbol-append-lst (cdr sym-lst)))))]))
  

;; list[a] -> list[list[a]]
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

  
  (define (list-intersection equ? l-l r-l)
    (if (empty? l-l)
        '()
        (if (member? (car l-l) r-l equ?)
            (cons (car l-l) (list-intersection equ? (cdr l-l) r-l))
            (list-intersection equ? (cdr l-l) r-l))))
  
  ;; gets nth element, starts at 1 (not 0).
  (define (get-element n list)
    (cond [(<= n 0) (error 'get-element "no 0th or lower element to get")]
          [(empty? list) (error 'get-element "list is too small to get requested element")]
          [(= n 1) (car list)]
          [else (get-element (- n 1) (cdr list))]))
                
  
  
)

;; Tests
(require tschantzUtil)

  (skipping-self-cross string-append (list "a" "b" "c" "d"))
  (skipping-self-cross string-append (list "a" "b"))
  (skipping-self-cross string-append (list "a"))
  (skipping-self-cross string-append '())

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