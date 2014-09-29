<?xml version="1.0" encoding="utf-8"?>
<!--
  Copyright (C) Igor Sysoev
  Copyright (C) Nginx, Inc.
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" version="4.0" indent="no" encoding="utf-8"/>

<xsl:strip-space elements="*"/>

<!--
  .. a current directory of a XSLT script is where the script is stored,
  .. but not where XSLT processor has been started to run the script
  -->
<xsl:param select="'../xml'" name="XML"/>
<xsl:param name="YEAR"/>
<xsl:param name="ORIGIN"/>
<xsl:param name="TRANS"/>

<xsl:variable select="/error/@link" name="LINK"/>
<xsl:variable select="/error/@lang" name="LANG"/>

<xsl:include href="dirname.xslt"/>
<xsl:include href="link.xslt"/>
<xsl:include href="style.xslt"/>
<xsl:include href="body.xslt"/>
<xsl:include href="menu.xslt"/>
<xsl:include href="ga.xslt"/>
<xsl:include href="content.xslt"/>


<xsl:template match="/error">
    <html><head><title> <xsl:value-of select="@name"/> </title>

    <xsl:call-template name="style"><xsl:with-param select="@lang" name="lang"/></xsl:call-template><xsl:call-template name="ga"/></head>

    <xsl:call-template name="body"><xsl:with-param select="@lang" name="lang"/></xsl:call-template></html>
</xsl:template>

</xsl:stylesheet>
