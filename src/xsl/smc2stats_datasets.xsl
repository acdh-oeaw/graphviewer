<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ds="http://aac.ac.at/corpus_shell/dataset"
  xmlns:my="myFunctions"   
  exclude-result-prefixes="xs my"
  
>
<!-- 
<purpose> statistics about the smc-data, generates a dataset/dataseries/value table-like xml-structure,
that can be transformed to html (or chart-data etc.) in separate next step 
relies on the data prepared in smc_commons.xsl
currently the main map is produced in a separate step and loaded from static-xml (map_file)</purpose>
<params>
main input file is expected dcr-cmd-map.xml
</params>
<history>
	<change on="2011-10-27" type="created" by="vr">from complist2terms_201109.xsl (via smc_init.xsl)</change>	
	<change on="2013-01-04" type="created" by="vr">from smc_stats.xsl </change>
</history>
-->
 

<xsl:import href="smc_commons.xsl"/>

	<xsl:output method="xml" indent="yes" />
	
  <xsl:param name="title" select="'SMC Stats'" />

	<!--
		
	        <info>
            <id xmlns:ns2="http://www.w3.org/1999/xlink">clarin.eu:cr1:p_1357720977520</id>
            <description xmlns:ns2="http://www.w3.org/1999/xlink">A CMDI profile for annotated text
                corpus resources.</description>
            <name xmlns:ns2="http://www.w3.org/1999/xlink">AnnotatedCorpusProfile</name>
            <registrationDate xmlns:ns2="http://www.w3.org/1999/xlink"
                >2013-01-31T11:57:12+00:00</registrationDate>
            <creatorName xmlns:ns2="http://www.w3.org/1999/xlink">nalida</creatorName>
            <userId xmlns:ns2="http://www.w3.org/1999/xlink">22</userId>
            <domainName xmlns:ns2="http://www.w3.org/1999/xlink"/>
            <ns2:href xmlns:ns2="http://www.w3.org/1999/xlink"
                >http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/clarin.eu:cr1:p_1357720977520</ns2:href>
            <groupName xmlns:ns2="http://www.w3.org/1999/xlink">CLARIN</groupName>
            <commentsCount xmlns:ns2="http://www.w3.org/1999/xlink">0</commentsCount>
            <showInEditor xmlns:ns2="http://www.w3.org/1999/xlink">true</showInEditor>
        </info>-->
	
<xsl:param name="profile-info-fields" >description,registrationDate,creatorName,domainName,groupName</xsl:param>
	<xsl:variable name="profile-info-fields-sequence" select="tokenize($profile-info-fields,',')"/>
		
    <!--
 <xsl:param name="map_file" select="'../../../../SMC/output/map_full.xml'" />  
 <xsl:variable name="map" select="document($dcr-cmd-map_file)" />
    -->
 
	<xsl:variable name="count_elems" select="count($cmd-terms//Term[@type='CMD_Element'])" ></xsl:variable>
	<xsl:variable name="count_distinct_datcats" select="count(distinct-values($cmd-terms//Term/@datcat[not(.='')]))" ></xsl:variable> <!--[@type='CMD_Element']-->
	
	<xsl:variable name="count_distinct_components" select="count(distinct-values($cmd-terms//Term[@type='CMD_Component'][not(@parent='')]/@id))" ></xsl:variable>
	<xsl:variable name="count_standalone_components" select="count(distinct-values($cmd-terms//Term[@type='CMD_Component'][not(@parent='')]/@id[not(contains(.,'#'))]))" ></xsl:variable>
	<xsl:variable name="count_distinct_elems" select="count(distinct-values($cmd-terms//Term[@type='CMD_Element']/@id))" ></xsl:variable>
	<xsl:variable name="count_components_datcat" select="count(distinct-values($cmd-terms//Term[@type='CMD_Component'][@datcat[not(.='')]]/@id))" ></xsl:variable>	

	<xsl:variable name="all_profiles" select="$cmd-terms//Termset" />
	<xsl:variable name="all_datcats" select="$dcr-terms//Concept" />
 
<!--<xsl:template name="continue-root">-->	
	<xsl:template match="/">
		<multiresult>
	        <xsl:call-template name="summary-overall"></xsl:call-template>
			<xsl:call-template name="summary-profiles"></xsl:call-template>
			<xsl:call-template name="summary-components"></xsl:call-template>
			<xsl:call-template name="summary-datcats"></xsl:call-template>
			<xsl:call-template name="ambigue-terms"></xsl:call-template>
		</multiresult>
<!--		<xsl:call-template name="summary-concepts"></xsl:call-template>
		<xsl:call-template name="summary-terms"></xsl:call-template>	
    	<xsl:call-template name="summary-cmd"></xsl:call-template>
		<xsl:call-template name="ambigue-elems"></xsl:call-template>
-->    
 </xsl:template>			
	
	
<xsl:template name="summary-overall">
		
	<ds:dataset key="summary" label="Summary">
		<ds:labels>
			<ds:label key="creation-date">created</ds:label>
			<ds:label key="profiles">Profiles</ds:label>
			<ds:label key="components">Components</ds:label>
			<ds:label key="distinct-components">distinct Components</ds:label>
			<ds:label key="elements">Elements</ds:label>
			<ds:label key="distinct-elements">distinct Elements</ds:label>
			
			<ds:label key="elems-with-datcats">Elements with DatCats</ds:label>
			<ds:label key="elems-without-datcats">Elements without DatCats</ds:label>
			<ds:label key="elems-without-datcats-ratio" >ratio of elements without DatCats</ds:label>			
<!--			<ds:label key="distinct-datcats">distinct used Data Categories</ds:label>-->			
			<ds:label key="used-concepts">used Concept</ds:label>
			<ds:label key="available-concepts">available Concepts (in Metadata profile or used in CMD)</ds:label>
			<!--<ds:label key="blind-concepts">blind Concepts (not in public ISOcat)</ds:label>
			<ds:label key="unused-concepts">Concepts not used in CMD</ds:label>-->			
		</ds:labels>
		<ds:dataseries key="overall" label="Overall">
			<ds:value key="creation-date"><xsl:value-of select="current-date()"/></ds:value>
			<ds:value key="profiles"><xsl:value-of select="count($cmd-terms//Termset)"/></ds:value>
			<ds:value key="components"><xsl:value-of select="count($cmd-terms//Term[@type='CMD_Component'])"/></ds:value>
			<ds:value key="distinct-components"><xsl:value-of select="$count_distinct_components"/></ds:value>
			<ds:value key="elements"><xsl:value-of select="$count_elems"/></ds:value>
			<ds:value key="distinct-elements"><xsl:value-of select="$count_distinct_elems"/></ds:value>
			<ds:value key="elems-with-datcats"><xsl:value-of select="count(distinct-values($cmd-terms//Term[@type='CMD_Element'][@datcat[not(.='')]]/@id))"/></ds:value>
			<ds:value key="elems-without-datcats"><xsl:value-of select="count(distinct-values($cmd-terms//Term[@type='CMD_Element'][@datcat='']/@id))"/></ds:value>
			<!--<xsl:variable name="elems-without-datcats-ratio" select="count($cmd-terms//Term[@type='CMD_Element'][@datcat='']) div $count_elems"></xsl:variable>
			<ds:value key="elems-without-datcats-ratio" formatted="{format-number($elems-without-datcats-ratio, '0.00 %')}">
				<xsl:value-of select="$elems-without-datcats-ratio"/></ds:value>-->
			<xsl:variable name="elems-distinct-without-datcats-ratio" select="count(distinct-values($cmd-terms//Term[@type='CMD_Element'][@datcat='']/@id)) div $count_distinct_elems"></xsl:variable>
			<ds:value key="elems-without-datcats-ratio" formatted="{format-number($elems-distinct-without-datcats-ratio, '0.00 %')}">
				<xsl:value-of select="$elems-distinct-without-datcats-ratio"/></ds:value>
<!--			<ds:value key="distinct-datcats"><xsl:value-of select="$count_distinct_datcats"/></ds:value>-->
			<ds:value key="used-concepts"><xsl:value-of select="count($dcr-cmd-map//Concept)"/></ds:value>
<!--			<ds:value key="blind-concepts"><xsl:value-of select="count(//Concept[not(Term[@set='isocat'])])"/></ds:value>-->
			<ds:value key="available-concepts"><xsl:value-of select="count($dcr-terms//Concept)"/></ds:value>
<!--			<ds:value key="unused-concepts"><xsl:value-of select="count($dcr-terms//Concept except $dcr-terms//Concept[@id=$dcr-cmd-map//Concept/@id])"/></ds:value>-->
		</ds:dataseries>	
		
	</ds:dataset>
			<!--
		    <tr><td>profileDescription</td><td align="right"><xsl:value-of select="count(//profileDescription)"/></td></tr>			
			<tr><td>componentDescription</td><td align="right"><xsl:value-of select="count(//componentDescription)"/></td></tr>			
			<tr><td>CMD_ComponentSpec</td><td align="right"><xsl:value-of select="count(//CMD_ComponentSpec)"/></td></tr>
			<tr><td>profiles</td><td align="right"><xsl:value-of select="count(//CMD_ComponentSpec[@isProfile='true'])"/></td></tr>
			<tr><td>CMD_Component</td><td align="right"><xsl:value-of select="count(//CMD_Component)"/></td></tr>			
			<tr><td>distinct CMD_Component</td><td align="right"><xsl:value-of select="count(distinct-values(//CMD_Component/@name))"/></td></tr>			
			<tr><td>CMD_Element</td><td align="right"><xsl:value-of select="count(//CMD_Element)"/></td></tr>						
			<tr><td>distinct CMD_Element</td><td align="right"><xsl:value-of select="count(distinct-values(//CMD_Element/@name))"/></td></tr>						
			<tr><td>CMD_Elements without ConceptLink</td><td align="right"><xsl:value-of select="count(distinct-values(//CMD_Element[@ConceptLink='' or not(@ConceptLink)]/@name))"/></td></tr>						
			<tr><td>conceptlinks</td><td align="right"><xsl:value-of select="count(//@ConceptLink)"/></td></tr>						
			<tr><td>conceptlinks (without lang-codes ISO639)</td><td align="right"><xsl:value-of select="count($concepts_nolang)"/></td></tr>						
			<tr><td>distinct conceptlinks (without lang-codes)</td><td align="right"><xsl:value-of select="count(distinct-values($concepts_nolang))"/></td></tr>						
			<tr><td>distinct CMD_Elem-conceptlinks</td><td align="right"><xsl:value-of select="count(distinct-values($concepts_nolang[parent::CMD_Element]))"/></td></tr> -->						
			<!-- <tr><td>datcats in isocat-profile:Metadata#5</td><td align="right"><xsl:value-of select="count($isocat//dcif:dataCategory)"/></td></tr> -->						
			<!--
			<tr><td>elem matrix</td><td align="right"><xsl:value-of select="count($term_matrix/Term)"/></td></tr>						
			<tr><td>distinct profile-elem</td><td align="right"><xsl:value-of select="count(distinct-values($term_matrix/Term/concat(@profile,@elem)))"/></td></tr>
			<tr><td>distinct profile-datcat</td><td align="right"><xsl:value-of select="count(distinct-values($term_matrix/Term/concat(@profile,@datcat)))"/></td></tr>
			<tr><td>distinct parent-elem</td><td align="right"><xsl:value-of select="count(distinct-values($term_matrix/Term/concat(@parent,@elem)))"/></td></tr>
			<tr><td>distinct profile-parent-elem</td><td align="right"><xsl:value-of select="count(distinct-values($term_matrix/Term/concat(@profile,@parent,@elem)))"/></td></tr>
			-->
	
</xsl:template>			

<xsl:template name="summary-terms">
    <table>
    	<caption>Term types</caption>
        <tbody>        	
           <xsl:for-each-group select="$dcr-cmd-map//Term" group-by="concat(@set,@type)">
               <tr><td><xsl:value-of select="concat(@set,'-', @type)"></xsl:value-of></td><td align="right"><xsl:value-of select="count(current-group())"/></td></tr>       
           </xsl:for-each-group>            
        </tbody>
     </table>
</xsl:template>

	
<xsl:template name="summary-profiles">
	
	
	
	<ds:dataset key="profile" label="Profiles" count="{count($cmd-terms//Termset)}">
		<ds:labels>
			<xsl:for-each select="$profile-info-fields-sequence">
				<ds:label key="{.}" ><xsl:value-of select="."/></ds:label>
			</xsl:for-each>
			<ds:label key="components">Components</ds:label>
			<ds:label key="distinct-components">distinct Components</ds:label>
			<ds:label key="elements">Elements</ds:label>
			<ds:label key="distinct-elements">distinct Elements</ds:label>
			<ds:label key="distinct-datcats"></ds:label>
			<ds:label key="elems-with-datcats"></ds:label>
			<ds:label key="elems-without-datcats"></ds:label>
			<ds:label key="elems-without-datcats-ratio" >ratio of elements without DatCats</ds:label>
			
		</ds:labels>
				
	    <xsl:for-each select="$cmd-terms//Termset" >		          
			<xsl:sort select="@name" order="ascending"/>
	    	<xsl:variable name="profile_id" select="xs:string(@id)" ></xsl:variable>
	    	<xsl:variable name="info" select="info" ></xsl:variable>
	        <xsl:variable name="count_elems" select="count(./Term[@type='CMD_Element'])" ></xsl:variable>
	        <xsl:variable name="count_distinct_datcats" select="count(distinct-values(./Term[@type='CMD_Element']/@datcat[not(.='')]))" ></xsl:variable>
					
	    	<ds:dataseries key="{@id}" label="{@name}" >
	    		<xsl:for-each select="$profile-info-fields-sequence">
	    			<ds:value key="{.}" ><xsl:value-of select="$info/*[local-name()=current()]" /></ds:value>
	    		</xsl:for-each>
<!--		    	<ds:value key="distinct-components"><xsl:value-of select="$count_distinct_components"/></ds:value>-->
	    		<xsl:call-template name="list">
	    			<xsl:with-param name="key">components</xsl:with-param>
<!--	    			 exclude the profile as component-->
	    			<xsl:with-param name="data" select="./Term[@type='CMD_Component'][not(xs:string(@id)=$profile_id)]"></xsl:with-param>
	    		</xsl:call-template>
<!--		    	<ds:value key="components"><xsl:value-of select="count(./Term[@type='CMD_Component'])"/></ds:value>-->
	    		<ds:value key="distinct-components"><xsl:value-of select="count(distinct-values(.//Term[@type='CMD_Component'][not(@parent='')]/@id))" /></ds:value>
	    		<xsl:call-template name="list">
	    			<xsl:with-param name="key">elements</xsl:with-param>
	    			<xsl:with-param name="data" select="./Term[@type='CMD_Element']"></xsl:with-param>
	    		</xsl:call-template>
	    		<ds:value key="distinct-elements"><xsl:value-of select="count(distinct-values(.//Term[@type='CMD_Element'][not(@parent='')]/@id))" /></ds:value>
<!--		    	<ds:value key="elements"><xsl:value-of select="$count_elems"/></ds:value>-->
	    		<xsl:call-template name="list">
	    			<xsl:with-param name="key">distinct-datcats</xsl:with-param>
	    			<xsl:with-param name="type">datcat</xsl:with-param>
	    			<xsl:with-param name="data" select="distinct-values(./Term[@type='CMD_Element']/@datcat[not(.='')])"></xsl:with-param>
	    		</xsl:call-template>
	    		
<!--	    		<ds:value key=""><xsl:value-of select="$count_distinct_datcats"/></ds:value>-->
	    		<ds:value key="elems-with-datcats"><xsl:value-of select="count(./Term[@type='CMD_Element']/@datcat[not(.='')])"/></ds:value>
	    		<ds:value key="elems-without-datcats"><xsl:value-of select="count(./Term[@type='CMD_Element'][@datcat=''])"/></ds:value>
		    	<xsl:variable name="elems-without-datcats-ratio" select="if($count_elems &gt; 0) then count(./Term[@type='CMD_Element'][@datcat='']) div $count_elems else 0"></xsl:variable>
	    		<ds:value key="elems-without-datcats-ratio" formatted="{format-number($elems-without-datcats-ratio, '0.00 %')}">
	    		<xsl:value-of select="$elems-without-datcats-ratio"/></ds:value>
	    	
	    	</ds:dataseries>
		</xsl:for-each>
	</ds:dataset>
</xsl:template>

<xsl:template name="summary-components">
		
	<ds:dataset key="component" label="Components" count="{count($cmd-terms//Term[@type='CMD_Component'])}">
			<ds:labels>
				<ds:label key="used">used in total</ds:label>
				<ds:label key="profiles">used in Profiles</ds:label>
				<ds:label key="components">has Components</ds:label>
				<ds:label key="distinct-elems">has Elements</ds:label>
				<ds:label key="elems-with-datcats">Elements with DatCats</ds:label>
				<ds:label key="distinct-datcats">uses DatCats</ds:label>
				<ds:label key="elems-without-datcats">Elements without DatCats</ds:label>
				<ds:label key="elems-without-datcats-ratio" >ratio of elements without DatCats</ds:label>
			</ds:labels>
			
		<xsl:for-each-group select="$cmd-terms-nested//Term[@type='CMD_Component']" group-by="@id">		          
				<xsl:sort select="@name" order="ascending"/>
			<xsl:variable name="count_usage" select="count(current-group())" ></xsl:variable>
			<xsl:variable name="count_using_profiles" select="count(distinct-values(current-group()/ancestor::Termset/@id))" ></xsl:variable>
			<xsl:variable name="count_distinct_elems" select="count(distinct-values(current-group()//Term[@type='CMD_Element']/@id))" ></xsl:variable>
<!--			<xsl:variable name="count_distinct_elem_datcats" select="count(distinct-values(current-group()//Term[@type='CMD_Element']/@datcat[not(.='')]))" ></xsl:variable>-->
						<xsl:variable name="count_distinct_datcats" select="count(distinct-values(current-group()//Term/@datcat[not(.='')]))" ></xsl:variable>
				
				<ds:dataseries key="{@id}" label="{@name}" >
					<!--		    	<ds:value key="distinct-components"><xsl:value-of select="$count_distinct_components"/></ds:value>-->
					<ds:value key="used"><xsl:value-of select="$count_usage"/></ds:value>
					<ds:value key="profiles"><xsl:value-of select="$count_using_profiles"/></ds:value>
					<ds:value key="components"><xsl:value-of select="count(distinct-values(current-group()//Term[@type='CMD_Component']/@id))"/></ds:value>
					<!--		    	<ds:value key="distinct-elements"><xsl:value-of select="$count_distinct_elems"/></ds:value>-->
					<ds:value key="distinct-elems"><xsl:value-of select="$count_distinct_elems"/></ds:value>
					<ds:value key="elems-with-datcats"><xsl:value-of select="count(distinct-values(current-group()//Term[@type='CMD_Element'][@datcat[not(.='')]]/@id))"/></ds:value>
					<ds:value key="distinct-datcats"><xsl:value-of select="$count_distinct_datcats"/></ds:value>
					<xsl:variable name="elems-without-datcats" select="count(distinct-values(current-group()//Term[@type='CMD_Element'][@datcat='']/@id))" />
					<ds:value key="elems-without-datcats"><xsl:value-of select="$elems-without-datcats"/></ds:value>
					<xsl:variable name="elems-without-datcats-ratio" select="if ($count_distinct_elems &gt; 0) then $elems-without-datcats div $count_distinct_elems else 0"></xsl:variable>
					<ds:value key="elems-without-datcats-ratio" formatted="{format-number($elems-without-datcats-ratio, '0.00 %')}">
						<xsl:value-of select="$elems-without-datcats-ratio"/></ds:value>
				</ds:dataseries>
			</xsl:for-each-group>
		</ds:dataset>
	</xsl:template>
	

<xsl:template name="summary-datcats">
	
	<ds:dataset key="datcat" label="Data Categories" count="{count($dcr-cmd-map//Concept)}">
		<ds:labels>
			<ds:label key="def">Definition</ds:label>
			<ds:label key="used-in-profiles">used in Profiles</ds:label>
			<ds:label key="referenced-by-elements">referenced by Elements</ds:label>
		</ds:labels>
		
		
		<!--<Term set="cmd" type="full-path" schema="clarin.eu:cr1:p_1297242111880"
			id="#applicationType">AnnotationTool.applicationType</Term>-->
		<xsl:for-each select="$dcr-cmd-map//Concept" >		          
			<xsl:sort select="lower-case(Term[@type='label'][1])" order="ascending"/>
			
			<xsl:variable name="def" select="$dcr-terms//Concept[@id=current()/@id]/info[1]" ></xsl:variable>
			<xsl:variable name="count_elems" select="count(Term[@type='full-path'])" ></xsl:variable>
			<xsl:variable name="profiles" select="distinct-values(Term[@type='full-path']/@schema)" ></xsl:variable>
			
			<ds:dataseries key="{@id}" label="{Term[@type='label'][1]}" >
				<!--		    	<ds:value key="distinct-components"><xsl:value-of select="$count_distinct_components"/></ds:value>-->
				
				<ds:value key="def"><xsl:value-of select="$def"/></ds:value>
				<xsl:call-template name="list">
					<xsl:with-param name="key" >used-in-profiles</xsl:with-param>
					<xsl:with-param name="type" >profile</xsl:with-param>
					<xsl:with-param name="data" select="$profiles" />
				</xsl:call-template>
				
				<ds:value key="referenced-by-elements"><xsl:value-of select="$count_elems"/></ds:value>
			</ds:dataseries>
		</xsl:for-each>
	</ds:dataset>
	<!--
		<table>
			
			<thead><tr><th rowspan="2">id</th><th rowspan="2">name</th>
				<th colspan="3" >count </th><th rowspan="2">elems</th></tr>
				<tr><th>profile*</th><th >all*</th><th>elems</th> </tr>		</thead>
			<tbody>		
				<xsl:for-each-group select="$term_matrix/Term" group-by="@datcat">
					<xsl:sort select="lower-case(@datcat)" order="ascending"/>					
					<tr><td valign="top"><xsl:value-of select="my:shortURL(@datcat)"/></td>
						<td valign="top"><xsl:value-of select="my:rewriteURL(@datcat)"/></td>
						<td valign="top" align="right">
							<span class="term_detail_caller" ><xsl:value-of select="count(distinct-values(current-group()/@profile))"/></span>
							<div class="term_detail" >
								<div class="box_heading"><xsl:value-of select="my:rewriteURL(@datcat)"/></div>
								<ul>
									<xsl:for-each select="distinct-values(current-group()/@profile)" >
										<li><xsl:value-of select="." /></li>
									</xsl:for-each>
								</ul>
							</div>							
						</td>
						<td valign="top" align="right">
							<span class="term_detail_caller" ><xsl:value-of select="count(current-group())"/></span>
							<div class="term_detail" >
								<div class="box_heading"><xsl:value-of select="my:rewriteURL(@datcat)"/></div>
								<ul>
									<xsl:for-each-group select="current-group()" group-by="@profile" >
										<li><xsl:value-of select="@profile" />
											<ul>
												<xsl:for-each select="current-group()/@comppath" >
													<li><xsl:value-of select="." /></li>
												</xsl:for-each>
											</ul>
										</li>
									</xsl:for-each-group>
								</ul>
							</div>							
						</td>
						<td valign="top" align="right"><xsl:value-of select="count(distinct-values(current-group()/@elem))"/></td>						
						
						<td width="40%">						
							<xsl:for-each select="distinct-values(current-group()/@elem)">
								<xsl:sort select="." />
								<xsl:value-of select="."/>,
							</xsl:for-each>
						</td>												
					</tr>					
				</xsl:for-each-group>
			</tbody>
		</table>-->
	</xsl:template>
	

<!--
	<table>
		<caption>Components with DatCats</caption>
		<thead><tr><th>comp-name</th><th colspan="3">datcat</th><th>count</th><th>profiles</th></tr></thead>
		<tbody>			
			<xsl:for-each-group select="$cmd-terms//Term[@type='CMD_Component'][@datcat[not(.='')]]" group-by="@id">				
					<xsl:sort select="parent::Termset/@name" />				
				<tr>					
<!-\-					<td><xsl:value-of select="@id"/></td>-\->
					<td><xsl:value-of select="@name"/></td>
					<td><xsl:value-of select="my:shortURL(@datcat)"/></td>
					<td><xsl:value-of select="$dcr-terms//Concept[@id=current()/@datcat]/Term[@type='mnemonic']" /></td>
					<td><xsl:value-of select="$dcr-terms//Concept[@id=current()/@datcat]/@datcat-type" /></td>					
					<td><xsl:value-of select="count(current-group())"/></td>
					<td><xsl:value-of select="count(current-group()/parent::Termset)"/> (<xsl:value-of select="parent::Termset/@name"/>)</td>
				</tr>
			</xsl:for-each-group>
		</tbody>
	</table>-->

	
<xsl:template name="ambigue-terms">	
	<ds:dataset key="ambigue-terms" label="Ambigue terms" >
		<ds:label key="term">Term</ds:label>
		<ds:label key="usage">usage</ds:label>
		<ds:label key="datcat">distinct DatCats</ds:label>
		<ds:label key="profiles">used in Profiles</ds:label>
			<xsl:for-each-group select="$cmd-terms//Term" group-by="lower-case(@name)">
				<!--				<xsl:sort select="lower-case(@name)" />				-->
				<xsl:sort select="count(distinct-values(current-group()/@datcat))" order="descending" data-type="number"></xsl:sort>
				<xsl:if test="count(distinct-values(current-group()/@id)) &gt; 1"  >
					<ds:dataseries key="{@name}" label="{@name}">
<!--						<ds:value key="term"><xsl:value-of select="@name"></xsl:value-of></ds:value>-->
						<xsl:call-template name="list">
								<xsl:with-param name="key">usage</xsl:with-param>
								<xsl:with-param name="data" select="distinct-values(current-group()/xs:string(@id))"></xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="list">
							<xsl:with-param name="key">datcat</xsl:with-param>
							<xsl:with-param name="type">datcat</xsl:with-param>
							<xsl:with-param name="data" select="distinct-values(current-group()/xs:string(@datcat))"></xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="list">
							<xsl:with-param name="key">profiles</xsl:with-param>
							<xsl:with-param name="type">profile</xsl:with-param>
							<xsl:with-param name="data" select="distinct-values(current-group()/ancestor::Termset/@id)"></xsl:with-param>
						</xsl:call-template>
					</ds:dataseries>
				</xsl:if>
				
				<!--
				<tr>					
					<!-\-					<td><xsl:value-of select="@id"/></td>-\->
					<td><xsl:value-of select="@name"/></td>
					<td><xsl:value-of select="count(distinct-values(current-group()/@datcat))"/></td>					
					<td><xsl:value-of select="count(distinct-values(current-group()/@id))"/></td>
				</tr>-->
			</xsl:for-each-group>
	</ds:dataset>
</xsl:template>
	
	
<xsl:template name="list" >
<xsl:param name="key" ></xsl:param>	
<xsl:param name="type" ></xsl:param>
<xsl:param name="data" ></xsl:param>
	
	<xsl:variable name="processed_data">
		<xsl:choose>
			<xsl:when test="$data[1] instance of element(li)">
				<xsl:copy-of select="$data" />
			</xsl:when>
			<xsl:when test="$data[1] instance of element()">
				<xsl:for-each select="$data">
					<ds:li key="{(@id,@path,@name)[1]}" title="{(@path,@id,@key,@name)[1]}"><xsl:value-of select="(@name,@label,@key, @path, @id)[1]"></xsl:value-of></ds:li>
				</xsl:for-each>
			</xsl:when>
			<!--
				<xsl:for-each select="$data">
					<li key="{.}"><xsl:value-of select="."></xsl:value-of></li>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$data[1] instance of xs:untypedAtomic">
				<li key="data"><xsl:value-of select="$data"></xsl:value-of></li>
				<xsl:for-each select="$data/node()">
					<li key="{.}"><xsl:value-of select="."></xsl:value-of></li>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$data[1] instance of attribute()">
				<xsl:for-each select="$data">
					<li key="{xs:string(.)}"><xsl:value-of select="xs:string(.)"></xsl:value-of></li>
				</xsl:for-each>
			</xsl:when>-->
			<xsl:otherwise>
				<xsl:for-each select="$data">
					
					<xsl:variable name="label" >
						<xsl:choose>
							<xsl:when test=".=''">_EMPTY_</xsl:when>
							<xsl:when test="$type='profile'">
								<xsl:value-of select="$all_profiles[@id=xs:string(current())]/@name" ></xsl:value-of>		
							</xsl:when>
							<xsl:when test="$type='datcat'">
								<xsl:value-of select="$all_datcats[@id=xs:string(current())]/Term[@type='label'][1]/text()" ></xsl:value-of>		
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="xs:string(.)"></xsl:value-of>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
						
					<ds:li key="{xs:string(.)}"><xsl:value-of select="($label, my:shortURL(xs:string(.)))[.!=''][1]"></xsl:value-of></ds:li>
				</xsl:for-each>	
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<ds:value key="{$key}" abs="{count($processed_data/*)}" >
		<ds:list>
			<xsl:for-each select="$processed_data/*" >
				<xsl:sort select="lower-case(.)" ></xsl:sort>
				<!--<xsl:variable name="profile-name" select="$all_profiles[@id=current()]/@name"></xsl:variable>-->
<!--				<li><a href="#{.}" ><xsl:value-of select="$profile-name" /></a></li>-->
					<xsl:copy-of select="."></xsl:copy-of>
			</xsl:for-each>
		</ds:list>
	</ds:value>
</xsl:template>
	<!--
<xsl:template name="list-terms">
	
	<div id="term-list" >
		<span class="box_heading" >Elements</span> <span class="note">|<xsl:value-of select="count($term_matrix/Term)" />/<xsl:value-of select="count(distinct-values($term_matrix/Term/@elem))" />|</span>
		
			<ul>
				<xsl:for-each-group select="$term_matrix/Term" group-by="lower-case(@elem)">
					<xsl:sort select="lower-case(@elem)" order="ascending"/>					
						<li><span class="term_detail_caller" ><a href="{@elem}" ><xsl:value-of select="@elem"/></a></span>
							
									<span class="note" >
										|<xsl:value-of select="count(distinct-values(current-group()/@datcat))"/>/
											<xsl:value-of select="count(distinct-values(current-group()/@profile))"/>/
											<xsl:value-of select="count(current-group())"/>|
											<!-\- <xsl:value-of select="count(distinct-values(current-group()//node()[not(name()='CMD_Element')]/@ConceptLink))"/> -\->
									</span>
									<span class="cmd cmd_filter"><xsl:text> </xsl:text></span><span class="cmd cmd_detail" ><xsl:text> </xsl:text></span><span class="cmd cmd_columns" ><xsl:text> </xsl:text></span>
								<div class="term_detail" >
									<div class="box_heading"><xsl:value-of select="@elem"/></div>
										<ul>
											<xsl:for-each-group select="current-group()" group-by="@datcat">
												<li><xsl:value-of select="my:shortURL(@datcat)"/>
													<ul>
														<xsl:for-each-group select="current-group()" group-by="@profile" >
															<li><xsl:value-of select="@profile" />
																	<ul>
																		<xsl:for-each select="current-group()/@comppath" >
																				<li><span class="cmd cmd_filter"><xsl:text> </xsl:text></span> <span class="cmd cmd_detail"><xsl:text> </xsl:text></span> <span class="cmd cmd_columns"><xsl:text> </xsl:text></span>
																					<a href="{.}" ><xsl:value-of select="." /></a></li>
																		</xsl:for-each>
																	</ul>
															</li>
														</xsl:for-each-group>
													</ul>
												</li>						
											</xsl:for-each-group>
										</ul>
								</div>							
						
						</li>
				</xsl:for-each-group>
			</ul>	
	</div>
</xsl:template>-->

</xsl:stylesheet>