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
<xsl:stylesheet exclude-result-prefixes="#all" xmlns:nf="http://www.nictiz.nl/functions" xmlns:f="http://hl7.org/fhir" xmlns:util="urn:hl7:utilities" xmlns="http://hl7.org/fhir" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:import href="../../2_fhir_cio_1.0.0-2019.01-include.xsl"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Author:</xd:b> Nictiz</xd:p>
            <xd:p><xd:b>Purpose:</xd:b> This XSL was created to facilitate mapping from ADA transaction, to HL7 FHIR STU3 profiles.</xd:p>
            <xd:p>
                <xd:b>History:</xd:b>
                <xd:ul>
                    <xd:li>2019-11-29 version 0.1 <xd:ul><xd:li>Initial version</xd:li></xd:ul></xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    <!-- If the desired output is to be a Bundle, then a self link string of type url is required. 
         See: https://www.hl7.org/fhir/stu3/search.html#conformance -->
    <xsl:param name="bundleSelfLink" as="xs:string?"/>
    <xd:doc>
        <xd:desc>dateT may be given for relative dates, only applicable for test instances</xd:desc>
    </xd:doc>
    <xsl:param name="dateT" as="xs:date?" select="current-date()"/>
    <!--<xsl:param name="dateT" as="xs:date?"/>-->
    <xd:doc>
        <xd:desc>pass an appropriate macAddress to ensure uniqueness of the UUID. 02-00-00-00-00-00 may not be used in a production situation</xd:desc>
    </xd:doc>
    <xsl:param name="macAddress">02-00-00-00-00-00</xsl:param>
    <xd:doc>
        <xd:desc>Privacy parameter. Accepts a comma separated list of patient ID root values (normally OIDs). When an ID is encountered with a root value in this list, then this ID will be masked in the output data. This is useful to prevent outputting Dutch bsns (<xd:ref name="oidBurgerservicenummer" type="variable"/>) for example. Default is to include any ID in the output as it occurs in the input.</xd:desc>
    </xd:doc>
    <xsl:param name="mask-ids" as="xs:string?" select="$oidBurgerservicenummer"/>
    <xd:doc>
        <xd:desc>parameter to determine whether to refer by resource/id should be false when there is no FHIR server available to retrieve the resources </xd:desc>
    </xd:doc>
    <xsl:param name="referById" as="xs:boolean" select="false()"/>
  
    <xsl:variable name="commonEntries" as="element(f:entry)*">
        <xsl:copy-of select="$patients/f:entry, $practitioners/f:entry, $organizations/f:entry, $practitionerRoles/f:entry, $relatedPersons/f:entry"/>
    </xsl:variable>

    <xd:doc>
        <xd:desc>Start conversion. Handle interaction specific stuff for "beschikbaarstellen allergieintolerantiegegevens".</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates select="adaxml/data/beschikbaarstellen_allergie_intolerantie"/>
    </xsl:template>
    <xd:doc>
        <xd:desc>Build a FHIR Bundle of type searchset.</xd:desc>
    </xd:doc>
    <xsl:template name="AllIntConversion_10" match="beschikbaarstellen_allergie_intolerantie">
        <xsl:processing-instruction name="xml-model">href="http://hl7.org/fhir/STU3/bundle.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        <Bundle xsl:exclude-result-prefixes="#all" xmlns="http://hl7.org/fhir" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://hl7.org/fhir http://hl7.org/fhir/STU3/bundle.xsd">
            <id value="{nf:get-uuid(*[1])}"/>
            <type value="searchset"/>
            <total value="{count($bouwstenen-all-int-gegevens)}"/>
            <xsl:choose>
                <xsl:when test="$bundleSelfLink[not(. = '')]">
                    <link>
                        <relation value="self"/>
                        <url value="{$bundleSelfLink}"/>
                    </link>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="util:logMessage">
                        <xsl:with-param name="level" select="$logWARN"/>
                        <xsl:with-param name="msg">Parameter bundleSelfLink is empty, but server SHALL return the parameters that were actually used to process the search.</xsl:with-param>
                        <xsl:with-param name="terminate" select="false()"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="$bouwstenen-all-int-gegevens" mode="ResultOutput"/>
            <!-- common entries (patient, practitioners, organizations, practitionerroles, relatedpersons -->
            <xsl:apply-templates select="$commonEntries" mode="ResultOutput"/>
        </Bundle>
    </xsl:template>

    <xd:doc>
        <xd:desc>Decision to output the fhirLogicalId based on $referById</xd:desc>
    </xd:doc>
    <xsl:template name="fhirLogicalId" match="f:id" mode="ResultOutput">
        <xsl:if test="$referById">
            <xsl:copy>
                <xsl:apply-templates select="@* | node()" mode="ResultOutput"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
