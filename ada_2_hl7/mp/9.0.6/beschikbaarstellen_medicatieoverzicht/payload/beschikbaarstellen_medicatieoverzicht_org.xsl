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
<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" xmlns:hl7nl="urn:hl7-nl:v3" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nf="http://www.nictiz.nl/functions" version="2.0">
    <xsl:import href="../../../2_hl7_mp_include_90.xsl"/>
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#default"/>
	<xsl:template match="/">
		<xsl:call-template name="Medicatieoverzicht_90">
			<xsl:with-param name="patient" select="//beschikbaarstellen_medicatieoverzicht/patient"/>
			<xsl:with-param name="mbh" select="//beschikbaarstellen_medicatieoverzicht/medicamenteuze_behandeling"/>
			<xsl:with-param name="docGeg" select="//beschikbaarstellen_medicatieoverzicht/documentgegevens"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="Medicatieoverzicht_90">
		<xsl:param name="patient"/>
		<xsl:param name="mbh"/>
		<xsl:param name="docGeg"/>

		<!-- phase="#ALL" achteraan de volgende regel zorgt dat oXygen niet met een phase chooser dialoog komt elke keer dat je de HL7 XML opent -->
		<xsl:processing-instruction name="xml-model">href="file:/C:/SVN/AORTA/branches/Onderhoud_Mp_v90/XML/schematron_closed_warnings/mp-MP90_mo.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron" phase="#ALL"</xsl:processing-instruction>

		<organizer xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:hl7-org:v3" xmlns:cda="urn:hl7-org:v3" xmlns:hl7nl="urn:hl7-nl:v3" xmlns:pharm="urn:ihe:pharm:medication" xsi:schemaLocation="urn:hl7-org:v3 file:/C:/SVN/AORTA/branches/Onderhoud_Mp_v90/XML/schemas/organizer.xsd" classCode="CLUSTER" moodCode="EVN">
			<templateId root="2.16.840.1.113883.2.4.3.11.60.20.77.10.9204"/>
			<code code="129" displayName="Medicatieoverzicht" codeSystem="2.16.840.1.113883.2.4.3.11.60.20.77.4" codeSystemName="ART DECOR transacties"/>
			<statusCode nullFlavor="NI"/>

			<!-- Documentdatum -->
			<xsl:call-template name="makeEffectiveTime">
				<xsl:with-param name="effectiveTime" select="$docGeg/document_datum"/>
			</xsl:call-template>

			<!-- Patient -->
			<xsl:for-each select="$patient">
				<xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.3.10.3_20170602000000">
					<xsl:with-param name="in" select="."/>
				</xsl:call-template>
			</xsl:for-each>

			<!-- Auteur (=samenstellende organisatie (of patient) van hele overzicht) -->
			<xsl:for-each select="$docGeg/auteur">
				<xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9171_20180111143827">
					<xsl:with-param name="auteur" select="."/>
				</xsl:call-template>
			</xsl:for-each>

			<!-- Verificatie patient -->
			<xsl:for-each select="$docGeg/verificatie_patient">
				<xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9179_20170523115538"/>
			</xsl:for-each>

			<!-- Verificatie zorgverlener -->
			<xsl:for-each select="$docGeg/verificatie_zorgverlener">
				<xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9180_20170523115753"/>
			</xsl:for-each>

			<xsl:for-each select="$mbh">
				<!-- eigen Medicatieafspraak -->
				<xsl:for-each select="./medicatieafspraak[not(kopie_indicator/@value='true')]">
					<component typeCode="COMP">
						<xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9216_20180423130413">
							<xsl:with-param name="ma" select="."/>
						</xsl:call-template>
					</component>
				</xsl:for-each>
				<!-- andermans Medicatieafspraak -->
				<xsl:for-each select="./medicatieafspraak[kopie_indicator/@value='true']">
					<component typeCode="COMP">
						<xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9202_20180419125808">
							<xsl:with-param name="ma" select="."/>
						</xsl:call-template>
					</component>
				</xsl:for-each>
				<!-- eigen Toedieningsafspraak -->
				<xsl:for-each select="./toedieningsafspraak[not(kopie_indicator/@value='true')]">
					<component typeCode="COMP">
						<xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9223_20180423130413">
							<xsl:with-param name="ta" select="."/>
						</xsl:call-template>
					</component>
				</xsl:for-each>
				<!-- andermans Toedieningsafspraak -->
				<xsl:for-each select="./toedieningsafspraak[kopie_indicator/@value='true']">
					<component typeCode="COMP">
						<xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9205_20180419000000">
							<xsl:with-param name="ta" select="."/>
						</xsl:call-template>
					</component>
				</xsl:for-each>
				<!-- eigen Medicatiegebruik -->
				<xsl:for-each select="./medicatie_gebruik[not(kopie_indicator/@value='true')]">
					<component typeCode="COMP">
						<xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9224_20180423130413">
							<xsl:with-param name="gb" select="."/>
						</xsl:call-template>
					</component>
				</xsl:for-each>
				<!-- andermans Medicatiegebruik -->
				<xsl:for-each select="./medicatie_gebruik[kopie_indicator/@value='true']">
					<component typeCode="COMP">
						<xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9209_20180419000000">
							<xsl:with-param name="gb" select="."/>
						</xsl:call-template>
					</component>
				</xsl:for-each>
				
			</xsl:for-each>
		</organizer>
	</xsl:template>

</xsl:stylesheet>
