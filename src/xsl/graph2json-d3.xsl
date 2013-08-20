<?xml version="1.0" encoding="UTF-8"?>
<!-- Generic stylesheet for viewing XML -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:svg="http://www.w3.org/2000/svg" xmlns:my="myFunctions" version="2.0">
    <xsl:output method="text" encoding="utf-8" indent="yes"/>
<!-- 
<purpose>transform a graph-xml (internal, TODO: align with some standard) 
into a json-object as expected by d3
</purpose>
<history>
	<change on="2012-05-17" type="created" by="vr">based on CMDI/scripts/cmd2dot.xsl</change>			
	<change on="2012-12-05" type="created" by="vr">based on CMDI/scripts/cmd2graph-json-d3.xsl.xsl (split into cmd2graph and graph2json</change>
</history>
<sample>
-->
    <xsl:param name="max-level" select="10"/>
    <xsl:param name="rank-distance" select="100"/>
    <xsl:param name="svg-file" select="'cmd-dep-graph.svg'"/>
<!--    <xsl:param name="svg-file" select="'cmd-dep-graph.svg'" />-->
    <xsl:variable name="svg" select="if(doc-available(resolve-uri($svg-file,base-uri(/)))) then doc(resolve-uri($svg-file,base-uri(/))) else () "/>
<!--        <xsl:variable name="svg" select="if(doc-available($svg-file)) then doc($svg-file) else () " />-->
    <xsl:variable name="svg-elements" select="$svg//svg:g[@class='node']"/>
    
    <!-- average rank-distance 
        trying to determine based on the x-values of the text-nodes-->
    <xsl:variable name="svg-rank-distance">
        <xsl:variable name="xs">
            <xsl:for-each-group select="$svg-elements/svg:text/@x" group-by=".">
                <xsl:sort select="." data-type="number"/>
                <xsl:sequence select="number(.)"/>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:variable name="xs-seq" select="tokenize($xs, ' ')"/>
        <xsl:variable name="diffs">
            <xsl:for-each select="$xs-seq[position() !=last()]">
                <xsl:variable name="pos" select="position()"/>
                <xsl:sequence select="number($xs-seq[$pos + 1]) - number(current())"/>
            </xsl:for-each>
        </xsl:variable>
        <!--<xsl:copy-of select="avg(number(tokenize($diffs,';')))" />-->
        <xsl:value-of select="floor(avg(for $i in tokenize($diffs,' ') return number($i)))"/>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:apply-templates select="graph" mode="json-d3"/>
    </xsl:template>
    <xsl:template match="graph" mode="json-d3">
<!--    <xsl:value-of select="doc-available($svg-file)" />
    svg-file:<xsl:value-of select="$svg-file" />
    svg-rank-distance: <xsl:value-of select="$svg-rank-distance"></xsl:value-of>
-->
        <xsl:text>{</xsl:text>
        <xsl:apply-templates select="nodes"/>
        <xsl:text>,
    </xsl:text>
        <xsl:apply-templates select="edges"/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="nodes">
        <xsl:text> "nodes": [</xsl:text>
        <xsl:apply-templates select="*"/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <xsl:template match="nodes/*">
        <xsl:text>{</xsl:text>
        <xsl:for-each select="@*">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text>":"</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>",</xsl:text>
<!--           <xsl:if test="not(position()=last())"><xsl:text>, </xsl:text></xsl:if>            -->
        </xsl:for-each>
    <!-- adding initial x based on level -->
        <xsl:variable name="svg-element" select="$svg-elements[starts-with(svg:title,current()/@key)][1]"/>
        <xsl:text>"init_x":</xsl:text>
        <xsl:value-of select="if ($svg-element/svg:text/@x) then floor($svg-element/svg:text/@x div $svg-rank-distance  * $rank-distance)   else if (number(@level)=number(@level)) then   @level * $rank-distance else $max-level * $rank-distance"/>
<!--    <xsl:text>, "px":</xsl:text><xsl:value-of select="@level * $rank-distance" />-->
        <xsl:text>, "init_y":</xsl:text>
        <xsl:value-of select="if ($svg-element/svg:text/@y) then round($svg-element/svg:text/@y div -50) else if (number(@level)=number(@level)) then   @level * $rank-distance else $max-level * $rank-distance"/>
<!--    <xsl:text>, "py":</xsl:text><xsl:value-of select="@level * $rank-distance" />-->
        <!--"name":"</xsl:text><xsl:value-of select="@label" /><xsl:text>", "weight":</xsl:text>
    <xsl:value-of select="@count" /><xsl:text>, "group": </xsl:text><xsl:value-of select="@group" />-->
        <xsl:text>}</xsl:text>
        <xsl:if test="not(position()=last())">
            <xsl:text>, 
    </xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="edges">
        <xsl:text> "links": [</xsl:text>
        <xsl:apply-templates select="*"/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <xsl:template match="edges/*">
        <xsl:text>{"source":</xsl:text>
        <xsl:value-of select="@ix_from"/>
        <xsl:text>, "target":</xsl:text>
        <xsl:value-of select="@ix_to"/>
        <xsl:text>, "value":</xsl:text>
        <xsl:value-of select="@value"/>
<!--        <xsl:text>{"source":"</xsl:text><xsl:value-of select="@from" /><xsl:text>", "target":"</xsl:text><xsl:value-of select="@to" /><xsl:text>", "value":</xsl:text><xsl:value-of select="$count" />-->
        <xsl:text>}</xsl:text>
        <xsl:if test="not(position()=last())">
            <xsl:text>, 
</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>