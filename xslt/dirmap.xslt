<?xml version="1.0" encoding="utf-8"?>
<!--
  Copyright (C) Nginx, Inc.
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="text"/>

<xsl:strip-space elements="*"/>

<xsl:template match="link">
    <xsl:value-of select="@id"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="substring-before(@doc, '.xml')"/>
    <xsl:text>.html#</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text>;&#10;</xsl:text>
</xsl:template>

<xsl:template match="link[@id = 'include']">
    <xsl:text>\</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="substring-before(@doc, '.xml')"/>
    <xsl:text>.html#</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text>;&#10;</xsl:text>
</xsl:template>

<xsl:template match="link[starts-with(@id, 'var_')]">
    <xsl:text>$</xsl:text>
    <xsl:value-of select="substring-after(@id, 'var_')"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="substring-before(@doc, '.xml')"/>
    <xsl:text>.html#</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text>;&#10;</xsl:text>
</xsl:template>

<xsl:template match="links | varlinks">
    <xsl:for-each select="link"><xsl:sort select="@id"/>
        <xsl:if test="count(preceding-sibling::link[@id = current()/@id]) = 0">
            <xsl:apply-templates select="."/>
        </xsl:if>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
