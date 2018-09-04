<x:transform xmlns:x="http://www.w3.org/1999/XSL/Transform" version="1.0"
           xmlns="http://www.w3.org/2000/svg"
           xmlns:xlink="http://www.w3.org/1999/xlink">

  <!-- we could use fn:upper-case but trying to stay on xslt1.0 for performance -->
  <x:variable name="lowercase" select="'abcdeéèfghijklmnopqrstuvwxyz'" />
  <x:variable name="uppercase" select="'ABCDEÉÈFGHIJKLMNOPQRSTUVWXYZ'" />


  <x:variable name="scaling-factor" select="100000"/>

  <x:variable name="background" select="'#571845'"/>
  <x:variable name="station" select="'#900c3e'"/>
  <x:variable name="road" select="'#c70039'"/>
  <x:variable name="park" select="'#ff5733'"/>
  <x:variable name="railway" select="'#ffc300'"/>


  <x:variable name="minlat" select="/osm/bounds/@minlat * $scaling-factor"/>
  <x:variable name="minlon" select="/osm/bounds/@minlon * $scaling-factor"/>
  <x:variable name="maxlat" select="/osm/bounds/@maxlat * $scaling-factor"/>
  <x:variable name="maxlon" select="/osm/bounds/@maxlon * $scaling-factor"/>

  <x:variable name="width" select="($maxlon - $minlon)"/>
  <x:variable name="height" select="$maxlat - $minlat"/>

  <x:template match="/"><x:apply-templates/></x:template>

  <x:output indent="yes"/>

  <x:template match="osm">
    <svg version="1.1" viewBox="0 0 {$width} {$height}" width="2000px" height="1500px" preserveAspectRatio="none" id="svgroot">
      <style>
        .polygon {
          filter: url('#hand-drawn');
        }

        .rail {
          filter: drop-shadow(7px 7px 2px black);
          font-family: 'BritishRailLightNormal';
          font-size: 40px;
          font-weight: bold;
        }

        .filtered{
          filter: url(#filter);
          -webkit-filter: url(#filter);
          fill: #9673FF;
          color: #9673FF;
          font-family: 'Alfa Slab One', cursive;
          text-transform: uppercase;
          font-size: 40px;
        }

        .way {
          filter: url(#hand-drawn);
        }

      </style>


      <filter id="hand-drawn">
        <feTurbulence type="turbulence" baseFrequency="0.02"
                      numOctaves="1" result="turbulence"/>
        <feDisplacementMap in2="turbulence" in="SourceGraphic"
                           scale="4" xChannelSelector="R" yChannelSelector="G"/>
      </filter>


      <rect x="0" y="0" width="{$width}" height="{$height}" fill="{$background}"/>


      // roads
      <x:apply-templates select="way[tag[@k='highway' and (@v='primary' or
                                                           @v='secondary' or
                                                           @v='tertiary' or
                                                           @v='residential' or
                                                           @v='trunk' or
                                                           @v='unclassified' or
                                                           @v='pedestrian')]]" mode="line"/>

      <x:apply-templates select="way[tag[@k='railway' and @v='rail']]" mode="railway"/>


      <x:apply-templates select="way[tag[@k='leisure' and (@v='park' or
                                                           @v='pitch' or
                                                           @v='playground')]]" mode="polygon"/>

      <x:apply-templates select="node[tag[@k='railway' and @v='station']]" mode="suburb-name"/>

      <!-- and now transform all road paths into splines -->
      <script>
        <![CDATA[
          const reg = /(?:M|L)([-\d.]+),([-\d.]+)/;
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

          document.querySelectorAll('.way').forEach(way => {
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
    <text class="rail"
          transform=" translate({$x},{$y + 43}) scale(1.5, 1.0)"
          text-anchor="middle"
          fill="{$railway}">
      <x:value-of select="tag[@k='name']/@v"/>
    </text>
  </x:template>

  <x:template match="way" mode="line">
    <x:variable name="stroke-width">
      <x:choose>
        <x:when test="tag[@k='highway' and (@v='primary' or @v='trunk')]">20px</x:when>
        <x:when test="tag[@k='highway' and @v='secondary']">8px</x:when>
        <x:when test="tag[@k='highway' and (@v='tertiary' or @v='unclassified')]">5px</x:when>
        <x:when test="tag[@k='highway' and @v='residential']">5px</x:when>
        <x:when test="tag[@k='highway' and @v='pedestrian']">5px</x:when>
        <x:otherwise>0</x:otherwise>
      </x:choose>
    </x:variable>
    <path class="way" id="ID{@id}" fill="none" stroke="{$road}" stroke-width="{$stroke-width}"  stroke-linejoin="round" stroke-linecap="round">
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
         fill="none"
         stroke="{$railway}"
         stroke-width="10px"
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
    <path class="polygon" id="ID{@id}" fill="{$park}">
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
