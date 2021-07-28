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

<xsl:stylesheet exclude-result-prefixes="#all" xmlns="http://hl7.org/fhir"
    xmlns:util="urn:hl7:utilities" xmlns:f="http://hl7.org/fhir"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:nf="http://www.nictiz.nl/functions"
    xmlns:nm="http://www.nictiz.nl/mapping" xmlns:uuid="http://www.uuid.org"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">

    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc scope="stylesheet">
        <xd:desc>Converts ADA zorg_team to FHIR CareTeam conforming to profile
            nl-core-CareTeam</xd:desc>
    </xd:doc>

    <xd:doc>
        <xd:desc>Create a nl-core-CareTeam instance as a CareTeam FHIR instance from ADA zorg_team.</xd:desc>
        <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
        <xd:param name="subject">Optional ADA instance or ADA reference element for the patient.</xd:param>
    </xd:doc>
    <xsl:template match="zorg_team" name="nl-core-CareTeam" mode="nl-core-CareTeam" as="element(f:CareTeam)">
        <xsl:param name="in" as="element()?" select="."/>
        <xsl:param name="subject" as="element()?"/>
        
        <xsl:for-each select="$in">
            <CareTeam>
                <xsl:call-template name="insertLogicalId"/>
                <meta>
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/nl-core-CareTeam"/>
                </meta>
                
                <xsl:for-each select="zorg_team_naam">
                    <name value="{normalize-space(@value)}"/>
                </xsl:for-each>
                <xsl:for-each select="zorg_team_lid/contactpersoon">
                    <participant>
                        <member>
                            <xsl:call-template name="makeReference">
                                <xsl:with-param name="in" select="contactpersoon"/>
                                <xsl:with-param name="profile" select="'nl-core-ContactPerson'"/>
                            </xsl:call-template>
                        </member>
                    </participant>
                </xsl:for-each>
                <xsl:for-each select="zorg_team_lid/patient">
                    <participant>
                        <member>
                            <xsl:call-template name="makeReference">
                                <xsl:with-param name="in" select="patient"/>
                                <xsl:with-param name="profile" select="'nl-core-Patient'"/>
                            </xsl:call-template>
                        </member>
                    </participant>
                </xsl:for-each>
                <xsl:for-each select="zorg_team_lid/zorgverlener">
                    <participant>
                        <member>
                            <xsl:call-template name="makeReference">
                                <xsl:with-param name="in" select="zorgverlener"/>
                                <xsl:with-param name="profile" select="'nl-core-HealthProfessional-PractitionerRole'"/>
                            </xsl:call-template>
                        </member>
                    </participant>
                </xsl:for-each>
                <xsl:for-each select="probleem">
                    <reasonReference>
                        <xsl:call-template name="makeReference">
                            <xsl:with-param name="in" select="probleem"/>
                            <xsl:with-param name="profile" select="'nl-core-Problem'"/>
                        </xsl:call-template>
                    </reasonReference>
                </xsl:for-each>
            </CareTeam>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>