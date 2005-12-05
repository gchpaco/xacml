#!/sw/bin/scsh \
-o let-opt -s
!#

(define alloydir "../alloydist")
(define jarfile "=build.dist/rewrite.jar")
(define command-lines
  '(;("one & one" "smallexamples/one.xacml" "smallexamples/one.xacml")
    ;("one & two" "smallexamples/one.xacml" "smallexamples/two.xacml")
    ;("two & one" "smallexamples/two.xacml" "smallexamples/one.xacml")
    ;("two & two" "smallexamples/two.xacml" "smallexamples/two.xacml")
    ("one & invl" "smallexamples/one.xacml" "../examples/invlmedicoex.xacml")
    ("invl & one" "../examples/invlmedicoex.xacml" "smallexamples/one.xacml")
    ;("two & invl" "smallexamples/two.xacml" "../examples/invlmedicoex.xacml")
    ;("invl & two" "../examples/invlmedicoex.xacml" "smallexamples/two.xacml")
    ;("invl & invl" "../examples/invlmedicoex.xacml"
     ;"../examples/invlmedicoex.xacml")
    ))
(define slops '(1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9
		  2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3));(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15))

(for-each
 (lambda (slop)
   (display "Slop\t")
   (display slop)
   (newline)
   (for-each
    (lambda (pair)
      (let ((tag (car pair))
	    (cmdline (cdr pair)))
	(display tag)
	(let ((output (run/file (java -jar ,jarfile -s ,slop ,@cmdline))))
          (with-cwd
           alloydir
           (for-each
            (lambda (junk)
              (display "\t")
              (receive (port child)
                       (run/port+proc
                        (| (epf (| (yes n)
                                 (/usr/bin/time -p java -cp alloy.jar
                                                alloy.api.AlloyRunner 
                                                ,output))
                                (= 2 1)
                                (> ,(format #f "output-~a-~a" tag slop)))
                         (sed -n "s/^real[ 	]*//p")))
                       (let ((time (port->string port))
                             (status (wait child)))
                         (if (= status 0)
                             (display (string-trim-both time))
                             (display "Error!")))))
            '(1 2 3 4 5)))))
      (newline))
    command-lines))
 slops)

