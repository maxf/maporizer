<transform xmlns="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:s="http://www.w3.org/2000/svg">

  <template match="/"><apply-templates/></template>

  <template match="osm">
    <s:svg version="1.1" viewBox="{bounds/@minlon} {bounds/@minlat} {bounds/@maxlat - bounds/@minlat} {bounds/@maxlon - bounds/@minlon}" width="100%" height="100%">
      <s:rect x="{bounds/@minlon}" y="{bounds/@minlat}" width="{bounds/@maxlat - bounds/@minlat}" height="{bounds/@maxlon - bounds/@minlon}" fill="lightblue"/>
      <apply-templates select="node"/>
      <apply-templates select="way"/>
    </s:svg>
  </template>


  <template match="node">
    <s:circle cx="{@lon}" cy="{@lat}" r="0.00001" fill="red"/>
  </template>

  <template match="way">
    <s:path stroke-width="0.000005" stroke="green">
      <attribute name="d">
        <for-each select="nd">
          <choose>
            <when test="position()=1">M </when>
            <otherwise>L </otherwise>
          </choose>
          <variable name="node" select="/osm/node[@id=current()/@ref]"/>
          <value-of select="concat($node/@lon,' ',$node/@lat,' ')"/>
        </for-each>
        <if test="tag[@k='area' and @v='yes']"> z</if>
      </attribute>
    </s:path>
  </template>


</transform>