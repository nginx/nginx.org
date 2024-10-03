<?xml version="1.0" encoding="utf-8"?>
<!--
  Copyright (C) Igor Sysoev
  Copyright (C) Nginx, Inc.
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template name="style"><xsl:param name="lang"/>

    <meta name="viewport" content="width=device-width,initial-scale=1"></meta>

    <link>
    <xsl:attribute name="rel">
      <xsl:text>stylesheet</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="href">
      <xsl:choose><xsl:when test="substring-after($DIRNAME, '/')">
          <xsl:value-of select=" concat($ROOT, '/css/style_', $lang, '.css') "/>
      </xsl:when><xsl:otherwise>
          <xsl:value-of select=" substring-after(concat('/css/style_', $lang, '.css'), '/') "/>
      </xsl:otherwise></xsl:choose>
    </xsl:attribute>
    <xsl:apply-templates/>
    </link>

</xsl:template>

</xsl:stylesheet>
