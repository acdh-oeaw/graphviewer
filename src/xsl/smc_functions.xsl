<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:my="myFunctions">

<!-- 
<purpose>functions for SMC</purpose>
<history>
	<change on="2011-10-28" type="created" by="vr">based on cmd_functions.xsl</change>
</history>
-->

<!-- did not work 
	<xsl:variable name="all-terms-nested" select="doc('file:/C:/Users/m/3lingua/clarin/CMDI/_repo2/SMC/data/cmd-terms-nested.xml')" />
	<xsl:key name="term-name" match="//Term" use="@name"></xsl:key>
-->

	<xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> May 15, 2013</xd:p>
			<xd:p><xd:b>Author:</xd:b> m</xd:p>
			<xd:p>This is used when resolving the cache-path. This way it is always interpreted relative to the primary source document.
				Otherwise the cache-path was interpreted inconsistently in the doc()-function vs. xsl:result-document@href </xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:variable name="base-uri" select="base-uri()" />
	
 <!--
 @param profiles - list of <profileDescription> 
 -->
	<xsl:function name="my:profiles2termsets" >
		<xsl:param name="profiles"/>
		<xsl:param name="nested"/>
		
		<Termsets count="{count($profiles)}">
		<xsl:for-each select="$profiles" >
			<xsl:variable name="profile_id" select="id"></xsl:variable>
			<Termset name="{(name,CMD_ComponentSpec/Header/Name)[1]}"  id="{$profile_id}" type="CMD_Profile">
				
					<!-- flattening the structure! -->
				<xsl:choose>
					<xsl:when test="$nested">
						<xsl:apply-templates select="CMD_ComponentSpec/CMD_Component" mode="make-term">
							<xsl:with-param name="nested" select="$nested"></xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select=".//CMD_Component|.//CMD_Element" mode="make-term">
							<xsl:with-param name="nested" select="$nested"></xsl:with-param>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
					
<!--					
				<xsl:for-each select=".//CMD_Component|.//CMD_Element" >
						<xsl:variable name="context" select="my:context(.)" />						
					
					<xsl:variable name="type" select="name()" />					
					<xsl:variable name="id"  >
						<xsl:choose>
							<xsl:when test="@ComponentId">
								<xsl:value-of select="@ComponentId" />
							</xsl:when>
							<!-\- top component = profile -\->
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
						<!-\-  <xsl:copy-of select="." /> -\->
					</Term>
					</xsl:for-each> 
-->			</Termset>
		</xsl:for-each>
		</Termsets>
	</xsl:function>

	<xsl:template match="CMD_Component|CMD_Element" mode="make-term">
	<xsl:param name="nested" select="true()"></xsl:param>
	<xsl:variable name="context" select="my:context(.)" />						
	
	<xsl:variable name="type" select="name()" />					
	<xsl:variable name="id"  >
		<xsl:choose>
			<xsl:when test="@ComponentId">
				<xsl:value-of select="@ComponentId" />
			</xsl:when>
			<!-- top component = profile -->
			<xsl:when test="not(exists(ancestor::CMD_Component))">
				<xsl:value-of select="(ancestor::profileDescription/id, ancestor::CMD_ComponentSpec/Header/ID)[1]" />
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
		<xsl:if test="$nested">
			<xsl:apply-templates select="CMD_Component|CMD_Element" mode="make-term">
				<xsl:with-param name="nested" select="$nested"></xsl:with-param>
			</xsl:apply-templates>
		</xsl:if>
	</Term>
</xsl:template>

<!--
<xsl:function name="my:profile2termset" >
    <xsl:param name="term"/>
    
    <xsl:variable name="profile" select="my:profile($term,true())" />
	<xsl:copy-of select="my:profiles2termsets($profile)" />
	
</xsl:function>

<xsl:function name="my:profile" >
    <xsl:param name="term"/>
    <xsl:param name="resolve" /> <!-\-  true|false-\->
    
    <!-\- <xsl:message>cmdprofiles_uri: <xsl:value-of select="$cmdprofiles_uri" /></xsl:message>  -\->
    
	<xsl:variable name="profile" select="$cmd_profiles//profileDescription[name=$term or $term='all']" />
    
    <xsl:choose>
      <xsl:when test="$resolve=true()">
      		<xsl:apply-templates select="$profile" mode="include" />
      </xsl:when>
      <xsl:otherwise>
      		<xsl:copy-of select="$profile" />
      </xsl:otherwise>
    </xsl:choose>
    
        
</xsl:function>-->

<!--  constructs a dot-path from ancestor-CMD_component-elements -->
<xsl:function name="my:context" >
	<xsl:param name="child" />
	<xsl:variable name="collect" >
			<xsl:for-each select="$child/ancestor::CMD_Component|$child/ancestor::Term" >
					<xsl:value-of select="@name" />.</xsl:for-each><xsl:value-of select="$child/@name" />
	</xsl:variable>
	<xsl:value-of select="$collect" />	
</xsl:function>	


	<xsl:function name="my:diffContext" >
		<xsl:param name="c1" />
		<xsl:param name="c2" />
		<!-- <xsl:message>C1:<xsl:copy-of select="count($c1/ancestor::Term/@name)" /></xsl:message> 
			<xsl:message><xsl:value-of select="$c1/ancestor::Term/@name" /></xsl:message>
			<xsl:message>C2:<xsl:value-of select="$c2/ancestor::Term/@name" /></xsl:message>
		-->
		<!--		<xsl:value-of select="($c1/ancestor::Term/@name except $c2/ancestor::Term/@name)[last()]" />-->
		
		<!-- <xsl:value-of select="string-join($c1/ancestor::Term/@name except $c2/ancestor::Term/@name,'.')" /> -->
		<!--   <xsl:copy-of select="$c1/ancestor::Term/@name except $c2/ancestor::Term/@name" />-->
		<xsl:variable name="diff" select="$c1/ancestor::Term/xs:string(@name[not(.=$c2/ancestor::Term/xs:string(@name))])" />
		<!-- <xsl:message>diff: <xsl:value-of select="$diff" /></xsl:message>  -->
		<xsl:copy-of select="$diff" />
		
	</xsl:function>
	
	<xsl:template match="*" mode="min-context" >
			<xsl:copy>
				<xsl:copy-of select="@*"></xsl:copy-of>
				<xsl:apply-templates mode="min-context">					
				</xsl:apply-templates>
			</xsl:copy>
		</xsl:template>
	
<!--  computing minimal unique path/index -->
<xsl:template match="Term" mode="min-context" >
		<xsl:param name="all-terms" select="$cmd-terms-nested" />
		<xsl:param name="term" select="." />
		
		
		<!--<xsl:variable name="termset_id" select="if (exists(ancestor::Termset/@id)) then ancestor::Termset/@id else ancestor::Termset/@name" />-->
	<xsl:variable name="termset_name" select="ancestor::Termset/@name" />
		
		<!-- unable to use lookup here - error:
			net.sf.saxon.tree.wrapper.VirtualCopy "cannot be cast" to net.sf.saxon.om.DocumentInfo -->
	<xsl:variable name="ambi_terms" select="$all-terms//Term[lower-case(@name)=lower-case($term/@name)]" />
	<!--	loookup did not work!
		<xsl:variable name="ambi_terms" >	 
		<xsl:call-template name="lookup">
			<xsl:with-param name="key" select="$term/@name"></xsl:with-param>
		</xsl:call-template>
		<xsl:for-each select="$all-terms-nested">
			<xsl:value-of select="key('term-name', lower-case($term/@name))"/>			
		</xsl:for-each>
		</xsl:variable> -->
		
		<xsl:variable name="min-path" >			
			<!-- don't apply prefix for the root element (=profile-name) -->		
			<xsl:if test="not($term/parent::Termset)" >
				<xsl:value-of select="$termset_name" ></xsl:value-of><xsl:text>:</xsl:text>
			</xsl:if> 
			
			<xsl:choose>		
				<xsl:when test="count($ambi_terms) &gt; 1" >
					<xsl:variable name="ambi_terms_parent" select="$ambi_terms/*[@name=$term/@name]" />
					<xsl:variable name="term1" select="." />
					<xsl:message>Term:<xsl:value-of select="$term1/@path" />|ambi: <xsl:value-of select="count($ambi_terms)" />|</xsl:message>
					<xsl:variable name="minimal_contexts" >
						<xsl:for-each select="$ambi_terms/*[not(@path=$term1/@path)]" > 
							<!--						[position() &gt; current()/position()]" >			-->
							<item>									
								<xsl:variable name="diff"  select="my:diffContext($term1,.)" />
								<!-- <xsl:message>diff: <xsl:value-of select="count($diff)" /></xsl:message>-->
								<xsl:copy-of select="$diff" />									 
								
							</item>									
						</xsl:for-each>
					</xsl:variable>
					<!-- DEBUG:				diffcontext1:<xsl:value-of select="count($minimal_contexts)" />
						|direct: <xsl:value-of select="count($minimal_contexts[1]/*)" />: <xsl:value-of select="$minimal_contexts[1]/*" />|
						|item1: <xsl:value-of select="count($minimal_contexts/item[1]/*)" />: <xsl:value-of select="$minimal_contexts/item[1]/*" />|
						cnt_mci:<xsl:value-of select="$minimal_contexts/*/count(tokenize(.,' '))" ></xsl:value-of>/
						max-strlen:<xsl:value-of select="max($minimal_contexts/*/string-length(.))" ></xsl:value-of>
					-->							 
					<xsl:variable name="last_contexts" select="distinct-values($minimal_contexts/*/tokenize(.,' ')[last()])" ></xsl:variable>
					<!--  to get the order right -->
					<xsl:for-each select="$last_contexts" >
						<xsl:sort select="index-of(tokenize($term1/@context,'\.'),.)[1]" /> 
						<xsl:value-of select="." />.</xsl:for-each>
					<!-- DEBUG: 	cnt_lc:<xsl:value-of select="count($last_contexts)" />}
						cnt_tok:<xsl:value-of select="count(tokenize($term1/@context,'\.'))" />
						
						<xsl:for-each select="tokenize($term1/@context,'\.')" >
						tokenizing-context:<xsl:value-of select="." />,<xsl:value-of select="current()" />|
						<xsl:if test="$last_contexts[.=current()]" >
						{<xsl:value-of select="." />}
						
						</xsl:if>
						</xsl:for-each>
					-->
					<!--								<xsl:value-of select="string-join(distinct-values($minimal_contexts/*/tokenize(.,' ')[last()]),'.')" ></xsl:value-of>		-->						
				</xsl:when>
				<xsl:otherwise>			
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="@name" ></xsl:value-of>
		</xsl:variable>
		
		<xsl:copy>
			<xsl:copy-of select="@*"></xsl:copy-of>
			<!-- 		<xsl:copy-of select="$path" />-->
			<xsl:attribute name="min-path" select="$min-path" />
			
			<xsl:apply-templates select="Term" mode="min-context" >
				<xsl:with-param name="all-terms" select="$all-terms"></xsl:with-param>
			</xsl:apply-templates>

		</xsl:copy>							
		
	</xsl:template>
	<!--
	<xsl:template name="lookup">
		<xsl:param name="key"/>
		<xsl:for-each select="$all-terms-nested">        
			<xsl:value-of select="key('term-name', $key)"/>
			<xsl:message><xsl:value-of select="key('term-name', $key)"/></xsl:message>
		</xsl:for-each>
		<xsl:message></xsl:message>
	</xsl:template>
	
	-->
	
	<xsl:function name="my:shortURL" >
		<xsl:param name="url" />
		<!--   <xsl:value-of select="replace($url, 'http://www.isocat.org/datcat/','isocat:')" /> -->
		<xsl:variable name="matching_termset"  select="if($url!='') then $termsets_config/Termsets/*[url_prefix][not(url_prefix='')][starts-with($url,url_prefix)] else ()" />
		<!-- <xsl:variable name="matchinge_termset"  select="if($url!='') then if ($terms_setup/Termsets/Termset[@url_prefix][starts-with($url,@url_prefix)]) then $terms_setup/Termsets/Termset[@url_prefix][starts-with($url,@url_prefix)][1] 
			else if $terms_setup/Termsets/Termset[@url][starts-with($url,@url)] then $terms_setup/Termsets/Termset[@url][starts-with($url,@url)][1] else ()" /> -->  
		<xsl:message>shortURL: <xsl:value-of select="$matching_termset/url_prefix" />:: <xsl:value-of select="$url" />
		</xsl:message>  		
		<xsl:value-of select="if ($matching_termset/url_prefix and $matching_termset/url_prefix!='' and $url!='') then replace($url, $matching_termset[1]/url_prefix, concat(string-join($matching_termset/key,','),':')) else $url" />		
	</xsl:function>	
	

<!-- taken from cmd2graph.xsl -->
	<xsl:function name="my:normalize">
		<xsl:param name="value" />		
		<xsl:value-of select="translate($value,'*/-.'',$@={}:[]()#>&lt; ','XZ__')" />		
	</xsl:function>
	
	
	<!-- resolve cache path relative to the primary input-document -->
	<xsl:function name="my:cachePath">
		<xsl:param name="key" />		
		<xsl:param name="id" />
		
		<xsl:value-of select="concat(resolve-uri($cache_dir,$base-uri), if (ends-with($cache_dir,'/') or ends-with($cache_dir,'\')) then '' else '/',
		$key, if ($id!='') then concat('/', my:normalize($id)) else '', '.xml')" />		
	</xsl:function>
	
	
	
</xsl:stylesheet>