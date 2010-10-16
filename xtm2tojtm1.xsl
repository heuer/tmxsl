<!--
  ======================================
  XTM 2 -> JTM 1.0 conversion stylesheet
  ======================================
  
  This stylesheet translates XTM 2.0 and 2.1 into JSON Topic Maps (JTM) 1.0 and 1.1.

  XTM 2.0: <http://www.isotopicmaps.org/sam/sam-xtm/2006-06-19/>
  JTM 1.0: <http://www.cerny-online.com/jtm/1.0/>
  JTM 1.1: <http://www.cerny-online.com/jtm/1.1/>


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
                xmlns:xtm="http://www.topicmaps.org/xtm/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" media-type="application/x-tm+jtm" encoding="utf-8"
              omit-xml-declaration="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:param name="jtm_version" select="'1.0'"/>

  <xsl:template match="xtm:topicMap">
    <xsl:if test="$jtm_version != '1.0' and $jtm_version != '1.1'">
      <xsl:message terminate="yes">Unsupported JTM version. Expected '1.0' or '1.1'</xsl:message>
    </xsl:if>
    <xsl:text>{"version":"</xsl:text><xsl:value-of select="$jtm_version"/><xsl:text>","item_type":"topicmap",</xsl:text>
    <xsl:call-template name="reifier"/>
    <xsl:apply-templates select="xtm:itemIdentity"/>
    <xsl:apply-templates select="xtm:topic"/>
    <xsl:apply-templates select="xtm:association"/>
    <xsl:variable name="process_isa" select="$jtm_version = '1.0' and count(xtm:topic/xtm:instanceOf) != 0"/>
    <xsl:if test="$process_isa">
      <xsl:choose>
        <xsl:when test="count(xtm:association) = 0">,"associations":[</xsl:when>
        <xsl:otherwise>,</xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="xtm:topic/xtm:instanceOf" mode="jtm10"/>
    </xsl:if>
    <xsl:if test="$process_isa or count(xtm:association) != 0">]</xsl:if>
    <xsl:text>}&#xA;</xsl:text>
  </xsl:template>

  <xsl:template match="xtm:topic">
    <!--** Translates xtm:topic into a JSON object. If it's the first topic, an "topics" array is created -->
    <xsl:choose>
      <!--@ First topic? Create a "topics" array -->
      <xsl:when test="position() = 1">,"topics":[</xsl:when>
      <!--@ Not the first topic, add the topic to the array -->
      <xsl:otherwise>,</xsl:otherwise>
    </xsl:choose>
    <xsl:text>{"item_identifiers":[</xsl:text>
    <xsl:choose>
        <xsl:when test="@id">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="concat('#', @id)"/>
            <xsl:text>"</xsl:text>
            <xsl:for-each select="xtm:itemIdentity">
                <xsl:text>,</xsl:text>
                <xsl:apply-templates select="@href" mode="iri"/>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <xsl:for-each select="xtm:itemIdentity">
                <xsl:if test="position() != 1"><xsl:text>,</xsl:text></xsl:if>
                <xsl:apply-templates select="@href" mode="iri"/>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:text>]</xsl:text>
    <xsl:apply-templates select="xtm:subjectIdentifier"/>
    <xsl:apply-templates select="xtm:subjectLocator"/>
    <xsl:if test="$jtm_version = '1.1'">
      <xsl:apply-templates select="xtm:instanceOf" mode="jtm11"/>
    </xsl:if>
    <xsl:apply-templates select="xtm:name"/>
    <xsl:apply-templates select="xtm:occurrence"/>
    <xsl:text>}</xsl:text>
    <!--@ Last topic? Finish the array -->
    <xsl:if test="position() = last()">]</xsl:if>
  </xsl:template>

  <xsl:template match="xtm:instanceOf" mode="jtm11">
    <!--** Creates an "instance_of" array in JTM 1.1 -->
    <xsl:if test="position() = 1">,"instance_of":[</xsl:if>
    <xsl:apply-templates/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  
  <xsl:template match="xtm:topic/xtm:instanceOf" mode="jtm10">
    <!--** Converts xtm:instanceOf into associations (JTM 1.0) -->
    <xsl:variable name="instance_player">
      <xsl:choose>
        <xsl:when test="../xtm:subjectIdentifier">
            <xsl:call-template name="string">
                <xsl:with-param name="s" select="concat('si:', ../xtm:subjectIdentifier/@href)"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="../xtm:subjectLocator">
            <xsl:call-template name="string">
                <xsl:with-param name="s" select="concat('sl:', ../xtm:subjectLocator/@href)"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="../xtm:itemIdentity">
            <xsl:call-template name="string">
                <xsl:with-param name="s" select="concat('ii:', ../xtm:itemIdentity/@href)"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="concat('&quot;ii:#', ../@id, '&quot;')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="xtm:*">
      <xsl:text>{"type":"si:http://psi.topicmaps.org/iso13250/model/type-instance","roles":[{"type": "si:http://psi.topicmaps.org/iso13250/model/instance","player":</xsl:text><xsl:value-of select="$instance_player"/><xsl:text>},{"type":"si:http://psi.topicmaps.org/iso13250/model/type","player":</xsl:text>
      <xsl:apply-templates select="."/>
      <xsl:text>}]}</xsl:text>
      <xsl:if test="position() != last()">,</xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="xtm:itemIdentity|xtm:subjectIdentifier|xtm:subjectLocator">
    <!--** Translates item identifiers != topic iids, subject identifiers and subject locators into a JSON array -->
    <xsl:if test="position() = 1">
      <xsl:choose>
        <xsl:when test="local-name(.) = 'subjectIdentifier'">,"subject_identifiers":[</xsl:when>
        <xsl:when test="local-name(.) = 'subjectLocator'">,"subject_locators":[</xsl:when>
        <xsl:otherwise>,"item_identifiers":[</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates select="@href" mode="iri"/>
    <xsl:choose>
      <xsl:when test="position() = last()">]</xsl:when>
      <xsl:otherwise>,</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@href" mode="iri">
    <xsl:call-template name="string">
      <xsl:with-param name="s" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="@href|@reifier" mode="topic-ref">
    <xsl:call-template name="string">
      <xsl:with-param name="s" select="concat('ii:', .)"/>
    </xsl:call-template>
  </xsl:template>

  <!-- catch all for constructs != topic and topicMap -->
  <xsl:template match="xtm:association|xtm:occurrence|xtm:name|xtm:variant|xtm:role">
    <xsl:if test="position() = 1">
      <xsl:value-of select="concat(',&quot;', local-name(.), 's', '&quot;:[')"/>
    </xsl:if>
    <xsl:text>{</xsl:text>
    <xsl:call-template name="reifier"/>
    <xsl:apply-templates select="xtm:itemIdentity"/> 
    <xsl:apply-templates select="xtm:type"/>
    <xsl:apply-templates select="xtm:scope"/>
    <xsl:apply-templates select="xtm:value|xtm:resourceRef|xtm:resourceData|xtm:topicRef|xtm:subjectIdentifierRef|xtm:subjectLocatorRef"/>
    <xsl:apply-templates select="xtm:role|xtm:variant"/>
    <xsl:text>}</xsl:text>
    <xsl:if test="position() != last()">,</xsl:if>
    <xsl:if test="position() = last() and local-name(.) != 'association'">]</xsl:if>
  </xsl:template>

  <xsl:template match="xtm:topicRef|xtm:subjectIdentifierRef|xtm:subjectLocatorRef">
    <xsl:if test="parent::xtm:role">
      <xsl:text>,"player":</xsl:text>
    </xsl:if>
    <xsl:variable name="prefix">
      <xsl:choose>
        <xsl:when test="local-name(.) = 'subjectIdentifierRef'"><xsl:value-of select="'si'"/></xsl:when>
        <xsl:when test="local-name(.) = 'subjectLocatorRef'"><xsl:value-of select="'sl'"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="'ii'"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="string">
      <xsl:with-param name="s" select="concat($prefix, ':', @href)"/>
    </xsl:call-template>
    <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
  </xsl:template>

  <xsl:template match="xtm:value|xtm:type|xtm:scope">
    <xsl:value-of select="concat(',&quot;', local-name(.), '&quot;:')"/>
    <xsl:if test="local-name(.) = 'scope'">[</xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="local-name(.) = 'scope'">]</xsl:if>
  </xsl:template>

  <xsl:template match="xtm:resourceRef|xtm:resourceData[@datatype = 'http://www.w3.org/2001/XMLSchema#anyURI']">
    <!--** Translates xtm:resourceData and xtm:resourceRef into "value":"...". The datatype is set to xsd:anyURI  -->
    <xsl:text>,"datatype":</xsl:text>
    <xsl:choose>
      <xsl:when test="$jtm_version = '1.1'">"[xsd:anyURI]"</xsl:when>
      <xsl:otherwise>"http://www.w3.org/2001/XMLSchema#anyURI"</xsl:otherwise>
    </xsl:choose>
    <xsl:text>,"value":</xsl:text>
    <xsl:call-template name="string">
      <xsl:with-param name="s" select="@href|text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="xtm:resourceData[not(@datatype) or @datatype = 'http://www.w3.org/2001/XMLSchema#string']">
    <!--** Translates xtm:resourceData into "value":"...". The datatype is omitted  -->
    <xsl:text>,"value":</xsl:text>
    <xsl:choose>
      <xsl:when test="not(text())">""</xsl:when>
      <xsl:otherwise><xsl:apply-templates select="text()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xtm:resourceData[@datatype]">
    <!--** Translates xtm:resourceData into a value / datatype pair -->
    <xsl:text>,"datatype":</xsl:text>
    <xsl:choose>
      <xsl:when test="$jtm_version = '1.1' and starts-with(@datatype, 'http://www.w3.org/2001/XMLSchema#')">
        <xsl:text>"[xsd:</xsl:text><xsl:value-of select="substring-after(@datatype, 'http://www.w3.org/2001/XMLSchema#')"/><xsl:text>]"</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="string">
          <xsl:with-param name="s" select="@datatype"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>,"value":</xsl:text>
    <xsl:apply-templates select="text()"/>
  </xsl:template>
  
  <xsl:template name="reifier">
    <!--** Writes reifier reference (maybe 'null') to the output.
           All constructs in the output start with the reifier property to have common structure
           to write further properties of the constructs. -->
    <xsl:text>"reifier":</xsl:text>
    <xsl:choose>
      <xsl:when test="@reifier">
        <xsl:apply-templates select="@reifier" mode="topic-ref"/>
      </xsl:when>
      <xsl:when test="xtm:reifier">
          <xsl:apply-templates select="xtm:reifier/xtm:*"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>null</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="string" match="text()">
    <xsl:param name="s" select="."/>
    <xsl:text>"</xsl:text>
    <xsl:call-template name="escape-bs-string">
      <xsl:with-param name="s" select="$s"/>
    </xsl:call-template>
    <xsl:text>"</xsl:text>
  </xsl:template>
  

<!-- 
  The following code was taken from 
  <http://code.google.com/p/xml2json-xslt/source/browse/trunk/xml2json.xslt>

  Copyright (c) 2006,2008 Doeke Zanstra
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, 
  are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer. Redistributions in binary 
  form must reproduce the above copyright notice, this list of conditions and the 
  following disclaimer in the documentation and/or other materials provided with 
  the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
  THE POSSIBILITY OF SUCH DAMAGE.
-->

  <!-- Escape the backslash (\) before everything else. -->
  <xsl:template name="escape-bs-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="contains($s,'\')">
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'\'),'\\')"/>
        </xsl:call-template>
        <xsl:call-template name="escape-bs-string">
          <xsl:with-param name="s" select="substring-after($s,'\')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="$s"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Escape the double quote ("). -->
  <xsl:template name="escape-quot-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="contains($s,'&quot;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&quot;'),'\&quot;')"/>
        </xsl:call-template>
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="substring-after($s,'&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="$s"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Replace tab, line feed and/or carriage return by its matching escape code. Can't escape backslash
       or double quote here, because they don't replace characters (&#x0; becomes \t), but they prefix 
       characters (\ becomes \\). Besides, backslash should be seperate anyway, because it should be 
       processed first. This function can't do that. -->
  <xsl:template name="encode-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <!-- tab -->
      <xsl:when test="contains($s,'&#x9;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&#x9;'),'\t',substring-after($s,'&#x9;'))"/>
        </xsl:call-template>
      </xsl:when>
      <!-- line feed -->
      <xsl:when test="contains($s,'&#xA;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&#xA;'),'\n',substring-after($s,'&#xA;'))"/>
        </xsl:call-template>
      </xsl:when>
      <!-- carriage return -->
      <xsl:when test="contains($s,'&#xD;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&#xD;'),'\r',substring-after($s,'&#xD;'))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$s"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
