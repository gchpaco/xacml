<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:sig="http://www.sigwinch.org/functions"
  xmlns:xacml="urn:oasis:names:tc:xacml:1.0:policy">
  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:include href="functions.xslt"/>
  
  <xsl:template match="/">
    <xsl:text>module Translation
open xacml/xacml
open xacml/rules
open xacml/attributes
open std/bool

/* attributes from environment */
static sig ENVIRONMENT {
</xsl:text>
    <xsl:call-template name="environment"/>
    <xsl:text>
}

/* expressions we can't represent */
static sig EXPRESSIONS {
</xsl:text>
    <xsl:call-template name="expressions"/>
    <xsl:text>}

/* static constants */
</xsl:text>
    <xsl:call-template name="constants"/>
    <xsl:text>
</xsl:text>
    <xsl:apply-templates mode="rules"/>
    <xsl:variable name="topid" select="generate-id(/xacml:PolicySet|/xacml:Policy|/xacml:Rule)"/>
    <xsl:text>

/* now, the tests */
fun SometimesValid () {
	</xsl:text>
    <xsl:value-of select="$topid"/>
    <xsl:text>.valid = True
}

fun PossibleToSatisfy () {
	</xsl:text>
    <xsl:value-of select="$topid"/>
    <xsl:text>.effect = Permit
}

fun NotTotal () {
	</xsl:text>
    <xsl:value-of select="$topid"/>
    <xsl:text>.effect = NotApplicable
}

fun PossibleToDeny () {
	</xsl:text>
    <xsl:value-of select="$topid"/>
    <xsl:text>.effect = Deny
}

assert ImpossibleToError {
	</xsl:text>
    <xsl:value-of select="$topid"/>
    <xsl:text>.effect != Indeterminate
}

</xsl:text>
    <xsl:variable name="howmany" select="3+count(//xacml:PolicySet|//xacml:Policy|//xacml:Rule)"/>
    <xsl:text>run SometimesValid for </xsl:text>
    <xsl:value-of select="$howmany"/>
    <xsl:text> but 4 Result, 2 Bool, 24 Attribute, 1 ENVIRONMENT, 1 EXPRESSIONS
run PossibleToSatisfy for </xsl:text>
    <xsl:value-of select="$howmany"/>
    <xsl:text> but 4 Result, 2 Bool, 24 Attribute, 1 ENVIRONMENT, 1 EXPRESSIONS
run NotTotal for </xsl:text>
    <xsl:value-of select="$howmany"/>
    <xsl:text> but 4 Result, 2 Bool, 24 Attribute, 1 ENVIRONMENT, 1 EXPRESSIONS
run PossibleToDeny for </xsl:text>
    <xsl:value-of select="$howmany"/>
    <xsl:text> but 4 Result, 2 Bool, 24 Attribute, 1 ENVIRONMENT, 1 EXPRESSIONS
check ImpossibleToError for </xsl:text>
    <xsl:value-of select="$howmany"/>
    <xsl:text> but 4 Result, 2 Bool, 24 Attribute, 1 ENVIRONMENT, 1 EXPRESSIONS
</xsl:text>
  </xsl:template>

  <xsl:key name="envid" match="xacml:SubjectAttributeDesignator|xacml:ResourceAttributeDesignator|xacml:ActionAttributeDesignator|xacml:EnvironmentAttributeDesignator" use="@AttributeId"/>
  <xsl:key name="selectid" match="xacml:AttributeSelector" use="@RequestContextPath"/>

  <xsl:template name="environment">
    <xsl:for-each select="//xacml:SubjectAttributeDesignator|//xacml:ResourceAttributeDesignator|//xacml:ActionAttributeDesignator|//xacml:EnvironmentAttributeDesignator">
      <xsl:sort select="@AttributeId"/>
      <xsl:if test="generate-id(.) = generate-id(key('envid',@AttributeId))">
        <xsl:text>	</xsl:text>
        <xsl:value-of select="generate-id(.)"/>
        <xsl:text> : set </xsl:text>
        <xsl:apply-templates select="." mode="datatype"/>
        <xsl:text> /* </xsl:text>
        <xsl:value-of select="@AttributeId"/>
        <xsl:text> */,
</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="//xacml:AttributeSelector">
      <xsl:sort select="@RequestContextPath"/>
      <xsl:if test="generate-id(.) = generate-id(key('selectid',@RequestContextPath))">
        <xsl:text>	</xsl:text>
        <xsl:value-of select="generate-id(.)"/>
        <xsl:text> : set </xsl:text>
        <xsl:apply-templates select="." mode="datatype"/>
        <xsl:text> /* </xsl:text>
        <xsl:value-of select="@RequestContextPath"/>
        <xsl:text> */</xsl:text>
        <xsl:text>,
</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>	dummy : set String /* to fill out commas */
</xsl:text>
  </xsl:template>
  
  <xsl:template name="expressions">
    <xsl:for-each select="//*[sig:badfunction(@MatchId) or sig:badfunction(@FunctionId)]">
      <xsl:text>	</xsl:text>
      <xsl:value-of select="generate-id(.)"/>
      <xsl:text> : scalar </xsl:text>
      <xsl:apply-templates select="." mode="datatype"/>
      <xsl:choose>
        <xsl:when test="not(position() = last())"><xsl:text>,
</xsl:text>
        </xsl:when>
        <xsl:otherwise><xsl:text>
</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:key name="constid" match="xacml:AttributeValue" use="normalize-space(text())"/>
  
  <xsl:template name="constants">
    <xsl:for-each select="//xacml:AttributeValue[generate-id(key('constid',normalize-space(text()))) =
	generate-id(.)]">
      <xsl:sort select="normalize-space(text())"/>
      <xsl:text>static sig CONST_</xsl:text>
      <xsl:value-of select="generate-id(key('constid',normalize-space(.)))"/>
      <xsl:text> extends </xsl:text>
      <xsl:apply-templates select="." mode="datatype"/>
      <xsl:text> {} /* </xsl:text>
      <xsl:value-of select="normalize-space(text())"/>
      <xsl:text> */
</xsl:text>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="xacml:Rule" mode="rules">
    <xsl:text>static sig </xsl:text>
    <xsl:variable name="ruleid" select="generate-id(.)"/>
    <xsl:value-of select="$ruleid"/>
    <xsl:text> extends Rule {} /* </xsl:text>
    <xsl:value-of select="@RuleId"/>
    <xsl:text> */
fact </xsl:text>
    <xsl:value-of select="$ruleid"/>
    <xsl:text>Conditions {
	</xsl:text>
    <xsl:copy-of select="$ruleid"/>
    <xsl:text>.intention = </xsl:text>
    <xsl:value-of select="@Effect"/>
    <xsl:text>
	</xsl:text>
    <xsl:call-template name="validity">
      <xsl:with-param name="id" select="$ruleid"/>
    </xsl:call-template>
    <xsl:apply-templates mode="errors">
      <xsl:with-param name="rule" select="$ruleid"/>
    </xsl:apply-templates>
    <xsl:choose>
      <xsl:when test="xacml:Condition">
        <xsl:apply-templates select="xacml:Condition" mode="functions">
          <xsl:with-param name="temp" select="1"/>
          <xsl:with-param name="toplevel" select="true()"/>
        </xsl:apply-templates>
        <xsl:text>
		=> </xsl:text>
        <xsl:copy-of select="$ruleid"/>
        <xsl:text>.conditions = True,
	</xsl:text>
        <xsl:copy-of select="$ruleid"/>
        <xsl:text>.conditions = False</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$ruleid"/>
        <xsl:text>.conditions = True</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>
}
</xsl:text>
  </xsl:template>
  
  <xsl:template match="xacml:Policy" mode="rules">
    <xsl:call-template name="policies">
      <xsl:with-param name="policyid" select="generate-id(.)"/>
      <xsl:with-param name="name" select="@PolicyId"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="xacml:PolicySet" mode="rules">
    <xsl:call-template name="policies">
      <xsl:with-param name="policyid" select="generate-id(.)"/>
      <xsl:with-param name="name" select="@PolicySetId"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="policies">
    <xsl:text>static sig </xsl:text>
    <xsl:copy-of select="$policyid"/>
    <xsl:text> extends </xsl:text>
    <xsl:apply-templates select="." mode="combiningalgs"/>
    <xsl:text> {} /* </xsl:text>
    <xsl:value-of select="$name"/>
    <xsl:text> */
fact </xsl:text>
    <xsl:value-of select="$policyid"/>
    <xsl:text>Conditions {
	</xsl:text>
    <xsl:copy-of select="$policyid"/>
    <xsl:text>.subpolicies = </xsl:text>
    <xsl:for-each select="xacml:Rule|xacml:Policy|xacml:PolicySet">
      <xsl:value-of select="generate-id(.)"/>
      <xsl:if test="not(position() = last())"><xsl:text> + </xsl:text></xsl:if>
    </xsl:for-each>
    <xsl:text>
	</xsl:text>
    <xsl:call-template name="validity">
      <xsl:with-param name="id" select="$policyid"/>
    </xsl:call-template>
    <xsl:text>
}
</xsl:text>
    <xsl:apply-templates mode="rules"/>
  </xsl:template>
  
  <xsl:template name="validity">
    <xsl:choose>
      <xsl:when test="xacml:Target//xacml:Subject|xacml:Target//xacml:Resource|xacml:Target//xacml:Action">
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="xacml:Target" mode="conditions"/>
        <xsl:text>) => </xsl:text>
        <xsl:copy-of select="$id"/>
        <xsl:text>.valid = True,
	</xsl:text>
        <xsl:copy-of select="$id"/>
        <xsl:text>.valid = False
	</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$id"/>
        <xsl:text>.valid = True
	</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*[@RuleCombiningAlgId='urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:deny-overrides']" mode="combiningalgs">
    <xsl:text>DenyOverrides</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@PolicyCombiningAlgId='urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:deny-overrides']" mode="combiningalgs">
    <xsl:text>DenyOverrides</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@RuleCombiningAlgId='urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:permit-overrides']" mode="combiningalgs">
    <xsl:text>PermitOverrides</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@PolicyCombiningAlgId='urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:permit-overrides']" mode="combiningalgs">
    <xsl:text>PermitOverrides</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@RuleCombiningAlgId='urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable']" mode="combiningalgs">
    <xsl:text>FirstApplicable</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@PolicyCombiningAlgId='urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:first-applicable']" mode="combiningalgs">
    <xsl:text>FirstApplicable</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@PolicyCombiningAlgId='urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:only-one-applicable']" mode="combiningalgs">
    <xsl:text>OnlyOneApplicable</xsl:text>
  </xsl:template>
  
  <xsl:template match="*" mode="combiningalgs">
    <xsl:text>UnknownCombiningAlgorithm</xsl:text>
  </xsl:template>
  
  <xsl:template match="text()" mode="rules">
  </xsl:template>

  <xsl:template match="xacml:Target" mode="conditions">
    <xsl:if test=".//xacml:Subject">
      <xsl:text>(</xsl:text>
      <xsl:for-each select=".//xacml:Subject">
        <xsl:apply-templates select="." mode="conditions"/>
        <xsl:if test="not(position()=last())"><xsl:text> ||
	</xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:if test=".//xacml:Subject and .//xacml:Resource"><xsl:text> &amp;&amp;
	</xsl:text></xsl:if>
    <xsl:if test=".//xacml:Resource">
      <xsl:text>(</xsl:text>
      <xsl:for-each select=".//xacml:Resource">
        <xsl:apply-templates select="." mode="conditions"/>
        <xsl:if test="not(position()=last())"><xsl:text> ||
	</xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:if test="(.//xacml:Subject or .//xacml:Resource) and .//xacml:Action"><xsl:text> &amp;&amp;
	</xsl:text></xsl:if>
    <xsl:if test=".//xacml:Action">
      <xsl:text>(</xsl:text>
      <xsl:for-each select=".//xacml:Action">
        <xsl:apply-templates select="." mode="conditions"/>
        <xsl:if test="not(position()=last())"><xsl:text> ||
	</xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xacml:Subject|xacml:Resource|xacml:Action" mode="conditions">
    <xsl:text>(</xsl:text>
    <xsl:for-each select="xacml:SubjectMatch|xacml:ResourceMatch|xacml:ActionMatch">
      <xsl:apply-templates select="." mode="functions">
        <xsl:with-param name="temp" select="1"/>
        <xsl:with-param name="toplevel" select="true()"/>
      </xsl:apply-templates>
      <xsl:if test="not(position()=last())"><xsl:text> &amp;&amp;
	  </xsl:text></xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[sig:badfunction(@FunctionId) or sig:badfunction(@MatchId)]" mode="functions">
    <xsl:text>EXPRESSIONS.</xsl:text>
    <xsl:value-of select="generate-id(.)"/>
    <xsl:if test="$toplevel">
      <xsl:text> = XACMLTrue</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[sig:xacml-ends-with(@MatchId, '-equal')]" mode="functions">
    <!-- according to the spec the first value of any match is always an
    attribute, so this is in fact just fine. -->
    <xsl:text>(some x</xsl:text>
    <xsl:copy-of select="$temp"/>
    <xsl:text>:</xsl:text>
    <xsl:apply-templates select="*[2]" mode="datatype"/>
    <xsl:text> | x</xsl:text>
    <xsl:copy-of select="$temp"/>
    <xsl:text> in </xsl:text>
    <xsl:apply-templates select="*[2]" mode="functions">
      <xsl:with-param name="temp" select="$temp + 1"/>
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text> &amp;&amp; x</xsl:text>
    <xsl:copy-of select="$temp"/>
    <xsl:text> = </xsl:text>
    <xsl:apply-templates select="*[1]" mode="functions">
      <xsl:with-param name="temp" select="$temp + 1"/>
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[sig:xacml-ends-with(@FunctionId, '-equal')]" mode="functions">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]" mode="functions">
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text> = </xsl:text>
    <xsl:apply-templates select="*[2]" mode="functions">
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[sig:xacml-ends-with(@FunctionId, '-is-in')]" mode="functions">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]" mode="functions">
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text> in </xsl:text>
    <xsl:apply-templates select="*[2]" mode="functions">
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[sig:xacml-ends-with(@FunctionId, '-at-least-one-member-of')]" mode="functions">
    <xsl:text>(some </xsl:text>
    <xsl:apply-templates select="*[1]" mode="functions">
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text> &amp; </xsl:text>
    <xsl:apply-templates select="*[2]" mode="functions">
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[sig:xacml-ends-with(@FunctionId, '-subset')]" mode="functions">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]" mode="functions">
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text> in </xsl:text>
    <xsl:apply-templates select="*[2]" mode="functions">
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[sig:xacml-ends-with(@FunctionId, '-intersection')]" mode="functions">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]" mode="functions">
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text> &amp; </xsl:text>
    <xsl:apply-templates select="*[2]" mode="functions">
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[sig:xacml-ends-with(@FunctionId, '-union')]" mode="functions">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]" mode="functions">
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text> + </xsl:text>
    <xsl:apply-templates select="*[2]" mode="functions">
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[sig:xacml-ends-with(@FunctionId, '-set-equals')]" mode="functions">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]" mode="functions">
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text> = </xsl:text>
    <xsl:apply-templates select="*[2]" mode="functions">
      <xsl:with-param name="toplevel" select="false()"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <!-- higher order functions: any-of, all-of, any-of-any, all-of-any, any-of-all, all-of-all, map -->
  
  <xsl:template match="*[sig:xacml-ends-with(@FunctionId, '-bag')]" mode="functions">
    <xsl:text>(</xsl:text>
    <xsl:for-each select="*">
      <xsl:apply-templates mode="functions">
        <xsl:with-param name="toplevel" select="false()"/>
      </xsl:apply-templates>
      <xsl:if test="not(position () = last ())"><xsl:text> + </xsl:text></xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="*[@FunctionId='urn:oasis:names:tc:xacml:1.0:function:and']" mode="functions">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]" mode="functions"/>
    <xsl:text> &amp;&amp; </xsl:text>
    <xsl:apply-templates select="*[2]" mode="functions"/>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@FunctionId='urn:oasis:names:tc:xacml:1.0:function:or']" mode="functions">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="*[1]" mode="functions"/>
    <xsl:text> || </xsl:text>
    <xsl:apply-templates select="*[2]" mode="functions"/>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@FunctionId='urn:oasis:names:tc:xacml:1.0:function:not']" mode="functions">
    <xsl:text>!(</xsl:text>
    <xsl:apply-templates select="*[1]" mode="functions"/>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <!-- n-of ? -->
  
  <xsl:template match="*[sig:xacml-ends-with(@FunctionId, '-one-and-only')]" mode="functions">
    <xsl:apply-templates mode="functions"/>
  </xsl:template>

  <xsl:template match="xacml:AttributeValue" mode="functions">
    <xsl:text>CONST_</xsl:text>
    <xsl:value-of select="generate-id(key('constid',normalize-space(.)))"/>
  </xsl:template>
  
  <xsl:template match="xacml:AttributeSelector" mode="functions">
    <xsl:text>ENVIRONMENT.</xsl:text>
    <xsl:value-of select="generate-id(key('selectid',@RequestContextPath))"/>
  </xsl:template>

  <xsl:template match="xacml:SubjectAttributeDesignator|xacml:ResourceAttributeDesignator|xacml:ActionAttributeDesignator|xacml:EnvironmentAttributeDesignator" mode="functions">
    <xsl:text>ENVIRONMENT.</xsl:text>
    <xsl:value-of select="generate-id(key('envid',@AttributeId))"/>
  </xsl:template>

  <xsl:template match="text()" mode="functions"/>
  
  <xsl:template match="*[sig:xacml-ends-with(@FunctionId,'-one-and-only')]" mode="errors">
    <xsl:text>not (one </xsl:text>
    <xsl:apply-templates mode="functions"/>
    <xsl:text>) => no </xsl:text>
    <xsl:value-of select="$rule"/>
    <xsl:text>.conditions,
	</xsl:text>
  </xsl:template>

  <xsl:template match="*" mode="errors">
    <xsl:apply-templates mode="errors">
      <xsl:with-param name="rule" select="$rule"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="text()" mode="errors"/>

  <xsl:template match="*[@DataType='urn:oasis:names:tc:xacml:1.0:data-type:x500Name']" mode="datatype">
    <xsl:text>X500Name</xsl:text>
  </xsl:template>

  <xsl:template match="*[@DataType='urn:oasis:names:tc:xacml:1.0:data-type:rfc822Name']" mode="datatype">
    <xsl:text>RFC822Name</xsl:text>
  </xsl:template>

  <xsl:template match="*[@DataType='http://www.w3.org/2001/XMLSchema#string']" mode="datatype">
    <xsl:text>String</xsl:text>
  </xsl:template>

  <xsl:template match="*[@DataType='http://www.w3.org/2001/XMLSchema#integer']" mode="datatype">
    <xsl:text>Integer</xsl:text>
  </xsl:template>

  <xsl:template match="*[@DataType='http://www.w3.org/2001/XMLSchema#double']" mode="datatype">
    <xsl:text>Double</xsl:text>
  </xsl:template>

  <xsl:template match="*[@DataType='http://www.w3.org/2001/XMLSchema#boolean']" mode="datatype">
    <xsl:text>Boolean</xsl:text>
  </xsl:template>

  <xsl:template match="*[@DataType='http://www.w3.org/2001/XMLSchema#date']" mode="datatype">
    <xsl:text>Date</xsl:text>
  </xsl:template>

  <xsl:template match="*[@DataType='http://www.w3.org/2001/XMLSchema#time']" mode="datatype">
    <xsl:text>Time</xsl:text>
  </xsl:template>

  <xsl:template match="*[@DataType='http://www.w3.org/2001/XMLSchema#datetime']" mode="datatype">
    <xsl:text>DateTime</xsl:text>
  </xsl:template>

  <xsl:template match="*[@DataType='http://www.w3.org/2001/XMLSchema#anyURI']" mode="datatype">
    <xsl:text>AnyURI</xsl:text>
  </xsl:template>

  <xsl:template match="*[@DataType='http://www.w3.org/2001/XMLSchema#hexBinary']" mode="datatype">
    <xsl:text>HexBinary</xsl:text>
  </xsl:template>

  <xsl:template match="*[@DataType='http://www.w3.org/2001/XMLSchema#base64Binary']" mode="datatype">
    <xsl:text>Base64Binary</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@DataType='http://www.w3.org/TR/2002/WD-xquery-operators-20020816#yearMonthDuration']" mode="datatype">
    <xsl:text>YearMonthDuration</xsl:text>
  </xsl:template>

  <xsl:template match="*[@DataType='http://www.w3.org/TR/2002/WD-xquery-operators-20020816#dayTimeDuration']" mode="datatype">
    <xsl:text>DayTimeDuration</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[sig:xacml-ends-with(@FunctionId,'-equal') or
		sig:xacml-ends-with(@FunctionId,'-greater-than') or
		sig:xacml-ends-with(@FunctionId,'-less-than') or
		sig:xacml-ends-with(@FunctionId,'-is-in') or
		sig:xacml-ends-with(@FunctionId,'-at-least-one-member-of') or
		sig:xacml-ends-with(@FunctionId,'-subset') or
		sig:xacml-ends-with(@FunctionId,'-set-equals')]" mode="datatype">
    <xsl:text>Boolean</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[sig:xacml-ends-with(@FunctionId,'-one-and-only') or
		sig:xacml-ends-with(@FunctionId,'-bag') or
		sig:xacml-ends-with(@FunctionId,'-intersection') or
		sig:xacml-ends-with(@FunctionId,'-union')]" mode="datatype">
    <xsl:apply-templates mode="datatype"/>
  </xsl:template>
  
  <xsl:template match="*[sig:xacml-ends-with(@FunctionId,'-match')]" mode="datatype">
    <xsl:text>Boolean</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@FunctionId='urn:oasis:names:tc:xacml:1.0:function: map']" mode="datatype">
    <!-- first argument is always the function to apply -->
    <xsl:apply-templates select="*[2]" mode="datatype"/>
  </xsl:template>
  
  <xsl:template match="*[@FunctionId='urn:oasis:names:tc:xacml:1.0:function:any-of' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:all-of' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:any-of-any' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:all-of-any' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:any-of-all' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:all-of-all']" mode="datatype">
    <xsl:text>Boolean</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[sig:xacml-ends-with(@FunctionId,'-bag-size')]" mode="datatype">
    <xsl:text>Integer</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@FunctionId='urn:oasis:names:tc:xacml:1.0:function:integer-add' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:integer-subtract' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:integer-multiply' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:integer-divide' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:integer-mod' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:integer-abs' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:double-to-integer' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:xpath-node-count']" mode="datatype">
    <xsl:text>Integer</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@FunctionId='urn:oasis:names:tc:xacml:1.0:function:double-add' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:double-subtract' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:double-multiply' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:double-divide' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:double-abs' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:round' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:floor' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:integer-to-double']" mode="datatype">
    <xsl:text>Double</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@FunctionId='urn:oasis:names:tc:xacml:1.0:function:string-normalize-space' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:string-normalize-to-lower-case']" mode="datatype">
    <xsl:text>String</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@FunctionId='urn:oasis:names:tc:xacml:1.0:function:dateTime-add-dayTimeDuration' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:dateTime-add-yearMonthDuration' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:dateTime-subtract-dayTimeDuration' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:dateTime-subtract-yearMonthDuration']"
		mode="datatype">
    <xsl:text>DateTime</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@FunctionId='urn:oasis:names:tc:xacml:1.0:function:date-add-yearMonthDuration' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:date-subtract-yearMonthDuration']"
		mode="datatype">
    <xsl:text>Date</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@FunctionId='urn:oasis:names:tc:xacml:1.0:function:or' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:and' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:n-of' or
		@FunctionId='urn:oasis:names:tc:xacml:1.0:function:not']" mode="datatype">
    <xsl:text>String</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[@MatchId]" mode="datatype">
    <xsl:text>Boolean</xsl:text>
  </xsl:template>

  <xsl:template match="*" mode="datatype">
    <xsl:text>UnrecognizedDatatype</xsl:text>
  </xsl:template>
</xsl:stylesheet>
