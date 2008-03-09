(load "xacml-base.ss")

(define m (make-dd-manager))

(define p (xacml-permit m))
(define d (xacml-deny m))
(define n (xacml-na m))

(define var1 (xacml-new-var m))
(define var2 (xacml-new-var m))

(define cond1 (xacml-and var1 var2 m))
(define rule1 (xacml-augment-rule cond1 p m))
(define rule2 (xacml-augment-rule var1 d m))

(printf "Rule 1~n")
(xacml-print rule1 m)

(printf "Rule 2~n")
(xacml-print rule2 m)

(define policy1 (combine-permit-override rule1 rule2 m))

(printf "Permit Overrides~n")
(xacml-print policy1 m)

(printf "Deny Overrides~n")
(xacml-print (combine-deny-override rule1 rule2 m) m)

(printf "Rule 1 before Rule 2~n")
(xacml-print (combine-first-applicable rule1 rule2 m) m)


