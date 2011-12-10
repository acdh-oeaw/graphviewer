<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:my="myFunctions"
    version="2.0">
 
<!-- the stylesheet for the operation mode:
    uses the prepared map to resolve terms to other terms, or list available terms. 
-->
 <xsl:include href="smc_commons.xsl"/>
    
<xsl:output indent="yes"></xsl:output>  
    
<!-- user input-params -->    
 <xsl:param name="context">*</xsl:param>
 <xsl:param name="term"></xsl:param>
 <xsl:param name="lang">pt</xsl:param>
    
    
 <xsl:template match="/">
     <xsl:choose>   
     		<xsl:when test="not($term='')">
     		    <Terms>
                 <xsl:variable name="matching_concepts" select="$dcr-cmd-map//Concept[Term=$term]"></xsl:variable>
	             <xsl:for-each select="$matching_concepts//Term[@set='cmd']">
	                 <xsl:copy-of select="." />;                     
	             </xsl:for-each>
     		    </Terms>
         </xsl:when>  
     <!-- if $set=*, list all termsets -->
         <xsl:when test="$context='*' or $context='top'">
                <xsl:copy-of select="my:getData('termsets')"></xsl:copy-of>             
         </xsl:when>
             <!-- if $term=*, list all terms -->         
         <xsl:when test="$term='*'">
             <Termset set="{$context}" xml:lang="{$lang}">
              <xsl:for-each  select="$dcr-cmd-map//Term[@set=$context and @xml:lang=$lang]" >
                  <xsl:copy-of select="." />
              </xsl:for-each>
             </Termset>
         </xsl:when>
         <xsl:otherwise>
             <xsl:variable name="matching_concepts" select="$dcr-cmd-map//Concept[Term=$term]"></xsl:variable>
             <xsl:for-each select="$matching_concepts//Term[@set='cmd']">
                 <xsl:value-of select="." />;                     
             </xsl:for-each>
         </xsl:otherwise>
     </xsl:choose>     
     
 </xsl:template>
    
</xsl:stylesheet>