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
    <xsl:import href="../../fhir/2_fhir_fhir_include.xsl"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="referById" as="xs:boolean" select="false()"/>
    <!-- pass an appropriate macAddress to ensure uniqueness of the UUID -->
    <!-- 02-00-00-00-00-00 may not be used in a production situation -->
    <xsl:param name="macAddress">02-00-00-00-00-00</xsl:param>

    <xsl:variable name="organizations" as="element()*">
        <!-- Zorgaanbieders -->
        <xsl:for-each-group select="//zorgaanbieder[not(zorgaanbieder)][not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" group-by="concat(nff:ada-za-id(zorgaanbieder_identificatie_nummer | zorgaanbieder_identificatienummer)/@root, nff:ada-za-id(zorgaanbieder_identificatie_nummer | zorgaanbieder_identificatienummer)/@value)">
            <xsl:for-each-group select="current-group()" group-by="nff:get-grouping-key-default(.)">
                <xsl:variable name="uuid" as="xs:boolean" select="position() > 1"/>
                <unieke-zorgaanbieder xmlns="">
                    <group-key xmlns="">
                        <xsl:value-of select="current-grouping-key()"/>
                    </group-key>
                    <xsl:variable name="organizationName" select="(organisatie_naam | organization_name)/@value"/>
                    <xsl:variable name="organizationLocation" select="(organisatie_locatie | organization_location)/@value"/>
                    <xsl:variable name="display-for-reference">
                        <xsl:choose>
                            <xsl:when test="$organizationName or $organizationLocation">
                                <xsl:value-of select="string-join(($organizationName, $organizationLocation)[. != ''], ' - ')"/>
                            </xsl:when>
                            <xsl:when test="(zorgaanbieder_identificatie_nummer | zorgaanbieder_identificatienummer)[@value]">Organisatie met id '<xsl:value-of select="(zorgaanbieder_identificatie_nummer | zorgaanbieder_identificatienummer)/@value"/>' in identificerend systeem '<xsl:value-of select="(zorgaanbieder_identificatie_nummer | zorgaanbieder_identificatienummer)/@root"/>'.</xsl:when>
                            <xsl:otherwise>Organisatie informatie: <xsl:value-of select="string-join(.//(@value | @code | @root | @codeSystem), ' - ')"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <reference-display xmlns="">
                        <xsl:value-of select="$display-for-reference"/>
                    </reference-display>
                    <xsl:for-each select="current-group()[1]">
                        <xsl:call-template name="organization-entry">
                            <xsl:with-param name="uuid" select="$uuid"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </unieke-zorgaanbieder>
            </xsl:for-each-group>
        </xsl:for-each-group>
    </xsl:variable>

    <xsl:variable name="patients" as="element()*">
        <!-- Patients -->
        <xsl:for-each-group select="//patient[not(patient)][not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" group-by="nff:get-grouping-key-default(.)">
            <!-- uuid als fullUrl en ook een fhir id genereren vanaf de tweede groep -->
            <xsl:variable name="uuid" as="xs:boolean" select="position() > 1"/>
            <unieke-patient xmlns="">
                <group-key xmlns="">
                    <xsl:value-of select="current-grouping-key()"/>
                </group-key>
                <reference-display xmlns="">
                    <xsl:value-of select="normalize-space(string-join(naamgegevens//*[not(name() = 'naamgebruik')]/@value, ' '))"/>
                </reference-display>
                <xsl:for-each select="current-group()[1]">
                    <xsl:call-template name="patient-entry">
                        <xsl:with-param name="uuid" select="$uuid"/>
                    </xsl:call-template>
                </xsl:for-each>
            </unieke-patient>
        </xsl:for-each-group>
    </xsl:variable>
    <xsl:variable name="practitioners" as="element()*">
        <!-- Zorgverleners with actual data in Practitioners -->
        <xsl:for-each-group select="//zorgverlener[not(zorgverlener)][not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)][*//(@value | @code | @nullFlavor)]" group-by="concat(nff:ada-zvl-id(./(zorgverlener_identificatie_nummer | zorgverlener_identificatienummer))/@root, nff:ada-zvl-id(./(zorgverlener_identificatie_nummer | zorgverlener_identificatienummer))/@value)">
            <xsl:for-each-group select="current-group()" group-by="nff:get-grouping-key-practitioner(.)">
                <!-- uuid als fullUrl en ook een fhir id genereren vanaf de tweede groep -->
                <xsl:variable name="uuid" as="xs:boolean" select="position() > 1"/>
                <unieke-zorgverlener xmlns="">
                    <group-key xmlns="">
                        <xsl:value-of select="current-grouping-key()"/>
                    </group-key>
                    <reference-display xmlns="">
                        <xsl:value-of select="normalize-space(string-join(.//naamgegevens[not(naamgegevens)]//*[not(name() = 'naamgebruik')]/@value, ' '))"/>
                    </reference-display>
                    <xsl:for-each select="current-group()[1]">
                        <xsl:call-template name="practitioner-entry">
                            <xsl:with-param name="uuid" select="$uuid"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </unieke-zorgverlener>
            </xsl:for-each-group>
        </xsl:for-each-group>
    </xsl:variable>

    <xsl:variable name="practitionerRoles" as="element()*">
        <!-- Zorgverleners in PractitionerRoles -->
        <xsl:for-each-group select="//zorgverlener[not(zorgverlener)][not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" group-by="nff:get-grouping-key-default(.)">
            <unieke-practitionerRole xmlns="">
                <group-key xmlns="">
                    <xsl:value-of select="current-grouping-key()"/>
                </group-key>
                <reference-display xmlns="">
                    <xsl:value-of select="nff:get-practitioner-role-display(.)"/>
                </reference-display>
                <xsl:apply-templates select="current-group()[1]" mode="doPractitionerRoleEntry"/>
            </unieke-practitionerRole>
        </xsl:for-each-group>
    </xsl:variable>

    <xsl:variable name="problems" as="element()*">
        <!-- probleem in problem -->
        <xsl:for-each-group select="//(probleem[not(probleem)] | problem[not(problem)])[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" group-by="nff:get-grouping-key-default(.)">
            <unieke-problem xmlns="">
                <group-key xmlns="">
                    <xsl:value-of select="current-grouping-key()"/>
                </group-key>
                <reference-display xmlns="">
                    <xsl:value-of select="(probleem_naam | problem_name)/@displayName"/>
                </reference-display>
                <xsl:apply-templates select="current-group()[1]" mode="doProblemEntry"/>
            </unieke-problem>
        </xsl:for-each-group>
    </xsl:variable>

    <xsl:variable name="related-persons" as="element()*">
        <!-- related-persons  -->
        <xsl:for-each-group select="//(contactpersoon[not(contactpersoon)] | contact[not(contact)])[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" group-by="nff:get-grouping-key-default(.)">
            <!-- uuid als fullUrl en ook een fhir id genereren vanaf de tweede groep -->
            <xsl:variable name="uuid" as="xs:boolean" select="position() > 1"/>
            <unieke-persoon xmlns="">
                <group-key xmlns="">
                    <xsl:value-of select="current-grouping-key()"/>
                </group-key>
                <reference-display xmlns="">
                    <xsl:value-of select="normalize-space(string-join(naamgegevens//*[not(name() = 'naamgebruik')]/@value, ' '))"/>
                </reference-display>
                <xsl:for-each select="current-group()[1]">
                    <xsl:call-template name="relatedperson-entry">
                        <xsl:with-param name="uuid" select="$uuid"/>
                    </xsl:call-template>
                </xsl:for-each>
            </unieke-persoon>
        </xsl:for-each-group>
    </xsl:variable>


    <xd:doc>
        <xd:desc>Helper template for organization payload independent of version (6.12 or nl-core).</xd:desc>
    </xd:doc>
    <xsl:template name="_organization-payload">
        <!-- zorgaanbieder_identificatienummer -->
        <xsl:for-each select="(zorgaanbieder_identificatie_nummer | healthcare_provider_identification_number)[@value]">
            <identifier>
                <xsl:call-template name="id-to-Identifier">
                    <xsl:with-param name="in" select="."/>
                </xsl:call-template>
            </identifier>
        </xsl:for-each>
        <!-- type -->
        <xsl:for-each select="organization_type | organisatie_type | department_specialty | afdeling_specialisme">
            <type>
                <xsl:call-template name="code-to-CodeableConcept">
                    <xsl:with-param name="in" select="."/>
                </xsl:call-template>
            </type>
        </xsl:for-each>
        <!-- name -->
        <xsl:variable name="organizationName" select="(organisatie_naam | organization_name)/@value"/>
        <xsl:variable name="organizationLocation" select="(organisatie_locatie | organization_location)/@value"/>
        <xsl:if test="$organizationName or $organizationLocation">
            <!-- Cardinality of ADA allows organizationLocation to be present without organizationName. This allows Organization.name to be the value of organizationLocation. This conforms to mapping of HCIM HealthcareProvider -->
            <name value="{string-join(($organizationName, $organizationLocation)[. != ''],' - ')}"/>
        </xsl:if>

        <!-- contactgegevens -->
        <xsl:apply-templates select=".//(contactgegevens[not(contactgegevens)] | contact_information[not(contact_information)])" mode="doContactPoint"/>
        <!-- adresgegevens -->
        <xsl:apply-templates select=".//(adresgegevens[not(adresgegevens)] | address_information[not(address_information)])" mode="doAddress"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Helper template for patient payload independent of profile tag (MP 6.12 DispenseConversion or nl-core).</xd:desc>
    </xd:doc>
    <xsl:template name="_patient-payload">

        <!-- patient_identificatienummer  -->
        <xsl:for-each select="(identificatienummer | patient_identification_number)[@value]">
            <!-- translation inconsistency -->
            <identifier>
                <xsl:call-template name="id-to-Identifier">
                    <xsl:with-param name="in" select="."/>
                </xsl:call-template>
            </identifier>
        </xsl:for-each>
        <!-- naamgegevens -->
        <xsl:for-each select=".//(naamgegevens[not(naamgegevens)] | name_information[not(name_information)])">
            <xsl:call-template name="nl-core-humanname">
                <xsl:with-param name="ada-naamgegevens" select="."/>
                <xsl:with-param name="unstructured-name" select="ongestructureerde_naam/@value"/>
            </xsl:call-template>
        </xsl:for-each>

        <xsl:apply-templates select=".//(contactgegevens[not(contactgegevens)] | contact_information[not(contact_information)])" mode="doContactPoint"/>

        <xsl:for-each select="(geslacht | gender)[@value | @code]">
            <gender>
                <xsl:attribute name="value">
                    <xsl:choose>
                        <xsl:when test="./@code = 'M'">male</xsl:when>
                        <xsl:when test="./@code = 'F'">female</xsl:when>
                        <xsl:when test="./@code = 'UN'">other</xsl:when>
                        <xsl:when test="./@code = 'UNK'">unknown</xsl:when>
                        <xsl:otherwise>unknown</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </gender>
        </xsl:for-each>

        <!-- geboortedatum -->
        <xsl:for-each select="(geboortedatum | date_of_birth)/@value">
            <!-- in the zib birthdate is of type date/time, in FHIR it is type date. 
                If we get a date/time in the input let's at least ignore a time earlier than 00:00:01 -->
            <xsl:variable name="fhirBirthDate">
                <xsl:choose>
                    <xsl:when test=". castable as xs:date">
                        <xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:when test=". castable as xs:dateTime">
                        <xsl:choose>
                            <xsl:when test="xs:time(nf:getTime(.)) lt xs:time('00:00:01')">
                                <!-- return only date -->
                                <xsl:value-of select="substring(., 1, 10)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- a time was in the input and may be relevant, let's output the time even though it will result in invalid FHIR -->
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <birthDate value="{$fhirBirthDate}"/>
        </xsl:for-each>

        <!-- zib/ADA defines date_of_death and death_indicator as separate fields, while FHIR uses the deceased[x] field.
                 So we first try to take the date_of_death value and if that isn't present, we try to take
                 death_indicator. -->
        <xsl:choose>
            <xsl:when test="(datum_overlijden | date_of_death)[@value]">
                <deceasedDateTime>
                    <xsl:attribute name="value">
                        <xsl:call-template name="format2FHIRDate">
                            <xsl:with-param name="dateTime" select="(datum_overlijden | date_of_death)/@value"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </deceasedDateTime>
            </xsl:when>
            <xsl:when test="(overlijdens_indicator | death_indicator)[@value]">
                <deceasedBoolean value="{xs:boolean((overlijdens_indicator | death_indicator)/@value)}"/>
            </xsl:when>
        </xsl:choose>
        <!-- adresgegevens -->
        <xsl:apply-templates select="adresgegevens[.//(@value | @code | @nullFlavor)]" mode="doAddress"/>

        <xsl:for-each select="(meerling_indicator | multiple_birth_indicator)[@value]">
            <multipleBirthBoolean value="{./@value}"/>
        </xsl:for-each>

    </xsl:template>
    <xd:doc>
        <xd:desc>Write out a FHIR reference type element.</xd:desc>
        <xd:param name="reference">A map containing the parameters for the reference. If this parameter is absent, no output will be produced. The following keys are recognized:
            <xd:ul>
                <xd:li>target: the target of the reference.</xd:li>
                <xd:li>display: an optional display value for the reference.</xd:li>
            </xd:ul>
        </xd:param>
        <xd:param name="wrapIn">
            <xd:p>Wrap the reference in an element with this name. If this parameter is not present, the output will be the naked content.</xd:p>
            <xd:p>This parameter makes it easy to create an element only if the reference parameter is present.</xd:p>
        </xd:param>
    </xd:doc>
    <xsl:template name="_Reference">
        <xsl:param name="reference" as="map(xs:string, xs:string)?"/>
        <xsl:param name="wrapIn" as="xs:string?"/>

        <xsl:if test="count($reference) > 0">
            <xsl:variable name="refContent">
                <reference value="{$reference('target')}"/>
                <xsl:if test="$reference('display')">
                    <display value="{$reference('display')}"/>
                </xsl:if>
            </xsl:variable>

            <xsl:choose>
                <xsl:when test="exists($wrapIn)">
                    <xsl:element name="{$wrapIn}">
                        <xsl:copy-of select="$refContent"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$refContent"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

    </xsl:template>

    <xd:doc>
        <xd:desc>Helper template to create FHIR default reference using grouping key default, context should be ada element to reference</xd:desc>
        <xd:param name="ResourceType">The FHIR resource type to reference, such as Patient, PractitionerRole, Organization</xd:param>
    </xd:doc>
    <xsl:template name="_do-reference" match="element()" mode="doReference">
        <xsl:param name="ResourceType" as="xs:string"/>
        <xsl:variable name="group-key">
            <xsl:choose>
                <xsl:when test="$ResourceType = 'Practitioner'">
                    <xsl:value-of select="nff:get-grouping-key-practitioner(.)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="nff:get-grouping-key-default(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <reference value="{nff:get-resource-info($ResourceType,$group-key, false(), 'FullUrlOrId')}"/>
        <display value="{nff:get-resource-info($ResourceType,$group-key, false(), 'ReferenceDisplay')}"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Mapping of nl.zorg.AllergieIntolerantie concept in ADA to FHIR resource <xd:a href="https://simplifier.net/search?canonical=http://nictiz.nl/fhir/StructureDefinition/zib-AllergyIntolerance">zib-AllergyIntolerance</xd:a>.</xd:desc>
        <xd:param name="logicalId">Optional FHIR logical id for the patient record.</xd:param>
        <xd:param name="ada-patient">The ada patient that is subject of this AllergyIntolerance</xd:param>
        <!-- <xd:param name="patientRef">The patient (subject) reference this resource applies to, as a map with 'target' and optional 'display' keys.</xd:param>
        <xd:param name="recorderRef">The recorder (auteur) reference of this resource, as a map with 'target' and optional 'display' keys.</xd:param>
        <xd:param name="asserterRef">The recorder (informant) reference of this resource, as a map with 'target' and optional 'display' keys.</xd:param>
   -->
    </xd:doc>
    <xsl:template name="zib-AllergyIntolerance" match="allergie_intolerantie | allergy_intolerance" as="element()" mode="doZibAllergyIntolerance">
        <xsl:param name="logicalId" as="xs:string?"/>
        <xsl:param name="ada-patient" as="element(patient)?"/>
        <!--  <xsl:param name="patientRef" as="map(xs:string, xs:string)"/>
        <xsl:param name="recorderRef" as="map(xs:string, xs:string)?"/>
        <xsl:param name="asserterRef" as="map(xs:string, xs:string)?"/>
    -->
        <AllergyIntolerance>

            <xsl:if test="exists($logicalId)">
                <id value="{$logicalId}"/>
            </xsl:if>

            <meta>
                <profile value="http://nictiz.nl/fhir/StructureDefinition/zib-AllergyIntolerance"/>
            </meta>

            <xsl:for-each select="(allergie_status | allergy_status)[@code]">
                <clinicalStatus>
                    <xsl:attribute name="value">
                        <xsl:choose>
                            <xsl:when test="@code = 'active'">active</xsl:when>
                            <xsl:when test="@code = 'completed'">resolved</xsl:when>
                            <xsl:otherwise>inactive</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <extension url="http://nictiz.nl/fhir/StructureDefinition/code-specification">
                        <valueCodeableConcept>
                            <xsl:call-template name="code-to-CodeableConcept">
                                <xsl:with-param name="in" select="."/>
                            </xsl:call-template>
                        </valueCodeableConcept>
                    </extension>
                </clinicalStatus>
            </xsl:for-each>

            <xsl:for-each select="(allergie_categorie | allergy_category)[@code]">
                <xsl:choose>
                    <xsl:when test="(allergie_status | allergy_status)[@code = 'nullified'][@codeSystem][1]">
                        <xsl:for-each select="allergie_status | allergy_status[@code = 'nullified'][@codeSystem][1]">
                            <verificationStatus value="entered-in-error">
                                <extension url="http://nictiz.nl/fhir/StructureDefinition/code-specification">
                                    <valueCodeableConcept>
                                        <coding>
                                            <system value="{local:getUri(@codeSystem)}"/>
                                            <code value="{@code}"/>
                                            <xsl:if test="@displayName">
                                                <display value="{@displayName}"/>
                                            </xsl:if>
                                        </coding>
                                    </valueCodeableConcept>
                                </extension>
                            </verificationStatus>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="(begin_datum_tijd | start_date_time)[@value]">
                        <verificationStatus value="confirmed"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- we don't know, but still a required element, data-absent-reason -->
                        <verificationStatus>
                            <extension url="http://hl7.org/fhir/StructureDefinition/data-absent-reason">
                                <valueCode value="unknown"/>
                            </extension>
                        </verificationStatus>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- The ZIB prescribes an (optional) value list for the allergy category, which is mapped onto
                     AllergyIntolerance.category. However, .category defines its own required coding, which can't be
                     always translated from the zib value set. In case we can't make the translation, we have no other
                     option than to exclude .category altogether, even if it means we also exclude the ZIB value - we
                     can't produce a valid FHIR instance otherwise. -->
                <xsl:variable name="fhirCategory">
                    <xsl:choose>
                        <xsl:when test="@code = '418471000'">food</xsl:when>
                        <xsl:when test="@code = '419511003'">medication</xsl:when>
                        <xsl:when test="@code = '426232007'">environment</xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="$fhirCategory != ''">
                    <category value="{$fhirCategory}">
                        <extension url="http://nictiz.nl/fhir/StructureDefinition/code-specification">
                            <valueCodeableConcept>
                                <xsl:call-template name="code-to-CodeableConcept">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </valueCodeableConcept>
                        </extension>
                    </category>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="(mate_van_kritiek_zijn | criticality)[@code]">
                <criticality>
                    <xsl:attribute name="value">
                        <xsl:choose>
                            <xsl:when test="@code = 62482003">low</xsl:when>
                            <xsl:otherwise>high</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <extension url="http://nictiz.nl/fhir/StructureDefinition/code-specification">
                        <valueCodeableConcept>
                            <xsl:call-template name="code-to-CodeableConcept">
                                <xsl:with-param name="in" select="."/>
                            </xsl:call-template>
                        </valueCodeableConcept>
                    </extension>
                </criticality>
            </xsl:for-each>

            <xsl:for-each select="veroorzakende_stof | causative_agent">
                <code>
                    <xsl:call-template name="code-to-CodeableConcept">
                        <xsl:with-param name="in" select="."/>
                    </xsl:call-template>
                </code>
            </xsl:for-each>

            <!-- Who the sensitivity is for -->
            <patient>
                <xsl:call-template name="_subjectOrZibrootSubject">
                    <xsl:with-param name="adaSubject" select="$ada-patient"/>
                    <xsl:with-param name="adaSubjectResourceType">Patient</xsl:with-param>
                    <xsl:with-param name="currentHcim" select="."/>
                </xsl:call-template>
            </patient>

            <xsl:for-each select="(begin_datum_tijd | start_date_time)[@value]">
                <onsetDateTime>
                    <xsl:attribute name="value">
                        <xsl:call-template name="format2FHIRDate">
                            <xsl:with-param name="dateTime" select="@value"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </onsetDateTime>
            </xsl:for-each>

            <!-- TODO -->

            <!--<xsl:call-template name="_Reference">
                <xsl:with-param name="reference" select="$recorderRef"/>
                <xsl:with-param name="wrapIn" select="'recorder'"/>
            </xsl:call-template>
            
            <xsl:call-template name="_Reference">
                <xsl:with-param name="reference" select="$asserterRef"/>
                <xsl:with-param name="wrapIn" select="'asserter'"/>
            </xsl:call-template>-->

            <xsl:for-each select="(laatste_reactie_datum_tijd | last_reaction_date_time)[@value]">
                <lastOccurrence>
                    <xsl:attribute name="value">
                        <xsl:call-template name="format2FHIRDate">
                            <xsl:with-param name="dateTime" select="@value"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </lastOccurrence>
            </xsl:for-each>

            <xsl:for-each select="(toelichting | comment)[@value]">
                <note>
                    <text value="{@value}"/>
                </note>
            </xsl:for-each>

            <xsl:for-each select="(reactie | reaction)[//@code or //@value]">
                <reaction>
                    <xsl:for-each select="(specifieke_stof | specific_substance)[@code]">
                        <substance>
                            <xsl:call-template name="code-to-CodeableConcept">
                                <xsl:with-param name="in" select="."/>
                            </xsl:call-template>
                        </substance>
                    </xsl:for-each>

                    <xsl:for-each select="(symptoom | symptom)[@code]">
                        <manifestation>
                            <xsl:call-template name="code-to-CodeableConcept">
                                <xsl:with-param name="in" select="."/>
                            </xsl:call-template>
                        </manifestation>
                    </xsl:for-each>

                    <xsl:for-each select="(reactie_beschrijving | reaction_description)[@value]">
                        <description value="{@value}"/>
                    </xsl:for-each>

                    <xsl:for-each select="(reactie_tijdstip | reaction_time)[@value]">
                        <onset>
                            <xsl:attribute name="value">
                                <xsl:call-template name="format2FHIRDate">
                                    <xsl:with-param name="dateTime" select="@value"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </onset>
                    </xsl:for-each>

                    <xsl:for-each select="(ernst | severity)[@code]">
                        <severity>
                            <xsl:attribute name="value">
                                <xsl:choose>
                                    <xsl:when test="@code = 255604002">mild</xsl:when>
                                    <xsl:when test="@code = 6736007">moderate</xsl:when>
                                    <xsl:when test="@code = 24484000">severe</xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
                        </severity>
                    </xsl:for-each>

                    <xsl:for-each select="(wijze_van_blootstelling | route_of_exposure)[@code]">
                        <exposureRoute>
                            <xsl:call-template name="code-to-CodeableConcept">
                                <xsl:with-param name="in" select="."/>
                            </xsl:call-template>
                        </exposureRoute>
                    </xsl:for-each>

                </reaction>
            </xsl:for-each>

        </AllergyIntolerance>
    </xsl:template>



    <xd:doc>
        <xd:desc>Mapping of nl.zorg.AllergieIntolerantie concept in ADA to FHIR resource <xd:a href="https://simplifier.net/search?canonical=http://nictiz.nl/fhir/StructureDefinition/zib-AllergyIntolerance">zib-AllergyIntolerance</xd:a>.</xd:desc>
        <xd:param name="logicalId">Optional FHIR logical id for the patient record.</xd:param>
        <xd:param name="ada-patient">The ada patient that is subject of this Alert</xd:param>
        <!-- <xd:param name="patientRef">The patient (subject) reference this resource applies to, as a map with 'target' and optional 'display' keys.</xd:param>
        <xd:param name="recorderRef">The recorder (auteur) reference of this resource, as a map with 'target' and optional 'display' keys.</xd:param>
        <xd:param name="asserterRef">The recorder (informant) reference of this resource, as a map with 'target' and optional 'display' keys.</xd:param>
   -->
    </xd:doc>
    <xsl:template name="zib-Alert" match="alert" as="element()" mode="doZibAlert">
        <xsl:param name="logicalId" as="xs:string?"/>
        <xsl:param name="ada-patient" as="element(patient)?"/>

        <xsl:variable name="currentAdaTransaction" select="ancestor::*[ancestor::data]"/>

        <Flag>
            <xsl:if test="exists($logicalId)">
                <id value="{$logicalId}"/>
            </xsl:if>

            <meta>
                <profile value="http://nictiz.nl/fhir/StructureDefinition/zib-Alert"/>
            </meta>

            <xsl:for-each select="nff:ada-resolve-reference(conditie/probleem | condition/problem)">

                <extension url="http://hl7.org/fhir/StructureDefinition/flag-detail">
                    <valueReference>
                        <xsl:call-template name="_do-reference">
                            <xsl:with-param name="ResourceType">Condition</xsl:with-param>
                        </xsl:call-template>
                    </valueReference>
                </extension>
            </xsl:for-each>
            <!-- status does not exist in zib but is 1..1 in FHIR profile -->
            <status>
                <extension url="http://hl7.org/fhir/StructureDefinition/data-absent-reason">
                    <valueCode value="unknown"/>
                </extension>
            </status>

            <xsl:for-each select="alert_type[@code]">
                <category>
                    <xsl:call-template name="code-to-CodeableConcept">
                        <xsl:with-param name="in" select="."/>
                    </xsl:call-template>
                </category>
            </xsl:for-each>

            <!-- code is 1..1 in FHIR profile, in zib either alert_naam or reference to problem should exist -->
            <code>
                <xsl:choose>
                    <xsl:when test="alert_naam[@code]">
                        <xsl:call-template name="code-to-CodeableConcept">
                            <xsl:with-param name="in" select="alert_naam[@code]"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <extension url="http://hl7.org/fhir/StructureDefinition/data-absent-reason">
                            <valueCode value="unknown"/>
                        </extension>
                    </xsl:otherwise>
                </xsl:choose>
            </code>

            <subject>
                <xsl:call-template name="_subjectOrZibrootSubject">
                    <xsl:with-param name="adaSubject" select="$ada-patient"/>
                    <xsl:with-param name="adaSubjectResourceType">Patient</xsl:with-param>
                    <xsl:with-param name="currentHcim" select="."/>
                </xsl:call-template>
            </subject>
        </Flag>
    </xsl:template>



    <xd:doc>
        <xd:desc>Template for FHIR profile nl-core-address-2.0, context should be ada adresgegevens element</xd:desc>
    </xd:doc>
    <xsl:template name="nl-core-address-2.0" match="(adresgegevens[not(adresgegevens)] | address_information[not(address_information)])[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" mode="doAddress">
        <xsl:for-each select=".[.//(@value | @code)]">
            <xsl:variable name="lineItems" as="element()*">
                <xsl:for-each select="./straat/@value">
                    <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName">
                        <valueString value="{.}"/>
                    </extension>
                </xsl:for-each>
                <xsl:for-each select="./huisnummer/@value">
                    <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber">
                        <valueString value="{.}"/>
                    </extension>
                </xsl:for-each>
                <xsl:for-each select="./huisnummerletter/@value | ./huisnummertoevoeging/@value">
                    <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-buildingNumberSuffix">
                        <valueString value="{.}"/>
                    </extension>
                </xsl:for-each>
                <xsl:for-each select="./additionele_informatie/@value">
                    <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-unitID">
                        <valueString value="{.}"/>
                    </extension>
                </xsl:for-each>
                <xsl:for-each select="./aanduiding_bij_nummer/@value">
                    <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-additionalLocator">
                        <valueString value="{.}"/>
                    </extension>
                </xsl:for-each>
            </xsl:variable>
            <address>
                <!-- adres_soort -->
                <xsl:for-each select="adres_soort[@codeSystem = '2.16.840.1.113883.5.1119'][@code]">
                    <xsl:choose>
                        <!-- Postadres -->
                        <xsl:when test="@code = 'PST'">
                            <use>
                                <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-AD-use">
                                    <valueCode value="PST"/>
                                </extension>
                            </use>
                            <type value="postal"/>
                        </xsl:when>
                        <!-- Officieel adres -->
                        <xsl:when test="@code = 'HP'">
                            <extension url="http://fhir.nl/fhir/StructureDefinition/nl-core-address-official">
                                <valueCode value="true"/>
                            </extension>
                            <use value="home">
                                <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-AD-use">
                                    <valueCode value="HP"/>
                                </extension>
                            </use>
                            <type value="physical"/>
                        </xsl:when>
                        <!-- Woon-/verblijfadres -->
                        <xsl:when test="@code = 'PHYS'">
                            <use value="home">
                                <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-AD-use">
                                    <valueCode value="HP"/>
                                </extension>
                            </use>
                            <type value="physical"/>
                        </xsl:when>
                        <!-- Tijdelijk adres -->
                        <xsl:when test="@code = 'TMP'">
                            <use value="temp"/>
                        </xsl:when>
                        <!-- Werkadres -->
                        <xsl:when test="@code = 'WP'">
                            <use value="work"/>
                        </xsl:when>
                        <!-- Vakantie adres -->
                        <xsl:when test="@code = 'HV'">
                            <use value="temp">
                                <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-AD-use">
                                    <valueCode value="HV"/>
                                </extension>
                            </use>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
                <line>
                    <xsl:if test="$lineItems">
                        <xsl:attribute name="value" select="string-join($lineItems//*:valueString/@value, ' ')"/>
                    </xsl:if>
                    <xsl:copy-of select="$lineItems"/>
                </line>
                <xsl:for-each select="./woonplaats/@value">
                    <city value="{.}"/>
                </xsl:for-each>
                <xsl:for-each select="./gemeente/@value">
                    <district value="{.}"/>
                </xsl:for-each>
                <xsl:for-each select="./postcode/@value">
                    <postalCode value="{.}"/>
                </xsl:for-each>
                <xsl:for-each select="./land/@value">
                    <country value="{.}"/>
                </xsl:for-each>
            </address>
        </xsl:for-each>

    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="ada-naamgegevens"/>
        <xd:param name="unstructured-name"/>
    </xd:doc>
    <xsl:template name="nl-core-humanname" match="(naamgegevens[not(naamgegevens)] | name_information[not(name_information)])[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" mode="doNlCoreHumanname">
        <xsl:param name="ada-naamgegevens" as="element()*"/>
        <xsl:param name="unstructured-name" as="xs:string?"/>
        <xsl:if test="$ada-naamgegevens[.//@value] or string-length($unstructured-name) gt 0">
            <xsl:choose>
                <xsl:when test="$ada-naamgegevens[.//@value]">
                    <xsl:for-each select="$ada-naamgegevens[.//@value]">
                        <name>
                            <xsl:for-each select="./naamgebruik[@code]">
                                <extension url="http://hl7.org/fhir/StructureDefinition/humanname-assembly-order">
                                    <valueCode value="{./@code}"/>
                                </extension>
                            </xsl:for-each>
                            <!-- unstructured-name, not supported in zib datamodel, may be customized per transaction, therefore parameterized in this template -->
                            <xsl:if test="string-length($unstructured-name) gt 0">
                                <text value="{$unstructured-name}"/>
                            </xsl:if>
                            <xsl:if test="./(geslachtsnaam | geslachtsnaam_partner)[.//@value]">
                                <family>
                                    <xsl:attribute name="value">
                                        <xsl:choose>
                                            <!-- Eigen geslachtsnaam -->
                                            <xsl:when test="./naamgebruik/@code = 'NL1'">
                                                <xsl:value-of select="normalize-space(string-join((./geslachtsnaam/voorvoegsels/@value, ././geslachtsnaam/achternaam/@value), ' '))"/>
                                            </xsl:when>
                                            <!-- 	Geslachtsnaam partner -->
                                            <xsl:when test="./naamgebruik/@code = 'NL2'">
                                                <xsl:value-of select="normalize-space(string-join((./geslachtsnaam_partner/voorvoegsels_partner/@value, ././geslachtsnaam_partner/achternaam_partner/@value), ' '))"/>
                                            </xsl:when>
                                            <!-- Geslachtsnaam partner gevolgd door eigen geslachtsnaam -->
                                            <xsl:when test="./naamgebruik/@code = 'NL3'">
                                                <xsl:value-of select="normalize-space(string-join((./geslachtsnaam_partner/voorvoegsels_partner/@value, ././geslachtsnaam_partner/achternaam_partner/@value, ./geslachtsnaam/voorvoegsels/@value, ././geslachtsnaam/achternaam/@value), ' '))"/>
                                            </xsl:when>
                                            <!-- Eigen geslachtsnaam gevolgd door geslachtsnaam partner -->
                                            <xsl:when test="./naamgebruik/@code = 'NL4'">
                                                <xsl:value-of select="normalize-space(string-join((./geslachtsnaam/voorvoegsels/@value, ././geslachtsnaam/achternaam/@value, ./geslachtsnaam_partner/voorvoegsels_partner/@value, ././geslachtsnaam_partner/achternaam_partner/@value), ' '))"/>
                                            </xsl:when>
                                            <!-- otherwise: we nemen aan NL4 - Eigen geslachtsnaam gevolgd door geslachtsnaam partner zodat iig geen informatie 'verdwijnt' -->
                                            <xsl:otherwise>
                                                <xsl:value-of select="normalize-space(string-join((./geslachtsnaam/voorvoegsels/@value, ././geslachtsnaam/achternaam/@value, ./geslachtsnaam_partner/voorvoegsels_partner/@value, ././geslachtsnaam_partner/achternaam_partner/@value), ' '))"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:for-each select="./geslachtsnaam/voorvoegsels[@value]">
                                        <extension url="http://hl7.org/fhir/StructureDefinition/humanname-own-prefix">
                                            <valueString value="{normalize-space(./@value)}"/>
                                        </extension>
                                    </xsl:for-each>
                                    <xsl:for-each select="./geslachtsnaam/achternaam[@value]">
                                        <extension url="http://hl7.org/fhir/StructureDefinition/humanname-own-name">
                                            <valueString value="{normalize-space(./@value)}"/>
                                        </extension>
                                    </xsl:for-each>
                                    <xsl:for-each select="./geslachtsnaam_partner/voorvoegsels[@value]">
                                        <extension url="http://hl7.org/fhir/StructureDefinition/humanname-partner-prefix">
                                            <valueString value="{normalize-space(./@value)}"/>
                                        </extension>
                                    </xsl:for-each>
                                    <xsl:for-each select="./geslachtsnaam_partner/achternaam[@value]">
                                        <extension url="http://hl7.org/fhir/StructureDefinition/humanname-partner-name">
                                            <valueString value="{normalize-space(./@value)}"/>
                                        </extension>
                                    </xsl:for-each>
                                </family>
                            </xsl:if>
                            <xsl:for-each select="./voornamen[.//@value]">
                                <given value="{normalize-space(./@value)}">
                                    <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier">
                                        <valueCode value="BR"/>
                                    </extension>
                                </given>
                            </xsl:for-each>
                            <xsl:for-each select="./initialen[.//@value]">
                                <given value="{normalize-space(./@value)}">
                                    <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier">
                                        <valueCode value="IN"/>
                                    </extension>
                                </given>
                            </xsl:for-each>
                            <xsl:for-each select="./roepnaam[.//@value]">
                                <given value="{normalize-space(./@value)}">
                                    <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier">
                                        <valueCode value="CL"/>
                                    </extension>
                                </given>
                            </xsl:for-each>
                            <xsl:for-each select="prefix[not(tokenize(@qualifier, '\s') = 'VV')]">
                                <prefix value="{.}"/>
                            </xsl:for-each>
                            <xsl:for-each select="suffix[.//@value]">
                                <suffix value="{.}"/>
                            </xsl:for-each>
                            <xsl:if test="validTime[.//@value]">
                                <period>
                                    <!-- <xsl:call-template name="IVL_TS-to-Period">
                     <xsl:with-param name="in" select="validTime"/>
                  </xsl:call-template>
            -->
                                </period>
                            </xsl:if>
                        </name>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <!-- only unstructured name -->
                    <name>
                        <text>
                            <xsl:value-of select="$unstructured-name"/>
                        </text>
                    </name>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc>Template for FHIR profile nl-core-organization-2.0</xd:desc>
        <xd:param name="ada-zorgaanbieder">Optional ada element zorgaanbieder, defaults to context</xd:param>
        <xd:param name="logicalId">Optional FHIR logical id for this record.</xd:param>
    </xd:doc>
    <xsl:template name="nl-core-organization-2.0" match="(zorgaanbieder[not(zorgaanbieder)] | healthcare_provider[not(healthcare_provider)])[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]">
        <xsl:param name="ada-zorgaanbieder" as="element()?" select="."/>
        <xsl:param name="logicalId" as="xs:string?"/>
        <xsl:for-each select="$ada-zorgaanbieder">
            <Organization>
                <xsl:for-each select="$logicalId">
                    <id value="{.}"/>
                </xsl:for-each>
                <meta>
                    <profile value="http://fhir.nl/fhir/StructureDefinition/nl-core-organization"/>
                </meta>
                <xsl:call-template name="_organization-payload"/>
            </Organization>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>Mapping of nl.zorg.Patient concept in ADA to FHIR resource <xd:a href="https://simplifier.net/search?canonical=http://fhir.nl/fhir/structuredefinition/nl-core-patient">nl-core-patient</xd:a>.</xd:desc>
        <xd:param name="logicalId">Optional FHIR logical id for the patient record.</xd:param>
    </xd:doc>
    <xsl:template name="nl-core-patient-2.0" match="patient[not(patient)][not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" as="element()" mode="doNlCorePatient">
        <xsl:param name="logicalId" as="xs:string?"/>
        <Patient>
            <xsl:if test="exists($logicalId)">
                <id value="{$logicalId}"/>
            </xsl:if>

            <meta>
                <profile value="http://fhir.nl/fhir/StructureDefinition/nl-core-patient"/>
            </meta>

            <xsl:call-template name="_patient-payload"/>

        </Patient>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template for FHIR profile nl-core-practitioner-2.0</xd:desc>
        <xd:param name="ada-zorgverlener">The practitioner in ada format</xd:param>
        <xd:param name="logicalId">Optional FHIR logical id for the resource.</xd:param>
    </xd:doc>
    <xsl:template name="nl-core-practitioner-2.0">
        <xsl:param name="ada-zorgverlener" as="element()?"/>
        <xsl:param name="logicalId" as="xs:string?"/>
        <!-- zorgverlener -->
        <xsl:for-each select="$ada-zorgverlener">
            <Practitioner>
                <xsl:for-each select="$logicalId">
                    <id value="{.}"/>
                </xsl:for-each>
                <meta>
                    <profile value="http://fhir.nl/fhir/StructureDefinition/nl-core-practitioner"/>
                </meta>
                <!-- zorgverlener_identificatie_nummer -->
                <xsl:for-each select="./(zorgverlener_identificatie_nummer | zorgverlener_identificatienummer)[.//@value]">
                    <identifier>
                        <xsl:call-template name="id-to-Identifier">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </identifier>
                </xsl:for-each>
                <!-- naamgegevens -->
                <xsl:for-each select="./(zorgverlener_naam/naamgegevens | .//naamgegevens[not(naamgegevens)])">
                    <xsl:call-template name="nl-core-humanname">
                        <xsl:with-param name="ada-naamgegevens" select="."/>
                        <xsl:with-param name="unstructured-name" select="./ongestructureerde_naam/@value"/>
                    </xsl:call-template>
                </xsl:for-each>
            </Practitioner>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc>Template for FHIR profile nl-core-practitionerrole-2.0</xd:desc>
        <xd:param name="ada-zorgverlener">ada element zorgverlener</xd:param>
        <xd:param name="logicalId">Optional FHIR logical id for the resource.</xd:param>
    </xd:doc>
    <xsl:template name="nl-core-practitionerrole-2.0">
        <xsl:param name="ada-zorgverlener" as="element()?" select="."/>
        <xsl:param name="logicalId" as="xs:string?"/>

        <xsl:variable name="currentAdaTransaction" select="$ada-zorgverlener/ancestor::*[ancestor::data]"/>

        <xsl:for-each select="$ada-zorgverlener">
            <PractitionerRole>
                <xsl:if test="string-length($logicalId) gt 0">
                    <id value="{$logicalId}"/>
                </xsl:if>
                <meta>
                    <profile value="http://fhir.nl/fhir/StructureDefinition/nl-core-practitionerrole"/>
                </meta>
                <xsl:for-each select=".[.//@value]">
                    <practitioner>
                        <xsl:apply-templates select="." mode="doReference">
                            <xsl:with-param name="ResourceType">Practitioner</xsl:with-param>
                        </xsl:apply-templates>
                    </practitioner>
                </xsl:for-each>

                <xsl:for-each select="nff:ada-resolve-reference(.//zorgaanbieder[not(zorgaanbieder)])">
                    <organization>
                        <xsl:apply-templates select="." mode="doReference">
                            <xsl:with-param name="ResourceType">Organization</xsl:with-param>
                        </xsl:apply-templates>
                    </organization>
                </xsl:for-each>

                <xsl:for-each select="zorgverlener_rol">
                    <code>
                        <xsl:call-template name="code-to-CodeableConcept">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </code>
                </xsl:for-each>
                <xsl:for-each select="specialisme">
                    <specialty>
                        <xsl:call-template name="code-to-CodeableConcept">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </specialty>
                </xsl:for-each>
            </PractitionerRole>
        </xsl:for-each>
    </xsl:template>


    <xd:doc>
        <xd:desc>Template for FHIR profile nl-core-problem-2.1.1</xd:desc>
        <xd:param name="ada-patient">The ada patient that is subject of this Condition, if not given template attempts to get subject from zibroot</xd:param>
        <xd:param name="logicalId">Optional FHIR logical id for the resource.</xd:param>
    </xd:doc>
    <xsl:template name="zib-Problem-2.1.1" match="(probleem[not(probleem)] | problem[not(problem)])[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" mode="doZibProblem211">
        <xsl:param name="ada-patient" as="element(patient)?"/>
        <xsl:param name="logicalId" as="xs:string?"/>

        <xsl:variable name="currentAdaTransaction" select="./ancestor::*[ancestor::data]"/>

        <Condition>
            <xsl:for-each select="$logicalId">
                <id value="{.}"/>
            </xsl:for-each>
            <meta>
                <profile value="http://nictiz.nl/fhir/StructureDefinition/zib-Problem"/>
            </meta>

            <!-- Clinical Status-->
            <xsl:for-each select="(problem_status | probleem_status)/@code">
                <clinicalStatus>
                    <xsl:attribute name="value">
                        <xsl:choose>
                            <xsl:when test=". = 55561003">active</xsl:when>
                            <xsl:when test=". = 73425007">inactive</xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </clinicalStatus>
            </xsl:for-each>
            <!-- Verification Status-->
            <xsl:for-each select="(verification_status | verificatie_status)/@code">
                <verificationStatus>
                    <xsl:attribute name="value">
                        <xsl:choose>
                            <xsl:when test=". = 415684004">provisional"</xsl:when>
                            <xsl:when test=". = 410590009">differential</xsl:when>
                            <xsl:when test=". = 410605003">confirmed</xsl:when>
                            <xsl:when test=". = 410516002">refuted</xsl:when>
                            <xsl:when test=". = 'UNK'">unknown</xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </verificationStatus>
            </xsl:for-each>

            <!-- Problem Type (.category) -->
            <xsl:for-each select="(problem_type | probleem_type)[.//(@value | @code)]">
                <category>
                    <xsl:call-template name="code-to-CodeableConcept">
                        <xsl:with-param name="in" select="."/>
                    </xsl:call-template>
                </category>
            </xsl:for-each>

            <!-- Problem Name (.code) -->
            <code>
                <xsl:call-template name="code-to-CodeableConcept">
                    <xsl:with-param name="in" select="problem_name | probleem_naam"/>
                </xsl:call-template>
            </code>

            <!-- BodySite SHALL be present when laterality or anatomical location is present in the adaxml -->
            <xsl:variable name="problemAnatomic" select="(problem_anatomical_location | probleem_anatomische_locatie)[@value | @code]"/>
            <xsl:variable name="problemLateral" select="(problem_laterality | probleem_lateraliteit)[@value | @code]"/>
            <xsl:if test="$problemAnatomic | $problemLateral">
                <bodySite>
                    <!-- extensie toevoegen als lateraliteit aanwezig is -->
                    <xsl:for-each select="$problemLateral">
                        <extension url="http://nictiz.nl/fhir/StructureDefinition/BodySite-Qualifier">
                            <valueCodeableConcept>
                                <xsl:call-template name="code-to-CodeableConcept">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </valueCodeableConcept>
                        </extension>
                    </xsl:for-each>
                    <!-- Codeableconcept toevoegen aan bodySite -->
                    <xsl:for-each select="$problemAnatomic">
                        <xsl:call-template name="code-to-CodeableConcept">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </xsl:for-each>
                </bodySite>
            </xsl:if>

            <subject>
                <xsl:call-template name="_subjectOrZibrootSubject">
                    <xsl:with-param name="adaSubject" select="$ada-patient"/>
                    <xsl:with-param name="adaSubjectResourceType">Patient</xsl:with-param>
                    <xsl:with-param name="currentHcim" select="."/>
                </xsl:call-template>
            </subject>

            <!-- OnsetPeriod -->
            <xsl:if test="(problem_start_date | probleem_begin_datum | problem_end_date | probleem_eind_datum)[@value]">
                <onsetPeriod>
                    <!-- StartDateTime -->
                    <xsl:if test="(problem_start_date | probleem_begin_datum)[@value]">
                        <start>
                            <xsl:attribute name="value">
                                <xsl:call-template name="format2FHIRDate">
                                    <xsl:with-param name="dateTime" select="(problem_start_date | probleem_begin_datum)/@value"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </start>
                    </xsl:if>

                    <!-- EndDateTime -->
                    <xsl:if test="(problem_end_date | probleem_eind_datum)[@value]">
                        <end>
                            <xsl:attribute name="value">
                                <xsl:call-template name="format2FHIRDate">
                                    <xsl:with-param name="dateTime" select="(problem_end_date | probleem_eind_datum)/@value"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </end>
                    </xsl:if>
                </onsetPeriod>
            </xsl:if>

            <!-- FUTURE IMPLEMENTATION, AN ISSUE HAS BEEN ENTERED TO CHANGE MAPPING OF START AND END DATE, BUT THIS IS STILL TO BE APPROVED-->
            <!-- <!-\- OnsetDatetime -\->
            <xsl:if test="(problem_start_date | probleem_start_datum)[@value | @code]">
                <onsetDateTime>
                    <xsl:attribute name="value">
                        <xsl:call-template name="format2FHIRDate">
                            <xsl:with-param name="dateTime"
                                select="(problem_start_date | probleem_start_datum)/@value"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </onsetDateTime>
            </xsl:if>

            <!-\- AbatementDateTime -\->
            <xsl:if test="problem_end_date | probleem_eind_datum">
                <abatementDateTime>
                    <xsl:attribute name="value">
                        <xsl:call-template name="format2FHIRDate">
                            <xsl:with-param name="dateTime"
                                select="(problem_end_date | probleem_eind_datum)/@value"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </abatementDateTime>
            </xsl:if>-->

            <!-- Comment (.note) -->
            <xsl:if test="(comment | toelichting)[@value]">
                <note>
                    <text value="{(comment | toelichting)/@value}"/>
                </note>
            </xsl:if>

        </Condition>


    </xsl:template>

    <xd:doc>
        <xd:desc>Template for FHIR profile nl-core-relatedperson-2.0</xd:desc>
        <xd:param name="logicalId">Optional FHIR logical id.</xd:param>
    </xd:doc>
    <xsl:template name="nl-core-relatedperson-2.0" match="(contactpersoon[not(contactpersoon)] | contact[not(contact)])[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" mode="doRelatedPerson">
        <xsl:param name="logicalId" as="xs:string?"/>
        <RelatedPerson>
            <xsl:for-each select="$logicalId">
                <id value="{.}"/>
            </xsl:for-each>
            <meta>
                <profile value="http://fhir.nl/fhir/StructureDefinition/nl-core-relatedperson"/>
            </meta>
            <xsl:for-each select="(rol | role)[@code]">
                <extension url="http://fhir.nl/fhir/StructureDefinition/nl-core-relatedperson-role">
                    <valueCodeableConcept>
                        <xsl:call-template name="code-to-CodeableConcept">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </valueCodeableConcept>
                </extension>
            </xsl:for-each>
            <!-- TODO, use zibroot or input ada-patient -->
            <patient>
                <!-- find the one (! should be only one) patient which has proper data and is not a reference in this ada transaction -->
                <xsl:apply-templates select="./ancestor::*[ancestor::data]//patient[not(patient)][not(@datatype = 'reference')]" mode="doReference">
                    <xsl:with-param name="ResourceType">Patient</xsl:with-param>
                </xsl:apply-templates>
            </patient>

            <xsl:for-each select="(relatie | relationship)[@code]">
                <relationship>
                    <xsl:call-template name="code-to-CodeableConcept">
                        <xsl:with-param name="in" select="."/>
                    </xsl:call-template>
                </relationship>
            </xsl:for-each>

            <xsl:for-each select=".//(naamgegevens[not(naamgegevens)] | name_information[not(name_information)])">
                <xsl:call-template name="nl-core-humanname">
                    <xsl:with-param name="ada-naamgegevens" select="."/>
                    <xsl:with-param name="unstructured-name" select="ongestructureerde_naam/@value"/>
                </xsl:call-template>
            </xsl:for-each>

            <xsl:apply-templates select=".//(contactgegevens[not(contactgegevens)] | contact_information[not(contact_information)])" mode="doContactPoint"/>

            <xsl:apply-templates select=".//(adresgegevens[not(adresgegevens)] | address_information[not(address_information)])" mode="doAddress"/>

        </RelatedPerson>
    </xsl:template>
    <xd:doc>
        <xd:desc>Template for FHIR datatype ContactPoint, context should be ada contactgegevens element</xd:desc>
    </xd:doc>
    <xsl:template name="fhir-contact-point" match="(contactgegevens[not(contactgegevens)] | contact_information[not(contact_information)])[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" mode="doContactPoint">
        <xsl:for-each select="telefoonnummers[.//(@value | @code)]">
            <telecom>
                <system value="phone"/>
                <value value="{telefoonnummer/@value}"/>
                <!-- todo telecomtype, is not part of an MP transaction up until now -->
                <use>
                    <xsl:attribute name="value">
                        <xsl:choose>
                            <xsl:when test="nummer_soort/@code = 'WP'">work</xsl:when>
                            <xsl:when test="nummer_soort/@code = 'HP'">home</xsl:when>
                            <xsl:when test="nummer_soort/@code = 'TMP'">temp</xsl:when>
                            <xsl:otherwise>unsupported nummer_soort/@code: '<xsl:value-of select="nummer_soort/@code"/>'.</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </use>
            </telecom>
        </xsl:for-each>
        <xsl:for-each select="email_adressen[.//(@value | @code)]">
            <telecom>
                <system value="email"/>
                <value value="{email_adres/@value}"/>
                <!-- todo telecomtype, is not part of an MP transaction up until now -->
                <use>
                    <xsl:attribute name="value">
                        <xsl:choose>
                            <xsl:when test="email_soort/@code = 'WP'">work</xsl:when>
                            <xsl:when test="email_soort/@code = 'HP'">home</xsl:when>
                            <xsl:otherwise>unsupported nummer_soort/@code: '<xsl:value-of select="nummer_soort/@code"/>'.</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </use>
            </telecom>
        </xsl:for-each>

    </xsl:template>

    <xd:doc>
        <xd:desc>Helper template to make a reference to given ada subject/resourceType, if that's not present than whatever is specified in hcim rootsubject of the current zib/hcim or if nothing is given it will try and find the patient in the transaction.</xd:desc>
        <xd:param name="adaSubject">Optional ada element which should be in the subject</xd:param>
        <xd:param name="adaSubjectResourceType">The FHIR resource type belonging to the adaSubject. Defaults to Patient.</xd:param>
        <xd:param name="currentHcim">Optional current hcim/zib for which to add a reference based on hcim/zib root (basic elements)</xd:param>
    </xd:doc>
    <xsl:template name="_subjectOrZibrootSubject">
        <xsl:param name="adaSubject" as="element()?"/>
        <xsl:param name="adaSubjectResourceType" as="xs:string?">Patient</xsl:param>
        <xsl:param name="currentHcim" as="element()?"/>
        <!-- The current ada-transaction element for resolving ada elements with datatype reference-->
        <xsl:variable name="currentAdaTransaction" select="./ancestor::*[ancestor::data[ancestor::adaxml]]"/>
        <!-- The zib root subject to be handled, is only evaluated when there is no adaSubject. -->
        <xsl:variable name="hcimrootSubject" select="$currentHcim//(zibroot | hcimroot)/(onderwerp | subject)[*]"/>

        <xsl:choose>
            <xsl:when test="$adaSubject">
                <xsl:apply-templates select="$adaSubject" mode="doReference">
                    <xsl:with-param name="ResourceType" select="$adaSubjectResourceType"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$hcimrootSubject">
                <xsl:apply-templates select="$hcimrootSubject" mode="_doZibRootSubject"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- nothing specified as subject, we should assume the problem is related to the patient which should be found in the current
                            ada transaction.
                            So let's try and find the patient in the transaction this problem should relate to -->
                <xsl:variable name="subject-patient" select="$currentAdaTransaction//patient[not(patient)][not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]"/>
                <xsl:choose>
                    <xsl:when test="$subject-patient">
                        <xsl:apply-templates select="$subject-patient" mode="doReference">
                            <xsl:with-param name="ResourceType">Patient</xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- I give up -->
                        <extension url="http://hl7.org/fhir/StructureDefinition/data-absent-reason">
                            <valueCode value="unknown"/>
                        </extension>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xd:doc>
        <xd:desc>Helper template to make a reference for zibroot/subject. Resolves the ada reference if needed</xd:desc>
    </xd:doc>
    <xsl:template name="_zibRootSubject" match="(onderwerp | subject)[parent::zibroot | parent::hcimroot][*]" mode="_doZibRootSubject">
        <xsl:choose>
            <xsl:when test=".//patient[not(patient)]">
                <xsl:apply-templates select="nff:ada-resolve-reference(.//patient[not(patient)])" mode="doReference">
                    <xsl:with-param name="ResourceType">Patient</xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test=".//contactpersoon">
                <xsl:apply-templates select="nff:ada-resolve-reference(.//contactpersoon)" mode="doReference">
                    <xsl:with-param name="ResourceType">RelatedPerson</xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:desc>Mapping of nl.zorg.Contactpersoon concept in ADA to FHIR resource <xd:a href="https://simplifier.net/search?canonical=http://nictiz.nl/fhir/StructureDefinition/nl-core-relatedperson">nl-core-relatedperson</xd:a>.</xd:desc>
        <xd:param name="logicalId">Optional FHIR logical id for the patient record.</xd:param>
        <xd:param name="patientRef">The patient (subject) reference this person is a contact of, as a map with 'target' and optional 'display' keys.</xd:param>
    </xd:doc>
    <xsl:template name="Contactpersoon" match="contactpersoon | contact" as="element()">
        <xsl:param name="logicalId" as="xs:string?"/>
        <xsl:param name="patientRef" as="map(xs:string, xs:string)"/>

        <RelatedPerson>

            <patient>
                <xsl:call-template name="_Reference">
                    <xsl:with-param name="reference" select="$patientRef"/>
                </xsl:call-template>
            </patient>

        </RelatedPerson>
    </xsl:template>




    <xd:doc>
        <xd:desc>Creates an organization resource as a FHIR entry</xd:desc>
        <xd:param name="uuid">boolean to determine whether to generate a uuid for the fullURL</xd:param>
    </xd:doc>
    <xsl:template name="organization-entry" match="(zorgaanbieder[not(zorgaanbieder)] | healthcare_provider[not(healthcare_provider)])[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" mode="doOrganization">
        <xsl:param name="uuid" as="xs:boolean"/>
        <xsl:variable name="ada-id">
            <xsl:choose>
                <xsl:when test="$uuid or not((zorgaanbieder_identificatie_nummer | zorgaanbieder_identificatienummer)/@value)">
                    <xsl:value-of select="nf:get-fhir-uuid(.)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="nf:getUriFromAdaId(nff:ada-za-id(zorgaanbieder_identificatie_nummer | zorgaanbieder_identificatienummer))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <entry>
            <fullUrl value="{$ada-id}"/>
            <resource>
                <xsl:choose>
                    <xsl:when test="$referById">
                        <xsl:variable name="fhir-resource-id">
                            <xsl:choose>
                                <xsl:when test="$uuid">
                                    <xsl:value-of select="nf:removeSpecialCharacters($ada-id)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="(upper-case(nf:removeSpecialCharacters(string-join(./*/@value, ''))))"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:call-template name="nl-core-organization-2.0">
                            <xsl:with-param name="logicalId" select="$fhir-resource-id"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="nl-core-organization-2.0">
                            <xsl:with-param name="ada-zorgaanbieder" select="."/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </resource>
        </entry>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template name="practitionerRole-entry" match="zorgverlener" mode="doPractitionerRoleEntry">
        <entry>
            <!-- input the node above this node, otherwise the fullUrl / fhir resource id will be identical to that of Practitioner.... -->
            <xsl:variable name="unique-id" select="nf:get-fhir-uuid(./..)"/>
            <fullUrl value="{$unique-id}"/>
            <resource>
                <xsl:choose>
                    <xsl:when test="$referById">
                        <xsl:variable name="fhir-resource-id" select="nf:removeSpecialCharacters($unique-id)"/>
                        <xsl:call-template name="nl-core-practitionerrole-2.0">
                            <xsl:with-param name="ada-zorgverlener" select="."/>
                            <xsl:with-param name="logicalId" select="$fhir-resource-id"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="nl-core-practitionerrole-2.0">
                            <xsl:with-param name="ada-zorgverlener" select="."/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>

            </resource>
        </entry>
    </xsl:template>

    <xd:doc>
        <xd:desc>Creates a FHIR entry for ada problem</xd:desc>
    </xd:doc>
    <xsl:template name="problem-entry" match="(probleem[not(probleem)] | problem[not(problem)][not(@datatype = 'reference')])" mode="doProblemEntry">
        <entry>
            <xsl:variable name="unique-id" select="nf:get-fhir-uuid(.)"/>
            <fullUrl value="{$unique-id}"/>
            <resource>
                <xsl:choose>
                    <xsl:when test="$referById">
                        <xsl:variable name="fhir-resource-id" select="nf:removeSpecialCharacters($unique-id)"/>
                        <xsl:call-template name="zib-Problem-2.1.1">
                            <xsl:with-param name="logicalId" select="$fhir-resource-id"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="zib-Problem-2.1.1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </resource>
        </entry>
    </xsl:template>


    <xd:doc>
        <xd:desc/>
        <xd:param name="uuid"/>
    </xd:doc>
    <xsl:template name="patient-entry" match="patient" mode="doPatientEntry">
        <xsl:param name="uuid" as="xs:boolean"/>

        <!-- For privacy reasons always use UUID as fullUrl for patient -->
        <xsl:variable name="patient-fullUrl" select="nf:get-fhir-uuid(.)"/>
        <entry>
            <fullUrl value="{$patient-fullUrl}"/>
            <resource>
                <xsl:choose>
                    <xsl:when test="$referById">
                        <xsl:variable name="fhir-resource-id">
                            <xsl:choose>
                                <xsl:when test="$uuid">
                                    <xsl:value-of select="nf:removeSpecialCharacters($patient-fullUrl)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="upper-case(nf:removeSpecialCharacters(./naamgegevens/geslachtsnaam/achternaam/@value))"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:call-template name="nl-core-patient-2.0">
                            <xsl:with-param name="logicalId" select="$fhir-resource-id"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="nl-core-patient-2.0"/>
                    </xsl:otherwise>
                </xsl:choose>
            </resource>
        </entry>
    </xsl:template>



    <xd:doc>
        <xd:desc/>
        <xd:param name="uuid"/>
    </xd:doc>
    <xsl:template name="practitioner-entry" match="zorgverlener" mode="doPractitionerEntry">
        <xsl:param name="uuid" as="xs:boolean"/>
        <xsl:variable name="ada-id" select="
                if ($uuid) then
                    nf:get-fhir-uuid(.)
                else
                    if (./(zorgverlener_identificatie_nummer | zorgverlener_identificatienummer)) then
                        nf:getUriFromAdaId(nff:ada-zvl-id(./(zorgverlener_identificatie_nummer | zorgverlener_identificatienummer)))
                    else
                        nf:get-fhir-uuid(.)"/>
        <entry>
            <fullUrl value="{$ada-id}"/>
            <resource>
                <xsl:choose>
                    <xsl:when test="$referById">
                        <xsl:variable name="fhir-resource-id">
                            <xsl:choose>
                                <xsl:when test="$uuid">
                                    <xsl:value-of select="nf:removeSpecialCharacters($ada-id)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="(upper-case(nf:removeSpecialCharacters(string-join(.//*[not(ancestor-or-self::zorgaanbieder)]/@value, ''))))"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:call-template name="nl-core-practitioner-2.0">
                            <xsl:with-param name="ada-zorgverlener" select="."/>
                            <xsl:with-param name="logicalId" select="$fhir-resource-id"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="nl-core-practitioner-2.0">
                            <xsl:with-param name="ada-zorgverlener" select="."/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </resource>
        </entry>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
        <xd:param name="uuid"/>
    </xd:doc>
    <xsl:template name="relatedperson-entry" match="persoon" mode="doRelatedPersonEntry">
        <xsl:param name="uuid" as="xs:boolean"/>
        <xsl:variable name="relatedperson-fullUrl" select="nf:get-fhir-uuid(.)"/>
        <entry>
            <fullUrl value="{$relatedperson-fullUrl}"/>
            <resource>
                <xsl:choose>
                    <xsl:when test="$referById">
                        <xsl:variable name="fhir-resource-id">
                            <xsl:choose>
                                <xsl:when test="$uuid">
                                    <xsl:value-of select="nf:removeSpecialCharacters($relatedperson-fullUrl)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="upper-case(nf:removeSpecialCharacters(string-join(.//(@value | @displayName), '')))"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:call-template name="nl-core-relatedperson-2.0">
                            <xsl:with-param name="logicalId" select="$fhir-resource-id"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="nl-core-relatedperson-2.0"/>
                    </xsl:otherwise>
                </xsl:choose>
            </resource>
        </entry>
    </xsl:template>

    <xd:doc>
        <xd:desc>Resolves the reference in an ada-transaction. Outputs a sequence with the resolved element.</xd:desc>
        <xd:param name="ada-element">The ada element which may need resolving, if not return the element, else the resolved element</xd:param>
    </xd:doc>
    <xsl:function name="nff:ada-resolve-reference" as="element()*">
        <xsl:param name="ada-element" as="element()"/>
        <!-- The current ada-transaction element -->
        <xsl:variable name="currentAdaTransaction" select="$ada-element/ancestor::*[ancestor::data[ancestor::adaxml]]"/>
        <!-- resolve the reference -->
        <xsl:choose>
            <xsl:when test="$ada-element[not(@datatype = 'reference')]">
                <xsl:sequence select="$ada-element"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$currentAdaTransaction//*[@id = $ada-element/@value]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc/>
        <xd:param name="zorgaanbieder-identificatie-nummer"/>
    </xd:doc>
    <xsl:function name="nff:ada-za-id" as="element()?">
        <xsl:param name="zorgaanbieder-identificatie-nummer" as="element()*"/>
        <xsl:sequence select="
                if ($zorgaanbieder-identificatie-nummer[@root = $oidURAOrganizations]) then
                    ($zorgaanbieder-identificatie-nummer[@root = $oidURAOrganizations])
                else
                    (if ($zorgaanbieder-identificatie-nummer[@root = $oidAGB]) then
                        ($zorgaanbieder-identificatie-nummer[@root = $oidAGB])
                    else
                        $zorgaanbieder-identificatie-nummer[1])"/>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="ada-zorgverlener"/>
    </xd:doc>
    <xsl:function name="nff:get-practitioner-role-display" as="xs:string?">
        <xsl:param name="ada-zorgverlener" as="element()?"/>
        <xsl:for-each select="$ada-zorgverlener">
            <xsl:value-of select="normalize-space(concat(string-join((.//naamgegevens[1]//*[not(name() = 'naamgebruik')]/@value), ' '), ' || ', string-join(.//organisatie_naam/@value | .//specialisme/@displayName, ' || ')))"/>
        </xsl:for-each>
    </xsl:function>


    <xd:doc>
        <xd:desc/>
        <xd:param name="zorgverlener-identificatie-nummer"/>
    </xd:doc>
    <xsl:function name="nff:ada-zvl-id" as="element()?">
        <xsl:param name="zorgverlener-identificatie-nummer" as="element()*"/>
        <xsl:sequence select="
                if ($zorgverlener-identificatie-nummer[@root = $oidUZIPersons]) then
                    ($zorgverlener-identificatie-nummer[@root = $oidUZIPersons])
                else
                    (if ($zorgverlener-identificatie-nummer[@root = $oidAGB]) then
                        ($zorgverlener-identificatie-nummer[@root = $oidAGB])
                    else
                        (if ($zorgverlener-identificatie-nummer[@root = $oidBIGregister]) then
                            ($zorgverlener-identificatie-nummer[@root = $oidBIGregister])
                        else
                            $zorgverlener-identificatie-nummer[1]))"/>
    </xsl:function>


    <xd:doc>
        <xd:desc/>
        <xd:param name="resourceType">The type of resource to find, using the variable with common entries</xd:param>
        <xd:param name="group-key">The group key to find the correct instance in the variables with common entries</xd:param>
        <xd:param name="bln-id">In case of $referById determine whether you get the id of or reference to the resource. If false() you get the reference (Patient/XXX_Amaya), if true() you get the id (XXX_Amaya).</xd:param>
        <xd:param name="info">The type if info needed, currently supported: "FullURLorID" of "ReferenceDisplay", defaults to "FullURLorID"</xd:param>
    </xd:doc>
    <xsl:function name="nff:get-resource-info" as="xs:string?">
        <xsl:param name="resourceType" as="xs:string?"/>
        <xsl:param name="group-key" as="xs:string?"/>
        <xsl:param name="bln-id" as="xs:boolean"/>
        <xsl:param name="info" as="xs:string?"/>

        <xsl:variable name="RESOURCETYPE" select="normalize-space(upper-case($resourceType))"/>
        <xsl:variable name="var">
            <xsl:choose>
                <xsl:when test="$RESOURCETYPE = 'PATIENT'">
                    <xsl:copy-of select="$patients"/>
                </xsl:when>
                <xsl:when test="$RESOURCETYPE = 'ORGANIZATION'">
                    <xsl:copy-of select="$organizations"/>
                </xsl:when>
                <xsl:when test="$RESOURCETYPE = 'PRACTITIONER'">
                    <xsl:copy-of select="$practitioners"/>
                </xsl:when>
                <xsl:when test="$RESOURCETYPE = 'PRACTITIONERROLE'">
                    <xsl:copy-of select="$practitionerRoles"/>
                </xsl:when>
                <xsl:when test="$RESOURCETYPE = 'CONDITION'">
                    <xsl:copy-of select="$problems"/>
                </xsl:when>
                <xsl:when test="$RESOURCETYPE = 'RELATEDPERSON'">
                    <xsl:copy-of select="$related-persons"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="normalize-space(upper-case($info)) = 'REFERENCEDISPLAY'">
                <xsl:value-of select="$var[.//group-key/text() = $group-key]//reference-display/text()"/>
            </xsl:when>
            <xsl:when test="normalize-space(upper-case($info)) = 'FULLURLORID' or not($info)">
                <xsl:choose>
                    <xsl:when test="$referById = true()">
                        <xsl:variable name="resource" select="$var/*[.//group-key/text() = $group-key]//*[f:id]"/>
                        <xsl:choose>
                            <xsl:when test="$bln-id">
                                <xsl:value-of select="$resource/f:id/@value"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat($resource/local-name(), '/', $resource/f:id/@value)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$var/*[.//group-key/text() = $group-key]//f:entry/f:fullUrl/@value"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc/>
        <xd:param name="in"/>
    </xd:doc>
    <xsl:function name="nff:get-grouping-key-default" as="xs:string?">
        <xsl:param name="in" as="element()?"/>
        <xsl:value-of select="normalize-space(upper-case(concat(string-join($in//@value, ''), string-join($in//@root, ''), string-join($in//@code, ''), string-join($in//@codeSystem, ''), string-join($in//@nullFlavor, ''))))"/>
    </xsl:function>

    <xd:doc>
        <xd:desc/>
        <xd:param name="zorgverlener"/>
    </xd:doc>
    <xsl:function name="nff:get-grouping-key-practitioner" as="xs:string?">
        <xsl:param name="zorgverlener" as="element()?"/>
        <xsl:value-of select="concat(nff:get-grouping-key-default($zorgverlener/(zorgverlener_identificatie_nummer | zorgverlener_identificatienummer)), nff:get-grouping-key-default($zorgverlener/(zorgverlener_naam | naamgegevens)), nff:get-grouping-key-default($zorgverlener/adres), nff:get-grouping-key-default($zorgverlener/telefoon_email))"/>
    </xsl:function>





</xsl:stylesheet>
