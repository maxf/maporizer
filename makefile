%.xml: %.osm fix-osm.xsl
	time java -jar saxon.jar -s:$< -xsl:fix-osm.xsl -o:$@

%.svg: %.xml maporizer.xsl
	time java -jar saxon.jar -s:$< -xsl:maporizer.xsl -o:$@ title='P E C K H A M'

.PRECIOUS: .xml
