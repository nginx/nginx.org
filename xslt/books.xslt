<?xml version="1.0" encoding="utf-8"?>
<!--
  Copyright (C) Igor Sysoev
  Copyright (C) Nginx, Inc.
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="book">

    <table><tr>

    <td bgcolor="#EEEEEE">
    <a href="{@link}">
    <img src="{@cover}" alt="" style="padding: 2pt;" border="0"/>
    </a>
    </td>

    <td>
    <xsl:text>title: </xsl:text> <a href="{@link}"><xsl:value-of select="@title"/></a> <br/>
    <xsl:choose><xsl:when test="@author2"> <xsl:text>authors: </xsl:text> </xsl:when><xsl:otherwise> <xsl:text>author: </xsl:text> </xsl:otherwise></xsl:choose>
    <xsl:choose><xsl:when test="@site"> <a href="{@site}"><xsl:value-of select="@author"/></a> </xsl:when><xsl:otherwise> <xsl:value-of select="@author"/> </xsl:otherwise></xsl:choose>
    <xsl:if test="@author2">
        <xsl:text>,</xsl:text> <br/> <xsl:text>&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;</xsl:text>
        <xsl:choose><xsl:when test="@site2"> <a href="{@site2}"><xsl:value-of select="@author2"/></a> </xsl:when><xsl:otherwise> <xsl:value-of select="@author2"/> </xsl:otherwise></xsl:choose>
    </xsl:if>
    <br/>
    <xsl:if test="@translator"> <xsl:text>translator: </xsl:text> <xsl:value-of select="@translator"/> <br/> </xsl:if>
    <xsl:if test="@publisher"> <xsl:text>publisher: </xsl:text> <xsl:value-of select="@publisher"/> <br/> </xsl:if>
    <xsl:text>language: </xsl:text> <xsl:value-of select="@lang"/>
    </td>

    </tr></table>
</xsl:template>

</xsl:stylesheet>
