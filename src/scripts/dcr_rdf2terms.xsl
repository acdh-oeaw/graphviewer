<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"      
  xmlns:dcr="http://www.isocat.org/ns/dcr.rdf#"   
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  exclude-result-prefixes="dcr rdf rdfs"
>
<!-- 
<purpose> 
handle all rdf DCRs (currently isocat, dublincore elements and terms)
</purpose>
<strategy>map from rdf to Terms </strategy>
<params>
<param name=""></param>
</params>
<history>
	<change on="2010-10-10" type="created" by="vr"></change>
	<change on="2011-10-26" type="changed" by="vr">reworking for SMC</change>
</history>
-->

<xsl:output method="xml" indent="yes" > </xsl:output>

	<xsl:param name="isocat_prefix" select="'http://www.isocat.org/datcat/'"></xsl:param>

 <!--
   	decide based on the inner-structure, what it is and how to handle
   	-->
<xsl:template match="*" mode="dcr">
	<xsl:param name="set" />
	
	<Termset set="{$set}">
		<xsl:apply-templates select="/rdf:RDF/rdf:Description | /rdf:RDF/rdf:Property ">
			<xsl:with-param name="set" select="$set" />
		</xsl:apply-templates>
	</Termset>
</xsl:template>

	<!-- isocat.rdf -->
<xsl:template match="rdf:Description[@rdf:ID]" >
	<xsl:param name="set" />
	
	<Concept type="datcat" id="{dcr:datcat}">
		<Term set="{$set}" type="mnemonic" >			 
			<xsl:value-of select="@rdf:ID" />
		</Term>
		<Term set="{$set}" type="id" >			 
			<xsl:value-of select="substring-after(dcr:datcat,$isocat_prefix)" />
		</Term>
		<xsl:for-each select="rdfs:label" >
			<Term set="{$set}" type="label" xml:lang="{./@xml:lang}">			 
				<xsl:value-of select="." />
			</Term>
		</xsl:for-each>
		<xsl:for-each select="rdfs:comment" >
			<info>
				<xsl:copy-of select="./@xml:lang"/>
				<xsl:value-of select="." />
			</info>	
		</xsl:for-each>				
<!--		<xsl:copy-of select="rdfs:comment|rdfs:label"></xsl:copy-of>-->
	</Concept>
</xsl:template>

<!-- dublincore elements | terms  -->
	<xsl:template match="rdf:Property|rdf:Description[@rdf:about]" >
	<xsl:param name="set" />
	<Concept type="datcat" id="{@rdf:about}">		
		<Term set="{$set}" type="label" >
			<xsl:value-of select="rdfs:label" /><!-- discard the xml:lang-attribute of rdfs:label (en-US) -->			
		</Term>
		<xsl:for-each select="rdfs:comment" >
			<info>
				<xsl:copy-of select="./@xml:lang"/>
				<xsl:value-of select="." />
			</info>	
		</xsl:for-each>
	</Concept>
</xsl:template>
	
</xsl:stylesheet>
