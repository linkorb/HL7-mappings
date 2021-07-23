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
    xmlns="http://hl7.org/fhir"
    xmlns:util="urn:hl7:utilities" 
    xmlns:f="http://hl7.org/fhir" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:nf="http://www.nictiz.nl/functions"
    xmlns:nm="http://www.nictiz.nl/mappings"
    xmlns:uuid="http://www.uuid.org"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>Converts ADA [...] to FHIR [...] conforming to profile [...]</xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>Create a nl-core-[zib name] instance as a [resource name] FHIR instance from ADA [ADA instance name].</xd:desc>
        <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
    </xd:doc>
    <xsl:template name="nl-core-InstructionsForUse" mode="nl-core-InstructionsForUse" match="gebruiks_instructie" as="element(f:*)+">
        <xsl:param name="in" as="element()?" select="."/>
        
        <xsl:for-each select="$in">
            <xsl:for-each select="doseerinstructie">
                <xsl:call-template name="nl-core-InstructionsForUse.DosageInstruction">
                    <xsl:with-param name="additionalInstruction" select="../aanvullende_instructie"/>
                    <xsl:with-param name="route" select="../toedieningsweg"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="nl-core-InstructionsForUse.DosageInstruction" mode="nl-core-InstructionsForUse.DosageInstruction" match="doseerinstructie" as="element(f:*)+">
        <xsl:param name="in" as="element()?" select="."/>
        <xsl:param name="additionalInstruction" as="element()?"/>
        <xsl:param name="route" as="element()?"/>
        
        <xsl:for-each select="$in">
            <xsl:variable name="sequence">
                <xsl:for-each select="volgnummer">
                    <sequence value="./@value"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="boundsDuration">
                <xsl:for-each select="doseerduur">
                    <boundsDuration>
                        <xsl:call-template name="hoeveelheid-to-Duration"/>
                    </boundsDuration>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:choose>
                <xsl:when test="dosering">
                    <xsl:for-each select="dosering">
                        <xsl:copy-of select="$sequence"/>
                        <xsl:for-each select="$additionalInstruction">
                            <additionalInstruction>
                                <text>
                                    <xsl:attribute name="value" select="./@value"/>
                                </text>
                            </additionalInstruction>
                            <!-- TODO: MP Additional instructions -->
                        </xsl:for-each>
                        <xsl:variable name="timingRepeat">
                            <xsl:call-template name="_buildTimingRepeat"/>
                        </xsl:variable>
                        <xsl:if test="$timingRepeat">
                            <timing>
                                <repeat>
                                    <xsl:copy-of select="$timing"/>
                                </repeat>
                            </timing>
                        </xsl:if>
                        
                        <xsl:for-each select="zonodig/criterium">
                            <asNeededCodeableConcept>
                                <xsl:call-template name="code-to-CodeableConcept"/>
                            </asNeededCodeableConcept>
                        </xsl:for-each>
                        
                        <xsl:for-each select="$route">
                            <route>
                                <xsl:call-template name="code-to-CodeableConcept"/>
                            </route>
                        </xsl:for-each>
                        
                        <xsl:variable name="doseAndRate">
                            <xsl:for-each select="keerdosis">
                                <xsl:if test="(minimum_waarde, maximum_waarde)[@value]">
                                    <doseRange>
                                        <low value="${minimum_waarde/@value}"/>
                                        <high value="${maximum_waarde/@value}"/>
                                    </doseRange>
                                </xsl:if>
                                <xsl:if test="nominale_waarde[@value]">
                                    <doseQuantity>
                                        <xsl:call-template name="hoeveelheid-to-Quantity"/>
                                    </doseQuantity>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each select="toediensnelheid">
                                <xsl:if test="(minimum_waarde, maximum_waarde)[@value]">
                                    <rateRange>
                                        <low value="${minimum_waarde/@value}"/>
                                        <high value="${maximum_waarde/@value}"/>
                                    </rateRange>
                                </xsl:if>
                                <xsl:if test="nominale_waarde[@value]">
                                    <rateQuantity>
                                        <xsl:call-template name="hoeveelheid-to-Quantity"/>
                                    </rateQuantity>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:if test="$doseAndRate">
                            <doseAndRate>
                                <xsl:copy-of select="$doseAndRate"/>
                            </doseAndRate>
                        </xsl:if>
                        
                        <xsl:for-each select="maximale_dosering">
                            <maxDosePerPeriod>
                                <xsl:call-template name="hoeveelheid-complex-to-Ratio">
                                    <xsl:with-param name="numerator" select="./@value"/>
                                    <xsl:with-param name="denominator" select="./@unit"/>
                                </xsl:call-template>
                            </maxDosePerPeriod>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:when>
                
                <!-- Fallback for when no dosering is defined but a volgnummer or doseerduur is present -->
                <xsl:when test="$sequence or $boundsDuration">
                    <xsl:if test="$sequence">
                        <xsl:copy-of select="$sequence"/>
                    </xsl:if>
                    <xsl:if test="$boundsDuration">
                        <timing>
                            <repeat>
                                <xsl:copy-of select="$boundsDuration"/>
                            </repeat>
                        </timing>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
                            
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="_buildTimingRepeat">
        <xsl:if test="dosering/toedieningsschema/interval[@value]">
            <extension url="http://hl7.org/fhir/StructureDefinition/timing-exact">
                <valueBoolean value="true"/>
            </extension>
        </xsl:if>
        <xsl:copy-of select="$boundsDuration"/>
        
        <xsl:if test="not(frequentie//*[@unit != ''])">
            <xsl:if test="frequentie/nominale_waarde[@value]">
                <count value="${frequentie/nominale_waarde/@value}"/>
            </xsl:if>
            <xsl:if test="frequentie/minimum_waarde[@value]">
                <count value="${frequentie/minimum_waarde/@value}"/>
            </xsl:if>
            <xsl:if test="frequentie/maximum_waarde[@value]">
                <countMax value="${frequentie/maximum_waarde/@value}"/>
            </xsl:if>
        </xsl:if>
        <xsl:if test="toedieningsduur/tijds_duur[@value]">
            <duration value="${toedieningsduur/tijds_duur/@value}"/>
            <xsl:if test="toedingsduur/tijds_duur[@unit]">
                <durationUnit>
                    <unit value="{./@unit}"/>
                    <system value="{local:getUri($oidUCUM)}"/>
                    <code value="${nf:convert_ADA_unit2UCUM_FHIR(./@unit)}"/>
                </durationUnit>
                <!-- start_datum_tijd and eind_datum_tijd are not mapped to the profile -->
            </xsl:if>
        </xsl:if>
        <xsl:if test="frequentie//*[@unit != '']">
            <xsl:if test="frequentie/nominale_waarde[@value]">
                <frequency value="${frequentie/nominale_waarde/@value}"/>
            </xsl:if>
            <xsl:if test="frequentie/minimum_waarde[@value]">
                <frequency value="${frequentie/minimum_waarde/@value}"/>
            </xsl:if>
            <xsl:if test="frequentie/maximum_waarde[@value]">
                <frequencyMax value="${frequentie/maximum_waarde/@value}"/>
            </xsl:if>
            <period value="1"/>
            <periodUnit>
                <unit value="{./@unit}"/>
                <system value="{local:getUri($oidUCUM)}"/>
                <code value="${nf:convert_ADA_unit2UCUM_FHIR(frequentie/*[@unit]/@unit[1])}"/>
            </periodUnit>
        </xsl:if>
        <xsl:if test="interval[@value and @unit]">
            <frequency value="1"/>
            <period value="${interval/@value}"/>
            <periodUnit>
                <unit value="{./@unit}"/>
                <system value="{local:getUri($oidUCUM)}"/>
                <code value="${nf:convert_ADA_unit2UCUM_FHIR(interval/@unit)}"/>
            </periodUnit>
        </xsl:if>
        <xsl:for-each select="weekdag">
            <dayOfWeek>
                <xsl:call-template name="code-to-code">
                    <xsl:with-param name="codeMap">
                        <map inCode="307145004" inCodeSystem="$oidSNOMEDCT" code="mon"/>;
                        <map inCode="307147007" inCodeSystem="$oidSNOMEDCT" code="tue"/>;
                        <map inCode="307148002" inCodeSystem="$oidSNOMEDCT" code="wed"/>;
                        <map inCode="307149005" inCodeSystem="$oidSNOMEDCT" code="thu"/>;
                        <map inCode="307150005" inCodeSystem="$oidSNOMEDCT" code="fri"/>;
                        <map inCode="307151009" inCodeSystem="$oidSNOMEDCT" code="sat"/>;
                        <map inCode="307146003" inCodeSystem="$oidSNOMEDCT" code="sun"/>;
                    </xsl:with-param>
                </xsl:call-template>
            </dayOfWeek>
        </xsl:for-each>
        <xsl:for-each select="toedientijd">
            <timeOfDay>
                <xsl:attribute name="value">
                    <xsl:call-template name="format2FHIRDate">
                        <xsl:with-param name="dateTime" select="."/>
                    </xsl:call-template>
                </xsl:attribute>
            </timeOfDay>
        </xsl:for-each>
        <xsl:for-each select="dagdeel">
            <when>
                <xsl:call-template name="code-to-code">
                    <xsl:with-param name="codeMap">
                        <map inCode="73775008"  inCodeSystem="$oidSNOMEDCT" code="MORN"/>;
                        <map inCode="255213009" inCodeSystem="$oidSNOMEDCT" code="AFT"/>;
                        <map inCode="3157002"   inCodeSystem="$oidSNOMEDCT" code="EVE"/>;
                        <map inCode="2546009"   inCodeSystem="$oidSNOMEDCT" code="NIGHT"/>;
                    </xsl:with-param>
                </xsl:call-template>
            </when>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Template to generate a unique id to identify this instance.</xd:desc>
    </xd:doc>
    <xsl:template match="[ada_element]" mode="_generateId">
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Template to generate a display that can be shown when referencing this instance.</xd:desc>
    </xd:doc>
    <xsl:template match="[ada_element]" mode="_generateDisplay">
    </xsl:template>
</xsl:stylesheet>