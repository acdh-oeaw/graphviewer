<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:my="myFunctions">

<!-- 
<purpose>functions for SMC</purpose>
<history>
	<change on="2011-10-28" type="created" by="vr">based on cmd_functions.xsl</change>
</history>
-->

 <!--
 @param profiles - list of <profileDescription> 
 -->
	<xsl:function name="my:profiles2termsets" >
		<xsl:param name="profiles"/>
		
		<Termsets count="{count($profiles)}">
		<xsl:for-each select="$profiles" >
			<xsl:variable name="profile_id" select="id"></xsl:variable>
			<Termset name="{name}"  id="{$profile_id}" type="CMD_Profile">
				
					<!-- flattening the structure! -->
				<xsl:for-each select=".//CMD_Component|.//CMD_Element" >
					<xsl:variable name="context" select="my:context(.)" />						
					
					<xsl:variable name="type" select="name()" />					
					<xsl:variable name="id"  >
						<xsl:choose>
							<xsl:when test="@ComponentId">
								<xsl:value-of select="@ComponentId" />
							</xsl:when>
							<!-- top component = profile -->
							<xsl:when test="not(exists(ancestor::CMD_Component))">
								<xsl:value-of select="$profile_id" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="ancestor::CMD_Component[@ComponentId][1]/@ComponentId" /><xsl:text>#</xsl:text>
								<xsl:for-each select="ancestor::CMD_Component[not(descendant-or-self::CMD_Component[@ComponentId])]" >
									<xsl:value-of select="@name" />.</xsl:for-each><xsl:value-of select="@name" />
							</xsl:otherwise>
						</xsl:choose>							
					</xsl:variable>
					<Term  type="{$type}" name="{@name}" datcat="{@ConceptLink}" id="{$id}"  elem="{@name}"
						parent="{ancestor::CMD_Component[1]/@name}" path="{$context}"
						>
						<!--  <xsl:copy-of select="." /> -->
					</Term>
				</xsl:for-each>
			</Termset>
		</xsl:for-each>
		</Termsets>
	</xsl:function>

<xsl:function name="my:profile2termset" >
    <xsl:param name="term"/>
    
    <xsl:variable name="profile" select="my:profile($term,true())" />
	<xsl:copy-of select="my:profiles2termsets($profile)" />
	
</xsl:function>

<xsl:function name="my:profile" >
    <xsl:param name="term"/>
    <xsl:param name="resolve" /> <!--  true|false-->
    
    <!-- <xsl:message>cmdprofiles_uri: <xsl:value-of select="$cmdprofiles_uri" /></xsl:message>  -->
    
	<xsl:variable name="profile" select="$cmd_profiles//profileDescription[name=$term or $term='all']" />
    
    <xsl:choose>
      <xsl:when test="$resolve=true()">
      		<xsl:apply-templates select="$profile" mode="include" />
      </xsl:when>
      <xsl:otherwise>
      		<xsl:copy-of select="$profile" />
      </xsl:otherwise>
    </xsl:choose>
    
        
</xsl:function>


<!--  constructs a dot-path from ancestor-CMD_component-elements -->
<xsl:function name="my:context" >
	<xsl:param name="child" />
	<xsl:variable name="collect" >
			<xsl:for-each select="$child/ancestor::CMD_Component|$child/ancestor::Term" >
					<xsl:value-of select="@name" />.</xsl:for-each><xsl:value-of select="$child/@name" />
	</xsl:variable>
	<xsl:value-of select="$collect" />	
</xsl:function>	


</xsl:stylesheet>