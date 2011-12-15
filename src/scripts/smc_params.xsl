<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- this can be also sent as input-file -->
    <xsl:param name="termset_config_file" select="'config.xml'" />
    
    <!-- used to config smc_init.xsl -->  
    <!-- allowed values:  cmd-profiles-raw , cmd-resolved, cmd-terms, dcr-terms, dcr-cmd-map -->
    <xsl:param name="data_key" select="'termsets'" /> 
    
    <!-- use, skip, refresh (refresh not working yet) -->
    <xsl:param name="cache" select="'use'" /> 
<!--    <xsl:param name="cache_dir" select="'file:/C:/Users/m/3lingua/clarin/CMDI/SMC/cache/'" />-->
    <xsl:variable name="cache_dir" select="'file:/C:/Users/m/3lingua/clarin/CMDI/SMC/cache/'" />
    
</xsl:stylesheet>