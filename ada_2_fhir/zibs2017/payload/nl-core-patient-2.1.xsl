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

<xsl:stylesheet exclude-result-prefixes="#all" xmlns="http://hl7.org/fhir" xmlns:util="urn:hl7:utilities" xmlns:f="http://hl7.org/fhir" xmlns:local="urn:fhir:stu3:functions" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:nf="http://www.nictiz.nl/functions" xmlns:uuid="http://www.uuid.org" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--<xsl:import href="../../fhir/2_fhir_fhir_include.xsl"/>
    <xsl:import href="_zib2017.xsl"/>
    <xsl:import href="nl-core-address-2.0.xsl"/>
    <!-\- beware: choose the appropriate contactpoint xsl -\->
    <!-\- 2019.01 -\->
<!-\-    <xsl:import href="nl-core-contactpoint-1.0.xsl"/>-\->
    <!-\- 2020.01 -\->    
    <xsl:import href="nl-core-contactpoint-2.0.xsl"/>
    <xsl:import href="nl-core-humanname-2.0.xsl"/>
    <xsl:import href="ext-code-specification-1.0.xsl"/>-->

    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xd:doc>
        <xd:desc>Converts ada patient to FHIR resource conforming to profile nl-core-patient-2.1</xd:desc>
        <xd:param name="referById">Optional parameter to indicate whether to output resource logical id. Defaults to false.</xd:param>
        <xd:param name="patientTokensXml">Optional parameter containing XML document based on QualificationTokens.json as used on Github / Touchstone</xd:param>
    </xd:doc>
    <xsl:param name="referById" as="xs:boolean" select="false()"/>
    <xsl:param name="patientTokensXml" select="document('../../fhir/QualificationTokens.xml')"/>

    <xd:doc>
        <xd:desc>Returns contents of Reference datatype element</xd:desc>
    </xd:doc>
    <xsl:template name="patientReference" match="patient" mode="doPatientReference-2.1" as="element()*">
        <xsl:variable name="theIdentifier" select="(identificatienummer | patient_identificatie_nummer | patient_identification_number)[normalize-space(@value | @nullFlavor)]"/>
        <xsl:variable name="theGroupKey" select="nf:getGroupingKeyPatient(.)"/>
        <xsl:variable name="theGroupElement" select="$patients[group-key = $theGroupKey]" as="element()?"/>
        <xsl:choose>
            <xsl:when test="$theGroupElement">
                <xsl:variable name="fullUrl" select="nf:getFullUrlOrId(($theGroupElement/f:entry)[1])"/>
                <reference value="{$fullUrl}"/>
            </xsl:when>
            <xsl:when test="$theIdentifier">
                <identifier>
                    <xsl:call-template name="id-to-Identifier">
                        <xsl:with-param name="in" select="($theIdentifier[not(@root = $mask-ids-var)], $theIdentifier)[1]"/>
                    </xsl:call-template>
                </identifier>
            </xsl:when>
        </xsl:choose>

        <xsl:if test="string-length($theGroupElement/reference-display) gt 0">
            <display value="{$theGroupElement/reference-display}"/>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:desc>Produces a FHIR entry element with a Patient resource</xd:desc>
        <xd:param name="uuid">If true generate uuid from scratch. Generating a UUID from scratch limits reproduction of the same output as the UUIDs will be different every time.</xd:param>
        <xd:param name="entryFullUrl">Optional. Value for the entry.fullUrl</xd:param>
        <xd:param name="fhirResourceId">Optional. Value for the entry.resource.Patient.id</xd:param>
        <xd:param name="searchMode">Optional. Value for entry.search.mode. Default: include</xd:param>
    </xd:doc>
    <xsl:template name="patientEntry" match="patient" mode="doPatientEntry-2.1" as="element(f:entry)">
        <xsl:param name="uuid" select="true()" as="xs:boolean"/>
        <xsl:param name="entryFullUrl" select="nf:get-fhir-uuid(.)"/>
        <xsl:param name="fhirResourceId">
            <xsl:if test="$referById">
                <xsl:choose>
                    <xsl:when test="not($uuid) and string-length(nf:get-resourceid-from-token(.)) gt 0">
                        <xsl:value-of select="nf:get-resourceid-from-token(.)"/>
                    </xsl:when>
                    <xsl:when test="not($uuid) and (naamgegevens[1]//*[not(name() = 'naamgebruik')]/@value | name_information[1]//*[not(name() = 'name_usage')]/@value)">
                        <xsl:value-of select="upper-case(nf:removeSpecialCharacters(normalize-space(string-join(naamgegevens[1]//*[not(name() = 'naamgebruik')]/@value | name_information[1]//*[not(name() = 'name_usage')]/@value, ' '))))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="nf:removeSpecialCharacters(replace($entryFullUrl, 'urn:[^i]*id:', ''))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:param>
        <xsl:param name="searchMode">include</xsl:param>
        <entry>
            <fullUrl value="{$entryFullUrl}"/>
            <resource>
                <xsl:call-template name="nl-core-patient-2.1">
                    <xsl:with-param name="in" select="."/>
                    <xsl:with-param name="logicalId" select="$fhirResourceId"/>
                </xsl:call-template>
            </resource>
            <xsl:if test="string-length($searchMode) gt 0">
                <search>
                    <mode value="{$searchMode}"/>
                </search>
            </xsl:if>
        </entry>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
        <xd:param name="logicalId">Patient.id value</xd:param>
        <xd:param name="in">Node to consider in the creation of a Patient resource</xd:param>
        <xd:param name="generalPractitionerRef">Optional. Reference datatype elements for the general practitioner of this Patient</xd:param>
        <xd:param name="managingOrganizationRef">Optional. Reference datatype elements for the amanging organization of this Patient record</xd:param>
    </xd:doc>
    <xsl:template name="nl-core-patient-2.1" match="patient" mode="doPatientResource-2.1" as="element(f:Patient)?">
        <xsl:param name="in" select="." as="element()?"/>
        <xsl:param name="logicalId" as="xs:string?"/>
        <xsl:param name="generalPractitionerRef" as="element()*"/>
        <xsl:param name="managingOrganizationRef" as="element()*"/>

        <xsl:for-each select="$in">
            <xsl:variable name="resource">
                <xsl:variable name="profileValue">
                    <xsl:choose>
                        <xsl:when test="parent::beschikbaarstellen_verstrekkingenvertaling">http://nictiz.nl/fhir/StructureDefinition/mp612-DispenseToFHIRConversion-Patient</xsl:when>
                        <xsl:otherwise>http://fhir.nl/fhir/StructureDefinition/nl-core-patient</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <Patient>
                    <xsl:if test="string-length($logicalId) gt 0">
                        <!-- do not add profile-id to patient id, we need the patient id to match the qualification token stuff -->
                        <id value="{$logicalId}"/>
                    </xsl:if>
                    <meta>
                        <profile value="{$profileValue}"/>
                    </meta>
                    <!-- patient_identificatienummer  -->
                    <xsl:for-each select="(identificatienummer | patient_identificatienummer | patient_identification_number)[@value | @nullFlavor]">
                        <identifier>
                            <xsl:call-template name="id-to-Identifier">
                                <xsl:with-param name="in" select="."/>
                            </xsl:call-template>
                        </identifier>
                    </xsl:for-each>
                    <!-- naamgegevens -->
                    <xsl:call-template name="nl-core-humanname-2.0">
                        <!-- in some datasets the name_information is unfortunately unnecessary nested in an extra group, hence the extra predicate -->
                        <xsl:with-param name="in" select=".//(naamgegevens[not(naamgegevens)] | name_information[not(name_information)])" as="element()*"/>
                    </xsl:call-template>
                    <!-- contactgegevens -->
                    <xsl:call-template name="nl-core-contactpoint-1.0">
                        <xsl:with-param name="in" select="contactgegevens | contact_information" as="element()*"/>
                    </xsl:call-template>
                    <!-- geslacht -->
                    <xsl:for-each select="(geslacht | gender)[@value | @code]">
                        <gender>
                            <xsl:call-template name="code-to-code">
                                <xsl:with-param name="in" select="."/>
                                <xsl:with-param name="codeMap" as="element()*">
                                    <xsl:for-each select="$genderMap">
                                        <map>
                                            <xsl:attribute name="inCode" select="@hl7Code"/>
                                            <xsl:attribute name="inCodeSystem" select="@hl7CodeSystem"/>
                                            <xsl:attribute name="code" select="@fhirCode"/>
                                        </map>
                                    </xsl:for-each>
                                </xsl:with-param>
                            </xsl:call-template>
                            <!-- MM-1036, add ext-code-specification-1.0 -->
                            <xsl:choose>
                                <!-- MM-1781, FHIR requires display, but display not always present in input ada -->
                                <xsl:when test="not(@displayName)">
                                    <xsl:variable name="geslachtIncludingDisplay" as="element()">
                                        <xsl:copy>
                                            <xsl:copy-of select="@*"/>
                                            <xsl:attribute name="displayName" select="$genderMap[@hl7Code = current()/@code][@hl7CodeSystem = current()/@codeSystem]/@displayName"/>
                                        </xsl:copy>
                                    </xsl:variable>
                                    <xsl:for-each select="$geslachtIncludingDisplay">
                                        <xsl:call-template name="ext-code-specification-1.0"/>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="ext-code-specification-1.0"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </gender>
                    </xsl:for-each>
                    <!-- geboortedatum -->
                    <xsl:for-each select="(geboortedatum | date_of_birth)[@value]">
                        <birthDate value="{./@value}">
                            <xsl:attribute name="value">
                                <xsl:call-template name="format2FHIRDate">
                                    <xsl:with-param name="dateTime" select="xs:string(@value)"/>
                                    <xsl:with-param name="precision" select="'DAY'"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </birthDate>
                    </xsl:for-each>
                    <!-- deceased -->
                    <xsl:choose>
                        <xsl:when test="datum_overlijden | date_of_death">
                            <deceasedDateTime>
                                <xsl:call-template name="date-to-datetime">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </deceasedDateTime>
                        </xsl:when>
                        <xsl:when test="overlijdens_indicator | death_indicator">
                            <deceasedBoolean>
                                <xsl:call-template name="boolean-to-boolean">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </deceasedBoolean>
                        </xsl:when>
                    </xsl:choose>
                    <!-- address -->
                    <xsl:call-template name="nl-core-address-2.0">
                        <xsl:with-param name="in" select="adresgegevens | address_information" as="element()*"/>
                    </xsl:call-template>
                    <!-- maritalStatus -->

                    <!-- multipleBirth -->
                    <xsl:for-each select="meerling_indicator | multiple_birth_indicator">
                        <multipleBirthBoolean>
                            <xsl:call-template name="boolean-to-boolean">
                                <xsl:with-param name="in" select="."/>
                            </xsl:call-template>
                        </multipleBirthBoolean>
                    </xsl:for-each>
                    <!-- photo -->

                    <!-- contact -->

                    <!-- animal -->

                    <!-- communication -->

                    <!-- generalPractitioner -->
                    <xsl:if test="$generalPractitionerRef">
                        <generalPractitioner>
                            <xsl:copy-of select="$generalPractitionerRef[self::f:extension]"/>
                            <xsl:copy-of select="$generalPractitionerRef[self::f:reference]"/>
                            <xsl:copy-of select="$generalPractitionerRef[self::f:identifier]"/>
                            <xsl:copy-of select="$generalPractitionerRef[self::f:display]"/>
                        </generalPractitioner>
                    </xsl:if>
                    <!-- managingOrganization -->
                    <xsl:if test="$managingOrganizationRef">
                        <generalPractitioner>
                            <xsl:copy-of select="$managingOrganizationRef[self::f:extension]"/>
                            <xsl:copy-of select="$managingOrganizationRef[self::f:reference]"/>
                            <xsl:copy-of select="$managingOrganizationRef[self::f:identifier]"/>
                            <xsl:copy-of select="$managingOrganizationRef[self::f:display]"/>
                        </generalPractitioner>
                    </xsl:if>
                    <!-- link -->
                </Patient>
            </xsl:variable>

            <!-- Add resource.text -->
            <xsl:apply-templates select="$resource" mode="addNarrative"/>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>Searches for resourceid using the input ada patient in global param patientTokensXml (configuration document) and returns it when found. 
            First attempt on bsn. Second attempt on exact match familyName. Third attempt on contains familyName. Then gives up.</xd:desc>
        <xd:param name="adaPatient">Input ada patient</xd:param>
    </xd:doc>
    <xsl:function name="nf:get-resourceid-from-token" as="xs:string?">
        <xsl:param name="adaPatient" as="element(patient)?"/>

        <xsl:variable name="adaBsn" select="normalize-space($adaPatient/(identificatienummer | patient_identificatienummer | patient_identification_number)[@root = $oidBurgerservicenummer]/@value)"/>
        <xsl:variable name="tokenResourceId" select="$patientTokensXml//*[bsn/normalize-space(text()) = $adaBsn]/resourceId"/>

        <xsl:choose>
            <xsl:when test="count($tokenResourceId) = 1">
                <xsl:value-of select="$tokenResourceId"/>
            </xsl:when>
            <xsl:when test="count($tokenResourceId) gt 1">
                <!-- more than one token on same BSN, something is really bogus in the QualificationTokens file let's report and quit here -->
                <xsl:call-template name="util:logMessage">
                    <xsl:with-param name="level" select="$logDEBUG"/>
                    <xsl:with-param name="msg">
                        <xsl:text>Found more then one token in QualificationTokens for bsn </xsl:text>
                        <xsl:value-of select="$adaBsn"/>
                        <xsl:text>. So we will not use either of those.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- not found using bsn, let's try exact match on family name -->
                <xsl:variable name="adaEigenAchternaam" select="upper-case(normalize-space($adaPatient//(naamgegevens[not(naamgegevens)] | name_information[not(name_information)])/geslachtsnaam/achternaam/@value))"/>
                <xsl:variable name="tokenResourceId" select="($patientTokensXml//*[familyName/upper-case(normalize-space(text())) = $adaEigenAchternaam]/resourceId)"/>

                <xsl:choose>
                    <xsl:when test="count($tokenResourceId) = 1">
                        <xsl:value-of select="$tokenResourceId"/>
                    </xsl:when>
                    <xsl:when test="count($tokenResourceId) gt 1">
                        <!-- more than one token on same last name, this is really not how it should be, let's report and quit here -->
                        <xsl:call-template name="util:logMessage">
                            <xsl:with-param name="level" select="$logDEBUG"/>
                            <xsl:with-param name="msg">
                                <xsl:text>Found more then one token in QualificationTokens for exact match on last name </xsl:text>
                                <xsl:value-of select="$adaEigenAchternaam"/>
                                <xsl:text>. So we will not use any of those.</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- not found using exact, let's try contains on family name -->
                        <xsl:variable name="tokenResourceId" select="$patientTokensXml//*[contains(familyName/upper-case(normalize-space(text())), $adaEigenAchternaam)]/resourceId"/>

                        <xsl:choose>
                            <xsl:when test="count($tokenResourceId) = 1">
                                <xsl:value-of select="$tokenResourceId"/>
                            </xsl:when>
                            <xsl:when test="count($tokenResourceId) gt 1">
                                <!-- more than one token on containing last name, this can happen, but is a shame, let's report -->
                                <xsl:call-template name="util:logMessage">
                                    <xsl:with-param name="level" select="$logDEBUG"/>
                                    <xsl:with-param name="msg">
                                        <xsl:text>Found more then one token in QualificationTokens for contains of last name </xsl:text>
                                        <xsl:value-of select="$adaEigenAchternaam"/>
                                        <xsl:text>. So we will not use any of those.</xsl:text>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- return nothing -->
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>
</xsl:stylesheet>
