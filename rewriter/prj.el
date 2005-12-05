(jde-project-file-version "1.0")
(jde-set-variables
 '(jde-build-function (quote (jde-ant-build)))
 '(jde-ant-read-buildfile nil)
 '(jde-ant-enable-find t)
 '(jde-global-classpath '("$CLASSPATH"
			  "~/wd/xacml/xacml/rewriter/=build"
			  "~/wd/xacml/xacml/rewriter/=build.test"))
 '(jde-run-option-classpath '("~/wd/xacml/xacml/rewriter/=build"
			      "~/wd/xacml/xacml/rewriter/=build.test"))
 '(jde-run-working-directory "~/wd/xacml/xacml/rewriter")
 '(jde-run-application-class "org.sigwinch.xacml.Rewriter")
 '(jde-sourcepath (quote ("~/wd/xacml/xacml/rewriter/src"
			  "~/wd/xacml/xacml/rewriter/tests")))
 '(jde-ant-home "/usr/share/ant")
 '(jde-run-executable-args '("../examples/financial.xacml")))
