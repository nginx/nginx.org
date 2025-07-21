<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" encoding="utf-8" />

  <!-- Root template -->
  <xsl:template match="/">
    <xsl:text>---</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>title: Variables Index</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>description: Variables Index</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>toc: true</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>nd-org-source: varindex.xml</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>nd-plus: false</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>nd-partial-plus: false</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>---</xsl:text>
    <xsl:text>&#10;&#10;</xsl:text>

    <xsl:for-each select="//varlinks/link">
      <xsl:sort select="@id" order="ascending" />
      <xsl:variable name="markdownPath">
        <xsl:text>/nginx/module-reference/</xsl:text>
        <xsl:value-of select="substring-before(@doc, '.xml')" />
      </xsl:variable>
      <xsl:variable name="moduleName">
        <xsl:choose>
          <xsl:when test="contains(@doc, '/')">
            <xsl:value-of select="substring-before(substring-after(@doc, '/'), '.xml')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="substring-before(@doc, '.xml')" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:text>- [`</xsl:text>
      <xsl:choose>
        <xsl:when test="starts-with(@id, 'var_')">
          <xsl:value-of select="substring-after(@id, 'var_')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@id" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>`]({{&lt; relref &quot;</xsl:text>
      <xsl:value-of select="$markdownPath" />
      <xsl:text>#</xsl:text>
      <xsl:choose>
        <xsl:when test="starts-with(@id, 'var_')">
          <xsl:value-of select="substring-after(@id, 'var_')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@id" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&quot; &gt;}}) (</xsl:text>
      <xsl:value-of select="$moduleName" />
      <xsl:text>)&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
