<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:func="http://exslt.org/functions"
  xmlns:xacml="urn:oasis:names:tc:xacml:1.0:policy"
  xmlns:sig="http://www.sigwinch.org/functions"
  extension-element-prefixes="exsl func"
  exclude-result-prefixes="exsl func">
  
  <func:function name="sig:ends-with">
    <xsl:param name="original"/>
    <xsl:param name="tail"/>
    <xsl:variable name="taillen" select="string-length($tail)"/>
    <xsl:variable name="start" select="string-length($original) - $taillen + 1"/>
    <func:result select="substring ($original, $start, $taillen) = $tail"/>
  </func:function>
  
  <func:function name="sig:xacml-ends-with">
    <xsl:param name="function"/>
    <xsl:param name="tail"/>
    <func:result select="starts-with($function, 'urn:oasis:names:tc:xacml:1.0:function:') and
		sig:ends-with($function, $tail)"/>
  </func:function>
  
  <func:function name="sig:badfunction">
    <xsl:param name="function"/>
    <xsl:choose>
      <xsl:when test="starts-with($function, 'urn:oasis:names:tc:xacml:1.0:function:') and
		(sig:ends-with($function, '-less-than-or-equal') or
		 sig:ends-with($function, '-greater-than-or-equal') or
		 sig:ends-with($function, '-less-than') or
		 sig:ends-with($function, '-greater-than') or
		 sig:ends-with($function, '-match') or
		 sig:ends-with($function, '-bag-size'))">
        <func:result select="true()"/>
      </xsl:when>
      <xsl:when test="$function='urn:oasis:names:tc:xacml:1.0:function:xpath-node-count' or
		$function='urn:oasis:names:tc:xacml:1.0:function:xpath-node-equal' or
		$function='urn:oasis:names:tc:xacml:1.0:function:date-add-yearMonthDuration' or
		$function='urn:oasis:names:tc:xacml:1.0:function:date-subtract-yearMonthDuration' or
		$function='urn:oasis:names:tc:xacml:1.0:function:dateTime-add-yearMonthDuration' or
		$function='urn:oasis:names:tc:xacml:1.0:function:dateTime-subtract-yearMonthDuration' or
		$function='urn:oasis:names:tc:xacml:1.0:function:dateTime-add-dayTimeDuration' or
		$function='urn:oasis:names:tc:xacml:1.0:function:dateTime-subtract-dayTimeDuration' or
		$function='urn:oasis:names:tc:xacml:1.0:function:double-to-integer' or
		$function='urn:oasis:names:tc:xacml:1.0:function:integer-to-double' or
		$function='urn:oasis:names:tc:xacml:1.0:function:string-normalize-space' or
		$function='urn:oasis:names:tc:xacml:1.0:function:string-normalize-to-lower-case' or
		$function='urn:oasis:names:tc:xacml:1.0:function:integer-add' or
		$function='urn:oasis:names:tc:xacml:1.0:function:integer-subtract' or
		$function='urn:oasis:names:tc:xacml:1.0:function:integer-multiply' or
		$function='urn:oasis:names:tc:xacml:1.0:function:integer-divide' or
		$function='urn:oasis:names:tc:xacml:1.0:function:integer-mod' or
		$function='urn:oasis:names:tc:xacml:1.0:function:double-add' or
		$function='urn:oasis:names:tc:xacml:1.0:function:double-subtract' or
		$function='urn:oasis:names:tc:xacml:1.0:function:double-multiply' or
		$function='urn:oasis:names:tc:xacml:1.0:function:double-divide' or
		$function='urn:oasis:names:tc:xacml:1.0:function:integer-abs' or
		$function='urn:oasis:names:tc:xacml:1.0:function:double-abs' or
		$function='urn:oasis:names:tc:xacml:1.0:function:round' or
		$function='urn:oasis:names:tc:xacml:1.0:function:floor'">
        <func:result select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </func:function>
</xsl:stylesheet>