<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:my="myFunctions"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:include href="smc_params.xsl"/>
    <xsl:include href="smc_functions.xsl"/>
    <xsl:include href="cmd_includes.xsl"/>    
    <xsl:include href="dcr_rdf2terms.xsl"/>
    
    <!-- use either input (precedence) or the config-file as the termsets configuration -->
    <xsl:variable name="termsets_config">
        <xsl:choose>
            <xsl:when test="exists(/Termsets)">
                <xsl:copy-of select="/Termsets"></xsl:copy-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="document($termset_config_file)"></xsl:copy-of>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:variable>
    
    <xsl:variable name="cmd_profiles_uri" select="my:config('cmd-profiles','url')" />
    <xsl:variable name="cmd_components_uri" select="my:config('cmd-components','url')" />
    <xsl:variable name="cmd_profiles" select="document(my:config('cmd-profiles','url'))" />
    <xsl:variable name="cmd_resolved" >        
        <xsl:apply-templates select="$cmd_profiles" mode="include" />
    </xsl:variable>
    <xsl:variable name="cmd_terms" select="my:profiles2termsets($cmd_resolved//profileDescription)" />	
    
    <xsl:variable name="dcr_terms" >
        <xsl:call-template name="load-dcr" />            
    </xsl:variable>
    
    <!--<xsl:variable name="concepts_nolang" 
        select="//@ConceptLink[not(starts-with(.,'http://cdb.iso.org/lg/'))]" />
    -->
    
    <xsl:variable name="map" select="document($map_file)" />
    
<!-- load all dcrs from the configuration and transform them into Termsets  
    (call appropriate included templates using the format-property of the dcr as mode)
   -->
    <xsl:template name="load-dcr">
        <Termsets type="dcr">
          <xsl:for-each select="$termsets_config//*[type='dcr']" >
              <xsl:variable name="dcr_termset" select="document(url)" />            
                  <xsl:apply-templates select="$dcr_termset" mode="dcr" >
                      <xsl:with-param name="set" select="id"></xsl:with-param>
                  </xsl:apply-templates>
              
          </xsl:for-each>
        </Termsets>
    </xsl:template>

<!--
    return a property of a Termset from the configuration.
-->    
    <xsl:function name="my:config">
        <xsl:param name="id"></xsl:param>
        <xsl:param name="property"></xsl:param>
        <xsl:value-of select="$termsets_config//*[id=$id]/*[name()=$property]"></xsl:value-of>
    </xsl:function>
    
    
</xsl:stylesheet>