;;
;; This is a set of asts for converting xacml to a scheme data sturture called ast.
;;
;; Warning: Only tested with case sensitivity on (see the manu Language->Choose Language and check details out)
;;

;; Should require this module to work with xacml
(module xacml mzscheme
  
  (require "xacml-ast.scm"
           "xacml2ast.scm"
           "ast2xacml.scm")
  
  (provide (all-from "xacml-ast.scm")
           (all-from "xacml2ast.scm")
           (all-from "ast2xacml.scm"))
  
  )






