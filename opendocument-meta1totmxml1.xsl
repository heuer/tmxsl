<?xml version="1.0" encoding="utf-8"?>
<!--
  ==============================================================
  Open Document Metadata 1.x -> TM/XML 1.0 conversion stylesheet
  ==============================================================
  
  This stylesheet translates the metadata of Open Document 1.x 
  into TM/XML 1.0.

  Open Document: <http://docs.oasis-open.org/office/v1.1/OS/OpenDocument-v1.1.pdf>
  TM/XML: <http://www.ontopia.net/topicmaps/tmxml.html>
  
  Note: This stylesheet is not very compact, but the ontology is not fixed yet
        and the more verbose form helps me to understand the mapping better :)


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
                xmlns:tm="http://psi.ontopia.net/xml/tm-xml/"
                xmlns:iso="http://psi.topicmaps.org/iso13250/model/"
                xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
                xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
                xmlns:xlink="http://www.w3.org/1999/xlink" 
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:nie="http://www.semanticdesktop.org/ontologies/2007/01/19/nie#"
                xmlns:nco="http://www.semanticdesktop.org/ontologies/2007/03/22/nco#"
                xmlns:nfo="http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#"
                exclude-result-prefixes="office meta xlink">

  <xsl:output method="xml" media-type="application/x-tm+tmxml" encoding="utf-8" standalone="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:param name="sid" select="''"/>
  <xsl:param name="slo" select="''"/>
  
  <xsl:variable name="xsd" select="'http://www.w3.org/2001/XMLSchema#'"/>

  <xsl:template match="office:meta">
    <!--** Container for the metadata elements -->
    <opendocument-topicmap>
      <xsl:variable name="doctype">
        <xsl:choose>
          <!-- Graphic is not detectable, try spreadsheet and text document -->
          <xsl:when test="count(meta:document-statistic/@meta:cell-count) > 0">Spreadsheet</xsl:when>
          <xsl:when test="count(meta:document-statistic[@meta:word-count 
                                  or @meta:paragraph-count or @meta:sentence-count
                                  or @meta:character-count or @meta:syllable-count]) > 0"
              >TextDocument</xsl:when>
          <xsl:otherwise>Document</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:element name="nfo:{$doctype}">
        <!-- Add an id iff no subject identifier / subject locator was defined -->
        <xsl:if test="not($sid) and not($slo)">
          <xsl:attribute name="id"><xsl:value-of select="generate-id()"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$sid">
          <tm:identifier><xsl:value-of select="$sid"/></tm:identifier>
        </xsl:if>
        <xsl:if test="$slo">
          <tm:locator><xsl:value-of select="$slo"/></tm:locator>
          <!-- TODO: Seems to be logical to use the subject locator as file URL 
               although I am not sure if this makes sense in Topic Maps -->
          <nfo:fileUrl datatype="{$xsd}anyURI">
            <xsl:value-of select="$slo"/>
          </nfo:fileUrl>
        </xsl:if>
        <xsl:apply-templates/>
      </xsl:element>
    </opendocument-topicmap>
  </xsl:template>

  <xsl:template match="meta:generator">
    <!--** A string that identifies the application or tool that was used to create or 
           last modify the XML document. -->
    
    <!-- TODO: Should be an assoc -->
    <nie:generator><xsl:value-of select="."/></nie:generator>
  </xsl:template>

  <xsl:template match="dc:title">
    <!--** The title of the document. -->
    <nie:title><tm:value><xsl:value-of select="."/></tm:value></nie:title>
  </xsl:template>

  <xsl:template match="dc:description">
    <!--** A brief description of the document. -->
    <nie:description><xsl:value-of select="."/></nie:description>
  </xsl:template>

  <xsl:template match="dc:subject">
    <!--** Specifies the subject of the document. -->
    <nie:subject><tm:value><xsl:value-of select="."/></tm:value></nie:subject>
  </xsl:template>

  <xsl:template match="meta:keyword">
    <!--** Contains a keyword pertaining to the document. 
           The metadata can contain any number of <meta:keyword> elements, each element 
           specifying one keyword. 
    -->
    <nie:keyword><xsl:value-of select="."/></nie:keyword>
  </xsl:template>

  <xsl:template match="meta:initial-creator">
    <!--** Specifies the name of the person who created the document initially. -->
    
    <!-- TODO: Create an assoc. between the document and an instance of nco:Contact.
               The nco:Contact needs an id that is generated by this element
               (we need the id for the association and the actual nco:Contact instance -->
  </xsl:template>

  <xsl:template match="dc:creator">
    <!--** Specifies the name of the person who last modified the document. -->
    
    <!-- TODO: See meta:initial-creator -->
  </xsl:template>

  <xsl:template match="meta:printed-by">
    <!--** Specifies the name of the last person who printed the document. -->
    
    <!-- TODO: See meta:initial-creator -->
  </xsl:template>

  <xsl:template match="dc:creator|meta:initial-creator|meta:printed-by" mode="topic">
    <!--** Creates an nco:Contact topic from the supplied information -->
    <nco:Contact id="{generate-id(.)}">
      <nco:fullname><tm:value><xsl:value-of select="."/></tm:value></nco:fullname>
    </nco:Contact>
  </xsl:template>

  <xsl:template match="meta:creation-date">
    <!--** Specifies the date and time when the document was created initially.
           To conform with [xmlschema-2], the date and time format is YYYY-MM-DDThh:mm:ss.
    -->
    <nfo:fileCreated datatype="{$xsd}dateTime">
      <xsl:value-of select="."/>
    </nfo:fileCreated>
  </xsl:template>

  <xsl:template match="dc:date">
    <!--** Specifies the date and time when the document was last modified.
           To conform with [xmlschema-2], the date and time format is YYYY-MM-DDThh:mm:ss.
    -->
    <nfo:fileLastModified datatype="{$xsd}dateTime">
      <xsl:value-of select="."/>
    </nfo:fileLastModified>
  </xsl:template>

  <xsl:template match="meta:print-date">
    <!--** Specifies the date and time when the document was last printed.
           To conform with [xmlschema-2], the date and time format is YYYY-MM-DDThh:mm:ss.
    -->

  </xsl:template>

  <xsl:template match="meta:template">
    <!--** Contains a URL for the document template that was used to create the document. 
           The URL is specified as an XLink.
           This element conforms to the XLink Specification. See [XLink].
           The attributes that may be associated with the <meta:template> element are:
           * Template location (xlink:href)
           * Template title (xlink:title)
           * Template modification date and time (meta:date) (YYYY-MM-DDThh:mm:ss)
    -->

    <!-- TODO: Assoc -->

  </xsl:template>

  <xsl:template match="meta:auto-reload">
    <!--** Specifies whether a document is reloaded or replaced by another document after a 
           certain period of time has elapsed.
           The attributes that may be associated with the <meta:auto-reload> element are:
           * Reload URL (xlink:href): The URL of the replacement document.
           * Reload delay (meta:delay) (duration data type of [xmlschema-2] PnYnMnDTnHnMnS)
    -->

  </xsl:template>

  <xsl:template match="meta:hyperlink-behaviour">
    <!--** Specifies the default behavior for hyperlinks in the document.
           The only attribute that may be associated with the <meta:hyperlink-behaviour> element is:
           * Target frame
             The meta:target-frame-name attribute specifies the name of the default target frame in which 
             to display a document referenced by a hyperlink.
             This attribute can have one of the following values:
             * _self : The referenced document replaces the content of the current frame.
             * _blank : The referenced document is displayed in a new frame.
             * _parent : The referenced document is displayed in the parent frame of the current frame.
             * _top : The referenced document is displayed in the topmost frame, that is the frame that 
                      contains the current frame as a child or descendent but is not contained within 
                      another frame.
             * A frame name : The referenced document is displayed in the named frame. If the named frame 
               does not exist, a new frame with that name is created.
            To conform with the XLink Specification, an additional xlink:show attribute is attached to 
            the <meta:hyperlink-behaviour> element. If the value of the meta:target-frame-name attribute 
            is _blank, the xlink:show attribute value is new. If the value of the meta:target-frame-name 
            attribute is any of the other value options, the value of the xlink:show attribute is replace.
    -->

    <!-- TODO: I think this can be ignored -->

  </xsl:template>

  <xsl:template match="dc:language">
    <!--** Specifies the default language of the document.
           The manner in which the language is represented is similar to the language tag described in 
           [RFC3066]. It consists of a two or three letter Language Code taken from the ISO 639 standard 
           optionally followed by a hyphen (-) and a two-letter Country Code taken from the ISO 3166 
           standard.
    -->

  </xsl:template>

  <xsl:template match="meta:editing-cycles">
    <!--** Specifies the number of editing cycles the document has been through. -->
  </xsl:template>

  <xsl:template match="meta:editing-duration">
    <!--** Specifies the total time spent editing the document.
           The duration is represented in the duration data type of [xmlschema-2], that is PnYnMnDTnHnMnS.
    -->
  </xsl:template>


  <!--=== Document statistics ===-->

  <xsl:template match="meta:document-statistic">
    <xsl:apply-templates select="@meta:*"/>
  </xsl:template>

  <xsl:template match="@meta:page-count">
    <!--** Used in:
           * text
           * spreadsheet 
           * graphic 
    -->
    
    <!-- TODO: Acc. to NFO the document must be an instance of nfo:PaginatedTextDocument 
               Check if it's legal for a document to be an instance of PaginatedTextDocument and
               TextDocument / Spreadsheet -->
    <nfo:pageCount datatype="{$xsd}integer">
      <xsl:value-of select="."/>
    </nfo:pageCount>
  </xsl:template>

  <xsl:template match="@meta:table-count">
    <!--** Used in:
           * text
           * spreadsheet 
    -->
  </xsl:template>

  <xsl:template match="@meta:draw-count">
    <!--** Used in:
           * text
    -->
  </xsl:template>

  <xsl:template match="@meta:image-count">
    <!--** Used in:
           * text
           * spreadsheet 
           * graphic 
    -->
  </xsl:template>

  <xsl:template match="@meta:object-count">
    <!--** Used in:
           * text
           * spreadsheet 
           * graphic 
    -->
  </xsl:template>

  <xsl:template match="@meta:ole-object-count">
    <!--** Used in:
           * text
    -->
  </xsl:template>

  <xsl:template match="@meta:paragraph-count">
    <!--** Used in:
           * text
    -->
  </xsl:template>

  <xsl:template match="@meta:word-count">
    <!--** Used in:
           * text
    -->
    <nfo:wordCount datatype="{$xsd}integer">
      <xsl:value-of select="."/>
    </nfo:wordCount>
  </xsl:template>

  <xsl:template match="@meta:character-count">
    <!--** Used in:
           * text
    -->
  </xsl:template>

  <xsl:template match="@meta:row-count">
    <!--** Used in:
           * text
    -->
  </xsl:template>

  <xsl:template match="@meta:frame-count">
    <!--** Used in:
           * text
    -->
  </xsl:template>

  <xsl:template match="@meta:sentence-count">
    <!--** Used in:
           * text
    -->
  </xsl:template>

  <xsl:template match="@meta:syllable-count">
    <!--** Used in:
           * text
    -->
  </xsl:template>

  <xsl:template match="@meta:non-whitespace-character-count">
    <!--** Used in:
           * text
    -->
    <nfo:characterCount datatype="{$xsd}integer">
      <xsl:value-of select="."/>
    </nfo:characterCount>
  </xsl:template>

  <!--=== Spreadsheet specific statistics ===-->
  
  <xsl:template match="@meta:cell-count">
    <!--** Used in:
           * spreadsheet 
    -->
  </xsl:template>


  <!--=== User-defined Metadata ===-->

  <xsl:template match="meta:user-defined">
    <!--** Specifies any additional user-defined metadata for the document. 
           Each instance of this element can contain one piece of user-defined metadata. 
           The element contains:
           * A meta:name attribute, which identifies the name of the metadata element.
           * An optional meta:value-type attribute, which identifies the type of the metadata element. 
             The allowed meta types are float, date, time, boolean and string (see also section 6.7.1).
           * The value of the element, which is the metadata in the format described in section 6.7.1 
             as value of the office:value attributes for the various data types.
    -->
  </xsl:template>

</xsl:stylesheet>