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
<xsl:stylesheet exclude-result-prefixes="nf xd xs xsl" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:pharm="urn:ihe:pharm:medication" xmlns:nf="http://www.nictiz.nl/functions" xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" xmlns:hl7nl="urn:hl7-nl:v3" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:import href="../../2_hl7_mp_include_920.xsl"/>
    <xsl:output method="xml" indent="yes"/>
    <!-- Generates a HL7 message based on ADA input -->

    <!-- give dateT a value when you need conversion of relative T dates, typically only needed for test instances -->
    <!--    <xsl:param name="dateT" as="xs:date?" select="current-date()"/>-->
        <xsl:param name="dateT" as="xs:date?" select="xs:date('2021-03-24')"/>
<!--    <xsl:param name="dateT" as="xs:date?"/>-->
    <!-- whether to generate a user instruction description text from the structured information, typically only needed for test instances  -->
    <xsl:param name="generateInstructionText" as="xs:boolean?" select="true()"/>
    <!-- param to influence whether to output schematron references, typically only needed for test instances -->
    <xsl:param name="schematronRef" as="xs:boolean" select="false()"/>

    <xsl:template match="/">
        <xsl:call-template name="Voorschrift_9x">
            <xsl:with-param name="in" select="adaxml/data/sturen_medicatievoorschrift"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="Voorschrift_9x">
        <xsl:param name="in" select="adaxml/data/sturen_medicatievoorschrift"/>

        <xsl:variable name="patient" select="$in/patient"/>
        <xsl:variable name="mbh" select="$in/medicamenteuze_behandeling"/>

        <xsl:if test="$schematronRef">
            <xsl:processing-instruction name="nictiz">status="example"</xsl:processing-instruction>
            <!--                        <xsl:processing-instruction name="xml-model">phase="#ALL" href="../../schematron_closed_warnings/mp-MP90_vo.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron" phase="#ALL"</xsl:processing-instruction>-->
<!--            <xsl:processing-instruction name="xml-model">phase="#ALL" href="file:/C:/SVN/AORTA/branches/Onderhoud_Mp_v90/XML/schematron_closed_warnings/mp-MP90_vo.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron" phase="#ALL"</xsl:processing-instruction>-->
            <xsl:processing-instruction name="xml-model">phase="#ALL" href="file:/C:/SVN/AORTA/trunk/Zorgtoepassing/Medicatieproces/DECOR/mp-runtime-develop/mp-mp92_vo.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron" phase="#ALL"</xsl:processing-instruction>
            <!--<xsl:if test="not(contains($in/@id, 'voorbeeld'))">
                <xsl:processing-instruction name="xml-model">href="../../../../../../../../../../../SVN/art_decor/trunk/ada-data/ada_2_test-xslt/mp/9.1.0/sturen_medicatievoorschrift/test_xslt_instance/<xsl:value-of select="$in/@id"/>.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
            </xsl:if>-->
        </xsl:if>
        <xsl:comment>Generated from ada instance with title: "<xsl:value-of select="$mbh/../@title"/>" and id: "<xsl:value-of select="$mbh/../@id"/>".</xsl:comment>
        <organizer xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:hl7-org:v3" xmlns:cda="urn:hl7-org:v3" xmlns:hl7nl="urn:hl7-nl:v3" xmlns:pharm="urn:ihe:pharm:medication" xsi:schemaLocation="urn:hl7-org:v3 file:/C:/SVN/AORTA/branches/Onderhoud_Mp_v90/XML/schemas/organizer.xsd" classCode="CLUSTER" moodCode="EVN">
            <templateId root="2.16.840.1.113883.2.4.3.11.60.20.77.10.9328"/>
            <code code="95" displayName="Voorschrift" codeSystem="2.16.840.1.113883.2.4.3.11.60.20.77.4" codeSystemName="ART DECOR transacties"/>
            <statusCode nullFlavor="NI"/>
            <!-- Patient -->
            <xsl:for-each select="$patient">
                <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.3.10.1_20180611000000"/>
            </xsl:for-each>
            <!-- Medicamenteuze behandeling -->
            <xsl:for-each select="$mbh">
                <!-- Medicatieafspraak -->
                <xsl:for-each select="medicatieafspraak[not(kopie_indicator/@value = 'true')]">
                    <component typeCode="COMP">
                        <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9324_20201015132016"/>
                    </component>
                </xsl:for-each>
                <!-- Medicatieafspraak -->
                <xsl:for-each select="medicatieafspraak[kopie_indicator/@value = 'true']">
                    <component typeCode="COMP">
                        <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9325_20201515132423"/>
                    </component>
                </xsl:for-each>
                <!-- Verstrekkingsverzoek -->
                <xsl:for-each select="verstrekkingsverzoek">
                    <component typeCode="COMP">
                        <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9356_20210402132627"/>
                    </component>
                </xsl:for-each>
            </xsl:for-each>
            <!-- Lichaamslengte -->
            <xsl:for-each select="$in/bouwstenen/lichaamslengte[.//(@value | @code)]">
                <component typeCode="COMP">
                    <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.7.10.30_20171025000000"/>
                </component>
            </xsl:for-each>
            <!-- Lichaamsgewicht -->
            <xsl:for-each select="$in/bouwstenen/lichaamsgewicht[.//(@value | @code)]">
                <component typeCode="COMP">
                    <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.121.10.19_20210701000000"/>
                </component>
            </xsl:for-each>         
        </organizer>
    </xsl:template>
</xsl:stylesheet>
