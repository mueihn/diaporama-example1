<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output
		method="text"
		encoding="utf-8"
		omit-xml-declaration="no"
		/>

	<!-- open config.xml from the same directory as the input XML -->
	<xsl:variable name="params" select="document('./config.xml', /)/config/param[not(./@name = ./following-sibling::param/@name)]" />

	<!-- variables to access the photos and advertisements from the input XML -->
	<xsl:variable name="photos" select="/files/photos/photo" />
	<xsl:variable name="advertisements" select="/files/advertisements/advertisement" />

	<!-- pre-calculate the number of photo positions that will be in the slideshow -->
	<xsl:variable name="numberOfPhotoPositions">
		<xsl:choose>
			<xsl:when test="count($photos) = 0 or $params[./@name = 'numberFotosBetweenAdvertisements'] = 0">
				<xsl:value-of select="0"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="temp">
					<xsl:choose>
						<xsl:when test="count($photos) &gt; count($advertisements) * $params[./@name = 'numberFotosBetweenAdvertisements']">
							<xsl:value-of select="count($photos)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="count($advertisements) * $params[./@name = 'numberFotosBetweenAdvertisements']"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="count($advertisements) &gt; 0">
						<!-- round up number of photo positions to an integer multiple of the
							intended number of photos between advertisement slides -->
						<xsl:value-of select="ceiling($temp div $params[./@name = 'numberFotosBetweenAdvertisements'])
									* $params[./@name = 'numberFotosBetweenAdvertisements']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$temp"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- main template as entry point of the processing -->
	<xsl:template match="/">
		<xsl:text>{</xsl:text>
			<xsl:text>"generator": {</xsl:text>
				<xsl:text>"url": "https://github.com/mueihn/slideshow-generator-canossa"</xsl:text>
			<xsl:text>}, </xsl:text>
			<xsl:text>"timeline": [</xsl:text>
				<xsl:choose>
					<xsl:when test="count($photos) = 0 or $params[./@name = 'numberFotosBetweenAdvertisements'] = 0">
						<!-- only show advertisements -->
						<!-- this also covers the special case of the list of advertisements being empty -->
						<xsl:for-each select="$advertisements">
							<xsl:apply-templates select="."/>
							<xsl:if test="generate-id(.) != generate-id($advertisements[last()])">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<!-- show an interleaving of photos and advertisements -->
						<xsl:call-template name="printPositions">
							<xsl:with-param name="toPos" select="$numberOfPhotoPositions - 1"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			<xsl:text>]</xsl:text>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<!-- named template that creates the intended interleaving of advertisements and photos -->
	<xsl:template name="printPositions">
		<xsl:param name="fromPos" select="0"/>
		<xsl:param name="toPos"/>

		<!-- this recursive iteration template is inspired by an answer at stackoverflow.com:
			https://stackoverflow.com/questions/9076323/xslt-looping-from-1-to-60#answer-9081077 -->

		<xsl:choose>
			<xsl:when test="$fromPos &gt; $toPos">
				<!-- we always iterate in ascending manner over a range of numbers -->
				<xsl:call-template name="printPositions">
					<xsl:with-param name="fromPos" select="$toPos"/>
					<xsl:with-param name="toPos" select="$fromPos"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$fromPos = $toPos">
						<!-- do the actual thing that shall be done per iteration -->
						<xsl:variable name="currPos" select="$fromPos"/>
						<!-- in some cases, write out an advertisement before the current photo -->
						<xsl:if test="count($advertisements) &gt; 0">
							<xsl:if test="$currPos mod $params[./@name = 'numberFotosBetweenAdvertisements'] = 0">
								<xsl:if test="$params[./@name = 'startWithAdvertisement'] = '1' or $currPos &gt; 0">
									<xsl:variable name="advertisementPos" select="$currPos div $params[./@name = 'numberFotosBetweenAdvertisements']
																- 1 + $params[./@name = 'startWithAdvertisement']"/>
									<xsl:apply-templates select="$advertisements[($advertisementPos mod count($advertisements)) + 1]"/>
									<xsl:text>, </xsl:text>
								</xsl:if>
							</xsl:if>
						</xsl:if>
						<!-- write out the photo for the current position -->
						<xsl:apply-templates select="$photos[($currPos mod count($photos)) + 1]"/>
						<!-- in one case, write out an advertisement after the current photo -->
						<xsl:if test="count($advertisements) &gt; 0">
							<xsl:if test="not($params[./@name = 'startWithAdvertisement'] = '1')">
								<xsl:if test="$currPos = $numberOfPhotoPositions - 1">
									<xsl:text>, </xsl:text>
									<xsl:variable name="advertisementPos" select="($currPos + 1) div $params[./@name = 'numberFotosBetweenAdvertisements']
																- 1 + $params[./@name = 'startWithAdvertisement']"/>
									<xsl:apply-templates select="$advertisements[($advertisementPos mod count($advertisements)) + 1]"/>
								</xsl:if>
							</xsl:if>
						</xsl:if>
						<!-- write out a comma except after the globally last position -->
						<xsl:if test="$currPos &lt; $numberOfPhotoPositions - 1">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<!-- split the range in the middle and do one recursive call per sub range -->
						<xsl:variable name="midPos" select="floor(($fromPos + $toPos) div 2)"/>
						<xsl:call-template name="printPositions">
							<xsl:with-param name="fromPos" select="$fromPos"/>
							<xsl:with-param name="toPos" select="$midPos"/>
						</xsl:call-template>
						<xsl:call-template name="printPositions">
							<xsl:with-param name="fromPos" select="$midPos + 1"/>
							<xsl:with-param name="toPos" select="$toPos"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- template that writes out the markup for a photo slide -->
	<xsl:template match="photo">
		<xsl:text>{</xsl:text>
			<xsl:text>"image": "</xsl:text><xsl:value-of select="."/><xsl:text>", </xsl:text>
			<xsl:text>"duration": </xsl:text><xsl:value-of select="$params[./@name = 'displaySecondsPerPhoto'] * 1000"/><xsl:text></xsl:text>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<!-- template that writes out the markup for an advertisement slide -->
	<xsl:template match="advertisement">
		<xsl:text>{</xsl:text>
			<xsl:text>"image": "</xsl:text><xsl:value-of select="."/><xsl:text>", </xsl:text>
			<xsl:text>"duration": </xsl:text><xsl:value-of select="$params[./@name = 'displaySecondsPerAdvertisement'] * 1000"/><xsl:text></xsl:text>
		<xsl:text>}</xsl:text>
	</xsl:template>

</xsl:stylesheet>
