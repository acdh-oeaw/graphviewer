<?xml version="1.0" encoding="UTF-8"?>

<!-- 
    $Rev: 74 $ 
    $Date: 2010-03-23 $ 
    
    created based on comp2schema.xsl vronk
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcr="http://www.isocat.org"
    xmlns:my="myFunctions"
	 exclude-result-prefixes="xs dcr my" >
	<xsl:import href="smc_commons.xsl"/>
	<xsl:include href="cs-commons/commons_v1.xsl"	/>

	<xsl:strip-space elements="*"/>
	
	
      <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>  
		
	<xsl:param name="format"  select="'htmltable'"/> <!-- table|list -->
	<xsl:param name="display_values_limit" select="10" />	
	<xsl:param name="title" 
		select="concat('Component view: ', if(/CMD_ComponentSpec/Header/Name/text()) then /CMD_ComponentSpec/Header/Name/text() else /CMD_ComponentSpec/CMD_Component[1]/@name)" />				
	
    <!--  includes-mode
    	  and params  
    		moved to cmd_commons.xsl -->
    
    <!-- main -->
    <!-- <xsl:template match="/"> -->
    <xsl:template name="continue-root"> 
        <!-- Resolve all includes -->
        <xsl:variable name="tree" select="/*">
<!--            <xsl:apply-templates mode="include"/>-->
        </xsl:variable>

	        <!-- Process the complete tree -->        	        
	        
		<xsl:choose>
    	 	<xsl:when test="$format='comp2htmldetail'" >
    	 			<div id="compviewdetail">
	    				<xsl:apply-templates select="$tree/*"/>
	    				</div>
    	 	</xsl:when>
    	 	<xsl:when test="$format='comp2htmllist'" >    	 		
    	 		<div id="compviewlist">
    	 			<xsl:apply-templates select="$tree/*" mode="list"/>
    	 		</div>
    	 	</xsl:when>
    	 	<xsl:otherwise>
    	 			<div id="compviewdefault">
	    	 			<xsl:apply-templates select="$tree/*" />
	    	 		</div>
    	 	</xsl:otherwise>
    	 </xsl:choose>


    </xsl:template>
    

    <!-- generate actual HTML(?)-view -->
    <xsl:template match="CMD_ComponentSpec">
							
				<div class="comp_detail">
					<ul id="starttree" class="treeview">
					<xsl:apply-templates />
					</ul>
				</div>				
	</xsl:template>
		
		
	<xsl:template match="Header">
		
		<div class="note">
			<xsl:apply-templates />
		</div>
	</xsl:template>
				
    <!--  generic -->
    <xsl:template match="*">
		<div class="elem"><span class="label"><xsl:value-of select="name()" />:</span>
		<span class="value" ><xsl:value-of select="text()" /></span></div>		
	</xsl:template>
	
	
    <xsl:template match="CMD_Component">
		<li>
			<div class="cmdcomp"><h2><span class="cmdcomp_name" ><xsl:value-of select="@name" /></span>
				<span  class="sub" ><xsl:value-of select="@filename" /><xsl:text> </xsl:text><xsl:apply-templates select="@ConceptLink" />
				   	<xsl:if test="@CardinalityMin | @CardinalityMax" >
						<span><xsl:value-of select="concat('{',@CardinalityMin, '..', @CardinalityMax,'}')" /></span>			
					</xsl:if>		
				</span>				
			   	<xsl:if test="number(@CardinalityMax) &gt; 1 or @CardinalityMax='unbounded'" >
					<span class="cmd cmd_add"><xsl:text> </xsl:text></span>			
				</xsl:if>	
			</h2>			
			<xsl:apply-templates select="AttributeList"/> 				
		 </div>
     
          <!--<xsl:apply-templates select="./AttributeList"/>	                
          <xsl:apply-templates select="./CMD_Element"/> -->
          <!-- process all components at one level deeper (recursive call) -->
          <!-- <xsl:apply-templates select="./CMD_Component"/> -->          
         
				<ul>
          <xsl:apply-templates select="*[not(name()='AttributeList')]"/> 
         </ul>

			<!-- </div>		 -->
		</li>
	</xsl:template>
		
	<xsl:template match="CMD_Element">
	<li>
		<div class="cmdelem"><span class="cmdelem_name"><xsl:value-of select="@name" /></span>
		<span  class="sub" ><xsl:apply-templates select="@ConceptLink" />
			<span>[<xsl:value-of select="concat('{',@CardinalityMin, '..', @CardinalityMax,'}')" /></span>
		</span>
		<!--<br/>		
		  <input type="text" id="q_{@name}" value="" name="q_{@name}" /> 
		<xsl:if test="number(@CardinalityMax) &gt; 1 or @CardinalityMax='unbounded'" >
			<span class="cmd cmd_add"><xsl:text> </xsl:text></span>			
		</xsl:if>		
			-->
			
			<span><xsl:call-template name="valuescheme" /></span>		
			<xsl:apply-templates select="AttributeList" />
		</div>	
	</li>
	</xsl:template>
	
	<xsl:template name="valuescheme" >			
		<xsl:if test="ValueScheme | @ValueScheme | Type" >
			<span class="valuescheme">		
				[<xsl:if test="@ValueScheme"><xsl:value-of select="concat('xs:',@ValueScheme)"/></xsl:if>
				 <xsl:if test="Type"><xsl:value-of select="concat('xs:',Type)"/></xsl:if>
				  <xsl:for-each select="ValueScheme/enumeration/item[position() &lt; $display_values_limit]" >
					<span class="elem_value"><xsl:value-of select="." /></span>, </xsl:for-each>
					<xsl:if test="count(ValueScheme/enumeration/item) &gt; $display_values_limit" >
					...|<xsl:value-of select="count(.//item)"/> / <xsl:value-of select="string-length(ValueScheme)"/>|
					</xsl:if>
				]
			
			</span>
		</xsl:if>	
	</xsl:template>
	
	<xsl:template match="@ConceptLink">
		<!--	[2013-01-29]	<span class="conceptlink">[<a href="{my:rewriteURL(.)}" ><xsl:value-of select="my:shortURL(.)" /></a>]</span>				-->
		<span class="conceptlink">[<a href="{.}" ><xsl:value-of select="my:shortURL(.)" /></a>]</span>				
	</xsl:template>

	<xsl:template match="@ComponentId">
		<span class="componentid"><xsl:value-of select="." /></span>				
	</xsl:template>

	<xsl:template match="AttributeList">
		<div class="attributes">
				<xsl:apply-templates />
		</div>				
	</xsl:template>
	
	<xsl:template match="Attribute">
		<span class="attribute">@<xsl:value-of select="Name"/>
			<span><xsl:call-template name="valuescheme" /></span>		
		</span>				
	</xsl:template>



 <!--  LIST  --> 
 
 <xsl:template match="/CMD_ComponentSpec" mode="list">
			<xsl:apply-templates select="Header" mode="list"/> 
		<!--   srcfile:<xsl:value-of select="$src_file" /> -->
			
				<ul id="starttree" class="treeview">
					<xsl:apply-templates select="CMD_Component" mode="list">
					</xsl:apply-templates> 
				</ul>				
	</xsl:template>
			
	<xsl:template match="Header" mode="list">
		<div class="note">
			<xsl:apply-templates />
		</div>
	</xsl:template>

  <xsl:template match="CMD_Component" mode="list">
<!--  		<xsl:variable name="detail_uri" select="if(@ComponentId) then concat($detail_comp_prefix, my:extractID(@ComponentId)) else concat($detail_profile_prefix, my:extractID(parent::CMD_ComponentSpec/Header/ID))" />-->
  		<xsl:variable name="detail_uri" select="if(@ComponentId) then @ComponentId else parent::CMD_ComponentSpec/Header/ID" />
  	
		<li><a href="{$detail_uri}" ><xsl:value-of select="@name" /></a>
 				<span class="data comppath" ><xsl:value-of select="my:context(.)" /></span>
			
		<span class="cmd cmd_filter"><xsl:text> </xsl:text></span><span class="cmd cmd_detail" ><xsl:text> </xsl:text></span>
		<!--
		<div class="cmdcomp"><h2><xsl:value-of select="@name" />
		<span  class="sub" ><xsl:value-of select="@filename" /><xsl:text> </xsl:text><xsl:apply-templates select="@ConceptLink" />
		</span>
		</h2>			-->
		<ul>
    	<xsl:apply-templates select="./*" mode="list"/> 
    </ul>
    </li>

	</xsl:template>
			
	<xsl:template match="CMD_Element" mode="list">
			<li><xsl:value-of select="@name" />
					<span class="data comppath" ><xsl:value-of select="my:context(.)" /></span>
				<span class="cmd cmd_filter"><xsl:text> </xsl:text></span><span class="cmd cmd_detail" ><xsl:text> </xsl:text></span>
			</li>
			
		<!--
		<span  class="sub" ><xsl:apply-templates select="@ConceptLink" /></span></h4>		
			<span>[<xsl:value-of select="concat('{',@CardinalityMin, '..', @CardinalityMax,'}')" /></span>
			<span><xsl:call-template name="valuescheme" /></span>		
		</div>		 
		-->
	</xsl:template>
	


</xsl:stylesheet>