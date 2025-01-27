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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://hl7.org/fhir"
    xmlns:local="urn:fhir:stu3:functions"
    xmlns:nf="http://www.nictiz.nl/functions" 
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!--Uncomment imports for standalone use and testing.-->
    <!--<xsl:import href="../../fhir/fhir_2_ada_fhir_include.xsl"/>-->
    
    <xd:doc>
        <xd:desc>Template to resolve f:supportingInformation to correct Observation resource.</xd:desc>
    </xd:doc>
    <xsl:template match="f:supportingInformation" mode="resolve-bodyWeight">
        <xsl:variable name="reference" select="f:reference/@value"/>
        <xsl:apply-templates select="ancestor::f:Bundle/f:entry[f:fullUrl/@value=$reference]/f:resource/f:Observation[f:meta/f:profile/@value='http://nictiz.nl/fhir/StructureDefinition/zib-BodyWeight']" mode="zib-body-weight-2.1"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Template to convert f:Observation to ADA lichaamsgewicht.</xd:desc>
    </xd:doc>
    <xsl:template match="f:Observation" mode="zib-body-weight-2.1">
        <lichaamsgewicht>
            <!-- lengte_waarde -->
            <xsl:apply-templates select="f:valueQuantity" mode="#current"/>
            <!-- lenge_datum_tijd -->
            <xsl:apply-templates select="f:effectiveDateTime" mode="#current"/>
        </lichaamsgewicht>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Template to convert f:valueQuantity to gewicht_waarde.</xd:desc>
    </xd:doc>
    <xsl:template match="f:valueQuantity" mode="zib-body-weight-2.1">
        <gewicht_waarde value="{f:value/@value}" unit="{f:unit/@value}"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Template to convert f:effectiveDateTime to gewicht_datum_tijd.</xd:desc>
    </xd:doc>
    <xsl:template match="f:effectiveDateTime" mode="zib-body-weight-2.1">
        <gewicht_datum_tijd>
            <xsl:choose>
                <xsl:when test="f:extension/@url=$urlExtHL7DataAbsentReason">
                    <xsl:attribute name="nullFlavor" select="f:extension/f:valueCode/@value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="value">
                        <xsl:call-template name="format2ADADate">
                            <xsl:with-param name="dateTime" select="@value"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:attribute name="datatype">datetime</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </gewicht_datum_tijd>
    </xsl:template>
    
</xsl:stylesheet>