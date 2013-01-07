<?xml version="1.0"?>
<!-- Generic stylesheet for viewing XML -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	 xmlns:my="myFunctions"
	 xmlns:svg="http://www.w3.org/2000/svg" >

			<xsl:output method="text" encoding="utf-8"			    
			indent="yes"
			    />
<!-- 
<purpose>transform a graph-xml (internal format) 
into a dot-format 
</purpose>
<history>
	<change on="2012-05-17" type="created" by="vr">based on CMDI/scripts/cmd2dot.xsl</change>			
	<change on="2012-12-05" type="created" by="vr">based on CMDI/scripts/cmd2graph-json-d3.xsl.xsl (split into cmd2graph and graph2json</change>
	<change on="2012-12-05" type="created" by="vr">based on CMDI/scripts/graph2json-d3.xsl</change>
</history>
<sample>
-->

<xsl:param name="title" select="'cmd-dep-graph'" />

<xsl:template match="/" >
        <xsl:apply-templates select="graph" mode="dot" ></xsl:apply-templates>
</xsl:template>
    
<xsl:template match="graph" mode="dot">
    
    <xsl:text>digraph </xsl:text><xsl:value-of select="my:normalize($title)" />
    <xsl:text>{
				rankdir=LR;
				ranksep=1;
				label = "</xsl:text><xsl:value-of select="$title" /><xsl:text>";
 				size="12,12";   
    </xsl:text>
    <!--    		
/* 
	graph [compound=true, mclimit=4, remincross=true
			ranksep=0.25, nodesep=0.18];
*/
-->

    <xsl:apply-templates select="nodes" mode="dot"/>
    <xsl:text>
    </xsl:text>
    <xsl:apply-templates select="edges" mode="dot"/>
    <xsl:text>
   } /* end graph */</xsl:text>
</xsl:template>
    
<xsl:template match="nodes" mode="dot">
    <xsl:text> /* nodes */ 
    	node [shape=none]
    	</xsl:text>
    <xsl:apply-templates select="*" mode="dot"></xsl:apply-templates>
     <xsl:text>
     	</xsl:text>
</xsl:template>
    
 <xsl:template match="nodes/*" mode="dot">
     <xsl:value-of select="@key" /> [label="<xsl:value-of select="@name" />",
     url="<xsl:value-of select="@id"/>"];
</xsl:template>

<xsl:template match="edges" mode="dot">
    <xsl:text> /* edges */</xsl:text>
    <xsl:apply-templates select="*" mode="dot"></xsl:apply-templates>
    <xsl:text>
      	</xsl:text>
</xsl:template>

<xsl:template match="edges/*" mode="dot">     
		<xsl:value-of select="@from" /> -&gt; <xsl:value-of select="@to" />;
</xsl:template>

<xsl:template match="text()"/>  

<!-- duplicated from cmd2graph ! -->
    <xsl:function name="my:normalize">
        <xsl:param name="value" />		
        <xsl:value-of select="translate($value,'*/-.'',$@={}:[]()#>&lt; ','XZ__')" />		
    </xsl:function>
    
</xsl:stylesheet>
