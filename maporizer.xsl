<transform xmlns="http://www.w3.org/1999/XSL/Transform" version="2.0" 
           xmlns:s="http://www.w3.org/2000/svg"
           xmlns:f="http://lapin-bleu.net"
           xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <variable name="minlat" select="/osm/bounds/@minlat"/>
  <variable name="minlon" select="/osm/bounds/@minlon"/>
  <variable name="maxlat" select="/osm/bounds/@maxlat"/>
  <variable name="maxlon" select="/osm/bounds/@maxlon"/>

  <template match="/"><apply-templates/></template>

  <output indent="yes"/>

  <template match="osm">
    <s:svg version="1.1" viewBox="{$minlon} {-$maxlat} {$maxlon - $minlon} {$maxlat - $minlat}" width="100%" height="100%">
      <s:rect x="{$minlon}" y="{-$maxlat}" width="{$maxlon - $minlon}" height="{$maxlat - $minlat}" fill="lightblue"/>
      <apply-templates select="node"/>
      <apply-templates select="way[tag[@k='area' and @v='yes']]" mode="area"/>
      <apply-templates select="way[not(tag[@k='area' and @v='yes'])]" mode="road"/>
    </s:svg>
  </template>


  <template match="node">
    <s:circle cx="{@lon}" cy="{- @lat}" r="0.00001" fill="red"/>
  </template>

  <template match="way" mode="area">
    <s:polygon fill="green" stroke="none">
      <attribute name="points">
        <for-each select="nd">
          <variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <value-of select="concat($node/@lon,',',-$node/@lat,' ')"/>
        </for-each>
      </attribute>
    </s:polygon>
  </template>

  <template match="way" mode="road">
    <s:polyline stroke-width="0.000005" fill="none" stroke="black">
      <attribute name="points">
        <for-each select="nd">
          <variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <value-of select="concat($node/@lon,',',-$node/@lat,' ')"/>
        </for-each>
      </attribute>
    </s:polyline>
  </template>



</transform>

