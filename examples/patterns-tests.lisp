(in-package #:pattern-matching-test)(def-test-fixture pattern-fixture ()  ()  (:documentation "Test fixture for pattern matching"))(defmethod setup ((fix pattern-fixture))  t)(defmethod teardown ((fix pattern-fixture))  t)(defmethod trivial-pattern-test ((fix pattern-fixture))  (unless (pattern-match-p 'and 'and)    (failure "Failure to match ~A to ~A" 'and 'and))  (when (pattern-match-p '(< 4 5) '(< 4 6))    (failure "Matched ~A to ~A" '(< 4 5) '(< 4 6)))  (when (pattern-match-p 'or 'and)    (failure "Matched ~A to ~A" 'or 'and)))(defmethod wildcard-test ((fix pattern-fixture))  (unless (pattern-match-p '(< * *) '(< 4 5))    (failure "Failure to match ~A to ~A" '(< * *) '(< 4 5)))  (unless (pattern-match-p '* 'and)    (failure "Failure to match ~A to ~A" '* 'and))  (when (pattern-match-p '(< * 6) '(< 4 5))    (failure "Matched ~A to ~A" '(< * 6) '(< 4 5)))  (when (pattern-match-p '(< * * *) '(< 4 5))    (failure "Matched ~A to ~A" '(< * * *) '(< 4 5))))(defmethod big-wildcard-test ((fix pattern-fixture))  (unless (pattern-match-p '(< ** *) '(< 4 5))    (failure "Failure to match ~A to ~A" '(< ** *) '(< 4 5)))  (unless (pattern-match-p '** 'and)    (failure "Failure to match ~A to ~A" '* 'and))  (unless (pattern-match-p '(< ** *) '(< 4 5 6 3 2))    (failure "Failure to match ~A to ~A" '(< ** *) '(< 4 5 6 3 2)))  (unless (pattern-match-p '(< * **) '(< 4 5 6 3 2))    (failure "Failure to match ~A to ~A" '(< * **) '(< 4 5 6 3 2)))  (unless (pattern-match-p '(< ** *) '(< 4))    (failure "Failure to match ~A to ~A" '(< ** *) '(< 4)))  (when (pattern-match-p '(< ** *) '(<))    (failure "Failure to match ~A to ~A" '(< ** *) '(<))))(defmethod backtracking-wildcard-test ((fix pattern-fixture))  (unless (pattern-match-p '(and ** (and **) z **)                            '(and (and x) y (and z) z 4 5))    (failure "Failure to match ~A to ~A"              '(and ** (and **) z **) '(and (and x) y (and z) z 4 5))))(defmethod check-return-values-test ((fix pattern-fixture))  (multiple-value-bind (result others)                       (pattern-match-p 'and 'and)    (unless (and result (null others))      (failure "Returned values from trivial match: ~A" others)))  (multiple-value-bind (result values)                       (pattern-match-p '(and ** (and * *) **)                                        '(and x (and y z) (< z 6) 4))    (unless result      (failure "Failure to match ~A to ~A"                '(and ** (and **) **) '(and x (and y z) (< z 6))))    (destructuring-bind (first second third fourth &rest others) values      (unless (equalp first '(x))        (failure "First wildcard wasn't ~A: ~A instead" '(x) first))      (unless (equalp second 'y)        (failure "Second wildcard wasn't ~A: ~A instead" 'y second))      (unless (equalp third 'z)        (failure "Third wildcard wasn't ~A: ~A instead" 'z third))      (unless (equalp fourth '((< z 6) 4))        (failure "Fourth wildcard wasn't ~A: ~A instead" '((< z 6) 4) fourth))      (unless (null others)        (failure "Returned too many results: ~A" others)))));; stuff to test yet: need to return the partial tree matches for the *s(setf pattern-matching-test-suite      (make-test-suite "Pattern Matching Test Suite"                       "Test suite for matching patterns in trees"                       ("trivial stuff" 'pattern-fixture                        :test-thunk 'trivial-pattern-test                        :description                        "Testing to see if it matches trivial stuff")                       ("wildcards" 'pattern-fixture                        :test-thunk 'wildcard-test                        :description                        "Matching simple wildcards")                       ("general wildcards" 'pattern-fixture                        :test-thunk 'big-wildcard-test                        :description                        "Matching general wildcards")                       ("backtracking wildcards" 'pattern-fixture                        :test-thunk 'backtracking-wildcard-test                        :description                        "Matching wildcards when backtracking is needed")                       ("return values" 'pattern-fixture                        :test-thunk 'check-return-values-test                        :description                        "Checking return values for wildcards")))(report-result (run-test pattern-matching-test-suite) :verbose t)