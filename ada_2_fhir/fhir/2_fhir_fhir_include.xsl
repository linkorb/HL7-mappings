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
<!-- Templates of the form 'make<datatype/flavor>Value' correspond to ART-DECOR supported datatypes / HL7 V3 Datatypes R1 -->
<xsl:stylesheet exclude-result-prefixes="#all" xmlns="http://hl7.org/fhir" xmlns:f="http://hl7.org/fhir" xmlns:uuid="http://www.uuid.org" xmlns:local="urn:fhir:stu3:functions" xmlns:nf="http://www.nictiz.nl/functions" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!-- import because we want to be able to override the param for macAddress -->
    <!-- pass an appropriate macAddress to ensure uniqueness of the UUID -->
    <!-- 02-00-00-00-00-00 may not be used in a production situation -->
    <xsl:import href="../../util/uuid.xsl"/>
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all"/>
    <xsl:include href="../../util/constants.xsl"/>
    <xsl:include href="../../util/datetime.xsl"/>
    <!-- pass an appropriate macAddress to ensure uniqueness of the UUID -->
    <!-- 28-F1-0E-48-1D-92 is the mac address of a Nictiz device and may not be used outside of Nictiz -->
    <xsl:param name="macAddress">28-F1-0E-48-1D-92</xsl:param>

    <xd:doc>
        <xd:desc>Transforms ada code element to FHIR code/@value</xd:desc>
        <xd:param name="in">the ada code element, may have any name but should have ada datatype code</xd:param>
        <xd:param name="codeMap">Array of map elements to be used to map input HL7v3 codes to output ADA codes if those differ. See handleCV for more documentation.
            
            <xd:p>Example. if you only want to translate ActStatus completed into a FHIR ObservationStatus final, this would suffice:</xd:p>
            <xd:p><code>&lt;map inCode="completed" inCodeSystem="$codeSystem" code="final"/&gt;</code>
                <div>to produce</div>
                <code>&lt;$elemName value="final"/&gt;</code></xd:p>
        </xd:param>
    </xd:doc>
    <xsl:template name="code-to-code" as="attribute(value)?">
        <xsl:param name="in" as="element()?" select="."/>
        <xsl:param name="codeMap" as="element()*"/>

        <xsl:for-each select="$in">
            <xsl:variable name="theCode">
                <xsl:choose>
                    <xsl:when test="@code">
                        <xsl:value-of select="@code"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@nullFlavor"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="theCodeSystem">
                <xsl:choose>
                    <xsl:when test="@code">
                        <xsl:value-of select="@codeSystem"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$oidHL7NullFlavor"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="out" as="element()">
                <xsl:choose>
                    <xsl:when test="$codeMap[@inCode = $theCode][@inCodeSystem = $theCodeSystem]">
                        <xsl:copy-of select="$codeMap[@inCode = $theCode][@inCodeSystem = $theCodeSystem]"/>
                    </xsl:when>
                    <xsl:when test="$codeMap[@inCode = $theCode][@inCodeSystem = $theCodeSystem]">
                        <xsl:copy-of select="$codeMap[@inCode = $theCode][@inCodeSystem = $theCodeSystem]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:attribute name="value">
                <xsl:value-of select="$out/@code"/>
                <!-- In the case where codeMap if only used to add a @value for ADA, this saves having to repeat the @inCode and @inCodeSystem as @code resp. @codeSystem -->
                <xsl:if test="not($out/@code) and not(empty($theCode))">
                    <xsl:value-of select="$theCode"/>
                </xsl:if>
            </xsl:attribute>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada code element to FHIR CodeableConcept</xd:desc>
        <xd:param name="in">the ada code element, may have any name but should have ada datatype code</xd:param>
        <xd:param name="element-name">Optionally provide the element name, default = coding. In extensions it is valueCoding.</xd:param>
        <xd:param name="user-selected">Optionally provide a user selected boolean.</xd:param>
    </xd:doc>
    <xsl:template name="code-to-CodeableConcept" as="element()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:param name="element-name" as="xs:string?">coding</xsl:param>
        <xsl:param name="user-selected" as="xs:boolean?"/>
        <xsl:choose>
            <xsl:when test="$in[@codeSystem = $oidHL7NullFlavor]">
                <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-nullFlavor">
                    <valueCode value="{$in/@code}"/>
                </extension>
            </xsl:when>
            <xsl:when test="$in[not(@codeSystem = $oidHL7NullFlavor)]">
                <xsl:element name="{$element-name}">
                    <xsl:call-template name="code-to-Coding">
                        <xsl:with-param name="in" select="$in"/>
                        <xsl:with-param name="user-selected" select="$user-selected"/>
                    </xsl:call-template>
                </xsl:element>
                <!--<xsl:if test="$in/@displayName">
                    <text value="{$in/@displayName}"/>
                </xsl:if>-->
                <!-- ADA heeft geen ondersteuning voor vertalingen, dus onderstaande is theoretisch -->
                <xsl:for-each select="$in/translation">
                    <xsl:element name="{$element-name}">
                        <xsl:call-template name="code-to-Coding">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="$in[@originalText]">
            <text value="{$in/@originalText}"/>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada code element to FHIR Coding</xd:desc>
        <xd:param name="in">the ada code element, may have any name but should have ada datatype code</xd:param>
        <xd:param name="user-selected">Optionally provide a user selected boolean.</xd:param>
    </xd:doc>
    <xsl:template name="code-to-Coding" as="element()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:param name="user-selected" as="xs:boolean?"/>
        <xsl:choose>
            <xsl:when test="$in[@codeSystem = $oidHL7NullFlavor]">
                <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-nullFlavor">
                    <valueCode value="{$in/@code}"/>
                </extension>
            </xsl:when>
            <xsl:when test="$in[not(@codeSystem = $oidHL7NullFlavor)]">
                <system value="{local:getUri($in/@codeSystem)}"/>
                <code value="{$in/@code}"/>
                <xsl:if test="$in/@displayName">
                    <display value="{$in/@displayName}"/>
                </xsl:if>
                <xsl:if test="exists($user-selected)">
                    <userSelected value="{$user-selected}"/>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada 'hoeveelheid' element to FHIR Duration</xd:desc>
        <xd:param name="in">the ada 'hoeveelheid' element, may have any name but should have ada datatype hoeveelheid (quantity)</xd:param>
    </xd:doc>
    <xsl:template name="hoeveelheid-to-Duration" as="element()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:variable name="unit-UCUM" select="$in/nf:convertTime_ADA_unit2UCUM_FHIR(@unit)"/>
        <xsl:choose>
            <xsl:when test="$in[@value]">
                <value value="{$in/@value}"/>
                <xsl:if test="$unit-UCUM">
                    <unit value="{$in/@unit}"/>
                    <system value="{local:getUri($oidUCUM)}"/>
                    <code value="{$unit-UCUM}"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$in[@nullFlavor]">
                <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-nullFlavor">
                    <valueCode value="{$in/@nullFlavor}"/>
                </extension>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada numerator and denominator elements to FHIR Ratio</xd:desc>
        <xd:param name="numerator">ada numerator element, may have any name but should have sub elements eenheid with datatype code and waarde with datatype aantal (count)</xd:param>
        <xd:param name="denominator">ada denominator element, may have any name but should have sub elements eenheid with datatype code and waarde with datatype aantal (count)</xd:param>
    </xd:doc>
    <xsl:template name="hoeveelheid-complex-to-Ratio" as="element()*">
        <xsl:param name="numerator" as="element()?"/>
        <xsl:param name="denominator" as="element()?"/>

        <xsl:for-each select="$numerator">
            <numerator>
                <xsl:call-template name="hoeveelheid-complex-to-Quantity">
                    <xsl:with-param name="eenheid" select="./eenheid"/>
                    <xsl:with-param name="waarde" select="./waarde"/>
                </xsl:call-template>
            </numerator>
        </xsl:for-each>
        <xsl:for-each select="$denominator">
            <denominator>
                <xsl:call-template name="hoeveelheid-complex-to-Quantity">
                    <xsl:with-param name="eenheid" select="./eenheid"/>
                    <xsl:with-param name="waarde" select="./waarde"/>
                </xsl:call-template>
            </denominator>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada element of type hoeveelheid to FHIR Quantity</xd:desc>
        <xd:param name="in">ada element may have any name but should have datatype aantal (count)</xd:param>
    </xd:doc>
    <xsl:template name="hoeveelheid-to-Quantity" as="element()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:choose>
            <xsl:when test="$in[not(@value) or @nullFlavor]">
                <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-nullFlavor">
                    <xsl:variable name="valueCode" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$in[@nullFlavor]">
                                <xsl:value-of select="$in/@nullFlavor"/>
                            </xsl:when>
                            <xsl:otherwise>NI</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <valueCode value="{$valueCode}"/>
                </extension>
            </xsl:when>
            <xsl:otherwise>
                <value value="{$in/@value}"/>
                <xsl:for-each select="$in[@unit]">
                    <xsl:for-each select="./@unit">
                        <!-- UCUM -->
                        <unit value="{.}"/>
                        <system value="{local:getUri($oidUCUM)}"/>
                    </xsl:for-each>
                    <code value="{$in/@unit}"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada waarde and eenheid elements to FHIR Quantity</xd:desc>
        <xd:param name="waarde">ada element may have any name but should have datatype aantal (count)</xd:param>
        <xd:param name="eenheid">ada element may have any name but should have datatype code</xd:param>
    </xd:doc>
    <xsl:template name="hoeveelheid-complex-to-Quantity" as="element()*">
        <xsl:param name="waarde" as="element()?"/>
        <xsl:param name="eenheid" as="element()?"/>
        <xsl:choose>
            <xsl:when test="$waarde[not(@value) or @nullFlavor]">
                <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-nullFlavor">
                    <xsl:variable name="valueCode" select="
                            if ($waarde[@nullFlavor]) then
                                ($waarde/@nullFlavor)
                            else
                                ('NI')"/>
                    <valueCode value="{$valueCode}"/>
                </extension>
            </xsl:when>
            <xsl:otherwise>
                <value value="{$waarde/@value}"/>
                <xsl:for-each select="$eenheid[@code]">
                    <xsl:for-each select="./@displayName">
                        <unit value="{.}"/>
                    </xsl:for-each>
                    <xsl:for-each select="./@codeSystem">
                        <system value="{local:getUri(.)}"/>
                    </xsl:for-each>
                    <code value="{$eenheid/@code}"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada element to FHIR Identifier. Masks Burgerservicenummers</xd:desc>
        <xd:param name="in">ada element with datatype identifier</xd:param>
    </xd:doc>
    <xsl:template name="id-to-Identifier" as="element()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:choose>
            <xsl:when test="$in[@nullFlavor]">
                <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-nullFlavor">
                    <valueCode value="{$in/@nullFlavor}"/>
                </extension>
            </xsl:when>
            <xsl:when test="$in[@root = $oidBurgerservicenummer]">
                <extension url="http://hl7.org/fhir/StructureDefinition/data-absent-reason">
                    <valueCode value="masked"/>
                </extension>
                <system value="{local:getUri(@root)}"/>
            </xsl:when>
            <xsl:when test="$in[@value | @root]">
                <xsl:for-each select="$in/@root">
                    <system value="{local:getUri(.)}"/>
                </xsl:for-each>
                <xsl:for-each select="$in/@value">
                    <value value="{.}"/>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada element with zib type interval and only start and end date to FHIR Period</xd:desc>
        <xd:param name="in">ada element with sub ada elements start and end date (both with datatype dateTime)</xd:param>
    </xd:doc>
    <xsl:template name="startend-to-Period" as="element()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:for-each select="$in">
            <xsl:choose>
                <xsl:when test="start_datum_tijd[@nullFlavor]">
                    <start>
                        <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-nullFlavor">
                            <valueCode value="{start_datum_tijd/@nullFlavor}"/>
                        </extension>
                    </start>
                </xsl:when>
                <xsl:when test="start_datum_tijd[@value]">
                    <start value="{nf:add-Amsterdam-timezone(start_datum_tijd/@value)}"/>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="eind_datum_tijd[@nullFlavor]">
                    <end>
                        <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-nullFlavor">
                            <valueCode value="{eind_datum_tijd/@nullFlavor}"/>
                        </extension>
                    </end>
                </xsl:when>
                <xsl:when test="eind_datum_tijd[@value]">
                    <end value="{nf:add-Amsterdam-timezone(eind_datum_tijd/@value)}"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>Transforms ada element to FHIR Range</xd:desc>
        <xd:param name="in">ada element with sub ada elements min and max (both with datatype aantal/count) and a sibling ada element eenheid (datatype code)</xd:param>
    </xd:doc>
    <xsl:template name="minmax-to-Range" as="element()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:choose>
            <xsl:when test="$in/min[@nullFlavor]">
                <low>
                    <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-nullFlavor">
                        <valueCode value="{$in/min/@nullFlavor}"/>
                    </extension>
                </low>
            </xsl:when>
            <xsl:when test="$in/min[@value]">
                <low>
                    <xsl:call-template name="hoeveelheid-complex-to-Quantity">
                        <xsl:with-param name="eenheid" select="$in/../eenheid"/>
                        <xsl:with-param name="waarde" select="$in/min"/>
                    </xsl:call-template>
                </low>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$in/max[@nullFlavor]">
                <high>
                    <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-nullFlavor">
                        <valueCode value="{$in/max/@nullFlavor}"/>
                    </extension>
                </high>
            </xsl:when>
            <xsl:when test="$in/max[@value]">
                <high>
                    <xsl:call-template name="hoeveelheid-complex-to-Quantity">
                        <xsl:with-param name="eenheid" select="$in/../eenheid"/>
                        <xsl:with-param name="waarde" select="$in/max"/>
                    </xsl:call-template>
                </high>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Transforms ada element numerator-aantal, -eenheid and denominator to FHIR Ratio</xd:desc>
        <xd:param name="numerator-aantal">ada element of datatype aantal (count)</xd:param>
        <xd:param name="numerator-eenheid">ada element of datatype code</xd:param>
        <xd:param name="denominator">ada element of datatype hoeveelheid (quantity)</xd:param>
    </xd:doc>
    <xsl:template name="quotient-to-Ratio" as="element()*">
        <xsl:param name="numerator-aantal" as="element()?"/>
        <xsl:param name="numerator-eenheid" as="element()?"/>
        <xsl:param name="denominator" as="element()?"/>
        <xsl:if test="$numerator-aantal | $numerator-eenheid">
            <numerator>
                <xsl:call-template name="hoeveelheid-complex-to-Quantity">
                    <xsl:with-param name="eenheid" select="$numerator-eenheid"/>
                    <xsl:with-param name="waarde" select="$numerator-aantal"/>
                </xsl:call-template>
            </numerator>
        </xsl:if>
        <xsl:for-each select="$denominator">
            <denominator>
                <xsl:call-template name="hoeveelheid-to-Duration">
                    <xsl:with-param name="in" select="."/>
                </xsl:call-template>
            </denominator>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc>Converts an ada time unit to the UCUM unit as used in FHIR</xd:desc>
        <xd:param name="ADAtime">The ada time unit string</xd:param>
    </xd:doc>
    <xsl:function name="nf:convertTime_ADA_unit2UCUM_FHIR" as="xs:string?">
        <xsl:param name="ADAtime" as="xs:string?"/>
        <xsl:if test="$ADAtime">
            <xsl:choose>
                <xsl:when test="$ADAtime = $ada-unit-second">s</xsl:when>
                <xsl:when test="$ADAtime = $ada-unit-minute">min</xsl:when>
                <xsl:when test="$ADAtime = $ada-unit-hour">h</xsl:when>
                <xsl:when test="$ADAtime = $ada-unit-day">d</xsl:when>
                <xsl:when test="$ADAtime = $ada-unit-week">wk</xsl:when>
                <xsl:when test="$ADAtime = $ada-unit-month">mo</xsl:when>
                <xsl:when test="$ADAtime = $ada-unit-year">a</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('onbekende tijdseenheid: ', $ADAtime)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    <xd:doc>
        <xd:desc>Converts an ada unit to the UCUM unit as used in FHIR</xd:desc>
        <xd:param name="ADAunit">The ada unit string</xd:param>
    </xd:doc>
    <xsl:function name="nf:convert_ADA_unit2UCUM_FHIR" as="xs:string?">
        <xsl:param name="ADAunit" as="xs:string?"/>
        <xsl:if test="$ADAunit">
            <xsl:choose>
                <xsl:when test="$ADAunit = $ada-unit-gram">g</xsl:when>
                <xsl:when test="$ADAunit = $ada-unit-kilo">kg</xsl:when>
                <xsl:when test="$ADAunit = $ada-unit-cm">cm</xsl:when>
                <xsl:when test="$ADAunit = $ada-unit-m">m</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('onbekende tijdseenheid: ', $ADAunit)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    <xd:doc>
        <xd:desc>Get the FHIR System URI based on an input OID from ada or HL7. xs:anyURI if possible, urn:oid:.. otherwise</xd:desc>
        <xd:param name="oid">input OID from ada or HL7</xd:param>
    </xd:doc>
    <xsl:function name="local:getUri" as="xs:string?">
        <xsl:param name="oid" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$oidMap[@oid = $oid][@uri]">
                <xsl:value-of select="$oidMap[@oid = $oid]/@uri"/>
            </xsl:when>
            <xsl:when test="matches($oid, $OIDpattern)">
                <xsl:value-of select="concat('urn:oid:', $oid)"/>
            </xsl:when>
            <xsl:when test="matches($oid, $UUIDpattern)">
                <xsl:value-of select="concat('urn:uuid:', $oid)"/>
            </xsl:when>
            <xsl:when test="matches($oid, '^https?:')">
                <xsl:value-of select="$oid"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$oid"/>
                <xsl:message>WARNING: local:getUri() expects an OID, but got "<xsl:value-of select="$oid"/>"</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc>Returns a UUID with urn:uuid: preconcatenated</xd:desc>
        <xd:param name="in">xml element to be used to generate uuid</xd:param>
    </xd:doc>
    <xsl:function name="nf:get-fhir-uuid" as="xs:string">
        <xsl:param name="in" as="element()"/>
        <xsl:value-of select="concat('urn:uuid:', uuid:get-uuid($in))"/>
    </xsl:function>
    <xd:doc>
        <xd:desc>Returns a UUID</xd:desc>
        <xd:param name="in">xml element to be used to generate uuid</xd:param>
    </xd:doc>
    <xsl:function name="nf:get-uuid" as="xs:string">
        <xsl:param name="in" as="element()"/>
        <xsl:value-of select="uuid:get-uuid($in)"/>
    </xsl:function>
    <xd:doc>
        <xd:desc>If possible generates an uri based on oid or uuid from input. If not possible generates an uri based on gerenated uuid making use of input element</xd:desc>
        <xd:param name="ada-identificatie">input element for which uri is needed</xd:param>
    </xd:doc>
    <xsl:function name="nf:getUriFromAdaId" as="xs:string">
        <xsl:param name="ada-identificatie" as="element()"/>
        
        <xsl:choose>
            <!-- root = oid and extension = numeric -->
            <xsl:when test="$ada-identificatie[matches(@root, $OIDpattern)][matches(@extension, '^\d+$')]">
                <xsl:variable name="ii" select="$ada-identificatie[matches(@root, $OIDpattern)][matches(@extension, '^\d+$')][1]"/>
                <xsl:value-of select="concat('urn:oid:', $ii/string-join((@root, replace(@extension, '^0+', '')[not(. = '')]),'.'))"/>
            </xsl:when>
            <!-- root = oid and no extension -->
            <xsl:when test="$ada-identificatie[matches(@root, $OIDpattern)][not(@extension)]">
                <xsl:variable name="ii" select="$ada-identificatie[matches(@root, $OIDpattern)][not(@extension)][1]"/>
                <xsl:value-of select="concat('urn:oid:', $ii/string-join((@root, replace(@extension, '^0+', '')[not(. = '')]),'.'))"/>
            </xsl:when>
            <!-- root = 'not important' and extension = uuid -->
            <xsl:when test="$ada-identificatie[matches(@extension, $UUIDpattern)]">
                <xsl:variable name="ii" select="$ada-identificatie[matches(@extension, $UUIDpattern)][1]"/>
                <xsl:value-of select="concat('urn:uuid:', $ii/@extension)"/>
            </xsl:when>
            <!-- root = uuid and extension = 'not important' -->
            <xsl:when test="$ada-identificatie[matches(@root, $UUIDpattern)]">
                <xsl:variable name="ii" select="$ada-identificatie[matches(@root, $UUIDpattern)][1]"/>
                <xsl:value-of select="concat('urn:uuid:', $ii/@root)"/>
            </xsl:when>
            <!-- give up and do new uuid -->
            <xsl:otherwise>
                <xsl:value-of select="nf:get-fhir-uuid($ada-identificatie[1])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="in"/>
    </xd:doc>
    <xsl:function name="nf:removeSpecialCharacters" as="xs:string?">
        <xsl:param name="in" as="xs:string?"/>
        <xsl:value-of select="replace(translate($in, '_.', '--'), '[^a-zA-Z0-9-]', '')"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>Generates FHIR uri based on input ada code element. OID if possible, otherwise generates uri based on generated uuid using input element.</xd:desc>
        <xd:param name="ada-code">Input element for which uri is needed</xd:param>
    </xd:doc>
    <xsl:function name="nf:getUriFromAdaCode" as="xs:string?">
        <xsl:param name="ada-code" as="element()?"/>
        <xsl:choose>
            <xsl:when test="$ada-code[matches(@codeSystem, $OIDpattern)][matches(@code, '^\d+$')]">
                <!-- No leading zeroes -->
                <xsl:value-of select="concat('urn:oid:', $ada-code/string-join((@codeSystem, replace(@code, '^0+', '')), '.'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="nf:get-fhir-uuid($ada-code)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc>Try to interpret the value of complex type in ADA as a quantity string with value and unit</xd:desc>
        <xd:param name="value_string">The input text (like 12 mmol/l)</xd:param>
        <xd:return>
            <xd:p>A collection of 'value' and possibly 'unit' tags if the string could be interpreted as a quantity string, or an empty collection.</xd:p>
            <xd:p><xd:b>NOTE: </xd:b>even if the string is interpreted as a quantity, only the textual 'unit' tag is included in the result, not a formal system/code pair.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:function name="nf:try-complex-as-Quantity" as="element()*">
        <xsl:param name="value_string" as="xs:string?"/>
        <xsl:analyze-string select="$value_string" regex="^\s*([0-9\.,]+)\s*([^0-9]*)\s*$">
            <xsl:matching-substring>
                <value value="{regex-group(1)}"/>
                <xsl:if test="regex-group(2)">
                    <unit value="{regex-group(2)}"/>
                </xsl:if>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xd:doc>
        <xd:desc>Formats ada or HL7 dateTime to FHIR date(Time) based on input precision</xd:desc>
        <xd:param name="dateTime">Input ada or HL7 date(Time)</xd:param>
        <xd:param name="precision">Determines the precision of the output. Precision of minutes outputs seconds as '00'</xd:param>
    </xd:doc>
    <xsl:template name="format2FHIRDate">
        <xsl:param name="dateTime"/>
        <!-- precision determines the picture of the date format, currently only use case for day, minute or second. Seconds is the default. -->
        <xsl:param name="precision">second</xsl:param>
        <xsl:variable name="picture" as="xs:string?">
            <xsl:choose>
                <xsl:when test="upper-case($precision) = ('DAY', 'DAG', 'DAYS', 'DAGEN', 'D')">[Y0001]-[M01]-[D01]</xsl:when>
                <xsl:when test="upper-case($precision) = ('MINUTE', 'MINUUT', 'MINUTES', 'MINUTEN', 'MIN', 'M')">[Y0001]-[M01]-[D01]T[H01]:[m01]:00</xsl:when>
                <xsl:otherwise>[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="normalize-space($dateTime) castable as xs:dateTime">
                <xsl:value-of select="format-dateTime(xs:dateTime($dateTime), $picture)"/>
            </xsl:when>
            <xsl:when test="normalize-space($dateTime) castable as xs:date">
                <xsl:value-of select="format-date(xs:date($dateTime), '[Y0001]-[M01]-[D01]')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="newDateTime" select="replace(concat(normalize-space($dateTime), '00000000000000'), '^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})', '$1-$2-$3T$4:$5:$6')"/>
                <xsl:variable name="newDate" select="replace(normalize-space($dateTime), '^(\d{4})(\d{2})(\d{2})', '$1-$2-$3')"/>
                <xsl:choose>
                    <xsl:when test="$newDateTime castable as xs:dateTime">
                        <xsl:value-of select="format-dateTime(xs:dateTime($newDateTime), $picture)"/>
                    </xsl:when>
                    <xsl:when test="$newDate castable as xs:date">
                        <xsl:value-of select="format-date(xs:date($newDateTime), $picture)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$dateTime"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
