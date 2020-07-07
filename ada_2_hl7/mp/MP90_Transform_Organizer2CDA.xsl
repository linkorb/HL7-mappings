<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xd nf xsl" xmlns="urn:hl7-org:v3" xmlns:nf="http://www.nictiz.nl/functions" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- param to influence whether to output schematron references, typically only needed for test instances -->
    <xsl:param name="schematronRef" as="xs:boolean" select="false()"/>


    <xd:doc>
        <xd:desc> Transforms HL7 organizer example message into CDA version of the same thing. For publication 9.0.6 </xd:desc>
    </xd:doc>
    <xsl:template match="hl7:organizer">
        <ClinicalDocument xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sdtc="urn:hl7-org:sdtc" xmlns="urn:hl7-org:v3" xmlns:hl7nl="urn:hl7-nl:v3" xmlns:pharm="urn:ihe:pharm:medication">
            <xsl:if test="$schematronRef">
                <xsl:attribute name="xsi:schemaLocation">urn:hl7-org:v3 file:/C:/SVN/AORTA/branches/Onderhoud_Mp_v90/XML/schemas/CDANL_extended.xsd</xsl:attribute>
            </xsl:if>
            <realmCode code="NL"/>
            <typeId extension="POCD_HD000040" root="2.16.840.1.113883.1.3"/>
            <!-- select the correct templateId -->
            <templateId>
                <xsl:attribute name="root">
                    <xsl:choose>
                        <!-- Medicatiegegevens -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9104'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9133'"/>
                        </xsl:when>
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9192'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9197'"/>
                        </xsl:when>
                        <!-- 9.0.6 -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9221'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9222'"/>
                        </xsl:when>
                        <!-- 9.0.7 -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9239'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9236'"/>
                        </xsl:when>
                        <!-- 9.1.0 -->
                        <xsl:when test="hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9284'">2.16.840.1.113883.2.4.3.11.60.20.77.10.9283</xsl:when>

                        <!-- Afhandeling Voorschrift -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9124'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9136'"/>
                        </xsl:when>
                        <!-- 9.0.6 -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9228'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9229'"/>
                        </xsl:when>
                        <!-- 9.0.7 -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9260'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9261'"/>
                        </xsl:when>
                        <!-- 9.1.0 -->
                        <xsl:when test="hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9295'">2.16.840.1.113883.2.4.3.11.60.20.77.10.9296</xsl:when>

                        <!-- Medicatiegebruik -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9125'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9138'"/>
                        </xsl:when>
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9191'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9198'"/>
                        </xsl:when>
                        <!-- 9.0.6 -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9225'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9227'"/>
                        </xsl:when>
                        <!-- 9.0.7 -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9252'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9249'"/>
                        </xsl:when>
                        <!-- 9.1.0 -->
                        <xsl:when test="hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9290'">2.16.840.1.113883.2.4.3.11.60.20.77.10.9291</xsl:when>

                        <!-- Medicatieoverzicht -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9132'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9146'"/>
                        </xsl:when>
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9193'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9199'"/>
                        </xsl:when>
                        <!-- 9.0.6 -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9204'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9207'"/>
                        </xsl:when>
                        <!-- 9.0.7 -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9245'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9243'"/>
                        </xsl:when>
                        <!-- 9.1.0 -->
                        <xsl:when test="hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9286'">2.16.840.1.113883.2.4.3.11.60.20.77.10.9288</xsl:when>

                        <!-- Voorschrift -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9126'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9140'"/>
                        </xsl:when>
                        <!-- 9.0.6 -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9217'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9219'"/>
                        </xsl:when>
                        <!-- 9.0.7 -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9240'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9237'"/>
                        </xsl:when>
                        <!-- 9.1.0 -->
                        <xsl:when test="hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9272'">2.16.840.1.113883.2.4.3.11.60.20.77.10.9273</xsl:when>

                        <!-- Voorstel MA -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9127'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9142'"/>
                        </xsl:when>

                        <!-- Voorstel VV -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9130'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9144'"/>
                        </xsl:when>

                        <!-- Antwoord VVV -->
                        <xsl:when test="./hl7:templateId[last()]/@root = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9211'">
                            <xsl:value-of select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9215'"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
            </templateId>
            <id extension="someUniqueID">
                <!-- Use the template id to make a unique root for document id -->
                <xsl:attribute name="root">
                    <xsl:value-of select="concat(./hl7:templateId[1]/@root, '.1.2.3.999')"/>
                </xsl:attribute>
            </id>
            <!-- This is from 9.0.6 onwards, and not compatible with 9.0.5 -->
            <code code="52981000146104" codeSystem="2.16.840.1.113883.6.96" codeSystemName="SNOMED CT" displayName="Medication section (record artifact)"/>
            <!-- parameterize the title based on input, this is not perfect -->
            <xsl:variable name="hl7Docdate" as="xs:string?">
                <xsl:choose>
                    <!-- for medicatieoverzicht there will be an organizer/effectiveTime, but not for medicatievoorschrift -->
                    <xsl:when test="hl7:effectiveTime[@value]">
                        <xsl:value-of select="@value"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- use the max (most recent) author time we find -->
                        <xsl:value-of select="xs:string(xs:integer(max(hl7:component/*/hl7:author/hl7:time/@value)))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!-- append if needed -->
            <xsl:variable name="hl7DocdateApptime">
                <xsl:choose>
                    <xsl:when test="string-length($hl7Docdate) = 0">
                        <xsl:value-of select="$hl7Docdate"/>
                    </xsl:when>
                    <xsl:when test="string-length($hl7Docdate) lt 14">
                        <xsl:value-of select="concat($hl7Docdate, substring('000000', string-length($hl7Docdate) - 7))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$hl7Docdate"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="docdatum">
                <xsl:choose>
                    <xsl:when test="string-length($hl7DocdateApptime) gt 0">
                        <xsl:variable name="docdate" select="nf:formatHL72XMLDate($hl7DocdateApptime, 'second')"/>
                        <xsl:value-of select="nf:formatDate($docdate)"/>
                    </xsl:when>
                    <xsl:otherwise>onbekende datum</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <title>
                <xsl:variable name="naamPatient">
                    <xsl:value-of select="./hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:name[1]/hl7:given[1]"/>
                    <xsl:value-of select="concat(' ', ./hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:name[1]/hl7:prefix[1])"/>
                    <xsl:value-of select="concat(' ', ./hl7:recordTarget/hl7:patientRole/hl7:patient/hl7:name[1]/hl7:family[1])"/>
                </xsl:variable>
                <xsl:variable name="transactienaam" select="./hl7:code/@displayName"/>
                <xsl:value-of select="concat($transactienaam, ' ', normalize-space($naamPatient), ' op ', $docdatum)"/>
            </title>
            <!-- time is mandatory in CDA, so we take the time appended variable here -->
            <effectiveTime value="{$hl7DocdateApptime}"/>
            <confidentialityCode code="N" codeSystem="2.16.840.1.113883.5.25" displayName="normal"/>
            <languageCode code="nl-NL"/>
            <xsl:copy-of select="./hl7:recordTarget" copy-namespaces="no"/>

            <!-- author -->
            <xsl:variable name="cdaAuthor" as="element()?">
                <xsl:choose>
                    <!-- organizer author, should be present in transaction medicatieoverzicht -->
                    <xsl:when test="hl7:author">
                        <xsl:copy-of select="hl7:author" copy-namespaces="no"/>
                    </xsl:when>
                    <!-- use the author of verstrekkingsverzoek (if present) for transaction voorschrift -->
                    <xsl:when test=".[hl7:code[@code = '95' and @codeSystem = '2.16.840.1.113883.2.4.3.11.60.20.77.4']]/hl7:component/hl7:supply">
                        <xsl:variable name="vvAuthor" select="hl7:component/hl7:supply[hl7:code[@code = '52711000146108'][@codeSystem = '2.16.840.1.113883.6.96']]/hl7:author"/>
                        <xsl:copy-of select="($vvAuthor[hl7:time[@value = $vvAuthor/hl7:time/xs:integer(max(@value))]])[1]" copy-namespaces="no"/>
                    </xsl:when>
                    <!-- otherwise use the author of most recent medicatieafspraak for transaction voorschrift -->
                    <xsl:when test=".[hl7:code[@code = '95' and @codeSystem = '2.16.840.1.113883.2.4.3.11.60.20.77.4']]">
                        <xsl:variable name="maAuthor" select="hl7:component/hl7:substanceAdministration[hl7:code[@code = '16076005'][@codeSystem = '2.16.840.1.113883.6.96']]/hl7:author"/>
                        <xsl:copy-of select="($maAuthor[hl7:time[@value = $maAuthor/hl7:time/xs:integer(max(@value))]])[1]" copy-namespaces="no"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- don't know which author to use, CDA still requires one, let's use the first author we encounter -->
                        <xsl:copy-of select="(hl7:component/*/hl7:author)[1]" copy-namespaces="no"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:copy-of select="$cdaAuthor" copy-namespaces="no"/>
            <!-- custodian, the organization of the author -->
            <custodian>
                <assignedCustodian>
                    <representedCustodianOrganization>
                        <xsl:copy-of select="$cdaAuthor/hl7:assignedAuthor/hl7:representedOrganization/*" copy-namespaces="no"/>
                    </representedCustodianOrganization>
                </assignedCustodian>
            </custodian>
            <xsl:for-each select="hl7:participant">
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:for-each>
            <component>
                <structuredBody>
                    <component>
                        <section>
                            <text>Medicatiegegevens.</text>
                            <xsl:apply-templates select="comment() | hl7:component"/>
                        </section>
                    </component>
                </structuredBody>
            </component>
        </ClinicalDocument>
    </xsl:template>


    <xd:doc>
        <xd:desc> Niet kopiëren </xd:desc>
    </xd:doc>
    <xsl:template match="hl7:organizer/hl7:templateId | hl7:organizer/hl7:code | hl7:organizer/hl7:statusCode | hl7:organizer/hl7:recordTarget | hl7:organizer/hl7:author"/>


    <xd:doc>
        <xd:desc> participantRole element hernomen naar associatedEntity in CDA participant </xd:desc>
    </xd:doc>
    <xsl:template match="hl7:organizer/hl7:participant/hl7:participantRole">
        <xsl:element name="associatedEntity">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>


    <xd:doc>
        <xd:desc> template id conversies (voor participant) </xd:desc>
    </xd:doc>
    <xsl:template match="hl7:templateId/@root[. = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9179']">
        <xsl:attribute name="root" select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9173'"/>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="hl7:templateId/@root[. = '2.16.840.1.113883.2.4.3.11.60.20.77.10.9180']">
        <xsl:attribute name="root" select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9174'"/>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="hl7:organizer/hl7:component">
        <entry xmlns="urn:hl7-org:v3">
            <xsl:apply-templates select="* | node()"/>
        </entry>
    </xsl:template>


    <xd:doc>
        <xd:desc>format HL7 2 XMLDate</xd:desc>
        <xd:param name="dateTime">input hl7 date as string</xd:param>
        <xd:param name="precision">precision for output</xd:param>
    </xd:doc>
    <xsl:function name="nf:formatHL72XMLDate">
        <xsl:param name="dateTime" as="xs:string?"/>
        <!-- precision determines the picture of the date format, currently only use case for day or second. -->
        <xsl:param name="precision" as="xs:string?"/>
        <xsl:variable name="xml-date" select="
                xs:date(concat(
                substring($dateTime, 1, 4), '-',
                substring($dateTime, 5, 2), '-',
                substring($dateTime, 7, 2)))"/>
        <xsl:choose>
            <xsl:when test="upper-case($precision) = ('DAY', 'DAG', 'DAYS', 'DAGEN', 'D')">
                <xsl:value-of select="$xml-date"/>
            </xsl:when>
            <xsl:when test="upper-case($precision) = ('SECOND', 'SECONDE', 'SECONDS', 'SECONDEN', 'SEC', 'S') and string-length($dateTime) >= 14">
                <xsl:value-of select="
                        xs:dateTime(concat(
                        substring($dateTime, 1, 4), '-',
                        substring($dateTime, 5, 2), '-',
                        substring($dateTime, 7, 2), 'T',
                        substring($dateTime, 9, 2), ':',
                        substring($dateTime, 11, 2), ':',
                        substring($dateTime, 13, 2)))"/>
            </xsl:when>
            <xsl:when test="upper-case($precision) = ('SECOND', 'SECONDE', 'SECONDS', 'SECONDEN', 'SEC', 'S') and string-length($dateTime) &lt; 14">
                <!-- asked for seconds, but input is smaller than seconds, just return date -->
                <xsl:value-of select="$xml-date"/>
            </xsl:when>
            <xsl:otherwise>Could not determine xml date from input: '<xsl:value-of select="$dateTime"/>' with precision: '<xsl:value-of select="$precision"/>'.</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc>Takes an xml inputdate(time) as a string in inputDate and outputs the date in format '3 jun 2018'</xd:desc>
        <xd:param name="inputDate"/>
    </xd:doc>
    <xsl:function name="nf:formatDate" as="xs:string?">
        <xsl:param name="inputDate" as="xs:string?"/>
        <xsl:variable name="date" select="
                if ($inputDate) then
                    substring($inputDate, 1, 10)
                else
                    ()"/>
        <xsl:if test="$date castable as xs:date">
            <xsl:value-of select="replace(format-date(xs:date($date), '[D] [Mn,*-3] [Y]'), 'maa', 'mrt')"/>
        </xsl:if>
    </xsl:function>

    <xd:doc>
        <xd:desc>Default copy template</xd:desc>
    </xd:doc>
    <xsl:template match="@* | node()">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>