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

<xsl:stylesheet 
    exclude-result-prefixes="#all" 
    xmlns:f="http://hl7.org/fhir" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    
    <xsl:import href="zib_latest_package.xsl"/>
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Author:</xd:b> Nictiz</xd:p>
            <xd:p><xd:b>Purpose:</xd:b> This XSL was created to facilitate mapping from ADA transaction to HL7 FHIR R4 profiles.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>pass an appropriate macAddress to ensure uniqueness of the UUID. 02-00-00-00-00-00 may not be used in a production situation</xd:desc>
    </xd:doc>
    <xsl:param name="macAddress">02-00-00-00-00-00</xsl:param>
    
    <xd:doc>
        <xd:desc>parameter to determine whether to refer by resource/id should be false when there is no FHIR server available to retrieve the resources </xd:desc>
    </xd:doc>
    <xsl:param name="referById" as="xs:boolean" select="false()"/>
    
    <xd:doc>
        <xd:desc>dateT may be given for relative dates, only applicable for test instances</xd:desc>
    </xd:doc>
    <xsl:param name="dateT" as="xs:date?" select="current-date()"/>
    <!--<xsl:param name="dateT" as="xs:date?"/>-->
    
    <xd:doc>
        <xd:desc>Privacy parameter. Accepts a comma separated list of patient ID root values (normally OIDs). When an ID is encountered with a root value in this list, then this ID will be masked in the output data. This is useful to prevent outputting Dutch bsns (<xd:ref name="oidBurgerservicenummer" type="variable"/>) for example. Default is to include any ID in the output as it occurs in the input.</xd:desc>
    </xd:doc>
    <xsl:param name="mask-ids" as="xs:string?" select="$oidBurgerservicenummer"/>

    <xd:doc>
        <xd:desc>Start conversion.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates select="adaxml/data"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Build a FHIR Bundle of type collection.</xd:desc>
    </xd:doc>
    <xsl:template match="adaxml/data" name="Zib2020Conversion">
        <Bundle xsl:exclude-result-prefixes="#all" xmlns="http://hl7.org/fhir">
            <type value="collection"/>
            <xsl:apply-templates select="*"/>
        </Bundle>
    </xsl:template>

</xsl:stylesheet>
