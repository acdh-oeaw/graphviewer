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
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="my xd"
 >
 
 <xd:doc scope="stylesheet">
  <xd:p><xd:b>Created on:</xd:b> Sep 4, 2012</xd:p>
  <xd:p><xd:b>Author:</xd:b> m</xd:p>
  <xd:desc>
   <xd:p>starting script for SemanticMapping components.</xd:p>
   <xd:p>generate lists for Terms (CMDI-Elements, CMDI-components, Datcats)
    based on the Components-list (provided by CompReg).</xd:p>
   <xd:p>strategy:  regard CMD_Component, CMd_Element, ConceptLink</xd:p>   
  </xd:desc>
  <!-- <xd:param name="isocat_file">
   <xd:p>String to be analyzed</xd:p>
   </xd:param> 
   <xd:return>
   <xd:p>A substring starting from the beginning of <xd:i>string</xd:i> to the last
   occurrence of <xd:i>searched</xd:i>. If no occurrence is found an empty string will be
   returned.</xd:p>
   </xd:return>-->
 </xd:doc>
<xsl:include href="smc_commons.xsl"/>
	
 <xd:doc>
  <xd:desc>
   <xd:p></xd:p>
  </xd:desc>
 </xd:doc>
<xsl:output method="xml" indent="yes" exclude-result-prefixes="#all" />


 <xd:doc>
  <xd:desc>
   <xd:p></xd:p>
  </xd:desc>
 </xd:doc>
<xsl:template match="/" > 
 <xsl:copy-of select="my:getData($data_key,$cache)" exclude-result-prefixes="my"></xsl:copy-of>
</xsl:template>			
	 

</xsl:stylesheet>