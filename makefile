%.svg: %.xml maporizer-bxl.xsl
	java -jar saxon.jar -t -s:$< -xsl:maporizer-bxl.xsl -o:$@

