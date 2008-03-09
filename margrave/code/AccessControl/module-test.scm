(load-relative-extension "import.so")
;(load-relative-extension "idmodule.so")
;(load-relative-extension "testm.so")


(module test mzscheme

  (provide p1)
  (require import)
  ;(require import)
  
  (display "hi")

  (define (p1 x) 
    (+ (identity x) 1)) 
  
  )

(require test)

(p1 3)
