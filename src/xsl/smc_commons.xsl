<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:my="myFunctions" exclude-result-prefixes="xs my" version="2.0">
   
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all" name="xml"/>
    
    
    <xsl:include href="smc_params.xsl"/>
    <xsl:include href="smc_functions.xsl"/>
    <xsl:include href="cmd_includes.xsl"/>    
    <xsl:include href="dcr_rdf2terms.xsl"/>
    <xsl:include href="dcr_dcif2terms.xsl"/>
   
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>use either input (precedence) or the config-file as the termsets configuration</xd:p>
        </xd:desc>
    </xd:doc>
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
   <xsl:variable name="cmd_profiles_uri" select="my:config('cmd-profiles','url_prefix')" />
    
<!-- intermediate datasets bound into variables,to prevent calling the function every time -->
    <xsl:variable name="dcr-terms-preload" select="my:getData('dcr-terms-preload')" />
   <xsl:variable name="dcr-terms" select="my:getData('dcr-terms')" />
    <xsl:variable name="rr-relations" select="my:getData('rr-relations')" />
    <!-- rr-relations expanded with terms-->
    <xsl:variable name="rr-terms" select="my:getData('rr-terms')" />
   <xsl:variable name="cmd-terms" select="my:getData('cmd-terms')" />
    <xsl:variable name="cmd-terms-nested" select="my:getData('cmd-terms-nested')" />
   <xsl:variable name="dcr-cmd-map" select="my:getData('dcr-cmd-map')" />
   <xsl:variable name="isocat-languages" select="my:getData('isocat-languages')" />

    <xsl:key name="concept-id" match="Concept" use="xs:string(@id)" /> 

    <!--  -->
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>either serves a dataset or invokes its generation and stores to cache, based on the cache parameter</xd:p>
            <xd:p>passes down to my:getData() function for actual generation of the dataset</xd:p>
        </xd:desc>
        <xd:param name="key">dataset key</xd:param>
        <xd:param name="id">optional profile or component identifier to retrieve a single profile or component</xd:param>
        <xd:param name="cache">use: returns the requested dataset, refresh: writes the dataset to cache (overwriting)</xd:param>
    </xd:doc>
    <xsl:template name="getData">
        <xsl:param name="key" select="$data_key"></xsl:param>
        <xsl:param name="id" select="$id"></xsl:param>
        <xsl:param name="cache" select="$cache"></xsl:param>
        
        <xsl:variable name="cache_path"  select="my:cachePath($key,$id)" />
        <!--<xsl:message>document-uri1: <xsl:value-of select="document-uri(/)"></xsl:value-of></xsl:message>-->
        <xsl:variable name="result" select="my:getData($key,$id,$cache)"></xsl:variable>
        
        <xsl:message><xsl:value-of select="$cache_path" /> available <xsl:value-of select="doc-available($cache_path)" /></xsl:message>
<!--        <xsl:message>cachePath: <xsl:value-of select="$cache_path"></xsl:value-of></xsl:message>-->
            <xsl:if test="contains($cache,'refresh') and not(doc-available($cache_path))">
             <xsl:result-document href="{$cache_path}" format="xml" >
                 <xsl:copy-of select="$result" />
             </xsl:result-document>
            </xsl:if>
        
        
        <!-- only output to main result if cache is use (otherwise only write out to cache) -->
<!--        <xsl:if test="$cache='use' and not(doc-available($cache_path))">-->
            <xsl:if test="contains($cache,'use')">
            <xsl:copy-of select="$result"></xsl:copy-of>
        </xsl:if>
        
    </xsl:template>
    
 <!-- 
         -->
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>serves individual datasets (cmd-profiles, dcr-termsets...)</xd:p>            
            <xd:p>primitive cache mechanism - 
                if data of given key is already stored, serve it, 
                otherwise build a new (but don't store in cache - within this function)               
             </xd:p>
        </xd:desc>
        <xd:param name="key">dataset key</xd:param>
        <xd:param name="id">optional profile or component identifier to retrieve a single profile or component</xd:param>
        <xd:param name="cache">recognized value: use beware of the param-value in recursive calls (currently 'use' is fixed for deeper calls)</xd:param>
    </xd:doc>
  <xsl:function name="my:getData">
        <xsl:param name="key"></xsl:param>
        <xsl:param name="id"></xsl:param>
       <xsl:param name="cache"></xsl:param>
        
      <xsl:variable name="cached_data_file" select="my:cachePath($key,$id)"></xsl:variable>
                <xsl:message>cache: <xsl:value-of select="$cache" /></xsl:message>
                <xsl:message>key: <xsl:value-of select="$key"></xsl:value-of></xsl:message>
                <xsl:message><xsl:value-of select="$cached_data_file" /> available <xsl:value-of select="doc-available($cached_data_file)" /></xsl:message>
      
      
        <xsl:choose>
            <xsl:when test="doc-available($cached_data_file) and $cache='use'">
                <xsl:message>reading in: <xsl:value-of select="$cached_data_file" />                    
                </xsl:message>
                <xsl:copy-of select="doc($cached_data_file)"></xsl:copy-of>
            </xsl:when>
            <xsl:when test="$key='cmd-profiles-raw'">
                 
                <xsl:variable name="cmd-profiles" select="document(my:config('cmd-profiles','url'))" />                
                <!-- integrate profiles that are already used in instance data, but not public - if appropriate config entry given -->
                <xsl:variable name="used-profiles" >
                    <xsl:if test="my:config('used-profiles','url') ne ''" >
                        <xsl:copy-of select="document(my:config('used-profiles','url'))" />                            
                    </xsl:if>                   
                </xsl:variable>
                <profileDescriptions>
<!--                    DEBUG:<xsl:value-of select="my:config('used-profiles','url')"></xsl:value-of>-->
                    <xsl:copy-of select="$cmd-profiles//profileDescription"  />
                    <xsl:copy-of select="$used-profiles//profileDescription[not(id = $cmd-profiles//profileDescription/id)]" />
                    
                </profileDescriptions>                
            </xsl:when>
            <xsl:when test="$key='profiles' or $key='datcats'">                
                <xsl:copy-of select="my:getRawData($key, $id)" />                
            </xsl:when> 
            <xsl:when test="$key='cmd-resolved'">
                <xsl:apply-templates select="my:getData('cmd-profiles-raw')" mode="include" />                
            </xsl:when>
            <xsl:when test="$key='cmd-terms'">
                <xsl:copy-of select="my:profiles2termsets(my:getData('cmd-resolved')//profileDescription,false())" />
            </xsl:when>
            <xsl:when test="$key='cmd-terms-nested'">
                <xsl:copy-of select="my:profiles2termsets(my:getData('cmd-resolved')//profileDescription,true())" />
            </xsl:when>
            <xsl:when test="$key='cmd-terms-nested-minimal'">
                <xsl:apply-templates select="$cmd-terms-nested" mode="min-context"></xsl:apply-templates>
            </xsl:when>            
            <xsl:when test="$key='dcr-terms-preload'">
                <xsl:call-template name="load-dcr" />								
            </xsl:when>
            <xsl:when test="$key='dcr-terms'">
                <xsl:call-template name="postload-datcats" />								
            </xsl:when>
            <xsl:when test="$key='rr-relations'">
                <xsl:call-template name="load-rr-relations" />								
            </xsl:when>
            <xsl:when test="$key='rr-terms'">
                <xsl:call-template name="rr-terms" />								
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
        
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>overload method with one param and value of global cache-param as default</xd:p>
        </xd:desc>
        <xd:param name="key"></xd:param>
    </xd:doc>
    <xsl:function name="my:getData">
        <xsl:param name="key"></xsl:param>
        <xsl:copy-of select="my:getData($key,'', $cache)"></xsl:copy-of>
    </xsl:function>
    
    <xsl:function name="my:getData">
        <xsl:param name="key"></xsl:param>
        <xsl:param name="id"></xsl:param>
        <xsl:copy-of select="my:getData($key,$id, $cache)"></xsl:copy-of>
    </xsl:function>
   
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>get the raw xml for a specific piece of data (profile, component, later data category) from the source, or from the cache if already available</xd:p>
            <xd:p>Storing to cache happens in load-profiles template</xd:p>
        </xd:desc>
        <xd:param name="key">currently only 'profiles'</xd:param>
        <xd:param name="id">id for the profile</xd:param>
    </xd:doc>
    <xsl:function name="my:getRawData">
        <xsl:param name="key"></xsl:param>
        <xsl:param name="id"></xsl:param>
        
        <xsl:variable name="cached_data_file" select="my:cachePath($key,$id)"></xsl:variable>
<!--        <xsl:variable name="cached_data_file" select="concat($cache_dir, if (ends-with($cache_dir,'/') or ends-with($cache_dir,'\')) then '' else '/',
            $key, '/', my:normalize($id), '.xml')"></xsl:variable>-->
    <!--    <xsl:message>cache: <xsl:value-of select="$cache" /></xsl:message>
        <xsl:message><xsl:value-of select="$cached_data_file" /> available <xsl:value-of select="doc-available($cached_data_file)" /></xsl:message>
    -->    
        
        <!--<xsl:variable name="resolved_fn" select="concat($cmd_components_uri, @ComponentId)" /> 
        <xsl:variable name="compid" select="@ComponentId" /> 
        
        -->
        <xsl:variable name="resolved_uri" select="if (doc-available($cached_data_file)) then $cached_data_file else concat($cmd_profiles_uri[$key='profiles'] , $id, '/xml'[$key='profiles'], '.dcif'[$key='datcats'])" />
        
        <xsl:message><xsl:value-of select="$key" />:</xsl:message>
        <xsl:message>resolved_uri:<xsl:value-of select="$resolved_uri" /></xsl:message>
        <xsl:if test="doc-available($resolved_uri)">
            <xsl:copy-of select="doc($resolved_uri)" />
                <!--            <xsl:apply-templates select="document($resolved_uri)" mode="include" />-->
        </xsl:if>
        
    </xsl:function>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>load all dcrs from the configuration and transform them into Termsets
                (uses mode=dcr-templates in dcr_rdf2terms.xsl)</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="load-dcr">
        <Termsets type="dcr">
          <xsl:for-each select="$termsets_config//*[type='dcr']" >
              <xsl:variable name="dcr_termset" select="document(url)" />            
                  <xsl:apply-templates select="$dcr_termset" mode="dcr" >
                      <xsl:with-param name="config-node" select="." />                                               
                      <xsl:with-param name="set" select="key"></xsl:with-param>
                  </xsl:apply-templates>              
          </xsl:for-each>           
        </Termsets>
    </xsl:template>
    
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>load all data-categories, that are used in CMD, and are not present in the Termsets already downloaded in load-dcr</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="postload-datcats">
        
        <xsl:variable name="missing-datcats" select="distinct-values($cmd-terms//Term[not(@datcat='')][not(@datcat =$dcr-terms-preload//Concept/@id)]/@datcat)" />
        <xsl:for-each select="$missing-datcats">
<!--            <xsl:copy-of select="my:getRawData('datcats',.)" />-->
                <xsl:call-template name="getData">
                    <xsl:with-param name="key" select="'datcats'"></xsl:with-param>
                    <!--<xsl:with-param name="id" select="my:shortURL(.)"></xsl:with-param>-->
                    <xsl:with-param name="id" select="."></xsl:with-param>
                    <xsl:with-param name="cache" select="'refresh'"></xsl:with-param>
                </xsl:call-template>
        </xsl:for-each>
        
        <xsl:variable name="resolved_datcats">
        <xsl:for-each select="$missing-datcats">
            <!--            <xsl:copy-of select="my:getRawData('datcats',.)" />-->
            <xsl:apply-templates select="my:getData('datcats',.)" mode="dcr" >            
                <xsl:with-param name="config-node" >
                <item>
                    <name>ISOcat</name>
                    <url_prefix>http://www.isocat.org/datcat/</url_prefix>
                </item>
                </xsl:with-param>
                <xsl:with-param name="set" select="'isocat'"></xsl:with-param>
            </xsl:apply-templates>
        </xsl:for-each>
        </xsl:variable>
        <!-- weave in the newly generated missing dcr-terms inton the isocat termset-->
        
            <Termsets type="dcr">
                <Termset>
                    <xsl:copy-of select="$dcr-terms-preload//Termset[xs:string(@set)='isocat']/@*"/>
                    <xsl:copy-of select="$dcr-terms-preload//Termset[xs:string(@set)='isocat']/*" />
                    <xsl:copy-of select="$resolved_datcats/Termset[xs:string(@set)='isocat']/*" />
                </Termset>
                <xsl:copy-of select="$dcr-terms-preload//Termset[xs:string(@set) ne 'isocat']" />      
            </Termsets>

<!--        <xsl:copy-of select="$raw-datcat-defs"></xsl:copy-of>-->
        <!--    <xsl:for-each-group select="$cmd-terms//Term[not(@datcat='')]" group-by="@datcat">
                    <xsl:variable name="curr_datcat" select="@datcat" />
                <xsl:value-of select="$curr_datcat"></xsl:value-of>
                #<xsl:copy-of select="$dcr-terms-preload//key('concept-id',$curr_datcat)"></xsl:copy-of>-                
            </xsl:for-each-group>-->                
<!--        [not(exists($dcr-terms-preload/key('concept-id',@datcat)))]-->
<!--        </xsl:variable>-->
<!--        <xsl:value-of select="$missing-datcats" />-->
        <!--<xsl:for-each-group select="$cmd-terms//Term[not(@datcat='')]" group-by="@datcat">
            <Concept id="{@datcat}" type="datcat">
                <xsl:copy-of select="$dcr-terms//Concept[@id=current()/@datcat]/Term" exclude-result-prefixes="my" />
                
        -->
<!--        <Termsets type="dcr">
            <xsl:for-each select="$termsets_config//*[type='dcr']" >
                <xsl:variable name="dcr_termset" select="document(url)" />            
                <xsl:apply-templates select="$dcr_termset" mode="dcr" >
                    <xsl:with-param name="config-node" select="."></xsl:with-param>
                    <xsl:with-param name="set" select="key"></xsl:with-param>
                </xsl:apply-templates>              
            </xsl:for-each>           
        </Termsets>
    </xsl:template>


    <xsl:template name="load-profiles">
        
        <!-\-        <xsl:variable name="profiles" select="document(my:config('cmd-profiles','url'))"></xsl:variable>-\->
        <xsl:variable name="profiles" select="my:getData('cmd-profiles-raw')"></xsl:variable>
        
        <!-\- ???        <xsl:apply-templates select="$profiles" mode="include" />-\->
        
        <xsl:for-each select="$profiles//profileDescription[id]">
            <xsl:call-template name="getData">
                <xsl:with-param name="key" select="'profiles'"></xsl:with-param>
                <xsl:with-param name="id" select="id"></xsl:with-param>
                <xsl:with-param name="cache" select="'refresh'"></xsl:with-param>
            </xsl:call-template>
        </xsl:for-each>
-->        
    </xsl:template>


    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>stores all profiles in the cache, by calling getData-template with $cache=refresh param</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="load-profiles">
        
<!--        <xsl:variable name="profiles" select="document(my:config('cmd-profiles','url'))"></xsl:variable>-->
        <xsl:variable name="profiles" select="my:getData('cmd-profiles-raw')"></xsl:variable>
        
<!-- ???        <xsl:apply-templates select="$profiles" mode="include" />-->
        
        <xsl:for-each select="$profiles//profileDescription[id]">
            <xsl:call-template name="getData">
                <xsl:with-param name="key" select="'profiles'"></xsl:with-param>
                <xsl:with-param name="id" select="id"></xsl:with-param>
                <xsl:with-param name="cache" select="'refresh'"></xsl:with-param>
            </xsl:call-template>
        </xsl:for-each>
        
    </xsl:template>
        
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>invert the profiles-termsets + match with data from DCRs = create map datcat -> cmd-elements[]</xd:p>
        </xd:desc>
    </xd:doc>
<xsl:template name="dcr-cmd-map">
    <xsl:variable name="dcr-terms" select="my:getData('dcr-terms')" />
    <Termset type="dcr-cmd-map" >	
        <xsl:for-each-group select="$cmd-terms//Term[not(@datcat='')]" group-by="@datcat">
            <Concept id="{@datcat}" type="datcat">
                <xsl:copy-of select="$dcr-terms//Concept[@id=current()/@datcat]/Term" exclude-result-prefixes="my" />                
                <xsl:for-each select="current-group()">
                    <xsl:variable name="parent_profile" select="ancestor::Termset[@type='CMD_Profile']/@id" />
                    <Term set="cmd" type="full-path" schema="{$parent_profile}" id="{@id}"><xsl:value-of select="@path" /></Term>
                    <!--<xsl:copy-of select="."></xsl:copy-of>-->
                </xsl:for-each>
            </Concept>				
        </xsl:for-each-group>
    </Termset>
</xsl:template>			  

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>list dcr-termsets + cmd (+ cmd-profiles)</xd:p>
            <xd:p>TODO: missing: isocat@langs, RR-sets</xd:p>
        </xd:desc>
    </xd:doc>
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
            <key>cmd-profiles</key>
            <id>cmd-profiles</id>
            <name>CMD Profiles</name>
          <xsl:for-each select="$cmd-terms//Termset" >              
              <Termset>
                  <key><xsl:value-of select="@name"></xsl:value-of></key>
                  <id><xsl:value-of select="@id"></xsl:value-of></id>
                  <name><xsl:value-of select="@name"></xsl:value-of></name>
              </Termset>                        
          </xsl:for-each>
        </Termset>
    </Termsets>
</xsl:template>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>load relation sets from the configuration and transform into Termset/Relation/Concepet
                (uses mode=rr-templates in dcr_rdf2terms.xsl) </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="load-rr-relations">
        <Termsets type="rr">
            <xsl:for-each select="$termsets_config//*[type='rr']" >
                <xsl:variable name="rr_termset" select="document(url)" />            
                <xsl:apply-templates select="$rr_termset" mode="rr" >
                    <xsl:with-param name="set" select="key"></xsl:with-param>
                </xsl:apply-templates>              
            </xsl:for-each>
        </Termsets>
    </xsl:template>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>take the rr-relations and expand them with data from dcr-cmd-terms, 
                to get rr-expanded terms</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="rr-terms">        
            <xsl:apply-templates select="$rr-relations" mode="rr-expand" ></xsl:apply-templates>              
    </xsl:template>
    
    <xsl:template match="*" mode="rr-expand">
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:apply-templates mode="rr-expand"></xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>expand rr-concepts</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="Concept" mode="rr-expand">
        <xsl:variable name="concept-id" select="@id" />                
        <xsl:copy>
            <xsl:copy-of select="@*" />            
            <xsl:copy-of select="$dcr-cmd-map//Concept[@id=$concept-id]/Term" />            
        </xsl:copy>        
    </xsl:template>
        
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>return a property of a Termset from the configuration.</xd:p>
        </xd:desc>
        <xd:param name="key">key identifying the dataset item</xd:param>
        <xd:param name="property">element-name of the requested property</xd:param>
    </xd:doc>
    <xsl:function name="my:config">
        <xsl:param name="key"></xsl:param>
        <xsl:param name="property"></xsl:param>
        <xsl:value-of select="$termsets_config//*[key=$key]/*[name()=$property]"></xsl:value-of>
    </xsl:function>
    
    
</xsl:stylesheet>