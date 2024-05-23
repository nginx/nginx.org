<?xml version="1.0" encoding="utf-8"?>
<!--
  Copyright (C) Igor Sysoev
  Copyright (C) Nginx, Inc.
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="mainline_version">
   <xsl:apply-templates select="document(concat($XML, '/versions.xml'))
                /versions/download[@tag='mainline'][1]/item[1]/@ver"/>
</xsl:template>

<xsl:template match="stable_version">
   <xsl:apply-templates select="document(concat($XML, '/versions.xml'))
                /versions/download[@tag='stable'][1]/item[1]/@ver"/>
</xsl:template>

<xsl:template match="commercial_version">
    <a href="https://www.f5.com/products">
    <xsl:apply-templates/>
    </a>
</xsl:template>

</xsl:stylesheet>
