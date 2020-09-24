<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:docinfo="http://www.lexis-nexis.com/glp/docinfo"
    xmlns:case="http://www.lexis-nexis.com/glp/case" xmlns:ci="http://www.lexis-nexis.com/ci" xmlns:leg="http://www.lexis-nexis.com/glp/leg" xmlns:user="http://mynamespace1"
    xmlns:fn="http://mynamespace2" xmlns:comm="http://www.lexis-nexis.com/glp/comm" version="2.0">

    <!-- 
            Developed By        :   Keshav Kumar and Sandeep Kumar
            Version             :   2.4
            Modification Date   :   14-Feb-2018
    -->

    <xsl:output method="text"/>
    <xsl:variable name="files1"
        select="collection(concat(replace(substring-before(document-uri(.), tokenize(document-uri(.), '/')[last()]), '%20', ' '), '?select=*.xml;recurse=yes')) | collection(concat(replace(substring-before(document-uri(.), tokenize(document-uri(.), '/')[last()]), '%20', ' '), '?select=*.XML;recurse=yes'))"/>

    <xsl:variable name="mulbookseqnum">
        <xsl:for-each select="$files1">
            <xsl:if test=".//docinfo:bookseqnum[normalize-space(.) != ''][normalize-space(.) = $files1[document-uri(.) != document-uri(current())]//docinfo:bookseqnum[normalize-space(.) != '']]">
                <xsl:element name="bookseqnum">
                    <xsl:element name="file_name">
                        <xsl:value-of select="tokenize(document-uri(.), '/')[last()]"/>
                    </xsl:element>
                    <xsl:copy-of select=".//docinfo:bookseqnum"/>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="muldocid">
        <xsl:for-each select="$files1">
            <xsl:for-each select=".//docinfo:doc-id">
                <xsl:if test=". = $files1[document-uri(.) != document-uri(current())]//docinfo:doc-id or . = preceding::docinfo:doc-id">
                    <xsl:element name="docid">
                        <xsl:element name="file_name">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                        </xsl:element>
                        <xsl:copy-of select="."/>
                    </xsl:element>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:variable>
	
    <xsl:template match="/">
        <xsl:result-document href="DIValidationLog.txt" method="text">
            <xsl:text>Dated: </xsl:text>
            <xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]/[M01]/[D01] [H01]:[m01]:[s01]')"/>
            <xsl:text>&#x0a;&#x0a;</xsl:text>
            <xsl:choose>
                <xsl:when
                    test="$files1//fnr[not(@fntoken = //footnote/@fntoken)] or $files1//footnote[@fntoken = ./preceding::footnote/@fntoken] or $files1//remotelink[@refpt = '' or @dpsi = '' or not(@refpt) or not(@dpsi)] or $files1[not(.//docinfo:bookseqnum)] or $files1//docinfo:bookseqnum[normalize-space(.) = ''] or $files1[contains(tokenize(document-uri(.), '/')[last()], '.XML')] or $files1//LEGDOC//leg:body//leg:level/leg:level-vrnt[1][@toc-caption = ''] or $files1//LEGDOC//leg:body//leg:level/leg:level-vrnt[1][not(attribute::toc-caption)] or $files1//*[@href = ''] or $files1//locator[translate(@anchoridref, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_:', '') != ''] or $mulbookseqnum/bookseqnum or $muldocid/docid or $dateValidation/* or $files1//date or $files1//case:party/case:courtcode or $files1//case:party/case:juris or $files1//case:party/case:judges or $files1//case:party/case:filenum or $files1//case:party/case:dates or $files1//text/ol or $files1//p/emph or $files1//entry/@rotate or $files1//p/text()[normalize-space(.) != ''] or $files1//@iso-cc[normalize-space(.) = ''] or $files1//ci:page/@count or $files1//ci:page[not(@num)] or $files1/caseml or $files1//caseopt or $files1//party or $files1//sol">

                    <!-- Wrapper "for-each" -->
                    <xsl:for-each select="$files1">

                        <!-- 1. Missing footnote ID -->

                        <xsl:for-each select=".//fnr">
                            <xsl:choose>
                                <!--<xsl:when test="./@fntoken = //footnote/@fntoken or ./@fntoken = //footnote/@fnrtokens or ./@fntoken = //footnote/@fnrtokens[. = contains(.,current()/@fntoken)]"/>-->
                                <xsl:when
                                    test="./@fntoken = //footnote/@fntoken or ./@fntoken = //footnote/@fnrtokens or //footnote/@fnrtokens[contains(., current()/@fntoken)] or //footnote/@fnrtokens[contains(., current()/@fnrtoken)]"/>
                                <!--<xsl:when test="./@fntoken = //footnote/@fntoken"/>-->
                                <xsl:otherwise>
                                    <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                                    <xsl:text>: </xsl:text>
                                    <xsl:text>Footnote reference with refID: </xsl:text>
                                    <xsl:value-of select="./@fntoken"/>
                                    <xsl:text> does not exist</xsl:text>
                                    <xsl:text>&#x0a;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                            <xsl:choose>
                                <xsl:when test="./@fntoken[contains(., '-R')]">
                                    <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                                    <xsl:text>: </xsl:text>
                                    <xsl:text>FNR fntoken may contain wrong value: </xsl:text>
                                    <xsl:value-of select="./@fntoken"/>
                                    <xsl:text>&#x0a;</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>

                        <!-- Old code -->
                        <!--<xsl:for-each select=".//fnr">
                            <xsl:choose>
                                <xsl:when test="./@fntoken = //footnote/@fntoken"/>
                                <!-\-<xsl:when test="./@fntoken = //footnote/@fnrtokens[. = contains(.,current()/@fntoken)]"/>-\->
                                <xsl:otherwise>
                                    <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                                    <xsl:text>: </xsl:text>
                                    <xsl:text>Footnote reference with refID: </xsl:text><xsl:value-of select="./@fntoken"/><xsl:text> does not exist</xsl:text>
                                    <xsl:text>&#x0a;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>-->

                        <!-- 2. Duplicate footnote ID -->

                        <xsl:for-each select=".//footnote[@fntoken = preceding::footnote/@fntoken]">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>Footnote with ID </xsl:text>
                            <xsl:value-of select="@fntoken"/>
                            <xsl:text> are duplicate </xsl:text>

                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:for-each select="@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:for-each>

                        <!-- 3. Blank remotelink/@refpt or remotelink/@dpsi -->

                        <xsl:for-each select=".//remotelink[@refpt = '' or @dpsi = '' or not(@refpt) or not(@dpsi)]">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:choose>
                                <xsl:when test="not(@refpt) and @dpsi">
                                    <xsl:text>Missing @refpt attribute in </xsl:text>
                                </xsl:when>
                                <xsl:when test="@refpt and not(@dpsi)">
                                    <xsl:text>Missing @dpsi attribute in </xsl:text>
                                </xsl:when>
                                <xsl:when test="not(@refpt) and not(@dpsi)">
                                    <xsl:text>Missing both @refpt and @dpsi attribute in </xsl:text>
                                </xsl:when>
                                <xsl:when
                                    test="normalize-space(@refpt) = '' and normalize-space(@dpsi) != ''">
                                    <xsl:text>Blank value of @refpt in </xsl:text>
                                </xsl:when>
                                <xsl:when
                                    test="normalize-space(@refpt) != '' and normalize-space(@dpsi) = ''">
                                    <xsl:text>Blank value of @dpsi in </xsl:text>
                                </xsl:when>
                                <xsl:when
                                    test="normalize-space(@refpt) = '' and normalize-space(@dpsi) = ''">
                                    <xsl:text>Blank value of both @refpt and @dpsi in </xsl:text>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:for-each select="@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:for-each>


                        <!-- 3a. Blank remotelink/@docidref -->
                        
                        <!--<xsl:for-each select=".//remotelink[@docidref = '' or not(@docidref)]">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:choose>
                                <xsl:when test="not(@docidref)">
                                    <xsl:text>Missing @docidref attribute in </xsl:text>
                                </xsl:when>
                                <xsl:when test="normalize-space(@docidref) = ''">
                                    <xsl:text>Blank value of @docidref attribute in </xsl:text>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:for-each select="@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:for-each>-->
                        
                        
                        <!-- 4. Blank docinfo:bookseqnum -->

                        <xsl:choose>
                            <xsl:when test=".[not(.//docinfo:bookseqnum)]">
                                <xsl:value-of select="tokenize(document-uri(.), '/')[last()]"/>
                                <xsl:text>: Does not contain bookseqnum&#x0a;</xsl:text>
                            </xsl:when>
                            <xsl:when test=".//docinfo:bookseqnum[normalize-space(.) = '']">
                                <xsl:value-of select="tokenize(document-uri(.), '/')[last()]"/>
                                <xsl:text>: Blank bookseqnum&#x0a;</xsl:text>
                            </xsl:when>
                        </xsl:choose>

                        <!-- 5. Upper case File extension -->

                        <xsl:if test="contains(tokenize(document-uri(.), '/')[last()], '.XML')">
                            <xsl:value-of select="tokenize(document-uri(.), '/')[last()]"/>
                            <xsl:text>: File extension is in upper case&#x0a;</xsl:text>
                        </xsl:if>

                        <!-- 6. rosetta ID and docinfo:doc-id must not be equal  -->

                        <xsl:for-each select=".//rosetta/*">
                            <xsl:if
                                test="lower-case(ancestor::rosetta/@id) = lower-case(.//docinfo:doc-id)">
                                <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                                <xsl:text>: (</xsl:text>
                                <xsl:value-of select="ancestor::rosetta/@id"/>
                                <xsl:text>) rosetta id and docinfo:doc-id value should not be equal&#x0a;</xsl:text>
                            </xsl:if>
                        </xsl:for-each>

                        <!-- 7. leg:level-vrnt/@toc-caption must not be empty or missing  -->

                        <xsl:for-each select=".//LEGDOC//leg:body//leg:level/leg:level-vrnt[1][@toc-caption=''] | .//LEGDOC//leg:body//leg:level/leg:level-vrnt[1][not(attribute::toc-caption)]">
                            <xsl:choose>
                                <xsl:when test="not(@toc-caption)">
                                    <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                                    <xsl:text>: </xsl:text>
                                    <xsl:text>toc-caption attribute of element leg:level-vrnt is not present</xsl:text>
                                    <xsl:text>&lt;leg:level-vrnt</xsl:text>
                                    <xsl:for-each select="@*">
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="name(.)"/>
                                        <xsl:text>="</xsl:text>
                                        <xsl:value-of select="."/>
                                        <xsl:text>"</xsl:text>
                                    </xsl:for-each>
                                    <xsl:text>&gt;&#x0a;</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                                    <xsl:text>: </xsl:text>
                                    <xsl:text>toc-caption attribute of element leg:level-vrnt is blank</xsl:text>
                                    <xsl:text>: </xsl:text>
                                    <xsl:text>&lt;leg:level-vrnt</xsl:text>
                                    <xsl:for-each select="@*">
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="name(.)"/>
                                        <xsl:text>="</xsl:text>
                                        <xsl:value-of select="."/>
                                        <xsl:text>"</xsl:text>
                                    </xsl:for-each>
                                    <xsl:text>&gt;&#x0a;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>

                        <!-- 8. @href must not be empty -->

                        <xsl:for-each select=".//*[@href = '']">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>href attribute should not be empty: </xsl:text>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name()"/>
                            <xsl:for-each select="@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;&#x0a;</xsl:text>
                        </xsl:for-each>

                        <!-- 9. locator/@anchoridref value must be valid NMTOKEN  -->

                        <xsl:for-each
                            select=".//locator[translate(@anchoridref, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_:', '') != '']">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>locator/@anchoridref value not valid NMTOKEN: </xsl:text>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name()"/>
                            <xsl:for-each select="@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;&#x0a;</xsl:text>
                        </xsl:for-each>

                        <xsl:for-each select=".//entry[@charoff]">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>entry contains @charoff attribute: </xsl:text>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name()"/>
                            <xsl:for-each select="@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;&#x0a;</xsl:text>
                        </xsl:for-each>

                        <!-- 10. Empty case:judges element -->

                        <xsl:for-each select=".//case:judgment//case:judges[normalize-space(.) = '']">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>case:judges should not be empty in "case:judgment"&#x0a;</xsl:text>
                        </xsl:for-each>

                        <!-- Bhuwan: Check on empty "case:judges", Get confirmation on this check, then remove comment -->
                        <xsl:for-each select=".//case:courtinfo//case:judges[normalize-space(.) = '']">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>case:judges should not be empty in "case:courtinfo"&#x0a;</xsl:text>
                        </xsl:for-each>
                        

                        <!-- 11. First level/@leveltype within <comm:body> must be comm.chap -->

                        <xsl:for-each select=".//comm:body/level[1][@leveltype != 'comm.chap']">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>&lt;level</xsl:text>
                            <xsl:for-each select="@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:text>: First level/@leveltype within comm:body must be comm.chap&#x0a;</xsl:text>
                        </xsl:for-each>

                        <!-- 12. Wrong value of date attribute @day, @month, @year -->

                        <xsl:for-each
                            select=".//date[(number(@day) = 0 and number(@month) = 0 and number(@year) = 0) or (matches(@year, '^0'))]">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>Wrong date value: </xsl:text>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:for-each select="@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:for-each>

                        <!-- 13. Invalid Elements case:courtcode|case:juris|case:judges|case:filenum|case:dates -->

                        <xsl:for-each
                            select=".//case:party/case:courtcode | .//case:party/case:juris | .//case:party/case:judges | .//case:party/case:filenum | .//case:party/case:dates">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>Invalid element </xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:text> in case:party </xsl:text>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:for-each select="@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>&lt;/</xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:for-each>

                        <!-- 14. Invalid Element ol -->

                        <xsl:for-each select=".//text/ol">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>Invalid element </xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:text> in text </xsl:text>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:for-each select="@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:value-of select="normalize-space(.)"/>
                            <xsl:text>&lt;/</xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:for-each>

                        <!-- 14. Invalid Element emph -->

                        <xsl:for-each select=".//p/emph">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>Invalid element </xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:text> in p </xsl:text>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:for-each select="@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:value-of select="normalize-space(.)"/>
                            <xsl:text>&lt;/</xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:for-each>

                        <!-- 15. rotate attribute not allowed in element entry -->

                        <xsl:for-each select=".//entry/@rotate">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>Invalid attribute </xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:text> in entry @rotate="</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>"</xsl:text>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:for-each>

                        <!-- 16. PCDATA is appearing as the direct child of the element p -->

                        <xsl:for-each select=".//p/text()[normalize-space(.) != '']">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>PCDATA is appearing as the direct child of the element p </xsl:text>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name(..)"/>
                            <xsl:for-each select="../@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:value-of select="normalize-space(.)"/>
                            <xsl:text>&lt;/</xsl:text>
                            <xsl:value-of select="name(..)"/>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:for-each>

                        <!-- 17. The attribute @iso-cc must have value-->

                        <xsl:for-each select=".//@iso-cc[normalize-space(.) = '']">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>The attribute </xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:text> must have a value @rotate="</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>"</xsl:text>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:for-each>

                        <!-- 18. The attribute @count is not valid inside ci:page -->

                        <xsl:for-each select=".//ci:page/@count">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>The attribute @count is not valid inside ci:page </xsl:text>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name(..)"/>
                            <xsl:for-each select="../@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:value-of select="normalize-space(..)"/>
                            <xsl:text>&lt;/</xsl:text>
                            <xsl:value-of select="name(..)"/>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:for-each>

                        <!-- 19. The attribute @num is required in ci:page -->

                        <xsl:for-each select=".//ci:page[not(@num)]">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>The attribute @num is required in ci:page </xsl:text>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:for-each select="@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:value-of select="normalize-space(.)"/>
                            <xsl:text>&lt;/</xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:for-each>

                        <!-- 20. footnote token was a duplicate id and has been removed -->

                        <xsl:for-each-group select="//footnote" group-by="@fntoken">
                            <xsl:if test="count(current-group()) &gt; 1">
                                <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                                <xsl:text>: </xsl:text>
                                <xsl:text>footnote token was a duplicate id </xsl:text>
                                <xsl:text>&lt;</xsl:text>
                                <xsl:value-of select="name(current-group()[1])"/>
                                <xsl:for-each select="current-group()[1]/@*">
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="name(.)"/>
                                    <xsl:text>="</xsl:text>
                                    <xsl:value-of select="."/>
                                    <xsl:text>"</xsl:text>
                                </xsl:for-each>
                                <xsl:text>&gt;</xsl:text>
                                <xsl:text>&#x0a;</xsl:text>
                            </xsl:if>
                        </xsl:for-each-group>

                        <!-- 21. The file don't starts with the root element caseml -->

                        <xsl:for-each select="./caseml">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>The file don't starts with the root element caseml </xsl:text>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:for-each>


                        <!-- 22. The element caseopt, party and sol must be declared Invalid element  -->

                        <xsl:for-each select=".//caseopt | .//party | .//sol">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                            <xsl:text>: </xsl:text>
                            <xsl:text>The element caseopt, party and sol must be declared Invalid element </xsl:text>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:for-each select="@*">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name(.)"/>
                                <xsl:text>="</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:for-each>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:value-of select="normalize-space(.)"/>
                            <xsl:text>&lt;/</xsl:text>
                            <xsl:value-of select="name(.)"/>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:for-each>

                    </xsl:for-each>

                    <!-- 23. Duplicate docinfo:bookseqnum -->

                    <xsl:if test="$mulbookseqnum/bookseqnum">
                        <xsl:for-each select="$mulbookseqnum/bookseqnum">
                            <xsl:value-of select="file_name"/>
                            <xsl:text>: Have duplicate bookseqnum </xsl:text>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:text>docinfo:bookseqnum</xsl:text>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:value-of select="docinfo:bookseqnum"/>
                            <xsl:text>&lt;/</xsl:text>
                            <xsl:text>docinfo:bookseqnum</xsl:text>
                            <xsl:text>&gt;&#x0a;</xsl:text>
                        </xsl:for-each>
                    </xsl:if>

                    <!-- 24. Duplicate docinfo:doc-id -->

                    <xsl:if test="$muldocid/docid">
                        <xsl:for-each select="$muldocid/docid">
                            <xsl:value-of select="file_name"/>
                            <xsl:text>: Have duplicate docinfo:doc-id </xsl:text>
                            <xsl:text>&lt;</xsl:text>
                            <xsl:text>docinfo:doc-id</xsl:text>
                            <xsl:text>&gt;</xsl:text>
                            <xsl:value-of select="docinfo:doc-id"/>
                            <xsl:text>&lt;/</xsl:text>
                            <xsl:text>docinfo:doc-id</xsl:text>
                            <xsl:text>&gt;&#x0a;</xsl:text>
                        </xsl:for-each>
                    </xsl:if>

                    <!-- 25. Validation on case:decisiondate/date -->

                    <xsl:if test="$dateValidation/*">
                        <xsl:for-each select="$dateValidation/*">
                            <xsl:choose>
                                <xsl:when test="name(.) = 'wrong_year_value'">
                                    <xsl:value-of select="file_name"/>
                                    <xsl:text>: </xsl:text>
                                    <xsl:text>&lt;date</xsl:text>
                                    <xsl:for-each select="date/@*">
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="name(.)"/>
                                        <xsl:text>="</xsl:text>
                                        <xsl:value-of select="."/>
                                        <xsl:text>"</xsl:text>
                                    </xsl:for-each>
                                    <xsl:text>&gt; </xsl:text>
                                    <xsl:text>@year = </xsl:text>
                                    <xsl:value-of select="date/@year"/>
                                    <xsl:text>: Year information must not be 0000&#x0a;</xsl:text>
                                </xsl:when>
                                <xsl:when test="name(.) = 'wrong_date_day_value'">
                                    <xsl:value-of select="file_name"/>
                                    <xsl:text>: </xsl:text>
                                    <xsl:text>&lt;date</xsl:text>
                                    <xsl:for-each select="date/@*">
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="name(.)"/>
                                        <xsl:text>="</xsl:text>
                                        <xsl:value-of select="."/>
                                        <xsl:text>"</xsl:text>
                                    </xsl:for-each>
                                    <xsl:text>&gt; </xsl:text>
                                    <xsl:text>@day = </xsl:text>
                                    <xsl:value-of select="date/@day"/>
                                    <xsl:text>: Wrong value of day attribute&#x0a;</xsl:text>
                                </xsl:when>
                                <xsl:when test="name(.) = 'wrong_date_day_format'">
                                    <xsl:value-of select="file_name"/>
                                    <xsl:text>: </xsl:text>
                                    <xsl:text>&lt;date</xsl:text>
                                    <xsl:for-each select="date/@*">
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="name(.)"/>
                                        <xsl:text>="</xsl:text>
                                        <xsl:value-of select="."/>
                                        <xsl:text>"</xsl:text>
                                    </xsl:for-each>
                                    <xsl:text>&gt; </xsl:text>
                                    <xsl:text>@day = </xsl:text>
                                    <xsl:value-of select="date/@day"/>
                                    <xsl:text>: is not in required format&#x0a;</xsl:text>
                                </xsl:when>
                                <xsl:when test="name(.) = 'wrong_date_month_value'">
                                    <xsl:value-of select="file_name"/>
                                    <xsl:text>: </xsl:text>
                                    <xsl:text>&lt;date</xsl:text>
                                    <xsl:for-each select="date/@*">
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="name(.)"/>
                                        <xsl:text>="</xsl:text>
                                        <xsl:value-of select="."/>
                                        <xsl:text>"</xsl:text>
                                    </xsl:for-each>
                                    <xsl:text>&gt; </xsl:text>
                                    <xsl:text>@month = </xsl:text>
                                    <xsl:value-of select="date/@month"/>
                                    <xsl:text>: Wrong value of month attribute&#x0a;</xsl:text>
                                </xsl:when>
                                <xsl:when test="name(.) = 'wrong_date_month_format'">
                                    <xsl:value-of select="file_name"/>
                                    <xsl:text>: </xsl:text>
                                    <xsl:text>&lt;date</xsl:text>
                                    <xsl:for-each select="date/@*">
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="name(.)"/>
                                        <xsl:text>="</xsl:text>
                                        <xsl:value-of select="."/>
                                        <xsl:text>"</xsl:text>
                                    </xsl:for-each>
                                    <xsl:text>&gt; </xsl:text>
                                    <xsl:text>@month = </xsl:text>
                                    <xsl:value-of select="date/@month"/>
                                    <xsl:text>: is not in required format&#x0a;</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:if>

                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>No Error</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:result-document>
    </xsl:template>

    <user:Date>
        <monthInfo max="31" umonth="1"/>
        <monthInfo max="31" umonth="3"/>
        <monthInfo max="30" umonth="4"/>
        <monthInfo max="31" umonth="5"/>
        <monthInfo max="30" umonth="6"/>
        <monthInfo max="31" umonth="7"/>
        <monthInfo max="31" umonth="8"/>
        <monthInfo max="30" umonth="9"/>
        <monthInfo max="31" umonth="10"/>
        <monthInfo max="30" umonth="11"/>
        <monthInfo max="31" umonth="12"/>
    </user:Date>

    <xsl:variable name="dateValidation">
        <xsl:for-each select="$files1//case:decisiondate/date">
            <xsl:if test="number(@year) = 0">
                <xsl:element name="wrong_year_value">
                    <xsl:element name="file_name">
                        <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                    </xsl:element>
                    <xsl:copy-of select="."/>
                </xsl:element>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="string-length(@month) &lt;= 2 and string-length(@month) &gt;= 1">
                    <xsl:choose>
                        <xsl:when test="number(@month) &gt;= 1 and number(@month) &lt;= 12">
                            <xsl:choose>
                                <xsl:when
                                    test="string-length(@day) &lt;= 2 and string-length(@day) &gt;= 1">
                                    <xsl:choose>
                                        <xsl:when test="number(@month) != 2">
                                            <xsl:choose>
                                                <xsl:when
                                                  test="number(@day) &lt;= number(document('')//user:Date/monthInfo[number(@umonth) = number(current()/@month)]/@max) and number(@day) &gt;= 1"/>
                                                <xsl:otherwise>
                                                  <xsl:element name="wrong_date_day_value">
                                                  <xsl:element name="file_name">
                                                  <xsl:value-of
                                                  select="tokenize(document-uri(/), '/')[last()]"/>
                                                  </xsl:element>
                                                  <xsl:copy-of select="."/>
                                                  </xsl:element>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <!-- Test for february -->
                                            <xsl:choose>
                                                <xsl:when test="number(@year) mod 4 = 0">
                                                  <xsl:choose>
                                                  <xsl:when test="number(@year) mod 100 = 0">
                                                  <xsl:choose>
                                                  <xsl:when test="number(@year) mod 400 = 0">
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="number(@day) &lt;= 29 and number(@day) &gt;= 1"/>
                                                  <xsl:otherwise>
                                                  <xsl:element name="wrong_date_day_value">
                                                  <xsl:element name="file_name">
                                                  <xsl:value-of
                                                  select="tokenize(document-uri(/), '/')[last()]"/>
                                                  </xsl:element>
                                                  <xsl:copy-of select="."/>
                                                  </xsl:element>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="number(@day) &lt;= 28 and number(@day) &gt;= 1"/>
                                                  <xsl:otherwise>
                                                  <xsl:element name="wrong_date_day_value">
                                                  <xsl:element name="file_name">
                                                  <xsl:value-of
                                                  select="tokenize(document-uri(/), '/')[last()]"/>
                                                  </xsl:element>
                                                  <xsl:copy-of select="."/>
                                                  </xsl:element>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="number(@day) &lt;= 29 and number(@day) &gt;= 1"/>
                                                  <xsl:otherwise>
                                                  <xsl:element name="wrong_date_day_value">
                                                  <xsl:element name="file_name">
                                                  <xsl:value-of
                                                  select="tokenize(document-uri(/), '/')[last()]"/>
                                                  </xsl:element>
                                                  <xsl:copy-of select="."/>
                                                  </xsl:element>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="number(@day) &lt;= 28 and number(@day) &gt;= 1"/>
                                                  <xsl:otherwise>
                                                  <xsl:element name="wrong_date_day_value">
                                                  <xsl:element name="file_name">
                                                  <xsl:value-of
                                                  select="tokenize(document-uri(/), '/')[last()]"/>
                                                  </xsl:element>
                                                  <xsl:copy-of select="."/>
                                                  </xsl:element>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:element name="wrong_date_day_format">
                                        <xsl:element name="file_name">
                                            <xsl:value-of
                                                select="tokenize(document-uri(/), '/')[last()]"/>
                                        </xsl:element>
                                        <xsl:copy-of select="."/>
                                    </xsl:element>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="wrong_date_month_value">
                                <xsl:element name="file_name">
                                    <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                                </xsl:element>
                                <xsl:copy-of select="."/>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="wrong_date_month_format">
                        <xsl:element name="file_name">
                            <xsl:value-of select="tokenize(document-uri(/), '/')[last()]"/>
                        </xsl:element>
                        <xsl:copy-of select="."/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:variable>
	<!--For my comment-->
	<xsl:template match="docinfo:doc-id"/>
		<!--For my comment book seq no-->
	<xsl:template match="docinfo:book-seq"/>
</xsl:stylesheet>
