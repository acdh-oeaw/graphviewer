<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- this can be also sent as input-file -->
    <xsl:param name="termset_config_file" select="'termsets.xml'" />
    
    <xsl:param name="cache_dir" select="'cache/'" />
    
</xsl:stylesheet>