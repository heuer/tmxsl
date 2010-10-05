<?xml version="1.0" encoding="utf-8"?>
<!--
  =========================================
  Atom 1.0 -> XTM 2.1 conversion stylesheet
  =========================================
  
  This stylesheet translates Atom 1.0 into XTM 2.1.

  Atom 1.0: <http://tools.ietf.org/html/rfc4287>
  XTM 2.1: <http://www.itscj.ipsj.or.jp/sc34/open/1378.htm>

  Copyright (c) 2010, Semagia - Lars Heuer <http://www.semagia.com/>
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.

     * Redistributions in binary form must reproduce the above
       copyright notice, this list of conditions and the following
       disclaimer in the documentation and/or other materials provided
       with the distribution.

     * Neither the name of the copyright holders nor the names of the 
       contributors may be used to endorse or promote products derived 
       from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns="http://www.topicmaps.org/xtm/"
                exclude-result-prefixes="atom">

  <xsl:output method="xml" media-type="application/x-tm+xtm" encoding="utf-8" standalone="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:template match="atom:feed">
    <topicMap version="2.1">
      <reifier>
        <subjectIdentifierRef href="{atom:id}"/>
      </reifier>
      <topic>
        <xsl:apply-templates select="atom:id"/>
        <xsl:apply-templates select="atom:title|atom:subtitle|atom:updated"/>
      </topic>
      <xsl:apply-templates select="atom:author"/>
      <xsl:apply-templates select="atom:source"/>
      <xsl:apply-templates select="atom:entry"/>
    </topicMap>
  </xsl:template>

  <xsl:template match="atom:id">
    <!--** Translates atom:id into subject identifier
           
           Since atom:id may be a URN or any other non dereferencable IRI, 
           it seems to be more appropriate than subject locator 
    -->
    <subjectIdentifier href="{.}"/>
  </xsl:template>

  <xsl:template match="atom:title|atom:name">
    <!--** Translates atom:title and atom:name into TM name -->
    <name><value><xsl:value-of select="."/></value></name>
  </xsl:template>

  <xsl:template match="atom:subtitle">
    <!--** Translates atom:subtitle into TM name -->
    <name>
      <type><subjectIdentifierRef href="http://purl.org/dc/terms/alternative"/></type>
      <value><xsl:value-of select="."/></value>
    </name>
  </xsl:template>

  <xsl:template match="atom:uri">
    <!--** Link to the author becomes a subject identifier -->
    <subjectIdentifier href="{.}"/>
  </xsl:template>

  <xsl:template match="atom:link[@rel='alternate'][@type='text/html']">
    <!--** The link to the post becomes a subject locator -->
    <subjectLocator href="{@href}"/>
  </xsl:template>

  <xsl:template match="atom:email">
    <!--** Translates atom:email into a subject identifier with a "mailto:" prefix -->
    <subjectIdentifier href="{concat('mailto:', .)}"/>
  </xsl:template>

  <xsl:template match="atom:updated">
    <!--** atom:updated becomes an occurrence -->
    <xsl:call-template name="datetime">
      <xsl:with-param name="type" select="'http://purl.org/dc/terms/modified'"/>
      <xsl:with-param name="date" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="atom:published">
    <!--** atom:published becomes an occurrence -->
    <xsl:call-template name="datetime">
      <xsl:with-param name="type" select="'http://purl.org/dc/terms/date'"/>
      <xsl:with-param name="date" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="atom:summary">
    <!--** atom:summary becomes an occurrence -->
    <occurrence>
      <type><subjectIdentifierRef href="http://purl.org/dc/terms/abstract"/></type>
      <resourceData><xsl:value-of select="."/></resourceData>
    </occurrence>
  </xsl:template>

  <xsl:template match="atom:entry">
    <!--** Translates atom:entry to a topic and 
           creates an association between the entry and its author -->
    <topic>
      <xsl:apply-templates select="atom:id"/>
      <xsl:apply-templates select="atom:link"/>
      <xsl:apply-templates select="atom:title|atom:subtitle|atom:summary"/>
    </topic>
    <xsl:apply-templates select="atom:author"/>
    <xsl:apply-templates select="atom:source"/>
  </xsl:template>

  <xsl:template match="atom:author">
    <!--** atom:author becomes an association which connects the author with the entry -->
    <association>
      <type><subjectIdentifierRef href="http://purl.org/dc/terms/creator"/></type>
      <!--@ The entry plays the "resource" role -->
      <role>
        <type><subjectIdentifierRef href="http://psi.topicmaps.org/iso29111/resource"/></type>
        <subjectIdentifierRef href="{../atom:id}"/>
      </role>
      <!--@ The author plays the "value" role -->
      <role>
        <type><subjectIdentifierRef href="http://psi.topicmaps.org/iso29111/value"/></type>
        <xsl:choose>
          <xsl:when test="atom:uri"><subjectIdentifierRef href="{atom:uri}"/></xsl:when>
          <xsl:when test="atom:email"><subjectIdentifierRef href="{concat('mailto:', atom:email)}"/></xsl:when>
          <xsl:otherwise><topicRef href="#{generate-id(.)}"/></xsl:otherwise>
        </xsl:choose>
      </role>
    </association>
    <topic>
      <xsl:choose>
        <xsl:when test="atom:uri"><subjectIdentifier href="{atom:uri}"/></xsl:when>
        <xsl:when test="atom:email"><subjectIdentifier href="{concat('mailto:', atom:email)}"/></xsl:when>
        <xsl:otherwise><xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute></xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="atom:uri|atom:email"/>
      <xsl:apply-templates select="atom:name"/>
    </topic>
  </xsl:template>

  <xsl:template match="atom:source">
    <!-- TODO -->
  </xsl:template>

  <xsl:template name="datetime">
    <!--** Creates an occurrence with a xsd:dateTime value -->
    <xsl:param name="type" select="'http://purl.org/dc/terms/date'"/>
    <xsl:param name="date" select="."/>
    <occurrence>
      <type><subjectIdentifierRef href="{$type}"/></type>
      <resourceData datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="$date"/></resourceData>
    </occurrence>
  </xsl:template>

</xsl:stylesheet>