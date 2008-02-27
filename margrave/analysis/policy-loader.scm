(module policy-loader mzscheme
  (provide (all-defined))

  (require (lib "etc.ss")
           "../lib/errorf.scm"
           (prefix xacml: "../xacml/xacml.scm")
           (prefix ast2add: "xacml-to-xradd.scm")
           (prefix ast2matcheq: "xacml-to-matcheq.scm")) ; collect matches and equalities
  
  ;; Returns a list of matcheqs from a policy.
  (define glean-matcheq 
    (opt-lambda (policy [verbose? #f])
      ;(printf "policy: ~s~n" policy)
      (cond [(or (string? policy) (path? policy))
             (glean-matcheq (xacml:xacml->ast policy verbose?))]
            [(xacml:ast? policy)
             (reverse (ast2matcheq:ast->matcheq-list policy))]
            [else 
             (errorf "Must provide either a file name (a string) or a XACML AST.  Given: ~s" policy)])))
  
  
  
  
  ;; !
  ;; .type (string | ast) * [bool] -> policy
  ;; 
  ;; allows parsing in one step.
  ;; .comment the only function to use anything from the xacml2ast or ast2add modules
  (define ast-or-file->xradd
    (opt-lambda (policy [verbose? #f])
      (cond [(xacml:ast? policy) (ast2add:ast->xradd policy)]
            [(or (string? policy) (path? policy)) (ast2add:ast->xradd (xacml:xacml->ast policy verbose?))]
            [else (errorf "Can only load xacml asts, file names in string form, or file names in path form.  Given something which is neither a ast, string, or path: ~s" policy)])))
 
  )