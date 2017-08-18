<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:cmd="http://www.clarin.eu/cmd/">
    
    <xsl:param name="core"/>
    
    <!-- identity copy -->
    
    <xsl:template match="@*|node()" mode="#all" priority="0">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- handle schema location -->
    
    <xsl:template match="/cmd:CMD/@xsi:schemaLocation">
        <xsl:attribute name="xsi:schemaLocation">
            <xsl:text>http://www.clarin.eu/cmd/  http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/</xsl:text>
            <xsl:value-of select="$core/CMD_ComponentSpec/Header/ID"/>
            <xsl:text>/xsd</xsl:text>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="/cmd:CMD">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:comment>
                <xsl:text>[stripToCore] @xsi:schemaLocation="</xsl:text>
                <xsl:value-of select="@xsi:schemaLocation"/>
                <xsl:text>"</xsl:text> 
            </xsl:comment>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
        
    <!-- start traversing the components -->
    
    <xsl:template match="/cmd:CMD/cmd:Components/cmd:*">
        <!-- replace the instance profile node by the core profile node -->
        <xsl:comment>[stripToCore] added core profile node</xsl:comment>
        <xsl:element namespace="http://www.clarin.eu/cmd/" name="{$core/CMD_ComponentSpec/CMD_Component/@name}">
            <xsl:comment>
                <xsl:text>[stripToCore] </xsl:text> 
                <xsl:text>&lt;</xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text>&gt;</xsl:text>
            </xsl:comment>
            <xsl:apply-templates mode="core">
                <xsl:with-param name="core" select="$core/CMD_ComponentSpec/CMD_Component/*" tunnel="yes"/>
            </xsl:apply-templates>
            <xsl:comment>
                <xsl:text>[stripToCore] </xsl:text> 
                <xsl:text>&lt;/</xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text>&gt;</xsl:text>
            </xsl:comment>
        </xsl:element>        
    </xsl:template>
    
    <!-- match a node -->
    
    <xsl:template match="cmd:*" mode="core" priority="1">
        <xsl:param name="core" tunnel="yes"/>
        <xsl:variable name="cur" select="local-name()"/>
        <xsl:choose>
            <xsl:when test="$core/@name = $cur">
                <xsl:copy>
                    <xsl:variable name="attr-names" select="$core/AttributeList/Attribute/Name"/>
                    <xsl:copy-of select="@ref | @*[name()=$attr-names]"/>
                    <xsl:for-each select="@* except (@ref | @*[name()=$attr-names])">
                        <xsl:comment>
                            <xsl:text>[stripToCore] @</xsl:text>
                            <xsl:value-of select="name()"/>
                            <xsl:text>="</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>"</xsl:text> 
                        </xsl:comment>
                    </xsl:for-each>
                    <xsl:apply-templates select="node()" mode="core">
                        <xsl:with-param name="core" select="$core[@name = $cur]/(CMD_Component|CMD_Element)" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>
                    <xsl:text>[stripToCore] </xsl:text>
                    <xsl:apply-templates select="." mode="copy"/>
                </xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- make a commented copy of a node -->
    
    <xsl:template match="*" mode="copy" priority="1">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:apply-templates select="@*" mode="copy"/>
        <xsl:text>&gt;</xsl:text>
        <xsl:apply-templates select="node()" mode="copy"/>
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt;</xsl:text>
    </xsl:template>
        
    <xsl:template match="@*" mode="copy" priority="1">
        <xsl:text> </xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>="</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
    </xsl:template>
        
</xsl:stylesheet>