<?xml version="1.0" encoding="utf-8"?>
<!-- 
  ========================================
  XTM 1.0 -> XTM 2.0 conversion stylesheet
  ========================================
  
  This stylesheet translates XTM 1.0 into XTM 2.0.
  
  Available parameters:
  - omit_reification_identities: 
    true (default) or false
    If a subject identifier / item identifier pair is found that 
    estabilishes the reification of a construct, the item identifier /
    subject identifier is omitted if this parameter is set to ``true``
  - omit_item_identifiers
    false (default) or true
    If a construct != topic has an ``id`` attribute, an <itemIdentity/>
    element is created if this parameter is not set to ``true``.
    Note: If the ``id`` attribute is used to reify a construct, the 
    creation of the <itemIdentity/> element depends on the value of
    the ``omit_reification_identities`` parameter.
  - omit_mergemap:
    true (default) or false
    If a <mergeMap/> element is found, it is translated to a XTM 2.0
    <mergeMap/> element unless this parameter is set to ``true``.
  

  XTM 1.0: <http://www.topicmaps.org/xtm/1.0/xtm1-20010806.html>
  XTM 2.0: <http://www.isotopicmaps.org/sam/sam-xtm/2006-06-19/>

  Authors: 
  - Alexander Mikhailian <ami at spaceapplications.com>
  - Lars Heuer <heuer[at]semagia.com>

  This stylesheet is published under the same conditions as the 
  original stylesheet found at <http://www.topiwriter.com/misc/xtm1toxtm2.html>.
  
  Changes against the original version:
  - Made "http://www.topicmaps.org/xtm/" to the default namespace and
    therefor switched from <xsl:element name="..."/> to the concrete XTM 2.0
    element
  - All types of the XTM 1.0 topics are taken into account
  - Made translation of the <mergeMap/> element optional
  - Dropped all tmdm:glossary terms
  - Usage of XTM 1.0 default types instead of terminating the translation
  - <member/> elements with multiple players are translated into multiple roles
  - Renamed namespace "tm1" into "xtm"
  - Support for nested variants
  - Corrected and simplyfied reification handling
  - Avoid loosing information about topics which are referenced by 
    <subjectIndicatorRef/> and <resourceRef/>

  
  Copyright (c) 2007, Space Applications Services
  Copyright (c) 2009, Semagia - Lars Heuer <http://www.semagia.com/>
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
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xtm="http://www.topicmaps.org/xtm/1.0/"
                xmlns="http://www.topicmaps.org/xtm/"
                exclude-result-prefixes="xtm xlink">

  <xsl:output method="xml" media-type="application/x-tm+xtm" encoding="utf-8" standalone="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:param name="xtm_version" select="'2.0'"/>
  <xsl:param name="omit_reification_identities" select="true()"/>
  <xsl:param name="omit_item_identifiers" select="false()"/>
  <xsl:param name="omit_mergemap" select="true()"/>

  <xsl:key name="reifies" 
           match="xtm:subjectIdentity/xtm:subjectIndicatorRef/@xlink:href[starts-with(., '#')]" 
           use="."/>

  <xsl:key name="reifiable" match="xtm:*[local-name() != 'topic']" use="concat('#', @id)"/>

  <!-- copy and change the namespace from XTM 1.0 to XTM 2 -->
  <xsl:template match="xtm:*" >
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- rename xlink:href to href -->
  <xsl:template match="@xlink:href">
    <xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
  </xsl:template>

  <!-- Since XTM 2.0 knows only topicRef, 
       translate subjectIndicatorRef and resourceRef into topicRef -->
  <xsl:template match="xtm:subjectIndicatorRef|xtm:resourceRef[local-name(..) != 'occurrence'][local-name(..) != 'variantName']">
    <topicRef href="#{generate-id(.)}"/>
  </xsl:template>

  <!-- topic map -->
  <xsl:template match="xtm:topicMap">
    <xsl:if test="$xtm_version != '2.0'">
      <xsl:message terminate="yes">Unsupported version. Expected '2.0'</xsl:message>
    </xsl:if>
    <xsl:comment>This XTM 2.0 representation was automatically generated from a XTM 1.0 source by http://topic-maps.googlecode.com/</xsl:comment>
    <topicMap version="{$xtm_version}">
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
      <xsl:call-template name="post-process"/>
    </topicMap>
  </xsl:template>

  <!-- mergeMap contains only a @href now-->
  <xsl:template match="xtm:mergeMap">
    <xsl:if test="not($omit_mergemap)">
      <mergeMap href="{@xlink:href}"/>
    </xsl:if>
  </xsl:template>

  <!--convert @id into itemIdentity iff construct != topic -->
  <xsl:template match="@id">
    <xsl:choose>
      <xsl:when test="key('reifies', concat('#', .))">
        <xsl:attribute name="reifier"><xsl:value-of select="concat('#', key('reifies', concat('#', .))/ancestor::xtm:topic/@id)"/></xsl:attribute>
        <xsl:if test="not($omit_reification_identities)">
          <itemIdentity href="{concat('#', .)}"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="not($omit_item_identifiers)">
        <itemIdentity href="{concat('#', .)}"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--instanceOf != topic/instanceOf -> type 
      roleSpec -> type
  -->
  <xsl:template match="xtm:instanceOf[not(parent::xtm:topic)]|xtm:roleSpec">
    <type>
      <xsl:apply-templates/>
    </type>
  </xsl:template>

  <!--baseName -> name -->
  <xsl:template match="xtm:baseName">
    <name>
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates/>
    </name>
  </xsl:template>

  <!--baseNameString -> value -->
  <xsl:template match="xtm:baseNameString">
    <value><xsl:value-of select="."/></value>
  </xsl:template>

  <!-- variants -->
  <xsl:template match="xtm:variant">
    <variant>
      <xsl:apply-templates select="@id"/>
      <xsl:apply-templates select="*[local-name() != 'variant']"/>
    </variant>
    <xsl:apply-templates select="xtm:variant"/>
  </xsl:template>

  <!--parameters -> scope -->
  <xsl:template match="xtm:parameters">
    <scope>
      <xsl:apply-templates/>
      <!-- add the scope of the parent variants -->
      <xsl:apply-templates select="../ancestor::xtm:variant/xtm:parameters/*"/>
    </scope>
  </xsl:template>

  <!--variantName -> :nil -->
  <xsl:template match="xtm:variantName">
    <xsl:apply-templates/>
  </xsl:template>

  <!--subjectIdentity -> :nil -->
  <xsl:template match="xtm:subjectIdentity">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- occurrences -->
  <xsl:template match="xtm:occurrence">
    <occurrence>
      <xsl:apply-templates select="@id"/>
      <xsl:if test="count(xtm:instanceOf) = 0">
        <type><topicRef href="http://www.topicmaps.org/xtm/1.0/core.xtm#occurrence"/></type>
      </xsl:if>
      <xsl:apply-templates/>
    </occurrence>
  </xsl:template>

  <!-- associations -->
  <xsl:template match="xtm:association">
    <association>
      <xsl:apply-templates select="@id"/>
      <xsl:if test="count(xtm:instanceOf) = 0">
        <type><topicRef href="http://www.topicmaps.org/xtm/1.0/core.xtm#association"/></type>
      </xsl:if>
      <xsl:apply-templates/>
    </association>
  </xsl:template>

  <!-- roles -->
  <xsl:template match="xtm:member">
    <!-- Multiple players cause multiple roles -->
    <xsl:for-each select="xtm:topicRef|xtm:resourceRef|xtm:subjectIndicatorRef">
      <role>
        <xsl:choose>
          <xsl:when test="count(../xtm:roleSpec) = 0">
            <!-- This may cause an error if a XTM 2.0 parser checks if the 
                 <topicRef/> contains a fragment identifier 
                 Anyway, this XTM 2.0 'feature' is speculative and untyped roles are bad :)
            -->
            <type><topicRef href="http://psi.semagia.com/xtm/1.0/role"/></type>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="../xtm:roleSpec"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="."/>
      </role>
    </xsl:for-each>
  </xsl:template>

  <!-- subjectIdentity/subjectIndicatorRef -> subjectIdentifier -->
  <xsl:template match="xtm:subjectIdentity/xtm:subjectIndicatorRef">
    <xsl:if test="not($omit_reification_identities and key('reifiable', @xlink:href))">
      <subjectIdentifier>
        <!-- renaming some of the association types and role types-->
        <xsl:choose>
          <xsl:when test="@xlink:href='http://www.topicmaps.org/xtm/1.0/core.xtm#class-instance'">
            <xsl:attribute name="href">http://psi.topicmaps.org/iso13250/model/type-instance</xsl:attribute>
          </xsl:when>
          <xsl:when test="@xlink:href='http://www.topicmaps.org/xtm/1.0/core.xtm#class'">
            <xsl:attribute name="href">http://psi.topicmaps.org/iso13250/model/type</xsl:attribute>
          </xsl:when>
          <xsl:when test="@xlink:href='http://www.topicmaps.org/xtm/1.0/core.xtm#instance'">
            <xsl:attribute name="href">http://psi.topicmaps.org/iso13250/model/instance</xsl:attribute>
          </xsl:when>
          <xsl:when test="@xlink:href='http://www.topicmaps.org/xtm/1.0/core.xtm#superclass-subclass'">
            <xsl:attribute name="href">http://psi.topicmaps.org/iso13250/model/supertype-subtype</xsl:attribute>
          </xsl:when>
          <xsl:when test="@xlink:href='http://www.topicmaps.org/xtm/1.0/core.xtm#superclass'">
            <xsl:attribute name="href">http://psi.topicmaps.org/iso13250/model/supertype</xsl:attribute>
          </xsl:when>
          <xsl:when test="@xlink:href='http://www.topicmaps.org/xtm/1.0/core.xtm#subclass'">
            <xsl:attribute name="href">http://psi.topicmaps.org/iso13250/model/subtype</xsl:attribute>
          </xsl:when>
          <xsl:when test="@xlink:href='http://www.topicmaps.org/xtm/1.0/core.xtm#sort'">
            <xsl:attribute name="href">http://psi.topicmaps.org/iso13250/model/sort</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="href"><xsl:value-of select="@xlink:href"/></xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </subjectIdentifier>
    </xsl:if>
  </xsl:template>

  <!-- subjectIdentity/resourceRef -> subjectLocator -->
  <xsl:template match="xtm:subjectIdentity/xtm:resourceRef">
    <subjectLocator href="{@xlink:href}"/>
  </xsl:template>

  <!-- subjectIdentity/topicRef -> itemIdentity -->
  <xsl:template match="xtm:subjectIdentity/xtm:topicRef">
    <itemIdentity href="{@xlink:href}"/>
  </xsl:template>

  <!-- topics -->
  <xsl:template match="xtm:topic">
    <topic id="{@id}">
      <xsl:apply-templates select="xtm:subjectIdentity"/>
      <xsl:if test="count(xtm:instanceOf) != 0">
        <instanceOf>
          <xsl:for-each select="xtm:instanceOf/*">
            <xsl:apply-templates select="."/>
          </xsl:for-each>
        </instanceOf>
      </xsl:if>
      <xsl:apply-templates select="child::*[local-name() != 'instanceOf']
                                           [local-name() != 'subjectIdentity']"/>
    </topic>
  </xsl:template>

  <!-- Since XTM 2.0 knows only topicRef to reference topics, the information if
       a topic is referenced by a subject identifier / subject locator is lost.
       This template adds the information back -->
  <xsl:template name="post-process">
    <!-- sids -->
    <xsl:for-each select="xtm:association/xtm:member/xtm:subjectIndicatorRef|xtm:association/xtm:member/xtm:roleSpec/xtm:subjectIndicatorRef|//xtm:instanceOf/xtm:subjectIndicatorRef|//xtm:scope/xtm:subjectIndicatorRef|//xtm:parameters/xtm:subjectIndicatorRef">
      <topic id="{generate-id(.)}">
        <subjectIdentifier href="{@xlink:href}"/>
      </topic>
    </xsl:for-each>
    <!-- role players / themes which are referenced by their subject locator -->
    <xsl:for-each select="xtm:association/xtm:member/xtm:resourceRef|//xtm:scope/xtm:resourceRef">
      <topic id="{generate-id(.)}">
        <subjectLocator href="{@xlink:href}"/>
      </topic>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
