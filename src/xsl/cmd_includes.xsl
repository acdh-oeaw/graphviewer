<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:my="myFunctions"
 exclude-result-prefixes="my">

<!-- 
<purpose>CMD-components inclusion mechanism</purpose>
<history>
	<change on="2011-09-01" type="created" by="vr">extracted from cmd_commons.xsl</change>
</history>

-->

    <!-- resolve includes -->
    <xsl:template match="@*|node()" mode="include">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="include"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="CMD_Component[@ComponentId]" mode="include">
    
    		<!-- <xsl:param name="resolved_path" select="if (matches(@filename, $prefix)) then $prefix_replace else './'" /> -->

    		<!-- <xsl:variable name="resolved_fn" select="if (matches(@filename, $prefix)) then replace(@filename, $prefix, $prefix_replace) else if (document-uri(/)) then @filename else concat( $root_uri, '/', @filename)" /> -->    		
    		<!--<xsl:variable name="resolved_fn" select="concat($cmd_components_uri, my:extractID(@ComponentId))" />-->   
            <xsl:variable name="resolved_fn" select="concat($cmd_components_uri, @ComponentId)" /> 
    	    <xsl:variable name="compid" select="@ComponentId" /> 
	        
        <!-- <xsl:variable name="resolved_fn" select="replace(@filename, 'http://www.clarin.eu/cmd/components', 'file:///C:/Users/master/3lingua/clarin/CMDI/_repo2/metadata/toolkit/components')" /> -->
        
<!--        <xsl:message>document-uri:<xsl:value-of select="document-uri(/)" /></xsl:message>
        <xsl:message>resolved_fn:<xsl:value-of select="$resolved_fn" /></xsl:message>        
-->        
        <!-- some of the outer CMD_Component attributes can overwrite the inner CMD_Component attributes -->        
        <xsl:variable name="outer-attr" select="@CardinalityMin|@CardinalityMax"/>
        <xsl:for-each select="document($resolved_fn)/CMD_ComponentSpec/CMD_Component">
            <xsl:variable name="inner-attr" select="@*"/>
            <xsl:copy>
            		<!-- <xsl:attribute name="filename" select="replace($resolved_fn,$prefix_replace,'')" /> -->
            	
           		<xsl:attribute name="ComponentId" select="$compid" />
                <xsl:apply-templates select="$outer-attr" mode="include"/>
                <xsl:apply-templates select="$inner-attr[not(node-name(.) = $outer-attr/node-name(.))]" mode="include"/>
                <xsl:apply-templates select="node()" mode="include">
        <!--        	<xsl:with-param name="resolved_path" select="$resolved_path" /> -->
                </xsl:apply-templates>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>
    
<!--    <xsl:template match="componentDescription[id] | profileDescription[id]" mode="include">-->
    <xsl:template match="profileDescription[id]" mode="include">
    
    	<!--  <xsl:variable name="resolved_uri" select="concat($root_uri, '/', id)" />-->
    	<!--<xsl:variable name="resolved_uri" select="concat($cmd_profiles_uri , '/', my:extractID(id))" />-->
        <!--
        <xsl:variable name="resolved_uri" select="concat($cmd_profiles_uri , id, '/xml')" />
    	
        <xsl:message>PROFILE: document-uri:<xsl:value-of select="document-uri(/)" /></xsl:message>
        <xsl:message>resolved_uri:<xsl:value-of select="$resolved_uri" /></xsl:message>
        -->
                
        <xsl:copy>        	
            <xsl:apply-templates mode="include" />
            <xsl:copy-of select="my:getData('profiles', id, $cache)"></xsl:copy-of>
        	<!--<xsl:call-template name="getData">
        	    <xsl:with-param name="key" select="'profile'"></xsl:with-param>
        	    <xsl:with-param name="id" select="id"></xsl:with-param>
        	</xsl:call-template>-->
            <!-- <xsl:apply-templates mode="include" />
        	<xsl:apply-templates select="document($resolved_uri)" mode="include" /> -->
        	<!-- <xsl:copy-of select="document($resolved_uri)" /> -->
       		<!-- <xsl:copy-of select="document(id, $root_uri)" />  -->
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>