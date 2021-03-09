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

<xsl:stylesheet exclude-result-prefixes="#all"
    xmlns:util="urn:hl7:utilities" 
    xmlns:f="http://hl7.org/fhir" 
    xmlns="http://hl7.org/fhir"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:nf="http://www.nictiz.nl/functions" 
    xmlns:uuid="http://www.uuid.org"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0">
    
    <!-- Can be uncommented for debug purposes. Please comment before committing! -->
    <!-- <xsl:import href="../../../fhir/2_fhir_fhir_include.xsl"/> -->
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>Converts ada Contactpersoon to FHIR resource conforming to profile zib-ContactPerson</xd:desc>
    </xd:doc>
    <xsl:param name="referById" as="xs:boolean" select="false()"/>
    
    <xd:doc>
        <xd:desc>Unwrap contactpersoon_registratie element</xd:desc>
    </xd:doc>
    <xsl:template match="contactpersoon_registratie">
        <xsl:apply-templates select="contactpersoon" mode="zib-ContactPerson"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Mapping of zib-Contactpersoon concept in ADA to FHIR resource.</xd:desc>
        <xd:param name="logicalId">RelatedPerson.id value</xd:param>
        <xd:param name="in">Node to consider in the creation of a RelatedPerson resource</xd:param>
    </xd:doc>
        <xsl:template match="contactpersoon" name="zib-ContactPerson" mode="zib-ContactPerson">
        <xsl:param name="in" select="." as="element()?"/>
        <xsl:param name="logicalId" as="xs:string?"/>
        
          
        <xsl:for-each select="$in">
                <RelatedPerson>
                    <xsl:if test="string-length($logicalId) gt 0">
                        <id value="{$logicalId}"/>
                    </xsl:if>
                    <meta>
                        <profile value="http://nictiz.nl/fhir/StructureDefinition/zib-ContactPerson"/>
                    </meta>
                    
                    <!--
                    <patient>
                        <reference value="{$patientReference}"/>
                        <display value="{$patientName}"/>
                    </patient>
                    -->
                    
                    <!-- role -->
                    <xsl:for-each select="rol[@code]">
                        <relationship>
                            <xsl:call-template name="code-to-CodeableConcept">
                                <xsl:with-param name="in" select="."/>
                            </xsl:call-template>
                        </relationship>
                    </xsl:for-each>
                    
                    <!-- relatie -->
                    <xsl:for-each select="relatie[@code]">
                        <relationship>
                            <xsl:call-template name="code-to-CodeableConcept">
                                <xsl:with-param name="in" select="."/>
                            </xsl:call-template>
                        </relationship>
                    </xsl:for-each>
                    
                    <!-- naamgegevens -->
                    <!--<xsl:call-template name="zib-NameInformation">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </xsl:for-each>-->
                    
                    <!-- contactgegevens -->
                    <!--<xsl:call-template name="zib-ContactInformation">
                    <xsl:with-param name="in" select="contactgegevens"/>
                     </xsl:call-template>-->
                    
                    <!-- address -->
                    <!--<xsl:call-template name="zib-AddressInformation">
                    <xsl:with-param name="in" select="adresgegevens"/>
                    </xsl:call-template>-->

                </RelatedPerson>
        </xsl:for-each>
    </xsl:template>
        
</xsl:stylesheet>
