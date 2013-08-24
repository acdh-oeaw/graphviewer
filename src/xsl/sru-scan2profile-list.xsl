<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sru="http://www.loc.gov/zing/srw/"
    xmlns:diag="http://www.loc.gov/zing/srw/diagnostic/" 
    exclude-result-prefixes="xs sru"
    version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 31, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> m</xd:p>
            <xd:p>transform sru-scan response with cmd-profiles into a profile description</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- <sru:scanResponse xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fcs="http://clarin.eu/fcs/1.0">
    <sru:version>1.2</sru:version>
    <sru:terms>
        <sru:term>
            <sru:value>clarin.eu:cr1:p_1288172614026</sru:value>
            <sru:numberOfRecords>84039</sru:numberOfRecords>
            <sru:displayTerm>OLAC-DcmiTerms</sru:displayTerm>
            <sru:extraTermData>
                <diagnostics>
                    <diagnostic xmlns="http://www.loc.gov/zing/srw/diagnostic/" key="profile-unknown">
                        <uri>info:cmd/diagnostic/1/20</uri>
                        <details>clarin.eu:cr1:p_1369140737141</details>
                        <message>Missing profile reference (Unknown public profile)</message>
                    </diagnostic>
                </diagnostics>
                <fcsm:position xmlns:fcsm="http://clarin.eu/fcs/1.0">15</fcsm:position>
            </sru:extraTermData>
        </sru:term>
 -->
    
    <xsl:output indent="yes" />
    
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>if 'only-private' - generates an entry only for sru:terms with diagnostic @key=profile-unknown or <uri>info:cmd/diagnostic/1/20</uri>
            otherwise all profiles are transformed</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="filter" select="'only-private'" />
    
    <xsl:template match="/" >
        
        <xsl:choose>
            <xsl:when test="$filter='only-private'">
                <profileDescriptions type="used-in-instance-data-private">
                    <xsl:apply-templates select="//sru:term[.//diag:diagnostic[@key='unknown-profile' or diag:uri='info:cmd/diagnostic/1/20']]" />
                </profileDescriptions>
            </xsl:when>
            <xsl:otherwise>
                <profileDescriptions type="used-in-instance-data">
                    <xsl:apply-templates select="//sru:term" />
                </profileDescriptions>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
        <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
            <xd:desc>
                <xd:p></xd:p>
            </xd:desc>
        </xd:doc>
    <xsl:template match="sru:term">        
        <profileDescription>
            <id><xsl:value-of select="sru:value"></xsl:value-of></id>            
<!--            <description>A CMDI profile for annotated text corpus resources.</description>-->
            <name><xsl:value-of select="sru:displayTerm"></xsl:value-of></name>
<!--            <groupName>instance-data</groupName>-->
            <xsl:if test=".//diag:diagnostic[@key='unknown-profile' or diag:uri='info:cmd/diagnostic/1/20']" >
                <groupName>unknown-profile</groupName>
             </xsl:if>            
        </profileDescription>
        
    </xsl:template>
   
</xsl:stylesheet>