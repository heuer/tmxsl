<?xml version="1.0" encoding="utf-8"?>
<!--
  ====================================
  RSS -> XTM 2.1 conversion stylesheet
  ====================================
  
  This stylesheet translates RSS into XTM 2.1.

  RSS: <http://www.rssboard.org/rss-specification>
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
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns="http://www.topicmaps.org/xtm/"
                xmlns:str="http://exslt.org/strings"
                extension-element-prefixes="str"
                 exclude-result-prefixes="dc">

  <xsl:import href="rssdates.xsl"/>

  <xsl:output method="xml" media-type="application/x-tm+xtm" encoding="utf-8" standalone="yes" indent="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:template match="/rss/channel">
    <!--** Creates an reifier for the channel and converts each RSS item into a topic -->
    <topicMap version="2.1">
      <reifier>
        <subjectLocatorRef href="{link}"/>
      </reifier>
      <topic>
        <subjectLocator href="{link}"/>
        <xsl:apply-templates select="title|description|copyright|pubDate|dc:date|dc:rights"/>
      </topic>
      <xsl:apply-templates select="item"/>
    </topicMap>
  </xsl:template>

  <xsl:template match="item[link]">
    <!--** Converts RSS items into topics and connects each item with the item's author -->
    <topic>
      <xsl:apply-templates select="link|guid"/>
      <xsl:apply-templates select="title|description|pubDate|dc:date"/>
    </topic>
    <xsl:apply-templates select="author"/>
  </xsl:template>

  <xsl:template match="author">
    <!--** author becomes an association which connects the author with the item 
           
           <http://www.rssboard.org/rss-specification#ltauthorgtSubelementOfLtitemgt>
           
           <author>lawyer@boyer.net (Lawyer Boyer)</author>
    -->
    <!--@ Extract the e-mail address and the name of the author -->
    <xsl:variable name="email" select="str:split(.)[1]"/>
    <xsl:variable name="name" select="str:replace(str:split(., '(')[2], ')', '')"/>
    <association>
      <type><subjectIdentifierRef href="http://purl.org/dc/terms/creator"/></type>
      <!--@ The item plays the "resource" role -->
      <role>
        <type><subjectIdentifierRef href="http://psi.topicmaps.org/iso29111/resource"/></type>
        <subjectLocatorRef href="{../link}"/>
      </role>
      <!--@ The author plays the "value" role -->
      <role>
        <type><subjectIdentifierRef href="http://psi.topicmaps.org/iso29111/value"/></type>
        <subjectIdentifierRef href="mailto:{$email}"/>
      </role>
    </association>
    <xsl:if test="$name">
      <topic>
        <subjectIdentifier href="mailto:{$email}"/>
        <name><value><xsl:value-of select="$name"/></value></name>
      </topic>
    </xsl:if>
  </xsl:template>

  <xsl:template match="link">
    <!--** Converts RSS link into a subject locator (within a topic context) -->
    <subjectLocator href="{.}"/>
  </xsl:template>

  <xsl:template match="guid">
    <!--** Converts RSS guid into a subject locator iff the guid is a permalink 
           
           Only guids with permalinks MUST be IRIs, all other guids may simply be
           a unique string if I understood the RSS spec correctly. So, we're ignoring
           non-permalink guids
    -->
    <xsl:if test="@isPermaLink">
      <subjectLocator href="{.}"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="title">
    <!--** Converts RSS title into a name -->
    <name><value><xsl:value-of select="."/></value></name>
  </xsl:template>

  <xsl:template match="description">
    <!--** Converts RSS description into an occurrence -->
    <occurrence>
      <type><subjectIdentifierRef href="http://purl.org/dc/terms/abstract"/></type>
      <resourceData><xsl:value-of select="."/></resourceData>
    </occurrence>
  </xsl:template>

  <xsl:template match="copyright|dc:rights">
    <!--** Converts RSS copyright / dc:rights into an occurrence -->
    <occurrence>
      <type><subjectIdentifierRef href="http://purl.org/dc/elements/1.1/rights"/></type>
      <resourceData><xsl:value-of select="."/></resourceData>
    </occurrence>
  </xsl:template>

  <xsl:template match="dc:date">
    <!--** Converts dc:date into an occurrence -->
    <occurrence>
      <type><subjectIdentifierRef href="http://purl.org/dc/elements/1.1/date"/></type>
      <resourceData datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:value-of select="."/></resourceData>
    </occurrence>
  </xsl:template>

  <xsl:template match="pubDate">
    <!--** Converts RSS pubDate into an occurrence -->
    <occurrence>
      <type><subjectIdentifierRef href="http://purl.org/dc/elements/1.1/date"/></type>
      <resourceData datatype="http://www.w3.org/2001/XMLSchema#dateTime"><xsl:call-template name="convertRssDate"><xsl:with-param name="in" select="."/></xsl:call-template></resourceData>
    </occurrence>
  </xsl:template>

</xsl:stylesheet>
