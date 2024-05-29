<?xml version="1.0" encoding="utf-8"?>
<!--
  Copyright (C) Igor Sysoev
  Copyright (C) Nginx, Inc.
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="security"> <ul> <xsl:apply-templates/> </ul> </xsl:template>


<xsl:template match="security/item">

    <li>
    <p>

    <xsl:value-of select="@name"/><br/>

    <xsl:choose><xsl:when test="@severity = 'major'">
        <xsl:text>Severity: </xsl:text> <b><xsl:value-of select="@severity"/></b><br/>
    </xsl:when><xsl:otherwise>
        <xsl:text>Severity: </xsl:text> <xsl:value-of select="@severity"/><br/>
    </xsl:otherwise></xsl:choose>

    <xsl:if test="@advisory">
        <a href="{@advisory}"> <xsl:text>Advisory</xsl:text> </a>
        <br/>
    </xsl:if>

    <xsl:if test="@cert">
        <a>
        <xsl:attribute name="href">
            <xsl:text>http://www.kb.cert.org/vuls/id/</xsl:text> <xsl:value-of select="@cert"/>
        </xsl:attribute>
        <xsl:text>VU#</xsl:text> <xsl:value-of select="@cert"/>
        </a>
    </xsl:if>

    <xsl:if test="@cve">
        <xsl:if test="@cert">
            <xsl:text>&#xA0;&#xA0;</xsl:text>
        </xsl:if>
        <a>
        <xsl:attribute name="href">
            <xsl:text>https://www.cve.org/CVERecord?id=CVE-</xsl:text> <xsl:value-of select="@cve"/>
        </xsl:attribute>
        <xsl:text>CVE-</xsl:text> <xsl:value-of select="@cve"/>
        </a>
    </xsl:if>

    <xsl:if test="@core">
        <xsl:if test="@cert or @cve">
            <xsl:text>&#xA0;&#xA0;</xsl:text>
        </xsl:if>
        <a href="{@href}"> <xsl:value-of select="@core"/> </a>
    </xsl:if>

    <xsl:if test="@cert or @cve or @core">
        <br/>
    </xsl:if>

    <xsl:text>Not vulnerable: </xsl:text> <xsl:value-of select="@good"/> <br/>
    <xsl:text>Vulnerable: </xsl:text> <xsl:value-of select="@vulnerable"/>

    <xsl:for-each select="patch">
        <br/>

        <a>
        <xsl:attribute name="href">
            <xsl:text>/download/</xsl:text> <xsl:value-of select="@name"/>
        </xsl:attribute>
        <xsl:text>The patch</xsl:text>
        </a>

        <xsl:text>&#xA0;&#xA0;</xsl:text>

        <a>
        <xsl:attribute name="href">
            <xsl:text>/download/</xsl:text> <xsl:value-of select="@name"/> <xsl:text>.asc</xsl:text>
        </xsl:attribute>
        <xsl:text>pgp</xsl:text>
        </a>

        <xsl:if test="@versions">
            <xsl:text>&#xA0;&#xA0;(for </xsl:text> <xsl:value-of select="@versions"/> <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:for-each>

    </p>
    </li>
</xsl:template>


</xsl:stylesheet>
