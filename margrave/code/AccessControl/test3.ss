(load "xacml-base.ss")

(define m (make-dd-manager))

(define (show d) (xacml-print d m))
(define (show-change d) (xacml-change-print d m))
(define (show-change-only d) (xacml-change-only-print d m))

(define teacher (xacml-new-var m))
(define student (xacml-new-var m))
(define ta (xacml-new-var m))
(define reads (xacml-new-var m))
(define writes (xacml-new-var m))
(define exams (xacml-new-var m))
(define grades (xacml-new-var m))

(define rule1 (xacml-augment-rule (xacml-and teacher (xacml-and writes exams m) m)
				  (xacml-permit m) m))

(define rule2 (xacml-augment-rule (xacml-and teacher (xacml-and writes grades m) m)
				  (xacml-permit m) m))

(define rule3 (xacml-augment-rule (xacml-and student (xacml-and reads grades m) m)
				  (xacml-permit m) m))

(define rule4 (xacml-augment-rule (xacml-and student (xacml-and writes grades m) m)
				  (xacml-deny m) m))

(define policy1 (combine-deny-override rule1 rule4 m))

(define policy2 (combine-deny-override
		rule1 (combine-deny-override
		       rule2 (combine-deny-override rule3 rule4 m) m) m))
(printf "A policy~n")
(show policy1)

;; constrain policy1 to cases involving teachers
(define tonlyp1 (xadd-assume policy1 teacher m))
(printf "Policy restricted to teachers~n")
(show tonlyp1)

;; restrict tonlyp1 to the permit cases
(define tpermits (restrict-to-permit tonlyp1 m))
(printf "teacher cases that yield permit~n")
(show tpermits)

;; create change-merged policy from policy1 and policy2
(define c (xacml-change-merge policy1 policy2 m))
(printf "the change add for two policies~n")
(show-change c)

;; display only change values from c
(printf "only the change lines from the change add (ADD unaltered) ~n")
(show-change-only c)

;; retrict change-merged policy to NP values only
(define c-pd (restrict-to c NP_VAL m))
(printf "restricting the change add to cases that went from NA to Permit~n")
(show-change c-pd)

(printf "var extraction tests~n")
(printf "Rule 1~n")
(show rule1)
(printf "Vars true in rule 1 ~a~n" (always-true-vars rule1 m))
(printf "Vars false in rule 1 ~a~n" (always-false-vars rule1 m))
(printf "Vars dc in rule 1 ~a~n" (always-dc-vars rule1 m))

(define r1p (restrict-to-permit rule1 m))
(printf "Rule 1 restricted to permit cases~n")
(show r1p)
(printf "Vars true in restricted rule 1 ~a~n" (always-true-vars r1p m))
(printf "Vars false in restricted rule 1 ~a~n" (always-false-vars r1p m))
(printf "Vars dc in restricted rule 1 ~a~n" (always-dc-vars r1p m))

