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
  <xsl:param name="operation">list</xsl:param> <!-- list | map --> 
 <xsl:param name="context">*</xsl:param>
 <xsl:param name="term"></xsl:param>
 <!--<xsl:param name="lang">pt</xsl:param>-->
    
    
 <xsl:template match="/">
     <xsl:choose>   
     		<xsl:when test="$operation='map'">
     		    <Terms>
                 <xsl:variable name="matching_concepts" select="$dcr-cmd-map//Concept[Term=$term]"></xsl:variable>
	             <xsl:for-each select="$matching_concepts//Term[@set='cmd']">
	                 <xsl:copy-of select="." />                  
	             </xsl:for-each>
     		    </Terms>
     		</xsl:when>  
            <xsl:when test="$operation='list' and $context='*' or $context='top'">
                 <xsl:copy-of select="my:getData('termsets')"></xsl:copy-of>             
             </xsl:when>
          <!-- list all terms of given context-->         
         <xsl:when test="$operation='list'">
             <!--separate handling for isocat, because of lang -->
                <xsl:choose>
                    <xsl:when test="starts-with($context, 'isocat')">
                        <xsl:variable name="lang" select="if(starts-with($context, 'isocat')) then substring-after($context, 'isocat-') else 'en'"></xsl:variable>
                        <Termset set="{$context}" xml:lang="{$lang}">                            
                            <xsl:for-each  select="$dcr-cmd-map//Term[@set='isocat' and @xml:lang=$lang]" >
                                <xsl:copy >
                                    <xsl:copy-of select="@*" />
                                    <xsl:attribute name="concept-id" select="ancestor::Concept/@id"></xsl:attribute>
                                    <xsl:copy-of select="." />
                                </xsl:copy>
                            </xsl:for-each>
                        </Termset>
                    </xsl:when>
                    <xsl:otherwise>
                        <Termset set="{$context}" >                            
                            <xsl:for-each  select="$dcr-cmd-map//Term[@set=$context]" >
                                <xsl:copy >
                                    <xsl:copy-of select="@*" />
                                    <xsl:attribute name="concept-id" select="ancestor::Concept/@id"></xsl:attribute>
                                    <xsl:copy-of select="." />
                                </xsl:copy>
                                
                            </xsl:for-each>
                        </Termset>
                    </xsl:otherwise>                    
                </xsl:choose>
                
         </xsl:when>
         <xsl:otherwise>
             <diagnostics>unknown operation: <xsl:value-of select="$operation"></xsl:value-of></diagnostics>
         </xsl:otherwise>     
     </xsl:choose>     
     
 </xsl:template>
    
</xsl:stylesheet>