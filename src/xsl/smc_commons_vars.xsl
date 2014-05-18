<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:my="myFunctions" exclude-result-prefixes="xs my" version="2.0">
   
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all" name="xml"/>
    
    
    <xsl:include href="smc_commons.xsl"/>
    
    
<!-- intermediate datasets bound into variables,to prevent calling the function every time 
    however they get initialized even if not needed! -->
    <xsl:variable name="dcr-terms-preload" select="my:getData('dcr-terms-preload')" />
   <xsl:variable name="dcr-terms" select="my:getData('dcr-terms')" />
    <xsl:variable name="rr-relations" select="my:getData('rr-relations')" />
    <!-- rr-relations expanded with terms-->
    <xsl:variable name="rr-terms" select="my:getData('rr-terms')" />
   <xsl:variable name="cmd-terms" select="my:getData('cmd-terms')" />
<!--    <xsl:variable name="cmd-terms" select="()" />-->
    
    <xsl:variable name="cmd-terms-nested" select="my:getData('cmd-terms-nested')" />
   <xsl:variable name="dcr-cmd-map" select="my:getData('dcr-cmd-map')" />
   <xsl:variable name="isocat-languages" select="my:getData('isocat-languages')" />

</xsl:stylesheet>
