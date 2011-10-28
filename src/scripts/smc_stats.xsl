<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:my="myFunctions"
  xmlns:dcif="http://www.isocat.org/ns/dcif"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"   
  xmlns:owl="http://www.w3.org/2002/07/owl#"
  xmlns:dcr="http://www.isocat.org/ns/dcr.rdf#"
  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
  xmlns:dcam="http://purl.org/dc/dcam/"
  exclude-result-prefixes=""
>
<!-- 
<purpose> statistics about the smc-data
relies on the data prepared in smc_commons.xsl
currently the main map is produced in a separate step and loaded from static-xml (map_file)</purpose>
<params>

</params>
<history>
	<change on="2011-10-27" type="created" by="vr">from complist2terms_201109.xsl (via smc_init.xsl)</change>	
</history>
-->
 
<xsl:import href="cmd_commons.xsl"/>
    
<xsl:output method="xml" indent="yes" />
	
<xsl:include href="smc_commons.xsl"/>
	
  <xsl:param name="title" select="'SMC Stats'" />
    
    <!--
 <xsl:param name="map_file" select="'../../../../SMC/output/map_full.xml'" />  
 <xsl:variable name="map" select="document($map_file)" />
    -->
    
<xsl:template name="continue-root">
        <xsl:call-template name="summary-overall"></xsl:call-template>
    <xsl:call-template name="summary-terms"></xsl:call-template>
    <xsl:call-template name="summary-cmd"></xsl:call-template>
<!--    <xsl:call-template name="summary-concepts"></xsl:call-template>-->
 </xsl:template>			
	
	
<xsl:template name="summary-overall">
		<table>
		<tbody>
		    <tr><td>creation date</td><td align="right"><xsl:value-of select="current-date()"/></td></tr>
		    <tr><td>available Concepts</td><td align="right"><xsl:value-of select="count($dcr_terms//Concept)"/></td></tr>
		    <tr><td>used Concept</td><td align="right"><xsl:value-of select="count($map//Concept)"/></td></tr>		    
		    <tr><td>blind Concepts (not in isocat)</td><td align="right"><xsl:value-of select="count(//Concept[not(Term[@set='isocat'])])"/></td></tr>
		    <tr><td>unused Concepts</td><td align="right"><xsl:value-of select="count($dcr_terms//Concept except $dcr_terms//Concept[@id=$map//Concept/@id])"/></td></tr>
		    <tr><td>Term</td><td align="right"><xsl:value-of select="count($map//Term)"/></td></tr>
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
		</tbody>
</table>
	
</xsl:template>			

<xsl:template name="summary-terms">
    <table>
        <tbody>
           <xsl:for-each-group select="$map//Term" group-by="concat(@set,@type)">
               <tr><td><xsl:value-of select="concat(@set,'-', @type)"></xsl:value-of></td><td align="right"><xsl:value-of select="count(current-group())"/></td></tr>       
           </xsl:for-each-group>            
        </tbody>
     </table>
</xsl:template>

<xsl:template name="summary-concepts">
    <table>
        <tbody>
            <xsl:for-each select="$map//Concept[not(Term[@set='isocat'])]" >
                <tr><td><xsl:value-of select="@id"></xsl:value-of></td>
                    </tr>       
            </xsl:for-each>            
        </tbody>
    </table>
</xsl:template>

    
<xsl:template name="summary-cmd">
	
	<table>
		<caption>Profiles |<xsl:value-of select="count($cmd_terms//Termset)" />|</caption>
	    <thead><tr><th>name</th><th>|comp|</th><th>|elems|</th><th colspan="2">|distinct datcat|</th><th colspan="2">|elems w/o datcat|</th></tr></thead>
		<tbody>		
		    <xsl:for-each select="$cmd_terms//Termset" >		          
					<xsl:sort select="name" order="ascending"/>
		        <xsl:variable name="count_elems" select="count(./Term[@type='CMD_Element'])" ></xsl:variable>
		        <xsl:variable name="count_distinct_datcats" select="count(distinct-values(./Term[@type='CMD_Element']/@datcat[not(.='')]))" ></xsl:variable>
						<tr><td><xsl:value-of select="@name"/></td>									
						    <td align="right"><xsl:value-of select="count(./Term[@type='CMD_Component'])"/></td>
							<td align="right"><xsl:value-of select="$count_elems"/></td>
						    <td align="right"><xsl:value-of select="$count_distinct_datcats"/></td>
						    <td align="right"><xsl:value-of select="count(./Term[@type='CMD_Element']/@datcat[not(.='')])"/></td>
						    <td align="right"><xsl:value-of select="count(./Term[@type='CMD_Element'][@datcat=''])"/></td>			
						    <td align="right"><xsl:value-of select="format-number(count(./Term[@type='CMD_Element'][@datcat='']) div $count_elems, '0.00 %')"/></td>
						</tr>
					
				</xsl:for-each>
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