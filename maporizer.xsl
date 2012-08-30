<transform xmlns="http://www.w3.org/1999/XSL/Transform" version="2.0" 
           xmlns:s="http://www.w3.org/2000/svg"
           xmlns:f="http://lapin-bleu.net"
           xmlns:xlink="http://www.w3.org/1999/xlink"
           xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <variable name="minlat" select="/osm/bounds/@minlat * 1000"/>
  <variable name="minlon" select="/osm/bounds/@minlon * 1000"/>
  <variable name="maxlat" select="/osm/bounds/@maxlat * 1000"/>
  <variable name="maxlon" select="/osm/bounds/@maxlon * 1000"/>

  <template match="/"><apply-templates/></template>

  <output indent="yes"/>

  <template match="osm">
    <s:svg version="1.1" viewBox="{$minlon} {-$maxlat} {$maxlon - $minlon} {$maxlat - $minlat}" width="100%" height="100%" preserveAspectRatio="none">

      <s:defs>
        <apply-templates select="way[tag[@k='highway'] and not(tag[@k='area'])]" mode="highway-path"/>
      <apply-templates select="way[tag[@k='area' and @v='yes']]" mode="area-pattern"/>
      </s:defs>


      <s:rect x="{$minlon}" y="{-$maxlat}" width="{$maxlon - $minlon}" height="{$maxlat - $minlat}" fill="lightblue"/>

      <apply-templates select="way[tag[@k='area' and @v='yes']]" mode="area-draw"/>
      <apply-templates select="way[tag[@k='highway'] and not(tag[@k='area'])]" mode="highway-text"/>
    </s:svg>
  </template>


  <template match="way" mode="area-pattern">
   <s:pattern id="ID{@id}" patternUnits="objectBoundingBox"
            x="0" y="0" width=".3" height=".3"
            viewBox="0 0 10 10" >
        <s:text x="1" y="6" font-family="Verdana" font-size="5" fill="black">
          <value-of select="tag[@k='name']/@v"/>
        </s:text>
<!--        <s:rect x="0" y="0" width="10" height="10" stroke="red" /> -->
    </s:pattern> 
  </template>


  <template match="way" mode="area-draw">
    <s:polygon fill="url(#ID{@id})" stroke="none">
      <attribute name="points">
        <for-each select="nd">
          <variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <value-of select="concat($node/@lon * 1000,',',-$node/@lat * 1000,' ')"/>
        </for-each>
      </attribute>
    </s:polygon>
  </template>

  <template match="way" mode="highway-path">
    <s:path id="ID{@id}">
      <attribute name="d">
        <for-each select="nd">
          <value-of select="if (position() = 1) then 'M' else 'L'"/>
          <variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <value-of select="concat($node/@lon * 1000,',',-$node/@lat * 1000,' ')"/>
        </for-each>
      </attribute>
    </s:path>
  </template>

  <template match="way" mode="highway-text">
    <variable name="font-size">
      <choose>
        <when test="tag[@k='highway' and @v='tertiary']">0.10</when>
        <when test="tag[@k='highway' and @v='residential']">0.08</when>
        <when test="tag[@k='highway' and @v='pedestrian']">0.06</when>
        <otherwise>0.04</otherwise>
      </choose>
    </variable>

    <s:use xlink:href="#ID{@id}" fill="none" stroke="red" stroke-width="0.01" />
    <s:text font-family="Verdana" font-size="{$font-size}" fill="black">
      <s:textPath xlink:href="#ID{@id}" baseline-shift="-30%">
        <value-of select="for $a in (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1) return concat(tag[@k='name']/@v, ' -')"/>
      </s:textPath>
    </s:text>

  </template>



</transform>

