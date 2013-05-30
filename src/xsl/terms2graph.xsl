<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	 xmlns:my="myFunctions" >
    
    <xsl:import href="graph2json-d3.xsl" />
    
			<xsl:output method="xml" encoding="utf-8"			    
			indent="yes"
			    />
<!-- 
<purpose>generate a graph (xml) of CMD-component reuse (based on smc:cmd-terms) 
</purpose>
<history>
	<change on="2012-05-17" type="created" by="vr">based on CMDI/scripts/cmd2dot.xsl</change>
	<change on="2012-12-05" type="created" by="vr">based on CMDI/scripts/cmd2graph-json-d3.xsl.xsl (split into cmd2graph and graph2json</change>
</history>
<sample>
-->


<xsl:variable name="title" select="'mdrepo stats'" />
   
    <xsl:param name="profiles" select="''" />  <!--teiHeader-->
    <xsl:param name="format" select="'xml'" />  <!-- xml | json-d3 ;  todo: dot, json-jit?  -->
    <xsl:param name="rank-distance" select="50" />
    
    <xsl:param name="base-uri" select="base-uri(/)" />
    <xsl:param name="dcr-terms" select="doc(resolve-uri('dcr-terms.xml',$base-uri))" />
    
<!--    <xsl:param name="cmd-terms-uri" select="doc(resolve-uri('cmd-terms-nested.xml',$base-uri))" />-->
        <xsl:param name="cmd-terms-uri" select="doc(resolve-uri('cmd-terms-nested.xml',$base-uri))" />
    <xsl:param name="cmd-terms" select="doc($cmd-terms-uri)" />

    <xsl:key name="cmd-terms-path" match="Term" use="@path"></xsl:key>

<xsl:template match="/">
 	<xsl:variable name="filtered-termsets" >
 	    <xsl:choose>
 	        <xsl:when test="not($profiles='')">
 	            <xsl:copy-of select="//Termset[contains($profiles,@id) or contains($profiles,@name)]"></xsl:copy-of>
 	        </xsl:when>
 	        <xsl:otherwise><xsl:copy-of select="//Termset"></xsl:copy-of></xsl:otherwise>
 	    </xsl:choose>
 	    
 	</xsl:variable>
 	
 	<!-- if instance data - merge with cmd-terms (to get the IDs) --> 
    <xsl:variable name="enriched-termsets" >
        <xsl:choose>
            <xsl:when test="$filtered-termsets//Termset[@type='CMD_Profile']">
                <xsl:copy-of select="$filtered-termsets"></xsl:copy-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$filtered-termsets//Termset" mode="enrich" ></xsl:apply-templates>
            
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:variable>
 	
	<xsl:variable name="nodes">
	    <!--<xsl:for-each select="$filtered-termsets//Termset/Term">
    	    
	        <xsl:variable name="profile" select="$cmd-terms//Termset[@name=current()/@name]"></xsl:variable>
<!-\-    	    DEBUG:-<xsl:value-of select="current()/@name"/><xsl:copy-of select="$profile"></xsl:copy-of>-\->
    	-->    
	        <xsl:apply-templates select="$enriched-termsets//Term" mode="nodes">
<!--    	        <xsl:with-param name="cmd-terms" select="$profile"></xsl:with-param>-->
    	    </xsl:apply-templates>
	    <xsl:apply-templates select="$enriched-termsets//Term" mode="nodes-datcats"/>
    	        
<!--	    </xsl:for-each>-->
	</xsl:variable>
    <xsl:variable name="edges">
        <xsl:apply-templates select="$enriched-termsets//Term" mode="edges"/>
        <xsl:apply-templates select="$enriched-termsets//Term" mode="edges-datcats" />
    </xsl:variable>
        <xsl:variable name="distinct-nodes"  >
            <xsl:for-each-group select="$nodes/*" group-by="@key">
                
                <node position="{position()}" count="{(@count, count(current-group()))}"  
                      avg_level="{avg(current-group()/@level)}" sum_level="{sum(current-group()/@level)}">
                    <xsl:copy-of select="@*" />
                </node>
            </xsl:for-each-group>
        </xsl:variable>
    
    <xsl:variable name="distinct-edges">
     <xsl:for-each-group select="$edges/*" group-by="concat(@from, @to)">
         <xsl:variable name="count" select="count(current-group())"  />    
         <xsl:variable name="ix_from" select="$distinct-nodes/*[@key=current()/@from]/@position - 1 "  />
         <xsl:variable name="ix_to" select="$distinct-nodes/*[@key=current()/@to]/@position - 1"  />
         <edge ix_from="{$ix_from}"  ix_to="{$ix_to}" from="{@from}" to="{@to}" value="{$count}" />
     </xsl:for-each-group>
    </xsl:variable>
    
    <xsl:variable name="graph">
        <graph>
            <nodes count="{count($filtered-termsets//Term)}">
<!--                <xsl:copy-of select="$enriched-termsets" />-->
            <xsl:copy-of select="$distinct-nodes" />
            </nodes>
            <edges>
            <xsl:copy-of select="$distinct-edges" />
            </edges>
        </graph>
    </xsl:variable>
    
    <xsl:choose>
        <xsl:when test="$format='json-d3'">
            <xsl:apply-templates select="$graph"></xsl:apply-templates>
        </xsl:when>
        <xsl:when test="$format='xml'">
            <xsl:copy-of select="$graph" />
        </xsl:when>
        <xsl:otherwise>
            unknown format: <xsl:value-of select="$format"></xsl:value-of>
        </xsl:otherwise>
    </xsl:choose>
            
</xsl:template>


<!--
    <Termset name="Bedevaartbank" id="clarin.eu:cr1:p_1280305685223" type="CMD_Profile">
        <Term type="CMD_Component" name="Bedevaartbank" datcat="" id="clarin.eu:cr1:p_1280305685223" elem="Bedevaartbank" parent="" path="Bedevaartbank"/>
        <Term type="CMD_Component" name="Database" datcat="" id="clarin.eu:cr1:c_1280305685207" elem="Database" parent="Bedevaartbank" path="Bedevaartbank.Database"/>
-->

<xsl:template match="Term[Term]" mode="nodes">
<xsl:param name="cmd-terms" select="$cmd-terms"></xsl:param>    
	<!--<xsl:variable name="current_comp_key" select="my:normalize(concat(@id, '_', @name))" />-->
    <!--<xsl:variable name="equivalent-cmd-term"
        select="$cmd-terms//Term[@path=current()/@path]/@id" />
    -->
    <xsl:variable name="current_comp_key" select="my:normalize(@id)" />
    <xsl:variable name="type" >
         <xsl:choose>
           <xsl:when test="@parent=''">Profile</xsl:when>
               <xsl:otherwise>Component</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="level" select="count(ancestor::Term)" />
    <node id="{@id}" key="{$current_comp_key}" name="{@name}" type="{$type}" level="{$level}" count="{@count}" freq="{@count}"
        path="{@path}">
<!--       <xsl:value-of select="$equivalent_schema_term"></xsl:value-of>-->
    </node>
</xsl:template>

<!--
    <Term type="CMD_Element" name="applicationType"
        datcat="http://www.isocat.org/datcat/DC-3786"
        id="#applicationType"
        elem="applicationType"
        parent="AnnotationTool"
        path="AnnotationTool.applicationType"/>
    -->
    <xsl:template match="Term[not(Term)]" mode="nodes">    
        <xsl:param name="cmd-terms" select="$cmd-terms"></xsl:param>    
        <!--<xsl:variable name="equivalent-cmd-term"
            select="$cmd-terms//Term[@path=current()/@path]/@id" />
-->
        <xsl:variable name="current_elem_key" select="my:normalize(@id)" />
        
        <xsl:variable name="level" select="count(ancestor::Term)" />
        <node id="{@id}" key="{$current_elem_key}" name="{@name}" type="Element" level="{$level}"/>
<!--        <xsl:message><xsl:value-of select="concat(@id, '-', ancestor::Term[1]/@id)"></xsl:value-of></xsl:message>-->
        
    </xsl:template>
   
   
    <!--    process Terms (not only Elements!) once again, to get datcat-nodes -->
    <xsl:template match="Term[@datcat][not(@datcat='')]" mode="nodes-datcats">
        
        <xsl:variable name="level" select="count(ancestor::Term) + 1" />
            <xsl:variable name="datcat-name"  >
                <xsl:variable name="get-mnemonic" select="$dcr-terms//Concept[@id=current()/@datcat]/Term[@type='mnemonic']" />
                <xsl:value-of select="if($get-mnemonic) then $get-mnemonic else tokenize(@datcat,'/')[last()]" />
            </xsl:variable>       
            <node id="{@datcat}" key="{my:normalize(@datcat)}" name="{$datcat-name}" type="DatCat" level="{$level}"/>
        
    </xsl:template>
    
    
   
<!--    process both Components and Elements, from the child point of view
    i.e. find the parent -->
<!--    [@type='CMD_Component']-->
    <xsl:template match="Term[@parent ne '']" mode="edges">
        
        <!-- cater for both: flat and nested input structure -->
        <xsl:variable name="parent" select="(parent::Term[@type='CMD_Component'][1] | preceding-sibling::Term[@type='CMD_Component'][@name=current()/@parent][1])[1]" />
        <xsl:variable name="current_comp_key" select="my:normalize(@id)" />
        
        <edge from="{my:normalize($parent/@id)}"
                to="{$current_comp_key}" /> 
    
    </xsl:template>
    
    <!--    process Terms (not only Elements!) once again, to get links to datcats -->
    <xsl:template match="Term[exists(@datcat) and not(@datcat='')]" mode="edges-datcats">
        <xsl:variable name="current_comp_key" select="my:normalize(@id)" />
        
        <edge from="{$current_comp_key}"
            to="{my:normalize(@datcat)}" /> 
        
    </xsl:template>
    
    
    
    <xsl:template match="Termset" mode="enrich">
        
        <!-- get the correct profile matching on the name of the top element -->
        <xsl:variable name="profile" select="$cmd-terms//Termset[@name=current()/Term/@name]"></xsl:variable>
        <!--    	    DEBUG:-<xsl:value-of select="current()/@name"/><xsl:copy-of select="$profile"></xsl:copy-of>-->
        <xsl:copy>
            <xsl:copy-of select="@*"></xsl:copy-of>
         <xsl:apply-templates select="Term" mode="enrich">
             <xsl:with-param name="cmd-terms" select="$profile"></xsl:with-param>
         </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
   <xsl:template match="Term" mode="enrich">    
      <xsl:param name="cmd-terms" select="$cmd-terms"></xsl:param>    
   
       <xsl:variable name="curr_path" select="@path" />
       <xsl:variable name="equivalent-cmd-term" >
<!--           select="$cmd-terms//Term[@path=current()/@path]" -->
           <xsl:for-each select="$cmd-terms">
               <xsl:copy-of select="key('cmd-terms-path',$curr_path)"></xsl:copy-of>
           </xsl:for-each>
       </xsl:variable>
        
<!--        <xsl:variable name="current_elem_key" select="my:normalize((@id,$equivalent-cmd-term)[1])" />-->
        
        <xsl:copy>
            <xsl:attribute name="curr_path" select="$curr_path" />
            <xsl:copy-of select="@*"></xsl:copy-of>
<!--            <xsl:copy-of select="$equivalent-cmd-term/*" />-->
            <xsl:copy-of select="$equivalent-cmd-term/*/(@type,@parent,@id)"></xsl:copy-of>
            <xsl:apply-templates select="Term" mode="enrich"></xsl:apply-templates>
        </xsl:copy>
<!--        <xsl:variable name="level" select="count(ancestor::Term)" />
        <node id="{(@id,$equivalent-cmd-term)}" key="{$current_elem_key}" name="{@name}" type="Element" level="{$level}"/>
        <!-\-        <xsl:message><xsl:value-of select="concat(@id, '-', ancestor::Term[1]/@id)"></xsl:value-of></xsl:message>-\->
-->        
       
    </xsl:template>

<xsl:function name="my:normalize">
<xsl:param name="value" />		
		<xsl:value-of select="translate($value,'*/-.'',$@={}:[]()#>&lt; ','XZ__')" />		
</xsl:function>

<xsl:function name="my:simplify">
<xsl:param name="value" />		
		<xsl:value-of select="replace($value,'http://www.clarin.eu/cmd/components/','cmd:')" />		
</xsl:function>


<xsl:template match="text()"/>  

</xsl:stylesheet>
