<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:my="myFunctions"
  xmlns:dcif="http://www.isocat.org/ns/dcif"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"   
  xmlns:owl="http://www.w3.org/2002/07/owl#"
  xmlns:dcr="http://www.isocat.org/ns/dcr.rdf#"
  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
  xmlns:dcam="http://purl.org/dc/dcam/"
  exclude-result-prefixes=""
>
<!-- 
<purpose> starting script for SemanticMapping components

generate lists for Terms (CMDI-Elements, CMDI-components, Datcats)
 based on the Components-list (provided by CompReg).
		strategy:  regard CMD_Component, CMd_Element, ConceptLink</purpose>
<params>
<param name="isocat_file">the DCIF-Metadata-Profile</param>
</params>
<history>
	<change on="2011-10-20" type="created" by="vr">from complist2terms_201109.xsl</change>	
</history>
-->

<xsl:include href="smc_commons.xsl"/>
	
<xsl:output method="xml" indent="yes" />
	
<xsl:param name="operation" select="'no-op'" /> <!-- cmd-profiles-raw , cmd-resolved, cmd-terms, dcr-terms, dcr-cmd-map -->	

<xsl:template match="/" >
	<xsl:choose>
		<xsl:when test="$operation='cmd-profiles-raw'">
			<xsl:copy-of select="$cmd_profiles"></xsl:copy-of>			
		</xsl:when>
		<xsl:when test="$operation='cmd-resolved'">
			<xsl:copy-of select="$cmd_resolved"></xsl:copy-of>			
		</xsl:when>
		<xsl:when test="$operation='cmd-terms'">
			<xsl:copy-of select="$cmd_terms"></xsl:copy-of>			
		</xsl:when>
		<xsl:when test="$operation='dcr-terms'">
			<xsl:copy-of  select="$dcr_terms" />								
		</xsl:when>		
		<xsl:when test="$operation='dcr-cmd-map'">
			<xsl:call-template name="dcr-cmd-map" />
		</xsl:when>		
		
		<xsl:otherwise>			
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>			
	
<!--
	invert the profiles-termsets = create map datcat -> cmd-elements[] 
-->	
<xsl:template name="dcr-cmd-map">
	<Termset type="dcr-cmd-map" >	
	<xsl:for-each-group select="$cmd_terms//Term[not(@datcat='')]" group-by="@datcat">
		<Concept id="{@datcat}" type="datcat">
			<xsl:copy-of select="$dcr_terms//Concept[@id=current()/@datcat]/Term" />
			
			<xsl:for-each select="current-group()">
				<Term set="cmd" type="full-path" id="{@id}"><xsl:value-of select="@context" /></Term>
				<!--<xsl:copy-of select="."></xsl:copy-of>-->
			</xsl:for-each>
		</Concept>				
	</xsl:for-each-group>
	</Termset>
</xsl:template>			

</xsl:stylesheet>