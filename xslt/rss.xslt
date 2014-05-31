<?xml version="1.0" encoding="utf-8"?>
<!--
  Copyright (C) Igor Sysoev
  Copyright (C) Nginx, Inc.
  -->

<xsl:stylesheet xmlns:date="http://exslt.org/dates-and-times" exclude-result-prefixes="date" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output indent="no" encoding="utf-8"/>

<xsl:strip-space elements="*"/>

<!--
  .. a current directory of a XSLT script is where the script is stored,
  .. but not where XSLT processor has been started to run the script
  -->
<xsl:param select="'../xml'" name="XML"/>
<xsl:param name="YEAR"/>

<xsl:variable select="'http://nginx.org'" name="SITE"/>
<xsl:variable select="/news/@link" name="LINK"/>

<xsl:include href="dirname.xslt"/>
<xsl:include href="link.xslt"/>
<xsl:include href="menu.xslt"/>
<xsl:include href="content.xslt"/>


<xsl:template match="/news">
    <rss version="2.0">
    <channel>
    <title> <xsl:value-of select="@name"/> </title>
    <link> <xsl:value-of select="$SITE"/> </link>
    <description/>
    <xsl:apply-templates select="event"/>
    </channel>
    </rss>
</xsl:template>


<xsl:template match="event[position() &lt;= 10]">

    <xsl:variable name="year"> <xsl:value-of select="substring(../event[position()=1]/@date, 1, 4)"/> </xsl:variable>
    <xsl:variable name="y"> <xsl:value-of select="substring(@date, 1, 4)"/> </xsl:variable>

    <xsl:variable name="page">
        <xsl:if test="$year != $y">
            <xsl:value-of select="concat($y, '.html')"/>
        </xsl:if>
    </xsl:variable>

    <item>
        <title> <xsl:apply-templates select="para[1]//text()"/> </title>
        <guid> <xsl:value-of select="$SITE"/> <xsl:text>/</xsl:text> <xsl:value-of select="$page"/> <xsl:text>#</xsl:text> <xsl:value-of select="@date"/> </guid>
        <link> <xsl:value-of select="$SITE"/> <xsl:text>/</xsl:text> <xsl:value-of select="$page"/> <xsl:text>#</xsl:text> <xsl:value-of select="@date"/> </link>
        <pubDate>
            <xsl:value-of select=" concat(date:day-abbreviation(@date), ', ',
                      format-number(date:day-in-month(@date), '00'), ' ',
                      date:month-abbreviation(@date), ' ',
                      date:year(@date),
                      ' 00:00:00 +0300') "/>
        </pubDate>

        <description>
            <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
            <xsl:value-of select="@date"/>
            <xsl:apply-templates select="para"/>
            <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
         </description>
    </item>
</xsl:template>


<xsl:template match="event"> </xsl:template>


</xsl:stylesheet>
