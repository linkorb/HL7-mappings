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
<xsl:stylesheet exclude-result-prefixes="#all" xmlns="http://hl7.org/fhir" xmlns:f="http://hl7.org/fhir" xmlns:local="urn:fhir:stu3:functions" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:nf="http://www.nictiz.nl/functions" xmlns:uuid="http://www.uuid.org" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>  
    <xsl:param name="referById" as="xs:boolean" select="false()"/>
   
    <xd:doc>
        <xd:desc>Mapping of ADA geboortezorg concept to FHIR Observation <xd:a href="https://simplifier.net/resolve/?target=simplifier&amp;canonical=http://nictiz.nl/fhir/StructureDefinition/zib-LaboratoryTestResult-Observation">zib-LaboratoryTestResult-Observation</xd:a>.</xd:desc>
        <xd:param name="logicalId">Optional FHIR logical id for the record.</xd:param>
        <xd:param name="in">Node to consider in the creation of an Observation resource</xd:param>
        <xd:param name="adaPatient">Required. ADA patient concept to build a reference to from this resource</xd:param>
    </xd:doc>
    <xsl:template name="bc-pregnancy-observation" match="graviditeit | pariteit | pariteit_voor_deze_zwangerschap | a_terme_datum | wijze_einde_zwangerschap | datum_einde_zwangerschap" as="element()">
        <xsl:param name="in" select="." as="element()?"/>
        <xsl:param name="logicalId" as="xs:string?"/>
        <xsl:param name="adaPatient"/>
        <xsl:param name="dossierId"/>
        <xsl:param name="pregnancyId"/>
        
        <xsl:variable name="elementName" select="name(.)"/>
                
        <xsl:for-each select="$in">            
            <Observation>
                <xsl:if test="$referById">
                    <id value="{$logicalId}"/>
                </xsl:if>
                <meta>
                    <xsl:choose>
                        <xsl:when test="$elementName='graviditeit'">
                            <profile value="http://nictiz.nl/fhir/StructureDefinition/zib-Pregnancy-Gravidity"/>
                        </xsl:when>
                        <xsl:when test="$elementName='pariteit' or $elementName='pariteit_voor_deze_zwangerschap'">
                            <profile value="http://nictiz.nl/fhir/StructureDefinition/zib-Pregnancy-Parity"/>
                        </xsl:when>
                        <xsl:when test="$elementName='a_terme_datum'">
                            <profile value="http://nictiz.nl/fhir/StructureDefinition/zib-Pregnancy-TermDate"/>
                        </xsl:when>
                        <xsl:when test="$elementName='wijze_einde_zwangerschap'">
                            <profile value="http://nictiz.nl/fhir/StructureDefinition/bc-WayEndPregnancy"/>
                        </xsl:when>
                        <xsl:when test="$elementName='datum_einde_zwangerschap'">
                            <profile value="http://nictiz.nl/fhir/StructureDefinition/bc-DateEndPregnancy"/>
                        </xsl:when>
                    </xsl:choose>
                </meta>
                <xsl:if test="$dossierId!=''">
                    <extension url="http://nictiz.nl/fhir/StructureDefinition/workflow-episodeOfCare">
                        <valueReference>
                            <reference value="EpisodeOfCare/{$dossierId}"/>
                        </valueReference>
                    </extension>
                </xsl:if>
                <xsl:if test="$pregnancyId!=''">
                    <extension url="http://nictiz.nl/fhir/StructureDefinition/Observation-focus-stu3">
                        <valueReference>
                            <reference value="Condition/{$pregnancyId}"/>
                        </valueReference>
                    </extension>
                </xsl:if>
                <status value="final"/>
                <code>
                    <coding>
                    <xsl:choose>
                        <xsl:when test="$elementName='graviditeit'">
                            <system value="http://loinc.org"/>
                            <code value="11996-6"/>
                            <display value="Gravidity"/>
                        </xsl:when>
                        <xsl:when test="$elementName='pariteit' or $elementName='pariteit_voor_deze_zwangerschap'">
                            <system value="http://loinc.org"/>
                            <code value="11977-6"/>
                            <display value="Parity"/>
                        </xsl:when>
                        <xsl:when test="$elementName='a_terme_datum'">
                            <system value="http://loinc.org"/>
                            <code value="11778-8"/>
                            <display value="Deliv date Clin est"/>
                        </xsl:when>
                        <xsl:when test="$elementName='wijze_einde_zwangerschap'">
                            <system value="urn:oid:2.16.840.1.113883.2.4.4.13"/>
                            <code value="EindeZw"/>
                            <display value="Wijze einde zwangerschap"/>
                        </xsl:when>
                        <xsl:when test="$elementName='datum_einde_zwangerschap'">
                            <system value="http://snomed.info/sct"/>
                            <code value="118185001"/>
                            <display value="Finding related to pregnancy (finding)"/>
                        </xsl:when>
                    </xsl:choose>
                    </coding>
                </code>
                <xsl:for-each select="$adaPatient">
                    <subject>
                        <xsl:apply-templates select="." mode="doPatientReference-2.1"/>
                    </subject>
                </xsl:for-each>
                <xsl:for-each select=".">
                    <xsl:call-template name="any-to-value">
                        <xsl:with-param name="in" select="."/>
                        <xsl:with-param name="elemName">value</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>   
                <!-- obv datatype aanroepen -->
            </Observation>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
