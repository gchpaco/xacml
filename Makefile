REWRITE_DIR:=rewriter
FILE_DIR:=examples/margrave
BIN_DIR:=bin
REWRITER:=$(REWRITE_DIR)/=build.jar/rewrite.jar
properties:=C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 C11 M1 M2 V1
runs:=1 2 3 4 5

outputs: $(foreach property,$(properties),outputs/$(property)-M)
	for property in $(properties);\
	do \
	    echo -n $$property ""; bin/median outputs/$$property-M; \
	done

outputs/%-M: $(foreach run,$(runs),outputs/%-A-$(run))
	bin/extract_data $^ > $@

outputs/M1-A-%: $(REWRITER) examples/examples/invlmedicoex.xacml rewriter/smallexamples/one.xacml
	java -jar $(REWRITER) --roundtrip rewriter/smallexamples/one.xacml examples/examples/invlmedicoex.xacml > $@ 2>&1
outputs/M2-A-%: $(REWRITER) examples/examples/invlmedicoex.xacml rewriter/smallexamples/two.xacml
	java -jar $(REWRITER) --roundtrip rewriter/smallexamples/two.xacml examples/examples/invlmedicoex.xacml > $@ 2>&1
outputs/V1-A-%: $(REWRITER) rewriter/smallexamples/paperquery.xacml rewriter/smallexamples/paperschema.xacml
	java -jar $(REWRITER) --roundtrip rewriter/smallexamples/paperquery.xacml rewriter/smallexamples/paperschema.xacml > $@ 2>&1

outputs/C1-A-%: $(REWRITER) $(FILE_DIR)/continueB.xacml $(FILE_DIR)/conflict.xacml
	java -jar $(REWRITER) --roundtrip $(FILE_DIR)/continueB.xacml $(FILE_DIR)/conflict.xacml > $@ 2>&1
outputs/C6-A-%: $(REWRITER) $(FILE_DIR)/continueB.xacml $(FILE_DIR)/discussion.xacml
	java -jar $(REWRITER) --roundtrip -t p $(FILE_DIR)/discussion.xacml $(FILE_DIR)/continueB.xacml > $@ 2>&1
outputs/C7-A-%: $(REWRITER) $(FILE_DIR)/continueB.xacml $(FILE_DIR)/conflictreview.xacml
	java -jar $(REWRITER) --roundtrip $(FILE_DIR)/conflictreview.xacml $(FILE_DIR)/discussion.xacml > $@ 2>&1
outputs/C10-A-%: $(REWRITER) $(FILE_DIR)/continueB.xacml $(FILE_DIR)/submitted.xacml
	java -jar $(REWRITER) --roundtrip -t p $(FILE_DIR)/submitted.xacml $(FILE_DIR)/continueB.xacml > $@ 2>&1
outputs/C11-A-%: $(REWRITER) $(FILE_DIR)/continueB.xacml $(FILE_DIR)/unsubmitted.xacml
	java -jar $(REWRITER) --roundtrip -t d $(FILE_DIR)/unsubmitted.xacml $(FILE_DIR)/continueB.xacml > $@ 2>&1
outputs/C2-A-%: $(REWRITER) $(FILE_DIR)/continueB.xacml $(FILE_DIR)/mayedit.xacml
	java -jar $(REWRITER) --roundtrip $(FILE_DIR)/mayedit.xacml $(FILE_DIR)/continueB.xacml > $@ 2>&1
outputs/C8-A-%: $(REWRITER) $(FILE_DIR)/continueB.xacml $(FILE_DIR)/norole2.xacml
	java -jar $(REWRITER) --roundtrip $(FILE_DIR)/continueB.xacml $(FILE_DIR)/norole2.xacml > $@ 2>&1
outputs/C3-A-%: $(REWRITER) $(FILE_DIR)/continueB.xacml $(FILE_DIR)/norole.xacml
	java -jar $(REWRITER) --roundtrip $(FILE_DIR)/continueB.xacml $(FILE_DIR)/norole.xacml > $@ 2>&1
outputs/C9-A-%: $(REWRITER) $(FILE_DIR)/continueB.xacml $(FILE_DIR)/onlychair.xacml
	java -jar $(REWRITER) --roundtrip $(FILE_DIR)/continueB.xacml $(FILE_DIR)/onlychair.xacml > $@ 2>&1
outputs/C4-A-%: $(REWRITER) $(FILE_DIR)/continueB.xacml $(FILE_DIR)/seeeverything.xacml
	java -jar $(REWRITER) --roundtrip -t p $(FILE_DIR)/seeeverything.xacml $(FILE_DIR)/continueB.xacml > $@ 2>&1
outputs/C5-A-%: $(REWRITER) $(FILE_DIR)/continueB.xacml $(FILE_DIR)/seeeverything2.xacml
	java -jar $(REWRITER) --roundtrip -t p $(FILE_DIR)/seeeverything2.xacml $(FILE_DIR)/continueB.xacml > $@ 2>&1

.PRECIOUS: $(foreach property,$(properties),outputs/$(property)-%)

$(REWRITER):
	cd $(REWRITE_DIR) && ant dist
