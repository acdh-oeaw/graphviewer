<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:my="myFunctions" exclude-result-prefixes="xs my" version="2.0">
    
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
    
<!--    needed in cmd_includes.xsl --> 
   <xsl:variable name="cmd_components_uri" select="my:config('cmd-components','url')" />
   <xsl:variable name="cmd_profiles_uri" select="my:config('cmd-profiles','url')" />
    
<!-- intermediate datasets bound into variables,to prevent calling the function every time -->
   <xsl:variable name="dcr-terms" select="my:getData('dcr-terms')" />
   <xsl:variable name="cmd-terms" select="my:getData('cmd-terms')" />
   <xsl:variable name="dcr-cmd-map" select="my:getData('dcr-cmd-map')" />
   <xsl:variable name="isocat-languages" select="my:getData('isocat-languages')" />
    
 <!-- serves individual datasets (cmd-profiles, dcr-termsets...)
        primitive cache mechanism - 
        if data of given key is already stored, serve it, 
        otherwise build a new (but don't store in cache - within this function)
        regard the cache-param - beware of the param-value in recursive calls (currently 'use' is fixed for deeper calls)     -->
  <xsl:function name="my:getData">
        <xsl:param name="key"></xsl:param>
        <xsl:param name="cache"></xsl:param>
        
        <xsl:variable name="cached_data_file" select="concat($cache_dir, $key, '.xml')"></xsl:variable>
        <xsl:message>
            cache: <xsl:value-of select="$cache" />
            <xsl:value-of select="$cached_data_file" />: <xsl:value-of select="doc-available($cached_data_file)" />
        </xsl:message>
        <xsl:choose>
            <xsl:when test="doc-available($cached_data_file) and $cache='use'">
                <xsl:message>reading in: <xsl:value-of select="$cached_data_file" />                    
                </xsl:message>
                <xsl:copy-of select="document($cached_data_file)"></xsl:copy-of>
            </xsl:when>
            <xsl:when test="$key='cmd-profiles-raw'">
                <xsl:copy-of select="document(my:config('cmd-profiles','url'))" />                
            </xsl:when>
            <xsl:when test="$key='cmd-resolved'">
                <xsl:apply-templates select="my:getData('cmd-profiles-raw')" mode="include" />                
            </xsl:when>
            <xsl:when test="$key='cmd-terms'">
                <xsl:copy-of select="my:profiles2termsets(my:getData('cmd-resolved')//profileDescription)" />
            </xsl:when>
            <xsl:when test="$key='dcr-terms'">
                <xsl:call-template name="load-dcr" />								
            </xsl:when>
            <xsl:when test="$key='termsets'">
                <xsl:call-template name="termsets" />								
            </xsl:when>
            <xsl:when test="$key='isocat-languages'">
                <xsl:copy-of select="document(my:config('isocat-languages','url'))" />								
            </xsl:when>
            <xsl:when test="$key='dcr-cmd-map'">
                <xsl:call-template name="dcr-cmd-map" />
            </xsl:when>
            <!-- for debugging -->
            <xsl:when test="$key='termsets-config'">
                <xsl:copy-of select="$termsets_config" />								
            </xsl:when>
            <xsl:otherwise>	
                <diagnostics>unknown data: <xsl:value-of select="$key" /></diagnostics>
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:function>
    
    <!-- overload method with one param and value of global cache-param as default -->    
    <xsl:function name="my:getData">
        <xsl:param name="key"></xsl:param>
        <xsl:copy-of select="my:getData($key,$cache)"></xsl:copy-of>
    </xsl:function>
    
<!-- load all dcrs from the configuration and transform them into Termsets
       (uses mode=dcr-templates in dcr_rdf2terms.xsl)       -->
    <xsl:template name="load-dcr">
        <Termsets type="dcr">
          <xsl:for-each select="$termsets_config//*[type='dcr']" >
              <xsl:variable name="dcr_termset" select="document(url)" />            
                  <xsl:apply-templates select="$dcr_termset" mode="dcr" >
                      <xsl:with-param name="set" select="key"></xsl:with-param>
                  </xsl:apply-templates>              
          </xsl:for-each>
        </Termsets>
    </xsl:template>

<!-- invert the profiles-termsets + match with data from DCRs = create map datcat -> cmd-elements[] -->	
<xsl:template name="dcr-cmd-map">
    <Termset type="dcr-cmd-map" >	
        <xsl:for-each-group select="$cmd-terms//Term[not(@datcat='')]" group-by="@datcat">
            <Concept id="{@datcat}" type="datcat">
                <xsl:copy-of select="$dcr-terms//Concept[@id=current()/@datcat]/Term" />                
                <xsl:for-each select="current-group()">
                    <xsl:variable name="parent_profile" select="ancestor::Termset[@type='CMD_Profile']/@id" />
                    <Term set="cmd" type="full-path" schema="{$parent_profile}" id="{@id}"><xsl:value-of select="@path" /></Term>
                    <!--<xsl:copy-of select="."></xsl:copy-of>-->
                </xsl:for-each>
            </Concept>				
        </xsl:for-each-group>
    </Termset>
</xsl:template>			

<!-- list dcr-termsets + cmd (+ cmd-profiles) 
TODO: missing: isocat@langs, RR-sets -->    
<xsl:template name="termsets">    
    <Termsets type="list">
        <!-- add dcr-termsets directly from config -->
        <xsl:for-each select="$termsets_config//*[type='dcr'][not(key='isocat')]" >
            <Termset>
                <xsl:copy-of select="*" />
            </Termset>                        
        </xsl:for-each>        
        <xsl:for-each select="$termsets_config//*[type='dcr'][key='isocat']" >
            <Termset>
                <xsl:copy-of select="*" />
                <xsl:for-each select="$isocat-languages/languages/language" >
                    <Termset>
<!--                        name="Finnish" search="finnish" tag="fi"-->
                        <key>isocat-<xsl:value-of select="@tag"></xsl:value-of></key>                        
                        <name>ISOcat <xsl:value-of select="@name"></xsl:value-of></name>
                    </Termset>
                </xsl:for-each>
            </Termset>                        
        </xsl:for-each>
        
        <Termset type="cmd">
          <xsl:for-each select="$cmd-terms//Termset" >
              <key>cmd-profiles</key>
              <id><xsl:value-of select="@id"></xsl:value-of></id>
              <name>CMD Profiles</name>
              <Termset>
                  <key><xsl:value-of select="@name"></xsl:value-of></key>
                  <id><xsl:value-of select="@id"></xsl:value-of></id>
                  <name><xsl:value-of select="@name"></xsl:value-of></name>
              </Termset>                        
          </xsl:for-each>
        </Termset>
    </Termsets>
</xsl:template>

<!-- return a property of a Termset from the configuration. -->    
    <xsl:function name="my:config">
        <xsl:param name="key"></xsl:param>
        <xsl:param name="property"></xsl:param>
        <xsl:value-of select="$termsets_config//*[key=$key]/*[name()=$property]"></xsl:value-of>
    </xsl:function>
</xsl:stylesheet>