<?xml version="1.0" encoding="utf-8"?>
<!--
  Copyright (C) Igor Sysoev
  Copyright (C) Nginx, Inc.
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="menu/item">

    <!--
      ..  variables are not allowed in a template match predicate,
      ..  therefore, we have to use ugly "if"s instead of elegant
      ..     "menu/item[@href = $LINK]", etc.
      -->

    <li>

    <xsl:choose><xsl:when test="@href = $LINK">
        <xsl:choose><xsl:when test="$YEAR and @href='/'">
            <a href="./"> news </a> <br/>
        </xsl:when><xsl:otherwise>
            <xsl:value-of select=" normalize-space(text()) "/><br/>
        </xsl:otherwise></xsl:choose>

    </xsl:when><xsl:otherwise>
        <!--
          .. If a menu item has the switchlang attribute, then it will point
          .. to the same document in the specified language.
          -->
        <xsl:choose><xsl:when test="$TRANS and @switchlang">

            <!--
              .. Check if list of available translations ($TRANS) contains
              .. the language we are going to generate link to.
              .. If yes - generate link, otherwise just name the language.
              -->
            <xsl:choose><xsl:when test="contains($TRANS, @switchlang)">
                <a>
                <xsl:attribute name="href">
                    <xsl:value-of select=" concat($ROOT, '/', @switchlang, '/',
                        substring-after($LINK, concat('/', $LANG, '/'))) "/>
                </xsl:attribute>
                <xsl:value-of select=" normalize-space(text()) "/>
                </a>

            </xsl:when><xsl:otherwise>
                <a class="notrans"> <xsl:value-of select=" normalize-space(text()) "/> </a>
            </xsl:otherwise></xsl:choose>
        </xsl:when><xsl:otherwise>

            <a>
            <xsl:attribute name="href">

                <xsl:choose><xsl:when test="starts-with(@href, $DIRNAME)">
                    <xsl:choose><xsl:when test="substring-after(@href, $DIRNAME) = ''">
                        <xsl:text>./</xsl:text>
                    </xsl:when><xsl:otherwise>
                        <xsl:value-of select=" substring-after(@href, $DIRNAME) "/>
                    </xsl:otherwise></xsl:choose>

                </xsl:when><xsl:otherwise>
                    <xsl:value-of select=" concat($ROOT, @href) "/>
                </xsl:otherwise></xsl:choose>
            </xsl:attribute>
            <xsl:value-of select=" normalize-space(text()) "/>
            </a>

            <xsl:if test="@lang"> <xsl:text> [</xsl:text> <xsl:value-of select="@lang"/> <xsl:text>]</xsl:text></xsl:if>
        </xsl:otherwise></xsl:choose>
    </xsl:otherwise></xsl:choose>
    </li>
</xsl:template>


<xsl:template match="menu/item[@year]">
    <xsl:if test="$YEAR or $LINK='/'">
        <li>
        <xsl:choose><xsl:when test="$YEAR=@year">
            <xsl:value-of select="@year"/>
        </xsl:when><xsl:otherwise>
            <xsl:if test="@href"> <a href="{@href}"> <xsl:value-of select="@year"/> </a> </xsl:if>
        </xsl:otherwise></xsl:choose>
        </li>
    </xsl:if>
</xsl:template>


<xsl:template match="menu/item[starts-with(@href, 'http://') or starts-with(@href, 'https://')]">
    <li>
    <a href="{@href}"> <xsl:value-of select=" normalize-space(text()) "/> </a>
    <xsl:if test="@lang"> <xsl:text> [</xsl:text> <xsl:value-of select="@lang"/> <xsl:text>]</xsl:text></xsl:if>
    </li>
</xsl:template>


<xsl:template match="menu/item[not(@href) and not(@year)]">
    <li><xsl:value-of select=" normalize-space(text()) "/> <br/></li>
</xsl:template>

</xsl:stylesheet>
