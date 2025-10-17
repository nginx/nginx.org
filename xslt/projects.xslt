<?xml version="1.0" encoding="utf-8"?>
<!--
  Copyright (C) Nginx, Inc.
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="topnews">
    <xsl:text disable-output-escaping="yes">
        &lt;table class="news"&gt;
    </xsl:text>
    <xsl:apply-templates select="document(concat($XML, '/index.xml'))/news/event[position() &lt;= 4]"/>
    <xsl:text disable-output-escaping="yes">
        &lt;/table&gt;
    </xsl:text>
</xsl:template>

<xsl:template match="event">
    <tr>
    <td class="date">
        <a name="{@date}"/> <xsl:value-of select="@date"/>
    </td>
    <td> <xsl:apply-templates select="para"/> </td>
    </tr>
</xsl:template>

<xsl:template match="projects"> <div class="projects"> <xsl:apply-templates/> </div> </xsl:template>

<xsl:template match="project">

    <table>

    <tr>
    <td width="90px" align="center" valign="middle">
    <a href="{@docs}" valign="top">
    <img src="{@logo}" width="50px" alt="{@title} logo"/>
    </a>
    </td>

    <td valign="bottom">
    <strong> <xsl:value-of select="@title"/> </strong> <xsl:text> </xsl:text> <xsl:value-of select="@description"/> <br/>
    <a href="{@docs}">Docs</a> •
    <a href="{@repo}">Code</a>
    </td>
    </tr>

    <tr>
    <td colspan="2"><br/></td>
    </tr>

    </table>
</xsl:template>

</xsl:stylesheet>
