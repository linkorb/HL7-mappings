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

<xsl:stylesheet exclude-result-prefixes="#all" xmlns="http://hl7.org/fhir" xmlns:f="http://hl7.org/fhir" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:local="urn:fhir:stu3:functions" xmlns:nf="http://www.nictiz.nl/functions" xmlns:nff="http://www.nictiz.nl/fhir-functions" xmlns:uuid="http://www.uuid.org" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--<xsl:import href="../../../zibs2017/payload/all-zibs.xsl"/>
    <xsl:import href="gebz_mappings.xsl"/>-->

    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xd:doc>
        <xd:desc>Mapping of ADA geboortezorg zwangerschap to FHIR Condition <xd:a href="https://simplifier.net/resolve/?target=simplifier&amp;canonical=http://nictiz.nl/fhir/StructureDefinition/zib-LaboratoryTestResult-Observation">zib-LaboratoryTestResult-Observation</xd:a>.</xd:desc>
        <xd:param name="logicalId">Optional FHIR logical id for the record.</xd:param>
        <xd:param name="in">Node to consider in the creation of a Condition resource</xd:param>
        <xd:param name="adaPatient">Required. ADA patient concept to build a reference to from this resource</xd:param>
    </xd:doc>
    <xsl:template name="zib-pregnancy" mode="doPregnancyInstance" match="zwangerschap" as="element()">
        <xsl:param name="in" select="." as="element()?"/>
        <xsl:param name="logicalId" as="xs:string?"/>
        <xsl:param name="adaPatient"/>
        <xsl:param name="dossierId"/>
        <xsl:param name="pregnancyId"/>
        
        <xsl:variable name="parentElemName" select="parent::node()/name(.)"/>
        
        <xsl:for-each select="$in">            
            <Condition>
                <xsl:if test="$referById">
                    <id value="{$logicalId}"/>
                </xsl:if>
                <meta>
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/zib-Pregnancy"/>
                </meta>
                <xsl:if test="$parentElemName='prio1_vorig'">
                    <clinicalStatus value="inactive"/>
                </xsl:if>
                <xsl:if test="$parentElemName='prio1_huidig'">
                    <clinicalStatus value="active"/>
                </xsl:if>
                <code>
                    <coding>
                        <system value="http://snomed.info/sct" />
                        <code value="364320009" />
                        <display value="Pregnancy observable (observable entity)"/>
                    </coding>
                </code>
                <subject>
                    <xsl:for-each select="$adaPatient">
                        <xsl:apply-templates select="." mode="doPatientReference-2.1"/>
                    </xsl:for-each>
                </subject>
                <xsl:if test="$dossierId!=''">
                    <context>
                        <reference value="EpisodeOfCare/{$dossierId}"/>
                    </context>
                </xsl:if>             
            </Condition>
        </xsl:for-each>
    </xsl:template>
       
</xsl:stylesheet>
