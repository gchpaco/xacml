(module file-utils mzscheme 

  (require (lib "file.ss"))
  (provide (all-defined))
  

  (define (read-file file)
    (cond [(string? file)    
           (call-with-input-file file
             (lambda (port)
               (read-file port)))]
          [(input-port? file)
           (let [ [str (read-string 1 file)] ]
             (if (eof-object? str)
                 ""
                 (string-append str
                                (read-file file))))]
          [else (error 'read-file "expects a string (file name) or an input port.  Given: ~s" file)]))
  
  
  ;; (string -> a) -> a
  ;; where the string is a file name
  ;; calls proc passing it a temp file.
  ;; The temp file is created before calling proc
  ;; and removed after calling proc.
  (define (run-with-temp-file proc)
    (let [ [temp-file-name (make-temporary-file)] ]
      (begin0 (proc temp-file-name)
              (delete-file temp-file-name))))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; paths
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  (define (split-path* path)
    (let-values [ [(base name dir?) (split-path path)] ]
      (values (cond [(not base) "/"]
                    [(eq? 'relative base) "."]
                    [(path? base) base]
                    [else (error 'split-path* "Base ~a illegel for path ~a." base path)])
              (cond [(eq? 'up name) ".."]
                    [(eq? 'same name) "."]
                    [(path? name) name]
                    [else (error 'split-path* "Name ~a illegel for path ~a." name path)])
              dir?)))
  
  (define (build-path* . parts)
    (apply build-path parts))
  
  )