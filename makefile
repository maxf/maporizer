%.svg: %.xml maporizer.xsl
	java -jar saxon.jar -s:$< -xsl:maporizer.xsl -o:$@
