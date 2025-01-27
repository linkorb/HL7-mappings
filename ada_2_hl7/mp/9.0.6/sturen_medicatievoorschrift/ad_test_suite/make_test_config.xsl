<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright © Nictiz

This program is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation; either version
2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<xsl:stylesheet exclude-result-prefixes="#all" xmlns:nf="http://www.nictiz.nl/functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="xml" indent="yes"/>
	<xsl:variable name="ada-files" select="collection('POC/20180704_POC_dag/ada_instance/?select=*.xml')"/>
	<xsl:template match="/">
		<tests>
			<xsl:for-each select="$ada-files">
				<test name="{.//data/*/@title}">
					<pattern-id value="pattern_{.//data/*/@id}"/>
					<data-string-medication-code>
						<xsl:attribute name="value">
							<xsl:value-of select="'data(('"/>
							<xsl:for-each select="distinct-values(.//data//product_code/@code)">
								<xsl:value-of select="concat('''',.,'''')"/>
								<xsl:if test="not(position() = last())">,</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="'))'"/>
						</xsl:attribute>
					</data-string-medication-code>
					<data-int-medication-code>
						<xsl:attribute name="value">
							<xsl:value-of select="'data(('"/>
							<xsl:for-each select="distinct-values(.//data//product_code/@code)">
								<xsl:value-of select="."/>
								<xsl:if test="not(position() = last())">,</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="'))'"/>
						</xsl:attribute>
					</data-int-medication-code>
					<medication-name>
						<xsl:attribute name="value">
							<xsl:value-of select="'data(('"/>
							<xsl:for-each select="distinct-values(.//data//product_code/@displayName)">
								<xsl:value-of select="concat('''',.,'''')"/>
								<xsl:if test="not(position() = last())">,</xsl:if>
							</xsl:for-each>
							<xsl:value-of select="'))'"/>
						</xsl:attribute>
					</medication-name>
					<ada-instance-filename value="POC/20180704_POC_dag/ada_instance/{.//data/*/@id}.xml"/>
				</test>
			</xsl:for-each>
		</tests>
	</xsl:template>
</xsl:stylesheet>
