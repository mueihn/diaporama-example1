<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" indent="yes" />

	<xsl:template match="/">
		<files>
			<photos>
				<xsl:for-each select="/files/photos/photo">
					<xsl:sort select="." order="descending" />
					<photo><xsl:value-of select="." /></photo>
				</xsl:for-each>
			</photos>
			<advertisements>
				<xsl:for-each select="/files/advertisements/advertisement">
					<xsl:sort select="." order="ascending" />
					<advertisement><xsl:value-of select="." /></advertisement>
				</xsl:for-each>
			</advertisements>
		</files>
	</xsl:template>

</xsl:stylesheet>
