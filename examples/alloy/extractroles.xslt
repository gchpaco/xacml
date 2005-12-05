<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xacml="urn:oasis:names:tc:xacml:1.0:policy">
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:template match='xacml:SubjectAttributeDesignator[@AttributeId="urn:com:example:network:target:role" or @AttributeId="urn:com:example:network:source:role"]'>
    <role><xsl:copy-of select="normalize-space(../xacml:AttributeValue/text())"/></role>
  </xsl:template>
  <xsl:template match='xacml:SubjectAttributeDesignator[@AttributeId="urn:com:example:network:target:network" or @AttributeId="urn:com:example:network:source:network"]'>
    <network><xsl:copy-of select="normalize-space(../xacml:AttributeValue/text())"/></network>
  </xsl:template>
  
  <xsl:template match="text()"/>
  
  <xsl:template match="/">
    <collection>
      <xsl:apply-templates/>
    </collection>
  </xsl:template>
</xsl:stylesheet>