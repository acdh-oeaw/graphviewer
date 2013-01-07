<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  
  exclude-result-prefixes="xs"
  
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

	<xsl:output method="html" indent="yes" />
	
  <xsl:param name="title" select="'SMC Stats'" />
    
    <!--
 <xsl:param name="map_file" select="'../../../../SMC/output/map_full.xml'" />  
 <xsl:variable name="map" select="document($dcr-cmd-map_file)" />
    -->
 
	<xsl:variable name="count_elems" select="count($cmd-terms//Term[@type='CMD_Element'])" ></xsl:variable>
	<xsl:variable name="count_distinct_datcats" select="count(distinct-values($cmd-terms//Term[@type='CMD_Element']/@datcat[not(.='')]))" ></xsl:variable>
	<xsl:variable name="count_distinct_components" select="count(distinct-values($cmd-terms//Term[@type='CMD_Component'][not(@parent='')]/@id))" ></xsl:variable>
	<xsl:variable name="count_standalone_components" select="count(distinct-values($cmd-terms//Term[@type='CMD_Component'][not(@parent='')]/@id[not(contains(.,'#'))]))" ></xsl:variable>
	<xsl:variable name="count_distinct_elems" select="count(distinct-values($cmd-terms//Term[@type='CMD_Element']/@id))" ></xsl:variable>
	<xsl:variable name="count_components_datcat" select="count(distinct-values($cmd-terms//Term[@type='CMD_Component'][@datcat[not(.='')]]/@id))" ></xsl:variable>	
	
 
<!--<xsl:template name="continue-root">-->	
	<xsl:template match="/">
		<multiresult>
	        <xsl:call-template name="summary-overall"></xsl:call-template>
			<xsl:call-template name="summary-profiles"></xsl:call-template>
		</multiresult>
<!--		<xsl:call-template name="summary-concepts"></xsl:call-template>
		<xsl:call-template name="summary-terms"></xsl:call-template>	
    	<xsl:call-template name="summary-cmd"></xsl:call-template>
		<xsl:call-template name="ambigue-elems"></xsl:call-template>
-->    
 </xsl:template>			
	
	
<xsl:template name="summary-overall">
		
	<dataset key="summary">
		<labels>
			<label key="creation-date">Created</label>
			<label key="available-concepts">available Concepts</label>
			<label key="used-concepts">used Concept</label>
			<label key="blind-concepts">blind Concepts (not in isocat)</label>
			<label key="unused-concepts">unused Concepts</label>
			<label key="count-terms">Term</label>
			
			<label key="distinct-components"></label>
			<label key="components"></label>
			<label key="distinct-elements"></label>
			<label key="elements"></label>
			<label key="distinct-datcats"></label>
			<label key="elems-with-datcats"></label>
			<label key="elems-without-datcats"></label>
			<label key="elems-without-datcats-ratio" ></label>
		</labels>
		<dataseries key="overall">
			<value key="creation-date"><xsl:value-of select="current-date()"/></value>
			<value key="available-concepts"><xsl:value-of select="count($dcr-terms//Concept)"/></value>
			<value key="used-concepts"><xsl:value-of select="count($dcr-cmd-map//Concept)"/></value>
			<value key="blind-concepts"><xsl:value-of select="count(//Concept[not(Term[@set='isocat'])])"/></value>
			<value key="unused-concepts"><xsl:value-of select="count($dcr-terms//Concept except $dcr-terms//Concept[@id=$dcr-cmd-map//Concept/@id])"/></value>
			<value key="count-terms" ><xsl:value-of select="count($dcr-cmd-map//Term)"/></value>
			<value key="distinct-components"><xsl:value-of select="$count_distinct_components"/></value>
			<value key="components"><xsl:value-of select="count($cmd-terms//Term[@type='CMD_Component'])"/></value>
			<value key="distinct-elements"><xsl:value-of select="$count_distinct_elems"/></value>
			<value key="elements"><xsl:value-of select="$count_elems"/></value>
			<value key="distinct-datcats"><xsl:value-of select="$count_distinct_datcats"/></value>
			<value key="elems-with-datcats"><xsl:value-of select="count($cmd-terms//Term[@type='CMD_Element']/@datcat[not(.='')])"/></value>
			<value key="elems-without-datcats"><xsl:value-of select="count($cmd-terms//Term[@type='CMD_Element'][@datcat=''])"/></value>
			<xsl:variable name="elems-without-datcats-ratio" select="count($cmd-terms//Term[@type='CMD_Element'][@datcat='']) div $count_elems"></xsl:variable>
			<value key="elems-without-datcats-ratio" formatted="{format-number($elems-without-datcats-ratio, '0.00 %')}">
				<xsl:value-of select="$elems-without-datcats-ratio"/></value>
		</dataseries>	
		
	</dataset>
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

<xsl:template name="summary-concepts">
	
    <table>
    	<caption>Data Categories Sets</caption>
        <tbody>
            <xsl:for-each select="$dcr-terms//Termset" >
                <tr><td><xsl:value-of select="@set"></xsl:value-of></td>
                	<td align="right"><xsl:value-of select="count(Concept)"></xsl:value-of></td>
                    </tr>       
            </xsl:for-each>            
        </tbody>
    </table>
</xsl:template>

    
<xsl:template name="summary-cmd">
	
	<table>
		<tbody>
			<tr><td>distinct components</td><td align="right"><xsl:value-of select="$count_distinct_components"/></td></tr>
			<tr><td>distinct standalone components</td><td align="right"><xsl:value-of select="$count_standalone_components"/></td></tr>
			<tr><td>distinct elements</td><td align="right"><xsl:value-of select="$count_distinct_elems"/></td></tr>	
			<tr><td>elements with datcats </td><td align="right"><xsl:value-of select="format-number(count($cmd-terms//Term[@type='CMD_Element'][not(@datcat='')]) div $count_elems, '0.00 %')"/></td></tr>
			<tr><td>components with datcats</td><td align="right"><xsl:value-of select="$count_components_datcat"/></td></tr>
		</tbody>
	</table>
</xsl:template>
	
<xsl:template name="summary-profiles">
	
	<dataset key="profiles" label="Profiles" count="{count($cmd-terms//Termset)}">
		<labels>
			<label key="components"></label>
			<label key="elements"></label>
			<label key="distinct-datcats"></label>
			<label key="elems-with-datcats"></label>
			<label key="elems-without-datcats"></label>
			<label key="elems-without-datcats-ratio" ></label>
		</labels>
				
	    <xsl:for-each select="$cmd-terms//Termset" >		          
			<xsl:sort select="@name" order="ascending"/>
	        <xsl:variable name="count_elems" select="count(./Term[@type='CMD_Element'])" ></xsl:variable>
	        <xsl:variable name="count_distinct_datcats" select="count(distinct-values(./Term[@type='CMD_Element']/@datcat[not(.='')]))" ></xsl:variable>
					
	    	<dataseries key="{@id}" label="{@name}" >
<!--		    	<value key="distinct-components"><xsl:value-of select="$count_distinct_components"/></value>-->
		    	<value key="components"><xsl:value-of select="count(./Term[@type='CMD_Component'])"/></value>
<!--		    	<value key="distinct-elements"><xsl:value-of select="$count_distinct_elems"/></value>-->
		    	<value key="elements"><xsl:value-of select="$count_elems"/></value>
		    	<value key="distinct-datcats"><xsl:value-of select="$count_distinct_datcats"/></value>
		    	<value key="elems-with-datcats"><xsl:value-of select="count(./Term[@type='CMD_Element']/@datcat[not(.='')])"/></value>
		    	<value key="elems-without-datcats"><xsl:value-of select="count(./Term[@type='CMD_Element'][@datcat=''])"/></value>
		    	<xsl:variable name="elems-without-datcats-ratio" select="count(./Term[@type='CMD_Element'][@datcat='']) div $count_elems"></xsl:variable>
		    	<value key="elems-without-datcats-ratio" formatted="{format-number($elems-without-datcats-ratio, '0.00 %')}">
	    		<xsl:value-of select="$elems-without-datcats-ratio"/></value>
	    	</dataseries>
		</xsl:for-each>
	</dataset>
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

	
<xsl:template name="ambigue-elems">	
	<table>
		<caption>Ambigue elements</caption>
		<thead><tr><th>comp-name</th><th colspan="3">datcat</th><th>count</th><th>profiles</th></tr></thead>
		<tbody>			
			<xsl:for-each-group select="$cmd-terms//Term" group-by="lower-case(@name)">				
<!--				<xsl:sort select="lower-case(@name)" />				-->
				<xsl:sort select="count(distinct-values(current-group()/@datcat))" order="descending" data-type="number"></xsl:sort>
				<tr>					
					<!--					<td><xsl:value-of select="@id"/></td>-->
					<td><xsl:value-of select="@name"/></td>
					<td><xsl:value-of select="count(distinct-values(current-group()/@datcat))"/></td>					
					<td><xsl:value-of select="count(distinct-values(current-group()/@id))"/></td>
				</tr>
			</xsl:for-each-group>
		</tbody>
	</table>
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
	<!--
<xsl:template name="list-datcats">
	
	<table>
		<caption>DatCats |<xsl:value-of select="count(distinct-values($term_matrix/Term/@datcat))" />| <span class="note">* Click on numbers to see detail </span></caption>
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
	</table>
	</xsl:template>-->

</xsl:stylesheet>