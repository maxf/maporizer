<x:transform xmlns:x="http://www.w3.org/1999/XSL/Transform" version="1.0"
           xmlns="http://www.w3.org/2000/svg"
           xmlns:xlink="http://www.w3.org/1999/xlink">

  <x:param name="W" select="5000"/>
  <x:param name="H" select="5000"/>
  <x:param name="pxWidth" select="'1000px'"/>
  <x:param name="pxHeight" select="'1000px'"/>
  <x:param name="border" select="200"/>
  <x:param name="bottom-border" select="800"/>
  <x:param name="title" select="''"/>

  <x:param name="bgCol" select="'black'"/>

  <x:variable name="border-width" select="$W - (2 * $border)"/>
  <x:variable name="border-height" select="$H - $border - $bottom-border"/>
  <x:variable name="F" select="($border-width div $border-height) * 1.3"/>

  <x:variable name="minLon" select="/osm/bounds/@minlon + 0.0005"/>
  <x:variable name="maxLon" select="/osm/bounds/@maxlon - 0.0005"/>
  <x:variable name="minLat" select="/osm/bounds/@minlat + 0.0005"/>
  <x:variable name="maxLat" select="/osm/bounds/@maxlat - 0.0005"/>

  <x:output indent="yes"/>

  <x:template match="/"><x:apply-templates/></x:template>

  <x:template match="osm">
    <svg version="1.1" viewBox="0 0 {$W} {$H}" width="{$pxWidth}" height="{$pxHeight}" id="svgroot">
      <style>@import url(style.css);</style>

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

          <x:apply-templates
              select="(way|relation)[tag[@k='leisure' and (@v='common' or @v='park' or @v='golf_course')]]"
              mode="park"/>

          <x:apply-templates
              select="(way|relation)[tag[@k='landuse' and @v='cemetery']]"
              mode="park"/>


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
              mode="road"/>

          <x:apply-templates
              select="way[tag[@k='railway' and @v='rail']]"
              mode="railway"/>

        </g>
      </g>


      <!-- clipping rectangles -->
      <rect x="{$border div 2}" y="{$border div 2}"
            width="{$W - $border}" height="{$H - $bottom-border}"
            fill="none" stroke="{$bgCol}" stroke-width="{$border}"/>

      <rect x="0" y="{$H - $bottom-border}"
            width="{$W}" height="{$bottom-border}"
            fill="{$bgCol}" />

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
          x="{$W div 2}" y="{$H - 200}"
          font-size="550"
          text-anchor="middle"
          class="title"><x:value-of select="$title"/></text>

      <script href="flatten.umd.min.js" type="application/javascript"></script>
      <script href="seedrandom.js" type="application/javascript"></script>
      <script href="svg.js" type="application/javascript"></script>
      <script href="draw.js" type="application/javascript"></script>
   </svg>
  </x:template>

  <x:template match="relation" mode="park">
    <x:apply-templates select="member" mode="park"/>
  </x:template>

  <x:template match="member" mode="park">
    <x:call-template name="path">
      <x:with-param name="way" select="id(@ref)"/>
      <x:with-param name="class" select="'park'"/>
    </x:call-template>
  </x:template>

  <x:template match="way" mode="road">
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
    <x:call-template name="path">
      <x:with-param name="class" select="concat('way ', $size)"/>
    </x:call-template>
  </x:template>

  <x:template match="way" mode="park">
    <x:call-template name="path">
      <x:with-param name="class" select="'park'"/>
    </x:call-template>
  </x:template>

  <x:template name="path">
    <x:param name="way" select="."/>
    <x:param name="class" select="''"/>
    <path class="{$class}">
      <x:attribute name="d">
        <x:for-each select="$way/nd">
          <x:variable name="node" select="id(@ref)"/>
          <x:value-of select="if (position() = 1) then 'M' else ' L'"/>
          <x:value-of select="concat($node/@lon,',',$node/@lat)"/>
        </x:for-each>
      </x:attribute>
    </path>
  </x:template>

</x:transform>
