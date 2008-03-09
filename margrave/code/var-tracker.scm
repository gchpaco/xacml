;(include "tschantzUtil.scm")

(module var-tracker mzscheme
  
  
  (provide lookup
           store
           ->string
           match->string
           get-all-attrId
           get-all-attrValues
           get-match-creation-list
           match=?
           (struct match (subtarget
                          attrId
                          attrValue)))
  
  
  (require (lib "list.ss")
           (lib "etc.ss"))

  
  (define-struct match (subtarget
			attrId
			attrValue))
  
  ;  (define (make-key subtarget attrId attrValue)
  ;    (symbol-append subtarget '^ attrId '^ attrValue))
  
  ;; oldest first
  (define creation-list '())
  
  ;; from key to var
  (define key2var-table (make-hash-table 'equal))
  
  (define subject-key2var-table (make-hash-table 'equal))
  (define resource-key2var-table (make-hash-table 'equal))
  (define action-key2var-table (make-hash-table 'equal))
  
  
  ;; from var to match
  (define var2match-table (make-hash-table 'equal))
  
  (define (get-subtarget-table subtarget)
    (cond [(symbol=? subtarget 'Subject) subject-key2var-table]
          [(symbol=? subtarget 'Resource) resource-key2var-table]
          [(symbol=? subtarget 'Action) action-key2var-table]
          [else (error 'get-subtarget-table: "unknown subtarget: ~a" subtarget)])) 
  
  (define (get-match-creation-list)
    creation-list)
  
  ;; sym * sym * sym -> var | #f
  (define (match->var subtarget attrId attrValue)
    (let [ [attrId-table (hash-table-get (get-subtarget-table subtarget) attrId (lambda () #f))] ]
      (if attrId-table
	  (hash-table-get attrId-table attrValue (lambda () #f))
	  #f)))
  
  ;; key -> var | #f
  ;;(define (key->var key)
  ;;  (hash-table-get key2var-table key (lambda () #f)))
  
  ;; var -> match | #f
  (define (var->match var) 
    (hash-table-get var2match-table var (lambda () #f)))
  
  
  ;; -> list[list[attrId]]
  ;; subtarget -> list[attrId]
  ;; returns all the attrIds found for a subtarget
  (define get-all-attrId
    (case-lambda 
      [() (list (get-all-attrId 'Subject)
                (get-all-attrId 'Resource)
                (get-all-attrId 'Action))]
      [(subtarget) (hash-table-map (get-subtarget-table subtarget)
                                   (lambda (key val) key))]))
  
  ;; subtarget * attrId -> list[attrVal]
  ;; subtarget -> list[pair(attrId, list[attrVal])]
  ;; -> list[list[pair(attrId, list[attrVal])]]
  ;; returns all the attrValues found for a subtarget's attrId
  (define get-all-attrValues 
    (case-lambda
      [() (list (get-all-attrValues 'Subject)
                (get-all-attrValues 'Resource)
                (get-all-attrValues 'Action))]
      [(subtarget) (map (lambda (attrId) (list attrId (get-all-attrValues subtarget attrId)))
                        (get-all-attrId subtarget))]
      [(subtarget attrId) (hash-table-map (hash-table-get (get-subtarget-table subtarget) attrId)
                                          (lambda (key val) key))]))
  
  ;; last one made is listed first
  ;(define creation-list '())
  
  
  ;; sym * sym * sym * var ->
  (define (store subtarget attrId attrValue var)
    (let* [ [subtarget-table (get-subtarget-table subtarget)]
	    [attrId-table (hash-table-get subtarget-table attrId (lambda () #f))]
	    [match (make-match subtarget attrId attrValue)] ]
      (if attrId-table					
	  (hash-table-put! attrId-table attrValue var)		
	  (let [ [new-attrId-table (make-hash-table)] ]
	    (hash-table-put! subtarget-table attrId new-attrId-table)
	    (hash-table-put! new-attrId-table attrValue var)
	    (hash-table-put! var2match-table var match)))
      (set! creation-list (append creation-list (list (make-match subtarget attrId attrValue))))
      (hash-table-put! var2match-table var match)))
  
  ;; sym * sym * sym -> var | #f
  (define (lookup subtarget attrId attrValue)
    (match->var subtarget attrId attrValue))
  
  (define (match->string match)
    (string-append "/"                    
                   (symbol->string (match-subtarget match)) 
                   ", " 
                   (symbol->string (match-attrId match)) 
                   ", " 
                   (symbol->string (match-attrValue match)) 
                   "/"))
  
  (define (->string)
    (string-append (->string-help creation-list 1) "\n" (num-list 1 (length creation-list))))
 
  ;; list[match] * num -> string
  (define (->string-help c-l num)
    (if (empty? c-l)
        ""
        (let [ [match (car c-l)] ]
          (string-append " "
                         (number->string num) 
                         ":" 
                         (match->string match)
                         "\n"
                         (->string-help (rest c-l) (add1 num))))))
  ;; num * num -> string
  (define (num-list cur-num end-num)
    (if (> cur-num end-num)
        ""
        (string-append (number->string (remainder cur-num 10))
                       (num-list (add1 cur-num) end-num))))
  
  
  (define (match=? m n)
    (and (eq? (match-subtarget m) (match-subtarget n))
         (eq? (match-attrId m) (match-attrId n))
         (eq? (match-attrValue m) (match-attrValue n))))
  
  
  
  )