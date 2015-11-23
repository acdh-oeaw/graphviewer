<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="myFunctions" version="2.0" xml:space="default">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>generate a graph (xml) of CMD-component reuse (based on smc:cmd-terms)</xd:p>
            <xd:p>also takes instance-data summary as input - tries to merge with cmd-terms data (to get the ids)</xd:p>
    
            <xd:p>an integrated version, that based on format-param directly produced json, had very bad performance, 
                so the functionality is split. first step is here, generating the graph-xml, 
                which is then used as input for graph2json-d3.xsl, or graph2dot.xsl</xd:p>
            
            <xd:p>needs following auxiliary documents (under the base-uri):
                <xd:ul>
                    <xd:li>cmd-terms.xml</xd:li>
                    <xd:li>cmd-terms-nested.xml</xd:li>
                    <xd:li>dcr-terms.xml</xd:li>
                    <xd:li>dcr-cmd-map.xml</xd:li>
                    <xd:li>rr-relations.xml</xd:li>                    
                </xd:ul>
            </xd:p>
            <xd:p><xd:b>Created on:</xd:b> 2012-05-17 (based on CMDI/scripts/cmd2dot.xsl)</xd:p>
            <xd:p><xd:b>Modified:</xd:b> 2012-12-05, 2013-06, 2013-08-21</xd:p>
            <xd:p><xd:b>Author:</xd:b> m</xd:p>
            
        </xd:desc>
    </xd:doc>

    <xsl:output method="xml" encoding="utf-8" indent="yes"/>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>allows to restrict the outputted graph-nodes and edges by type </xd:p>
            <xd:p>profiles are output always</xd:p>
            <xd:p>recognized values: collections,components,profile-groups,datcats,relations (delimited by ',')</xd:p>            
            <xd:p>if datcats and no components - direct links between profiles and datcats are generated</xd:p>
            <xd:p>if no datcats and no components - direct links between profiles are generated (weighted by the number of shared data categories</xd:p>
            <xd:p>profile-groups generates extra nodes grouping profiles by metadata (creatore, groupName, domainName)</xd:p>
        </xd:desc>
    </xd:doc>
<!--        <xsl:param name="parts" select="'profile-groups'"/>-->
    <xsl:param name="debug" select="false()"/>
    <xsl:param name="parts" select="'collections,profile-groups,components,datcats,relations'"/>
    <xsl:variable name="parts-sequence" select="tokenize($parts,',')"></xsl:variable>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="profiles" select="''"/>  <!--teiHeader-->
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>threshold for the similarity quotient (matched_datcats : profile_terms), when linking profiles (mode=edges-profiles)</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="match_threshold" select="0.5"/>
    


    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>used as base, when resolving the auxiliary files, that get loaded with doc</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="base-uri" select="base-uri(/)"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>auxiliary data: data categories in the terms format, loaded from dcr-terms.xml</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="dcr-terms" select="doc(resolve-uri('dcr-terms.xml',$base-uri))"/>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
             <xd:p>generate a deep copy of the cmd-terms data - this is necessary due to a problem with Saxon 9.2.1.5 (used by exist; 9.3.0.5 seemed to work) - see enrich-mode templates </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="dcr-terms-copy">
        <xsl:apply-templates select="$dcr-terms" mode="copy"/>
    </xsl:variable>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="rr-relations" select="doc(resolve-uri('rr-relations.xml',$base-uri))"/>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="cmd-terms-uri" select="resolve-uri('cmd-terms-nested.xml',$base-uri)"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="cmd-terms" select="doc($cmd-terms-uri)"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>generate a deep copy of the cmd-terms data - this is necessary due to a problem with Saxon 9.2.1.5 (used by exist; 9.3.0.5 seemed to work) - see enrich-mode templates </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="cmd-terms-copy">
        <xsl:apply-templates select="$cmd-terms/*" mode="copy"/>
    </xsl:variable>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>lookup term by path in cmd-terms, when enriching instance data with cmd-terms</xd:p>
            <xd:pre><Term type="CMD_Component" name="GeneralInfo" datcat="" id="clarin.eu:cr1:c_1359626292113" elem="GeneralInfo" parent="AnnotatedCorpusProfile" path="AnnotatedCorpusProfile.GeneralInfo">
                    <Term type="CMD_Element" name="ResourceName" datcat="http://www.isocat.org/datcat/DC-2544" id="clarin.eu:cr1:c_1359626292113#ResourceName" elem="ResourceName" parent="GeneralInfo" path="AnnotatedCorpusProfile.GeneralInfo.ResourceName"/>
                </Term>
            </xd:pre>
            
        </xd:desc>
    </xd:doc>
    <xsl:key name="cmd-terms-path" match="Term" use="@path"/>
    
    <xsl:key name="cmd-terms-datcat" match="Term" use="@datcat"/>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>lookup a profile by name</xd:p>
            <xd:pre><Termset name="AnnotatedCorpusProfile" id="clarin.eu:cr1:p_1357720977520" type="CMD_Profile" /></xd:pre>
        </xd:desc>
    </xd:doc>
    <xsl:key name="cmd-termset-name" match="Termset" use="@name"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>lookup a profile by id</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:key name="cmd-termset-id" match="Termset" use="@id"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>lookup dcr-terms (data categories) by their identifier</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:key name="dcr-terms" match="Concept" use="@id"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Main template</xd:p>
            <xd:p>steps performed:</xd:p>
            <xd:ul>
                <xd:li>apply optional profile-filter</xd:li>
                <xd:li>if instance data -> enrich (= merge with cmd-terms)</xd:li> 
                <xd:li>generate nodes for profiles/components/elements, datcats (if instance data additionally collections) </xd:li>
                <xd:li>generate edges for profiles -> components -> elements, terms -> datcats, relations (if instance data additionally collections-> profiles) </xd:li>
                <xd:li>fold nodes and edges ($nodes -> $distinct-nodes, $edges -> $distinct-edges)</xd:li>
                <xd:li>return full graph-xml</xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
<!--        <xsl:value-of select="doc-available(resolve-uri('../data/cmd-terms-nested.xml',$base-uri))"></xsl:value-of>-->
        <xsl:variable name="filtered-termsets">
            <xsl:choose>
                <xsl:when test="not($profiles='')">
                    <xsl:copy-of select="//Termset[contains($profiles,@id) or contains($profiles,@name)]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="//Termset"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
 	
 	<!-- if instance data - merge with cmd-terms (to get the IDs) -->
        <xsl:variable name="enriched-termsets">
            <xsl:choose>
                <xsl:when test="$filtered-termsets//Termset[@type='CMD_Profile']">
                    <xsl:copy-of select="$filtered-termsets"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$filtered-termsets//Termset" mode="enrich"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="nodes">
	    <!--<xsl:for-each select="$filtered-termsets//Termset/Term">
    	    
	        <xsl:variable name="profile" select="$cmd-terms//Termset[@name=current()/@name]"></xsl:variable>
<!-\-    	    DEBUG:-<xsl:value-of select="current()/@name"/><xsl:copy-of select="$profile"></xsl:copy-of>-\->
    	-->
            <xsl:if test="'collections' = $parts-sequence"><xsl:apply-templates select="$enriched-termsets//Termset[@context]" mode="nodes-collections"/></xsl:if>
            <xsl:apply-templates select="$enriched-termsets//Termset[@type='CMD_Profile']" mode="nodes"/>
            <xsl:if test="'profile-groups' = $parts-sequence">
                <xsl:call-template name="nodes-profile-groups"><xsl:with-param name="termsets" select="$enriched-termsets" /></xsl:call-template>                
            </xsl:if>
            <xsl:if test="'components' = $parts-sequence"><xsl:apply-templates select="$enriched-termsets//Term" mode="nodes" /></xsl:if>
            <xsl:if test="'datcats' = $parts-sequence"><xsl:apply-templates select="$enriched-termsets//Term" mode="nodes-datcats"/></xsl:if>
            <xsl:if test="'relations' = $parts-sequence">
                <xsl:for-each-group select="$rr-relations//Concept" group-by="@id">
                    <xsl:variable name="datcat-id" select="@id"/>
                    <xsl:variable name="get-mnemonic">
                        <xsl:for-each select="$dcr-terms-copy">
                            <xsl:copy-of select="key('dcr-terms', $datcat-id)/Term[@type=('mnemonic','label')][1]"/>
                            <!--                /Concept/Term[@type='mnemonic']-->
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:variable name="datcat-name">
                        <!--            <xsl:variable name="get-mnemonic" select="$dcr-terms//Concept[@id=current()/@datcat]/Term[@type='mnemonic']"/>-->
                        <xsl:value-of select="if($get-mnemonic ne '') then $get-mnemonic else tokenize($datcat-id,'/')[last()]"/>
                    </xsl:variable>
                    <node id="{@id}" key="{my:normalize(@id)}" name="{$datcat-name}" type="DatCat">
                        <xsl:copy-of select="@*[not (name()=('count','type'))]"/>
                    </node>
                </xsl:for-each-group>
            </xsl:if>
    	        
<!--	    </xsl:for-each>-->
        </xsl:variable>
        <xsl:variable name="edges">
            <xsl:if test="'collections' = $parts-sequence"><xsl:apply-templates select="$enriched-termsets//Termset[@context]/Term" mode="edges-collections"/></xsl:if>
            <xsl:if test="'components' = $parts-sequence"><xsl:apply-templates select="$enriched-termsets//Term" mode="edges"/></xsl:if>
            <xsl:if test="'datcats' = $parts-sequence and 'components' = $parts-sequence" ><xsl:apply-templates select="$enriched-termsets//Term" mode="edges-datcats"/></xsl:if>
            <xsl:if test="'datcats' = $parts-sequence and not('components' = $parts-sequence)" ><xsl:apply-templates select="$enriched-termsets//Term" mode="edges-profiles-datcats"/></xsl:if>
            <xsl:if test="not('datcats' = $parts-sequence) and not('components' = $parts-sequence)" ><xsl:apply-templates select="$enriched-termsets//Termset[@type='CMD_Profile']" mode="edges-profiles"/></xsl:if>
            <xsl:if test="'relations' = $parts-sequence" ><xsl:apply-templates select="$rr-relations//Relation" mode="edges-rels"/></xsl:if>            
            <xsl:if test="'profile-groups' = $parts-sequence">
                <xsl:apply-templates select="$enriched-termsets//info/(groupName | domainName | creatorName)[. ne '']" mode="edges-profiles-groups"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="distinct-nodes">
            <xsl:for-each-group select="$nodes/*" group-by="@key">
                <node position="{position()}" count="{(sum(current-group()/@count[. ne ''][number(.)=number(.)])[.>0], count(current-group()))[1]}" avg_level="{avg(current-group()/@level)}" sum_level="{sum(current-group()/@level)}">
                    <xsl:copy-of select="@*[not (name()='count')]"/>
                </node>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:variable name="distinct-edges">
            <xsl:for-each-group select="$edges/*" group-by="concat(@from, @to)">
                <xsl:variable name="value" select="if (exists(@value)) then sum(@value) else count(current-group())"/>
                <xsl:variable name="weight" select="if (exists(@weight)) then sum(@weight) else 1"/>
                <xsl:variable name="ix_from" select="$distinct-nodes/*[@key=current()/@from]/@position - 1 "/>
                <xsl:variable name="ix_to" select="$distinct-nodes/*[@key=current()/@to]/@position - 1"/>
                <edge ix_from="{$ix_from}" ix_to="{$ix_to}" from="{@from}" to="{@to}" value="{$value}" weight="{$weight}"/>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:variable name="graph">
            <graph>
<!--                <nodes count="{count($filtered-termsets//Term)}">-->
           <nodes count="{count($distinct-nodes)}">
                    
<!--                                                            <xsl:copy-of select="$dcr-terms-copy"/>-->
                    <xsl:copy-of select="$distinct-nodes"/>
<!--       DEBUG: <xsl:copy-of select="$nodes"/>-->
                </nodes>
                <edges>
                    <xsl:copy-of select="$distinct-edges"/>
                    <xsl:if test="$debug"><debug><xsl:copy-of select="$edges"/></debug></xsl:if>
                </edges>
            </graph>
        </xsl:variable>

        <xsl:copy-of select="$graph"/>

    </xsl:template>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Generate nodes for CMD-Profile in cmd-terms</xd:p>
            <xd:p>Termset = profiles + root component 
                (data is inconsistent sometimes profile is the root component, sometimes a separate components (e.g. imdi-session)</xd:p>
        </xd:desc>    
    </xd:doc>
    <xsl:template match="Termset" mode="nodes">
        
        <xsl:variable name="current_profile_key" select="my:normalize(@id)"/>
        <node id="{@id}" key="{$current_profile_key}" name="{@name}" type="Profile" level="0" count="{(@count, count(.//Term))[1]}" path="{@path}">
            <!--       <xsl:value-of select="$equivalent_schema_term"></xsl:value-of>-->
        </node>
        <!-- if root component not profile generate a separte node for it -->
        <xsl:if test="xs:string(@id) ne Term/xs:string(@id)">
            <xsl:for-each select="Term">
                <node id="{@id}" key="{my:normalize(@id)}" name="{@name}" type="Component" level="1" count="{(@count, count(.//Term))[1]}" path="{@path}"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template> 
        
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Generate nodes for CMD-Components and CMD-Elements (and CMD-Profiles in instance-data) </xd:p>
            <xd:p>Expects Terms with @id-attribute, so instance data has to be enriched first</xd:p>
            <xd:pre><Termset name="Bedevaartbank" id="clarin.eu:cr1:p_1280305685223" type="CMD_Profile">
        <Term type="CMD_Component" name="Bedevaartbank" datcat="" id="clarin.eu:cr1:p_1280305685223" elem="Bedevaartbank" parent="" path="Bedevaartbank"/>
        <Term type="CMD_Component" name="Database" datcat="" id="clarin.eu:cr1:c_1280305685207" elem="Database" parent="Bedevaartbank" path="Bedevaartbank.Database"/>
            </Termset>
            </xd:pre>
        </xd:desc>        
    </xd:doc>
    <xsl:template match="Term" mode="nodes">
    
        <xsl:variable name="current_term_key" select="my:normalize(@id)"/>
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="@type='CMD_Profile' or parent::Termset[@context]">Profile</xsl:when>
                <xsl:when test="@type='CMD_Component'">Component</xsl:when>
                <xsl:when test="@type='CMD_Element'">Element</xsl:when>
                <!-- pass special types -->
                <xsl:otherwise>
                    <xsl:value-of select="@type"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="level" select="count(ancestor::Term)"/>
        <node id="{@id}" key="{$current_term_key}" name="{@name}" type="{$type}" level="{$level}" count="{@count}" path="{@path}">
            <!--       <xsl:value-of select="$equivalent_schema_term"></xsl:value-of>-->
        </node>
    </xsl:template>
    <!--
    <!-\- not root components = (mostly) profiles -\->
    <xsl:template match="Term[not(parent::Termset)][Term]" mode="nodes">
        <xsl:param name="cmd-terms" select="$cmd-terms"/>    
	<!-\-<xsl:variable name="current_comp_key" select="my:normalize(concat(@id, '_', @name))" />-\->
    <!-\-<xsl:variable name="equivalent-cmd-term"
        select="$cmd-terms//Term[@path=current()/@path]/@id" />
    -\->
        <xsl:variable name="current_comp_key" select="my:normalize(@id)"/>
        <xsl:variable name="type" select="'Component'">
            <!-\-<xsl:choose>
                <xsl:when test="@parent=''">Profile</xsl:when>
                <xsl:otherwise>Component</xsl:otherwise>
            </xsl:choose>-\->
        </xsl:variable>
        <xsl:variable name="level" select="count(ancestor::Term)"/>
        <node id="{@id}" key="{$current_comp_key}" name="{@name}" type="{$type}" level="{$level}" count="{@count}" path="{@path}">
<!-\-       <xsl:value-of select="$equivalent_schema_term"></xsl:value-of>-\->
        </node>
    </xsl:template>-->
    

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>OBSOLETING in favor of more general template for all Term</xd:p>
            <xd:p>Generate nodes for CMD-Elements (leaf nodes in cmd-terms)</xd:p>
            <xd:p>However, in the data there is also CMD_ComponentsGenerate nodes for CMD-Elements (leaf nodes in cmd-terms)</xd:p>
            <xd:p>Expects Terms with @id-attribute, so instance data has to be enriched first</xd:p>
            <xd:pre><Term type="CMD_Element" name="applicationType"
        datcat="http://www.isocat.org/datcat/DC-3786"
        id="#applicationType"
        elem="applicationType"
        parent="AnnotationTool"
        path="AnnotationTool.applicationType"/>
    </xd:pre>
        </xd:desc>        
    </xd:doc>
    <!--<xsl:template match="Term[not(Term)]" mode="nodes">        
        <xsl:variable name="current_elem_key" select="my:normalize(@id)"/>
        <xsl:variable name="level" select="count(ancestor::Term)"/>
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="@type='CMD_Element'">Element</xsl:when>
                
                <xsl:when test="@type='CMD_Component'">Component</xsl:when>                
                <!-\- pass special types -\->
                <xsl:otherwise>
                    <xsl:value-of select="@type"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <node id="{@id}" key="{$current_elem_key}" name="{@name}" type="{$type}" level="{$level}" count="{@count}" path="{@path}"/>
<!-\-        <xsl:message><xsl:value-of select="concat(@id, '-', ancestor::Term[1]/@id)"></xsl:value-of></xsl:message>-\->
    </xsl:template>-->
   
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>process Terms (also Components, not only Elements!) once again, to get datcat-nodes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="Term[@datcat][not(@datcat='')]" mode="nodes-datcats">
        <xsl:variable name="level" select="count(ancestor::Term) + 1"/>
        <xsl:variable name="datcat-id" select="@datcat"/>
        <xsl:variable name="get-mnemonic">
            <xsl:for-each select="$dcr-terms-copy">
                <xsl:copy-of select="key('dcr-terms', $datcat-id)/Term[@type=('mnemonic','label')][1]"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="datcat-name">
            <xsl:value-of select="if($get-mnemonic ne '') then $get-mnemonic else tokenize(@datcat,'/')[last()]"/>
        </xsl:variable>
<!--     DEBUG:get-mnemonic:<xsl:value-of select=""/>-->
        <node id="{$datcat-id}" key="{my:normalize($datcat-id)}" name="{$datcat-name}" type="DatCat" level="{$level}"
            mnemonic="{$get-mnemonic}" ref_term_id="{@id}"/>
    </xsl:template>
    
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Generate nodes representing collections (in instance-data)</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="Termset[@context]" mode="nodes-collections">    
        
        <xsl:variable name="coll_key" select="my:normalize(@context)"/>
        <xsl:variable name="type" select="'Collection'"/>
        <xsl:variable name="level" select="-1"/>
        <xsl:variable name="count" select="if (exists(@count)) then number(@count) else sum(Term/@count)"></xsl:variable>
        <node id="{@context}" key="{$coll_key}" name="{translate(@context, '_', ' ')}" type="{$type}" level="{$level}" count="{$count}" path="{@context}"/>
    </xsl:template>

    <xsl:template name="nodes-profile-groups">
        <xsl:param name="termsets"></xsl:param>
        <xsl:for-each-group select="$termsets//Termset/info/(groupName | domainName | creatorName)[. ne '']" group-by=".">
            <xsl:variable name="type" select="concat('profile-', substring-before(name(),'Name'))"/>
            <xsl:variable name="node_key" select="my:normalize(concat($type, '_', .))"/>
            <xsl:variable name="level" select="-1"/>
            <xsl:variable name="count" select="count($termsets//Termset[info/*[local-name()=local-name(current())][. = current-grouping-key()]])"/>
            
            <node id="{$node_key}" key="{$node_key}" name="{.}" type="{$type}" level="{$level}" count="{$count}" path="{$node_key}"/>    
        </xsl:for-each-group>

    </xsl:template>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Generate links between the profiles and the collections they appear in</xd:p>
            <xd:pre>collection -> profile</xd:pre>
        </xd:desc>
    </xd:doc>
    <xsl:template match="Termset[@context]/Term" mode="edges-collections">
        
        <!-- cater for both: flat and nested input structure -->
        <xsl:variable name="parent_coll" select="(parent::Termset/@context)"/>
        <xsl:variable name="curr_profile_key" select="my:normalize(@id)"/>
        <edge from="{my:normalize($parent_coll)}" to="{$curr_profile_key}"/>
    </xsl:template>
    
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>generate bi-directional links for Relations between concepts</xd:p>
            <xd:p>Sample input data:</xd:p>
            <xd:pre><Relation type="sameAs">
        <Concept type="datcat" id="http://www.isocat.org/datcat/DC-2520" role="about"/>
        <Concept type="datcat" id="http://purl.org/dc/elements/1.1/description"/>
                
    </Relation></xd:pre>
            <xd:pre>concept1 -> concept2, concept2 -> concept1</xd:pre>
        </xd:desc>
    </xd:doc>
    <xsl:template match="Relation" mode="edges-rels">
        <edge from="{my:normalize(Concept[1]/@id)}" to="{my:normalize(Concept[2]/@id)}" type="{@type}"/>
        <edge from="{my:normalize(Concept[2]/@id)}" to="{my:normalize(Concept[1]/@id)}" type="-{@type}"/>
    </xsl:template>
    
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p> process both Components and Elements, from the child point of view
                i.e. find the parent </xd:p>
        </xd:desc>
    </xd:doc>
    <!--    [@type='CMD_Component'] [@parent ne '']-->
    <xsl:template match="Term[parent::Term]" mode="edges">            
        <!-- cater for both: flat and nested input structure -->
<!--        <xsl:variable name="parent" select="(parent::Term[@type='CMD_Component'][1] | preceding-sibling::Term[@type='CMD_Component'][@name=current()/@parent][1])[1]"/>-->
<!--      not any more: just accept nested structure  -->
        <xsl:variable name="parent" select="parent::Term[1] "/>
        <xsl:variable name="current_comp_key" select="my:normalize(@id)"/>
        <edge from="{my:normalize($parent/@id)}" to="{$current_comp_key}"/>
    </xsl:template>
    
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>process Terms (not only Elements!) once again, to get links to datcats </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="Term[exists(@datcat) and not(@datcat='')]" mode="edges-datcats">
        <xsl:variable name="current_comp_key" select="my:normalize(@id)"/>
        <edge from="{$current_comp_key}" to="{my:normalize(@datcat)}"/>
    </xsl:template>
    
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>alternatively process Terms to generate direct links between Profiles and Datcats</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="Term[exists(@datcat) and not(@datcat='')]" mode="edges-profiles-datcats">
        <xsl:variable name="current_profile_key" select="my:normalize(ancestor::Termset/@id)"/>
        <edge from="{$current_profile_key}" to="{my:normalize(@datcat)}"/>
    </xsl:template>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>create direct links between profiles based on shared Datcats</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="Termset[@type='CMD_Profile']" mode="edges-profiles">
        <xsl:variable name="current_profile_key" select="my:normalize(@id)"/>
        <xsl:variable name="current_profile_name" select="@name"/>
        <xsl:variable name="profile_datcats" select="distinct-values(.//Term/data(@datcat)[not(.='')])"/>
        <xsl:variable name="profile_terms" select=".//Term/data(@id)"/>
<!--        <edge from="{$current_profile_key}" weight="{count($profile_datcats)}"/>-->
        <xsl:for-each select="following-sibling::Termset" >
            <xsl:variable name="other_profile_key" select="my:normalize(@id)"/>
            <xsl:variable name="matching_datcats" select="distinct-values(.//Term[not(@datcat='')][@datcat=$profile_datcats]/data(@datcat))"/>
            <xsl:variable name="other_datcats" select="distinct-values(.//Term[not(@datcat='')]/data(@datcat))"/>
            <xsl:variable name="matching_terms" select="distinct-values(.//Term[@id=$profile_terms]/data(@id))"/>
            <!--<xsl:variable name="matching_datcats">            
                <xsl:copy-of select=".//Term[key('cmd-terms-datcat',$profile_datcats)]"/>            
            </xsl:variable>-->
<!--            <xsl:if test="exists($matching_datcats)" > -->
            <xsl:variable name="match_quotient1" select="if (exists($profile_datcats)) then count($matching_datcats) div count($profile_datcats) else 0 " />
            <xsl:variable name="match_quotient2" select="if (exists($other_datcats)) then count($matching_datcats) div count($other_datcats) else 0" />
            <xsl:variable name="match_quotient" select="number(($match_quotient1 + $match_quotient2) div 2)" />
            
            <xsl:if test="number($match_quotient) &gt; number($match_threshold)" >
            <!--<xsl:if test="not(number($match_quotient) = number($match_quotient))" >  
            <xsl:message>DEBUG: <xsl:value-of select="$match_quotient"></xsl:value-of> </xsl:message>
            </xsl:if>-->
<!--                weight="{count($matching_datcats) + count($matching_terms)}"-->
                <edge from="{$current_profile_key}" to="{$other_profile_key}"
                    from_name="{$current_profile_name}" to_name="{data(@name)}"
                    value="{count($matching_datcats)}"
                    weight="{$match_quotient}"                    
                    count_matching_distinct_terms="{count($matching_terms)}" match_quotient="{$match_quotient}"
                    count_matching_datcats="{count($matching_datcats)}" 
                    count_profile_datcats="{count($profile_datcats)}"
                    count_other_datcats="{count($other_datcats)}"
                    count_terms="{count($profile_terms)}"
                    count_other_terms="{count(.//Term)}"
                    >
                   <!--DEBUG:
                       <xsl:copy-of select="$matching_datcats"></xsl:copy-of>-->
               </edge>
            </xsl:if>
            
        </xsl:for-each>
        
    </xsl:template>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Generate links between the profiles and their respective profile-groups</xd:p>
            <xd:pre>profile-group -> profile</xd:pre>
        </xd:desc>
    </xd:doc>
    <xsl:template match="info/*" mode="edges-profiles-groups">
        
        <xsl:variable name="type" select="concat('profile-', substring-before(name(),'Name'))"/>
        <xsl:variable name="node_key" select="my:normalize(concat($type, '_', .))"/>
        
        <xsl:variable name="curr_profile_key" select="ancestor::Termset[@type='CMD_Profile']/my:normalize(@id)"/>
        <edge from="{$node_key}" to="{$curr_profile_key}"/>
    </xsl:template>
    
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>entry template for enrich-mode</xd:p>
        </xd:desc>
        <xd:desc>
            <xd:p>When enriching the instance data Termset-element represents the collection.
                Profile is the Termset/Term element </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="Termset" mode="enrich">
        
        <!-- get the correct profile matching on the name of the top element 
            is currently not used due to the bug - rather the global variable $cmd-terms-copy is consulted on every lookup -->
        <xsl:variable name="profile" select="$cmd-terms-copy//Termset[@name=current()/Term/@name]"/>
<!--            	    DEBUG:-<xsl:value-of select="current()/@name"/><xsl:copy-of select="$profile"></xsl:copy-of>-->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="Term" mode="enrich">
            <!--    <xsl:with-param name="cmd-terms">
                    <xsl:apply-templates select="$profile" mode="copy"/>
                </xsl:with-param>-->
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>merges the Term elements from instance-data with corresponding cmd-terms</xd:p>
            <xd:p>There is a bug(?) in Saxon 9.2.1.5 (used in exist): "Exception: attribute node may not be created after children of containing node."
            when the $cmd-terms nodeset is passed as a variable. The error disappears when the node is deep-copied().
            However it is prohibitively expensive to do the copy of the context-profile on every term, 
            thus rather the global variable $cmd-terms-copy is used.
            WATCHME: There may be a problem with correct matching!
            In Saxon 9.3.0.5 (Oxygen) no such error occurs.</xd:p>
        </xd:desc>
        <xd:param name="cmd-terms">obsoleted, because unusable due to the error</xd:param>
    </xd:doc>
    
    <xsl:template match="Term" mode="enrich">
<!--        <xsl:param name="cmd-terms" select="$cmd-terms"/>-->
        <xsl:variable name="curr_path" select="xs:string(@path)"/>
        <xsl:variable name="equivalent-cmd-term">
            <xsl:call-template name="get-equivalent-cmd-term">
<!--                <xsl:with-param name="cmd-terms" select="$cmd-terms"/>-->
<!--                <xsl:with-param name="cmd-terms">                    
                    <xsl:apply-templates select="$cmd-terms" mode="copy"/>
                </xsl:with-param>-->                
                <xsl:with-param name="key" select="xs:string(@path)"/>
                <xsl:with-param name="isProfile" select="exists(parent::Termset)"/>
            </xsl:call-template>
        </xsl:variable>
<!--        <xsl:message><debug><xsl:copy-of select="$equivalent-cmd-term"/></debug> </xsl:message>-->
<!--        <xsl:variable name="current_elem_key" select="my:normalize((@id,$equivalent-cmd-term)[1])" />-->
        <!--            <xsl:attribute name="curr_path" select="$curr_path"/>-->
        <Term>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="count($equivalent-cmd-term/*) = 1">
                    <xsl:copy-of select="$equivalent-cmd-term/*/(@type,@parent,@id,@datcat)"/>
                </xsl:when>
                <xsl:when test="count($equivalent-cmd-term/*) &gt; 1">
                    <xsl:attribute name="type" select="concat('ERROR-ambigue-', count($equivalent-cmd-term/*))"/>
                    <xsl:copy-of select="$equivalent-cmd-term/*[1]/(@parent,@id,@datcat)"/>
                </xsl:when>
                <xsl:otherwise><!-- if no equivalent term find - use path as id and mark as missing -->
                    <xsl:attribute name="id" select="xs:string(@path)"/>
                    <xsl:attribute name="type">ERROR-cmd-term-missing</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>

            <!--          type="{$equivalent-cmd-term/*/@type}" id="{$equivalent-cmd-term/*/@id}"  <xsl:copy-of select="$equivalent-cmd-term/*/(@parent,@id)"/><xsl:copy-of select="@*"/>-->
<!--            <xsl:value-of select="$equivalent-cmd-term" />-->
            <xsl:apply-templates select="Term" mode="enrich">

            </xsl:apply-templates>
        </Term>
    </xsl:template>

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>helper template handling lookup of corresponding cmd-terms (lookup in post-loaded data)</xd:p>
        </xd:desc>
        <xd:param name="cmd-terms">data to look in</xd:param>
        <xd:param name="key">key to look for</xd:param>
        <xd:param name="isProfile">indicate, if we are looking for a profile</xd:param>
    </xd:doc>
    <xsl:template name="get-equivalent-cmd-term">
        <xsl:param name="cmd-terms" select="$cmd-terms-copy"/>
        <xsl:param name="key" select="xs:string(@path)"/>
        <xsl:param name="isProfile" select="false()"/>
<!--        <xsl:message><xsl:value-of select="concat($key,'-',$isProfile)"></xsl:value-of></xsl:message>-->
        <xsl:choose>
            <xsl:when test="$isProfile">
                <xsl:for-each select="$cmd-terms">
                    <xsl:copy-of select="key('cmd-termset-name',$key)"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$cmd-terms">
                    <xsl:copy-of select="key('cmd-terms-path',$key)"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>helper-function translating ids and similar to (javascript-)safe keys, removing special characters</xd:p>
        </xd:desc>
        <xd:param name="value"></xd:param>
    </xd:doc>
    <xsl:function name="my:normalize">
        <xsl:param name="value"/>
        <xsl:value-of select="translate($value,'*/-.'',$@={}:[]()#&gt;&lt; ','XZ__')"/>
    </xsl:function>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
        <xd:param name="value"></xd:param>
    </xd:doc>
    <xsl:function name="my:simplify">
        <xsl:param name="value"/>
        <xsl:value-of select="replace($value,'http://www.clarin.eu/cmd/components/','cmd:')"/>
    </xsl:function>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="text()"/>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>copy-mode - util-template, generate a deep copy </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="*|@*" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()" mode="copy"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>copy-mode: copy text</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="text()" mode="copy">
        <xsl:copy/>
    </xsl:template>
    
    
</xsl:stylesheet>