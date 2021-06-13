//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
USING System.Reflection
USING System.Globalization
USING System.Collections.Generic
USING System.Text.RegularExpressions

USING XSharp.Internal
/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/evaluate/*" />
/// <seealso cref="NeedsAccessToLocalsAttribute" />
[NeedsAccessToLocals(TRUE)];
    FUNCTION Evaluate(cString AS STRING) AS USUAL
RETURN Evaluate(cString, TRUE)

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/evaluate/*" />
/// <param name="lAllowSingleQuotes">Should single quotes be allowed as string delimiters.</param>
/// <seealso cref="NeedsAccessToLocalsAttribute" />
[NeedsAccessToLocals(TRUE)];
    FUNCTION Evaluate(cString AS STRING, lAllowSingleQuotes AS LOGIC) AS USUAL
    LOCAL oMacro AS XSharp._Codeblock
    LOCAL uRes   AS USUAL
    oMacro := MCompile(cString, lAllowSingleQuotes)
    IF oMacro != NULL_OBJECT .AND. ! oMacro:IsBlock
        uRes := oMacro:EvalBlock()
    ELSE
        // strange but evaluate on a codeblock returns the block in stead of evaluating it
        uRes := oMacro
    ENDIF
RETURN uRes

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/mcompile/*" />
/// <remarks>MCompile() allows you to use the macro compiler to compile a string and store the compiled results for later execution.  Instead of invoking the macro compiler each time an expression is evaluated, you could speed up your application by compiling an expression only once and executing the compiled form as often as desired.</remarks>
/// <note type="caution">MCompile returns a STRING in VO. It returns a XSharp._Codeblock in .Net.</note>
/// <seealso cref="_Codeblock" />
FUNCTION MCompile(cString AS STRING) AS XSharp._Codeblock
    RETURN MCompile(cString, TRUE)

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/mcompile/*" />
/// <param name="lAllowSingleQuotes">Should single quotes be allowed as string delimiters</param>
/// <seealso cref="_Codeblock" />
FUNCTION MCompile(cString AS STRING, lAllowSingleQuotes AS LOGIC) AS XSharp._Codeblock
    VAR oMC := XSharp.RuntimeState.MacroCompiler
    IF oMC != NULL_OBJECT
        VAR oMod := XSharp.RuntimeState.AppModule
        IF oMod == NULL_OBJECT
            XSharp.RuntimeState.AppModule := TYPEOF(XSharp.Core.Functions):Module
        ENDIF
        IF XSharp.RuntimeState:MacroResolver == NULL
            XSharp.RuntimeState:MacroResolver := DefaultMacroAmbigousMatchResolver
        ENDIF
        LOCAL oResult AS XSharp._Codeblock
        VAR cMacro := MPrepare(cString)
        IF oMC IS IMacroCompilerUsual VAR oMCU
            oResult := oMCU:CompileCodeblock(cMacro, lAllowSingleQuotes, oMod)
            oResult:SetString(cString)
        ELSE
            LOCAL iResult AS ICodeblock
            iResult := oMC:Compile(cMacro, lAllowSingleQuotes, oMod, OUT VAR lIsCodeblock, OUT VAR addsMemVars)
            oResult := XSharp._Codeblock{iResult, cString, lIsCodeblock, addsMemVars}
            oResult:SetString(cString)
        ENDIF
        RETURN oResult
    ENDIF
    RETURN NULL_OBJECT

INTERNAL GLOBAL macroTokens AS Dictionary<STRING, STRING>

INTERNAL FUNCTION MPrepare(cMacro AS STRING) AS STRING
    // Replace ".or." and other strings when they are part of the macro
    VAR pos := cMacro:IndexOf(c'.')
    IF pos < 0
        RETURN cMacro
    ENDIF
    // This is probably too much but it works
    // and it does not fix MiXeD cased NaMeS
    IF macroTokens == NULL
        macroTokens := Dictionary<STRING, STRING>{}
        macroTokens:Add("\.or\.", " .or. ")
        macroTokens:Add("\.and\.", " .and. ")
        macroTokens:Add("\.not\.", " .not. ")
        macroTokens:Add("\.xor\.", " .xor. ")
        macroTokens:Add("\.t\.", " .t. ")
        macroTokens:Add("\.f\.", " .f. ")
        macroTokens:Add("\.n\.", " .n. ")
        macroTokens:Add("\.y\.", " .y. ")
    ENDIF
    VAR result := cMacro

    FOREACH VAR replace IN macroTokens
        result := Regex.Replace(result,replace:Key, replace:Value, RegexOptions.IgnoreCase)
    NEXT
    RETURN result


/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/mexec/*" />
/// <note type="caution">MCompile returns a STRING containing PCode tokens in VO.
/// It returns a XSharp._Codeblock in .Net. Therefore the parameter of MExec is a Codeblock</note>
/// <seealso cref="_Codeblock" />
/// <seealso cref="MCompile" />
/// <seealso cref="NeedsAccessToLocalsAttribute" />
[NeedsAccessToLocals(TRUE)];
    FUNCTION MExec(oBlock AS CODEBLOCK) AS USUAL
RETURN Eval(oBlock)




// Copied from the Roslyn Lexer and Macro Lexer
INTERNAL FUNCTION _IsIdentifierStartChar(cChar AS CHAR) AS LOGIC
    IF cChar >= c'A' .AND. cChar <= c'Z'
        RETURN TRUE
    ENDIF
    IF cChar >= c'a' .AND. cChar <= c'z'
        RETURN TRUE
    ENDIF
    IF cChar == c'_'
        RETURN TRUE
    ENDIF
    IF cChar < 0x7F
        // All other lower ascii are not allowed
        RETURN FALSE
    ENDIF
    VAR cat := CharUnicodeInfo.GetUnicodeCategory(cChar)
    SWITCH cat
        CASE UnicodeCategory.UppercaseLetter
        CASE UnicodeCategory.LowercaseLetter
        CASE UnicodeCategory.TitlecaseLetter
        CASE UnicodeCategory.ModifierLetter
        CASE UnicodeCategory.OtherLetter
        CASE UnicodeCategory.LetterNumber
            RETURN TRUE
    END SWITCH
RETURN FALSE

INTERNAL FUNCTION _IsIdentifierPartChar(cChar AS CHAR) AS LOGIC
    IF _IsIdentifierStartChar(cChar)
        RETURN TRUE
    ENDIF
    VAR cat := CharUnicodeInfo.GetUnicodeCategory(cChar)
    SWITCH cat
        CASE UnicodeCategory.DecimalDigitNumber
        CASE UnicodeCategory.ConnectorPunctuation
        CASE UnicodeCategory.NonSpacingMark
        CASE UnicodeCategory.SpacingCombiningMark
            RETURN TRUE
        CASE UnicodeCategory.Format
            RETURN cChar > 127
    END SWITCH
RETURN FALSE

INTERNAL FUNCTION _IsIdentifier(cName AS STRING) AS LOGIC
    IF cName:Length=0 .OR. ! _IsIdentifierStartChar(cName[0])
        RETURN FALSE
    ENDIF
    FOR VAR nChar := 1 TO cName:Length-1
        IF ! _IsIdentifierPartChar(cName[nChar])
            RETURN FALSE
        ENDIF
    NEXT
RETURN TRUE

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/type/*" />
/// <seealso cref="NeedsAccessToLocalsAttribute" />
[NeedsAccessToLocals(FALSE)];
    FUNCTION Type(cString AS STRING) AS STRING
    LOCAL uValue AS USUAL
    LOCAL cRet	 AS STRING
    IF String.IsNullOrEmpty(cString)
        cRet := "UE"
    ELSE
        TRY
                // do not use the macro compiler to find "simple" memvar or local names
                IF _IsIdentifier(cString) .AND. MemVarTryGet(cString, OUT uValue)
                    cRet   := ValType(uValue)
                ELSE
                    // Ok, this is not a memvar or local name. Let's evaluate it
                    uValue := Evaluate(cString)
                    cRet   := ValType(uValue)
            ENDIF
        CATCH  AS Exception
            cRet  := "UE"
        END TRY
    ENDIF
    IF RuntimeState.Dialect == XSharpDialect.FoxPro .and. cRet == "UE"
        cRet := "U"
    ENDIF

RETURN cRet



/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/strevaluate/*" />
/// <seealso cref="NeedsAccessToLocalsAttribute" />
[NeedsAccessToLocals(FALSE)];
    FUNCTION StrEvaluate( cString AS STRING ) AS STRING
    IF cString:IndexOf("&") > 0
        LOCAL cVariableName AS STRING
        LOCAL lInVariable   AS LOGIC
        LOCAL evalMacro     AS LOGIC
        LOCAL lAddChar      AS LOGIC
        lInVariable := evalMacro := FALSE
        cVariableName := ""
        VAR sb := System.Text.StringBuilder{cString:Length}
        FOREACH VAR cChar IN cString
            lAddChar := TRUE
            SWITCH cChar
                CASE c'&'
                    lInVariable   := TRUE
                    cVariableName := ""
                    lAddChar     := FALSE
                CASE c' '
                CASE c'\t'
                    IF lInVariable
                        lInVariable := FALSE
                        evalMacro   := TRUE
                    ENDIF
                CASE c'.'
                    IF lInVariable
                        lInVariable := FALSE
                        evalMacro   := TRUE
                        lAddChar     := FALSE
                    ENDIF
                OTHERWISE
                    IF lInVariable
                        IF Char.IsLetterOrDigit(cChar)
                                cVariableName += cChar:ToString()
                            lAddChar     := FALSE
                        ELSE
                            lInVariable := FALSE
                            evalMacro   := TRUE
                        ENDIF
                    ENDIF
            END SWITCH
            IF evalMacro
                VAR result := StrEvaluateMemVarGet(cVariableName)
                sb:Append(result)
                evalMacro := FALSE
            ENDIF
            IF lAddChar
                sb:Append(cChar)
            ENDIF
        NEXT
        IF lInVariable
            VAR result := StrEvaluateMemVarGet(cVariableName)
            sb:Append(result)
        ENDIF
        cString := sb:ToString()
    ENDIF
RETURN cString


INTERNAL FUNCTION StrEvaluateMemVarGet(cVariableName AS STRING) AS STRING
    TRY
            VAR oMemVar := XSharp.MemVar.PrivateFind(cVariableName)
            IF oMemVar == NULL
                oMemVar := XSharp.MemVar.PublicFind(cVariableName)
            ENDIF
            IF oMemVar != NULL
                RETURN oMemVar:Value:ToString()
        ENDIF
    CATCH
        // Memvar not found ?
    END TRY
RETURN cVariableName

INTERNAL FUNCTION DefaultMacroAmbigousMatchResolver(m1 AS MemberInfo, m2 AS MemberInfo, args AS System.Type[]) AS LONG
    LOCAL comp1 := GetCompany(m1:Module:Assembly) AS STRING
    LOCAL comp2 := GetCompany(m2:Module:Assembly) AS STRING
    IF comp1 == XSharp.Constants.Company
        IF ! (comp2 == XSharp.Constants.Company)
            RETURN 2
        ENDIF
    ENDIF
    IF comp2 == XSharp.Constants.Company
        IF  ! (comp1== XSharp.Constants.Company)
            RETURN 1
        ENDIF
    ENDIF

RETURN 0

INTERNAL FUNCTION GetCompany(asm AS System.Reflection.Assembly) AS STRING
    FOREACH attr AS CustomAttributeData IN asm:CustomAttributes
        IF attr:AttributeType== typeof(AssemblyCompanyAttribute)
            RETURN (STRING) attr:ConstructorArguments[0]:Value
        ENDIF
    NEXT
RETURN NULL


INTERNAL GLOBAL _fullMacroCompiler AS Assembly

/// <include file="VFPDocs.xml" path="Runtimefunctions/execscript/*" />
FUNCTION ExecScript( cExpression, eParameters ) AS USUAL CLIPPER
    LOCAL result := NIL AS USUAL
    XSharp.RuntimeState.LastScriptError := NULL
    TRY
        IF _fullMacroCompiler == NULL_OBJECT
            AssemblyHelper.Load("XSharp.Scripting")
            AssemblyHelper.Load("XSharp.CodeAnalysis")
            _fullMacroCompiler := AssemblyHelper.Load("XSharp.MacroCompiler.Full")
            VAR oImm := AssemblyHelper.FindLoadedAssembly("System.Collections.Immutable")
            IF oImm == NULL_OBJECT
                oImm := Assembly.Load("System.Collections.Immutable, Version=5.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
            ENDIF
            IF oImm == NULL_OBJECT
                THROW Error{"Could not load 'System.Collections.Immutable'"}
            ENDIF
        ENDIF
        IF _fullMacroCompiler != NULL_OBJECT
            LOCAL type := _fullMacroCompiler:GetType("XSharp_MacroCompiler_Full.Functions") AS System.Type
            if (type != NULL)
                var exec := type:GetMethod("_ExecScript")
                var argTmp := List<USUAL>{}
                argTmp:AddRange(_Args())
                argTmp:RemoveAt(0)
                if exec != null
                    var args := OBJECT[]{2}
                    args[1] := (String) cExpression
                    args[2] := argTmp:ToArray()
                    TRY
                        result := exec:Invoke(NULL, args)
                    CATCH e as Exception
                        XSharp.RuntimeState.LastScriptError := e
                        THROW e
                    END TRY
                ELSE
                    THROW Error{"Could not load function '_ExecScript' in type 'XSharp_MacroCompiler_Full.Functions'"}
                endif
            ELSE
                THROW Error{"Could not load type 'XSharp_MacroCompiler_Full.Functions' in XSharp.MacroCompiler.Full.dll"}
            endif
        ENDIF
    CATCH e as Exception
        XSharp.RuntimeState.LastScriptError :=  e
        THROW e
    END TRY
    RETURN result



