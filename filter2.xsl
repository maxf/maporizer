<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--  <xsl:strip-space elements="*"/> -->
  <xsl:output indent="yes"/>

  <xsl:template match="osm">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()"/>

  <xsl:template match="way[tag[@k='highway' and (@v='trunk' or @v='primary' or @v='secondary')]]">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="way[tag[@k='leisure' and (@v='common' or @v='park' or @v='golf_course')]]">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="way[tag[@k='landuse' and @v='cemetery']]">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="way[count(tag)=0]">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="relation[tag[@k='leisure' and (@v='common' or @v='park' or @v='golf_course')]]">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="bounds">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="node">
    <node id="{@id}" lat="{@lat}" lon="{@lon}"/>
  </xsl:template>

</xsl:transform>
