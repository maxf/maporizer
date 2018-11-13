<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="way[tag[@k='building']]"/>

  <xsl:template match="tag[@k='surface' or
                           @k='maxspeed' or
                           @k='lit' or
                           @k='sidewalk' or
                           @k='operator' or
                           @k='horse' or
                           @k='oneway' or
                           @k='lanes' or
                           @k='usage' or
                           @k='voltage' or
                           @k='gauge' or
                           @k='foot' or
                           @k='segregated' or
                           @k='source:ref' or
                           @k='frequency' or
                           @k='amenity' or
                           (@k='highway' and @v='bus_stop')]"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:transform>
