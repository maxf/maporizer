<x:transform xmlns:x="http://www.w3.org/1999/XSL/Transform" version="1.0"
           xmlns="http://www.w3.org/2000/svg"
           xmlns:xlink="http://www.w3.org/1999/xlink">

  <!-- we could use fn:upper-case but trying to stay on xslt1.0 for performance -->
  <x:variable name="lowercase" select="'abcdeéèfghijklmnopqrstuvwxyz'" />
  <x:variable name="uppercase" select="'ABCDEÉÈFGHIJKLMNOPQRSTUVWXYZ'" />


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
    <svg version="1.1" viewBox="-100 -60 3000 2000" width="1600px" height="1600px" preserveAspectRatio="none" id="svgroot">
      <style>
        @import url(../style.css);
      </style>
      <filter id="hand-drawn">
        <feTurbulence type="turbulence" baseFrequency="0.03"
                      numOctaves="1" result="turbulence" seed="1"
                      stitchTiles="stitch"
                      />
        <feDisplacementMap in2="turbulence" in="SourceGraphic"
                           scale="4" xChannelSelector="R" yChannelSelector="G"/>
      </filter>


      <rect x="0" y="0" width="{$width}" height="{$height}" class="background"/>


      <x:apply-templates select="way[tag[@k='highway' and (@v='primary' or
                                                           @v='secondary' or
                                                           @v='tertiary' or
                                                           @v='residential' or
                                                           @v='trunk' or
                                                           @v='unclassified' or
                                                           @v='cycleway' or
                                                           @v='service' or
                                                           @v='footway' or
                                                           @v='pedestrian')]]" mode="line"/>

<!--
      <x:apply-templates select="way[tag[@k='leisure' and (@v='park')]]" mode="polygon"/>
-->

      <x:apply-templates select="way[tag[@k='building']]" mode="polygon"/>


      <x:apply-templates select="way[tag[@k='railway' and @v='rail']]" mode="railway"/>
<!--
    <x:apply-templates select="node[tag[@k='railway' and @v='station']]" mode="suburb-name"/>
-->


      <rect x="-100" y="-100" width="{$width + 200}" height="{$height + 200}" class="frame"/>
      <rect x="0" y="0" width="{$width}" height="{$height}" class="border"/>
      <text
            transform="scale(3.3,2) translate(0, {$height + 100})"
            class="title">P E C K H A M</text>


      <!-- and now transform all road paths into splines -->

     <script>
        <![CDATA[
          const reg = /(?:M|L)([-\d.]+),([-\d.]+)/;

/*
          document.querySelectorAll('.rail').forEach(way => {
            const path = way.getAttribute('d').split(' ').map(p => {
              const m = p.match(reg);
              return {x:parseFloat(m[1],10), y:parseFloat(m[2],10)};
            });
            let beziers = [`M${path[0].x},${path[0].y}`];
            beziers.push(` Q${(path[0].x+path[1].x)/2},${(path[0].y+path[1].y)/2}`);
            beziers.push(` ${path[1].x},${path[1].y}`);
            for (i=2; i<path.length; i++) {
              beziers.push(` T${path[i].x},${path[i].y}`);
            }
            way.setAttribute('d', beziers.join(''));
          });
*/
          document.querySelectorAll('.rail').forEach(way => {
            const path = way.getAttribute('d').split(' ').map(p => {
              const m = p.match(reg);
              return {x:parseFloat(m[1],10), y:parseFloat(m[2],10)};
            });
            const s = i => `${path[i].x},${path[i].y}`;
            const m = (i, j) => `${(path[i].x+path[j].x)/2},${(path[i].y+path[j].y)/2}`;

            let beziers = [`M${s(0)}`];
            beziers.push(` L${m(0,1)}`);
            let i=1;
            for (i=1; i<path.length-1; i++) {
              beziers.push(` Q${s(i)} ${m(i,i+1)}`);
            }
            beziers.push(` L${s(i)}`);

            way.setAttribute('d', beziers.join(''));
          });
        ]]>
      </script>
   </svg>
  </x:template>

  <x:template match="node" mode="suburb-name">
    <x:variable name="x" select="@lon * $scaling-factor - $minlon"/>
    <x:variable name="y" select="-@lat * $scaling-factor + $maxlat"/>
    <text class="station"
          transform=" translate({$x},{$y + 43}) scale(1.5, 1.0)"
          text-anchor="middle">
      <x:value-of select="tag[@k='name']/@v"/>
    </text>
  </x:template>

  <x:template match="way" mode="line">
    <x:variable name="size">
      <x:choose>
        <x:when test="tag[@k='highway' and (@v='primary' or @v='trunk')]">xl</x:when>
        <x:when test="tag[@k='highway' and @v='secondary']">l</x:when>
        <x:when test="tag[@k='highway' and (@v='tertiary' or @v='unclassified')]">m</x:when>
        <x:when test="tag[@k='highway' and @v='residential']">s</x:when>
        <x:when test="tag[@k='highway' and @v='pedestrian']">s</x:when>
        <x:otherwise>xs</x:otherwise>
      </x:choose>
    </x:variable>
    <path class="way {$size}" id="ID{@id}" stroke-linejoin="round" stroke-linecap="round">
      <x:attribute name="d">
        <x:for-each select="nd">
          <x:value-of select="if (position() = 1) then 'M' else ' L'"/>
          <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <x:value-of select="concat($node/@lon * $scaling-factor - $minlon,',',-$node/@lat * $scaling-factor + $maxlat)"/>
        </x:for-each>
      </x:attribute>
    </path>
  </x:template>

  <x:template match="way" mode="railway">
     <path
         class="rail"
         id="ID{@id}"
         stroke-linejoin="round"
         stroke-linecap="round">
      <x:attribute name="d">
        <x:for-each select="nd">
          <x:value-of select="if (position() = 1) then 'M' else ' L'"/>
          <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <x:value-of select="concat($node/@lon * $scaling-factor - $minlon,',',-$node/@lat * $scaling-factor + $maxlat)"/>
        </x:for-each>
      </x:attribute>
    </path>
  </x:template>

 <x:template match="way" mode="polygon">
    <path class="park" id="ID{@id}">
      <x:attribute name="d">
        <x:for-each select="nd">
          <x:value-of select="if (position() = 1) then 'M' else ' L'"/>
          <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <x:value-of select="concat($node/@lon * $scaling-factor - $minlon,',',-$node/@lat * $scaling-factor + $maxlat)"/>
        </x:for-each>
      </x:attribute>
    </path>
  </x:template>

</x:transform>
