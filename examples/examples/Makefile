BUILD==build
ALLOYJAR=alloy.jar
ALLOYCLI=alloy.cli.AlloyCLI
FILES=${BUILD}/unifiedlynda.als
#FILES=${BUILD}/invlmedicoex.als ${BUILD}/unifiedlynda.als

all: init alloy
init:
	test -e ${BUILD} || mkdir ${BUILD}

${BUILD}/unifiedlynda.xacml: classroom.xacml external.xacml financial.xacml \
	staff.xacml lyndapolicy.xacml
	(echo '<foo>'; for x in $^; do sed 1d $$x; done; echo '</foo>') | \
		xsltproc ../converter/refunifier.xslt - > $@

${BUILD}/%.xacml: %.xacml
	cp $< $@

alloy: ${FILES}
	for x in $^; do \
		java -Xmx128m -classpath "$$CLASSPATH:${ALLOYJAR}" ${ALLOYCLI} -E $$x; \
	done

${BUILD}/%.als: ${BUILD}/%.xacml ../converter/xacmltranslate.xslt
	xsltproc ../converter/xacmltranslate.xslt $< > $@

.PHONY: all init alloy
