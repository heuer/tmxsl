<?xml version="1.0" encoding="utf-8"?>
<!--
  ==============================================================
  Open Document Metadata 1.x -> TM/XML 1.0 conversion stylesheet
  ==============================================================
  
  This stylesheet translates the metadata of Open Document 1.x 
  into TM/XML 1.0.

  Open Document: <http://docs.oasis-open.org/office/v1.1/OS/OpenDocument-v1.1.pdf>
  TM/XML: <http://www.ontopia.net/topicmaps/tmxml.html>


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
                exclude-result-prefixes="office meta xlink">

  <xsl:output method="xml" media-type="application/x-tm+tmxml" encoding="utf-8" standalone="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:param name="sid" select="''"/>
  <xsl:param name="slo" select="''"/>

  <xsl:template match="office:meta">
    <!--** Container for the metadata elements -->
    <opendocument-topicmap>
      <!-- TODO: Use a useful type here. Either a generic one like "an-ontology:document" or infer 
                 the document type:
                 * meta:document-statistic/@(paragraph-count|word-count|character-count) -> text document
                 * meta:document-statistic/@cell-count -> spreadsheet
      -->
      <tm:topic>
        <!-- Add an id iff no subject identifier / subject locator was defined -->
        <xsl:if test="not($sid) and not($slo)">
          <xsl:attribute name="id"><xsl:value-of select="generate-id()"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$sid">
          <tm:identifier><xsl:value-of select="$sid"/></tm:identifier>
        </xsl:if>
        <xsl:if test="$slo">
          <tm:locator><xsl:value-of select="$slo"/></tm:locator>
        </xsl:if>
        <xsl:apply-templates select="*"/>
      </tm:topic>
    </opendocument-topicmap>
  </xsl:template>

  <xsl:template match="meta:generator">
    <!--** A string that identifies the application or tool that was used to create or 
           last modify the XML document. -->
    
  </xsl:template>

  <xsl:template match="dc:title">
    <!--** The title of the document. -->
    <iso:topic-name><xsl:value-of select="."/></iso:topic-name>
  </xsl:template>

  <xsl:template match="dc:description">
    <!--** A brief description of the document. -->
    <dc:description><xsl:value-of select="."/></dc:description>
  </xsl:template>

  <xsl:template match="dc:subject">
    <!--** Specifies the subject of the document. -->
  </xsl:template>

  <xsl:template match="meta:keyword">
    <!--** Contains a keyword pertaining to the document. 
           The metadata can contain any number of <meta:keyword> elements, each element 
           specifying one keyword. 
    -->
  </xsl:template>

  <xsl:template match="meta:initial-creator">
    <!--** Specifies the name of the person who created the document initially. -->
    
  </xsl:template>

  <xsl:template match="dc:creator">
    <!--** Specifies the name of the person who last modified the document. -->

  </xsl:template>

  <xsl:template match="meta:printed-by">
    <!--** Specifies the name of the last person who printed the document. -->

  </xsl:template>

  <xsl:template match="meta:creation-date">
    <!--** Specifies the date and time when the document was created initially.
           To conform with [xmlschema-2], the date and time format is YYYY-MM-DDThh:mm:ss.
    -->

  </xsl:template>

  <xsl:template match="dc:date">
    <!--** Specifies the date and time when the document was last modified.
           To conform with [xmlschema-2], the date and time format is YYYY-MM-DDThh:mm:ss.
    -->

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
  </xsl:template>

  <xsl:template match="@meta:table-count">
  </xsl:template>

  <xsl:template match="@meta:draw-count">
  </xsl:template>

  <xsl:template match="@meta:image-count">
  </xsl:template>

  <xsl:template match="@meta:object-count">
  </xsl:template>

  <xsl:template match="@meta:ole-object-count">
  </xsl:template>

  <xsl:template match="@meta:paragraph-count">
  </xsl:template>

  <xsl:template match="@meta:word-count">
  </xsl:template>

  <xsl:template match="@meta:character-count">
  </xsl:template>

  <xsl:template match="@meta:row-count">
  </xsl:template>

  <xsl:template match="@meta:frame-count">
  </xsl:template>

  <xsl:template match="@meta:sentence-count">
  </xsl:template>

  <xsl:template match="@meta:syllable-count">
  </xsl:template>

  <xsl:template match="@meta:non-whitespace-character-count">
  </xsl:template>

  <!--=== Spreadsheet specific statistics ===-->
  
  <xsl:template match="@meta:cell-count">
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