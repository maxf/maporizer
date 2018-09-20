<x:transform xmlns:x="http://www.w3.org/1999/XSL/Transform" version="1.0"
           xmlns="http://www.w3.org/2000/svg"
           xmlns:xlink="http://www.w3.org/1999/xlink">

  <x:param name="W" select="400"/>
  <x:param name="H" select="400"/>
  <x:param name="border" select="20"/>
  <x:param name="bottom-border" select="40"/>

  <x:variable name="border-width" select="$W - (2 * $border)"/>
  <x:variable name="border-height" select="$H - $border - $bottom-border"/>
  <x:variable name="F" select="($border-width div $border-height) * 1.2"/>



  <x:variable name="minLat" select="/osm/bounds/@minlat"/>
  <x:variable name="minLon" select="/osm/bounds/@minlon"/>
  <x:variable name="maxLat" select="/osm/bounds/@maxlat"/>
  <x:variable name="maxLon" select="/osm/bounds/@maxlon"/>


  <x:output indent="yes"/>


  <x:template match="/"><x:apply-templates/></x:template>

  <x:template match="osm">
    <svg version="1.1" viewBox="0 0 {$W} {$H}" width="1000px" id="svgroot">
      <style>@import url(style.css);</style>
      <defs>
        <filter id="hand-drawn" filterUnits="objectBoundingBox" primitiveUnits="objectBoundingBox">
          <feTurbulence type="turbulence" baseFrequency="0.3"
                        numOctaves="1" result="turbulence" seed="1"
                        stitchTiles="stitch" />
          <feDisplacementMap in2="turbulence" in="SourceGraphic"
                             scale="0.0004" xChannelSelector="R" yChannelSelector="G"/>
        </filter>
        <filter id="shadow" filterUnits="objectBoundingBox" primitiveUnits="objectBoundingBox">
          <feDropShadow dx=".008" dy="-.008" stdDeviation=".005" flood-color="black"></feDropShadow>
        </filter>
      </defs>


      <rect x="0" y="0" width="{$W}" height="{$H}" class="background"/>

      <g transform="matrix({($W - 2 * $border) div $F}, 0, 0, {$H - $border - $bottom-border}, {$border}, {$border})">

        <x:variable name="deltaLon" select="$maxLon - $minLon"/>
        <x:variable name="deltaLat" select="$maxLat - $minLat"/>
        <x:variable name="Ao" select="$deltaLon div $deltaLat"/>

        <x:variable name="trans2">
          <x:choose>
            <x:when test="$Ao > $F">
              <x:variable name="alphaX" select="$minLon + ($deltaLon - $deltaLat * $F) div 2"/>
              <x:variable name="alphaY" select="$maxLat"/>
              <x:variable name="betaX" select="$maxLon - ($deltaLon - $deltaLat * $F) div 2"/>
              <x:variable name="betaY" select="$minLat"/>

              <x:variable name="sx" select="$F div ($betaX - $alphaX)"/>
              <x:variable name="sy" select="1 div ($betaY - $alphaY)"/>
              <x:variable name="tx" select="- $sx * $alphaX"/>
              <x:variable name="ty" select="- $sy * $alphaY"/>

              <x:value-of select="concat('matrix(',$sx,',0,0,',$sy,',',$tx,',',$ty,')')"/>

            </x:when>
            <x:otherwise>
              <x:variable name="alphaX" select="$minLon"/>
              <x:variable name="alphaY" select="$maxLat - ($deltaLat - $deltaLon div $F) div 2"/>
              <x:variable name="betaX" select="$maxLon"/>
              <x:variable name="betaY" select="$minLat + ($deltaLat - $deltaLon div $F) div 2"/>

              <x:variable name="sx" select="$F div ($betaX - $alphaX)"/>
              <x:variable name="sy" select="1 div ($betaY - $alphaY)"/>
              <x:variable name="tx" select="- $sx * $alphaX"/>
              <x:variable name="ty" select="- $sy * $alphaY"/>

              <x:value-of select="concat('matrix(',$sx,',0,0,',$sy,',',$tx,',',$ty,')')"/>

            </x:otherwise>
          </x:choose>
        </x:variable>

        <g transform="{$trans2}">


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

          <x:apply-templates select="way[tag[@k='railway' and @v='rail']]" mode="railway"/>

          <x:apply-templates
              select="way[tag[@k='leisure' and @v='common']]"
              mode="park"/>


<!--
      <x:apply-templates select="way[tag[@k='building']]" mode="building"/>
-->


        </g>

      </g>


      <!-- clipping rectangles -->
      <rect x="{$border div 2}" y="{$border div 2}"
            width="{$W - $border}" height="{$H - $bottom-border}"
            fill="none" stroke="#e0e4cc" stroke-width="{$border}"/>

      <rect x="0" y="{$H - $bottom-border}"
            width="{$W}" height="{$bottom-border}"
            fill="#e0e4cc" />

      <x:variable name="Z" select="20000"/>
      <rect x="{-$Z div 2}" y="{-$Z div 2}"
            width="{$W + $Z}" height="{$H + $Z}"
            fill="none" stroke="white" stroke-width="{$Z}"/>

      <!-- thin border around map -->
      <rect x="{$border}" y="{$border}"
            width="{$border-width}"
            height="{$border-height}"
            class="border"/>
<!--
      <text
          x="{$border}" y="{$H}"
          font-size="52"
          class="title">P E C K H A M</text>
-->


      <!-- and now make some polylines smooth -->
      <x:call-template name="smoothify"/>
   </svg>
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
    <x:variable name="d">
      <x:for-each select="nd">
        <x:value-of select="if (position() = 1) then 'M' else ' L'"/>
        <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
        <x:value-of select="concat($node/@lon,',',$node/@lat)"/>
      </x:for-each>
    </x:variable>
    <path class="way {$size}" id="ID{@id}" d="{$d}"/>
  </x:template>


  <x:template match="way" mode="railway">
     <path
         class="rail"
         style="filter: url(#shadow)"
         id="ID{@id}"
         stroke-linejoin="round"
         stroke-linecap="round">
      <x:attribute name="d">
        <x:for-each select="nd">
          <x:value-of select="if (position() = 1) then 'M' else ' L'"/>
          <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <x:value-of select="concat($node/@lon,',',$node/@lat)"/>
        </x:for-each>
      </x:attribute>
    </path>
  </x:template>

 <x:template match="way" mode="building">
    <path class="building" id="ID{@id}">
      <x:attribute name="d">
        <x:for-each select="nd">
          <x:value-of select="if (position() = 1) then 'M' else ' L'"/>
          <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <x:value-of select="concat($node/@lon,',',$node/@lat)"/>
        </x:for-each>
      </x:attribute>
    </path>
  </x:template>

 <x:template match="way" mode="park">
    <path class="park" id="ID{@id}">
      <x:attribute name="d">
        <x:for-each select="nd">
          <x:value-of select="if (position() = 1) then 'M' else ' L'"/>
          <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <x:value-of select="concat($node/@lon,',',$node/@lat)"/>
        </x:for-each>
      </x:attribute>
    </path>
  </x:template>

  <x:template name="smoothify">
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
              if (m) {
                return {x:parseFloat(m[1],10), y:parseFloat(m[2],10)};
              } else {
                return null;
              }
            })
            .filter(p => p);
            if (path.length>0) {
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
            }
          });
      ]]>
    </script>
  </x:template>

<!--
    Use rough.js instead of filter to simulate hand-drawn strokes

      <script xlink:href="../rough.min.js"></script>
      <script>
        const svg = document.getElementById('svgroot');
        const rc = rough.svg(svg);
        let g;

      <x:apply-templates select="way[tag[@k='highway' and (@v='primary' or
                                                           @v='secondary' or
                                                           @v='tertiary' or
                                                           @v='residential' or
                                                           @v='trunk' or
                                                           @v='unclassified' or
                                                           @v='cycleway' or
                                                           @v='service' or
                                                           @v='footway' or
                                                           @v='pedestrian')]]" mode="rough"/>
      </script>
  <x:template match="way" mode="rough">
    <x:variable name="size">
      <x:choose>
        <x:when test="tag[@k='highway' and (@v='primary' or @v='trunk')]">8</x:when>
        <x:when test="tag[@k='highway' and @v='secondary']">4</x:when>
        <x:when test="tag[@k='highway' and (@v='tertiary' or @v='unclassified')]">3</x:when>
        <x:when test="tag[@k='highway' and @v='residential']">2</x:when>
        <x:when test="tag[@k='highway' and @v='pedestrian']">2</x:when>
        <x:otherwise>0</x:otherwise>
      </x:choose>
    </x:variable>
    <x:variable name="d">
      <x:for-each select="nd">
        <x:value-of select="if (position() = 1) then 'M' else ' L'"/>
        <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
        <x:value-of select="concat($node/@lon,',',$node/@lat)"/>
      </x:for-each>
    </x:variable>
    <x:if test="$size != 0">
      g = rc.path('<x:value-of select="$d"/>', { strokeWidth: <x:value-of select="$size"/>, roughness: 0 });
      svg.appendChild(g);
    </x:if>
  </x:template>
-->

</x:transform>
