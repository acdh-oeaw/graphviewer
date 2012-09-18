<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:my="myFunctions"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:openskos="http://openskos.org/xmlns#"
  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  
  	xmlns:dcif="http://www.isocat.org/ns/dcif"
  	exclude-result-prefixes="xs my"
	>
	<xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
		<xd:desc>
			<xd:p>generate a SKOS-version for a datcat-profile mapping from internal format (Termset/Concept/Term)</xd:p>
			<xd:p>also expects data from relationregistry in the variable: <xd:ref name="rr-relations"></xd:ref></xd:p>			
			<xd:p><xd:b>Created on:</xd:b> Sep 18, 2012</xd:p>
			<xd:p><xd:b>Author:</xd:b> m</xd:p>
			<xd:p></xd:p>
		</xd:desc>
	</xd:doc>

<xsl:import href="smc_commons.xsl"/>

	<xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
		<xd:desc>
			<xd:p></xd:p>
		</xd:desc>
	</xd:doc>
<xsl:output method="xml" indent="yes" > </xsl:output>


	<xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
		<xd:desc>
			<xd:p>Which Termset shall be processed</xd:p> 
			<xd:p>Input file contains multiple Termsets (in /Termsets/Termset), but we want each termset in a separate collection</xd:p>
		</xd:desc>
	</xd:doc>
<xsl:param name="set" select="'isocat'"></xsl:param>

<!--<xsl:template name="continue-root">
<xsl:message>count terms:<xsl:value-of select="count(/dcif:dataCategorySelection/dcif:dataCategory)" /></xsl:message>
	<xsl:apply-templates select="/dcif:dataCategorySelection" />
</xsl:template>
-->
	<xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
		<xd:desc>
			<xd:p></xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="/" >
		
		<xsl:apply-templates select="/Termsets/Termset[@set=$set]"></xsl:apply-templates>		
	</xsl:template>
		
	<xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
		<xd:desc>
			<xd:p></xd:p>
		</xd:desc>
	</xd:doc>
<xsl:template match="Termset" >	
	<rdf:RDF 
		openskos:tenant="icltt" openskos:collection="{@set}" openskos:key="icltt2012">
		<rdf:Description rdf:about="{@url}">
			<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#ConceptScheme"/>
			<dc:title xml:lang="en"><xsl:value-of select="@name"></xsl:value-of></dc:title>
			<dc:creator xml:lang="en">ICLTT</dc:creator>			
			<dc:description xml:lang="en">Data Categories</dc:description>			
			<xsl:apply-templates mode="index"/>
		</rdf:Description>		
		<xsl:apply-templates >
			<xsl:with-param name="scheme" select="@url"></xsl:with-param>
		</xsl:apply-templates>		
	</rdf:RDF>	
</xsl:template> 

	<xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
		<xd:desc>
			<xd:p></xd:p>
		</xd:desc>
	</xd:doc>
<xsl:template match="Concept" mode="index">
	<skos:hasTopConcept rdf:resource="{@id}"/>
</xsl:template>
	
	
	<xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
		<xd:desc>
			<xd:p></xd:p>
		</xd:desc>
		<xd:param name="scheme"></xd:param>
	</xd:doc>
<xsl:template match="Concept" >
	<xsl:param name="scheme" />
	<rdf:Description rdf:about="{@id}">
		<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
		<skos:inScheme rdf:resource="{$scheme}"/>
		<xsl:apply-templates select="Term|info"></xsl:apply-templates>
		
		<xsl:call-template name="matches" >
			<xsl:with-param name="concept" select="@id"></xsl:with-param>
		</xsl:call-template>		
	</rdf:Description>
</xsl:template>


	<xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
		<xd:desc>
			<xd:p></xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="info" >
		<skos:definition xml:lang="{@xml:lang}"><xsl:value-of select="."/></skos:definition>
	</xsl:template>
	
	
	<xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
		<xd:desc>
			<xd:p></xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="Term" >
	
	<xsl:choose>		
		<!-- in isocat mnemonic is taken as default,  in dublincore there is only one Term (this is not too reliable)			-->
		<xsl:when test="count(../Term)=1" >
			<skos:prefLabel xml:lang="en"><xsl:value-of select="."/></skos:prefLabel>	
		</xsl:when>
		<xsl:when test="@type='mnemonic'" >
			<skos:altLabel xml:lang="en"><xsl:value-of select="."/></skos:altLabel>	
		</xsl:when>	
		<xsl:when test="@type='label'">
			<skos:prefLabel xml:lang="{@xml:lang}"><xsl:value-of select="."/></skos:prefLabel>
		</xsl:when>
		<xsl:when test="@type='id'" >
			<skos:altLabel ><xsl:value-of select="."/></skos:altLabel>
		</xsl:when>				
		<xsl:otherwise>
			<skos:altLabel ><xsl:value-of select="."/></skos:altLabel>
		</xsl:otherwise>
	</xsl:choose>
	
		
	<!--
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
	
	<!-\-  <xsl:variable name="datcat" select="my:shortURL(@pid)" />  -\->
				
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

	<xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
		<xd:desc>
			<xd:p></xd:p>
		</xd:desc>
		<xd:param name="concept"></xd:param>
	</xd:doc>
<xsl:template name="matches">
	<xsl:param name="concept"></xsl:param>
<!--<DEBUG><xsl:value-of select="$concept"></xsl:value-of></DEBUG>	-->
	<xsl:for-each select="$rr-relations//Relation[Concept/@id=$concept]" >
		<xsl:variable name="other_concept" select="Concept[not(@id=$concept)]"></xsl:variable>
		<xsl:choose>
			<xsl:when test="@type='sameAs'">
				<skos:exactMatch rdf:resource="{$other_concept/@id}" />
			</xsl:when>
			<xsl:when test="@type='subClassOf' and $other_concept/@role='about'">
				<skos:narrowMatch rdf:resource="{$other_concept/@id}" />	
			</xsl:when>
			<xsl:when test="@type='subClassOf' and not($other_concept/@role='about')">
				<skos:broadMatch rdf:resource="{$other_concept/@id}" />	
			</xsl:when>
			<xsl:otherwise>
				<skos:relatedMatch rdf:resource="{$other_concept/@id}" />
			</xsl:otherwise>
				
		</xsl:choose>
		
		
	</xsl:for-each>
	
	
</xsl:template>

</xsl:stylesheet>
