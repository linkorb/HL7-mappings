<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" name="lsp-hl72fhir" version="1" xmlns:foo="dummy" xmlns:f="http://hl7.org/fhir">
    
    <p:input port="source" primary="true" sequence="false">
        <p:document href="../hl7_2_ada/mp/6.12.9/opleveren_verstrekkingenlijst/hl7_instance/QURX_EX990113NL_01.xml"/>
    </p:input>
    
    <p:output port="result" sequence="true">
        <p:pipe step="last-step" port="result"/>
    </p:output>
    
    <p:xslt name="hl72ada" >
        <p:input port="stylesheet">
            <p:document href="../hl7_2_ada/mp/6.12.9/opleveren_verstrekkingenlijst/payload/opleveren_verstrekkingenlijst_612_to_ada_vv.xsl"/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="ada2fhir">
        <p:input port="stylesheet">
            <p:document href="../ada_2_fhir/mp/9.0.7/beschikbaarstellen_verstrekkingenvertaling/payload/beschikbaarstellen_verstrekkingenvertaling_2_fhir.xsl"/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="operationoutcome">
        <p:input port="source">
            <p:pipe port="source" step="lsp-hl72fhir"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../lsp/BATCH_LSP_to_FHIR_OperationOutcome_xproc.xsl"/>
        </p:input>
    </p:xslt>
    
    <p:choose>
        <p:when test="/foo:Dummy/f:entry">
            <p:insert position="last-child" match="/f:Bundle">
                <p:input port="insertion">
                    <p:pipe port="result" step="operationoutcome"/>
                </p:input>
                <p:input port="source">
                    <p:pipe port="result" step="ada2fhir"/>
                </p:input>
            </p:insert>
            <p:uuid match="/f:Bundle/foo:Dummy/f:entry/f:fullUrl/@value"/>
            <p:unwrap match="/f:Bundle/foo:Dummy"/>
        </p:when>
    </p:choose>
    
    <p:store href="result.xml" indent="true" method="xml" name="last-step"/>
    
</p:declare-step>
