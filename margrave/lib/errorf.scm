(module errorf mzscheme
  
  (provide (all-defined))

;(define (errorf format-string . values)
;    (error (apply format (cons format-string values))))
  
  (define-syntax (errorf stx)
    (syntax-case stx ()
      [(errorf format-string value ...)
       (syntax/loc stx (error (format format-string value ...)))]))
  
  )