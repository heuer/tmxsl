<?xml version="1.0" encoding="utf-8"?>
<!--
  ====================================
  RSS -> XTM 2.1 conversion stylesheet
  ====================================
  
  This stylesheet translates RSS into XTM 2.1.

  RSS: <http://www.rssboard.org/rss-specification>
  RSS 1.0: <http://web.resource.org/rss/1.0/spec>
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
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rss="http://purl.org/rss/1.0/"
                xmlns="http://www.topicmaps.org/xtm/"
                xmlns:str="http://exslt.org/strings"
                extension-element-prefixes="str"
                exclude-result-prefixes="dc rdf rss">

  <xsl:output method="xml" media-type="application/x-tm+xtm" encoding="utf-8" standalone="yes"/>

  <xsl:strip-space elements="*"/>

  <!-- RSS 1.0 -->

  <xsl:template match="/rdf:RDF">
    <!--** Matches RSS 1.0 -->
    <topicMap version="2.1">
      <xsl:apply-templates select="rss:channel"/>
      <xsl:apply-templates select="rss:item"/>
    </topicMap>
  </xsl:template>

  <xsl:template match="rss:channel">
    <!--** Creates an reifier for the channel and converts each RSS item into a topic -->
    <reifier>
      <subjectLocatorRef href="{rss:link}"/>
    </reifier>
    <topic>
      <subjectLocator href="{rss:link}"/>
      <xsl:apply-templates select="rss:title|rss:description|dc:date|dc:rights"/>
    </topic>
  </xsl:template>

  <!-- RSS 0.9x, 2.0 -->

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

  <xsl:template match="item[link]|rss:item">
    <!--** Converts RSS items into topics and connects each item with the item's author -->
    <topic>
      <xsl:apply-templates select="link|guid|rss:link"/>
      <xsl:apply-templates select="title|rss:title|description|rss:description|pubDate|dc:date"/>
    </topic>
    <!-- Associations -->
    <xsl:apply-templates select="author"/>
    <xsl:apply-templates select="dc:creator"/>
    <xsl:apply-templates select="dc:relation"/>
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

  <xsl:template match="dc:relation">
    <!--** Converts dc:relation into an association -->
    <association>
      <type><subjectIdentifierRef href="http://purl.org/dc/elements/1.1/relation"/></type>
      <role>
        <type><subjectIdentifierRef href="http://psi.topicmaps.org/iso29111/resource"/></type>
        <subjectLocatorRef href="{../link|../rss:link}"/>
      </role>
      <role>
        <type><subjectIdentifierRef href="http://psi.topicmaps.org/iso29111/value"/></type>
        <subjectLocatorRef href="{.}"/>
      </role>
    </association>
  </xsl:template>

  <xsl:template match="link|rss:link">
    <!--** Converts RSS link into a subject locator (within a topic context) -->
    <subjectLocator href="{.}"/>
  </xsl:template>

  <xsl:template match="guid">
    <!--** Converts RSS guid into a subject locator iff the guid is a permalink 
           
           Only guids with permalinks MUST be IRIs, all other guids may simply be
           a unique string if I understood the RSS spec correctly. So, we're ignoring
           non-permalink guids
    -->
    <xsl:if test="@isPermaLink = 'true'">
      <subjectLocator href="{.}"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="title|rss:title">
    <!--** Converts RSS title into a name -->
    <name><value><xsl:value-of select="."/></value></name>
  </xsl:template>

  <xsl:template match="description|rss:description">
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

  <xsl:template match="dc:creator">
    <!--** Converts dc:creator into an association which connects the item with the author 
           
           Since dc:creator is almost always a string, a topic (with an item identifier) 
           is created for the dc:creator.
    -->
    <association>
      <type><subjectIdentifierRef href="http://purl.org/dc/terms/creator"/></type>
      <!--@ The item plays the "resource" role -->
      <role>
        <type><subjectIdentifierRef href="http://psi.topicmaps.org/iso29111/resource"/></type>
        <subjectLocatorRef href="{../link|../rss:link}"/>
      </role>
      <!--@ dc:creator plays the "value" role -->
      <role>
        <type><subjectIdentifierRef href="http://psi.topicmaps.org/iso29111/value"/></type>
        <topicRef href="#{generate-id(.)}"/>
      </role>
    </association>
    <topic id="{generate-id(.)}">
      <name><value><xsl:value-of select="."/></value></name>
    </topic>
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




  <!-- RFC822 date parser -->
  
  <!--
        Created by David Powell 
        
        <http://djpowell.net/atomrdf/0.1/files/rssdates.xsl>
  -->
  
  
  
  <!-- $Id: rssdates.xsl,v 1.3 2006/05/01 19:28:29 Dave Exp $ -->


  <xsl:template name="convertRssDate">    
    <xsl:param name="in" />
    <xsl:variable name="normDate">
     <xsl:call-template name="addSeconds">
        <xsl:with-param name="in">
          <xsl:call-template name="make4DigitYear">
            <xsl:with-param name="in">
              <xsl:call-template name="padDay">
                <xsl:with-param name="in">
                  <xsl:call-template name="stripDOW">
                    <xsl:with-param name="in">
                      <xsl:call-template name="stripLWSP">
                        <xsl:with-param name="in" select="$in" />
                      </xsl:call-template>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <!-- YYYY -->
    <xsl:value-of select="substring($normDate, 6, 4)" />
    <xsl:text>-</xsl:text>

    <!-- MM -->
    <xsl:call-template name="convertMonth">
      <xsl:with-param name="in" select="substring($normDate, 3, 3)" />
    </xsl:call-template>
    <xsl:text>-</xsl:text>

    <!-- DD -->
    <xsl:value-of select="substring($normDate, 1, 2)" />
    <xsl:text>T</xsl:text>

    <!-- HH -->
    <xsl:value-of select="substring($normDate, 10, 2)" />
    <xsl:text>:</xsl:text>

    <!-- MM -->
    <xsl:value-of select="substring($normDate, 13, 2)" />
    <xsl:text>:</xsl:text>

    <!-- SS -->
    <xsl:value-of select="substring($normDate, 16, 2)" />

    <xsl:call-template name="convertZone">
      <xsl:with-param name="in" select="substring($normDate, 18)" />
    </xsl:call-template>

  </xsl:template>

  <!-- Mon,01Jan199900:00:00GMT -->
  <!-- ooooOrRRRooRRrrRrrOooRRR -->
  <xsl:template name="stripLWSP">
    <xsl:param name="in" />
    <xsl:call-template name="stripComments">
      <xsl:with-param name="in">
        <xsl:call-template name="stripEscapedBrackets">
          <xsl:with-param name="in">
            <!-- remove all spaces -->
            <xsl:value-of select="translate(normalize-space($in), ' ', '')" />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="stripDOW">
    <xsl:param name="in" />
    <xsl:choose>
      <xsl:when test="string(number(substring($in, 1, 1))) = 'NaN'">
        <xsl:value-of select="substring($in, 5)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$in" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="padDay">
    <xsl:param name="in" />
    <xsl:if test="string(number(substring($in, 2, 1))) = 'NaN'">
      <xsl:text>0</xsl:text>
    </xsl:if>
    <xsl:value-of select="$in" />
  </xsl:template>

  <!-- 01Jan199900:00:00GMT -->
  <!-- 01Jan9900:00:00GMT -->
  <xsl:template name="make4DigitYear">
    <xsl:param name="in" />
    <xsl:choose>
      <xsl:when test="substring($in, 10, 1) = ':'">
        <xsl:value-of select="substring($in, 1, 5)" />
        <xsl:variable name="year2" select="substring($in, 6, 2)" />
        <xsl:choose>
          <xsl:when test="number($year2) > 30">
            <xsl:text>19</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>20</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="substring($in, 6)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$in" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- 01Jan199900:00GMT -->
  <!-- 01Jan199900:00:00GMT -->
  <xsl:template name="addSeconds">
    <xsl:param name="in" />
    <xsl:choose>
      <xsl:when test="substring($in, 15, 1) = ':'">
        <xsl:value-of select="$in" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="substring($in, 1, 14)" />
        <xsl:text>:00</xsl:text>
        <xsl:value-of select="substring($in, 15)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!--
       zone        =  "UT"  / "GMT"                ; Universal Time
                                                 ; North American : UT
                 /  "EST" / "EDT"                ;  Eastern:  - 5/ - 4
                 /  "CST" / "CDT"                ;  Central:  - 6/ - 5
                 /  "MST" / "MDT"                ;  Mountain: - 7/ - 6
                 /  "PST" / "PDT"                ;  Pacific:  - 8/ - 7
                 /  1ALPHA                       ; Military: Z = UT;
                                                 ;  A:-1; (J not used)
                                                 ;  M:-12; N:+1; Y:+12
                 / ( ("+" / "-") 4DIGIT )        ; Local differential
-->
  <xsl:template name="convertZone">
    <xsl:param name="in" />
    <xsl:variable name="inu" select="translate($in, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
    <xsl:variable name="inu1" select="substring($inu, 1, 1)" />
    <xsl:choose>
      <xsl:when test="$inu1 = '+' or $inu1 = '-'">
        <xsl:value-of select="substring($inu, 1, 3)" />
        <xsl:text>:</xsl:text>
        <xsl:value-of select="substring($inu, 4)" />
      </xsl:when>
      <xsl:when test="$inu = 'UT' or $inu = 'GMT'">-00:00</xsl:when>
      <xsl:when test="$inu = 'EDT'">-04:00</xsl:when>
      <xsl:when test="$inu = 'EST' or $inu = 'CDT'">-05:00</xsl:when>
      <xsl:when test="$inu = 'CST' or $inu = 'MDT'">-06:00</xsl:when>
      <xsl:when test="$inu = 'MST' or $inu = 'PDT'">-07:00</xsl:when>
      <xsl:when test="$inu = 'PST'">-08:00</xsl:when>
      <xsl:otherwise>
        <!-- military time -->
        <xsl:variable name="t1" select="translate($inu1, 'ABCDEFGHIZ', '1234567890')" />
        <xsl:choose>
          <xsl:when test="string(number($t1)) != 'NaN'">
            <xsl:text>-0</xsl:text>
            <xsl:value-of select="$t1" />
            <xsl:text>:00</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="t2" select="translate($inu1, 'NOPQRSTUV', '123456789')" />
            <xsl:choose>
              <xsl:when test="string(number($t2)) != 'NaN'">
                <xsl:text>+0</xsl:text>
                <xsl:value-of select="$t2" />
                <xsl:text>:00</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="t3" select="translate($inu1, 'KLM', '012')" />
                <xsl:choose>
                  <xsl:when test="string(number($t3)) != 'NaN'">
                    <xsl:text>-1</xsl:text>
                    <xsl:value-of select="$t3" />
                    <xsl:text>:00</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:variable name="t4" select="translate($inu1, 'WXY', '012')" />
                    <xsl:text>+1</xsl:text>
                    <xsl:value-of select="$t4" />
                    <xsl:text>:00</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="stripEscapedBrackets">
    <xsl:param name="in" />
    <xsl:choose>
      <xsl:when test="substring-before($in, '\') != ''">
        <xsl:value-of select="substring-before($in, '\')" />
        <!-- strip next char -->
        <xsl:call-template name="stripEscapedBrackets">
          <xsl:with-param name="in" select="substring(substring-after($in, '\'), 3)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$in" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="stripComments">
    <xsl:param name="in" />
    <xsl:param name="commentLevel" select="0" />
    
    <xsl:variable name="nextToken">
      <xsl:variable name="open" select="substring-before($in, '(')" />
      <xsl:variable name="close" select="substring-before($in, ')')" />
      <xsl:choose>
        <xsl:when test="$open = '' and $close = ''">
          <!-- substring-before might have returned empty because the
               first character was the token, let's return the first
               character as a seperator -->
          <xsl:value-of select="substring($in, 1, 1)" />
        </xsl:when>
        <xsl:when test="$open = ''">
          <xsl:text>)</xsl:text>
        </xsl:when>
        <xsl:when test="$close = ''">
          <xsl:text>(</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="string-length($open) > string-length($close)">
              <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>(</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>        
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$nextToken = '('">
        <xsl:if test="$commentLevel = 0">
          <xsl:value-of select="substring-before($in, '(')" />
        </xsl:if>
        <xsl:call-template name="stripComments">
          <xsl:with-param name="in" select="substring-after($in, '(')" />
          <xsl:with-param name="commentLevel" select="$commentLevel + 1" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$nextToken = ')'">
        <xsl:if test="$commentLevel = 0">
          <xsl:value-of select="substring-before($in, ')')" />
        </xsl:if>
        <xsl:call-template name="stripComments">
          <xsl:with-param name="in" select="substring-after($in, ')')" />
          <xsl:with-param name="commentLevel" select="$commentLevel - 1" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$in" />
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>

  <xsl:template name="convertMonth">
    <xsl:param name="in" />
    <xsl:variable name="inu" select="translate($in, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
    <xsl:choose>
      <xsl:when test="$inu = 'JAN'">
        <xsl:text>01</xsl:text>
      </xsl:when>
      <xsl:when test="$inu = 'FEB'">
        <xsl:text>02</xsl:text>
      </xsl:when>
      <xsl:when test="$inu = 'MAR'">
        <xsl:text>03</xsl:text>
      </xsl:when>
      <xsl:when test="$inu = 'APR'">
        <xsl:text>04</xsl:text>
      </xsl:when>
      <xsl:when test="$inu = 'MAY'">
        <xsl:text>05</xsl:text>
      </xsl:when>
      <xsl:when test="$inu = 'JUN'">
        <xsl:text>06</xsl:text>
      </xsl:when>
      <xsl:when test="$inu = 'JUL'">
        <xsl:text>07</xsl:text>
      </xsl:when>
      <xsl:when test="$inu = 'AUG'">
        <xsl:text>08</xsl:text>
      </xsl:when>
      <xsl:when test="$inu = 'SEP'">
        <xsl:text>09</xsl:text>
      </xsl:when>
      <xsl:when test="$inu = 'OCT'">
        <xsl:text>10</xsl:text>
      </xsl:when>
      <xsl:when test="$inu = 'NOV'">
        <xsl:text>11</xsl:text>
      </xsl:when>
      <xsl:when test="$inu = 'DEC'">
        <xsl:text>12</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>Unparsable date: </xsl:text>
          <xsl:value-of select="$in" />
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
