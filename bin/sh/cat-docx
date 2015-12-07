#/bin/bash

[[ -z $1 ]] && echo -e "USAGE:\tcatdocx <file.docx>" && exit
DIR="$(mktemp -d)"
cp "$1" $DIR
cd $DIR
unzip "$1" >/dev/null 2>&1
[[ $? -ne 0 ]] && echo "Unable to unzip $1" && rm -rf $DIR && exit

cat <<"EOF" > xslt.xsl
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">

<xsl:template match="w:p">
<xsl:apply-templates/><xsl:if test="position()!=last()"><xsl:text>

</xsl:text></xsl:if>
</xsl:template>

<xsl:template match="w:r">
 <xsl:if test="w:rPr/w:b"><xsl:text>\033[1m</xsl:text></xsl:if>
 <xsl:call-template name="pastb"/>
 <xsl:if test="w:rPr/w:b"><xsl:text>\033[0m</xsl:text></xsl:if>
</xsl:template>

<xsl:template name="pastb">
 <xsl:if test="w:rPr/w:i"><xsl:text></xsl:text></xsl:if>
 <xsl:call-template name="pasti"/>
 <xsl:if test="w:rPr/w:i"><xsl:text></xsl:text></xsl:if>
</xsl:template>

<xsl:template name="pasti">
 <xsl:apply-templates select="w:t"/>
</xsl:template>

</xsl:stylesheet>
EOF

echo -e "$(xsltproc xslt.xsl word/document.xml)" |
	sed '1d' | tr -cd '\000-\177'
rm -rf $DIR
