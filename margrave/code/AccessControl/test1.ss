(load "xacml-base.ss")

(define dd-manager (make-dd-manager))

(define bdd1 (xacml-new-var dd-manager))
(define bdd2 (xacml-new-var dd-manager))

(define xadd-deny (xacml-augment-rule bdd1 (xacml-deny dd-manager)
				      dd-manager))
(xacml-print xadd-deny dd-manager)(display "------")(newline)

(define xadd-permit (xacml-augment-rule bdd2 (xacml-permit dd-manager)
					dd-manager))
(xacml-print xadd-permit dd-manager)(display "------")(newline)

;; xadd-good and xadd-bad should be equal,
;; but only xadd-good has the correct value.
(display "--- test 1 ---")(newline)
(define xadd-good (combine-permit-override xadd-deny xadd-permit
					   dd-manager))
(xacml-print xadd-good dd-manager)(display "------")(newline)

(define xadd-bad (combine-permit-override xadd-permit xadd-deny
					  dd-manager))
(xacml-print xadd-bad dd-manager)(display "------")(newline)

;; The problem also shows up with deny-override,
;; but with the args in the oppsite order.
(display "--- test 2 ---")(newline)
(define xadd-bad-deny (combine-deny-override xadd-deny xadd-permit
					     dd-manager))
(xacml-print xadd-bad-deny dd-manager)(display "------")(newline)

(define xadd-good-deny (combine-deny-override xadd-permit xadd-deny
					      dd-manager))
(xacml-print xadd-good-deny dd-manager)(display "------")(newline)

