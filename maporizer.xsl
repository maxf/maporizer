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
    <svg version="1.1" viewBox="0 0 {$width} {$height}" width="2500px" height="1500px" preserveAspectRatio="none" id="svgroot">

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

    </svg>
  </x:template>


  <x:template match="node" mode="suburb-name">
    <x:message>Found node</x:message>
    <x:variable name="x" select="@lon * $scaling-factor - $minlon"/>
    <x:variable name="y" select="-@lat * $scaling-factor + $maxlat"/>
    <text transform=" translate({$x},{$y + 40}) scale(1.5, 1.0)"
          text-anchor="middle"
          font-size="40px"
          fill="{$railway}"
          font-family="Attach"
          font-weight="bold">
      <x:value-of select="tag[@k='name']/@v"/>
    </text>
  </x:template>

  <x:template match="way" mode="line">
    <x:variable name="stroke-width">
      <x:choose>
        <x:when test="tag[@k='highway' and (@v='primary' or @v='trunk')]">7px</x:when>
        <x:when test="tag[@k='highway' and @v='secondary']">6px</x:when>
        <x:when test="tag[@k='highway' and (@v='tertiary' or @v='unclassified')]">5px</x:when>
        <x:when test="tag[@k='highway' and @v='residential']">4px</x:when>
        <x:when test="tag[@k='highway' and @v='pedestrian']">3px</x:when>
        <x:otherwise>0</x:otherwise>
      </x:choose>
    </x:variable>
    <path id="ID{@id}" fill="none" stroke="{$road}" stroke-width="{$stroke-width}"  stroke-linejoin="round" stroke-linecap="round">
      <x:attribute name="d">
        <x:for-each select="nd">
          <x:value-of select="if (position() = 1) then 'M' else 'L'"/>
          <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <x:value-of select="concat($node/@lon * $scaling-factor - $minlon,',',-$node/@lat * $scaling-factor + $maxlat,' ')"/>
        </x:for-each>
      </x:attribute>
    </path>
  </x:template>

  <x:template match="way" mode="railway">
     <path id="ID{@id}" fill="none" stroke="{$railway}" stroke-width="10px"  stroke-linejoin="round" stroke-linecap="round">
      <x:attribute name="d">
        <x:for-each select="nd">
          <x:value-of select="if (position() = 1) then 'M' else 'L'"/>
          <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <x:value-of select="concat($node/@lon * $scaling-factor - $minlon,',',-$node/@lat * $scaling-factor + $maxlat,' ')"/>
        </x:for-each>
      </x:attribute>
    </path>
  </x:template>

 <x:template match="way" mode="polygon">
    <path id="ID{@id}" fill="{$park}">
      <x:attribute name="d">
        <x:for-each select="nd">
          <x:value-of select="if (position() = 1) then 'M' else 'L'"/>
          <x:variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <x:value-of select="concat($node/@lon * $scaling-factor - $minlon,',',-$node/@lat * $scaling-factor + $maxlat,' ')"/>
        </x:for-each>
      </x:attribute>
    </path>
  </x:template>

</x:transform>
