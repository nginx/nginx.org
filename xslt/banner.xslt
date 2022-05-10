<?xml version="1.0" encoding="utf-8"?>
<!--
  Copyright (C) Nginx, Inc.
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:variable select="'/banner/banner.html'" name="BANNER"/>

<xsl:template name="banner_link">
    <xsl:choose><xsl:when test="substring-after($DIRNAME, '/')">
        <xsl:value-of select=" concat($ROOT, $BANNER) "/>
    </xsl:when><xsl:otherwise>
        <xsl:value-of select=" substring-after($BANNER, '/') "/>
    </xsl:otherwise></xsl:choose>
</xsl:template>

<xsl:template name="banner">

    <script>
        window.addEventListener("load", function(e) {
            fetch("<xsl:call-template name="banner_link"/>")
                .then((response) => response.text())
                .then((resp) => {
                    document.getElementById("banner").innerHTML = resp;
                })
                .catch((error) => {
                    console.warn(error);
                });
        });
    </script>

</xsl:template>

</xsl:stylesheet>
