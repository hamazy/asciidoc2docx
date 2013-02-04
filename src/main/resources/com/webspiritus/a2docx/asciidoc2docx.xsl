<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
		xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types"
		xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
		xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
		xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
		xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
		xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
		xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml"></xsl:output>
  <xsl:param name="what-to-gen"></xsl:param>
  <xsl:param name="target-base"></xsl:param>
  <xsl:param name="endline" select="'&#x0A;'"></xsl:param>
  <!-- 1 pixel = 9525 EMU (English Metrics Unit) -->
  <xsl:variable name="emu" select="9525"></xsl:variable>
  <xsl:variable name="cr" select="'&#x0D;'"></xsl:variable>
  <xsl:variable name="lf" select="'&#x0A;'"></xsl:variable>
  <xsl:variable name="crlf" select="concat($cr, $lf)"></xsl:variable>
  <xsl:variable name="a4-width" select="11907"></xsl:variable>
  <xsl:variable name="a4-height" select="16839"></xsl:variable>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$what-to-gen = 'content-types'">
    	<xsl:call-template name="content-types"></xsl:call-template>
      </xsl:when>
      <xsl:when test="$what-to-gen = 'root-rels'">
      	<xsl:call-template name="root-rels"></xsl:call-template>
      </xsl:when>
      <xsl:when test="$what-to-gen = 'document-rels'">
      	<xsl:call-template name="document-rels"></xsl:call-template>
      </xsl:when>
      <xsl:when test="$what-to-gen = 'styles'">
      	<xsl:call-template name="styles"></xsl:call-template>
      </xsl:when>
      <xsl:when test="$what-to-gen = 'numbering'">
      	<xsl:call-template name="numbering"></xsl:call-template>
      </xsl:when>
      <xsl:when test="$what-to-gen = 'header1'">
	<xsl:call-template name="header1"></xsl:call-template>
      </xsl:when>
      <xsl:when test="$what-to-gen = 'footer1'">
	<xsl:call-template name="footer1"></xsl:call-template>
      </xsl:when>
      <xsl:when test="$what-to-gen = 'list-images'">
	<xsl:call-template name="list-images"></xsl:call-template>
      </xsl:when>
      <xsl:when test="$what-to-gen = 'document'">
      	<xsl:call-template name="document"></xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
    	<xsl:message terminate="yes">
    	  <xsl:text>Unknown param value: </xsl:text><xsl:value-of select="$what-to-gen"></xsl:value-of>
    	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template name="content-types">
    <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
      <Default Extension="xml"
	       ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml" />
      <Default Extension="rels"
	       ContentType="application/vnd.openxmlformats-package.relationships+xml" />
      <Default Extension="jpg"
	       ContentType="image/jpeg" />
      <Default Extension="png"
	       ContentType="image/png" />
      <Override PartName="/word/styles.xml"
		ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml" />
      <Override PartName="/word/numbering.xml"
		ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml" />
      <Override PartName="/word/footer1.xml"
		ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"></Override>
      <Override PartName="/word/header1.xml"
		ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml"></Override>
    </Types>
  </xsl:template>

  <xsl:template name="root-rels">
    <xsl:element name="rel:Relationships">
      <xsl:element name="rel:Relationship">
	<xsl:attribute name="Type">http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument</xsl:attribute>
	<xsl:attribute name="Target">/word/document.xml</xsl:attribute>
	<xsl:attribute name="Id"><xsl:value-of select="generate-id(document(concat($target-base, '/word/document.xml')))"></xsl:value-of></xsl:attribute>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="document-rels">
    <xsl:element name="rel:Relationships">
      <xsl:element name="rel:Relationship">
	<xsl:attribute name="Type">http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles</xsl:attribute>
	<xsl:attribute name="Target">/word/styles.xml</xsl:attribute>
	<xsl:attribute name="Id"><xsl:value-of select="generate-id(document(concat($target-base, '/word/styles.xml')))"></xsl:value-of></xsl:attribute>
      </xsl:element>
      <xsl:for-each select="//imagedata[@fileref]">
	<xsl:variable name="filename"><xsl:value-of select="@fileref"></xsl:value-of></xsl:variable>
	<xsl:element name="rel:Relationship">
	  <xsl:attribute name="Type">http://schemas.openxmlformats.org/officeDocument/2006/relationships/image</xsl:attribute>
	  <xsl:attribute name="Target"><xsl:value-of select="concat('/media/', $filename)"></xsl:value-of></xsl:attribute>
	  <xsl:attribute name="Id"><xsl:value-of select="generate-id(.)"></xsl:value-of></xsl:attribute>
	</xsl:element>
      </xsl:for-each>
      <xsl:call-template name="icon-rel">
	<xsl:with-param name="type">caution</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="icon-rel">
	<xsl:with-param name="type">important</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="icon-rel">
	<xsl:with-param name="type">note</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="icon-rel">
	<xsl:with-param name="type">tip</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="icon-rel">
	<xsl:with-param name="type">warning</xsl:with-param>
      </xsl:call-template>
      <xsl:element name="rel:Relationship">
	<xsl:attribute name="Type">http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering</xsl:attribute>
	<xsl:attribute name="Target">/word/numbering.xml</xsl:attribute>
	<xsl:attribute name="Id"><xsl:value-of select="generate-id(document(concat($target-base, '/word/numbering.xml')))"></xsl:value-of></xsl:attribute>
      </xsl:element>
      <xsl:element name="rel:Relationship">
	<xsl:attribute name="Type">http://schemas.openxmlformats.org/officeDocument/2006/relationships/header</xsl:attribute>
	<xsl:attribute name="Target">/word/header1.xml</xsl:attribute>
	<xsl:attribute name="Id"><xsl:value-of select="generate-id(document(concat($target-base, '/word/header1.xml')))"></xsl:value-of></xsl:attribute>
      </xsl:element>
      <xsl:element name="rel:Relationship">
	<xsl:attribute name="Type">http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer</xsl:attribute>
	<xsl:attribute name="Target">/word/footer1.xml</xsl:attribute>
	<xsl:attribute name="Id"><xsl:value-of select="generate-id(document(concat($target-base, '/word/footer1.xml')))"></xsl:value-of></xsl:attribute>
      </xsl:element>
      <xsl:for-each select="//ulink[@url]">
	<xsl:element name="rel:Relationship">
	  <xsl:attribute name="Type">http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink</xsl:attribute>
	  <xsl:attribute name="Target"><xsl:value-of select="@url"></xsl:value-of></xsl:attribute>
	  <xsl:attribute name="TargetMode">External</xsl:attribute>
	  <xsl:attribute name="Id"><xsl:value-of select="generate-id(.)"></xsl:value-of></xsl:attribute>
	</xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template name="icon-rel">
    <xsl:param name="type"></xsl:param>
    <xsl:element name="rel:Relationship">
      <xsl:attribute name="Type">http://schemas.openxmlformats.org/officeDocument/2006/relationships/image</xsl:attribute>
      <xsl:attribute name="Target"><xsl:value-of select="concat('/media/', $type, '.png')"></xsl:value-of></xsl:attribute>
      <xsl:attribute name="Id"><xsl:value-of select="concat('icon-', $type)"></xsl:value-of></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template name="styles">
    <w:styles>
      <w:docDefaults>
	<w:rPrDefault>
	  <w:rPr>
	    <w:rFonts w:asciiTheme="minorHAnsi" w:eastAsiaTheme="minorEastAsia" w:hAnsiTheme="minorHAnsi" w:cstheme="minorBidi"/>
	    <w:kern w:val="2"/>
	    <w:sz w:val="20"/>
	    <w:szCs w:val="20"/>
	    <w:lang w:val="en-US" w:eastAsia="ja-JP" w:bidi="ar-SA"/>
	  </w:rPr>
	</w:rPrDefault>
	<w:pPrDefault/>
      </w:docDefaults>
      <w:style w:type="paragraph" w:styleId="title" w:customStyle="true">
	<w:name w:val="title" />
	<w:basedOn w:val="Normal" />
	<w:next w:val="Normal" />
	<w:pPr>
	  <w:spacing w:before="100" w:beforeAutospacing="1" w:after="100" w:afterAutospacing="1"/>
	</w:pPr>
	<w:rPr>
	  <w:rFonts w:ascii="Arial" w:eastAsia="ＭＳ Ｐゴシック" />
	  <w:b w:val="true" />
	  <w:sz w:val="48" />
	  <w:szCs w:val="48" />
	</w:rPr>
      </w:style>
      <w:style w:type="paragraph" w:styleId="author" w:customStyle="true">
	<w:name w:val="author" />
	<w:basedOn w:val="Normal" />
	<w:next w:val="Normal" />
	<w:pPr>
	  <w:spacing w:before="100" w:beforeAutospacing="1" w:after="100" w:afterAutospacing="1"/>
	  <w:jc w:val="right" />
	</w:pPr>
	<w:rPr>
	  <w:rFonts w:ascii="Arial" w:eastAsia="ＭＳ Ｐゴシック" />
	  <w:b w:val="true" />
	  <w:sz w:val="36" />
	  <w:szCs w:val="36" />
	</w:rPr>
      </w:style>
      <w:style w:type="paragraph" w:styleId="heading1" w:customStyle="true">
	<w:name w:val="heading1" />
	<w:basedOn w:val="Normal" />
	<w:next w:val="Normal" />
	<w:pPr>
	  <w:spacing w:before="100" w:beforeAutospacing="1" w:after="100" w:afterAutospacing="1"/>
	  <w:outlineLvl w:val="0"/>
	</w:pPr>
	<w:rPr>
	  <w:rFonts w:ascii="Arial" w:eastAsia="ＭＳ Ｐゴシック" />
	  <w:b w:val="true" />
	  <w:sz w:val="48" />
	  <w:szCs w:val="48" />
	</w:rPr>
      </w:style>
      <w:style w:type="paragraph" w:styleId="heading2" w:customStyle="true">
	<w:name w:val="heading2" />
	<w:basedOn w:val="Normal" />
	<w:next w:val="Normal" />
	<w:pPr>
	  <w:spacing w:before="100" w:beforeAutospacing="1" w:after="100" w:afterAutospacing="1"/>
	  <w:outlineLvl w:val="1"/>
	</w:pPr>
	<w:rPr>
	  <w:rFonts w:ascii="Arial" w:eastAsia="ＭＳ Ｐゴシック" />
	  <w:b w:val="true" />
	  <w:sz w:val="36" />
	  <w:szCs w:val="36" />
	</w:rPr>
      </w:style>
      <w:style w:type="paragraph" w:styleId="heading3" w:customStyle="true">
	<w:name w:val="heading3" />
	<w:basedOn w:val="Normal" />
	<w:next w:val="Normal" />
	<w:pPr>
	  <w:spacing w:before="100" w:beforeAutospacing="1" w:after="100" w:afterAutospacing="1"/>
	  <w:outlineLvl w:val="2"/>
	</w:pPr>
	<w:rPr>
	  <w:rFonts w:ascii="Arial" w:eastAsia="ＭＳ Ｐゴシック" />
	  <w:b w:val="true" />
	  <w:sz w:val="27" />
	  <w:szCs w:val="27" />
	</w:rPr>
      </w:style>
      <w:style w:type="paragraph" w:styleId="heading4" w:customStyle="true">
	<w:name w:val="heading4" />
	<w:basedOn w:val="Normal" />
	<w:next w:val="Normal" />
	<w:pPr>
	  <w:spacing w:before="100" w:beforeAutospacing="1" w:after="100" w:afterAutospacing="1"/>
	  <w:outlineLvl w:val="3"/>
	</w:pPr>
	<w:rPr>
	  <w:rFonts w:ascii="Arial" w:eastAsia="ＭＳ Ｐゴシック" />
	  <w:b w:val="true" />
	  <w:sz w:val="24" />
	  <w:szCs w:val="24" />
	</w:rPr>
      </w:style>
      <w:style w:type="paragraph" w:styleId="screen" w:customStyle="true">
	<w:name w:val="screen"></w:name>
	<w:basedOn w:val="Normal"></w:basedOn>
	<w:next w:val="Normal"></w:next>
	<w:pPr>
	  <w:spacing w:before="100" w:beforeAutospacing="1" w:after="100" w:afterAutospacing="1"/>
	</w:pPr>
	<w:rPr>
	  <w:rFonts w:ascii="Courier" w:eastAsia="Courier" />
	</w:rPr>
      </w:style>
    </w:styles>
  </xsl:template>

  <xsl:template name="numbering">
    <w:numbering>
      <w:abstractNum w:abstractNumId="0">
	<w:multiLevelType w:val="hybridMultilevel" />
	<w:lvl w:ilvl="0">
	  <w:numFmt w:val="bullet" />
	  <w:lvlText w:val="&#x2022;" />
	  <w:lvlJc w:val="left" />
	  <w:pPr>
	    <w:ind w:left="420" w:hanging="420" />
	  </w:pPr>
	  <w:rPr>
	    <w:rFonts w:hint="default" w:ascii="Arial Unicode MS" w:hAnsi="Arial Unicode MS" />
	  </w:rPr>
	</w:lvl>
	<w:lvl w:ilvl="1">
	  <w:numFmt w:val="bullet" />
	  <w:lvlText w:val="&#x2023;" />
	  <w:lvlJc w:val="left" />
	  <w:pPr>
	    <w:ind w:left="840" w:hanging="420" />
	  </w:pPr>
	  <w:rPr>
	    <w:rFonts w:hint="default" w:ascii="Arial Unicode MS" w:hAnsi="Arial Unicode MS" />
	  </w:rPr>
	</w:lvl>
	<w:lvl w:ilvl="2">
	  <w:numFmt w:val="bullet" />
	  <w:lvlText w:val="&#x2043;" />
	  <w:lvlJc w:val="left" />
	  <w:pPr>
	    <w:ind w:left="1280" w:hanging="420" />
	  </w:pPr>
	  <w:rPr>
	    <w:rFonts w:hint="default" w:ascii="Arial Unicode MS" w:hAnsi="Arial Unicode MS" />
	  </w:rPr>
	</w:lvl>
      </w:abstractNum>
      <w:abstractNum w:abstractNumId="1">
	<w:multiLevelType w:val="hybridMultilevel" />
	<w:lvl w:ilvl="0">
	  <w:start w:val="1"/>
	  <w:numFmt w:val="decimal" />
	  <w:lvlText w:val="%1." />
	  <w:lvlJc w:val="left" />
	  <w:pPr>
	    <w:ind w:left="420" w:hanging="420" />
	  </w:pPr>
	  <w:rPr>
	    <w:rFonts w:hint="default" w:ascii="Arial Unicode MS" w:hAnsi="Arial Unicode MS" />
	  </w:rPr>
	</w:lvl>
	<w:lvl w:ilvl="1">
	  <w:start w:val="1"/>
	  <w:numFmt w:val="lowerLetter" />
	  <w:lvlText w:val="%2." />
	  <w:lvlJc w:val="left" />
	  <w:pPr>
	    <w:ind w:left="840" w:hanging="420" />
	  </w:pPr>
	  <w:rPr>
	    <w:rFonts w:hint="default" w:ascii="Arial Unicode MS" w:hAnsi="Arial Unicode MS" />
	  </w:rPr>
	</w:lvl>
	<w:lvl w:ilvl="2">
	  <w:start w:val="1"/>
	  <w:numFmt w:val="lowerRoman" />
	  <w:lvlText w:val="%3." />
	  <w:lvlJc w:val="left" />
	  <w:pPr>
	    <w:ind w:left="1280" w:hanging="420" />
	  </w:pPr>
	  <w:rPr>
	    <w:rFonts w:hint="default" w:ascii="Arial Unicode MS" w:hAnsi="Arial Unicode MS" />
	  </w:rPr>
	</w:lvl>
      </w:abstractNum>
      <w:num w:numId="1">
	<w:abstractNumId w:val="0" />
      </w:num>
      <w:num w:numId="2">
	<w:abstractNumId w:val="1" />
      </w:num>
    </w:numbering>
  </xsl:template>

  <xsl:template name="header1">
    <w:hdr>
      <w:p>
	<w:pPr>
	  <w:jc w:val="right" />
	</w:pPr>
	<w:r>
	  <w:t><xsl:value-of select="/article/articleinfo/title/text()"></xsl:value-of></w:t>
	</w:r>
      </w:p>
    </w:hdr>
  </xsl:template>

  <xsl:template name="footer1">
    <w:ftr>
      <w:p>
	<w:pPr>
	  <w:jc w:val="right" />
	</w:pPr>
	<w:r>
	  <w:fldChar w:fldCharType="begin"/>
	</w:r>
	<w:r>
	  <w:instrText xml:space="preserve">PAGE  </w:instrText>
	</w:r>
	<w:r>
	  <w:fldChar w:fldCharType="end"/>
	</w:r>
      </w:p>
    </w:ftr>
  </xsl:template>

  <xsl:template name="list-images">
    <xsl:element name="images">
      <xsl:for-each select="//imagedata[@fileref]">
	<xsl:element name="image">
	  <xsl:value-of select="@fileref"></xsl:value-of>
	</xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template name="document">
    <xsl:apply-templates></xsl:apply-templates>
  </xsl:template>

  <xsl:template match="article">
    <w:document>
      <w:body>
	<xsl:apply-templates select="*"></xsl:apply-templates>
    	<w:sectPr>
	  <w:headerReference w:type="default">
	    <xsl:attribute name="r:id">
	      <xsl:value-of select="document(concat($target-base, '/word/_rels/document.xml.rels'))/rel:Relationships/rel:Relationship[@Target='/word/header1.xml']/@Id"></xsl:value-of>
	    </xsl:attribute>
	  </w:headerReference>
	  <w:footerReference w:type="default">
	    <xsl:attribute name="r:id">
	      <xsl:value-of select="document(concat($target-base, '/word/_rels/document.xml.rels'))/rel:Relationships/rel:Relationship[@Target='/word/footer1.xml']/@Id"></xsl:value-of>
	    </xsl:attribute>
	  </w:footerReference>
    	  <w:pgSz>
	    <xsl:attribute name="w:w"><xsl:value-of select="$a4-width"></xsl:value-of></xsl:attribute>
	    <xsl:attribute name="w:h"><xsl:value-of select="$a4-height"></xsl:value-of></xsl:attribute>
	  </w:pgSz>
    	</w:sectPr>
      </w:body>
    </w:document>
  </xsl:template>

  <xsl:template match="articleinfo">
    <w:p>
      <w:pPr>
	<w:pStyle w:val="title" />
      </w:pPr>
      <w:r><w:t><xsl:value-of select="title/text()"></xsl:value-of></w:t></w:r>
    </w:p>
    <w:p>
      <w:pPr>
	<w:pStyle w:val="author" />
	<w:spacing w:beforeAutospacing="1" w:afterAutospacing="1"/>
      </w:pPr>
      <w:r><w:t><xsl:for-each select="author//text()">
	<xsl:value-of select="."></xsl:value-of><xsl:text> </xsl:text>
      </xsl:for-each></w:t></w:r>
    </w:p>
    <w:tbl>
      <w:tblPr>
	<w:tblW w:w="5000" w:type="pct"/>
	<w:tblBorders><w:top w:val="single" w:sz="12" />
	<w:left w:val="single" w:sz="12" />
	<w:bottom w:val="single" w:sz="12" />
	<w:right w:val="single" w:sz="12" />
	<w:insideH w:val="single" w:sz="8" />
	<w:insideV w:val="single" w:sz="8" /></w:tblBorders>
	<w:tblLayout w:type="autofit"></w:tblLayout>
      </w:tblPr>
      <w:tblGrid />
      <w:tr>
	<w:tc>
	  <w:tcPr>
	    <w:gridSpan w:val="3" />
	    <w:shd w:val="clear" w:color="auto" w:fill="F0F0F0" />
	  </w:tcPr>
	  <w:p><w:r><w:rPr><w:b w:val="true" /></w:rPr>
	  <w:t>改訂履歴</w:t></w:r></w:p>
	</w:tc>
      </w:tr>
      <xsl:for-each select="revhistory/revision">
	<w:tr><w:tc><w:p><w:r><w:t>改訂 <xsl:value-of select="revnumber/text()"></xsl:value-of></w:t></w:r></w:p></w:tc>
	<w:tc><w:p><w:r><w:t><xsl:value-of select="date/text()"></xsl:value-of></w:t></w:r></w:p></w:tc>
	<w:tc><w:p><w:r><w:t><xsl:value-of select="authorinitials"></xsl:value-of></w:t></w:r></w:p></w:tc>
	</w:tr>
	<w:tr><w:tc>
	  <w:tcPr><w:gridSpan w:val="3" /></w:tcPr>
	  <xsl:apply-templates select="revdescription/*"></xsl:apply-templates>
	</w:tc></w:tr>
      </xsl:for-each>
    </w:tbl>
    <w:p>
      <w:pPr>
    	<w:sectPr>
    	  <w:pgSz>
	    <xsl:attribute name="w:w"><xsl:value-of select="$a4-width"></xsl:value-of></xsl:attribute>
	    <xsl:attribute name="w:h"><xsl:value-of select="$a4-height"></xsl:value-of></xsl:attribute>
	  </w:pgSz>
    	</w:sectPr>
      </w:pPr>
    </w:p>
  </xsl:template>

  <xsl:template match="simpara">
    <xsl:param name="level"></xsl:param>
    <xsl:param name="list-type"></xsl:param>
    <xsl:choose>
      <xsl:when test="$level = '' and  $list-type != 'definition'">
	<w:p>
	  <xsl:apply-templates select="node()"></xsl:apply-templates>
	</w:p>
      </xsl:when>
      <xsl:when test="$list-type = 'definition'">
	<xsl:apply-templates mode="definition" select="."></xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$list-type='ordered'">
	<xsl:apply-templates mode="number" select=".">
	  <xsl:with-param name="level" select="$level"></xsl:with-param>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates mode="bullet" select=".">
	  <xsl:with-param name="level" select="$level"></xsl:with-param>
	</xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="section">
    <xsl:param name="section-id"></xsl:param>
    <xsl:apply-templates select="*">
      <xsl:with-param name="section-id" select="concat($section-id, '.', count(preceding-sibling::section) + 1)"></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="/article/section">
    <xsl:variable name="section-id" select="count(preceding-sibling::section) + 1"></xsl:variable>
    <xsl:apply-templates select="*">
      <xsl:with-param name="section-id" select="$section-id"></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="/article/section/title | /article/appendix/title">
    <xsl:param name="section-id"></xsl:param>
    <w:p>
      <w:pPr>
	<w:pStyle w:val="heading1" />
      </w:pPr>
      <!-- <w:bookmarkStart> -->
      <!-- 	<xsl:attribute name="w:id"><xsl:value-of select="generate-id(.)"></xsl:value-of></xsl:attribute> -->
      <!-- 	<xsl:attribute name="w:name"><xsl:value-of select="generate-id(.)"></xsl:value-of></xsl:attribute> -->
      <!-- </w:bookmarkStart> -->
      <w:r>
	<w:t><xsl:value-of select="concat($section-id, ' ', text())"></xsl:value-of></w:t>
      </w:r>
      <!-- <w:bookmarkEnd> -->
      <!-- 	<xsl:attribute name="w:id"><xsl:value-of select="generate-id(.)"></xsl:value-of></xsl:attribute> -->
      <!-- </w:bookmarkEnd> -->
    </w:p>
  </xsl:template>

  <xsl:template match="/article/section/section/title | /article/appendix/section/title">
    <xsl:param name="section-id"></xsl:param>
    <w:p>
      <w:pPr>
	<w:pStyle w:val="heading2" />
      </w:pPr>
      <w:r>
	<w:t><xsl:value-of select="concat($section-id, ' ', text())"></xsl:value-of></w:t>
      </w:r>
    </w:p>
  </xsl:template>

  <xsl:template match="/article/section/section/section/title | /article/appendix/section/section/title">
    <xsl:param name="section-id"></xsl:param>
    <w:p>
      <w:pPr>
	<w:pStyle w:val="heading3" />
      </w:pPr>
      <w:r>
	<w:t><xsl:value-of select="concat($section-id, ' ', text())"></xsl:value-of></w:t>
      </w:r>
    </w:p>
  </xsl:template>

  <xsl:template match="/article/section/section/section/section/title | /article/appendix/section/section/section/title">
    <xsl:param name="section-id"></xsl:param>
    <w:p>
      <w:pPr>
	<w:pStyle w:val="heading4" />
      </w:pPr>
      <w:r>
	<w:t><xsl:value-of select="concat($section-id, ' ', text())"></xsl:value-of></w:t>
      </w:r>
    </w:p>
  </xsl:template>

  <xsl:template match="/article/appendix">
    <xsl:variable name="section-id">
      <xsl:number value="count(preceding-sibling::appendix) + 1"
		  format="A"></xsl:number>
    </xsl:variable>
    <xsl:apply-templates select="*">
      <xsl:with-param name="section-id" select="$section-id"></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="itemizedlist">
    <xsl:param name="level"></xsl:param>
    <xsl:choose>
      <xsl:when test="$level=''">
	<xsl:apply-templates select="listitem">
	  <xsl:with-param name="level" select="0"></xsl:with-param>
	  <xsl:with-param name="list-type" select="'unordered'"></xsl:with-param>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="listitem">
	  <xsl:with-param name="level" select="$level + 1"></xsl:with-param>
	  <xsl:with-param name="list-type" select="'unordered'"></xsl:with-param>
	</xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="listitem">
    <xsl:param name="level"></xsl:param>
    <xsl:param name="list-type"></xsl:param>
    <xsl:apply-templates select="*">
      <xsl:with-param name="level" select="$level"></xsl:with-param>
      <xsl:with-param name="list-type" select="$list-type"></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="simpara" mode="bullet">
    <xsl:param name="level"></xsl:param>
    <xsl:element name="w:p">
      <xsl:element name="w:pPr">
	<xsl:element name="w:numPr">
	  <xsl:element name="w:ilvl">
	    <xsl:attribute name="w:val">
	      <xsl:value-of select="$level"></xsl:value-of>
	    </xsl:attribute>
	  </xsl:element>
	  <xsl:element name="w:numId">
	    <xsl:attribute name="w:val">
	      <xsl:value-of select="1"></xsl:value-of>
	    </xsl:attribute>
	  </xsl:element>
	</xsl:element>
      </xsl:element>
      <xsl:apply-templates select="node()"></xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="orderedlist">
    <xsl:param name="level"></xsl:param>
    <xsl:choose>
      <xsl:when test="$level=''">
    	<xsl:apply-templates select="listitem">
    	  <xsl:with-param name="level" select="0"></xsl:with-param>
    	  <xsl:with-param name="list-type" select="'ordered'"></xsl:with-param>
    	</xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
    	<xsl:apply-templates select="listitem">
    	  <xsl:with-param name="level" select="$level + 1"></xsl:with-param>
    	  <xsl:with-param name="list-type" select="'ordered'"></xsl:with-param>
    	</xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="simpara" mode="number">
    <xsl:param name="level"></xsl:param>
    <xsl:element name="w:p">
      <xsl:element name="w:pPr">
	<xsl:element name="w:numPr">
	  <xsl:element name="w:ilvl">
	    <xsl:attribute name="w:val">
	      <xsl:value-of select="$level"></xsl:value-of>
	    </xsl:attribute>
	  </xsl:element>
	  <xsl:element name="w:numId">
	    <xsl:attribute name="w:val">
	      <xsl:value-of select="2"></xsl:value-of>
	    </xsl:attribute>
	  </xsl:element>
	</xsl:element>
      </xsl:element>
      <xsl:apply-templates select="node()"></xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="variablelist">
    <xsl:apply-templates select="*"></xsl:apply-templates>
  </xsl:template>

  <xsl:template match="varlistentry">
    <xsl:apply-templates select="*">
      <xsl:with-param name="list-type" select="'definition'"></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="term">
    <xsl:element name="w:p">
      <xsl:apply-templates select="node()">
	<xsl:with-param name="bold" select="1"></xsl:with-param>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="simpara" mode="definition">
    <xsl:element name="w:p">
      <w:pPr>
	<w:ind w:left="420" />
      </w:pPr>
      <xsl:apply-templates select="node()"></xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="informaltable | table">
    <xsl:apply-templates select="title"></xsl:apply-templates>
    <w:tbl>
      <w:tblPr>
	<w:tblW w:w="5000" w:type="pct"/>
	<w:tblBorders><w:top w:val="single" w:sz="12" />
	<w:left w:val="single" w:sz="12" />
	<w:bottom w:val="single" w:sz="12" />
	<w:right w:val="single" w:sz="12" />
	<w:insideH w:val="single" w:sz="8" />
	<w:insideV w:val="single" w:sz="8" /></w:tblBorders>
	<w:tblLayout w:type="autofit"></w:tblLayout>
      </w:tblPr>
      <w:tblGrid />
      <xsl:apply-templates select="tgroup/thead"></xsl:apply-templates>
      <xsl:apply-templates select="tgroup/tbody"></xsl:apply-templates>
    </w:tbl>
  </xsl:template>

  <xsl:template match="thead">
    <xsl:apply-templates select="*">
      <xsl:with-param name="header" select="1"></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="tbody">
    <xsl:apply-templates select="*"></xsl:apply-templates>
  </xsl:template>

  <xsl:template match="row">
    <xsl:param name="header"></xsl:param>
    <w:tr>
      <xsl:apply-templates select="*">
	<xsl:with-param name="header" select="$header"></xsl:with-param>
      </xsl:apply-templates>
    </w:tr>
  </xsl:template>

  <xsl:template match="entry">
    <xsl:param name="header"></xsl:param>
    <xsl:variable name="horizontal_span" select="@namest != '' and @nameend !=''"></xsl:variable>
    <xsl:variable name="vertical_span" select="@morerows &gt;= 1"></xsl:variable>
    <w:tc>
      <xsl:choose>
	<!-- <xsl:when test="$header or $horizontal_span or $vertical_span"> -->
	<xsl:when test="$header or $horizontal_span">
	  <w:tcPr>
	    <xsl:if test="$horizontal_span">
	      <xsl:element name="w:gridSpan">
		<xsl:attribute name="w:val">
		  <xsl:variable name="start">
		    <xsl:for-each select="../../../colspec[@colname = current()/@namest]">
		      <xsl:number></xsl:number>
		    </xsl:for-each>
		  </xsl:variable>
		  <xsl:variable name="end">
		    <xsl:for-each select="../../../colspec[@colname = current()/@nameend]">
		      <xsl:number></xsl:number>
		    </xsl:for-each>
		  </xsl:variable>
		  <xsl:value-of select="$end - $start + 1"></xsl:value-of>
		</xsl:attribute>
	      </xsl:element>
	    </xsl:if>
	    <!-- <xsl:if test="$vertical_span"> -->
	    <!--   <w:vMerge w:val="restart" /> -->
	    <!-- </xsl:if> -->
	    <xsl:if test="$header">
	      <w:shd w:val="clear" w:color="auto" w:fill="F0F0F0" />
	    </xsl:if>
	  </w:tcPr>
	  <w:p>
	    <xsl:apply-templates select="node()">
	      <xsl:with-param name="bold" select="1"></xsl:with-param>
	    </xsl:apply-templates>
	  </w:p>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates select="*"></xsl:apply-templates>
	</xsl:otherwise>
      </xsl:choose>
    </w:tc>
  </xsl:template>

  <xsl:template match="informalfigure">
    <xsl:variable name="file-name"
		  select="mediaobject/imageobject/imagedata/@fileref"></xsl:variable>
    <xsl:variable name="width"
		  select="mediaobject/imageobject/imagedata/@contentwidth"></xsl:variable>
    <xsl:variable name="height"
		  select="mediaobject/imageobject/imagedata/@contentdepth"></xsl:variable>
    <xsl:if test="$width &lt;= 0 or $height &lt;= 0">
      <xsl:message terminate="yes">
	<xsl:text>width or height for </xsl:text>
	<xsl:value-of select="$file-name"></xsl:value-of>
	<xsl:text> is invalid.</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="description"
		  select="mediaobject/textobject/phrase/node()"></xsl:variable>
    <xsl:variable name="relationship-target"
		  select="concat('/media/', $file-name)"></xsl:variable>
    <xsl:variable name="relationship-id"
		  select="document(concat($target-base, '/word/_rels/document.xml.rels'))/rel:Relationships/rel:Relationship[@Target=$relationship-target]/@Id"></xsl:variable>
    <w:p><w:r>
      <xsl:call-template name="figure">
	<xsl:with-param name="width" select="$width"></xsl:with-param>
	<xsl:with-param name="height" select="$height"></xsl:with-param>
	<xsl:with-param name="description" select="$description"></xsl:with-param>
	<xsl:with-param name="file-name" select="$file-name"></xsl:with-param>
	<xsl:with-param name="relationship-id" select="$relationship-id"></xsl:with-param>
      </xsl:call-template>
    </w:r></w:p>
  </xsl:template>

  <xsl:template name="figure">
    <xsl:param name="width"></xsl:param>
    <xsl:param name="height"></xsl:param>
    <xsl:param name="description"></xsl:param>
    <xsl:param name="file-name"></xsl:param>
    <xsl:param name="relationship-id"></xsl:param>
    <xsl:variable name="width-in-emu" select="$width * $emu"></xsl:variable>
    <xsl:variable name="height-in-emu" select="$height * $emu"></xsl:variable>
    <w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0">
      <wp:extent>
	<xsl:attribute name="cx"><xsl:value-of select="$width-in-emu"></xsl:value-of></xsl:attribute>
	<xsl:attribute name="cy"><xsl:value-of select="$height-in-emu"></xsl:value-of></xsl:attribute>
      </wp:extent>
      <wp:effectExtent l="0" t="0" r="0" b="0" />
      <wp:docPr>
	<xsl:attribute name="id">
	  <xsl:value-of select="count(preceding::informalfigure)"></xsl:value-of>
	</xsl:attribute>
	<xsl:attribute name="name">
	  <xsl:value-of select="$description"></xsl:value-of>
	</xsl:attribute>
      </wp:docPr>
      <wp:cNvGraphicFramePr>
	<a:graphicFrameLocks noChangeAspect="1" />
      </wp:cNvGraphicFramePr>
      <a:graphic>
	<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
	  <pic:pic>
	    <pic:nvPicPr>
	      <pic:cNvPr>
		<xsl:attribute name="name"><xsl:value-of select="$file-name"></xsl:value-of></xsl:attribute>
		<xsl:attribute name="id">
		  <xsl:value-of select="count(preceding::informalfigure)"></xsl:value-of>
		</xsl:attribute>
	      </pic:cNvPr>
	      <pic:cNvPicPr />
	    </pic:nvPicPr>
	    <pic:blipFill>
	      <a:blip cstate="print">
		<xsl:attribute name="r:embed">
		  <xsl:value-of select="$relationship-id"></xsl:value-of>
		</xsl:attribute>
		<a:extLst>
		  <a:ext>
		    <xsl:attribute name="uri">{28A0092B-C50C-407E-A947-70E740481C1C}</xsl:attribute>
		  </a:ext>
		</a:extLst>
	      </a:blip>
	      <a:stretch>
		<a:fillRect />
	      </a:stretch>
	    </pic:blipFill>
	    <pic:spPr>
	      <a:xfrm>
		<a:off x="0" y="0" />
		<a:ext>
		  <xsl:attribute name="cx"><xsl:value-of select="$width-in-emu"></xsl:value-of></xsl:attribute>
		  <xsl:attribute name="cy"><xsl:value-of select="$height-in-emu"></xsl:value-of></xsl:attribute>
		</a:ext>
	      </a:xfrm>
	      <a:prstGeom prst="rect">
		<a:avLst />
	      </a:prstGeom>
	    </pic:spPr>
	  </pic:pic>
	</a:graphicData>
      </a:graphic>
    </wp:inline></w:drawing>
  </xsl:template>

  <xsl:template name="icon-figure">
    <xsl:param name="width"></xsl:param>
    <xsl:param name="height"></xsl:param>
    <xsl:param name="description"></xsl:param>
    <xsl:param name="file-name"></xsl:param>
    <xsl:param name="relationship-id"></xsl:param>
    <xsl:variable name="width-in-emu" select="$width * $emu"></xsl:variable>
    <xsl:variable name="height-in-emu" select="$height * $emu"></xsl:variable>
    <w:drawing>
      <xsl:element name="wp:anchor">
	<xsl:attribute name="distT">0</xsl:attribute>
	<xsl:attribute name="distB">0</xsl:attribute>
	<xsl:attribute name="distL">114300</xsl:attribute>
	<xsl:attribute name="distR">114300</xsl:attribute>
	<xsl:attribute name="simplePos">0</xsl:attribute>
	<xsl:attribute name="relativeHeight">251658240</xsl:attribute>
	<xsl:attribute name="behindDoc">0</xsl:attribute>
	<xsl:attribute name="locked">0</xsl:attribute>
	<xsl:attribute name="layoutInCell">1</xsl:attribute>
	<xsl:attribute name="allowOverlap">1</xsl:attribute>
	<wp:simplePos x="0" y="0"/>
	<wp:positionH relativeFrom="column">
	  <wp:posOffset>0</wp:posOffset>
	</wp:positionH>
	<wp:positionV relativeFrom="paragraph">
	  <wp:posOffset>179705</wp:posOffset>
	</wp:positionV>
	<wp:extent>
	  <xsl:attribute name="cx"><xsl:value-of select="$width-in-emu"></xsl:value-of></xsl:attribute>
	  <xsl:attribute name="cy"><xsl:value-of select="$height-in-emu"></xsl:value-of></xsl:attribute>
	</wp:extent>
	<wp:effectExtent l="0" t="0" r="0" b="0" />
	<wp:wrapSquare wrapText="bothSides"/>
	<wp:docPr>
	  <xsl:attribute name="id">
	    <xsl:value-of select="count(preceding::informalfigure)"></xsl:value-of>
	  </xsl:attribute>
	  <xsl:attribute name="name">
	    <xsl:value-of select="$description"></xsl:value-of>
	  </xsl:attribute>
	</wp:docPr>
	<wp:cNvGraphicFramePr>
	  <a:graphicFrameLocks noChangeAspect="1" />
	</wp:cNvGraphicFramePr>
	<a:graphic>
	  <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
	    <pic:pic>
	      <pic:nvPicPr>
		<pic:cNvPr>
		  <xsl:attribute name="name"><xsl:value-of select="$file-name"></xsl:value-of></xsl:attribute>
		  <xsl:attribute name="id">
		    <xsl:value-of select="count(preceding::informalfigure)"></xsl:value-of>
		  </xsl:attribute>
		</pic:cNvPr>
		<pic:cNvPicPr />
	      </pic:nvPicPr>
	      <pic:blipFill>
		<a:blip cstate="print">
		  <xsl:attribute name="r:embed">
		    <xsl:value-of select="$relationship-id"></xsl:value-of>
		  </xsl:attribute>
		  <a:extLst>
		    <a:ext>
		      <xsl:attribute name="uri">{28A0092B-C50C-407E-A947-70E740481C1C}</xsl:attribute>
		    </a:ext>
		  </a:extLst>
		</a:blip>
		<a:stretch>
		  <a:fillRect />
		</a:stretch>
	      </pic:blipFill>
	      <pic:spPr>
		<a:xfrm>
		  <a:off x="0" y="0" />
		  <a:ext>
		    <xsl:attribute name="cx"><xsl:value-of select="$width-in-emu"></xsl:value-of></xsl:attribute>
		    <xsl:attribute name="cy"><xsl:value-of select="$height-in-emu"></xsl:value-of></xsl:attribute>
		  </a:ext>
		</a:xfrm>
		<a:prstGeom prst="rect">
		  <a:avLst />
		</a:prstGeom>
	      </pic:spPr>
	    </pic:pic>
	  </a:graphicData>
	</a:graphic>
      </xsl:element>
    </w:drawing>
  </xsl:template>

  <xsl:template match="screen">
    <w:p>
      <w:pPr>
	<w:pStyle w:val="screen" />
	<w:pBdr>
	  <w:top w:val="single" w:color="808080" w:sz="6" w:space="2" />
	  <w:left w:val="single" w:color="808080" w:sz="6" w:space="2" />
	  <w:bottom w:val="single" w:color="808080" w:sz="6" w:space="2" />
	  <w:right w:val="single" w:color="808080" w:sz="6" w:space="2" />
	</w:pBdr>
	<w:shd w:val="clear" w:color="auto" w:fill="F0F0F0" />
	<w:kinsoku w:val="0"/>
	<w:wordWrap w:val="0"/>
	<w:overflowPunct w:val="0"/>
	<w:autoSpaceDE w:val="0"/>
	<w:autoSpaceDN w:val="0"/>
      </w:pPr>
      <xsl:apply-templates select="node()">
	<xsl:with-param name="space-preserve" select="1"></xsl:with-param>
      </xsl:apply-templates>
    </w:p>
  </xsl:template>

  <xsl:template match="literal">
    <xsl:apply-templates select="node()">
      <xsl:with-param name="monospace" select="1"></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="ulink">
    <xsl:variable name="url"><xsl:value-of select="@url"></xsl:value-of></xsl:variable>
    <xsl:element name="w:hyperlink">
      <xsl:attribute name="r:id">
	<xsl:value-of select="document(concat($target-base, '/word/_rels/document.xml.rels'))/rel:Relationships/rel:Relationship[@Target=$url]/@Id"></xsl:value-of>
      </xsl:attribute>
      <xsl:apply-templates select="node()">
	<xsl:with-param name="color">000080</xsl:with-param><!-- navy -->
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="link">
    <!-- TODO: @linkend -->
    <xsl:apply-templates select="node()"></xsl:apply-templates>
  </xsl:template>

  <xsl:template match="note">
    <xsl:call-template name="draw-separator"></xsl:call-template>
    <xsl:apply-templates select="*"></xsl:apply-templates>
    <xsl:call-template name="draw-separator"></xsl:call-template>
  </xsl:template>

  <xsl:template name="draw-separator">
    <xsl:element name="w:p">
      <xsl:element name="w:r">
	<xsl:element name="w:separator"></xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="table/title">
    <w:p>
      <w:pPr>
	<w:pStyle w:val="heading3" />
      </w:pPr>
      <w:r><w:t>表<xsl:value-of select="count(preceding::table) + 1"></xsl:value-of>: </w:t></w:r>
      <xsl:apply-templates select="node()"></xsl:apply-templates>
    </w:p>
  </xsl:template>

  <xsl:template match="note/title">
    <xsl:element name="w:p">
      <w:pPr>
	<w:pStyle w:val="heading3" />
      </w:pPr>
      <w:r>
	<xsl:call-template name="icon-figure">
	  <xsl:with-param name="width">32</xsl:with-param>
	  <xsl:with-param name="height">32</xsl:with-param>
	  <xsl:with-param name="description">note-icon</xsl:with-param>
	  <xsl:with-param name="file-name">note.png</xsl:with-param>
	  <xsl:with-param name="relationship-id">icon-note</xsl:with-param>
	</xsl:call-template>
      </w:r>
      <xsl:apply-templates select="node()"></xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="text()" priority="0.75">
    <xsl:param name="bold"></xsl:param>
    <xsl:param name="space-preserve" select="0"></xsl:param>
    <xsl:param name="monospace"></xsl:param>
    <xsl:param name="color"></xsl:param>
    <w:r>
      <xsl:if test="$bold or $monospace or $color">
	<w:rPr>
	  <xsl:if test="$bold"><w:b /></xsl:if>
	  <xsl:if test="$monospace"><w:rFonts w:ascii="Courier" w:eastAsia="Courier" /></xsl:if>
	  <xsl:if test="$color">
	    <xsl:element name="w:color">
	      <xsl:attribute name="w:val"><xsl:value-of select="$color"></xsl:value-of></xsl:attribute>
	    </xsl:element>
	  </xsl:if>
	</w:rPr>
      </xsl:if>
      <xsl:choose>
	<xsl:when test="$space-preserve">
	  <xsl:call-template name="split-lines">
	    <xsl:with-param name="space-preserve" select="$space-preserve"></xsl:with-param>
	    <xsl:with-param name="text" select="."></xsl:with-param>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:element name="w:t">
	    <xsl:value-of select="."></xsl:value-of>
	  </xsl:element>
	</xsl:otherwise>
      </xsl:choose>
    </w:r>
  </xsl:template>

  <xsl:template name="split-lines">
    <xsl:param name="space-preserve" select="0"></xsl:param>
    <xsl:param name="text"></xsl:param>
    <xsl:variable name="no-crlf"
		  select="substring-before(concat($text, $crlf), $crlf)"></xsl:variable>
    <xsl:call-template name="strip-cr">
      <xsl:with-param name="text" select="$no-crlf"></xsl:with-param>
      <xsl:with-param name="space-preserve" select="$space-preserve"></xsl:with-param>
    </xsl:call-template>
    <xsl:if test="string-length(substring-after($text, $crlf))">
      <w:br></w:br>
      <xsl:call-template name="split-lines">
	<xsl:with-param name="text" select="substring-after($text, $crlf)"></xsl:with-param>
	<xsl:with-param name="space-preserve" select="$space-preserve"></xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="strip-cr">
    <xsl:param name="space-preserve" select="0"></xsl:param>
    <xsl:param name="text"></xsl:param>
    <xsl:variable name="no-cr-crlf"
		  select="substring-before(concat($text, $cr), $cr)"></xsl:variable>
    <xsl:call-template name="strip-lf">
      <xsl:with-param name="text" select="$no-cr-crlf"></xsl:with-param>
      <xsl:with-param name="space-preserve" select="$space-preserve"></xsl:with-param>
    </xsl:call-template>
    <xsl:if test="string-length(substring-after($text, $cr))">
      <w:br></w:br>
      <xsl:call-template name="strip-cr">
	<xsl:with-param name="text" select="substring-after($text, $cr)"></xsl:with-param>
	<xsl:with-param name="space-preserve" select="$space-preserve"></xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="strip-lf">
    <xsl:param name="space-preserve" select="0"></xsl:param>
    <xsl:param name="text"></xsl:param>
    <xsl:variable name="no-lf-cr-crlf"
		  select="substring-before(concat($text, $lf), $lf)"></xsl:variable>
    <xsl:element name="w:t">
      <xsl:if test="$space-preserve">
	<xsl:attribute name="xml:space">preserve</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$no-lf-cr-crlf"></xsl:value-of>
    </xsl:element>
    <xsl:if test="string-length(substring-after($text, $lf))">
      <w:br></w:br>
      <xsl:call-template name="strip-lf">
	<xsl:with-param name="text" select="substring-after($text, $lf)"></xsl:with-param>
	<xsl:with-param name="space-preserve" select="$space-preserve"></xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
