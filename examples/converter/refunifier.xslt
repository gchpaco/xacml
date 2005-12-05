<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xacml="urn:oasis:names:tc:xacml:1.0:policy"
  version="1.0">

  <xsl:output method="xml"/>

  <xsl:key name="policy" match="xacml:Policy" use="@PolicyId"/>

  <xsl:template match="xacml:PolicyIdReference">
    <xsl:copy-of select="key('policy',normalize-space(text()))"/>
  </xsl:template>

  <xsl:template match="/foo">
    <xsl:for-each select=".//xacml:Rule|.//xacml:Policy|.//xacml:PolicySet">
      <xsl:if test="position() = last()">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
