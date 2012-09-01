%.svg: %.xml
	java -jar saxon.jar -t -s:$< -xsl:maporizer.xsl -o:$@

