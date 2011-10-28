<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
 
<!-- the stylesheet for the operation mode:
    uses the prepared map to resolve terms to other terms, or list available terms. 
-->
 <xsl:include href="smc_commons.xsl"/>
    
<xsl:output indent="yes"></xsl:output>  
    
<!-- user input-params -->    
 <xsl:param name="set">isocat</xsl:param>
 <xsl:param name="term"></xsl:param>
 <xsl:param name="lang">pt</xsl:param>
    
    
 <xsl:template match="/">
     <xsl:choose>
         <!-- if $term=*, list all terms -->
         <xsl:when test="$term='*'">
             <Termset set="{$set}" xml:lang="{$lang}">
              <xsl:for-each  select="$map//Term[@set=$set and @xml:lang=$lang]" >
                  <xsl:copy-of select="." />
              </xsl:for-each>
             </Termset>
         </xsl:when>
         <xsl:otherwise>
             <xsl:variable name="matching_concepts" select="$map//Concept[Term=$term]"></xsl:variable>
             <xsl:for-each select="$matching_concepts//Term[@set='cmd']">
                 <xsl:value-of select="." />;                     
             </xsl:for-each>
         </xsl:otherwise>
     </xsl:choose>
     
     
 </xsl:template>
    
</xsl:stylesheet>