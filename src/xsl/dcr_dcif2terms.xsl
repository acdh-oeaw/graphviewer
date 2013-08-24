<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:my="myFunctions"
  	xmlns:dcif="http://www.isocat.org/ns/dcif"
  	exclude-result-prefixes="xs my"
 >
<!-- 
<purpose> generate a termMatrix for a datcat-profile (dcif-based = isocat: http://www.isocat.org/rest/profile/5)</purpose>
<strategy>map from rdf to Terms </strategy>
<params>
<param name=""></param>
</params>
<history>
	<change on="2010-10-10" type="created" by="vr"></change>
	<change on="2010-05-21" type="created" by="vr">integrated with SMC</change>	
</history>
-->


<!--<xsl:output method="xml" indent="yes" > </xsl:output>-->

<xsl:param name="isocat_prefix" select="'http://www.isocat.org/datcat/'"></xsl:param>

<!--<xsl:template name="continue-root">
<xsl:message>count terms:<xsl:value-of select="count(/dcif:dataCategorySelection/dcif:dataCategory)" /></xsl:message>
	<xsl:apply-templates select="/dcif:dataCategorySelection" />
</xsl:template>
-->
<xsl:template match="dcif:dataCategorySelection" >
	
	<Termset id="isocat{if($lang!=$default_lang) then $lang else ''}" label="{concat(@name, ' [', $lang ,']')}" >		
		<xsl:apply-templates select="dcif:dataCategory" />		
	</Termset>
</xsl:template> 

<!-- <Term elem="TextCorpusProfile" datcat="" corresponding_component="" parent="" context=".TextCorpusProfile" 
name="TextCorpusProfile" count="8" count_text="199" count_distinct_text="87" path="TextCorpusProfile"/>
 -->
 
 <!--  handling compressed dcif-format 
 	<dcif:dataCategory definition="start time of recording" identifier="recordingTime"
 	name="recording time" owner="Reichel, Uwe" pid="http://www.isocat.org/datcat/DC-4521"
 	type="complex" version="1:0">
 	<dcif:conceptualDomain type="constrained">
 	<dcif:dataType>string</dcif:dataType>
 	<dcif:ruleType>XML Schema regular expression</dcif:ruleType>
 	<dcif:rule>([01][0-9]|2[0-4]):[0-5][0-9]:[0-5][0-9]</dcif:rule>
 	</dcif:conceptualDomain>
 	</dcif:dataCategory> 	
 -->
<xsl:template match="dcif:dataCategory[@name]" >
	<xsl:param name="set" />
	<Concept type="datcat" id="{@pid}" datcat-type="{@type}">
		<Term set="{$set}" type="mnemonic" >			 
			<xsl:value-of select="@identifier" />
		</Term>
		<Term set="{$set}" type="id" >			 
			<xsl:value-of select="substring-after(@pid,$isocat_prefix)" />
		</Term>
		<xsl:for-each select="*" >
			<info>
				<xsl:copy-of select="./@xml:lang"/>
				<xsl:copy-of select="." />
			</info>	
		</xsl:for-each>				
<!--		
	<Term type="datcat" name="{@name}" datcat="{@pid}" id="{@identifier}">		
		<xsl:for-each select="@*" >
			<xsl:element name="{name()}" ><xsl:value-of select="." /></xsl:element>			
		</xsl:for-each>
	</Term>-->
	</Concept>
</xsl:template>

 <!--  handling full dcif-format -->
<xsl:template match="dcif:dataCategory" >
	<xsl:param name="set" />
	
	<xsl:variable name="n" >
		<xsl:choose>
			<xsl:when test=".//dcif:name[@xml:lang=$lang]">
				<xsl:value-of select=".//dcif:name[@xml:lang=$lang]" />
			</xsl:when>
			<xsl:when test=".//dcif:name[@xml:lang=$default_lang]">
				<xsl:value-of select=".//dcif:name[@xml:lang=$default_lang]" />
			</xsl:when>
			<xsl:when test=".//dcif:name">
				<xsl:value-of select=".//dcif:name" />
			</xsl:when>
			<xsl:when test=".//dcif:dataElementName">
				<xsl:value-of select=".//dcif:dataElementName" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select=".//dcif:identifier" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!--  <xsl:variable name="datcat" select="my:shortURL(@pid)" />  -->
	
	<Concept type="datcat" id="{@pid}" datcat-type="{@type}">
		<Term set="{$set}" type="mnemonic" >			 
			<xsl:value-of select="$n" />
		</Term>
		<Term set="{$set}" type="id" >			 
			<xsl:value-of select="substring-after(@pid,$isocat_prefix)" />
		</Term>
		<xsl:for-each select="dcif:descriptionSection//dcif:definition" >
			<info>
				<xsl:copy-of select="./@xml:lang"/>
				<xsl:value-of select="." />
			</info>	
		</xsl:for-each>			
		
	</Concept>
	<!--
	<Term type="datcat" name="{$n}" datcat="{@pid}" id="{.//dcif:identifier}">
		<xsl:copy-of select="dcif:administrationRecord/*" />
		<xsl:choose>
		<xsl:when test=".//dcif:languageSection[language=$lang]" >
			<xsl:for-each select=".//dcif:languageSection[language=$lang]//*[@xml:lang=$lang]" >			
					<xsl:element name="{name()}" ><xsl:value-of select="." /></xsl:element>			
			</xsl:for-each>			
		</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select=".//dcif:languageSection[1]//*[exists(text()) and text()!='']" >			
					<xsl:element name="{name()}" ><xsl:value-of select="." /></xsl:element>			
			</xsl:for-each>
		</xsl:otherwise>
		</xsl:choose>
						
		<!-\-   probably need to add conceptual domain! -\->
	</Term>-->
</xsl:template>

</xsl:stylesheet>
