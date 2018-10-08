<x:transform xmlns:x="http://www.w3.org/1999/XSL/Transform" version="1.0"
           xmlns="http://www.w3.org/2000/svg"
           xmlns:xlink="http://www.w3.org/1999/xlink">

  <x:param name="W" select="5000"/>
  <x:param name="H" select="4000"/>
  <x:param name="border" select="200"/>
  <x:param name="bottom-border" select="800"/>

  <x:variable name="border-width" select="$W - (2 * $border)"/>
  <x:variable name="border-height" select="$H - $border - $bottom-border"/>
  <x:variable name="F" select="($border-width div $border-height) * 1.5"/>



  <x:variable name="minLon" select="/osm/bounds/@minlon"/>
  <x:variable name="maxLon" select="/osm/bounds/@maxlon"/>
  <x:variable name="minLat" select="/osm/bounds/@minlat"/>
  <x:variable name="maxLat" select="/osm/bounds/@maxlat"/>


  <x:output indent="yes"/>


  <x:template match="/"><x:apply-templates/></x:template>

  <x:template match="osm">
    <svg version="1.1" viewBox="0 0 {$W} {$H}" width="2000px" height="2500px" id="svgroot">
      <style>@import url(style.css);</style>
      <defs>
        <filter id="hand-drawn">
          <feTurbulence type="turbulence" baseFrequency="5000"
                        numOctaves="1" result="turbulence" seed="1"
                        stitchTiles="stitch" />
          <feDisplacementMap in2="turbulence" in="SourceGraphic" result="displaced"
                             scale="0.00002" xChannelSelector="R" yChannelSelector="G"/>
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

        <g transform="{$trans2}" id="trans2">
<!--
          <x:apply-templates
              select="way[tag[@k='highway' and (@v='primary' or
                      @v='secondary' or
                      @v='tertiary' or
                      @v='residential' or
                      @v='trunk' or
                      @v='unclassified' or
                      @v='cycleway' or
                      @v='service' or
                      @v='footway' or
                      @v='pedestrian')]]"
              mode="line"/>
-->
<!--
          <x:apply-templates
              select="way[tag[@k='building']]"
              mode="building"/>
-->
          <x:apply-templates
              select="way[tag[@k='railway' and @v='rail']]"
              mode="railway"/>

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

      <text
          x="{$W div 2}" y="{$H - 300}"
          font-size="500"
          text-anchor="middle"
          class="title">M O N T P E L I E R</text>



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

  <x:template match="way" mode="park-rough">
    <x:variable name="d">
      <x:for-each select="nd">
        <x:value-of select="if (position() = 1) then 'M' else ' L'"/>
        <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
        <x:value-of select="concat($node/@lon,',',$node/@lat)"/>
      </x:for-each>
    </x:variable>

     g = rc.path('<x:value-of select="$d"/>', { strokeWidth: 0.00002, roughness: 0, fill: 'green', fillStyle: 'solid' });
     svg.appendChild(g);

  </x:template>

  <x:template name="smoothify">
    <script xlink:href="rough.min.js"></script>
    <script>
      <![CDATA[
          const reg = /(?:M|L)([-\d.]+),([-\d.]+)/;
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

          const svg = document.getElementById('trans2');
          const rc = rough.svg(svg);
          let g; ]]>

<!--
            <x:apply-templates select="way[tag[@k='highway' and (@v='primary' or @v='secondary')]]" mode="rough"/>
-->

            <x:apply-templates
                select="way[tag[@k='leisure' and (@v='common' or @v='park')]]"
                mode="park-rough"/>
    </script>
  </x:template>

  <x:template match="way" mode="rough">
    <x:variable name="size">
      <x:choose>
        <x:when test="tag[@k='highway' and (@v='primary' or @v='trunk')]">0.00025</x:when>
        <x:when test="tag[@k='highway' and @v='secondary']">0.00020</x:when>
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
      g = rc.path('<x:value-of select="$d"/>', { strokeWidth: <x:value-of select="$size * 10"/>, roughness: 2.8, stroke: 'rgba(50,255,50,0.5)' });
      svg.appendChild(g);
    </x:if>
  </x:template>


</x:transform>
