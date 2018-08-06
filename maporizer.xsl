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
    <svg version="1.1" viewBox="0 0 {$width} {$height}" width="100%" height="100%" id="svgroot">

      <rect x="{-$width}" y="{-$height}" width="{3*$width}" height="{3*$height}" fill="#ddd"/>
      <rect x="0" y="0" width="{$width}" height="{$height}" stroke="black" stroke-width="2px"/>


      // roads
      <x:apply-templates select="way[tag[@k='highway' and (@v='primary' or
                                                           @v='secondary' or
                                                           @v='tertiary' or
                                                           @v='residential' or
                                                           @v='trunk' or
                                                           @v='unclassified' or
                                                           @v='pedestrian')]]"/>
    </svg>
  </x:template>

  <x:template match="way">
    <x:variable name="stroke-width">
      <x:choose>
        <x:when test="tag[@k='highway' and (@v='primary' or @v='trunk')]">20px</x:when>
        <x:when test="tag[@k='highway' and @v='secondary']">18px</x:when>
        <x:when test="tag[@k='highway' and (@v='tertiary' or @v='unclassified')]">16px</x:when>
        <x:when test="tag[@k='highway' and @v='residential']">13px</x:when>
        <x:when test="tag[@k='highway' and @v='pedestrian']">10px</x:when>
        <x:otherwise>0</x:otherwise>
      </x:choose>
    </x:variable>

    <path id="ID{@id}" fill="none" stroke="#d55" stroke-width="{$stroke-width}"  stroke-linejoin="round" stroke-linecap="round">
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
