;(load-relative "tschantzUtil.scm")
(include "tschantzUtil.scm")

(module sxml-tools mzscheme
  
  (require (prefix util: tschantzUtil)
           (lib "etc.ss")
           (prefix xml: (lib "xml.ss" "xml")))
  
  (provide (all-defined))
  
  
  ;; .type (string | port | xml:document | xml:element) [(listof symbol)] -> xexpr
  (define ->xexpr
    (opt-lambda (x [whitespace-does-not-matter '()])
      (cond [(string? x)
             (let [ [input-port (open-input-file x)] ]
               (begin0
                 (->xexpr input-port whitespace-does-not-matter)
                 (close-input-port input-port)))]
            [(port? x) 
             (->xexpr (parameterize [[xml:read-comments #f] [xml:collapse-whitespace #t]] (xml:read-xml x)) 
                      whitespace-does-not-matter)]
            [(xml:document? x) 
             (->xexpr ((xml:eliminate-whitespace whitespace-does-not-matter 
                                                 (lambda (x) x))
                       (xml:document-element x)) 
                      whitespace-does-not-matter)]
            [(xml:element? x) 
             (xml:xml->xexpr x)]
            [else (error '->xexpr "Unknown input type")])))  
  
  ;;;
  ;; for accessing sxml info
  ;;;
  
  ;; sxml -> string
  ;; e.g.
  ;; <in-tag1>val1</in-tag1> => 'in-tag1
  (define (get-tag xexpr)
    (car xexpr))
  
  ;; sxml -> list[sxml]
  ;; e.g.
  ;;<out-tag>
  ;;<in-tag1>val1</in-tag1>
  ;;<in-tag2>val2</in-tag2>
  ;;<out-tag>  
  ;;  =>
  ;;(<in-tag1>val1</in-tag1>  <in-tag2>val2</in-tag2>)
  ;;  and
  ;; <tag>val1</tag> => (val1)
  (define (get-content xexpr)
    (cdr (cdr xexpr)))
  
  ;; sxml -> sxml
  ;; sxml -> string if used as intended
  ;; e.g. 
  ;; <tag>val1</tag> => val1
  (define (get-value xexpr)
    (car (get-content xexpr)))
  
  ;; e.g. <tag a="b" c="d">val1</tag> => ((a "b") (c "d"))
  (define (get-attribute-list xexpr)
    (car (cdr xexpr)))
  
  ;; xml attribute
  (define (get-attribute attribute-name xexpr)
    (let [ [attribute (util:get-list-headed-by attribute-name (get-attribute-list xexpr))] ]
      (if attribute
          (car (cdr attribute))
          (error 'get-attribute "no attribute found for ~a in ~a" attribute-name xexpr))))
  
  ;; symbol * xexpr -> xexpr | #f
  ;; returns the first one
  (define get-subxexpr 
    (opt-lambda (name xexpr [fail-thunk (lambda () #f)])
      ;(printf "~n>>name: ~a~n xexpr: ~a~n" name xexpr)
      (let [ [ret (util:get-list-headed-by name (get-content xexpr))] ]
        (if ret
            ret
            (fail-thunk)))))
  
  
  (define show-sxml-struct (opt-lambda (s [start ""] [add ""])
                             (cond [(xml:element? s)
                                    (begin0
                                      (printf "~a name: ~a~n" start (xml:element-name s))
                                      (map (lambda (x) (show-sxml-struct x (string-append start add) add))
                                           (xml:element-attributes s))
                                      (map (lambda (x) (show-sxml-struct x (string-append start add) add))
                                           (xml:element-content s)))]
                                   [(xml:attribute? s)
                                    (begin0
                                      (printf "~a attr: ~a  =  ~a~n" start (xml:attribute-name s) (xml:attribute-value s)))]
                                   [(xml:pcdata? s)
                                    (printf "~a data: ~a~n" start (xml:pcdata-string s))]
                                   [else
                                    (printf "~a %~a~n" start s)])))
  
  )
