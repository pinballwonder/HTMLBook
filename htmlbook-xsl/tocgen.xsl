<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns="http://www.w3.org/1999/xhtml">

<!-- Functionality still ToDo: Support for multilevel labels (including label for ancestor element); see common.xsl -->
<!-- Functionality still ToDo: Setting TOC section depth (e.g., how many levels of sections to include in TOC -->

  <xsl:import href="common.xsl"/>

  <xsl:output method="xml"
              encoding="UTF-8"/>
  <xsl:preserve-space elements="*"/>

  <xsl:param name="autogenerate-toc" select="1"/>

  <!-- Specify whether or not to overwrite any content in the TOC placeholder element -->
  <xsl:param name="toc-placeholder-overwrite-contents" select="0"/>

  <!-- Specify whether or not to include book title in autogenerated TOC -->
  <xsl:param name="toc-include-title" select="0"/>

  <!-- Specify whether to include number labels in TOC entries -->
  <xsl:param name="toc-include-labels" select="0"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$autogenerate-toc = 1 and count(//h:nav[@class='toc']) = 0">
	<xsl:message>Unable to autogenerate TOC: no TOC "nav" element found.</xsl:message>
      </xsl:when>
      <xsl:when test="$toc-placeholder-overwrite-contents != 1 and count(//h:nav[@class='toc'][1][not(node())]) = 0">
	<xsl:message>Unable to autogenerate TOC: first TOC "nav" is not empty, and $toc-placeholder-overwrite-contents param not enabled.</xsl:message>
      </xsl:when>
    </xsl:choose>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Default rule for TOC generation -->
  <xsl:template match="*" mode="tocgen">
    <xsl:apply-templates select="*" mode="tocgen"/>
  </xsl:template>

  <xsl:template match="h:section[not(@class = 'dedication' or @class = 'titlepage' or @class = 'toc' or @class = 'colophon' or @class = 'copyright-page' or @class = 'halftitlepage')]|h:div[@class='part']" mode="tocgen">
    <xsl:element name="li">
      <xsl:attribute name="class">
	<xsl:value-of select="@class"/>
      </xsl:attribute>
      <a>
	<xsl:attribute name="href">
	  <xsl:call-template name="href.target">
	    <xsl:with-param name="target-node" select="."/>
	  </xsl:call-template>
	</xsl:attribute>
	<xsl:if test="$toc-include-labels = 1">
	  <xsl:apply-templates select="." mode="label.value"/>
	</xsl:if>
	<xsl:apply-templates select="." mode="titlegen"/>
      </a>
      <xsl:if test="descendant::h:section|descendant::h:div[@class='part']">
	<ol>
	  <xsl:apply-templates mode="tocgen"/>
	</ol>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="h:nav[@class='toc']">
    <xsl:choose>
      <!-- If autogenerate-toc is enabled, and it's the first toc-placeholder-element, and it's either empty or overwrite-contents is specified, then
	   go ahead and generate the TOC here -->
      <xsl:when test="($autogenerate-toc = 1) and 
		      (not(preceding::h:nav[@class='toc'])) and
		      (not(node()) or $toc-placeholder-overwrite-contents != 0)">
	<nav>
	  <xsl:if test="$toc-include-title != 0">
	    <h1>
	      <xsl:value-of select="//h:body/h1"/>
	    </h1>
	  </xsl:if>
	  <ol>
	    <xsl:apply-templates select="/*" mode="tocgen"/>
	  </ol>
	</nav>
      </xsl:when>
      <xsl:otherwise>
	<!-- Otherwise, just process as normal -->
	<!-- ToDo: Consider using <xsl:apply-imports> here, depending on how we decide to do stylesheet layering for packaging for EPUB, etc. -->
	<xsl:copy>
	  <xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Default Rule -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- By default, TOC will be generated in first empty -->

</xsl:stylesheet> 