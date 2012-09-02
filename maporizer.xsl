<x:transform xmlns:x="http://www.w3.org/1999/XSL/Transform" version="2.0" 
           xmlns="http://www.w3.org/2000/svg"
           xmlns:f="http://lapin-bleu.net"
           xmlns:xlink="http://www.w3.org/1999/xlink"
           xmlns:fn= "http://www.w3.org/2005/xpath-functions"
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
    <svg version="1.1" viewBox="0 0 {$width} {$height}" width="100%" height="100%" id="svgroot">

      <defs>
        <x:apply-templates select="way[tag[@k='highway'] and not(tag[@k='area'])]" mode="highway-path"/>
      </defs>

      <rect x="{-$width}" y="{-$height}" width="{3*$width}" height="{3*$height}" fill="lightblue"/>

      <x:apply-templates select="way[tag[(@k='area' and @v='yes') or @k='natural']]" mode="area-draw"/>
      <x:apply-templates select="way[tag[@k='highway'] and not(tag[@k='area'])]" mode="highway-text"/>
    </svg>
  </x:template>


  <x:template match="way" mode="area-draw">

    <x:variable name="color">
      <x:choose>
        <x:when test="tag[@k='natural' and @v='water']">blue</x:when>
        <x:otherwise>grey</x:otherwise>
      </x:choose>
    </x:variable>

    <clipPath id="clip-{generate-id()}">
      <path>
        <x:attribute name="d">
          <x:for-each select="nd">
            <x:value-of select="if (position() = 1) then 'M' else 'L'"/>
            <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
            <x:value-of select="concat($node/@lon * $scaling-factor - $minlon,',',-$node/@lat * $scaling-factor + $maxlat,' ')"/>
          </x:for-each>
        </x:attribute>
      </path>
    </clipPath>

    <!-- we also need a polygon in order to get the bounding box -->
    <polygon id="{generate-id()}" fill="#ddd">
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
      var color = "]]><x:value-of select="$color"/><![CDATA[";
      var poly = document.getElementById(id);
      var bbox = poly.getBBox();

      var texture = document.createElementNS("http://www.w3.org/2000/svg","g");
      texture.setAttributeNS(null,"clip-path", "url(#clip-"+id+")");

      var xmin = bbox.x - bbox.width/2;
      var width = 2*bbox.width;
      var ymin = bbox.y - bbox.height/2;
      var height = 2*bbox.height;
      var nbStrokes = width*height/100;
      console.log(nbStrokes);

      for (var i=0; i<nbStrokes; i++) {
        var x = xmin + Math.random() * width;
        var y = ymin + Math.random() * height;
        var fontSize = 10 + Math.random() * 10;
        var newString = document.createElementNS("http://www.w3.org/2000/svg","text");
        newString.setAttributeNS(null,"x",x);		
        newString.setAttributeNS(null,"y",y);
        newString.setAttributeNS(null,"stroke","white");
        newString.setAttributeNS(null,"stroke-width", fontSize/15);
        newString.setAttributeNS(null,"fill",color);
        newString.setAttributeNS(null,"font-size", fontSize + "px");
        newString.setAttributeNS(null,"font-family","Impact");
        newString.setAttributeNS(null,"text-anchor","middle");
        newString.setAttributeNS(null,"transform","translate("+x+","+y+") rotate("+(Math.random()*40-5)+") translate(-"+x+",-"+y+")");

        var textNode = document.createTextNode(text.toUpperCase());
        newString.appendChild(textNode);
        texture.appendChild(newString);
      }

      poly.parentElement.appendChild(texture);


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
        <x:when test="tag[@k='highway' and @v='tertiary']">12px</x:when>
        <x:when test="tag[@k='highway' and @v='residential']">8px</x:when>
        <x:when test="tag[@k='highway' and @v='pedestrian']">4px</x:when>
        <x:otherwise>0</x:otherwise>
      </x:choose>
    </x:variable>

<!--    <use xlink:href="#ID{@id}" fill="none" stroke="white" stroke-width="10" /> -->
    <text font-family="Impact" font-size="{$font-size}" fill="black">
      <textPath xlink:href="#ID{@id}" baseline-shift="-30%">
        <x:value-of select="for $a in (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1) return concat(fn:upper-case(tag[@k='name']/@v), '·')"/>
      </textPath>
    </text>

  </x:template>



</x:transform>

