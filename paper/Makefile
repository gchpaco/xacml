REWRITER=../rewriter
REWRITE=$(REWRITER)/=build.dist/rewrite.jar

define remove-junk
	sed 's/oasis:names:tc:xacml:1.0:[^:"]*/.../' < $< | \
	sed 's/urn:oasis:tc:xacml:1.0:subject-category:access-subject/.../' | \
	sed 's|http://www.w3.org/2001/XMLSchema|...|' > $@
endef

paper.tex: trimmedexample.xacml.tex trimmedexample.als.tex \
	data/invloutput.tex data/output.tex data/output.graph.tex

trimmedexample.xacml: alloyexample.xacml
	$(remove-junk)

trimmedexample.als: alloyexample.als
	$(remove-junk)

data/%.tex: data/%.tsv
	awk -f data/format.awk < $< > $@

data/%.d: data/%.tsv
	awk -f data/graph.awk < $< > $@

data/%.graph.tex: data/%.d
	awk -f data/extract.awk < $< | grap | pic -t > $@

%.tex: %
	(echo "\begin{verbatim}"; sed 's/	/  /' < $<; \
	echo "\end{verbatim}") | fmt -s > $@

%.als: %.xacml $(REWRITE)
	java -jar $(REWRITE) $< > $@

$(REWRITE):
	cd $(REWRITER) && ant dist
