<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Neumont PLiX (Programming Language in XML) Code Generator

	Copyright © Neumont University and Matthew Curland. All rights reserved.

	The use and distribution terms for this software are covered by the
	Common Public License 1.0 (http://opensource.org/licenses/cpl) which
	can be found in the file CPL.txt at the root of this distribution.
	By using this software in any fashion, you are agreeing to be bound by
	the terms of this license.

	You must not remove this notice, or any other, from this software.
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:plx="http://schemas.neumont.edu/CodeGeneration/PLiX"
	xmlns:plxGen="urn:local-plix-generator"
	xmlns:exsl="http://exslt.org/common"
	exclude-result-prefixes="#default exsl plx plxGen">
	<xsl:import href="PLiXMain.xslt"/>
	<xsl:output method="text"/>
	<!-- The prefix used for any automatically generated labels -->
	<xsl:param name="AutoLabelPrefix" select="'PLiXVB_AutoLabel'"/>
	<xsl:param name="AutoVariablePrefix" select="'PLiXVB'"/>
	<xsl:template match="*" mode="LanguageInfo">
		<plxGen:languageInfo
			defaultBlockClose=""
			blockOpen=""
			newLineBeforeBlockOpen="no"
			defaultStatementClose=""
			requireCaseLabels="yes"
			expandInlineStatements="yes"
			autoVariablePrefix="{$AutoVariablePrefix}"
			comment="'"
			docComment="''' "/>
	</xsl:template>

	<!-- Operator Precedence Resolution -->
	<xsl:template match="*" mode="ResolvePrecedence">
		<xsl:param name="Indent"/>
		<xsl:param name="Context"/>
		<xsl:variable name="contextPrecedenceFragment">
			<xsl:apply-templates select="$Context" mode="Precedence"/>
		</xsl:variable>
		<xsl:variable name="contextPrecedence" select="number($contextPrecedenceFragment)"/>
		<xsl:choose>
			<!-- NaN tests false (which we want to ignore), but so does 0 (which we don't) -->
			<xsl:when test="$contextPrecedence or ($contextPrecedence=0)">
				<xsl:variable name="currentPrecedenceFragment">
					<xsl:apply-templates select="."  mode="Precedence"/>
				</xsl:variable>
				<xsl:variable name="currentPrecedence" select="number($currentPrecedenceFragment)"/>
				<xsl:choose>
					<xsl:when test="($currentPrecedence or ($currentPrecedence=0)) and ($contextPrecedence&lt;$currentPrecedence)">
						<xsl:text>(</xsl:text>
						<xsl:apply-templates select=".">
							<xsl:with-param name="Indent" select="$Indent"/>
						</xsl:apply-templates>
						<xsl:text>)</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select=".">
							<xsl:with-param name="Indent" select="$Indent"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select=".">
					<xsl:with-param name="Indent" select="$Indent"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:expression[@parens='true' or @parens='1']" mode="ResolvePrecedence">
		<xsl:param name="Indent"/>
		<xsl:apply-templates select=".">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:apply-templates>
	</xsl:template>
	<!-- Assume elements without explicit precedence are autonomous expression  (indicated by 0) -->
	<xsl:template match="*" mode="Precedence">0</xsl:template>
	<xsl:template match="plx:inlineStatement" mode="Precedence">
		<xsl:apply-templates select="child::*" mode="Precedence"/>
	</xsl:template>
	<!-- Specific precedence values -->
	<xsl:template match="plx:callInstance" mode="Precedence">6</xsl:template>
	<xsl:template match="plx:callNew" mode="Precedence">8</xsl:template>
	<xsl:template match="plx:unaryOperator" mode="Precedence">20</xsl:template>
	<xsl:template match="plx:concatenate|plx:increment|plx:decrement" mode="Precedence">40</xsl:template>
	<xsl:template match="plx:binaryOperator" mode="Precedence">
		<xsl:variable name="type" select="string(@type)"/>
		<xsl:choose>
			<xsl:when test="$type='add'">40</xsl:when>
			<xsl:when test="$type='assignNamed'">0</xsl:when>
			<xsl:when test="$type='bitwiseAnd'">80</xsl:when>
			<xsl:when test="$type='bitwiseExclusiveOr'">84</xsl:when>
			<xsl:when test="$type='bitwiseOr'">82</xsl:when>
			<xsl:when test="$type='booleanAnd'">80</xsl:when>
			<xsl:when test="$type='booleanOr'">82</xsl:when>
			<xsl:when test="$type='divide'">30</xsl:when>
			<xsl:when test="$type='equality'">60</xsl:when>
			<xsl:when test="$type='greaterThan'">60</xsl:when>
			<xsl:when test="$type='greaterThanOrEqual'">60</xsl:when>
			<xsl:when test="$type='identityEquality'">60</xsl:when>
			<xsl:when test="$type='identityInequality'">60</xsl:when>
			<xsl:when test="$type='inequality'">60</xsl:when>
			<xsl:when test="$type='lessThan'">60</xsl:when>
			<xsl:when test="$type='lessThanOrEqual'">60</xsl:when>
			<xsl:when test="$type='modulus'">30</xsl:when>
			<xsl:when test="$type='multiply'">30</xsl:when>
			<xsl:when test="$type='shiftLeft'">50</xsl:when>
			<xsl:when test="$type='shiftRight'">50</xsl:when>
			<xsl:when test="$type='shiftRightZero'">50</xsl:when>
			<xsl:when test="$type='shiftRightPreserve'">50</xsl:when>
			<xsl:when test="$type='subtract'">40</xsl:when>
			<xsl:when test="$type='typeEquality'">60</xsl:when>
			<xsl:when test="$type='typeInequality'">60</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:unaryOperator[@type='bitwiseNot' or @type='booleanNot']" mode="Precedence">70</xsl:template>

	<!-- Matched templates -->
	<xsl:template match="plx:alternateBranch">
		<xsl:param name="Indent"/>
		<xsl:text>ElseIf </xsl:text>
		<xsl:apply-templates select="plx:condition/child::*">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:apply-templates>
		<xsl:text> Then</xsl:text>
	</xsl:template>
	<xsl:template match="plx:assign">
		<xsl:param name="Indent"/>
		<xsl:apply-templates select="plx:left/child::*">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:apply-templates>
		<xsl:text> = </xsl:text>
		<xsl:apply-templates select="plx:right/child::*">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="plx:attachEvent">
		<xsl:param name="Indent"/>
		<xsl:text>AddHandler </xsl:text>
		<xsl:apply-templates select="plx:left/child::*">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:apply-templates>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="plx:right/child::*">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="plx:attribute">
		<xsl:param name="Indent"/>
		<xsl:text>&lt;</xsl:text>
		<xsl:variable name="attributePrefix" select="string(@type)"/>
		<xsl:choose>
			<xsl:when test="$attributePrefix='assembly'">
				<xsl:text>Assembly: </xsl:text>
			</xsl:when>
			<xsl:when test="$attributePrefix='module'">
				<xsl:text>Module: </xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:call-template name="RenderAttribute">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:call-template>
		<xsl:text>&gt;</xsl:text>
	</xsl:template>
	<xsl:template match="plx:autoDispose">
		<xsl:param name="Indent"/>
		<xsl:text>Using </xsl:text>
		<xsl:if test="not(@localName='.implied')">
			<xsl:value-of select="@localName"/>
			<xsl:text> As </xsl:text>
			<xsl:call-template name="RenderType"/>
			<xsl:text> = </xsl:text>
		</xsl:if>
		<xsl:for-each select="plx:initialize">
			<xsl:apply-templates select="child::*">
				<xsl:with-param name="Indent" select="$Indent"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="plx:autoDispose" mode="IndentInfo">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="'End Using'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:binaryOperator">
		<xsl:param name="Indent"/>
		<xsl:variable name="type" select="string(@type)"/>
		<xsl:if test="starts-with($type,'type')">
			<xsl:if test="$type='typeInequality'">
				<xsl:text>Not </xsl:text>
			</xsl:if>
			<xsl:text>TypeOf </xsl:text>
		</xsl:if>
		<xsl:apply-templates select="plx:left/child::*" mode="ResolvePrecedence">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="Context" select="."/>
		</xsl:apply-templates>
		<xsl:choose>
			<xsl:when test="$type='add'">
				<xsl:text> + </xsl:text>
			</xsl:when>
			<xsl:when test="$type='assignNamed'">
				<xsl:text>:=</xsl:text>
			</xsl:when>
			<xsl:when test="$type='bitwiseAnd'">
				<xsl:text> And </xsl:text>
			</xsl:when>
			<xsl:when test="$type='bitwiseExclusiveOr'">
				<xsl:text> Xor </xsl:text>
			</xsl:when>
			<xsl:when test="$type='bitwiseOr'">
				<xsl:text> Or </xsl:text>
			</xsl:when>
			<xsl:when test="$type='booleanAnd'">
				<xsl:text> AndAlso </xsl:text>
			</xsl:when>
			<xsl:when test="$type='booleanOr'">
				<xsl:text> OrElse </xsl:text>
			</xsl:when>
			<xsl:when test="$type='divide'">
				<xsl:text> / </xsl:text>
			</xsl:when>
			<xsl:when test="$type='equality'">
				<xsl:text> = </xsl:text>
			</xsl:when>
			<xsl:when test="$type='greaterThan'">
				<xsl:text> &gt; </xsl:text>
			</xsl:when>
			<xsl:when test="$type='greaterThanOrEqual'">
				<xsl:text> &gt;= </xsl:text>
			</xsl:when>
			<xsl:when test="$type='identityEquality'">
				<xsl:text> Is </xsl:text>
			</xsl:when>
			<xsl:when test="$type='identityInequality'">
				<xsl:text> IsNot </xsl:text>
			</xsl:when>
			<xsl:when test="$type='inequality'">
				<xsl:text> &lt;&gt; </xsl:text>
			</xsl:when>
			<xsl:when test="$type='lessThan'">
				<xsl:text> &lt; </xsl:text>
			</xsl:when>
			<xsl:when test="$type='lessThanOrEqual'">
				<xsl:text> &lt;= </xsl:text>
			</xsl:when>
			<xsl:when test="$type='modulus'">
				<xsl:text> Mod </xsl:text>
			</xsl:when>
			<xsl:when test="$type='multiply'">
				<xsl:text> * </xsl:text>
			</xsl:when>
			<xsl:when test="$type='shiftLeft'">
				<xsl:text> &lt;&lt; </xsl:text>
			</xsl:when>
			<xsl:when test="$type='shiftRight'">
				<xsl:text> &gt;&gt; </xsl:text>
			</xsl:when>
			<xsl:when test="$type='shiftRightZero'">
				<xsl:text> &gt;&gt; </xsl:text>
			</xsl:when>
			<xsl:when test="$type='shiftRightPreserve'">
				<xsl:text> &gt;&gt; </xsl:text>
			</xsl:when>
			<xsl:when test="$type='subtract'">
				<xsl:text> - </xsl:text>
			</xsl:when>
			<xsl:when test="$type='typeEquality'">
				<xsl:text> Is </xsl:text>
			</xsl:when>
			<xsl:when test="$type='typeInequality'">
				<!-- This whole expression is negated -->
				<xsl:text> Is </xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates select="plx:right/child::*" mode="ResolvePrecedence">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="Context" select="."/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="plx:branch">
		<xsl:param name="Indent"/>
		<xsl:text>If </xsl:text>
		<xsl:apply-templates select="plx:condition/child::*">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:apply-templates>
		<xsl:text> Then</xsl:text>
	</xsl:template>
	<xsl:template match="plx:branch" mode="IndentInfo">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="'End If'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:break">
		<xsl:apply-templates select="parent::plx:*" mode="RenderBreak"/>
	</xsl:template>
	<xsl:template match="*" mode="RenderBreak">
		<xsl:apply-templates select="parent::plx:*" mode="RenderBreak"/>
	</xsl:template>
	<xsl:template match="plx:loop" mode="RenderBreak">
		<!-- This needs to be carefully kept in sync with plx:loop so
						 we match the correct loop type -->
		<xsl:choose>
			<xsl:when test="@checkCondition='after' and plx:condition">
				<xsl:text>Exit Do</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<!-- UNDONE: Recognize patterns for VB's for loop. -->
				<xsl:text>Exit While</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:iterator" mode="RenderBreak">
		<xsl:text>Exit For</xsl:text>
	</xsl:template>
	<xsl:template match="plx:switch" mode="RenderBreak">
		<xsl:text>Exit Select</xsl:text>
	</xsl:template>
	<xsl:template match="plx:callInstance">
		<xsl:param name="Indent"/>
		<xsl:if test="@type='methodReference'">
			<xsl:text>AddressOf </xsl:text>
		</xsl:if>
		<xsl:apply-templates select="plx:callObject/child::*" mode="ResolvePrecedence">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="Context" select="."/>
		</xsl:apply-templates>
		<xsl:call-template name="RenderCallBody">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:callNew">
		<xsl:param name="Indent"/>
		<xsl:text>New </xsl:text>
		<xsl:call-template name="RenderType">
			<xsl:with-param name="RenderArray" select="false()"/>
		</xsl:call-template>
		<xsl:variable name="arrayDescriptor" select="plx:arrayDescriptor"/>
		<xsl:variable name="isSimpleArray" select="@dataTypeIsSimpleArray='true' or @dataTypeIsSimpleArray='1'"/>
		<xsl:choose>
			<xsl:when test="$arrayDescriptor or $isSimpleArray">
				<xsl:variable name="initializer" select="plx:arrayInitializer"/>
				<xsl:choose>
					<xsl:when test="$initializer">
						<!-- If we have an array initializer, then ignore the passed in
							 parameters and render the full array descriptor brackets -->
						<xsl:choose>
							<xsl:when test="$arrayDescriptor">
								<xsl:for-each select="$arrayDescriptor">
									<xsl:call-template name="RenderArrayDescriptor"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>()</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:for-each select="$initializer">
							<xsl:call-template name="RenderArrayInitializer">
								<xsl:with-param name="Indent" select="$Indent"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<!-- There is no initializer, so parameters are passed for the
							 first bound. We need the same number as parameters as the
							 first array rank, and we get the array descriptor brackets
							 for nested arrays. -->
						<xsl:variable name="passParams" select="plx:passParam"/>
						<xsl:call-template name="RenderPassParams">
							<xsl:with-param name="Indent" select="$Indent"/>
							<xsl:with-param name="PassParams" select="$passParams"/>
						</xsl:call-template>
						<xsl:choose>
							<xsl:when test="$arrayDescriptor">
								<xsl:for-each select="$arrayDescriptor">
									<xsl:if test="@rank!=count($passParams)">
										<xsl:message terminate="yes">The number of parameters must match the rank of the array if no initializer is specified.</xsl:message>
									</xsl:if>
									<xsl:for-each select="plx:arrayDescriptor">
										<xsl:call-template name="RenderArrayDescriptor"/>
									</xsl:for-each>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="1!=count($passParams)">
									<xsl:message terminate="yes">The number of parameters must match the rank of the array if no initializer is specified.</xsl:message>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text> {}</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- Not an array constructor -->
				<xsl:call-template name="RenderPassParams">
					<xsl:with-param name="Indent" select="$Indent"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:callStatic">
		<xsl:param name="Indent"/>
		<xsl:if test="@type='methodReference'">
			<xsl:text>AddressOf </xsl:text>
		</xsl:if>
		<xsl:call-template name="RenderType"/>
		<xsl:call-template name="RenderCallBody">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="Unqualified" select="@dataTypeName='.global'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:callThis">
		<xsl:param name="Indent"/>
		<xsl:if test="@type='methodReference'">
			<xsl:text>AddressOf </xsl:text>
		</xsl:if>
		<xsl:variable name="accessor" select="@accessor"/>
		<xsl:choose>
			<xsl:when test="$accessor='base'">
				<xsl:text>MyBase</xsl:text>
			</xsl:when>
			<xsl:when test="$accessor='explicitThis'">
				<xsl:text>MyClass</xsl:text>
			</xsl:when>
			<xsl:when test="$accessor='static'">
				<!-- Nothing to do, don't qualify -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Me</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="RenderCallBody">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="Unqualified" select="$accessor='static'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:case">
		<xsl:param name="Indent"/>
		<xsl:param name="LocalItemKey"/>
		<xsl:param name="CaseLabels"/>
		<xsl:text>Case </xsl:text>
		<xsl:for-each select="plx:condition">
			<xsl:if test="position()!=1">
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:apply-templates select="child::plx:*">
				<xsl:with-param name="Indent" select="$Indent"/>
			</xsl:apply-templates>
		</xsl:for-each>
		<xsl:if test="$CaseLabels[@key=$LocalItemKey]">
			<xsl:value-of select="$NewLine"/>
			<xsl:value-of select="$Indent"/>
			<xsl:value-of select="$AutoLabelPrefix"/>
			<xsl:value-of select="$LocalItemKey"/>
			<xsl:text>:</xsl:text>
		</xsl:if>
	</xsl:template>
	<xsl:template match="plx:cast">
		<xsl:param name="Indent"/>
		<xsl:variable name="castTarget" select="child::plx:*[position()=last()]"/>
		<xsl:variable name="castType" select="string(@type)"/>
		<xsl:choose>
			<xsl:when test="$castType='testCast'">
				<xsl:text>TryCast(</xsl:text>
				<xsl:apply-templates select="$castTarget">
					<xsl:with-param name="Indent" select="$Indent"/>
				</xsl:apply-templates>
				<xsl:text>, </xsl:text>
				<xsl:call-template name="RenderType"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<!-- Handles exceptionCast, unbox, primitiveChecked, primitiveUnchecked -->
				<!-- UNDONE: Distinguish primitiveChecked vs primitiveUnchecked cast -->
				<xsl:variable name="targetTypeFragment">
					<xsl:call-template name="RenderType"/>
				</xsl:variable>
				<xsl:variable name="targetType" select="string($targetTypeFragment)"/>
				<xsl:variable name="convertTo" select="substring-after(' Boolean/CBool Byte/CByte Char/CChar Date/CDate Double/CDbl Decimal/CDec Integer/CInt Long/CLng Object/CObj SByte/CSByte Short/CShort Single/CSng String/CStr UInteger/CUInt ULong/CULng UShort/CUShort ', concat(' ',$targetType,'/'))"/>
				<xsl:choose>
					<xsl:when test="string-length($convertTo)">
						<xsl:value-of select="substring-before($convertTo,' ')"/>
						<xsl:text>(</xsl:text>
						<xsl:apply-templates select="$castTarget">
							<xsl:with-param name="Indent" select="$Indent"/>
						</xsl:apply-templates>
						<xsl:text>)</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$castType='unbox'">
								<xsl:text>DirectCast(</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>CType(</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:apply-templates select="$castTarget">
							<xsl:with-param name="Indent" select="$Indent"/>
						</xsl:apply-templates>
						<xsl:text>, </xsl:text>
						<xsl:value-of select="$targetType"/>
						<xsl:text>)</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:catch">
		<xsl:text>Catch </xsl:text>
		<xsl:value-of select="@localName"/>
		<xsl:text> As </xsl:text>
		<xsl:call-template name="RenderType"/>
	</xsl:template>
	<xsl:template match="plx:class">
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderTypeDefinition">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="TypeKeyword" select="'Class'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:class" mode="IndentInfo">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="'End Class'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:concatenate">
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderExpressionList">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="BracketPair" select="''"/>
			<xsl:with-param name="ListSeparator" select="' &amp; '"/>
			<xsl:with-param name="PrecedenceContext" select="."/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:continue">
		<xsl:param name="Indent"/>
		<xsl:apply-templates select="parent::plx:*" mode="RenderContinue">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="*" mode="RenderContinue">
		<xsl:param name="Indent"/>
		<xsl:apply-templates select="parent::plx:*" mode="RenderContinue">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="plx:iterator" mode="RenderContinue">
		<xsl:text>Continue For</xsl:text>
	</xsl:template>
	<xsl:template match="plx:loop" mode="RenderContinue">
		<xsl:param name="Indent"/>
		<!-- This needs to be carefully kept in sync with plx:loop so
						 we match the correct loop type -->
		<xsl:choose>
			<xsl:when test="@checkCondition='after'">
				<xsl:variable name="condition" select="plx:condition/child::plx:*"/>
				<xsl:choose>
					<xsl:when test="$condition">
						<xsl:variable name="beforeLoop" select="plx:beforeLoop/child::plx:*"/>
						<xsl:for-each select="$beforeLoop">
							<xsl:call-template name="RenderElement">
								<xsl:with-param name="Indent" select="$Indent"/>
								<xsl:with-param name="Statement" select="true()"/>
								<xsl:with-param name="SkipLeadingIndent" select="true()"/>
							</xsl:call-template>
						</xsl:for-each>
						<xsl:text>Continue Do</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Continue While</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Continue While</xsl:text>
			</xsl:otherwise>
			<!-- UNDONE: Recognize patterns for VB's for loop. -->
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:decrement">
		<xsl:param name="Indent"/>
		<!-- UNDONE: Can we always render like this, or only for nameRef and call* type='field' -->
		<xsl:apply-templates select="child::*">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:apply-templates>
		<xsl:text> = </xsl:text>
		<xsl:apply-templates select="child::*" mode="ResolvePrecedence">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="Context" select="."/>
		</xsl:apply-templates>
		<xsl:text> - 1</xsl:text>
	</xsl:template>
	<xsl:template match="plx:defaultValueOf">
		<xsl:text>Nothing</xsl:text>
	</xsl:template>
	<xsl:template match="plx:delegate">
		<xsl:param name="Indent"/>
		<xsl:variable name="returns" select="plx:returns"/>
		<xsl:call-template name="RenderAttributes">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:call-template>
		<xsl:if test="$returns">
			<xsl:for-each select="$returns">
				<xsl:call-template name="RenderAttributes">
					<xsl:with-param name="Indent" select="$Indent"/>
					<xsl:with-param name="Prefix" select="'returns:'"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:if>
		<xsl:call-template name="RenderVisibility"/>
		<xsl:call-template name="RenderReplacesName"/>
		<xsl:text>Delegate </xsl:text>
		<xsl:choose>
			<xsl:when test="$returns">
				<xsl:text>Function </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Sub </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="@name"/>
		<xsl:variable name="typeParams" select="plx:typeParam"/>
		<xsl:if test="$typeParams">
			<xsl:call-template name="RenderTypeParams">
				<xsl:with-param name="TypeParams" select="$typeParams"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="RenderParams"/>
		<xsl:if test="$returns">
			<xsl:text> As </xsl:text>
			<xsl:for-each select="$returns">
				<xsl:call-template name="RenderAttributes">
					<xsl:with-param name="Indent" select="$Indent"/>
					<xsl:with-param name="Inline" select="true()"/>
				</xsl:call-template>
				<xsl:call-template name="RenderType"/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template match="plx:detachEvent">
		<xsl:param name="Indent"/>
		<xsl:text>RemoveHandler </xsl:text>
		<xsl:apply-templates select="plx:left/child::*">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:apply-templates>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="plx:right/child::*">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="plx:directTypeReference">
		<xsl:call-template name="RenderType"/>
	</xsl:template>
	<xsl:template match="plx:enum">
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderTypeDefinition">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="TypeKeyword" select="'Enum'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:enum" mode="IndentInfo">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="'End Enum'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:enumItem">
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderAttributes">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:call-template>
		<xsl:value-of select="@name"/>
		<xsl:for-each select="plx:initialize">
			<xsl:text> = </xsl:text>
			<xsl:apply-templates select="child::*">
				<xsl:with-param name="Indent" select="$Indent"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="plx:event">
		<xsl:param name="Indent"/>
		<xsl:variable name="explicitDelegate" select="plx:explicitDelegateType"/>
		<xsl:variable name="name" select="@name"/>
		
		<xsl:call-template name="RenderAttributes">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:call-template>
		<xsl:if test="not(parent::plx:interface)">
			<xsl:call-template name="RenderVisibility"/>
			<xsl:call-template name="RenderProcedureModifier"/>
		</xsl:if>
		<xsl:call-template name="RenderReplacesName"/>
		<xsl:if test="plx:onAdd">
			<xsl:text>Custom </xsl:text>
		</xsl:if>
		<xsl:text>Event </xsl:text>
		<xsl:value-of select="$name"/>
		<xsl:choose>
			<xsl:when test="$explicitDelegate">
				<xsl:text> As </xsl:text>
				<xsl:for-each select="$explicitDelegate">
					<xsl:call-template name="RenderType">
						<xsl:with-param name="ExplicitPassTypeParams" select="following-sibling::plx:passTypeParam"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="typeParams" select="plx:typeParam"/>
				<xsl:if test="$typeParams">
					<xsl:call-template name="RenderTypeParams">
						<xsl:with-param name="TypeParams" select="$typeParams"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:call-template name="RenderParams"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="RenderInterfaceMembers">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:event[not(plx:onAdd)][not(parent::plx:interface)][plx:attribute[@type='implicitAccessorFunction' or @type='implicitField']]">
		<xsl:param name="Indent"/>
		<xsl:variable name="explicitDelegate" select="plx:explicitDelegateType"/>
		<xsl:variable name="name" select="string(@name)"/>
		<xsl:variable name="implicitDelegateName" select="string(@implicitDelegateName)"/>
		<xsl:call-template name="RenderVisibility"/>
		<xsl:call-template name="RenderProcedureModifier"/>
		<xsl:text>Custom Event </xsl:text>
		<xsl:value-of select="$name"/>
		<xsl:text> As </xsl:text>
		<xsl:choose>
			<xsl:when test="$explicitDelegate">
				<xsl:for-each select="$explicitDelegate">
					<xsl:call-template name="RenderType">
						<xsl:with-param name="ExplicitPassTypeParams" select="following-sibling::plx:passTypeParam"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="passTypeParams" select="plx:passTypeParams"/>
				<xsl:choose>
					<xsl:when test="$implicitDelegateName">
						<xsl:call-template name="RenderType">
							<xsl:with-param name="DataTypeName" select="$implicitDelegateName"/>
							<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="RenderType">
							<xsl:with-param name="DataTypeName" select="concat($name,'EventHandler')"/>
							<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:event[plx:onAdd]" mode="IndentInfo" priority=".6">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<!-- Ignored if the main template says this is a simple event -->
			<xsl:with-param name="closeWith" select="'End Event'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:event[not(parent::plx:interface)][plx:attribute[@type='implicitField' or @type='implicitAccessorFunction']]" mode="IndentInfo" priority=".55">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="style" select="'blockMember'"/>
			<xsl:with-param name="closeBlockCallback" select="true()"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:event" mode="CloseBlock">
		<xsl:param name="Indent"/>
		<!-- This is a very special case. We render a delegate, field, and custom event functions so that
		we can properly place the attributes. Note that there is no way to render custom method
		attributes on interfaces in VB, so we ignore this case (field attributes considered part of
		the implementation, not the method signature, so they are never rendered on interfaces). -->
		<xsl:variable name="explicitDelegate" select="plx:explicitDelegateType"/>
		<xsl:variable name="name" select="string(@name)"/>
		<xsl:variable name="isStatic" select="@modifier='static'"/>
		<xsl:variable name="implicitDelegateName" select="string(@implicitDelegateName)"/>
		<xsl:variable name="passTypeParams" select="plx:passTypeParams"/>
		<xsl:variable name="methodAttributes" select="plx:attribute[@type='implicitAccessorFunction']"/>

		<!-- Render the AddHandler, RemoveHandler, RaiseEvent methods -->
		<xsl:choose>
			<xsl:when test="$methodAttributes">
				<xsl:value-of select="$SingleIndent"/>
				<xsl:call-template name="RenderAttributes">
					<xsl:with-param name="Indent" select="concat($Indent,$SingleIndent)"/>
					<xsl:with-param name="TypeFilter" select="'implicitAccessorFunction'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$SingleIndent"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>AddHandler(ByVal value As </xsl:text>
		<xsl:choose>
			<xsl:when test="$explicitDelegate">
				<xsl:for-each select="$explicitDelegate">
					<xsl:call-template name="RenderType">
						<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$implicitDelegateName">
				<xsl:call-template name="RenderType">
					<xsl:with-param name="DataTypeName" select="$implicitDelegateName"/>
					<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="RenderType">
					<xsl:with-param name="DataTypeName" select="concat($name,'EventHandler')"/>
					<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>)</xsl:text>
		<xsl:value-of select="$NewLine"/>
		<xsl:value-of select="$Indent"/>
		<xsl:value-of select="$SingleIndent"/>
		<xsl:value-of select="$SingleIndent"/>
		<xsl:value-of select="$name"/>
		<xsl:text>Event = DirectCast(System.Delegate.Combine(</xsl:text>
		<xsl:value-of select="$name"/>
		<xsl:text>Event, value), </xsl:text>
		<xsl:choose>
			<xsl:when test="$explicitDelegate">
				<xsl:for-each select="$explicitDelegate">
					<xsl:call-template name="RenderType">
						<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$implicitDelegateName">
				<xsl:call-template name="RenderType">
					<xsl:with-param name="DataTypeName" select="$implicitDelegateName"/>
					<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="RenderType">
					<xsl:with-param name="DataTypeName" select="concat($name,'EventHandler')"/>
					<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>)</xsl:text>
		<xsl:value-of select="$NewLine"/>
		<xsl:value-of select="$Indent"/>
		<xsl:value-of select="$SingleIndent"/>
		<xsl:text>End AddHandler</xsl:text>
		<xsl:value-of select="$NewLine"/>
		<xsl:value-of select="$Indent"/>
		<xsl:choose>
			<xsl:when test="$methodAttributes">
				<xsl:value-of select="$SingleIndent"/>
				<xsl:call-template name="RenderAttributes">
					<xsl:with-param name="Indent" select="concat($Indent,$SingleIndent)"/>
					<xsl:with-param name="TypeFilter" select="'implicitAccessorFunction'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$SingleIndent"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>RemoveHandler(ByVal value As </xsl:text>
		<xsl:choose>
			<xsl:when test="$explicitDelegate">
				<xsl:for-each select="$explicitDelegate">
					<xsl:call-template name="RenderType">
						<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$implicitDelegateName">
				<xsl:call-template name="RenderType">
					<xsl:with-param name="DataTypeName" select="$implicitDelegateName"/>
					<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="RenderType">
					<xsl:with-param name="DataTypeName" select="concat($name,'EventHandler')"/>
					<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>)</xsl:text>
		<xsl:value-of select="$NewLine"/>
		<xsl:value-of select="$Indent"/>
		<xsl:value-of select="$SingleIndent"/>
		<xsl:value-of select="$SingleIndent"/>
		<xsl:value-of select="$name"/>
		<xsl:text>Event = DirectCast(System.Delegate.Remove(</xsl:text>
		<xsl:value-of select="$name"/>
		<xsl:text>Event, value), </xsl:text>
		<xsl:choose>
			<xsl:when test="$explicitDelegate">
				<xsl:for-each select="$explicitDelegate">
					<xsl:call-template name="RenderType">
						<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$implicitDelegateName">
				<xsl:call-template name="RenderType">
					<xsl:with-param name="DataTypeName" select="$implicitDelegateName"/>
					<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="RenderType">
					<xsl:with-param name="DataTypeName" select="concat($name,'EventHandler')"/>
					<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>)</xsl:text>
		<xsl:value-of select="$NewLine"/>
		<xsl:value-of select="$Indent"/>
		<xsl:value-of select="$SingleIndent"/>
		<xsl:text>End RemoveHandler</xsl:text>
		<xsl:value-of select="$NewLine"/>
		<xsl:value-of select="$Indent"/>
		<xsl:value-of select="$SingleIndent"/>
		<xsl:text>RaiseEvent</xsl:text>
		<xsl:call-template name="RenderParams"/>
		<xsl:value-of select="$NewLine"/>
		<xsl:value-of select="$Indent"/>
		<xsl:value-of select="$SingleIndent"/>
		<xsl:value-of select="$SingleIndent"/>
		<xsl:value-of select="$name"/>
		<xsl:text>Event(</xsl:text>
		<xsl:for-each select="plx:param">
			<xsl:if test="position()!=1">
				<xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:value-of select="@name"/>
		</xsl:for-each>
		<xsl:text>)</xsl:text>
		<xsl:value-of select="$NewLine"/>
		<xsl:value-of select="$Indent"/>
		<xsl:value-of select="$SingleIndent"/>
		<xsl:text>End RaiseEvent</xsl:text>
		<xsl:value-of select="$NewLine"/>
		<xsl:value-of select="$Indent"/>
		<xsl:text>End Event</xsl:text>
		<xsl:value-of select="$NewLine"/>
		<xsl:value-of select="$Indent"/>

		<!-- Render the delegate and field as needed -->
		<xsl:if test="not($explicitDelegate)">
			<xsl:text><![CDATA[''' <summary>Delegate auto-generated by PLiX VB formatter</summary>]]></xsl:text>
			<xsl:value-of select="$NewLine"/>
			<xsl:value-of select="$Indent"/>
			<xsl:call-template name="RenderVisibility"/>
			<xsl:text>Delegate Sub </xsl:text>
			<xsl:value-of select="@name"/>
			<xsl:choose>
				<xsl:when test="$implicitDelegateName">
					<xsl:value-of select="$implicitDelegateName"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$name"/>
					<xsl:text>EventHandler</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="RenderTypeParams">
				<xsl:with-param name="TypeParams" select="plx:typeParam"/>
			</xsl:call-template>
			<xsl:call-template name="RenderParams"/>
			<xsl:value-of select="$NewLine"/>
			<xsl:value-of select="$Indent"/>
		</xsl:if>
		<xsl:text><![CDATA[''' <summary>Field auto-generated by PLiX VB formatter</summary>]]></xsl:text>
		<xsl:value-of select="$NewLine"/>
		<xsl:value-of select="$Indent"/>
		<xsl:call-template name="RenderAttributes">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="TypeFilter" select="'implicitField'"/>
		</xsl:call-template>
		<xsl:text>Private </xsl:text>
		<xsl:if test="$isStatic">
			<!-- Ignore modifiers other than static for the field, don't call RenderProcedureModifier -->
			<xsl:text>Shared </xsl:text>
		</xsl:if>
		<xsl:value-of select="$name"/>
		<xsl:text>Event As </xsl:text>
		<xsl:choose>
			<xsl:when test="$explicitDelegate">
				<xsl:for-each select="$explicitDelegate">
					<xsl:call-template name="RenderType">
						<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$implicitDelegateName">
				<xsl:call-template name="RenderType">
					<xsl:with-param name="DataTypeName" select="$implicitDelegateName"/>
					<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="RenderType">
					<xsl:with-param name="DataTypeName" select="concat($name,'EventHandler')"/>
					<xsl:with-param name="ExplicitPassTypeParams" select="$passTypeParams"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$NewLine"/>
	</xsl:template>
	<xsl:template match="plx:expression">
		<xsl:variable name="outputParens" select="@parens='true' or @parens='1'"/>
		<xsl:if test="$outputParens">
			<xsl:text>(</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="child::*"/>
		<xsl:if test="$outputParens">
			<xsl:text>)</xsl:text>
		</xsl:if>
	</xsl:template>
	<xsl:template match="plx:fallbackBranch">
		<xsl:text>Else</xsl:text>
	</xsl:template>
	<xsl:template match="plx:fallbackCase">
		<xsl:text>Case Else</xsl:text>
	</xsl:template>
	<xsl:template match="plx:fallbackCatch">
		<xsl:text>Catch</xsl:text>
	</xsl:template>
	<xsl:template match="plx:falseKeyword">
		<xsl:text>False</xsl:text>
	</xsl:template>
	<xsl:template match="plx:field">
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderAttributes">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:call-template>
		<xsl:call-template name="RenderVisibility"/>
		<xsl:call-template name="RenderStatic"/>
		<xsl:call-template name="RenderReplacesName"/>
		<xsl:call-template name="RenderConst"/>
		<xsl:call-template name="RenderReadOnly"/>
		<xsl:value-of select="@name"/>
		<xsl:text> As </xsl:text>
		<xsl:call-template name="RenderType"/>
		<xsl:for-each select="plx:initialize">
			<xsl:text> = </xsl:text>
			<xsl:apply-templates select="child::*">
				<xsl:with-param name="Indent" select="$Indent"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="plx:finally">
		<xsl:text>Finally</xsl:text>
	</xsl:template>
	<xsl:template match="plx:function">
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderAttributes">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:call-template>
		<xsl:variable name="name" select="@name"/>
		<xsl:choose>
			<xsl:when test="starts-with($name,'.')">
				<xsl:choose>
					<xsl:when test="$name='.construct'">
						<xsl:call-template name="RenderVisibility"/>
						<xsl:if test="@modifier='static'">
							<!-- Ignore modifiers other than static, don't call RenderProcedureModifier -->
							<xsl:text>Shared </xsl:text>
						</xsl:if>
						<xsl:text>Sub New</xsl:text>
						<xsl:call-template name="RenderParams"/>
						<xsl:for-each select="plx:initialize/child::plx:callThis">
							<xsl:variable name="accessor" select="string(@accessor)"/>
							<xsl:variable name="callNameFragment">
								<xsl:choose>
									<xsl:when test="string-length($accessor)=0 or $accessor='this'">
										<xsl:text>Me.New</xsl:text>
									</xsl:when>
									<xsl:when test="$accessor='base'">
										<xsl:text>MyBase.New</xsl:text>
									</xsl:when>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="callName" select="string($callNameFragment)"/>
							<xsl:if test="$callName">
								<xsl:value-of select="$NewLine"/>
								<xsl:value-of select="$Indent"/>
								<xsl:value-of select="$SingleIndent"/>
								<xsl:call-template name="RenderCallBody">
									<xsl:with-param name="Indent" select="concat($Indent,$SingleIndent)"/>
									<xsl:with-param name="Unqualified" select="true()"/>
									<xsl:with-param name="Name" select="$callName"/>
								</xsl:call-template>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="$name='.finalize'">
						<xsl:text>Protected Overrides Sub Finalize()</xsl:text>
						<xsl:value-of select="$NewLine"/>
						<xsl:value-of select="$Indent"/>
						<xsl:value-of select="$SingleIndent"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="returns" select="plx:returns"/>
				<xsl:if test="not(parent::plx:interface)">
					<xsl:call-template name="RenderVisibility"/>
					<xsl:call-template name="RenderOverload"/>
					<xsl:call-template name="RenderProcedureModifier"/>
				</xsl:if>
				<xsl:call-template name="RenderReplacesName"/>
				<xsl:choose>
					<xsl:when test="$returns">
						<xsl:text>Function </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Sub </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="@name"/>
				<xsl:variable name="typeParams" select="plx:typeParam"/>
				<xsl:if test="$typeParams">
					<xsl:call-template name="RenderTypeParams">
						<xsl:with-param name="TypeParams" select="$typeParams"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:call-template name="RenderParams"/>
				<xsl:if test="$returns">
					<xsl:for-each select="$returns">
						<xsl:text> As </xsl:text>
						<xsl:call-template name="RenderAttributes">
							<xsl:with-param name="Indent" select="$Indent"/>
							<xsl:with-param name="Inline" select="true()"/>
						</xsl:call-template>
						<xsl:call-template name="RenderType"/>
					</xsl:for-each>
				</xsl:if>
				<xsl:call-template name="RenderInterfaceMembers">
					<xsl:with-param name="Indent" select="$Indent"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:function" mode="IndentInfo">
		<xsl:variable name="closeName">
			<xsl:choose>
				<xsl:when test="plx:returns">
					<xsl:text>End Function</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>End Sub</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="string($closeName)"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:get">
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderAttributes">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:call-template>
		<xsl:call-template name="RenderVisibility"/>
		<xsl:text>Get</xsl:text>
	</xsl:template>
	<xsl:template match="plx:get" mode="IndentInfo">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="'End Get'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:goto">
		<xsl:param name="Indent"/>
		<xsl:text>GoTo </xsl:text>
		<xsl:value-of select="@name"/>
	</xsl:template>
	<xsl:template match="plx:gotoCase">
		<xsl:param name="LocalItemKey"/>
		<xsl:param name="CaseLabels"/>
		<xsl:text>GoTo </xsl:text>
		<xsl:value-of select="$AutoLabelPrefix"/>
		<xsl:variable name="renderedCondition">
			<xsl:apply-templates select="plx:condition/child::*">
				<xsl:with-param name="Indent" select="''"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="caseLabelMatch" select="$CaseLabels[@condition=string($renderedCondition)]"/>
		<xsl:choose>
			<xsl:when test="$caseLabelMatch">
				<xsl:value-of select="$caseLabelMatch/@key"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>_UNMATCHED_CONDITION 'condition = </xsl:text>
				<xsl:value-of select="$renderedCondition"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:increment">
		<xsl:param name="Indent"/>
		<!-- UNDONE: Can we always render like this, or only for nameRef and call* type='field' -->
		<xsl:apply-templates select="child::*">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:apply-templates>
		<xsl:text> = </xsl:text>
		<xsl:apply-templates select="child::*" mode="ResolvePrecedence">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="Context" select="."/>
		</xsl:apply-templates>
		<xsl:text> + 1</xsl:text>
	</xsl:template>
	<xsl:template match="plx:interface">
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderTypeDefinition">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="TypeKeyword" select="'Interface'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:interface" mode="IndentInfo">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="'End Interface'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:iterator">
		<xsl:param name="Indent"/>
		<xsl:text>For Each </xsl:text>
		<xsl:value-of select="@localName"/>
		<xsl:text> As </xsl:text>
		<xsl:call-template name="RenderType"/>
		<xsl:text> In </xsl:text>
		<xsl:for-each select="plx:initialize">
			<xsl:apply-templates select="child::*">
				<xsl:with-param name="Indent" select="$Indent"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="plx:iterator" mode="IndentInfo">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="'Next'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:label">
		<xsl:param name="Indent"/>
		<xsl:value-of select="@name"/>
		<xsl:text>:</xsl:text>
	</xsl:template>
	<xsl:template match="plx:local">
		<xsl:param name="Indent"/>
		<xsl:param name="const" select="@const"/>
		<xsl:choose>
			<xsl:when test="$const='true' or $const='1'">
				<xsl:text>Const </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Dim </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="@name"/>
		<xsl:text> As </xsl:text>
		<xsl:call-template name="RenderType"/>
		<xsl:for-each select="plx:initialize">
			<xsl:text> = </xsl:text>
			<xsl:apply-templates select="child::*">
				<xsl:with-param name="Indent" select="$Indent"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="plx:lock">
		<xsl:param name="Indent"/>
		<xsl:text>SyncLock</xsl:text>
		<xsl:for-each select="plx:initialize">
			<xsl:apply-templates select="child::*">
				<xsl:with-param name="Indent" select="$Indent"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="plx:lock" mode="IndentInfo">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="'End SyncLock'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:loop">
		<xsl:param name="Indent"/>
		<xsl:variable name="initialize" select="plx:initializeLoop/child::plx:*"/>
		<xsl:variable name="condition" select="plx:condition/child::plx:*"/>
		<xsl:choose>
			<xsl:when test="@checkCondition='after' and $condition">
				<xsl:if test="$initialize">
					<xsl:apply-templates select="$initialize">
						<xsl:with-param name="Indent" select="$Indent"/>
					</xsl:apply-templates>
					<xsl:text>;</xsl:text>
					<xsl:value-of select="$NewLine"/>
					<xsl:value-of select="$Indent"/>
				</xsl:if>
				<xsl:text>Do</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$initialize">
					<xsl:apply-templates select="$initialize">
						<xsl:with-param name="Indent" select="$Indent"/>
					</xsl:apply-templates>
					<xsl:value-of select="$NewLine"/>
					<xsl:value-of select="$Indent"/>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$condition">
						<xsl:text>While </xsl:text>
						<xsl:apply-templates select="$condition">
							<xsl:with-param name="Indent" select="$Indent"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>While True</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<!-- UNDONE: Recognize patterns for VB's for loop. -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:loop" mode="IndentInfo">
		<xsl:choose>
			<xsl:when test="(@checkCondition='after' and plx:condition) or plx:beforeLoop">
				<xsl:call-template name="CustomizeIndentInfo">
					<xsl:with-param name="defaultInfo">
						<xsl:apply-imports/>
					</xsl:with-param>
					<xsl:with-param name="closeBlockCallback" select="true()"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="CustomizeIndentInfo">
					<xsl:with-param name="defaultInfo">
						<xsl:apply-imports/>
					</xsl:with-param>
					<xsl:with-param name="closeWith" select="'End While'"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:loop" mode="CloseBlock">
		<xsl:param name="Indent"/>
		<xsl:param name="StandardCloseWith"/>
		<xsl:variable name="beforeLoop" select="plx:beforeLoop/child::plx:*"/>
		<xsl:variable name="condition" select="plx:condition/child::plx:*"/>
		<xsl:for-each select="$beforeLoop">
			<xsl:value-of select="$SingleIndent"/>
			<xsl:call-template name="RenderElement">
				<xsl:with-param name="Indent" select="$Indent"/>
				<xsl:with-param name="Statement" select="true()"/>
				<xsl:with-param name="SkipLeadingIndent" select="true()"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="@checkCondition='after' and $condition">
				<xsl:text>Loop While </xsl:text>
				<xsl:apply-templates select="plx:condition/child::plx:*">
					<xsl:with-param name="Indent" select="$Indent"/>
				</xsl:apply-templates>
				<xsl:value-of select="$NewLine"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>End While</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$NewLine"/>
	</xsl:template>
	<xsl:template match="plx:nameRef">
		<xsl:value-of select="@name"/>
	</xsl:template>
	<xsl:template match="plx:namespace">
		<xsl:text>Namespace </xsl:text>
		<xsl:value-of select="@name"/>
	</xsl:template>
	<xsl:template match="plx:namespace" mode="IndentInfo">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="'End Namespace'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:namespaceImport">
		<xsl:text>Imports </xsl:text>
		<xsl:if test="string-length(@alias)">
			<xsl:value-of select="@alias"/>
			<xsl:text> = </xsl:text>
		</xsl:if>
		<xsl:value-of select="@name"/>
	</xsl:template>
	<xsl:template match="plx:nullKeyword">
		<xsl:text>Nothing</xsl:text>
	</xsl:template>
	<xsl:template match="plx:onAdd">
		<xsl:text>AddHandler(</xsl:text>
		<xsl:call-template name="RenderAttributes">
			<xsl:with-param name="Inline" select="true()"/>
			<xsl:with-param name="TypeFilter" select="'implicitValueParameter'"/>
		</xsl:call-template>
		<xsl:text>ByVal value As </xsl:text>
		<xsl:for-each select="parent::plx:event/plx:explicitDelegateType">
			<xsl:call-template name="RenderType">
				<xsl:with-param name="ExplicitPassTypeParams" select="following-sibling::plx:passTypeParam"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:text>)</xsl:text>
	</xsl:template>
	<xsl:template match="plx:onAdd" mode="IndentInfo">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="'End AddHandler'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:onRemove">
		<xsl:text>RemoveHandler(</xsl:text>
		<xsl:call-template name="RenderAttributes">
			<xsl:with-param name="Inline" select="true()"/>
			<xsl:with-param name="TypeFilter" select="'implicitValueParameter'"/>
		</xsl:call-template>
		<xsl:text>ByVal value As </xsl:text>
		<xsl:for-each select="parent::plx:event/plx:explicitDelegateType">
			<xsl:call-template name="RenderType">
				<xsl:with-param name="ExplicitPassTypeParams" select="following-sibling::plx:passTypeParam"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:text>)</xsl:text>
	</xsl:template>
	<xsl:template match="plx:onRemove" mode="IndentInfo">
		<xsl:choose>
			<xsl:when test="following-sibling::plx:onFire[1]">
				<xsl:call-template name="CustomizeIndentInfo">
					<xsl:with-param name="defaultInfo">
						<xsl:apply-imports/>
					</xsl:with-param>
					<xsl:with-param name="closeWith" select="'End RemoveHandler'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="CustomizeIndentInfo">
					<xsl:with-param name="defaultInfo">
						<xsl:apply-imports/>
					</xsl:with-param>
					<xsl:with-param name="closeBlockCallback" select="true()"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:onRemove" mode="CloseBlock">
		<!-- onAdd and onRemove always appear together, but onFire is optional in the plix schema.
		     If this is called, then we need to spit a dummy RaiseEvent for VB to compile -->
		<xsl:param name="Indent"/>
		<xsl:text>End RemoveHandler</xsl:text>
		<xsl:value-of select="$NewLine"/>
		<xsl:value-of select="$Indent"/>
		<xsl:text>RaiseEvent</xsl:text>
		<xsl:for-each select="..">
			<xsl:call-template name="RenderParams"/>
		</xsl:for-each>
		<xsl:value-of select="$NewLine"/>
		<xsl:value-of select="$Indent"/>
		<xsl:text>End RaiseEvent</xsl:text>
		<xsl:value-of select="$NewLine"/>
	</xsl:template>
	<xsl:template match="plx:operatorFunction">
		<xsl:param name="Indent"/>
		<xsl:variable name="operatorType" select="string(@type)"/>
		<xsl:variable name="operatorNameFragment">
			<xsl:choose>
				<xsl:when test="$operatorType='add'">
					<xsl:text>+</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='bitwiseAnd'">
					<xsl:text>And</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='bitwiseExclusiveOr'">
					<xsl:text>Xor</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='bitwiseNot'">
					<xsl:text>Not</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='bitwiseOr'">
					<xsl:text>Or</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='booleanNot'">
					<xsl:text>op_LogicalNot</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='castNarrow'">
					<xsl:text>CType.Narrowing</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='castWiden'">
					<xsl:text>CType.Widening</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='decrement'">
					<xsl:text>op_Decrement</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='divide'">
					<xsl:text>/</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='equality'">
					<xsl:text>=</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='greaterThan'">
					<xsl:text>&gt;</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='greaterThanOrEqual'">
					<xsl:text>&gt;=</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='increment'">
					<xsl:text>op_Increment</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='inequality'">
					<xsl:text>&lt;&gt;</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='integerDivide'">
					<xsl:text>\</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='isFalse'">
					<xsl:text>IsFalse</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='isTrue'">
					<xsl:text>IsTrue</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='lessThan'">
					<xsl:text>&lt;</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='lessThanOrEqual'">
					<xsl:text>&lt;=</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='like'">
					<xsl:text>Like</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='modulus'">
					<xsl:text>Mod</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='multiply'">
					<xsl:text>*</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='negative'">
					<xsl:text>-</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='positive'">
					<xsl:text>+</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='shiftLeft'">
					<xsl:text>&lt;&lt;</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='shiftRight'">
					<xsl:text>&gt;&gt;</xsl:text>
				</xsl:when>
				<xsl:when test="$operatorType='subtract'">
					<xsl:text>-</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="operatorName" select="string($operatorNameFragment)"/>
		<xsl:choose>
			<xsl:when test="starts-with($operatorName,'op_')">
				<!-- Occurs when the operator is not one that VB does automatically. These can still be
					 implemented to look like the operator, but we need to add the additional
					 System.Runtime.CompilerServices.SpecialName attribute -->
				<xsl:variable name="modifiedAttributesFragment">
					<xsl:copy-of select="plx:attribute"/>
					<plx:attribute dataTypeName="SpecialName" dataTypeQualifier="System.Runtime.CompilerServices"/>
				</xsl:variable>
				<xsl:for-each select="exsl:node-set($modifiedAttributesFragment)">
					<xsl:call-template name="RenderAttributes">
						<xsl:with-param name="Indent" select="$Indent"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="RenderAttributes">
					<xsl:with-param name="Indent" select="$Indent"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="returns" select="plx:returns"/>
		<xsl:for-each select="$returns">
			<xsl:call-template name="RenderAttributes">
				<xsl:with-param name="Indent" select="$Indent"/>
				<xsl:with-param name="Prefix" select="'returns:'"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:text>Public </xsl:text>
		<xsl:call-template name="RenderOverload"/>
		<xsl:text>Shared </xsl:text>
		<xsl:call-template name="RenderReplacesName"/>
		<xsl:choose>
			<xsl:when test="starts-with($operatorName, 'CType.')">
				<xsl:value-of select="substring($operatorName, 7)"/>
				<xsl:text> Operator CType</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="starts-with($operatorName, 'op_')">
						<xsl:text>Function </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Operator </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$operatorName"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="RenderParams"/>
		<xsl:for-each select="plx:returns">
			<xsl:text> As </xsl:text>
			<xsl:call-template name="RenderAttributes">
				<xsl:with-param name="Indent" select="$Indent"/>
				<xsl:with-param name="Inline" select="true()"/>
			</xsl:call-template>
			<xsl:call-template name="RenderType"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="plx:operatorFunction" mode="IndentInfo">
		<xsl:variable name="closeName">
			<xsl:variable name="operatorType" select="string(@type)"/>
			<xsl:choose>
				<xsl:when test="$operatorType='booleanNot' or $operatorType='decrement' or $operatorType='increment'">
					<!-- These operator types do not render natively, so we render them as
						 specially attributed functions instead -->
					<xsl:text>End Function</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>End Operator</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="string($closeName)"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:pragma">
		<xsl:variable name="type" select="string(@type)"/>
		<xsl:variable name="data" select="string(@data)"/>
		<xsl:choose>
			<xsl:when test="$type='alternateConditional'">
				<xsl:text>#ElseIf </xsl:text>
				<xsl:value-of select="$data"/>
			</xsl:when>
			<xsl:when test="$type='alternateNotConditional'">
				<xsl:text>#ElseIf Not </xsl:text>
				<xsl:value-of select="$data"/>
			</xsl:when>
			<xsl:when test="$type='conditional'">
				<xsl:text>#If </xsl:text>
				<xsl:value-of select="$data"/>
			</xsl:when>
			<xsl:when test="$type='closeConditional'">
				<xsl:text>#End If</xsl:text>
				<xsl:if test="string-length($data)">
					<xsl:text> '</xsl:text>
					<xsl:value-of select="$data"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$type='closeRegion'">
				<xsl:text>#End Region</xsl:text>
				<!-- This looks weird in the VB editor when the region is collapsed, don't do it -->
				<!--<xsl:if test="string-length($data)">
					<xsl:text> '</xsl:text>
					<xsl:value-of select="$data"/>
				</xsl:if>-->
			</xsl:when>
			<xsl:when test="$type='fallbackConditional'">
				<xsl:text>#Else</xsl:text>
				<xsl:if test="string-length($data)">
					<xsl:text> '</xsl:text>
					<xsl:value-of select="$data"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$type='notConditional'">
				<xsl:text>#If Not </xsl:text>
				<xsl:value-of select="$data"/>
			</xsl:when>
			<xsl:when test="$type='region'">
				<xsl:text>#Region </xsl:text>
				<xsl:call-template name="RenderString">
					<xsl:with-param name="String" select="$data"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:property">
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderAttributes">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:call-template>
		<xsl:variable name="name" select="@name"/>
		<xsl:if test="parent::plx:*/@defaultMember=$name">
			<xsl:text>Default </xsl:text>
		</xsl:if>
		<xsl:if test="not(parent::plx:interface)">
			<xsl:call-template name="RenderVisibility"/>
			<xsl:call-template name="RenderProcedureModifier"/>
		</xsl:if>
		<xsl:call-template name="RenderReplacesName"/>
		<xsl:if test="not(plx:get)">
			<xsl:text>WriteOnly </xsl:text>
		</xsl:if>
		<xsl:if test="not(plx:set)">
			<xsl:text>ReadOnly </xsl:text>
		</xsl:if>
		<xsl:text>Property </xsl:text>
		<xsl:value-of select="$name"/>
		<xsl:variable name="typeParams" select="plx:typeParam"/>
		<xsl:if test="$typeParams">
			<xsl:call-template name="RenderTypeParams">
				<xsl:with-param name="TypeParams" select="$typeParams"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="RenderParams"/>
		<xsl:for-each select="plx:returns">
			<xsl:text> As </xsl:text>
			<xsl:call-template name="RenderAttributes">
				<xsl:with-param name="Indent" select="$Indent"/>
				<xsl:with-param name="Inline" select="true()"/>
			</xsl:call-template>
			<xsl:call-template name="RenderType"/>
		</xsl:for-each>
		<xsl:call-template name="RenderInterfaceMembers">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:property" mode="IndentInfo">
		<xsl:variable name="isAbstract">
			<xsl:choose>
				<xsl:when test="@modifier='abstract'">
					<xsl:text>x</xsl:text>
				</xsl:when>
				<xsl:when test="@modifier='abstractOverride'">
					<xsl:text>x</xsl:text>
				</xsl:when>
				<xsl:when test="parent::plx:interface">
					<xsl:text>x</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($isAbstract)">
				<xsl:call-template name="CustomizeIndentInfo">
					<xsl:with-param name="defaultInfo">
						<xsl:apply-imports/>
					</xsl:with-param>
					<xsl:with-param name="style" select="'simpleMember'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="CustomizeIndentInfo">
					<xsl:with-param name="defaultInfo">
						<xsl:apply-imports/>
					</xsl:with-param>
					<xsl:with-param name="closeWith" select="'End Property'"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:return">
		<xsl:param name="Indent"/>
		<xsl:variable name="retVal" select="child::*"/>
		<xsl:text>Return</xsl:text>
		<xsl:if test="$retVal">
			<xsl:text> </xsl:text>
			<xsl:apply-templates select="$retVal">
				<xsl:with-param name="Indent" select="$Indent"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	<xsl:template match="plx:set">
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderAttributes">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:call-template>
		<xsl:call-template name="RenderVisibility"/>
		<xsl:text>Set(</xsl:text>
		<xsl:call-template name="RenderAttributes">
			<xsl:with-param name="Inline" select="true()"/>
			<xsl:with-param name="TypeFilter" select="'implicitValueParameter'"/>
		</xsl:call-template>
		<xsl:text>ByVal value As </xsl:text>
		<xsl:for-each select="parent::plx:property/plx:returns">
			<xsl:call-template name="RenderType"/>
		</xsl:for-each>
		<xsl:text>)</xsl:text>
	</xsl:template>
	<xsl:template match="plx:set" mode="IndentInfo">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="'End Set'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:string">
		<xsl:variable name="rawValue">
			<xsl:call-template name="RenderRawString"/>
		</xsl:variable>
		<xsl:call-template name="RenderString">
			<xsl:with-param name="String" select="string($rawValue)"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:structure">
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderTypeDefinition">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="TypeKeyword" select="'Structure'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:structure" mode="IndentInfo">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="'End Structure'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:switch">
		<xsl:param name="Indent"/>
		<xsl:text>Select Case </xsl:text>
		<xsl:apply-templates select="plx:condition/child::*">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="plx:switch" mode="IndentInfo">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="'End Select'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:thisKeyword">
		<xsl:text>Me</xsl:text>
	</xsl:template>
	<xsl:template match="plx:throw">
		<xsl:param name="Indent"/>
		<xsl:text>Throw</xsl:text>
		<xsl:for-each select="child::plx:*">
			<xsl:text> </xsl:text>
			<xsl:apply-templates select=".">
				<xsl:with-param name="Indent" select="$Indent"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="plx:trueKeyword">
		<xsl:text>True</xsl:text>
	</xsl:template>
	<xsl:template match="plx:try">
		<xsl:text>Try</xsl:text>
	</xsl:template>
	<xsl:template match="plx:try" mode="IndentInfo">
		<xsl:call-template name="CustomizeIndentInfo">
			<xsl:with-param name="defaultInfo">
				<xsl:apply-imports/>
			</xsl:with-param>
			<xsl:with-param name="closeWith" select="'End Try'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:typeOf">
		<xsl:text>GetType(</xsl:text>
		<xsl:call-template name="RenderType"/>
		<xsl:text>)</xsl:text>
	</xsl:template>
	<xsl:template match="plx:unaryOperator">
		<xsl:param name="Indent"/>
		<xsl:variable name="type" select="string(@type)"/>
		<xsl:choose>
			<xsl:when test="$type='booleanNot'">
				<xsl:text>Not </xsl:text>
			</xsl:when>
			<xsl:when test="$type='bitwiseNot'">
				<xsl:text>Not </xsl:text>
			</xsl:when>
			<xsl:when test="$type='negative'">
				<xsl:text>-</xsl:text>
			</xsl:when>
			<xsl:when test="$type='positive'">
				<xsl:text>+</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates select="child::*" mode="ResolvePrecedence">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="Context" select="."/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="plx:value">
		<xsl:variable name="type" select="string(@type)"/>
		<xsl:choose>
			<xsl:when test="$type='char'">
				<xsl:text>&quot;</xsl:text>
				<xsl:value-of select="@data"/>
				<xsl:text>&quot;c</xsl:text>
			</xsl:when>
			<xsl:when test="$type='hex2' or $type='hex4' or $type='hex8'">
				<xsl:text>&amp;H</xsl:text>
				<xsl:value-of select="@data"/>
				<xsl:if test="$type='hex2'">
					<xsl:text>S</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@data"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="plx:valueKeyword">
		<xsl:variable name="stringize" select="string(@stringize)"/>
		<xsl:choose>
			<xsl:when test="$stringize='1' or $stringize='true'">
				<xsl:text>"value"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>value</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- TopLevel templates, used for rendering snippets only -->
	<xsl:template match="plx:arrayDescriptor" mode="TopLevel">
		<xsl:call-template name="RenderArrayDescriptor"/>
	</xsl:template>
	<xsl:template match="plx:arrayInitializer">
		<!-- Note not TopLevel to allow inline expansion -->
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderArrayInitializer">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:derivesFromClass" mode="TopLevel">
		<xsl:text>Inherits </xsl:text>
		<xsl:call-template name="RenderType"/>
	</xsl:template>
	<xsl:template match="plx:implementsInterface" mode="TopLevel">
		<xsl:text>Implements </xsl:text>
		<xsl:call-template name="RenderType"/>
	</xsl:template>
	<xsl:template match="plx:interfaceMember" mode="TopLevel">
		<xsl:text>Implements </xsl:text>
		<xsl:call-template name="RenderType"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="@name"/>
	</xsl:template>
	<xsl:template match="plx:passTypeParam|plx:passMemberTypeParam|plx:explicitDelegateType|plx:typeConstraint" mode="TopLevel">
		<xsl:call-template name="RenderType"/>
	</xsl:template>
	<xsl:template match="plx:parametrizedDataTypeQualifier" mode="TopLevel">
		<xsl:call-template name="RenderType">
			<!-- No reason to check for an array here -->
			<xsl:with-param name="RenderArray" select="false()"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:passParam">
		<!-- Note not TopLevel to allow inline expansion -->
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderPassParams">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="PassParams" select="."/>
			<xsl:with-param name="BracketPair" select="''"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:passParamArray">
		<!-- Note not TopLevel to allow inline expansion -->
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderPassParams">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="PassParams" select="plx:passParam"/>
			<xsl:with-param name="BracketPair" select="''"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="plx:param" mode="TopLevel">
		<xsl:for-each select="..">
			<xsl:call-template name="RenderParams">
				<xsl:with-param name="BracketPair" select="''"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="plx:returns" mode="TopLevel">
		<xsl:param name="Indent"/>
		<xsl:text>As </xsl:text>
		<xsl:call-template name="RenderAttributes">
			<xsl:with-param name="Indent" select="$Indent"/>
			<xsl:with-param name="Inline" select="true()"/>
		</xsl:call-template>
		<xsl:call-template name="RenderType"/>
	</xsl:template>
	<xsl:template match="plx:typeParam" mode="TopLevel">
		<xsl:param name="Indent"/>
		<xsl:call-template name="RenderTypeParams">
			<xsl:with-param name="TypeParams" select="."/>
		</xsl:call-template>
	</xsl:template>

	<!-- Named templates -->
	<xsl:template name="RepeatString">
		<xsl:param name="Count"/>
		<xsl:param name="String"/>
		<xsl:value-of select="$String"/>
		<xsl:if test="$Count &gt; 1">
			<xsl:call-template name="RepeatString">
				<xsl:with-param name="Count" select="$Count - 1"/>
				<xsl:with-param name="String" select="$String"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<xsl:template name="RenderAttribute">
		<xsl:param name="Indent"/>
		<xsl:variable name="rawAttributeName" select="@dataTypeName"/>
		<xsl:variable name="attributeNameFragment">
			<xsl:choose>
				<xsl:when test="string-length($rawAttributeName)&gt;9 and contains($rawAttributeName,'Attribute')">
					<xsl:choose>
						<xsl:when test="substring-after($rawAttributeName,'Attribute')">
							<xsl:value-of select="$rawAttributeName"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring($rawAttributeName, 1, string-length($rawAttributeName)-9)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$rawAttributeName"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="RenderType">
			<xsl:with-param name="DataTypeName" select="string($attributeNameFragment)"/>
		</xsl:call-template>
		<!-- Make sure any named arguments go last. This cannot be controlled 100% by the caller
			 because passParamArray always comes after passParam. -->
		<xsl:variable name="namedParameters" select="plx:passParam[plx:binaryOperator[@type='assignNamed']]"/>
		<xsl:choose>
			<xsl:when test="$namedParameters">
				<xsl:variable name="reorderedPassParamsFragment">
					<xsl:copy-of select="plx:passParam[not(plx:binaryOperator[@type='assignNamed'])]|plx:passParamArray/plx:passParam"/>
					<xsl:copy-of select="$namedParameters"/>
				</xsl:variable>
				<xsl:call-template name="RenderPassParams">
					<xsl:with-param name="Indent" select="$Indent"/>
					<xsl:with-param name="PassParams" select="exsl:node-set($reorderedPassParamsFragment)/child::*"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="RenderPassParams">
					<xsl:with-param name="Indent" select="$Indent"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="RenderAttributes">
		<xsl:param name="Indent"/>
		<xsl:param name="Inline" select="false()"/>
		<xsl:param name="Prefix" select="''"/>
		<xsl:param name="TypeFilter" select="''"/>
		<xsl:choose>
			<xsl:when test="$Inline">
				<!-- Put them all in a single bracket -->
				<xsl:for-each select="plx:attribute[@type=$TypeFilter]">
					<xsl:choose>
						<xsl:when test="position()=1">
							<xsl:text>&lt;</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>, </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="$Prefix"/>
					<xsl:call-template name="RenderAttribute">
						<xsl:with-param name="Indent" select="$Indent"/>
					</xsl:call-template>
					<xsl:if test="position()=last()">
						<xsl:text>&gt; </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="plx:attribute[@type=$TypeFilter]">
					<xsl:text>&lt;</xsl:text>
					<xsl:value-of select="$Prefix"/>
					<xsl:call-template name="RenderAttribute">
						<xsl:with-param name="Indent" select="$Indent"/>
					</xsl:call-template>
					<xsl:text>&gt;</xsl:text>
					<xsl:text> _</xsl:text>
					<xsl:value-of select="$NewLine"/>
					<xsl:value-of select="$Indent"/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="RenderArrayDescriptor">
		<xsl:text>(</xsl:text>
		<xsl:if test="@rank &gt; 1">
			<xsl:call-template name="RepeatString">
				<xsl:with-param name="Count" select="@rank - 1"/>
				<xsl:with-param name="String" select="','"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:text>)</xsl:text>
		<xsl:for-each select="plx:arrayDescriptor">
			<xsl:call-template name="RenderArrayDescriptor"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="RenderArrayInitializer">
		<xsl:param name="Indent"/>
		<xsl:variable name="nestedInitializers" select="plx:arrayInitializer"/>
		<xsl:variable name="nextIndent" select="concat($Indent,$SingleIndent)"/>
		<!-- We either get nested expressions or nested initializers, but not both -->
		<xsl:choose>
			<xsl:when test="$nestedInitializers">
				<xsl:text>{</xsl:text>
				<xsl:for-each select="$nestedInitializers">
					<xsl:if test="position()!=1">
						<xsl:text>, _</xsl:text>
					</xsl:if>
					<xsl:value-of select="$NewLine"/>
					<xsl:value-of select="$nextIndent"/>
					<xsl:call-template name="RenderArrayInitializer">
						<xsl:with-param name="Indent" select="$nextIndent"/>
					</xsl:call-template>
				</xsl:for-each>
				<xsl:text>}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="RenderExpressionList">
					<xsl:with-param name="Indent" select="$nextIndent"/>
					<xsl:with-param name="BracketPair" select="'{}'"/>
					<xsl:with-param name="BeforeFirstItem" select="concat(' _',$NewLine,$nextIndent)"/>
					<xsl:with-param name="ListSeparator" select="concat(', _',$NewLine,$nextIndent)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="RenderCallBody">
		<xsl:param name="Indent"/>
		<!-- Helper function to render most of a call. The caller has already
			 been set before this call -->
		<xsl:param name="Unqualified" select="false()"/>
		<xsl:param name="Name" select="@name"/>
		<!-- Render the name -->
		<xsl:variable name="callType" select="string(@type)"/>
		<xsl:variable name="isIndexer" select="$callType='indexerCall' or $callType='arrayIndexer'"/>
		<xsl:if test="not($Name='.implied') and not($isIndexer)">
			<xsl:if test="not($Unqualified)">
				<xsl:text>.</xsl:text>
			</xsl:if>
			<xsl:value-of select="$Name"/>
		</xsl:if>
		<!-- Add member type params -->
		<xsl:call-template name="RenderPassTypeParams">
			<xsl:with-param name="PassTypeParams" select="plx:passMemberTypeParam"/>
		</xsl:call-template>

		<xsl:variable name="passParams" select="plx:passParam | plx:passParamArray/plx:passParam"/>
		<xsl:variable name="hasParams" select="boolean($passParams)"/>
		<xsl:variable name="bracketPair">
			<xsl:choose>
				<xsl:when test="string-length($callType)=0 or $callType='methodCall' or $callType='delegateCall' or $isIndexer">
					<xsl:text>()</xsl:text>
				</xsl:when>
				<xsl:when test="$callType='property'">
					<xsl:if test="$hasParams">
						<xsl:text>()</xsl:text>
					</xsl:if>
				</xsl:when>
				<!-- field, event, methodReference handled with silence-->
				<!-- UNDONE: fireStandardEvent, fireCustomEvent -->
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$bracketPair">
			<xsl:choose>
				<xsl:when test="$hasParams">
					<xsl:call-template name="RenderPassParams">
						<xsl:with-param name="Indent" select="$Indent"/>
						<xsl:with-param name="PassParams" select="$passParams"/>
						<xsl:with-param name="BracketPair" select="$bracketPair"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$bracketPair"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<xsl:template name="RenderClassModifier">
		<xsl:param name="Modifier" select="@modifier"/>
		<xsl:choose>
			<xsl:when test="$Modifier='sealed'">
				<xsl:text>NotInheritable </xsl:text>
			</xsl:when>
			<xsl:when test="$Modifier='abstract'">
				<xsl:text>MustInherit </xsl:text>
			</xsl:when>
			<xsl:when test="$Modifier='static'">
				<!-- UNDONE: VB static class needs a parameterless private constructor -->
				<xsl:text>NotInheritable </xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="RenderConst">
		<xsl:param name="Const" select="@const"/>
		<xsl:if test="$Const='true' or $Const='1'">
			<xsl:text>Const </xsl:text>
		</xsl:if>
	</xsl:template>
	<xsl:template name="RenderExpressionList">
		<xsl:param name="Indent"/>
		<xsl:param name="Expressions" select="child::plx:*"/>
		<xsl:param name="BracketPair" select="'()'"/>
		<xsl:param name="ListSeparator" select="', '"/>
		<xsl:param name="BeforeFirstItem" select="''"/>
		<xsl:param name="PrecedenceContext"/>
		<xsl:variable name="hasPrecedenceContext" select="boolean($PrecedenceContext)"/>
		<xsl:value-of select="substring($BracketPair,1,1)"/>
		<xsl:for-each select="$Expressions">
			<xsl:choose>
				<xsl:when test="position()=1">
					<xsl:value-of select="$BeforeFirstItem"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$ListSeparator"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="$hasPrecedenceContext">
					<xsl:apply-templates select="." mode="ResolvePrecedence">
						<xsl:with-param name="Indent" select="$Indent"/>
						<xsl:with-param name="Context" select="$PrecedenceContext"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select=".">
						<xsl:with-param name="Indent" select="$Indent"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:value-of select="substring($BracketPair,2)"/>
	</xsl:template>
	<xsl:template name="RenderInterfaceMembers">
		<xsl:param name="Indent"/>
		<xsl:for-each select="plx:interfaceMember">
			<xsl:choose>
				<xsl:when test="position()=1">
					<xsl:text> Implements</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>,</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text> _</xsl:text>
			<xsl:value-of select="$NewLine"/>
			<xsl:value-of select="$Indent"/>
			<xsl:value-of select="$SingleIndent"/>
			<xsl:call-template name="RenderType"/>
			<xsl:text>.</xsl:text>
			<xsl:value-of select="@memberName"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="RenderOverload">
		<xsl:param name="Overload" select="@overload"/>
		<xsl:if test="$Overload='true' or $Overload='1'">
			<xsl:text>Overloads </xsl:text>
		</xsl:if>
	</xsl:template>
	<xsl:template name="RenderParams">
		<xsl:param name="BracketPair" select="'()'"/>
		<xsl:param name="RenderEmptyBrackets" select="true()"/>
		<xsl:variable name="params" select="plx:param"/>
		<xsl:choose>
			<xsl:when test="$params">
				<xsl:value-of select="substring($BracketPair,1,1)"/>
				<xsl:for-each select="$params">
					<xsl:if test="position()!=1">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:call-template name="RenderAttributes">
						<xsl:with-param name="Inline" select="true()"/>
					</xsl:call-template>
					<xsl:variable name="type" select="string(@type)"/>
					<xsl:choose>
						<xsl:when test="string-length($type)">
							<xsl:choose>
								<xsl:when test="$type='inOut'">
									<xsl:text>ByRef </xsl:text>
								</xsl:when>
								<xsl:when test="$type='out'">
									<xsl:text>&lt;System.Runtime.InteropServices.Out&gt; ByRef </xsl:text>
								</xsl:when>
								<xsl:when test="$type='in'">
									<xsl:text>ByVal </xsl:text>
								</xsl:when>
								<xsl:when test="$type='params'">
									<xsl:text>ParamArray </xsl:text>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>ByVal </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="@name"/>
					<xsl:text> As </xsl:text>
					<xsl:call-template name="RenderType"/>
				</xsl:for-each>
				<xsl:value-of select="substring($BracketPair,2,1)"/>
			</xsl:when>
			<xsl:when test="$RenderEmptyBrackets">
				<xsl:value-of select="$BracketPair"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="RenderPartial">
		<xsl:param name="Partial" select="@partial"/>
		<xsl:if test="$Partial='true' or $Partial='1'">
			<xsl:text>Partial </xsl:text>
		</xsl:if>
	</xsl:template>
	<xsl:template name="RenderPassTypeParams">
		<xsl:param name="PassTypeParams" select="plx:passTypeParam"/>
		<xsl:if test="$PassTypeParams">
			<xsl:text>(Of </xsl:text>
			<xsl:for-each select="$PassTypeParams">
				<xsl:if test="position()!=1">
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:call-template name="RenderType"/>
			</xsl:for-each>
			<xsl:text>)</xsl:text>
		</xsl:if>
	</xsl:template>
	<xsl:template name="RenderPassParams">
		<xsl:param name="Indent"/>
		<xsl:param name="PassParams" select="plx:passParam | plx:passParamArray/plx:passParam"/>
		<xsl:param name="BracketPair" select="'()'"/>
		<xsl:param name="ListSeparator" select="', '"/>
		<xsl:param name="BeforeFirstItem" select="''"/>
		<xsl:value-of select="substring($BracketPair,1,1)"/>
		<xsl:for-each select="$PassParams">
			<xsl:choose>
				<xsl:when test="position()=1">
					<xsl:value-of select="$BeforeFirstItem"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$ListSeparator"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="child::*">
				<xsl:with-param name="Indent" select="$Indent"/>
			</xsl:apply-templates>
		</xsl:for-each>
		<xsl:value-of select="substring($BracketPair,2)"/>
	</xsl:template>
	<xsl:template name="RenderProcedureModifier">
		<xsl:variable name="modifier" select="@modifier"/>
		<xsl:choose>
			<xsl:when test="$modifier='static'">
				<xsl:text>Shared </xsl:text>
			</xsl:when>
			<xsl:when test="$modifier='virtual'">
				<xsl:text>Overridable </xsl:text>
			</xsl:when>
			<xsl:when test="$modifier='abstract'">
				<xsl:text>MustOverride </xsl:text>
			</xsl:when>
			<xsl:when test="$modifier='override'">
				<xsl:text>Overrides </xsl:text>
			</xsl:when>
			<xsl:when test="$modifier='sealedOverride'">
				<xsl:variable name="parentModifier" select="string(parent::plx:*/@modifier)"/>
				<xsl:choose>
					<!-- Static doesn't make sense here, but plix schema does not block it -->
					<xsl:when test="$parentModifier='sealed' or $parentModifier='static'">
						<xsl:text>Overrides </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>NotOverridable Overrides </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$modifier='abstractOverride'">
				<xsl:text>MustOverride Overrides </xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="RenderReadOnly">
		<xsl:param name="ReadOnly" select="@readOnly"/>
		<xsl:if test="$ReadOnly='true' or $ReadOnly='1'">
			<xsl:text>ReadOnly </xsl:text>
		</xsl:if>
	</xsl:template>
	<xsl:template name="RenderReplacesName">
		<xsl:param name="ReplacesName" select="@replacesName"/>
		<xsl:if test="$ReplacesName='true' or $ReplacesName='1'">
			<xsl:text>Shadows </xsl:text>
		</xsl:if>
	</xsl:template>
	<xsl:template name="RenderStatic">
		<xsl:param name="Static" select="@static"/>
		<xsl:if test="$Static='true' or $Static='1'">
			<xsl:text>Shared </xsl:text>
		</xsl:if>
	</xsl:template>
	<xsl:template name="RenderString">
		<xsl:param name="String"/>
		<xsl:param name="AddQuotes" select="true()"/>
		<xsl:choose>
			<xsl:when test="string-length($String)">
				<xsl:choose>
					<xsl:when test="'&quot;'=substring($String,1,1)">
						<xsl:if test="$AddQuotes">
							<xsl:text>&quot;</xsl:text>
						</xsl:if>
						<xsl:text>&quot;&quot;</xsl:text>
						<xsl:call-template name="RenderString">
							<xsl:with-param name="String" select="substring($String,2)"/>
							<xsl:with-param name="AddQuotes" select="false()"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="before" select="substring-before($String,'&quot;')"/>
						<xsl:choose>
							<xsl:when test="string-length($before)">
								<xsl:if test="$AddQuotes">
									<xsl:text>&quot;</xsl:text>
								</xsl:if>
								<xsl:value-of select="$before"/>
								<xsl:text>&quot;&quot;</xsl:text>
								<xsl:call-template name="RenderString">
									<xsl:with-param name="String" select="substring($String,string-length($before)+2)"/>
									<xsl:with-param name="AddQuotes" select="false()"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="$AddQuotes">
									<xsl:text>&quot;</xsl:text>
								</xsl:if>
								<xsl:value-of select="$String"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$AddQuotes">
					<xsl:text>&quot;</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$AddQuotes">
				<xsl:text>&quot;&quot;</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="RenderType">
		<xsl:param name="RenderArray" select="true()"/>
		<xsl:param name="ExplicitPassTypeParams"/>
		<xsl:param name="DataTypeName" select="@dataTypeName"/>
		<xsl:variable name="rawTypeName" select="$DataTypeName"/>
		<xsl:choose>
			<xsl:when test="string-length($rawTypeName)">
				<!-- Spit the name for the raw type -->
				<xsl:choose>
					<xsl:when test="starts-with($rawTypeName,'.')">
						<xsl:choose>
							<xsl:when test="$rawTypeName='.i1'">
								<xsl:text>SByte</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.i2'">
								<xsl:text>Short</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.i4'">
								<xsl:text>Integer</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.i8'">
								<xsl:text>Long</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.u1'">
								<xsl:text>Byte</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.u2'">
								<xsl:text>UShort</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.u4'">
								<xsl:text>UInteger</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.u8'">
								<xsl:text>ULong</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.r4'">
								<xsl:text>Single</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.r8'">
								<xsl:text>Double</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.char'">
								<xsl:text>Char</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.decimal'">
								<xsl:text>Decimal</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.object'">
								<xsl:text>Object</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.boolean'">
								<xsl:text>Boolean</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.string'">
								<xsl:text>String</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.date'">
								<xsl:text>Date</xsl:text>
							</xsl:when>
							<xsl:when test="$rawTypeName='.unspecifiedTypeParam'"/>
							<xsl:when test="$rawTypeName='.global'"/>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="parametrizedQualifier" select="plx:parametrizedDataTypeQualifier"/>
						<xsl:choose>
							<xsl:when test="$parametrizedQualifier">
								<xsl:for-each select="$parametrizedQualifier">
									<xsl:call-template name="RenderType">
										<!-- No reason to check for an array here -->
										<xsl:with-param name="RenderArray" select="false()"/>
									</xsl:call-template>
								</xsl:for-each>
								<xsl:text>.</xsl:text>
								<xsl:value-of select="$rawTypeName"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="qualifier" select="@dataTypeQualifier"/>
								<xsl:choose>
									<xsl:when test="string-length($qualifier)">
										<xsl:choose>
											<xsl:when test="$qualifier='System'">
												<xsl:choose>
													<xsl:when test="$rawTypeName='SByte'">
														<xsl:text>SByte</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='Int16'">
														<xsl:text>Short</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='Int32'">
														<xsl:text>Integer</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='Int64'">
														<xsl:text>Long</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='Byte'">
														<xsl:text>Byte</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='UInt16'">
														<xsl:text>UShort</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='UInt32'">
														<xsl:text>UInteger</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='UInt64'">
														<xsl:text>ULong</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='Single'">
														<xsl:text>Single</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='Double'">
														<xsl:text>Double</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='Char'">
														<xsl:text>Char</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='Decimal'">
														<xsl:text>Decimal</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='Object'">
														<xsl:text>Object</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='Boolean'">
														<xsl:text>Boolean</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='String'">
														<xsl:text>String</xsl:text>
													</xsl:when>
													<xsl:when test="$rawTypeName='DateTime'">
														<xsl:text>Date</xsl:text>
													</xsl:when>
													<xsl:otherwise>
														<xsl:text>System.</xsl:text>
														<xsl:value-of select="$rawTypeName"/>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$qualifier"/>
												<xsl:text>.</xsl:text>
												<xsl:value-of select="$rawTypeName"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$rawTypeName"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>

				<!-- Deal with any type parameters -->
				<xsl:choose>
					<xsl:when test="$ExplicitPassTypeParams">
						<xsl:call-template name="RenderPassTypeParams">
							<xsl:with-param name="PassTypeParams" select="$ExplicitPassTypeParams"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="RenderPassTypeParams"/>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:if test="$RenderArray">
					<!-- Deal with array definitions. The explicit descriptor trumps the @dataTypeIsSimpleArray attribute -->
					<xsl:variable name="arrayDescriptor" select="plx:arrayDescriptor"/>
					<xsl:choose>
						<xsl:when test="$arrayDescriptor">
							<xsl:for-each select="$arrayDescriptor">
								<xsl:call-template name="RenderArrayDescriptor"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:when test="@dataTypeIsSimpleArray='true' or @dataTypeIsSimpleArray='1'">
							<xsl:text>()</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">Attempt to render an undefined data type</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="RenderTypeDefinition">
		<xsl:param name="Indent"/>
		<xsl:param name="TypeKeyword"/>
		<xsl:call-template name="RenderAttributes">
			<xsl:with-param name="Indent" select="$Indent"/>
		</xsl:call-template>
		<xsl:call-template name="RenderVisibility"/>
		<xsl:call-template name="RenderReplacesName"/>
		<xsl:call-template name="RenderClassModifier"/>
		<xsl:call-template name="RenderPartial"/>
		<xsl:value-of select="$TypeKeyword"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:variable name="typeParams" select="plx:typeParam"/>
		<xsl:if test="$typeParams">
			<xsl:call-template name="RenderTypeParams">
				<xsl:with-param name="TypeParams" select="$typeParams"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="baseClass" select="plx:derivesFromClass"/>
		<xsl:if test="$baseClass">
			<xsl:value-of select="$NewLine"/>
			<xsl:value-of select="$Indent"/>
			<xsl:value-of select="$SingleIndent"/>
			<xsl:text>Inherits </xsl:text>
			<xsl:for-each select="$baseClass">
				<xsl:call-template name="RenderType"/>
			</xsl:for-each>
		</xsl:if>
		<xsl:for-each select="plx:implementsInterface">
			<xsl:value-of select="$NewLine"/>
			<xsl:value-of select="$Indent"/>
			<xsl:value-of select="$SingleIndent"/>
			<xsl:choose>
				<xsl:when test="$TypeKeyword='Interface'">
					<xsl:text>Inherits </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Implements </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="RenderType"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="RenderTypeParamConstraint">
		<!-- Helper function for RenderTypeParam -->
		<!-- There are 4 constraint types c=class,s=structure,n=new,t=typed. Track them
			 for each type param so we know where to put the commas -->
		<xsl:variable name="typedConstraints" select="plx:typeConstraint"/>
		<xsl:variable name="constraintsFragment">
			<xsl:if test="$typedConstraints">
				<xsl:text>t</xsl:text>
			</xsl:if>
			<xsl:choose>
				<!-- class and struct are mutually exclusive -->
				<xsl:when test="@requireReferenceType='true' or @requireReferenceType='1'">
					<xsl:text>c</xsl:text>
				</xsl:when>
				<xsl:when test="@requireValueType='true' or @requireValueType='1'">
					<xsl:text>v</xsl:text>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="@requireDefaultConstructor='true' or @requireDefaultConstructor='1'">
				<xsl:text>n</xsl:text>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="constraints" select="string($constraintsFragment)"/>
		<xsl:if test="string-length($constraints)">
			<xsl:variable name="multipleConstraints" select="1&lt;string-length($constraints) or 1&lt;count($typedConstraints)"/>
			<xsl:text> As </xsl:text>
			<xsl:if test="$multipleConstraints">
				<xsl:text>{</xsl:text>
			</xsl:if>
			<xsl:for-each select="$typedConstraints">
				<xsl:if test="position()!=1">
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:call-template name="RenderType"/>
			</xsl:for-each>
			<xsl:choose>
				<xsl:when test="contains($constraints,'c')">
					<xsl:if test="not(starts-with($constraints,'c'))">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:text>Class</xsl:text>
				</xsl:when>
				<xsl:when test="contains($constraints,'v')">
					<xsl:if test="not(starts-with($constraints,'v'))">
						<xsl:text>, </xsl:text>
					</xsl:if>
					<xsl:text>Structure</xsl:text>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="contains($constraints,'n')">
				<xsl:if test="not(starts-with($constraints,'n'))">
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:text>New</xsl:text>
			</xsl:if>
			<xsl:if test="$multipleConstraints">
				<xsl:text>}</xsl:text>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template name="RenderTypeParams">
		<xsl:param name="TypeParams"/>
		<xsl:for-each select="$TypeParams">
			<xsl:choose>
				<xsl:when test="position()=1">
					<xsl:text>(Of </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>, </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="@name"/>
			<xsl:call-template name="RenderTypeParamConstraint"/>
			<xsl:if test="position()=last()">
				<xsl:text>)</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="RenderVisibility">
		<xsl:param name="Visibility" select="string(@visibility)"/>
		<xsl:if test="string-length($Visibility)">
			<!-- Note that private implementation members will not have a visibility set -->
			<xsl:choose>
				<xsl:when test="$Visibility='public'">
					<xsl:text>Public </xsl:text>
				</xsl:when>
				<xsl:when test="$Visibility='private' or $Visibility='privateInterfaceMember'">
					<xsl:text>Private </xsl:text>
				</xsl:when>
				<xsl:when test="$Visibility='protected'">
					<xsl:text>Protected </xsl:text>
				</xsl:when>
				<xsl:when test="$Visibility='internal'">
					<xsl:text>Friend </xsl:text>
				</xsl:when>
				<xsl:when test="$Visibility='protectedOrInternal'">
					<xsl:text>Protected Friend </xsl:text>
				</xsl:when>
				<xsl:when test="$Visibility='protectedAndInternal'">
					<!-- VB won't do the and protected, but enforce internal -->
					<xsl:text>Friend </xsl:text>
				</xsl:when>
				<!-- deferToPartial is not rendered -->
			</xsl:choose>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>