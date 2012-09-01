%.svg: %.xml maporizer.xsl
	java -jar saxon.jar -t -s:$< -xsl:maporizer.xsl -o:$@

