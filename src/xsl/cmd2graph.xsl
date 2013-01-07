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


<xsl:variable name="title" select="'CMD deps'" />
   
    <xsl:param name="profiles" select="''" />  <!--teiHeader-->
    <xsl:param name="format" select="'xml'" />  <!-- xml | json-d3 ;  todo: dot, json-jit?  -->
    <xsl:param name="rank-distance" select="50" />
    
    <xsl:param name="base-uri" select="base-uri(/)" />
    <xsl:param name="dcr-terms" select="doc(resolve-uri('dcr-terms.xml',$base-uri))" />

    
<xsl:template match="/">
 	<xsl:variable name="filtered-termsets" >
 	    <xsl:choose>
 	        <xsl:when test="not($profiles='')">
 	            <xsl:copy-of select="//Termset[contains($profiles,@id) or contains($profiles,@name)]"></xsl:copy-of>
 	        </xsl:when>
 	        <xsl:otherwise><xsl:copy-of select="//Termset"></xsl:copy-of></xsl:otherwise>
 	    </xsl:choose>
 	    
 	</xsl:variable>
 	
	<xsl:variable name="nodes">
	    <xsl:apply-templates select="$filtered-termsets//Term" mode="nodes"/>
	    <xsl:apply-templates select="$filtered-termsets//Term" mode="nodes-datcats"/>
	</xsl:variable>
    <xsl:variable name="edges">
        <xsl:apply-templates select="$filtered-termsets//Term" mode="edges"/>
        <xsl:apply-templates select="$filtered-termsets//Term" mode="edges-datcats" />
    </xsl:variable>
        <xsl:variable name="distinct-nodes"  >
            <xsl:for-each-group select="$nodes/*" group-by="@key">
                <node position="{position()}" count="{count(current-group())}" 
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
            <nodes>
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

<xsl:template match="Term[@type='CMD_Component']" mode="nodes">    
	<!--<xsl:variable name="current_comp_key" select="my:normalize(concat(@id, '_', @name))" />-->
    <xsl:variable name="current_comp_key" select="my:normalize(@id)" />
    <xsl:variable name="type" >
         <xsl:choose>
           <xsl:when test="@parent=''">Profile</xsl:when>
               <xsl:otherwise>Component</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="level" select="count(ancestor::Term)" />
    <node id="{@id}" key="{$current_comp_key}" name="{@name}" type="{$type}" level="{$level}"/>
</xsl:template>

<!--
    <Term type="CMD_Element" name="applicationType"
        datcat="http://www.isocat.org/datcat/DC-3786"
        id="#applicationType"
        elem="applicationType"
        parent="AnnotationTool"
        path="AnnotationTool.applicationType"/>
    -->
    <xsl:template match="Term[@type='CMD_Element']" mode="nodes">    
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
