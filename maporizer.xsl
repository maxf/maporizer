<x:transform xmlns:x="http://www.w3.org/1999/XSL/Transform" version="2.0" 
           xmlns="http://www.w3.org/2000/svg"
           xmlns:f="http://lapin-bleu.net"
           xmlns:xlink="http://www.w3.org/1999/xlink"
           xmlns:xs="http://www.w3.org/2001/XMLSchema">


  <x:variable name="scaling-factor" select="100000"/>

  <x:variable name="minlat" select="/osm/bounds/@minlat * $scaling-factor"/>
  <x:variable name="minlon" select="/osm/bounds/@minlon * $scaling-factor"/>
  <x:variable name="maxlat" select="/osm/bounds/@maxlat * $scaling-factor"/>
  <x:variable name="maxlon" select="/osm/bounds/@maxlon * $scaling-factor"/>

  <x:variable name="width" select="$maxlon - $minlon"/>
  <x:variable name="height" select="$maxlat - $minlat"/>

  <x:template match="/"><x:apply-templates/></x:template>

  <x:output indent="yes"/>

  <x:template match="osm">
<!--    <svg version="1.1" viewBox="{$minlon} {-$maxlat} {$width} {$height}" width="100%" height="100%"> -->
    <svg version="1.1" viewBox="0 0 {$width} {$height}" width="100%" height="100%">

      <defs>
        <x:apply-templates select="way[tag[@k='highway'] and not(tag[@k='area'])]" mode="highway-path"/>
      </defs>

      <rect x="0" y="0" width="{$width}" height="{$height}" fill="lightblue"/>

      <x:apply-templates select="way[tag[@k='area' and @v='yes']]" mode="area-draw"/>
      <x:apply-templates select="way[tag[@k='highway'] and not(tag[@k='area'])]" mode="highway-text"/>
    </svg>
  </x:template>


  <x:template match="way" mode="area-draw">
      <polygon fill="blue" id="{generate-id()}">
        <x:attribute name="points">
          <x:for-each select="nd">
            <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
            <x:value-of select="concat($node/@lon * $scaling-factor - $minlon,',',-$node/@lat * $scaling-factor + $maxlat,' ')"/>
          </x:for-each>
        </x:attribute>
      </polygon>
    <script><![CDATA[
      var id = "]]><x:value-of select="generate-id()"/><![CDATA[";
      var text = "]]><x:value-of select="tag[@k='name']/@v"/><![CDATA[";
      var poly = document.getElementById(id);
      var bbox = poly.getBBox();
      console.log(bbox);
      for (var i=0; i<10; i++) {
        var x = bbox.x + Math.random() * bbox.width;
        var y = bbox.y + Math.random() * bbox.height;
        var fontSize = 10 + Math.random() * 10;
        var newString = document.createElementNS("http://www.w3.org/2000/svg","text");
        newString.setAttributeNS(null,"x",x);		
        newString.setAttributeNS(null,"y",y);
        newString.setAttributeNS(null,"stroke","white");
        newString.setAttributeNS(null,"stroke-width", fontSize/15);
        newString.setAttributeNS(null,"fill","black");
        newString.setAttributeNS(null,"font-size", fontSize);
        newString.setAttributeNS(null,"font-family","Verdana");
        newString.setAttributeNS(null,"text-anchor","middle");
        newString.setAttributeNS(null,"transform","rotate("+(Math.random()*40-5)+")");
        var textNode = document.createTextNode(text);
        newString.appendChild(textNode);
        poly.parentElement.appendChild(newString);
      }      
    ]]></script>
  </x:template>

  <x:template match="way" mode="highway-path">
    <path id="ID{@id}">
      <x:attribute name="d">
        <x:for-each select="nd">
          <x:value-of select="if (position() = 1) then 'M' else 'L'"/>
          <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <x:value-of select="concat($node/@lon * $scaling-factor - $minlon,',',-$node/@lat * $scaling-factor + $maxlat,' ')"/>
        </x:for-each>
      </x:attribute>
    </path>
  </x:template>

  <x:template match="way" mode="highway-text">
    <x:variable name="font-size">
      <x:choose>
        <x:when test="tag[@k='highway' and @v='tertiary']">10</x:when>
        <x:when test="tag[@k='highway' and @v='residential']">8</x:when>
        <x:when test="tag[@k='highway' and @v='pedestrian']">6</x:when>
        <x:otherwise>4</x:otherwise>
      </x:choose>
    </x:variable>

    <use xlink:href="#ID{@id}" fill="none" stroke="white" stroke-width="10" />
    <text font-family="Verdana" font-size="{$font-size}" fill="black">
      <textPath xlink:href="#ID{@id}" baseline-shift="-30%">
        <x:value-of select="for $a in (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1) return concat(tag[@k='name']/@v, ' -')"/>
      </textPath>
    </text>

  </x:template>



</x:transform>

