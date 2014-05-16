<?xml version="1.0" encoding="utf-8"?>
<!--
  Copyright (C) Nginx, Inc.
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="xml" doctype-system="../../../dtd/article.dtd" encoding="utf-8" indent="yes"/>

<!--
  .. a current directory of a XSLT script is where the script is stored,
  .. but not where XSLT processor has been started to run the script
  -->
<xsl:param select="'../xml'" name="XML"/>

<xsl:param name="LANG"/>

<xsl:template match="modules">
    <article name="{document(concat($XML, '/i18n.xml'))
                    /i18n/text[@lang = $LANG]/item[@id='varindex']}" link="/{$LANG}/docs/varindex.html" lang="{$LANG}">
    <section>
    <para>
    <varlinks>
    <xsl:apply-templates select="module"/>
    </varlinks>
    </para>
    </section>
    </article>
</xsl:template>

<xsl:template match="module">
    <xsl:variable select="@name" name="module"/>
    <xsl:for-each select="document(@name)//tag-name/var">
        <link doc="{$module}" id="{../@id}"><xsl:apply-templates/></link>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
