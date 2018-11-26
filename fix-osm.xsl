<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output doctype-system="osm.dtd" indent="yes"/>

  <xsl:template match="@id">
    <xsl:attribute name="id">
      <xsl:value-of select="concat(name(parent::node()), .)"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@ref">
    <xsl:variable name="parent" select="name(parent::node())"/>
    <xsl:attribute name="ref">
      <xsl:choose>
        <xsl:when test="$parent = 'nd'">node</xsl:when>
        <xsl:when test="$parent = 'member'">
          <xsl:value-of select="../@type"/>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:transform>
