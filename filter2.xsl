<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="node"/>
  <xsl:template match="relation"/>

  <xsl:template match="way/nd">
    <xsl:variable name="node" select="/osm/node[@id = current()/@ref]"/>
    <node lat="{$node/@lat}" lon="{$node/@lon}"/>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:transform>
