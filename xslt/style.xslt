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
      <xsl:if test="substring-after($DIRNAME, '/') or $LINK = '404.html'">
          <xsl:value-of select=" concat($ROOT, '/') "/>
      </xsl:if>
      <xsl:value-of select=" concat('css/style_', $lang, '.css') "/>
    </xsl:attribute>
    <xsl:apply-templates/>
    </link>

</xsl:template>

</xsl:stylesheet>
