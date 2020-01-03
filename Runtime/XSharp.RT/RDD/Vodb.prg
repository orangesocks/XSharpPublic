//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//

USING XSharp.RDD
USING XSharp.RDD.Support
USING System.Collections.Generic
USING SYstem.Linq

/// <summary>The VoDb class extendes the CoreDb class with methods that take usual parameters or return usual values.<br/>
/// All other methods are identical and inherited from the CoreDb class.</summary>
PARTIAL CLASS XSharp.VoDb INHERIT XSharp.CoreDb
/// <inheritdoc cref='M:XSharp.CoreDb.BlobInfo(System.UInt32,System.UInt32,System.Object@)'/>
STATIC METHOD BlobInfo(nOrdinal AS DWORD,nPos AS DWORD,ptrRet REF USUAL) AS LOGIC
    LOCAL oRet := ptrRet AS OBJECT
    LOCAL result AS LOGIC
    result := CoreDb.BlobInfo(nOrdinal, nPos, REF oRet)
    ptrRet := oRet
    RETURN result

/// <inheritdoc cref='M:XSharp.CoreDb.BlobInfo(System.UInt32,System.UInt32,System.Object)'/>
STATIC METHOD BlobInfo(nOrdinal AS DWORD,nPos AS DWORD,uValue AS USUAL) AS LOGIC
    RETURN CoreDb.BlobInfo(nOrdinal, nPos, (OBJECT) uValue)

/// <inheritdoc cref='M:XSharp.CoreDb.FieldInfo(System.UInt32,System.UInt32,System.Object@)'/>
STATIC METHOD FieldInfo(nOrdinal AS DWORD,nPos AS DWORD,ptrRet REF USUAL) AS LOGIC
    LOCAL oRet := ptrRet AS OBJECT
    LOCAL result AS LOGIC
    result := CoreDb.FieldInfo(nOrdinal, nPos, REF oRet)
    ptrRet := oRet
    RETURN result

/// <inheritdoc cref="M:XSharp.CoreDb.FieldInfo(System.UInt32,System.UInt32,System.Object)"/>
STATIC METHOD FieldInfo(nOrdinal AS DWORD,nPos AS DWORD,uValue AS USUAL) AS LOGIC
    RETURN CoreDb.FieldInfo(nOrdinal, nPos, (OBJECT) uValue)
    
/// <inheritdoc cref="M:XSharp.CoreDb.FieldGet(System.UInt32,System.Object@)"/>
STATIC METHOD FieldGet(nPos AS DWORD,uRet REF USUAL) AS LOGIC
    LOCAL lResult AS LOGIC
    LOCAL oValue := uRet AS OBJECT
    lResult := CoreDb.FieldGet(nPos, REF oValue)
    uRet := oValue
    RETURN lResult

/// <inheritdoc cref="M:XSharp.CoreDb.Info(System.UInt32,System.Object)"/>
/// <remarks> <inheritdoc cref="M:XSharp.CoreDb.Info(System.UInt32,System.Object)"/>
/// <br/><br/> <note type="tip">The difference between VoDb.Info and CoreDb.Info is that VoDb.Info takes a USUAL parameter</note></remarks>
STATIC METHOD Info(nOrdinal AS DWORD,ptrRet REF USUAL) AS LOGIC
    LOCAL oRet := ptrRet AS OBJECT
    LOCAL result AS LOGIC
    result := CoreDb.Info(nOrdinal, REF oRet)
    ptrRet := oRet
    RETURN result

/// <inheritdoc cref='M:XSharp.CoreDb.Info(System.UInt32,System.Object)'/>
/// <remarks> <inheritdoc cref='M:XSharp.CoreDb.Info(System.UInt32,System.Object)'/>
/// <br/><br/> <note type="tip">The difference between VoDb.Info and CoreDb.Info is that VoDb.Info takes a USUAL parameter</note></remarks>
STATIC METHOD Info(nOrdinal AS DWORD,uValue AS USUAL) AS LOGIC
    RETURN CoreDb.Info(nOrdinal, (OBJECT) uValue)

/// <inheritdoc cref='M:XSharp.CoreDb.OrderInfo(System.UInt32,System.String,System.Object,System.Object@)'/>
/// <remarks> <inheritdoc cref='M:XSharp.CoreDb.OrderInfo(System.UInt32,System.String,System.Object,System.Object@)'/>
/// <br/><br/> <note type="tip">The difference between VoDb.OrderInfo and CoreDb.OrderInfo is that VoDb.Info takes a USUAL parameter</note></remarks>
STATIC METHOD OrderInfo(nOrdinal AS DWORD,cBagName AS STRING,uOrder AS OBJECT,uRet REF USUAL) AS LOGIC
    LOCAL oRet := uRet AS OBJECT   
    LOCAL result AS LOGIC
    result := CoreDb.OrderInfo(nOrdinal, cBagName,  uOrder, REF oRet)
    IF oRet == NULL
        uRet := NIL
    ELSE
        uRet := oRet
    ENDIF
    RETURN result

/// <inheritdoc cref="M:XSharp.CoreDb.OrderInfo(System.UInt32,System.String,System.Object,System.Object)" />
/// <remarks> <inheritdoc cref='M:XSharp.CoreDb.OrderInfo(System.UInt32,System.String,System.Object,System.Object)'/>
/// <br/><br/> <note type="tip">The difference between VoDb.OrderInfo and CoreDb.OrderInfo is that VoDb.Info takes a USUAL parameter</note></remarks>
STATIC METHOD OrderInfo(nOrdinal AS DWORD,cBagName AS STRING,uOrder AS OBJECT,uValue AS USUAL) AS LOGIC
    RETURN CoreDb.OrderInfo(nOrdinal, cBagName,  uOrder, (OBJECT) uValue)

/// <inheritdoc cref='M:XSharp.CoreDb.RddInfo(System.UInt32,System.Object@)'/>
/// <remarks> <inheritdoc cref='M:XSharp.CoreDb.RddInfo(System.UInt32,System.Object@)'/>
/// <br/><br/> <note type="tip">The difference between VoDb.RddInfo and CoreDb.RddInfo is that VoDb.RddInfo takes a USUAL parameter</note></remarks>
STATIC METHOD RddInfo(nOrdinal AS DWORD,uRet REF USUAL) AS LOGIC
    LOCAL oValue AS OBJECT
    oValue := uRet
    LOCAL result := CoreDb.RddInfo(nOrdinal, REF oValue) AS LOGIC
    uRet := oValue
    RETURN result

/// <inheritdoc cref='M:XSharp.CoreDb.RddInfo(System.UInt32,System.Object)'/>
/// <remarks> <inheritdoc cref='M:XSharp.CoreDb.RddInfo(System.UInt32,System.Object)'/>
/// <br/><br/> <note type="tip">The difference between VoDb.RddInfo and CoreDb.RddInfo is that VoDb.RddInfo takes a USUAL parameter</note></remarks>
STATIC METHOD RddInfo(nOrdinal AS DWORD,uValue AS USUAL) AS LOGIC
    RETURN CoreDb.RddInfo(nOrdinal, (OBJECT) uValue) 

/// <inheritdoc cref='M:XSharp.CoreDb.RecordInfo(System.UInt32,System.Object,System.Object@)'/>
/// <remarks> <inheritdoc cref='M:XSharp.CoreDb.RecordInfo(System.UInt32,System.Object,System.Object@)'/>
/// <br/><br/> <note type="tip">The difference between VoDb.RecordInfo and CoreDb.RecordInfo is that VoDb.RecordInfo takes a USUAL parameter</note></remarks>
STATIC METHOD RecordInfo(nOrdinal AS DWORD,uRecId AS USUAL,uRet REF USUAL) AS LOGIC
    LOCAL oRet := uRet AS OBJECT
    LOCAL lResult AS LOGIC
    lResult := CoreDb.RecordInfo(nOrdinal, uRecID, REF oRet)
    uRet := oRet
    RETURN lResult
    
/// <inheritdoc cref='M:XSharp.CoreDb.RecordInfo(System.UInt32,System.Object,System.Object)'/>
/// <remarks> <inheritdoc cref='M:XSharp.CoreDb.RecordInfo(System.UInt32,System.Object,System.Object)'/>
/// <br/><br/> <note type="tip">The difference between VoDb.RecordInfo and CoreDb.RecordInfo is that VoDb.RecordInfo takes a USUAL parameter</note></remarks>
STATIC METHOD RecordInfo(nOrdinal AS DWORD,uRecId AS USUAL,uRet AS USUAL) AS LOGIC
    RETURN CoreDb.RecordInfo(nOrdinal, uRecID,  (OBJECT) uRet)

   
/// <inheritdoc cref='M:XSharp.CoreDb.Select(System.UInt32,System.UInt32@)'/>
/// <remarks> <inheritdoc cref='M:XSharp.CoreDb.Select(System.UInt32,System.UInt32@)'/>
/// <br/><br/> <note type="tip">The difference between VoDb.Select and CoreDb.Select is that VoDb.Select takes a USUAL parameter</note></remarks>
STATIC METHOD Select(nNew AS DWORD,riOld REF USUAL) AS LOGIC
    LOCAL nOld := 0 AS DWORD
    LOCAL lResult AS LOGIC
    lResult := CoreDb.Select(nNew, REF nOld)
    riOld := nOld
    RETURN lResult

 
/// <inheritdoc cref='M:XSharp.CoreDb.SetFilter(XSharp.ICodeBlock,System.String)'/>
/// <remarks> <note type="tip">The difference between VoDb.SetFilter and CoreDb.SetFilter is that VoDb.SetFilter takes a USUAL parameter</note></remarks>
STATIC METHOD SetFilter(oBlock AS USUAL,cFilter AS STRING) AS LOGIC
    LOCAL cb AS ICodeBlock
    IF oBlock:IsCodeBlock
       cb := (ICodeBlock) oBlock
    ELSE
        cb := NULL
    ENDIF
    RETURN CoreDb.SetFilter(cb, cFilter)
 

    INTERNAL STATIC METHOD ParamError(cFuncSym AS STRING, dwArgNum  AS DWORD ,   dwArgType AS DWORD) AS Error 
    
        LOCAL oError    AS Error
        oError := Error{RuntimeState.LastRDDError}
        oError:SubSystem    := "DBCMD"
        oError:GenCode      := EG_ARG
        oError:Severity     := ES_ERROR
        oError:CanDefault   := .F.
        oError:CanRetry     := .T.
        oError:CanSubstitute := .F.
        oError:ArgType      := dwArgType
        oError:ArgNum       := dwArgNum
        oError:FuncSym      := cFuncSym
        RETURN oError
        
    INTERNAL STATIC METHOD DBCMDError(cFuncSym AS STRING)  AS Error 
        LOCAL oError    AS Error
        oError := Error{RuntimeState.LastRDDError}	
        oError:GenCode      := EG_NOTABLE
        oError:SubCode      := EDB_NOTABLE
        oError:SubSystem    := "DBCMD"
        oError:Severity     := ES_ERROR
        oError:FuncSym      := cFuncSym
        oError:CanDefault   := .T.
        RETURN oError
        
    INTERNAL STATIC METHOD AllocFieldNames(aStru AS ARRAY) AS _FieldNames
        VAR aNames := List<STRING>{}
        FOREACH aField AS USUAL IN aStru
            IF aField:IsArray
                aNames:Add(Upper(aField[DBS_NAME]))
            ELSE
                aNames:Add(upper(aField))
            ENDIF
        NEXT
        RETURN _FieldNames{aNames}
        
    INTERNAL STATIC METHOD TargetFields  (cAlias AS STRING, aNames AS ARRAY, oJoinList OUT _JoinList) AS ARRAY 
    
        LOCAL aNew      AS ARRAY
        LOCAL cName     AS STRING
        LOCAL aStruct   AS ARRAY
        LOCAL adbStruct AS ARRAY
        LOCAL nFields, i AS INT
        LOCAL siPos     AS DWORD
        LOCAL siSelect  AS DWORD
        LOCAL aFldList  AS ARRAY
        
        adbStruct := DbStruct()
        aStruct   := {}
        aFldList := {}
        
        IF ( Empty(aNames) )
        
            aNames     := {}
            nFields    := (INT) FCount()
            siSelect   := VoDb.GetSelect()
            FOR i := 1 TO nFields
                cName := adbStruct[i, DBS_NAME]
                AAdd(aFldList, {siSelect, FieldPos(cName)})
                AAdd(aStruct, aDbStruct[i])
                AAdd(aNames, cName)
            NEXT
        ELSE
            nFields := (INT)Len(aNames)
            aNew := {}
            FOR i := 1 TO nFields
                AAdd(aNew, AllTrim(Upper(aNames[i])))
            NEXT
            aNames := aNew
            nFields := (INT)FCount()
            siSelect := VoDb.GetSelect()
            FOR i := 1 TO nFields
                cName := adbStruct[i, DBS_NAME]
                IF AScan(aNames, {|c| c == cName}) > 0
                    AAdd(aFldList, {siSelect, FieldPos(cName)})
                    AAdd(aStruct, aDbStruct[i])
                ENDIF
            NEXT
        ENDIF
        siSelect := SELECT(cAlias)
        aDbStruct := DbStruct()
        nFields := (INT)Len(aNames)
        
        FOR i := 1 TO nFields
            IF "->" $ aNames[i]
                cName := SubStr2(aNames[i], At(">", aNames[i]) + 1)
            ELSE
                cName :=  aNames[i]
            ENDIF
            
            siPos := AScan(aDbStruct, {|a| a[DBS_NAME] == cName})
            IF siPos > 0 .AND. (AScan( aStruct, {|c|c[DBS_NAME]== cName }) == 0)
                AAdd(aFldList, {siSelect, FieldPos(cName)})
                AAdd(aStruct, aDbStruct[siPos])
            ENDIF
        NEXT
        nFields := (INT)ALen(aStruct)
        oJoinList := _JoinList{nFields}
        FOR i := 1 TO nFields
            oJoinList:Fields[i]:Area := aFldList[i,1]
            oJoinList:Fields[i]:Pos  := aFldList[i,2] - 1
        NEXT
        RETURN aStruct
        
    INTERNAL STATIC METHOD  RddList( xDriver AS USUAL, aHidden AS USUAL ) AS ARRAY
    
        LOCAL   nType   AS DWORD
        LOCAL   aRdds  := NULL_ARRAY AS ARRAY
        LOCAL   n       AS DWORD
        LOCAL   i       AS DWORD
        LOCAL   lFPT  := FALSE AS LOGIC
        LOCAL   lDbf    AS LOGIC
        
        IF xDriver:IsArray
            nType := ARRAY
        ELSEIF xDriver:IsString
            IF SLen(xDriver) = 0
                xDriver := RDDSetDefault()
            ENDIF
            nType := STRING
        ELSE
            xDriver := RDDSetDefault()
            nType := STRING
        ENDIF
        
        IF nType == ARRAY
            aRdds := xDriver
        ELSEIF nType == STRING
            aRdds := {}
            xDriver := upper(xDriver)
            SWITCH (STRING) xDriver
            CASE "DBFNTX"
            CASE "DBFMEMO"
            CASE "DBFDBT"
                lDbf := .T.
            CASE "_DBFCDX"
            CASE "DBFFPT"
                xDriver := "DBFFPT"
                lDbf := .T.
            CASE "DBFCDX"
                lFPT := .T.
                lDbf  := .T.
                xDriver := "DBFFPT"
            CASE "DBFMDX"
                lDbf := .T.
            OTHERWISE
                lDbf := .F.
                lFPT := .F.
            END SWITCH
            
            IF lDbf
                AAdd(aRdds, "DBF")  
            ENDIF
            
            AAdd(aRdds, xDriver)
            
            IF lFPT
                AAdd(aRdds, "DBFCDX")
            ENDIF
            
        ENDIF
        
        IF UsualType(aHidden) == ARRAY
            n := ALen(aHidden)
            FOR i := 1 TO n
                AAdd(aRdds, aHidden[i])
            NEXT
        ENDIF
        RETURN aRdds
        
    INTERNAL STATIC METHOD AllocRddList(aNames AS ARRAY) AS _RddList
        VAR aList := List<STRING>{}
        FOREACH cName AS STRING IN aNames
            aList:Add(cName)
        NEXT
        RETURN _RddList{aList:ToArray()}

    INTERNAL STATIC METHOD ArrayToFieldInfo(aStruct AS ARRAY) AS RddFieldInfo[]
        VAR oList := List<RddFieldInfo>{}
        FOREACH aField AS USUAL IN aStruct
            VAR oFld := RddFieldInfo{(STRING) aField[DBS_NAME], (STRING) aField[DBS_TYPE], (LONG)aField[DBS_LEN], (LONG)aField[DBS_DEC]}
            oList:Add(oFld)
        NEXT
        RETURN oList:ToArray()
        
    INTERNAL STATIC METHOD OrdScopeNum(nScope)  AS INT CLIPPER
        IF !nScope:IsNumeric
            nScope := 0
        ENDIF
        nScope := INT(nScope)
        IF nScope < 0
            nScope := 0
        ENDIF
        IF nScope > 1
            nScope := 1
        ENDIF
        RETURN nScope
        
    INTERNAL STATIC METHOD WithoutAlias(cName AS STRING) AS STRING 
        cName   := SubStr(cName, At(">", cName) + 1 )
        cName   := Trim(Upper(cName))
        RETURN cName

    INTERNAL STATIC METHOD ValidBlock(uBlock AS USUAL) AS ICodeblock
        LOCAL oBlock    := uBlock   AS OBJECT
        IF oBlock IS ICodeblock
            RETURN (ICodeblock) oBlock
        ENDIF
        RETURN NULL  

INTERNAL STATIC METHOD  FieldList(aStruct AS ARRAY, aNames AS ARRAY, aMatch AS ARRAY) AS ARRAY 
	
	LOCAL aNew      AS ARRAY
	LOCAL cobScan   AS CODEBLOCK
	LOCAL cName     AS STRING
	LOCAL n, i, j   AS DWORD
	LOCAL lMatch	AS LOGIC
	
	
	IF Empty(aNames)
		RETURN (aStruct)
	ENDIF
	
	//	UH 11/30/1998
	IF Empty(aMatch)
		lMatch := .F.
	ELSE
		lMatch := .T.
	ENDIF
	
	aNew:= {}
	n   := Len(aNames)
	
	FOR i := 1 TO n
		AAdd(aNew, VoDb.WithoutAlias(AllTrim(aNames[i])))
	NEXT
	
	aNames  := aNew
	cName   := ""
	aNew    := {}
	cobScan := {|aFld| aFld[DBS_NAME] == cName}
	
	FOR i := 1 TO n
		cName := aNames[i]
		j := AScan(aStruct, cobScan)
		
		IF j > 0
			IF lMatch
				IF aMatch[i, DBS_TYPE] == aStruct[j, DBS_TYPE]
					AAdd(aNew, aStruct[j])
				ENDIF
			ELSE
				AAdd(aNew, aStruct[j])
			ENDIF
		ENDIF
	NEXT
	
	RETURN aNew


END CLASS    
