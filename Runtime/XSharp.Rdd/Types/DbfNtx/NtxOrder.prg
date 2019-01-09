﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//

USING System
USING System.Collections
USING System.Collections.Generic
USING System.Diagnostics
USING System.Globalization
USING System.IO
USING System.Reflection
USING System.Text
USING System.Threading
USING XSharp.RDD.Enums
USING XSharp.RDD.Support

BEGIN NAMESPACE XSharp.RDD.NTX

    // Ntx Stack item
    // Keep informations 
    INTERNAL SEALED CLASS NtxStack
        INTERNAL Page AS LONG
        INTERNAL Pos AS LONG
        INTERNAL Count AS LONG
        
        INTERNAL METHOD Clear() AS VOID
            SELF:Page := 0
            SELF:Count := 0
            SELF:Pos := 0
            
    END CLASS
            
    INTERNAL ENUM NtxSkipDirection
        MEMBER Backward := -1
        MEMBER Forward := 1
        
    END ENUM
    
    INTERNAL ENUM NtxSearchMode
        MEMBER Left
        MEMBER LeftFound
        MEMBER Right
        MEMBER Bottom
        MEMBER Top
        
    END ENUM
    
    
    
    
    INTERNAL SEALED CLASS NtxOrder INHERIT BaseIndex IMPLEMENTS IRddSortWriter
    
        INTERNAL _hFile AS IntPtr
        INTERNAL _Encoding AS Encoding
        INTERNAL _Shared AS LOGIC
        INTERNAL _ReadOnly       AS LOGIC
        INTERNAL _Hot AS LOGIC
        INTERNAL _Unique AS LOGIC
        INTERNAL _Conditional AS LOGIC
        INTERNAL _Descending AS LOGIC
        INTERNAL _Partial AS LOGIC
        INTERNAL _SingleField AS LONG
        INTERNAL _KeyCodeBlock AS ICodeblock
        INTERNAL _ForCodeBlock AS ICodeblock
        INTERNAL _KeyExpr AS STRING
        INTERNAL _ForExpr AS STRING
        //
        INTERNAL _knownRecno AS DWORD
        INTERNAL _knownKeyBuffer AS BYTE[]
        INTERNAL _newKeyBuffer AS BYTE[]
        INTERNAL _newKeyLen AS LONG
        INTERNAL _indexVersion AS WORD
        INTERNAL _nextUnusedPageOffset AS DWORD
        INTERNAL _entrySize AS WORD
        INTERNAL _KeyExprType AS TypeCode
        INTERNAL _keySize AS WORD
        INTERNAL _keyDecimals AS WORD
        INTERNAL _MaxEntry AS WORD
        INTERNAL _halfPage AS WORD
        INTERNAL _TopStack AS DWORD
        INTERNAL _firstPageOffset AS DWORD
        INTERNAL _fileSize AS LONG
        INTERNAL _ntxStack AS NtxStack[]
        INTERNAL _HPLocking AS LOGIC
        INTERNAL _readLocks AS DWORD
        INTERNAL _writeLocks AS DWORD
        INTERNAL _tagNumber AS INT
        INTERNAL _maxLockTries AS INT
        INTERNAL _orderName AS STRING
        INTERNAL _fileName AS STRING
        INTERNAL _Ansi AS LOGIC
        INTERNAL _hasTopScope AS LOGIC
        INTERNAL _hasBottomScope AS LOGIC
        INTERNAL _topScopeBuffer AS BYTE[]
        INTERNAL _bottomScopeBuffer AS BYTE[]
        INTERNAL _topScope AS OBJECT
        INTERNAL _bottomScope AS OBJECT
        INTERNAL _topScopeSize AS LONG
        INTERNAL _bottomScopeSize AS LONG
        INTERNAL _oRdd AS DBFNTX
        INTERNAL _Header AS NtxHeader
        INTERNAL _oneItem AS NtxItem
        INTERNAL _PageList AS NtxPageList
        PRIVATE _levels AS NtxLevel[]
        PRIVATE _levelsCount AS DWORD
        PRIVATE _midItem AS NtxItem
        PRIVATE _outPageNo AS LONG
        PRIVATE _parkPlace AS LONG
        
        INTERNAL _lockScheme     AS DbfLocking
        
        INTERNAL PROPERTY Expression AS STRING GET _KeyExpr
        
        INTERNAL PROPERTY Condition AS STRING GET _ForExpr
            
        INTERNAL PROPERTY OrderName AS STRING GET _orderName
                
        INTERNAL PROPERTY Recno AS DWORD GET (DWORD)_oRdd:Recno
                    
        INTERNAL CONSTRUCTOR(oRDD AS DBFNTX )
            SUPER( oRdd )
            //
            LOCAL i AS LONG
            //
            SELF:_knownKeyBuffer := BYTE[]{ 257 }
            SELF:_newKeyBuffer := BYTE[]{ 257 }
            SELF:_fileName := NULL
            SELF:_hFile := NULL
            SELF:_oRdd := oRDD
            SELF:_Header := NULL 
            SELF:_ntxStack := NtxStack[]{ 20 }
            SELF:_Encoding := oRDD:_Encoding
            SELF:_tagNumber := 1
            SELF:_maxLockTries := 1
            //Init
            FOR i := 0 TO ( SELF:_ntxStack:Length - 1 )
                SELF:_ntxStack[i] := NtxStack{}
            NEXT
                            
            INTERNAL CONSTRUCTOR(oRDD AS DBFNTX , filePath AS STRING )
                SELF(oRDD)
                SELF:FileName := filePath
                            
            INTERNAL PROPERTY FileName AS STRING
            GET
                RETURN SELF:_fileName
            END GET
            SET
                SELF:_FileName := VALUE
                IF  String.IsNullOrEmpty( SELF:_FileName ) 
                    SELF:_FileName := SELF:_oRDD:_FileName
                    //SELF:_FileName := Path.ChangeExtension(SELF:_FileName, ".ntx")
                ENDIF
                // and be sure to have an extension
                VAR ext := Path.GetExtension(SELF:_FileName)
                IF String.IsNullOrEmpty(ext)
                    SELF:_FileName := Path.ChangeExtension(SELF:_FileName, ".ntx")
                ENDIF
                // Check that we have a FullPath
                IF Path.GetDirectoryName(SELF:_FileName):Length == 0
                    // Check that we have a FullPath
                    IF Path.GetDirectoryName(SELF:_oRDD:_FileName):Length == 0
                        //TODO: Change that code to take care of DefaultPath, ...
                        SELF:_FileName := AppDomain.CurrentDomain.BaseDirectory + Path.DirectorySeparatorChar + SELF:_FileName
                    ELSE
                        SELF:_FileName := Path.GetDirectoryName(SELF:_oRDD:_FileName) + Path.DirectorySeparatorChar + SELF:_FileName
                    ENDIF
                ENDIF
            END SET
        END PROPERTY

    INTERNAL METHOD __Compare( aLHS AS BYTE[], aRHS AS BYTE[], nLength AS LONG) AS LONG
        RETURN RuntimeState.StringCompare(aLHS, aRHS, nLength)

    INTERNAL METHOD Open(dbordInfo AS DBORDERINFO ) AS LOGIC
        LOCAL isOk AS LOGIC
        LOCAL i AS LONG
        //
        isOk := FALSE
        SELF:_oRdd:GoCold()
        //
        SELF:_Shared := SELF:_oRDD:_Shared
        SELF:_ReadOnly := SELF:_oRDD:_ReadOnly
        //
        SELF:_hFile    := Fopen(SELF:FileName, SELF:_oRDD:_OpenInfo:FileMode) 
        IF SELF:_hFile == F_ERROR 
            SELF:_oRDD:_dbfError( ERDD.OPEN_ORDER, GenCode.EG_OPEN, SELF:fileName)
            RETURN FALSE
        ENDIF
        //
        SELF:_Header := NtxHeader{ SELF:_hFile }
        IF !SELF:_Header:Read()
            SELF:_oRDD:_dbfError(ERDD.OPEN_ORDER, GenCode.EG_OPEN, SELF:fileName)
            RETURN FALSE
        ENDIF
        SELF:_PageList := NtxPageList{SELF}
        SELF:_Ansi := SELF:_oRdd:_Ansi
        // Key
        SELF:_KeyExpr := SELF:_Header:KeyExpression
        TRY
            SELF:_oRdd:Compile(SELF:_KeyExpr)
        CATCH
            SELF:_oRdd:_dbfError( SubCodes.EDB_EXPRESSION, GenCode.EG_SYNTAX,"DBFNTX.Compile")
            RETURN FALSE
        END TRY
        SELF:_KeyCodeBlock := (ICodeblock)SELF:_oRDD:_LastCodeBlock
        //
        SELF:_oRdd:GoTo(1)
        LOCAL evalOk AS LOGIC
        LOCAL oResult AS OBJECT
        evalOk := TRUE
        TRY
            oResult := SELF:_oRdd:EvalBlock(SELF:_KeyCodeBlock)
        CATCH
            evalOk := FALSE
            oResult := NULL
        END TRY
        IF !evalOk
            SELF:_oRdd:_dbfError( SubCodes.EDB_EXPRESSION, GenCode.EG_SYNTAX, "DBFNTX.Compile")
            RETURN FALSE
        ENDIF
        SELF:_KeyExprType := SELF:_getTypeCode(oResult)
        // For Condition
        SELF:_Conditional := FALSE
        SELF:_ForExpr := SELF:_Header:ForExpression
        IF SELF:_ForExpr:Length > 0
            TRY
                SELF:_oRdd:Compile(SELF:_Header:ForExpression)
            CATCH
                SELF:_oRdd:_dbfError( SubCodes.EDB_EXPRESSION, GenCode.EG_SYNTAX,"DBFNTX.Compile")
                RETURN FALSE
            END TRY
            SELF:_ForCodeBlock := (ICodeblock)SELF:_oRdd:_LastCodeBlock
            SELF:_oRdd:GoTo(1)
            evalOk := TRUE
            TRY
                VAR lOk := (LOGIC) SELF:_oRdd:EvalBlock(SELF:_ForCodeBlock)
            CATCH
                evalOk := FALSE
            END TRY
            IF !evalOk
                SELF:_oRdd:_dbfError(SubCodes.EDB_EXPRESSION,GenCode.EG_SYNTAX,  "DBFNTX.Compile")
                RETURN FALSE
            ENDIF
            SELF:_Conditional := TRUE
        ENDIF
        // If the Key Expression contains only a Field Name
        SELF:_SingleField := -1
        FOR i := 1 TO SELF:_oRDD:FieldCount
            IF string.Compare(SELF:_KeyExpr, SELF:_oRDD:FieldName(i), TRUE) == 0
                SELF:_SingleField := i
                EXIT
            ENDIF
        NEXT
        //
        SELF:_Shared := SELF:_oRdd:_Shared
        FSeek3( SELF:_hFile, 0, FS_END )
        SELF:_fileSize  := (LONG)FTell( SELF:_hFile ) 
        SELF:_Hot := FALSE
        SELF:ClearStack()
        //
        SELF:_entrySize := SELF:_Header:EntrySize
        SELF:_keySize := SELF:_Header:KeySize
        SELF:_keyDecimals := SELF:_Header:KeyDecimals
        SELF:_MaxEntry := SELF:_Header:MaxItem
        SELF:_halfPage := SELF:_Header:HalfPage
        SELF:_indexVersion := SELF:_Header:IndexingVersion
        SELF:_firstPageOffset := SELF:_Header:FirstPageOffset
        SELF:_nextUnusedPageOffset := SELF:_Header:NextUnusedPageOffset
        SELF:_Unique := SELF:_Header:Unique
        SELF:_Descending := SELF:_Header:Descending
        //
        SELF:_midItem := NtxItem{SELF:_keySize}
        SELF:_oneItem := NtxItem{SELF:_keySize}
        IF string.IsNullOrEmpty(SELF:_Header:OrdName)
            SELF:_orderName := Path.GetFileNameWithoutExtension(SELF:fileName)
        ELSE
            SELF:_orderName := SELF:_Header:OrdName:ToUpper()
        ENDIF
        IF SELF:_Header:Signature:HasFlag(NtxHeaderFlags.HpLock)
            SELF:_HPLocking := TRUE
        ENDIF
        //
        // Standard Locking Scheme
        SELF:_lockScheme:Initialize( DbfLockingModel.Clipper52 )
        // Except
        IF SELF:_Header:Signature:HasFlag(NtxHeaderFlags.NewLock)
            SELF:_lockScheme:Offset := -1
        ENDIF
        // NTX has only one Tag index
        SELF:_tagNumber := 1
        SELF:_maxLockTries := 99 //(LONG)XSharp.RuntimeState.LockTries
        SELF:_readLocks := 0
        //
        isOk := TRUE
        IF SELF:_HPLocking .AND. SELF:_Shared
            //DO
            REPEAT
                IF !SELF:_LockInit()
                    SELF:_oRDD:_dbfError( ERDD.INIT_LOCK, GenCode.EG_LOCK, "DBFNTX.LockInit", SELF:_fileName)
                    isOk := FALSE
                ENDIF
                //WHILE (!isOk)
            UNTIL isOk
        ENDIF
        IF !isOk
            SELF:Flush()
            SELF:Close()
        ENDIF
        RETURN isOk
                            
                            
                            
        DESTRUCTOR()
            Close()
                            
                            
        PUBLIC METHOD Flush() AS LOGIC
            IF !SELF:_Shared .AND. SELF:_Hot .AND. SELF:_hFile != F_ERROR
                SELF:GoCold()
                SELF:_PageList:Flush(TRUE)
                SELF:_Header:IndexingVersion        := 1
                SELF:_Header:NextUnusedPageOffset   := SELF:_nextUnusedPageOffset
                SELF:_Header:FirstPageOffset        := SELF:_firstPageOffset
                SELF:_Header:Write( )
            ENDIF
            FFlush( SELF:_hFile )
            RETURN TRUE
                            
                            
    PUBLIC METHOD Commit() AS LOGIC
        SELF:GoCold()
        IF !SELF:_Shared .AND. SELF:_Hot .AND. SELF:_hFile != F_ERROR
            SELF:_Header:IndexingVersion        := 1
            SELF:_Header:NextUnusedPageOffset   := SELF:_nextUnusedPageOffset
            SELF:_Header:FirstPageOffset        := SELF:_firstPageOffset
            SELF:_Header:Write( )
        ENDIF
        FFlush( SELF:_hFile )
        RETURN TRUE
                            
                            
        PUBLIC METHOD Close() AS LOGIC
            SELF:Flush()
            TRY
                IF SELF:_Shared .AND. SELF:_HPLocking
                    SELF:_LockExit()
                ENDIF
                IF SELF:_hFile != F_ERROR
                    FClose( SELF:_hFile )
                    SELF:_hFile := F_ERROR
                ENDIF
                                
            FINALLY
                SELF:_HPLocking := FALSE
                SELF:_hFile := F_ERROR
            END TRY
            RETURN TRUE
                            
                            
        PUBLIC METHOD GoCold() AS LOGIC
            IF SELF:_oRDD:IsHot
                RETURN SELF:_KeyUpdate((DWORD) SELF:_oRDD:RecNo, SELF:_oRDD:IsNewRecord )
            ENDIF
            RETURN TRUE
                            
                            
        PRIVATE METHOD _KeyUpdate(recordNo AS DWORD , lNewRecord AS LOGIC ) AS LOGIC
            LOCAL condFor := TRUE AS LOGIC
            LOCAL num AS DWORD
            LOCAL noMoreLock AS LOGIC
            LOCAL errorLevel AS LONG
            LOCAL lockCount AS DWORD
            num := 0
            noMoreLock := TRUE
            errorLevel := 0
            lockCount := 0
            DO WHILE TRUE
                IF SELF:_Shared
                    IF SELF:_HPLocking
                        lockCount := SELF:_readLocks
                        DO WHILE SELF:_readLocks != 0
                            noMoreLock := SELF:_ReadUnLock()
                            IF !noMoreLock
                                errorLevel := 2
                                EXIT
                            ENDIF
                        ENDDO
                    ENDIF
                    IF noMoreLock .AND. !SELF:_WriteLock()
                        errorLevel := 2
                        EXIT
                    ENDIF
                ENDIF
                LOCAL evalOk AS LOGIC
                IF SELF:_Conditional
                    evalOk := TRUE
                    TRY
                        condFor := (LOGIC)SELF:_oRdd:EvalBlock(SELF:_ForCodeBlock)
                    CATCH
                        evalOk := FALSE
                        SELF:_oRdd:_dbfError( SubCodes.ERDD_KEY_EVAL,GenCode.EG_DATATYPE, SELF:fileName)
                    END TRY
                    IF !evalOk
                        errorLevel := 1
                        EXIT
                    ENDIF
                ENDIF
                evalOk := TRUE
                LOCAL oValue AS OBJECT
                TRY
                    oValue := SELF:_oRdd:EvalBlock(SELF:_KeyCodeBlock)
                CATCH
                    oValue := NULL
                    evalOk := FALSE
                END TRY
                IF !evalOk
                    errorLevel := 1
                ELSE
                    LOCAL changed := FALSE AS LOGIC
                    IF !SELF:_ToString(oValue, SELF:_keySize, SELF:_keyDecimals, SELF:_newKeyBuffer, SELF:_Ansi)
                        errorLevel := 1
                    ELSE
                        IF !lNewRecord
                            changed := SELF:__Compare(SELF:_newKeyBuffer, SELF:_knownKeyBuffer, SELF:_keySize) != 0
                            IF changed
                                SELF:_TopStack := 0u
                            ENDIF
                            num := SELF:_goRecord(SELF:_knownKeyBuffer, SELF:_keySize, recordNo)
                            IF (SELF:_TopStack != 0 .AND. !SELF:_Conditional) .OR. num != 0
                                IF changed .OR. !condFor
                                    SELF:_deleteKey()
                                ENDIF
                            ELSE
                                IF !SELF:_Unique .AND. !SELF:_Conditional .AND. !SELF:_Partial
                                    SELF:_oRdd:_dbfError( SubCodes.ERDD_KEY_NOT_FOUND, GenCode.EG_DATATYPE,SELF:fileName)
                                ENDIF
                            ENDIF
                        ENDIF
                        IF (lNewRecord .OR. changed) .AND. condFor
                            SELF:_midItem:KeyBytes := SELF:_newKeyBuffer
                            SELF:_midItem:PageNo := 0
                            SELF:_midItem:Recno := recordNo
                            SELF:_TopStack := 0u
                            IF SELF:_Unique
                                IF SELF:_locate(SELF:_midItem:KeyBytes, SELF:_keySize, NtxSearchMode.Left, (LONG)SELF:_firstPageOffset) == 0
                                    SELF:_AddKey()
                                ELSE
                                    SELF:_TopStack := 0
                                ENDIF
                            ELSE
                                SELF:_locate(SELF:_midItem:KeyBytes, SELF:_keySize, NtxSearchMode.Right, (LONG)SELF:_firstPageOffset)
                                SELF:_AddKey()
                            ENDIF
                            SELF:_TopStack := 0u
                            SELF:_Hot := TRUE
                        ENDIF
                        Array.Copy(SELF:_newKeyBuffer, SELF:_knownKeyBuffer, SELF:_keySize + 1)
                        SELF:_knownRecno := recordNo
                        errorLevel := 0
                    ENDIF
                ENDIF
                EXIT
            ENDDO 
            IF errorLevel <= 1
                IF SELF:_Shared
                    SELF:_PageList:Flush(TRUE)
                    SELF:_indexVersion++
                    SELF:_PutHeader()
                    SELF:_Hot := FALSE
                    FFlush( SELF:_hFile )
                    SELF:_WriteUnLock()
                    IF SELF:_HPLocking
                        DO WHILE (lockCount != 0) .AND. (!SELF:_ReadLock())
                            lockCount--
                        ENDDO
                    ENDIF
                ENDIF
                RETURN TRUE
            ENDIF
            IF errorLevel == 2
                SELF:_oRdd:_dbfError( SubCodes.ERDD_KEY_EVAL, GenCode.EG_DATATYPE)
                RETURN FALSE
            ENDIF
            RETURN TRUE
                            
                            
        INTERNAL METHOD _keySave(rcno AS DWORD ) AS LOGIC
            LOCAL isOk AS LOGIC
            LOCAL uiRealLen AS LONG
            //
            isOk := TRUE
            uiRealLen := 0
            IF rcno != SELF:_knownRecno .OR. SELF:_Shared
                SELF:_knownRecno := 0u
                VAR oValue := SELF:_oRdd:EvalBlock(SELF:_KeyCodeBlock)
                isOk := ( oValue != NULL )
                IF isOk
                    isOk := SELF:_ToString(oValue, SELF:_keySize, SELF:_keyDecimals, SELF:_knownKeyBuffer, SELF:_Ansi, REF uiRealLen)
                    IF isOk
                        SELF:_knownRecno := rcno
                    ENDIF
                ENDIF
            ENDIF
            IF !isOk
                SELF:_oRdd:_dbfError(SubCodes.ERDD_KEY_EVAL, GenCode.EG_DATATYPE, SELF:fileName)
            ENDIF
            RETURN isOk
                            
                            
        PUBLIC METHOD Truncate() AS LOGIC
            SELF:_firstPageOffset := NtxConst.BUFF_SIZE
            SELF:_nextUnusedPageOffset := 0
            SELF:_Hot := TRUE
            SELF:ClearStack()
            SELF:_knownRecno := 0
            FChSize( SELF:_hFile, NtxConst.BUFF_SIZE )
            SELF:_fileSize := NtxConst.BUFF_SIZE
            SELF:Flush()
            RETURN TRUE
                            
                            
        PUBLIC METHOD SetOffLine() AS VOID
            SELF:ClearStack()
                            
                            
        PRIVATE METHOD _getHeader() AS LOGIC
            LOCAL changed AS LOGIC
            //
            changed := TRUE
            IF SELF:_Header:Read()
                changed := (SELF:_indexVersion != SELF:_Header:IndexingVersion)
                SELF:_indexVersion := SELF:_Header:IndexingVersion
                SELF:_firstPageOffset := SELF:_Header:FirstPageOffset
                SELF:_nextUnusedPageOffset := SELF:_Header:NextUnusedPageOffset
            ENDIF
            RETURN changed
                            
                            
        PRIVATE METHOD _PutHeader() AS LOGIC
            LOCAL ntxSignature AS NtxHeaderFlags
            //
            ntxSignature := NtxHeaderFlags.Default
            IF SELF:_Conditional .OR. SELF:_Descending
                ntxSignature |= NtxHeaderFlags.Conditional
            ENDIF
            IF SELF:_Partial
                ntxSignature |= NtxHeaderFlags.Partial
            ENDIF
            IF SELF:_HPLocking
                ntxSignature |= NtxHeaderFlags.HpLock
            ENDIF
            IF  SELF:_lockScheme:Offset == -1
                ntxSignature |= NtxHeaderFlags.NewLock
            ENDIF
            SELF:_Header:Signature              := ntxSignature
            SELF:_Header:IndexingVersion        := SELF:_indexVersion
            SELF:_Header:FirstPageOffset        := SELF:_firstPageOffset
            SELF:_Header:NextUnusedPageOffset   := SELF:_nextUnusedPageOffset
            RETURN SELF:_Header:Write()
                            
            // Save informations about the "current" Item	
        PRIVATE METHOD _saveRecordState( node AS NtxItem ) AS VOID
            SELF:_knownRecno := node:Recno
            Array.Copy(node:KeyBytes, SELF:_knownKeyBuffer, SELF:_keySize)
                            
                            
        PUBLIC METHOD Create(createInfo AS DBORDERCREATEINFO ) AS LOGIC
            LOCAL ordCondInfo AS DBORDERCONDINFO
            LOCAL isOk AS LOGIC
            LOCAL orderInfo AS DBORDERINFO
            LOCAL hasForCond AS LOGIC
            LOCAL Expression AS STRING
            LOCAL i AS LONG
            LOCAL num AS WORD
            //
            ordCondInfo := SELF:_oRdd:_OrderCondInfo
            IF string.IsNullOrEmpty(createInfo:BagName)
                SELF:_oRDD:_dbfError( GenCode.EG_ARG, SubCodes.EDB_CREATEINDEX)
                RETURN FALSE
            ENDIF
            isOk := SELF:_oRdd:GoCold()
            orderInfo := DBORDERINFO{}
            IF !ordCondInfo:Scoped
                orderInfo:AllTags := TRUE
                SELF:_oRdd:OrderListDelete(orderInfo)
            ENDIF
            SELF:_hFile := F_ERROR
            IF ordCondInfo:ForBlock != NULL
                hasForCond := TRUE
                SELF:_ForCodeBlock := ordCondInfo:ForBlock
            ELSE
                hasForCond := FALSE
            ENDIF
            Expression := createInfo:Expression
            IF createInfo:Block != NULL
                SELF:_KeyCodeBlock := createInfo:Block
            ELSE
                TRY
                    SELF:_oRdd:Compile(Expression)
                CATCH
                    isOk := FALSE
                END TRY
                IF isOk
                    SELF:_KeyCodeBlock := (ICodeblock)SELF:_oRdd:_LastCodeBlock
                ENDIF
            ENDIF
            SELF:_oRdd:GoToId(1)
            VAR oValue          := SELF:_oRdd:EvalBlock(SELF:_KeyCodeBlock) 
            SELF:_KeyExprType   := SELF:_getTypeCode(oValue)
            SELF:_KeyExpr := createInfo:Expression
            IF ordCondInfo != NULL .AND. ordCondInfo:ForExpression != NULL
                SELF:_ForExpr := ordCondInfo:ForExpression
            ELSE
                SELF:_ForExpr := string.Empty
            ENDIF
            SELF:_orderName := (STRING)createInfo:Order
            IF string.IsNullOrEmpty(SELF:_orderName)
                SELF:_orderName := Path.GetFileNameWithoutExtension(createInfo:BagName)
            ENDIF
            SELF:_SingleField := -1
            //Init
            FOR i := 0 TO ( SELF:_oRdd:_fields:Length - 1)
                IF string.Compare(SELF:_KeyExpr, SELF:_oRdd:_fields[i]:Name, TRUE) == 0
                    SELF:_SingleField := i
                    SELF:_keySize       := (WORD) SELF:_oRdd:_fields[i]:Length
                    SELF:_keyDecimals   := (WORD)SELF:_oRdd:_fields[i]:Decimals
                    EXIT
                ENDIF
            NEXT
            isOk := TRUE
            IF SELF:_SingleField == -1
                SELF:_keyDecimals := 0
                SELF:_keySize := 0
                isOk := SELF:_determineSize(oValue)
            ENDIF
            IF !isOk .OR. SELF:_keySize == 0
                SELF:Close()
                SELF:_oRdd:_dbfError( SubCodes.ERDD_NULLKEY, GenCode.EG_DATAWIDTH,createInfo:BagName)
                RETURN FALSE
            ENDIF
            IF SELF:_keySize > 0
                SELF:_knownKeyBuffer := BYTE[]{_Keysize+1}
                SELF:_newKeyBuffer   := BYTE[]{_Keysize+1}
            ENDIF

            // 8 Bytes : PrevPage (4 bytes) + Recno (4 bytes)
            SELF:_entrySize := SELF:_keySize + (WORD) 8
            //
            num := (WORD)(  ( NtxConst.BUFF_SIZE - 4) / (SELF:_keySize + 10))
            SELF:_halfPage := (WORD) ((num - 1) / 2)
            SELF:_MaxEntry := (WORD) (SELF:_halfPage * 2)
            SELF:_firstPageOffset := NtxConst.BUFF_SIZE
            SELF:_fileSize := 0
            SELF:_nextUnusedPageOffset := 0
            SELF:_indexVersion := 1
            SELF:_Shared := FALSE
            SELF:_Hot := TRUE
            SELF:_TopStack := 0u
            SELF:_Unique := createInfo:Unique
            SELF:_Ansi := SELF:_oRdd:_Ansi
            SELF:_Conditional := FALSE
            SELF:_Descending := FALSE
            SELF:_writeLocks := 0
            SELF:_Partial := ordCondInfo:Scoped
            SELF:_HPLocking := FALSE
            IF ordCondInfo:Active
                SELF:_Descending := ordCondInfo:Descending
                IF hasForCond .AND. !string.IsNullOrEmpty(ordCondInfo:ForExpression)
                    SELF:_Conditional := TRUE
                ENDIF
            ENDIF
            SELF:fileName := createInfo:BagName
            //
            TRY
                SELF:_hFile    := FCreate( SELF:fileName) 
                IF SELF:_hFile != F_ERROR 
                    FClose( SELF:_hFile )
                ENDIF
                SELF:_hFile := F_ERROR
            CATCH
                SELF:Close()
                SELF:_oRdd:_dbfError( SubCodes.ERDD_CREATE_ORDER, GenCode.EG_CREATE,createInfo:BagName)
                RETURN FALSE
            END TRY
            // To create an index we want to open the NTX NOT shared and NOT readonly
            VAR oldShared   := SELF:_oRDD:_Shared
            VAR oldReadOnly := SELF:_oRDD:_ReadOnly 
            SELF:_oRDD:_Shared := FALSE
            SELF:_oRDD:_ReadOnly  := FALSE
            SELF:_hFile    := Fopen(SELF:FileName, SELF:_oRDD:_OpenInfo:FileMode)
            SELF:_oRDD:_Shared := oldShared
            SELF:_oRDD:_ReadOnly  := oldReadOnly

            IF SELF:_hFile == F_ERROR
                SELF:Close()
                SELF:_oRdd:_dbfError( SubCodes.ERDD_CREATE_ORDER, GenCode.EG_CREATE, createInfo:BagName)
                RETURN FALSE
            ENDIF
            SELF:_PageList := NtxPageList{SELF}
            //
            SELF:_Header := NtxHeader{ SELF:_hFile }
            SELF:_Header:Signature              := NtxHeaderFlags.Default
            SELF:_Header:IndexingVersion        := SELF:_indexVersion
            SELF:_Header:FirstPageOffset        := SELF:_firstPageOffset
            SELF:_Header:NextUnusedPageOffset   := SELF:_nextUnusedPageOffset
            SELF:_Header:EntrySize              := (WORD)SELF:_entrySize
            SELF:_Header:KeySize                := (WORD)SELF:_keySize
            SELF:_Header:KeyDecimals            := (WORD)SELF:_keyDecimals
            SELF:_Header:MaxItem                := (WORD)SELF:_MaxEntry
            SELF:_Header:HalfPage               := (WORD)SELF:_halfPage
            SELF:_Header:Unique                 := SELF:_Unique
            SELF:_Header:Descending             := SELF:_Descending
            SELF:_Header:KeyExpression          := SELF:_KeyExpr
            SELF:_Header:ForExpression          := SELF:_ForExpr
            SELF:_Header:OrdName                := SELF:_orderName
            SELF:_midItem                       := NtxItem{SELF:_keySize}
            SELF:_oneItem                       := NtxItem{SELF:_keySize}
            IF SELF:_Conditional .OR. SELF:_Descending .OR. ordCondInfo:Scoped
                SELF:_Header:Signature |= NtxHeaderFlags.Conditional
            ENDIF
            IF SELF:_Partial
                SELF:_Header:Signature |= NtxHeaderFlags.Partial
            ENDIF
            SELF:_maxLockTries := 99 //(LONG)XSharp.RuntimeState.LockTries
            SELF:_tagNumber := 1
            SELF:_lockScheme:Initialize( DbfLockingModel.Clipper52 )
            IF  XSharp.RuntimeState.NewIndexLock 
                SELF:_Header:Signature |= NtxHeaderFlags.NewLock
                SELF:_lockScheme:Offset := -1
            ENDIF
            IF  XSharp.RuntimeState.HPLocking
                SELF:_HPLocking := TRUE
                SELF:_Header:Signature |= NtxHeaderFlags.Partial
            ENDIF
            IF !SELF:_Header:Write()
                SELF:Close()
                SELF:_oRdd:_dbfError(SubCodes.ERDD_WRITE,GenCode.EG_CREATE,  createInfo:BagName)
                RETURN FALSE
            ENDIF
            SELF:_fileSize += NtxConst.BUFF_SIZE
            IF !SELF:_Unique .AND. !SELF:_Conditional .AND. !SELF:_Descending .AND. !ordCondInfo:Scoped
                isOk := SELF:_CreateIndex()
            ELSE
                isOk := SELF:_CreateUnique(ordCondInfo)
            ENDIF
            IF !isOk
                SELF:Flush()
                SELF:Close()
                RETURN isOk
            ENDIF
            RETURN SELF:Flush()
                            
                            
        PRIVATE METHOD _determineSize(toConvert AS OBJECT ) AS LOGIC
            LOCAL tCode AS TypeCode
            LOCAL expr AS STRING
            LOCAL anyOf AS CHAR[]
            LOCAL nPos AS INT
            LOCAL sysType AS System.Type
            LOCAL strType AS STRING
            //
            sysType := toConvert:GetType()
            strType := sysType:ToString()
            // Compatibility ??
            BEGIN SWITCH strType
            CASE "XSharp.__Date"
                tCode := TypeCode.DateTime
            CASE "XSharp.__Float"
                tCode := TypeCode.Double
            OTHERWISE
                    //
                tCode := Type.GetTypeCode(sysType)
            END SWITCH
            //
            BEGIN SWITCH tCode
            CASE TypeCode.String
                SELF:_keySize := (WORD) ((STRING)toConvert):Length
            CASE TypeCode.Int16
            CASE TypeCode.UInt16
            CASE TypeCode.Int32
            CASE TypeCode.UInt32
            CASE TypeCode.Int64
            CASE TypeCode.UInt64
            CASE TypeCode.Single
            CASE TypeCode.Double
            CASE TypeCode.Decimal
                TRY
                    expr := "STR(" + SELF:_KeyExpr + ")"
                    TRY
                        VAR oBlock := SELF:_oRdd:Compile(expr)
                        expr := (STRING) SELF:_oRdd:EvalBlock(oBlock)
                    CATCH
                        RETURN FALSE
                    END TRY
                    SELF:_keySize := (WORD) expr:Length
                    anyOf := <CHAR>{',', '.' }
                    nPos := expr:IndexOfAny(anyOf)
                    IF nPos < 0
                        SELF:_keyDecimals := 0
                    ELSE
                        SELF:_keyDecimals := (WORD) (SELF:_keySize - nPos - 1)
                    ENDIF
                                
            CATCH //Exception
            END TRY
        CASE TypeCode.DateTime
            SELF:_keySize := 8
        CASE TypeCode.Boolean
            SELF:_keySize := 1
        OTHERWISE
                SELF:_keySize := 0
            RETURN FALSE
        END SWITCH
            IF SELF:_keySize > 0
                SELF:_knownKeyBuffer := BYTE[]{_Keysize+1}
                SELF:_newKeyBuffer   := BYTE[]{_Keysize+1}
            ENDIF

        RETURN TRUE
                    
        PRIVATE METHOD _ToString( toConvert AS OBJECT , sLen AS LONG , nDec AS LONG , buffer AS BYTE[] , isAnsi AS LOGIC ) AS LOGIC    
            LOCAL resultLength AS LONG
            //
            resultLength := 0
            RETURN SELF:_ToString( toConvert, sLen, nDec, buffer, isAnsi, REF resultLength)
                    
                    
        PRIVATE METHOD _ToString( toConvert AS OBJECT , sLen AS LONG , nDec AS LONG , buffer AS BYTE[] , isAnsi AS LOGIC , resultLength REF LONG ) AS LOGIC
            LOCAL text AS STRING
            LOCAL chkDigits AS LOGIC
            LOCAL typeCde AS TypeCode
            LOCAL valueFloat AS IFloat
            LOCAL sBuilder AS StringBuilder
            LOCAL valueDate AS IDate
            LOCAL formatInfo AS NumberFormatInfo
            //
            formatInfo := NumberFormatInfo{}
            formatInfo:NumberDecimalSeparator := "."
            //
            text := NULL
            chkDigits := FALSE
            // Float Value ?
            IF (toConvert ASTYPE IFloat) != NULL
                valueFloat := (IFloat)toConvert
                toConvert := valueFloat:Value
                formatInfo:NumberDecimalDigits := valueFloat:Decimals
                typeCde := TypeCode.Double
                text := valueFloat:Value:ToString("F", formatInfo)
                // Too long ?
                IF text:Length > sLen
                    sBuilder := StringBuilder{}
                    text := sBuilder:Insert(0, "*", sLen):ToString()
                    SELF:_oRDD:_Encoding:GetBytes( text, 0, slen, buffer, 0)
                    resultLength := text:Length
                    RETURN FALSE
                ENDIF
                IF text:Length < sLen
                    text := text:PadLeft(sLen, ' ')
                    chkDigits := TRUE
                ENDIF
            ELSE
                IF (toConvert ASTYPE IDate) != NULL
                    valueDate := (IDate)toConvert
                    text := valueDate:Value:ToString("yyyyMMdd")
                    typeCde := TypeCode.String
                ELSE
                    typeCde := Type.GetTypeCode(toConvert:GetType())
                ENDIF
            ENDIF
            IF text == NULL
                SWITCH typeCde
                CASE TypeCode.String
                    text := (STRING)toConvert
                CASE TypeCode.Int16
                CASE TypeCode.Int32
                CASE TypeCode.Int64
                CASE TypeCode.Single
                CASE TypeCode.Double
                CASE TypeCode.Decimal
                    formatInfo:NumberDecimalDigits := nDec
                    SWITCH typeCde
                    CASE TypeCode.Int32
                        text := ((LONG)toConvert):ToString("F", formatInfo)
                    CASE TypeCode.Double
                        text := ((REAL8)toConvert):ToString("F", formatInfo)
                    OTHERWISE
                        text := ((Decimal)toConvert):ToString("F", formatInfo)
                    END SWITCH
                    VAR length := text:Length
                    IF length > sLen
                        sBuilder := StringBuilder{}
                        text := sBuilder:Insert(0, "*", sLen):ToString()
                        SELF:_oRDD:_Encoding:GetBytes( text, 0, slen, buffer, 0)
                        resultLength := text:Length
                        RETURN FALSE
                    ENDIF
                    text := text:PadLeft(sLen, ' ')
                    chkDigits := TRUE
                CASE TypeCode.DateTime
                    text := ((DateTime)toConvert):ToString("yyyyMMdd")
                CASE TypeCode.Boolean
                    text := (IIF(((LOGIC)toConvert) , "T" , "F"))
                OTHERWISE
                    RETURN FALSE
                END SWITCH
            ENDIF
            IF sLen > text:Length
                sLen := text:Length
            ENDIF
            SELF:_oRDD:_Encoding:GetBytes( text, 0, slen, buffer, 0)
            IF chkDigits
                SELF:_checkDigits(buffer, SELF:_keySize, SELF:_keyDecimals )
            ENDIF
            resultLength := text:Length
            RETURN TRUE

    PRIVATE METHOD GetNumFieldValue(sourceIndex AS LONG, byteArray AS BYTE[]) AS LOGIC
        Array.Copy(SELF:_oRdd:_RecordBuffer, sourceIndex, byteArray, 0, SELF:_keySize)
        SELF:_checkDigits(byteArray, SELF:_keySize, SELF:_keyDecimals)
        RETURN TRUE

   PRIVATE METHOD GetFieldValue(sourceIndex AS LONG, byteArray AS BYTE[]) AS LOGIC
        Array.Copy(SELF:_oRdd:_RecordBuffer, sourceIndex, byteArray, 0, SELF:_keySize)
        RETURN TRUE

    PRIVATE METHOD GetExpressionValue(sourceIndex AS LONG, byteArray AS BYTE[]) AS LOGIC
        LOCAL result := TRUE AS LOGIC
        TRY
            VAR oKeyValue := SELF:_oRdd:EvalBlock(SELF:_KeyCodeBlock)
            LOCAL uiRealLen := 0 AS LONG
            result := SELF:_ToString(oKeyValue, SELF:_keySize, SELF:_keyDecimals, byteArray, SELF:_Ansi, REF uiRealLen)
        CATCH
            result := FALSE
        END TRY
        RETURN result
    PRIVATE DELEGATE ValueBlock( sourceIndex AS LONG, byteArray AS BYTE[]) AS LOGIC
    INTERNAL METHOD _CreateIndex() AS LOGIC
        LOCAL fType AS DbFieldType
        LOCAL sourceIndex AS LONG
        LOCAL evalCount AS LONG
        LOCAL lRecCount AS LONG
        LOCAL sortInfo AS DbSortInfo
        LOCAL hasBlock AS LOGIC
        LOCAL sorting AS RddSortHelper
        LOCAL byteArray AS BYTE[]
        LOCAL result AS LOGIC
        LOCAL ic AS NtxSortCompare
        
        LOCAL lAscii AS LOGIC
        LOCAL getKeyValue AS ValueBlock
        //
        fType := 0
        sourceIndex := 0
        evalCount := 0
        lRecCount := (LONG)SELF:_oRdd:RecCount
        IF lRecCount == 0
            RETURN SELF:_CreateEmpty()
        ENDIF
        sortInfo := DbSortInfo{0,1}     // 0 trans items, 1 sort item
        hasBlock    := SELF:_oRdd:_OrderCondInfo:EvalBlock != NULL
        evalCount := 1
        SELF:_levelsCount := 1u
        IF SELF:_SingleField != -1
            fType := SELF:_oRdd:_Fields[SELF:_SingleField]:fieldType
        ENDIF
        // 'C', 'N', 'D'
        SWITCH fType
        CASE DbFieldType.Character
        CASE DbFieldType.Number
        CASE DbFieldType.Date
            sourceIndex := SELF:_oRdd:_Fields[SELF:_SingleField]:OffSet
        OTHERWISE
            fType := 0
        END SWITCH
        //
        sorting := RddSortHelper{sortInfo, (DWORD)lRecCount}
        sortInfo:Items[0]:Length := SELF:_keySize
        IF SELF:_KeyExprType == TypeCode.String
            lAscii := FALSE
            sortInfo:Items[0]:Flags := DbSortFlags.Default
        ELSE
            lAscii := TRUE
            sortInfo:Items[0]:Flags := DbSortFlags.Ascii
        ENDIF
        IF SELF:_oRdd:_OrderCondInfo:Descending
            sortInfo:Items[0]:Flags += DbSortFlags.Descending
        ENDIF
        sortInfo:Items[0]:OffSet := 0
        SELF:_oRdd:GoTo(1)
        byteArray := BYTE[]{ SELF:_keySize }
        IF SELF:_SingleField != -1 .AND. fType != 0
            IF fType ==  DbFieldType.Number
                getKeyValue := GetNumFieldValue
            ELSE
                getKeyValue := GetFieldValue
            ENDIF
        ELSE
            getKeyValue := GetExpressionValue
        ENDIF
        REPEAT
            result := TRUE
            SELF:_oRdd:ReadRecord()
            result := getKeyValue(sourceIndex, byteArray)
            IF !result
                EXIT
            ENDIF
            VAR toSort := NTXSortRecord{byteArray, (DWORD) SELF:_oRdd:RecNo}
            sorting:Add(toSort)
            IF hasBlock
                IF evalCount >= SELF:_oRdd:_OrderCondInfo:StepSize
                    TRY
                        SELF:_oRdd:EvalBlock(SELF:_oRdd:_OrderCondInfo:EvalBlock)
                    CATCH
                        result := FALSE
                    END TRY
                    evalCount := 1
                ELSE
                    evalCount++
                ENDIF
            ENDIF
            result := SELF:_oRdd:GoTo(SELF:_oRdd:RecNo + 1)
        UNTIL ! (result .AND. SELF:_oRdd:_isValid)
        IF result
            IF lAscii
                ic := NTXSortCompareAscii{SELF:_oRdd, sortInfo}
            ELSE
                ic := NTXSortCompareDefault{SELF:_oRdd, sortInfo}
            ENDIF
            result := sorting:Sort(ic)
        ENDIF
        SELF:_levelsCount := SELF:_initLevels(SELF:_MaxEntry + 1, lRecCount)
        SELF:_outPageNo := 1
        IF result
            result := sorting:Write(SELF)
        ENDIF
        sorting:Clear()
        sorting := NULL
        SELF:_oneItem:PageNo := 0
        SELF:_placeItem(SELF:_oneItem)
        SELF:_firstPageOffset := (DWORD)SELF:_oneItem:PageNo
        SELF:_nextUnusedPageOffset := 0
        VAR lpLevels := SELF:_levels
        FOREACH level AS NtxLevel IN lpLevels 
            IF level != NULL
                IF level:PageOffset == 0
                    level:PageOffset := SELF:_outPageNo * NtxConst.BUFF_SIZE
                    SELF:_outPageNo++
                ENDIF
                level:Write(level:PageOffset)
            ENDIF
        NEXT
        FSeek3( SELF:_hFile, 0, FS_END )
        SELF:_fileSize  := (LONG)FTell( SELF:_hFile ) 
                    
        SELF:_levels := NULL
        RETURN result
                    
                       
    PRIVATE METHOD _checkDigits(buffer AS BYTE[] , length AS LONG , decimals AS LONG ) AS VOID
        LOCAL i := 0 AS LONG
        // Transform starting spaces with zeros
        DO WHILE buffer[i] == 32 .AND. i < length
            buffer[i] := (BYTE)'0'
            i++
        ENDDO
        IF i == length  // all spaces , now converted to all zeroes.
            // It must be a decimal value ?
            IF decimals != 0
                buffer[length - decimals - 1] := (BYTE)'.'
            ENDIF
        ENDIF
        IF buffer[i] == '-'
            i++
            FOR VAR j := 0 TO i-1 STEP 1
                buffer[j] := 44 // ,
            NEXT
            FOR VAR j := i TO length -1 STEP 1
                buffer[j] := (BYTE) (92 - buffer[j])
            NEXT
        ENDIF
        RETURN

        // IRddSortWriter Interface, used by RddSortHelper
        PUBLIC METHOD WriteSorted(si AS DbSortInfo , o AS OBJECT ) AS LOGIC
            LOCAL record AS NTXSortRecord
            record                  := (NTXSortRecord)o
            SELF:_oneItem:PageNo    := 0
            SELF:_oneItem:Recno     := record:Recno
            SELF:_oneItem:KeyBytes  := record:Data
            RETURN SELF:_placeItem(SELF:_oneItem)
                    
                    
        INTERNAL METHOD _CreateUnique(ordCondInfo AS DBORDERCONDINFO ) AS LOGIC
            LOCAL Ok AS LOGIC
            Ok := SELF:_CreateEmpty()
            IF Ok
                IF ordCondInfo:Active
                    RETURN SELF:_CondCreate(ordCondInfo)
                ENDIF
                SELF:_oRdd:GoTo(1)
                IF SELF:_oRdd:_isValid
                    REPEAT
                        SELF:_KeyUpdate((DWORD) SELF:_oRdd:RecNo, TRUE)
                        SELF:_oRdd:GoTo(SELF:_oRdd:RecNo + 1)
                    UNTIL ! SELF:_oRdd:_isValid
                ENDIF
                SELF:_TopStack := 0
            ENDIF
            SELF:Flush()
            RETURN Ok
                    
                    
        PRIVATE METHOD _initLevels(uiBOrder AS LONG , keyCount AS LONG ) AS DWORD
            LOCAL level AS DWORD
            LOCAL exp AS LONG
            LOCAL nLevel AS NtxLevel
            //
            level := 0
            exp := 1
            SELF:_levels := NtxLevel[]{ 16 }
            DO WHILE exp <= keyCount
                nLevel := NtxLevel{SELF}
                nLevel:Exp := exp
                nLevel:InitRefs(SELF:_MaxEntry, SELF:_entrySize)
                SELF:_levels[level] := nLevel
                level++
                exp *= uiBOrder
            ENDDO
            SELF:_RecalcLevel(level - 1, keyCount, 1)
            RETURN (DWORD) level
                    
                    
PRIVATE METHOD _CondCreate(ordCondInfo AS DBORDERCONDINFO ) AS LOGIC
    LOCAL isOk AS LOGIC
    LOCAL nOrder AS NtxOrder
    LOCAL hasWhile AS LOGIC
    LOCAL hasEvalBlock AS LOGIC
    LOCAL record AS DWORD
    LOCAL count AS DWORD
    LOCAL toDo AS DWORD
    LOCAL done AS DWORD
    LOCAL nextRecord AS DWORD
    LOCAL start AS DWORD
    LOCAL result AS LOGIC
    //
    isOk := TRUE
    nOrder := NULL
    hasWhile := FALSE
    hasEvalBlock := FALSE
    record := 1
    count := 1
    nextRecord := 0
    toDo := 0
    done := 0
    start := (DWORD)ordCondInfo:StartRecNo
    IF ordCondInfo:Scoped
        IF ordCondInfo:StartRecNo > 0
            record := (DWORD)ordCondInfo:StartRecNo
        ENDIF
        IF SELF:_oRdd:_ntxList:Focus != 0
            nOrder := SELF:_oRdd:_ntxList:CurrentOrder
        ENDIF
        IF ordCondInfo:All
            record := 1
            IF nOrder != NULL
                record := nOrder:_locateKey(NULL, 0, NtxSearchMode.Top)
            ENDIF
        ENDIF
    ENDIF
    IF ordCondInfo:RecNo > 0
        record := (DWORD)ordCondInfo:RecNo
        toDo := 1
    ENDIF
    IF ordCondInfo:NextCount > 0
        toDo := (DWORD)ordCondInfo:NextCount
    ENDIF
    SELF:_oRdd:GoTo((INT)record)
    IF !SELF:_oRdd:_isValid .AND. !SELF:_oRdd:_Eof
        SELF:_oRdd:GoTo((INT)start)
        SELF:_TopStack := 0
        RETURN FALSE
    ENDIF
    IF ordCondInfo:WhileBlock != NULL
        hasWhile := TRUE
    ENDIF
    IF ordCondInfo:EvalBlock != NULL
        hasEvalBlock := TRUE
    ENDIF
    IF nOrder != NULL .AND. nOrder:_TopStack != 0
        result := nOrder:_goTo((DWORD)SELF:_oRdd:RecNo)
        IF !result
            RETURN result
        ENDIF
    ENDIF
    REPEAT
        IF hasWhile
            isOk := TRUE
            TRY
                isOk := (LOGIC) SELF:_oRdd:EvalBlock(ordCondInfo:WhileBlock)
            CATCH
                SELF:_oRdd:_dbfError(SubCodes.ERDD_KEY_EVAL, GenCode.EG_DATATYPE, SELF:fileName)
                isOk := FALSE
            END TRY
            IF ! isOk
                EXIT
            ENDIF
            //
        ENDIF
        IF !SELF:_KeyUpdate((DWORD) SELF:_oRdd:RecNo, TRUE)
            EXIT
        ENDIF
        IF hasEvalBlock
            IF count >= ordCondInfo:StepSize
                isOk := TRUE
                TRY
                    isOk := (LOGIC) SELF:_oRdd:EvalBlock(ordCondInfo:EvalBlock)
                CATCH
                    SELF:_oRdd:_dbfError( SubCodes.ERDD_KEY_EVAL,GenCode.EG_DATATYPE, SELF:fileName)
                    isOk := FALSE
                END TRY
                IF ! isOk
                    EXIT
                ENDIF
                count := 1
            ELSE
                count++
            ENDIF
        ENDIF
        done++
        IF nOrder != NULL 
            nextRecord := _getNextKey(FALSE, NtxSkipDirection.Forward)
        ELSE
            nextRecord := (DWORD)SELF:_oRdd:RecNo + 1
        ENDIF
        SELF:_oRdd:GoToId(nextRecord)
    UNTIL !(toDo == 0 .OR. done < toDo) .AND. !SELF:_oRdd:_Eof .AND. SELF:_oRdd:_isValid
    SELF:_oRdd:GoToId(start)
    SELF:_TopStack := 0
    SELF:Flush()
    RETURN TRUE
                    
                    
PRIVATE METHOD _placeItem(lpNode AS NtxItem ) AS LOGIC
    LOCAL uiLevel AS DWORD
    LOCAL level AS NtxLevel
    LOCAL node AS NtxItem
    LOCAL page AS LONG
    //
    uiLevel := 0
    level := SELF:_levels[0]
    DO WHILE (uiLevel < SELF:_levelsCount) .AND. (level:NodeCount >= level:Parents)
        node := level[level:NodeCount]
        node:PageNo := SELF:_oneItem:PageNo
        page := SELF:_outPageNo * NtxConst.BUFF_SIZE
        SELF:_oneItem:PageNo := page
        level:PageOffset := page
        SELF:_outPageNo++
        uiLevel++
        level := SELF:_levels[uiLevel]
    ENDDO
    IF uiLevel >= SELF:_levelsCount
        RETURN FALSE
    ENDIF
    node := level[level:NodeCount]
    node:KeyBytes := lpNode:KeyBytes
    node:Recno := lpNode:Recno
    node:PageNo := lpNode:PageNo
    level:NodeCount++
    SELF:_oneItem:Clear()
    IF uiLevel > 0
        SELF:_ResetLevel(uiLevel - 1)
    ENDIF
    RETURN TRUE
                    
                    
PRIVATE METHOD _AddKey() AS LOGIC
    LOCAL uiHalfPage AS LONG
    LOCAL siSize AS WORD
    LOCAL page1 AS NtxPage
    LOCAL pageNo AS LONG
    LOCAL siRef AS WORD
    LOCAL i AS LONG
    LOCAL node AS NtxItem
    LOCAL page2 AS NtxPage
    LOCAL node2 AS NtxItem
    //
    SELF:_Hot := TRUE
    uiHalfPage := SELF:_halfPage
    siSize := SELF:_entrySize
    IF SELF:_TopStack == 0
        page1 := SELF:AllocPage()
        pageNo := page1:PageOffset
        siRef := (WORD) ((SELF:_MaxEntry + 2) * 2)
        FOR i := 0 TO SELF:_MaxEntry
            page1:SetRef(i, siRef)
            siRef := (siRef + siSize)
        NEXT
        node := page1[0]
        node:PageNo := (INT)SELF:_firstPageOffset
        node:Recno := SELF:_midItem:Recno
        node:KeyBytes := SELF:_midItem:KeyBytes
        node := page1[1]
        node:PageNo := SELF:_midItem:PageNo
        page1:NodeCount := 1
        SELF:_firstPageOffset := (DWORD)pageNo
        RETURN FALSE
    ENDIF
    page2 := SELF:_PageList:Update(SELF:_ntxStack[SELF:_TopStack]:Page)
    IF SELF:_insertKey(page2)
        page2:NodeCount := (WORD)uiHalfPage
        page1 := SELF:AllocPage()
        Array.Copy(page2:Bytes, page1:Bytes, NtxConst.BUFF_SIZE)
        FOR i := 0 TO uiHalfPage
            siRef := page1:GetRef(i)
            page1:SetRef(i, page1:GetRef(i + uiHalfPage))
            page1:SetRef(i + uiHalfPage, siRef)
        NEXT
        node2 := page1[0]
        node2:PageNo := SELF:_midItem:PageNo
        SELF:_midItem:PageNo := page1:PageOffset
        SELF:_TopStack--
        SELF:_AddKey()
        RETURN FALSE
    ENDIF
    RETURN TRUE
                    
                    
PRIVATE METHOD _insertKey(page AS NtxPage ) AS LOGIC
    LOCAL nodeCount AS LONG
    LOCAL uiPos AS LONG
    LOCAL offset AS WORD
    LOCAL node2 AS NtxItem
    LOCAL num AS LONG
    LOCAL node AS NtxItem
    LOCAL uiHalfPage AS LONG
    LOCAL num2 AS LONG
    LOCAL num3 AS LONG
    LOCAL num4 AS LONG
    LOCAL node3 AS NtxItem
    LOCAL ntxNode AS NtxItem
    LOCAL node4 AS NtxItem
    LOCAL pageNo AS LONG
    //
    nodeCount := page:NodeCount
    uiPos := SELF:_ntxStack[SELF:_TopStack]:Pos
    IF nodeCount < SELF:_MaxEntry
        offset := page:GetRef(nodeCount + 1)
        //Init
        num := nodeCount + 1
        DO WHILE num > uiPos
            page:SetRef(num, page:GetRef(num - 1))
            //Iterators
            num--
        ENDDO
        page:SetRef(uiPos, offset)
        node := page[uiPos]
        node:PageNo := page[uiPos + 1]:PageNo
        node := page[uiPos + 1]
        node:PageNo := SELF:_midItem:PageNo
        node2 := page[uiPos]
        node2:Recno := SELF:_midItem:Recno
        node2:KeyBytes := SELF:_midItem:KeyBytes
        page:NodeCount++
        RETURN FALSE
    ENDIF
    uiHalfPage := SELF:_halfPage
    IF uiPos == SELF:_halfPage
        RETURN TRUE
    ENDIF
    IF uiPos < SELF:_halfPage
        num2 := -1
        num3 := 1
        num4 := -1
    ELSE
        num2 := 0
        num3 := 0
        num4 := 1
    ENDIF
    node3 := page[uiHalfPage + num2]
    ntxNode := NtxItem{SELF:_keySize}
    ntxNode:Recno := node3:Recno
    ntxNode:KeyBytes := node3:KeyBytes
    node3 := page[uiHalfPage + num2 + 1]
    ntxNode:PageNo := node3:PageNo
    node4 := page[uiHalfPage + num2 + 1]
    node4:PageNo := page[uiHalfPage + num2]:PageNo
    offset := page:GetRef(uiHalfPage + num2)
    //Init
    num := uiHalfPage + num2
    DO WHILE num + num3 != uiPos
        page:SetRef(num, page:GetRef(num + num4))
        //Iterators
        num += num4
    ENDDO
    page:SetRef(uiPos - (num3 + num4), offset)
    node2 := page[uiPos + num3]
    pageNo := node2:PageNo
    node2:PageNo := SELF:_midItem:PageNo
    node2 := page[uiPos + num3 - 1]
    node2:PageNo := pageNo
    node2:Recno := SELF:_midItem:Recno
    node2:KeyBytes := SELF:_midItem:KeyBytes
    SELF:_midItem:Recno := ntxNode:Recno
    SELF:_midItem:KeyBytes := ntxNode:KeyBytes
    SELF:_midItem:PageNo := ntxNode:PageNo
    RETURN TRUE
                    
                    
PRIVATE METHOD _deleteKey() AS VOID
    LOCAL lPage AS LONG
    LOCAL uiPos AS LONG
    LOCAL ntxPage AS NtxPage
    LOCAL node AS NtxItem
    LOCAL nodeCount AS LONG
    LOCAL offset AS WORD
    LOCAL i AS LONG
    //
    lPage := SELF:_ntxStack[SELF:_TopStack]:Page
    uiPos := SELF:_ntxStack[SELF:_TopStack]:Pos
    ntxPage := SELF:_PageList:Read(lPage)
    node := ntxPage[uiPos]
    IF node:PageNo != 0
        SELF:_locate(NULL, 0, NtxSearchMode.Bottom, node:PageNo)
        ntxPage := SELF:_PageList:Read(SELF:_ntxStack[SELF:_TopStack]:Page)
        node    := ntxPage[SELF:_ntxStack[SELF:_TopStack]:Pos]
        SELF:_midItem:Recno := node:Recno
        SELF:_midItem:KeyBytes := node:KeyBytes
        ntxPage := SELF:_PageList:Update(lPage)
        node        := ntxPage[uiPos]
        node:Recno  := SELF:_midItem:Recno
        node:KeyBytes := SELF:_midItem:KeyBytes
        lPage := SELF:_ntxStack[SELF:_TopStack]:Page
        uiPos := SELF:_ntxStack[SELF:_TopStack]:Pos
        ntxPage := SELF:_PageList:Read(lPage)
        node := ntxPage[uiPos]
    ENDIF
    nodeCount := ntxPage:NodeCount
    offset := ntxPage:GetRef(uiPos)
    
    FOR i := uiPos TO nodeCount -1
        // Copy the next Item offset at the current place
        ntxPage:SetRef(i, ntxPage:GetRef(i + 1))
    NEXT
    ntxPage:SetRef(nodeCount, offset)
    IF nodeCount > 0
        ntxPage:NodeCount--
    ENDIF
    SELF:_ntxStack[SELF:_TopStack]:Count := ntxPage:NodeCount
    SELF:_ntxStack[SELF:_TopStack]:Pos := ntxPage:NodeCount
    SELF:_PageList:Write(lPage)
    IF ntxPage:NodeCount < SELF:_halfPage .AND. SELF:_TopStack > 1
        SELF:_Balance()
    ENDIF
                    
                    
PRIVATE METHOD _Balance() AS VOID
    LOCAL lPage AS LONG
    LOCAL uiCount AS LONG
    LOCAL pageLeft AS NtxPage
    LOCAL pageRight AS NtxPage
    LOCAL nodeLeft AS NtxItem
    LOCAL nodeRight AS NtxItem
    LOCAL iPos AS LONG
    LOCAL pageNo AS LONG
    LOCAL num2 AS LONG
    LOCAL offset AS WORD
    LOCAL num3 AS LONG
    LOCAL node3 AS NtxItem
    LOCAL num4 AS LONG
    LOCAL node4 AS NtxItem
    LOCAL node5 AS NtxItem
    //
    lPage := SELF:_ntxStack[SELF:_TopStack]:Page
    uiCount := SELF:_ntxStack[SELF:_TopStack]:Count
    IF uiCount < SELF:_halfPage
        IF SELF:_TopStack == 1
            IF uiCount == 0
                pageLeft := SELF:_PageList:Update(lPage)
                nodeLeft := pageLeft[0]
                SELF:_firstPageOffset := (DWORD)nodeLeft:PageNo
                nodeLeft:PageNo := (INT)SELF:_nextUnusedPageOffset
                SELF:_nextUnusedPageOffset := (DWORD)lPage
            ENDIF
        ELSE
            // get parent page
            iPos := SELF:_ntxStack[--SELF:_TopStack]:Pos
            pageLeft := SELF:_PageList:Read(SELF:_ntxStack[SELF:_TopStack]:Page)
            IF iPos == SELF:_ntxStack[SELF:_TopStack]:Count
                pageNo := pageLeft[iPos]:PageNo
                num2 := pageNo
                iPos := --SELF:_ntxStack[SELF:_TopStack]:Pos
                lPage := pageLeft[iPos]:PageNo
            ELSE
                lPage := pageLeft[iPos]:PageNo
                num2 := lPage
                pageNo := pageLeft[iPos + 1]:PageNo
            ENDIF
            SELF:_delToMid(pageLeft, iPos)
            SELF:_ntxStack[SELF:_TopStack]:Count--
            SELF:_PageList:Write(SELF:_ntxStack[SELF:_TopStack]:Page)
            pageLeft := SELF:_PageList:Read(lPage)
            pageRight := SELF:_PageList:Read(pageNo)
            pageLeft := SELF:_PageList:Read(lPage)
            pageRight := SELF:_PageList:Read(pageNo)
            IF num2 == lPage
                iPos := pageLeft:NodeCount
                nodeLeft := pageLeft[iPos]
                nodeLeft:Recno := SELF:_midItem:Recno
                nodeLeft:KeyBytes := SELF:_midItem:KeyBytes
                nodeLeft := pageLeft[iPos + 1]
                nodeRight := pageRight[0]
                nodeLeft:PageNo := nodeRight:PageNo
                nodeRight:PageNo := -1L
                pageLeft:NodeCount++
            ELSE
                uiCount := pageRight:NodeCount
                offset := pageRight:GetRef(uiCount + 1)
                //Init
                num3 := uiCount + 1
                DO WHILE num3 > 0
                    pageRight:SetRef(num3, pageRight:GetRef(num3 - 1))
                    //Iterators
                    num3--
                ENDDO
                pageRight:SetRef(0, offset)
                nodeRight := pageRight[0]
                nodeRight:Recno := SELF:_midItem:Recno
                nodeRight:KeyBytes := SELF:_midItem:KeyBytes
                nodeRight:PageNo := -1L
                pageRight:NodeCount++
            ENDIF
            iPos := pageLeft:NodeCount
            uiCount := iPos + pageRight:NodeCount
            IF uiCount == SELF:_MaxEntry
                uiCount := 0
                nodeLeft := pageLeft[iPos]
                nodeRight := pageRight[uiCount]
                DO WHILE iPos < SELF:_MaxEntry
                    nodeLeft:Recno := nodeRight:Recno
                    nodeLeft:KeyBytes := nodeRight:KeyBytes
                    uiCount++
                    iPos++
                    nodeLeft := pageLeft[iPos]
                    nodeRight := pageRight[uiCount]
                    nodeLeft:PageNo := nodeRight:PageNo
                ENDDO
                pageLeft:NodeCount := SELF:_MaxEntry
                node3 := pageRight[0]
                node3:PageNo := (INT)SELF:_nextUnusedPageOffset
                SELF:_nextUnusedPageOffset := (DWORD)pageNo
                SELF:_PageList:Write(lPage)
                SELF:_PageList:Write(pageNo)
                SELF:_Balance()
            ELSE
                num4 := (uiCount - 1) / 2
                IF iPos <= num4
                    uiCount := 0
                    nodeLeft := pageLeft[iPos]
                    nodeRight := pageRight[uiCount]
                    DO WHILE iPos < num4
                        nodeLeft:Recno := nodeRight:Recno
                        nodeLeft:KeyBytes := nodeRight:KeyBytes
                        uiCount++
                        iPos++
                        nodeLeft := pageLeft[iPos]
                        nodeRight := pageRight[uiCount]
                        nodeLeft:PageNo := nodeRight:PageNo
                    END DO
                    pageLeft:NodeCount := (WORD)iPos
                    nodeRight := pageRight[uiCount]
                    SELF:_midItem:Recno := nodeRight:Recno
                    SELF:_midItem:KeyBytes := nodeRight:KeyBytes
                    uiCount++
                    num4 := pageRight:NodeCount
                    iPos := 0
                    //Init
                    DO WHILE uiCount <= num4
                        offset := pageRight:GetRef(iPos)
                        pageRight:SetRef(iPos, pageRight:GetRef(uiCount))
                        pageRight:SetRef(uiCount, offset)
                        iPos++
                        //Iterators
                        uiCount++
                    ENDDO
                    pageRight:NodeCount := (WORD)(iPos - 1)
                ELSE
                    uiCount := pageRight:NodeCount
                    num4++
                    DO WHILE iPos > num4
                        offset := pageRight:GetRef(uiCount + 1)
                        //Init
                        num3 := uiCount + 1
                        DO WHILE num3 > 0
                            pageRight:SetRef(num3, pageRight:GetRef(num3 - 1))
                            //Iterators
                            num3--
                        ENDDO
                        pageRight:SetRef(0, offset)
                        node4 := pageRight[1]
                        node4:PageNo := pageLeft[iPos]:PageNo
                        iPos--
                        nodeRight := pageRight[0]
                        nodeLeft := pageLeft[iPos]
                        nodeRight:Recno := nodeLeft:Recno
                        nodeRight:KeyBytes := nodeLeft:KeyBytes
                        uiCount++
                    ENDDO
                    node5 := pageRight[0]
                    node5:PageNo := pageLeft[iPos]:PageNo
                    pageRight:NodeCount := (WORD)uiCount
                    iPos--
                    nodeLeft := pageLeft[iPos]
                    SELF:_midItem:Recno := nodeLeft:Recno
                    SELF:_midItem:KeyBytes := nodeLeft:KeyBytes
                    pageLeft:NodeCount := (WORD)iPos
                ENDIF
                SELF:_midItem:PageNo := pageNo
                SELF:_PageList:Write(lPage)
                SELF:_PageList:Write(pageNo)
                SELF:_AddKey()
            ENDIF
        ENDIF
    ENDIF
                    
                    
        PRIVATE METHOD _delToMid(page AS NtxPage , uiPos AS LONG ) AS VOID
            LOCAL node AS NtxItem
            LOCAL nodeCount AS LONG
            LOCAL pageNo AS LONG
            LOCAL offSet AS WORD
            LOCAL i AS LONG
            //
            node := page[uiPos]
            SELF:_midItem:Recno := node:Recno
            SELF:_midItem:KeyBytes := node:KeyBytes
            nodeCount := page:NodeCount
            pageNo := node:PageNo
            offSet := page:GetRef(uiPos)
            FOR i := uiPos TO nodeCount -1
                page:SetRef(i, page:GetRef(i + 1))
            NEXT
            page:SetRef(nodeCount, offSet)
            node := page[uiPos]
            node:PageNo := pageNo
            page:NodeCount--
            RETURN
                    
                    
        PRIVATE METHOD _CreateEmpty() AS LOGIC
            LOCAL nLevel AS NtxLevel
            //
            SELF:_firstPageOffset := (DWORD)SELF:_fileSize
            SELF:_fileSize += NtxConst.BUFF_SIZE
            nLevel := NtxLevel{SELF}
            nLevel:InitRefs(SELF:_MaxEntry, SELF:_entrySize)
            nLevel:Write((INT)SELF:_firstPageOffset)
            SELF:ClearStack()
            RETURN TRUE
                    
                    
        PRIVATE METHOD _RecalcLevel(uiLevel AS DWORD , lKeys AS LONG , uiBOrder AS LONG ) AS VOID
            LOCAL nLevel AS NtxLevel
            //
            nLevel := SELF:_levels[uiLevel]
            nLevel:Write(nLevel:PageOffset)
            nLevel:NodeCount := 0
            nLevel:BaseKeys := lKeys / uiBOrder
            nLevel:ExtraKeys := lKeys - nLevel:BaseKeys * uiBOrder
            nLevel:Keys := nLevel:BaseKeys
            IF (nLevel:ExtraKeys > 0)
                nLevel:ExtraKeys--
                nLevel:Keys++
            ENDIF
            nLevel:Parents := nLevel:Keys / nLevel:Exp
            IF (uiLevel > 0)
                SELF:_RecalcLevel(uiLevel - 1, nLevel:Keys - nLevel:Parents, nLevel:Parents + 1)
            ENDIF
                    
                    
        PRIVATE METHOD _ResetLevel(uiLevel AS DWORD ) AS VOID
            LOCAL nLevel AS NtxLevel
            //
            nLevel := SELF:_levels[uiLevel]
            nLevel:Write(nLevel:PageOffset)
            nLevel:NodeCount := 0
            IF (nLevel:ExtraKeys > 0)
                nLevel:ExtraKeys--
                IF (uiLevel > 0)
                    SELF:_RecalcLevel(uiLevel - 1, nLevel:Keys - nLevel:Parents, nLevel:Parents + 1)
                ENDIF
            ELSE
                IF (nLevel:Keys == nLevel:BaseKeys)
                    IF (uiLevel > 0)
                        SELF:_RecalcLevel(uiLevel - 1, nLevel:Keys - nLevel:Parents, nLevel:Parents + 1)
                    ENDIF
                ELSE
                    nLevel:Keys := nLevel:BaseKeys
                    nLevel:Parents := nLevel:Keys / nLevel:Exp
                    IF (uiLevel > 0)
                        SELF:_RecalcLevel(uiLevel - 1, nLevel:Keys - nLevel:Parents, nLevel:Parents + 1)
                    ENDIF
                ENDIF
            ENDIF
                    
                    
        PUBLIC METHOD SetOrderScope(itmScope AS OBJECT , uiScope AS DBOrder_Info ) AS LOGIC
            LOCAL uiRealLen AS LONG
            LOCAL result AS LOGIC
            //
            uiRealLen := 0
            result := TRUE
            SWITCH uiScope
            CASE DBOrder_Info.DBOI_SCOPETOP
                SELF:_topScope      := itmScope
                SELF:_hasTopScope   := (itmScope != NULL)
                IF itmScope != NULL
                    SELF:_topScopeBuffer := BYTE[]{ 257 }
                    SELF:_ToString(itmScope, SELF:_keySize, SELF:_keyDecimals, SELF:_topScopeBuffer, SELF:_Ansi, REF uiRealLen)
                    SELF:_topScopeSize := uiRealLen
                ENDIF
            CASE DBOrder_Info.DBOI_SCOPEBOTTOM
                SELF:_bottomScope    := itmScope
                SELF:_hasBottomScope := (itmScope != NULL)
                IF itmScope != NULL
                    SELF:_bottomScopeBuffer := BYTE[]{ 257 }
                    SELF:_ToString(itmScope, SELF:_keySize, SELF:_keyDecimals, SELF:_bottomScopeBuffer, SELF:_Ansi, REF uiRealLen)
                    SELF:_bottomScopeSize := uiRealLen
                ENDIF
            OTHERWISE
                result := FALSE
            END SWITCH
        RETURN result
                
                
    PRIVATE METHOD _getScopePos() AS DWORD
        LOCAL first AS DWORD
        LOCAL last AS DWORD
        //
        IF (SELF:_hasTopScope)
            IF SELF:__Compare(SELF:_knownKeyBuffer, SELF:_topScopeBuffer, SELF:_topScopeSize) < 0
                RETURN 0u
            ENDIF
        ENDIF
        IF (SELF:_hasBottomScope)
            IF SELF:__Compare(SELF:_knownKeyBuffer, SELF:_bottomScopeBuffer, SELF:_bottomScopeSize) > 0
                RETURN 0u
            ENDIF
        ENDIF
        first := 1u
        last := 1u
        DO WHILE SELF:_findItemPos(REF first, FALSE)
            NOP
        ENDDO
        IF (SELF:_hasTopScope)
            SELF:_ScopeSeek(DBOrder_Info.DBOI_SCOPETOP)
            DO WHILE SELF:_findItemPos(REF last, FALSE)
                NOP
            ENDDO
        ENDIF
        RETURN first - last + 1
                
                
    PRIVATE METHOD _ScopeSkip(lNumKeys AS LONG ) AS DWORD
        LOCAL RT_Deleted AS LOGIC
        LOCAL result AS DWORD
        LOCAL recno AS DWORD
        LOCAL ntxSkipDirection AS NtxSkipDirection
        //
        RT_Deleted := XSharp.RuntimeState.Deleted
        result := (DWORD)SELF:_oRdd:RecNo
        IF (lNumKeys == 1)
            recno := SELF:_getNextKey(FALSE, NtxSkipDirection.Forward)
            IF RT_Deleted .OR. SELF:_oRdd:_FilterInfo:Active
                recno := SELF:_skipFilter(recno, 1)
            ENDIF
            IF (recno == 0)
                SELF:_oRdd:_Eof := TRUE
                RETURN 0u
            ENDIF
            IF (SELF:_hasBottomScope)
                IF (SELF:__Compare(SELF:_knownKeyBuffer, SELF:_bottomScopeBuffer, SELF:_bottomScopeSize) > 0)
                    SELF:_oRdd:_Eof := TRUE
                    RETURN result
                ENDIF
            ENDIF
        ELSE
            IF (lNumKeys < 0)
                lNumKeys := -lNumKeys
                ntxSkipDirection := NtxSkipDirection.Backward
            ELSE
                ntxSkipDirection := NtxSkipDirection.Forward
            ENDIF
            rT_Deleted := XSharp.RuntimeState.Deleted
            IF (lNumKeys != 0)
                REPEAT
                    recno := SELF:_getNextKey(FALSE, ntxSkipDirection)
                    IF ((rT_Deleted) .OR. (SELF:_oRdd:_FilterInfo:Active))
                        recno := SELF:_skipFilter(recno, (LONG)ntxSkipDirection)
                    ENDIF
                    lNumKeys--
                    IF (ntxSkipDirection == NtxSkipDirection.Backward)
                        IF (SELF:_hasTopScope)
                            IF SELF:__Compare(SELF:_knownKeyBuffer, SELF:_topScopeBuffer, SELF:_topScopeSize) < 0
                                recno := SELF:_getNextKey(FALSE, NtxSkipDirection.Forward)
                                SELF:_oRdd:_Bof := TRUE
                                EXIT
                            ENDIF
                        ENDIF
                    ELSE
                        IF (SELF:_hasBottomScope)
                            IF (recno != 0)
                                SELF:_oRdd:_Eof := TRUE
                                RETURN result
                            ENDIF
                            SELF:_oRdd:_Bof := FALSE
                            IF SELF:__Compare(SELF:_knownKeyBuffer, SELF:_bottomScopeBuffer, SELF:_bottomScopeSize) > 0
                                SELF:_oRdd:_Eof := TRUE
                                RETURN result
                            ENDIF
                            result := recno
                        ENDIF
                    ENDIF
                UNTIL !((recno != 0) .AND. (lNumKeys != 0))
            ELSE
                recno := 0u
            ENDIF
        ENDIF
        RETURN recno
                
                
    PRIVATE METHOD _ScopeSeek(uiScope AS DBOrder_Info ) AS LOGIC
        LOCAL result AS LOGIC
        LOCAL seekInfo AS DbSeekInfo
        LOCAL obj AS OBJECT
        LOCAL mustSeek AS LOGIC
        //
        result := TRUE
        seekInfo := DbSeekInfo{}
        IF (uiScope == DBOrder_Info.DBOI_SCOPETOP)
            obj := SELF:_topScope
            IF (obj == NULL)
                result := SELF:GoTop()
                mustSeek := FALSE
            ELSE
                seekInfo:Last := FALSE
                mustSeek := TRUE
            ENDIF
        ELSE
            obj := SELF:_bottomScope
            IF (obj == NULL)
                result := SELF:GoBottom()
                mustSeek := FALSE
            ELSE
                seekInfo:Last := TRUE
                mustSeek := TRUE
            ENDIF
        ENDIF
        IF (mustSeek)
            seekInfo:Value      := obj
            seekInfo:SoftSeek   := TRUE
            result := SELF:_Seek(seekInfo, obj)
            SELF:_oRdd:_Found := SELF:_isInScope()
            IF (!SELF:_oRdd:_Found)
                SELF:_oRdd:GoTo(0)
            ENDIF
        ENDIF
        RETURN result
                
                
    PRIVATE METHOD _isInScope() AS LOGIC
        LOCAL isOk AS LOGIC
        LOCAL itmBottomScope AS OBJECT
        //
        isOk := SELF:_oRdd:_Found
        IF ((!isOk) .AND. (SELF:_oRdd:RecNo != 0))
            IF (SELF:_hasBottomScope)
                itmBottomScope := SELF:_bottomScope
                SELF:_ToString(itmBottomScope, SELF:_keySize, SELF:_keyDecimals, SELF:_newKeyBuffer, SELF:_Ansi)
                
                IF SELF:__Compare(SELF:_newKeyBuffer, SELF:_knownKeyBuffer, SELF:_keySize) >= 0
                    isOk := TRUE
                ENDIF
            ELSE
                isOk := TRUE
            ENDIF
        ENDIF
        RETURN isOk
                
                
    INTERNAL METHOD _CountRecords(records REF DWORD ) AS LOGIC
        LOCAL isOk AS LOGIC
        LOCAL oldRec AS DWORD
        LOCAL recno AS DWORD
        LOCAL last AS DWORD
        LOCAL count AS DWORD
        //
        isOk := TRUE
        SELF:_oRdd:GoCold()
        oldRec := SELF:Recno
        IF SELF:_Shared
            isOk := SELF:_lockForRead()
            IF (!isOk)
                RETURN FALSE
            ENDIF
        ENDIF
        IF ((SELF:_hasTopScope) .OR. (SELF:_hasBottomScope))
            SELF:_ScopeSeek(DBOrder_Info.DBOI_SCOPEBOTTOM)
            records := SELF:_getScopePos()
        ELSE
            IF (( XSharp.RuntimeState.Deleted ) .OR. (SELF:_oRdd:_FilterInfo:Active))
                SELF:_oRdd:SkipFilter(1)
                oldRec := SELF:Recno
                records := 0
                IF (!SELF:_oRdd:_Eof)
                    recno := SELF:_locateKey(NULL, 0, NtxSearchMode.Top)
                    isOk := SELF:_oRdd:GoToId(recno)
                    IF (isOk)
                        isOk := SELF:_oRdd:SkipFilter(1)
                    ENDIF
                    recno := SELF:Recno
                    last := (DWORD)SELF:_oRdd:RecCount + 1
                    count := 0
                    DO WHILE (recno != 0) .AND. (recno < last)
                        count++
                        recno := SELF:_ScopeSkip(1)
                    ENDDO
                    records := count
                ENDIF
            ELSE
                SELF:_oRdd:GoBottom()
                records := 0
                IF (!SELF:_oRdd:_Eof)
                    records := 1
                    DO WHILE SELF:_findItemPos(REF records, FALSE)
                        NOP
                    ENDDO
                ENDIF
            ENDIF
        ENDIF
        SELF:_oRdd:GoTo((INT)oldRec)
        IF SELF:_Shared
            isOk := SELF:_unLockForRead()
        ENDIF
        RETURN isOk
                
                
    INTERNAL METHOD _getRecPos(record REF DWORD ) AS LOGIC
        LOCAL oldRec AS DWORD
        LOCAL recno AS DWORD
        LOCAL count AS DWORD
        //
        SELF:_oRdd:GoCold()
        oldRec := SELF:Recno
        IF (!SELF:_lockForRead())
            RETURN FALSE
        ENDIF
        recno := record
        IF (recno == 0)
            recno := SELF:Recno
        ENDIF
        IF (SELF:_TopStack == 0)
            SELF:_goTo(recno)
        ENDIF
        IF ((SELF:_hasTopScope) .OR. (SELF:_hasBottomScope))
            record := SELF:_getScopePos()
        ELSE
            IF ((XSharp.RuntimeState.Deleted) .OR. (SELF:_oRdd:_FilterInfo:Active))
                SELF:_oRdd:SkipFilter(1)
                oldRec := SELF:Recno
                record := 0
                IF (!SELF:_oRdd:_Eof)
                    recno := SELF:_locateKey(NULL, 0, NtxSearchMode.Top)
                    IF (SELF:_oRdd:GoToId(recno))
                        SELF:_oRdd:SkipFilter(1)
                    ENDIF
                    recno := SELF:Recno
                    count := 1
                    DO WHILE (recno != 0) .AND. (recno != oldRec)
                        count++
                        recno := SELF:_ScopeSkip(1)
                    ENDDO
                    record := count
                ENDIF
            ELSE
                record := 1
                DO WHILE SELF:_findItemPos(REF record, FALSE)
                ENDDO
            ENDIF
        ENDIF
        SELF:_oRdd:GoToId(oldRec)
        RETURN SELF:_unLockForRead()
                
                
    PUBLIC METHOD GoBottom() AS LOGIC
        LOCAL locked AS LOGIC
        LOCAL result AS LOGIC
        //
        locked := FALSE
        TRY
            IF SELF:_hasBottomScope
                RETURN SELF:_ScopeSeek(DBOrder_Info.DBOI_SCOPEBOTTOM)
            ELSE
                SELF:_oRdd:GoCold()
                SELF:_oRdd:_Top := FALSE
                SELF:_oRdd:_Bottom := TRUE
                locked := SELF:_lockForRead()
                IF (locked)
                    VAR recno := SELF:_locateKey(NULL, 0, NtxSearchMode.Bottom)
                    result := SELF:_oRdd:GoToId(recno)
                    IF (!result)
                        RETURN result
                    ENDIF
                    RETURN SELF:_oRdd:SkipFilter(-1)
                ENDIF
            ENDIF
            RETURN FALSE
            
                    
        FINALLY
            IF (locked)
                SELF:_unLockForRead()
            ENDIF
        END TRY
                
                
    PUBLIC METHOD GoTop() AS LOGIC
        LOCAL locked AS LOGIC
        LOCAL result AS LOGIC
        locked := FALSE
        TRY
            SELF:_oRdd:GoCold()
            //
            IF SELF:_hasTopScope
                result := SELF:_ScopeSeek(DBOrder_Info.DBOI_SCOPETOP)
                IF (!SELF:_oRdd:_Found)
                    SELF:_oRdd:_Bof := TRUE
                ENDIF
                RETURN result
             ELSE
                SELF:_oRdd:_Top := TRUE
                SELF:_oRdd:_Bottom := FALSE
                locked := SELF:_lockForRead()
                IF (locked)
                    VAR recno := SELF:_locateKey(NULL, 0, NtxSearchMode.Top)
                    result := SELF:_oRdd:GoToId(recno)
                    IF (!result)
                        RETURN result
                    ENDIF
                    RETURN SELF:_oRdd:SkipFilter(1)
                ENDIF
                RETURN FALSE
            ENDIF
                    
        FINALLY
            IF (locked)
                result := SELF:_unLockForRead()
            ENDIF
        END TRY
                
                
    PUBLIC METHOD SkipRaw(nToSkip AS LONG ) AS LOGIC
        LOCAL recno AS DWORD
        LOCAL isBof AS LOGIC
        LOCAL isEof AS LOGIC
        LOCAL changedBof AS LOGIC
        LOCAL changedEof AS LOGIC
        LOCAL locked AS LOGIC
        LOCAL orgToSkip AS INT
        LOCAL result := FALSE AS LOGIC
        // Default Position = Current Record
        IF nToSkip == 0
            recno := SELF:Recno
        ELSE
            recno := 0
        ENDIF
        //
        isBof := FALSE
        isEof := FALSE
        changedBof := FALSE
        changedEof := FALSE
        locked := FALSE
        //
        TRY
            orgToSkip := nToSkip
            SELF:_oRdd:GoCold()
            locked := SELF:_lockForRead()
            IF (!locked)
                RETURN FALSE
            ENDIF
            IF (!SELF:_oRdd:_isValid)
                IF (nToSkip < 0)
                    recno := SELF:_locateKey(NULL, 0, NtxSearchMode.Bottom)
                    nToSkip++
                ELSE
                    recno := 0
                    nToSkip := 0
                ENDIF
            ELSE
                IF (SELF:_TopStack == 0)
                    SELF:_goTo(SELF:Recno)
                ENDIF
            ENDIF
            //
            IF (orgToSkip != 0)
                IF ((SELF:_hasTopScope) .OR. (SELF:_hasBottomScope))
                    isBof := SELF:_oRdd:_Bof
                    isEof := SELF:_oRdd:_Eof
                    recno := SELF:_ScopeSkip(nToSkip)
                    IF (isBof != SELF:_oRdd:_Bof)
                        changedBof := TRUE
                        isBof := SELF:_oRdd:_Bof
                    ELSE
                        changedBof := FALSE
                    ENDIF
                    IF (isEof != SELF:_oRdd:_Eof)
                        changedEof := TRUE
                        isEof := SELF:_oRdd:_Eof
                    ELSE
                        changedEof := FALSE
                    ENDIF
                ELSE
                    IF (nToSkip != 0)
                        recno := SELF:_nextKey(nToSkip)
                    ENDIF
                ENDIF
            ENDIF
            result := SELF:_oRdd:GoToId(recno)
            IF ((!SELF:_hasTopScope) .AND. (!SELF:_hasBottomScope))
                RETURN result
            ENDIF
            IF (changedBof)
                SELF:_oRdd:_Bof := isBof
            ENDIF
            IF (!changedEof)
                RETURN result
            ENDIF
            SELF:_oRdd:_Eof := isEof
                    
        CATCH e AS Exception
            System.Diagnostics.Debug.WriteLine(e:Message)  
        FINALLY
            IF (locked)
                result := SELF:_unLockForRead()
            ENDIF
        END TRY
        RETURN result
                
                
    PRIVATE METHOD _goRecord(keyBytes AS BYTE[], keyLen AS LONG, gotoRec AS DWORD ) AS DWORD
        LOCAL recno AS DWORD
        // Search the first occurence
        recno := SELF:_locateKey(keyBytes, keyLen, NtxSearchMode.Left)
        // Now, move until we found the right Recno
        DO WHILE (recno != 0) .AND. (recno != gotoRec)
            recno := SELF:_getNextKey(FALSE, NtxSkipDirection.Forward)
        ENDDO
        RETURN recno
                
                
    INTERNAL METHOD _goTo(recno AS DWORD ) AS LOGIC
        LOCAL result AS LOGIC
        result := TRUE
        SELF:_keySave(recno)
        IF SELF:_goRecord(SELF:_knownKeyBuffer, SELF:_keySize, recno) != recno
            IF SELF:_goRecord(NULL, 0, recno) != recno
                IF !SELF:_Unique .AND. !SELF:_Conditional .AND. !SELF:_Partial
                    SELF:_oRdd:_dbfError( SubCodes.ERDD_RECNO_MISSING, GenCode.EG_CORRUPTION,SELF:fileName)
                    result := FALSE
                ENDIF
                SELF:_TopStack := 0
            ENDIF
        ENDIF
        RETURN result
                
                
    PRIVATE METHOD _skipFilter(recno AS DWORD , iPolar AS LONG ) AS DWORD
        IF SELF:_oRdd:GoTo((INT)recno)
            SELF:_oRdd:SkipFilter(iPolar)
            recno := SELF:Recno
        ENDIF
        RETURN recno
                
                
    PUBLIC METHOD Seek(seekInfo AS DBSEEKINFO ) AS LOGIC
        LOCAL uiRealLen AS LONG
        LOCAL byteArray AS BYTE[]
        //
        uiRealLen := 0
        byteArray := BYTE[]{ 256 }
        // Convert the seeked key to a byte Array
        IF (!SELF:_ToString(seekInfo:Value, SELF:_keySize, SELF:_keyDecimals, byteArray, SELF:_Ansi, REF uiRealLen))
            SELF:_oRdd:_dbfError( SubCodes.ERDD_VAR_TYPE, GenCode.EG_DATATYPE,SELF:fileName)
            RETURN FALSE
        ENDIF
        IF SELF:_hasTopScope
            IF SELF:__Compare(byteArray, SELF:_topScopeBuffer, SELF:_keySize) < 0
                IF (seekInfo:SoftSeek)
                    RETURN SELF:_ScopeSeek(DBOrder_Info.DBOI_SCOPETOP)
                ENDIF
                RETURN SELF:_oRdd:GoToId(0)
            ENDIF
        ENDIF
        IF SELF:_hasBottomScope
            IF SELF:__Compare(byteArray, SELF:_bottomScopeBuffer, SELF:_keySize) > 0
                RETURN SELF:_oRdd:GoToId(0)
            ENDIF
        ENDIF
        RETURN SELF:_Seek(seekInfo, byteArray)
                
                
    PRIVATE METHOD _Seek(seekInfo AS DBSEEKINFO , abNewKey AS BYTE[] ) AS LOGIC
        LOCAL recno AS DWORD
        LOCAL result AS LOGIC
        LOCAL cmpMinMax AS LONG
        LOCAL fSoft AS LOGIC
        LOCAL recnoOk AS DWORD
        LOCAL locked AS LOGIC
        LOCAL strCmp AS INT
        LOCAL strCmpMaxMin AS INT
        LOCAL diff AS INT
        LOCAL deletedState AS LOGIC
        LOCAL padLen AS INT
        LOCAL needPadStr AS LOGIC
        LOCAL len AS INT
        LOCAL text AS STRING
        LOCAL temp AS BYTE
        //
        recno := 0
        result := FALSE
        cmpMinMax := 0
        fSoft := FALSE
        recnoOK := 0
        locked := FALSE
        TRY
            deletedState := XSharp.RuntimeState.Deleted
            SELF:_oRdd:GoCold()
            locked := SELF:_lockForRead()
            IF (locked)
                IF SELF:_Shared
                    SELF:_knownRecno := 0
                ENDIF
                needPadStr := FALSE
                IF (seekInfo:Value:GetType() == TYPEOF(STRING))
                    text := (STRING)seekInfo:Value
                    len := text:Length
                    padLen := len
                    IF (len < SELF:_keySize)
                        needPadStr := TRUE
                        IF (SELF:_Descending)
                            abNewKey[len] := Byte.MaxValue
                        ELSE
                            abNewKey[len] := 1
                        ENDIF
                        padLen := len + 1
                        fSoft := seekInfo:SoftSeek
                        seekInfo:SoftSeek := TRUE
                    ENDIF
                ELSE
                    len := SELF:_keySize
                    padLen := len
                ENDIF
                recno := SELF:_locateKey(abNewKey, padLen, IIF(seekInfo:SoftSeek , NtxSearchMode.LeftFound , NtxSearchMode.Left))
                result := SELF:_oRdd:GoToId(recno)
                IF ((deletedState) .OR. (SELF:_oRdd:_FilterInfo:Active))
                    SELF:_oRdd:SkipFilter(1)
                    recno := SELF:Recno
                ENDIF
                LOCAL found AS LOGIC
                IF (SELF:_oRdd:_isValid)
                    IF ((((deletedState) .OR. (SELF:_oRdd:_FilterInfo:Active)) .OR. (seekInfo:SoftSeek)) .OR. (seekInfo:Last))
                        SELF:_ToString(seekInfo:Value, SELF:_keySize, SELF:_keyDecimals, SELF:_newKeyBuffer, SELF:_Ansi, REF SELF:_newKeyLen)
                        strCmp := SELF:__Compare(abNewKey, SELF:_knownKeyBuffer, len)
                        found := (strCmp == 0)
                        IF ((needPadStr) .AND. (!found))
                            IF (SELF:_Descending)
                                SELF:_newKeyBuffer[len] := Byte.MaxValue
                                temp:= SELF:_knownKeyBuffer[len]
                                SELF:_knownKeyBuffer[len] := 1
                                cmpMinMax := SELF:__Compare(abNewKey, SELF:_knownKeyBuffer, padLen)
                                IF ((strCmp < 0) .AND. (cmpMinMax > 0))
                                    found := TRUE
                                ENDIF
                                IF (!found)
                                    SELF:_newKeyBuffer[len] := 1
                                    SELF:_knownKeyBuffer[len] := Byte.MaxValue
                                    strCmpMaxMin := SELF:__Compare(abNewKey, SELF:_knownKeyBuffer, padLen)
                                    IF ((strCmp > 0) .AND. (strCmpMaxMin < 0))
                                        found := TRUE
                                    ENDIF
                                ENDIF
                            ELSE
                                SELF:_newKeyBuffer[len] := 1
                                temp:= SELF:_knownKeyBuffer[len]
                                SELF:_knownKeyBuffer[len] := Byte.MaxValue
                                strCmpMaxMin := SELF:__Compare(SELF:_newKeyBuffer, SELF:_knownKeyBuffer, padLen)
                                IF ((strCmp > 0) .AND. (cmpMinMax < 0))
                                    found := TRUE
                                ENDIF
                                IF (!found)
                                    SELF:_newKeyBuffer[len] := Byte.MaxValue
                                    SELF:_knownKeyBuffer[len] := 1
                                    strCmpMaxMin := SELF:__Compare(SELF:_newKeyBuffer, SELF:_knownKeyBuffer, padLen)
                                    IF ((strCmp < 0) .AND. (strCmpMaxMin > 0))
                                        found := TRUE
                                    ENDIF
                                ENDIF
                            ENDIF
                            SELF:_newKeyBuffer[len] := 0
                            SELF:_knownKeyBuffer[len] := temp
                            seekInfo:SoftSeek := fSoft
                        ENDIF
                        IF (found)
                            IF (seekInfo:Last)
                                DO WHILE strCmp == 0
                                    recnoOK := recno
                                    recno := SELF:_nextKey(1)
                                    IF ((deletedState) .OR. (SELF:_oRdd:_FilterInfo:Active))
                                        recno := SELF:_skipFilter(recno, 1)
                                        IF ((SELF:_oRdd:_Eof) .OR. (recno == recnoOK))
                                            EXIT
                                        ENDIF
                                    ENDIF
                                    IF (recno == 0)
                                        EXIT
                                    ENDIF
                                    strCmp := SELF:__Compare(SELF:_newKeyBuffer, SELF:_knownKeyBuffer, len)
                                    IF (strCmp != 0)
                                        recno := SELF:_nextKey(-1)
                                        EXIT
                                    ENDIF
                                ENDDO
                                recno := recnoOK
                                result := SELF:_oRdd:GoToId(recno)
                                IF (recno != 0)
                                    found := TRUE
                                ENDIF
                            ENDIF
                        ELSE
                            IF (seekInfo:Last)
                                diff := strCmp
                                recno := SELF:_nextKey(-1)
                                strCmp := SELF:__Compare(SELF:_newKeyBuffer, SELF:_knownKeyBuffer, len)
                                found := (strCmp == 0)
                                IF (found)
                                    result := SELF:_oRdd:GoToId(recno)
                                ELSE
                                    IF (diff == -strCmp)
                                        found := TRUE
                                        result := SELF:_oRdd:GoToId(recno)
                                    ELSE
                                        result := SELF:_oRdd:GoToId(0)
                                    ENDIF
                                ENDIF
                            ELSE
                                IF (!seekInfo:SoftSeek)
                                    result := SELF:_oRdd:GoToId(0)
                                ENDIF
                            ENDIF
                        ENDIF
                    ELSE
                        strCmp := SELF:__Compare(abNewKey, SELF:_knownKeyBuffer, len)
                        found := (strCmp == 0)
                    ENDIF
                ELSE
                    found := FALSE
                ENDIF
                IF (!SELF:_oRdd:_isValid)
                    SELF:_TopStack := 0u
                ENDIF
                SELF:_oRdd:_Bof := (SELF:_oRdd:RecCount == 0)
                SELF:_oRdd:_Found := found
                RETURN result
            ENDIF
            RETURN FALSE
                    
        FINALLY
            IF (locked)
                result := SELF:_unLockForRead()
            ENDIF
        END TRY
                
                
                
    PRIVATE METHOD _nextKey( keyMove AS LONG ) AS DWORD
        LOCAL recno			AS DWORD
        LOCAL moveDirection	AS NtxSkipDirection
        //
        IF (keyMove == 1)
            recno := SELF:_getNextKey(FALSE, NtxSkipDirection.Forward)
        ELSE
            IF (keyMove < 0)
                keyMove := -keyMove
                moveDirection := NtxSkipDirection.Backward
            ELSE
                moveDirection := NtxSkipDirection.Forward
            ENDIF
            IF (keyMove != 0)
                REPEAT
                    recno := SELF:_getNextKey(FALSE, moveDirection)
                    keyMove--
                UNTIL !((recno != 0) .AND. (keyMove != 0))
            ELSE
                recno := 0
            ENDIF
        ENDIF
        RETURN recno
                
                
    PRIVATE METHOD _getNextKey(fThisPage AS LOGIC , moveDirection AS NtxSkipDirection ) AS DWORD
        LOCAL ntxPage AS NtxPage
        LOCAL node AS NtxItem
        // No page loaded ?
        IF (SELF:_TopStack == 0)
            RETURN 0
        ENDIF
        //
        ntxPage := SELF:_PageList:Read(SELF:_ntxStack[SELF:_TopStack]:Page)
        node := ntxPage[SELF:_ntxStack[SELF:_TopStack]:Pos]
        IF (fThisPage)
            IF (moveDirection == NtxSkipDirection.Backward)
                SELF:_ntxStack[SELF:_TopStack]:Pos--
                node:Fill(SELF:_ntxStack[SELF:_TopStack]:Pos, ntxPage)
            ENDIF
            IF (SELF:_knownRecno != node:Recno)
                SELF:_saveRecordState(node)
            ENDIF
            RETURN node:Recno
        ENDIF
        //
        IF (moveDirection == NtxSkipDirection.Forward)
            SELF:_ntxStack[SELF:_TopStack]:Pos++
            node:Fill(SELF:_ntxStack[SELF:_TopStack]:Pos, ntxPage)
            IF (node:PageNo != 0)
                RETURN SELF:_locate(NULL, 0, NtxSearchMode.Top, node:PageNo)
            ENDIF
            IF (SELF:_ntxStack[SELF:_TopStack]:Pos == SELF:_ntxStack[SELF:_TopStack]:Count)
                DO WHILE (SELF:_TopStack != 0) .AND. (SELF:_ntxStack[SELF:_TopStack]:Pos == SELF:_ntxStack[SELF:_TopStack]:Count)
                    SELF:PopPage()
                ENDDO
                RETURN SELF:_getNextKey(TRUE, NtxSkipDirection.Forward)
            ENDIF
            IF (SELF:_knownRecno != node:Recno)
                SELF:_saveRecordState(node)
            ENDIF
            RETURN node:Recno
        ENDIF
        IF (node:PageNo != 0)
            RETURN SELF:_locate(NULL, 0, NtxSearchMode.Bottom, node:PageNo)
        ENDIF
        IF (SELF:_ntxStack[SELF:_TopStack]:Pos == 0)
            DO WHILE (SELF:_TopStack != 0) .AND. (SELF:_ntxStack[SELF:_TopStack]:Pos == 0)
                SELF:PopPage()
            ENDDO
            RETURN SELF:_getNextKey(TRUE, NtxSkipDirection.Backward)
        ENDIF
        SELF:_ntxStack[SELF:_TopStack]:Pos--
        node:Fill(SELF:_ntxStack[SELF:_TopStack]:Pos, ntxPage)
        IF (SELF:_knownRecno != node:Recno)
            SELF:_saveRecordState(node)
        ENDIF
        RETURN node:Recno
                
                
    PRIVATE METHOD _findItemPos(record REF DWORD , nodePage AS LOGIC ) AS LOGIC
        LOCAL ntxPage AS NtxPage
        LOCAL node AS NtxItem
        //
        IF (SELF:_TopStack == 0)
            RETURN FALSE
        ENDIF
        ntxPage := SELF:_PageList:Read(SELF:_ntxStack[SELF:_TopStack]:Page)
        node := ntxPage[SELF:_ntxStack[SELF:_TopStack]:Pos]
        IF (nodePage)
            SELF:_ntxStack[SELF:_TopStack]:Pos--
            record++
            RETURN TRUE
        ENDIF
        IF (node:PageNo != 0)
            SELF:_locate(NULL, 0, NtxSearchMode.Bottom, node:PageNo)
            record += (DWORD)(SELF:_ntxStack[SELF:_TopStack]:Pos + 1)
            SELF:_ntxStack[SELF:_TopStack]:Pos := 0
            RETURN TRUE
        ENDIF
        IF (SELF:_ntxStack[SELF:_TopStack]:Pos == 0)
            DO WHILE (SELF:_TopStack != 0) .AND. (SELF:_ntxStack[SELF:_TopStack]:Pos == 0)
                SELF:PopPage()
            ENDDO
            RETURN SELF:_findItemPos(REF record, TRUE)
        ENDIF
        record += (DWORD)SELF:_ntxStack[SELF:_TopStack]:Pos
        SELF:_ntxStack[SELF:_TopStack]:Pos := 0
        RETURN TRUE
                
    PRIVATE METHOD _isEqual(lRecno AS LONG , objValue AS OBJECT , result REF LOGIC ) AS LOGIC
        LOCAL isOk AS LOGIC
        LOCAL length AS LONG
        LOCAL text AS STRING
        //
        // SELF:_knownRecno == lRecno, we are on the same record !!
        isOk := SELF:_ToString(objValue, SELF:_keySize, SELF:_keyDecimals, SELF:_newKeyBuffer, SELF:_Ansi, REF SELF:_newKeyLen)
        IF (!isOk)
            SELF:_oRdd:_dbfError( SubCodes.ERDD_KEY_EVAL, GenCode.EG_DATATYPE,SELF:fileName)
            RETURN FALSE
        ENDIF
        IF (objValue:GetType() == TYPEOF(STRING))
            text := (STRING)objValue
            length := text:Length
            SELF:_newKeyLen := text:Length
        ELSE
            length := SELF:_keySize
        ENDIF
        result := (SELF:__Compare(SELF:_newKeyBuffer, SELF:_knownKeyBuffer, length) != 0)
        RETURN isOk
                
                
    PRIVATE METHOD _Seek(dbsi AS DBSEEKINFO , lpval AS OBJECT ) AS LOGIC
        LOCAL byteArray AS BYTE[]
        //
        byteArray := BYTE[]{ 257 }
        SELF:_ToString(lpval, SELF:_keySize, SELF:_keyDecimals, byteArray, SELF:_Ansi)
        dbsi:SoftSeek := TRUE
        RETURN SELF:_Seek(dbsi, byteArray)
                
                
    PRIVATE METHOD _locateKey( keyBuffer AS BYTE[] , bufferLen AS LONG , searchMode AS NtxSearchMode ) AS DWORD
        SELF:_TopStack := 0u
        IF (bufferLen > SELF:_keySize)
            bufferLen := SELF:_keySize
        ELSE
            IF (bufferLen == 0)
                bufferLen := SELF:_keySize
            ENDIF
        ENDIF
        RETURN SELF:_locate(keyBuffer, bufferLen, searchMode, (INT)SELF:_firstPageOffset)
                
                
    PRIVATE METHOD _locate(keyBuffer AS BYTE[] , bufferLen AS LONG , searchMode AS NtxSearchMode , pageOffset AS LONG ) AS DWORD
        LOCAL foundPos AS LONG
        LOCAL ntxPage AS NtxPage
        LOCAL nodeCount AS LONG
        LOCAL node AS NtxItem
        LOCAL minPos AS LONG
        LOCAL maxPos AS LONG
        //
        foundPos := 0
        //Load the page at pageOffset
        ntxPage := SELF:_PageList:Read(pageOffset)
        IF (ntxPage == NULL)
            SELF:_TopStack := 0
            RETURN 0
        ENDIF
        // How many Items in that page ?
        nodeCount := ntxPage:NodeCount
        // Get the first one
        node := ntxPage[0]
        //
        BEGIN SWITCH searchMode
        CASE NtxSearchMode.Right
            IF (SELF:_Descending)
                // search...
                minPos := 0
                maxPos := nodeCount
                DO WHILE minPos < maxPos
                    foundPos := (minPos + maxPos) / 2
                    node:Fill(foundPos, ntxPage)
                    IF (SELF:__Compare(node:KeyBytes, keyBuffer, bufferLen) >= 0)
                        minPos := foundPos + 1
                    ELSE
                        maxPos := foundPos
                    ENDIF
                ENDDO
                foundPos := minPos
            ELSE
                minPos := 0
                maxPos := nodeCount
                DO WHILE minPos < maxPos
                    foundPos := (minPos + maxPos) / 2
                    node:Fill(foundPos, ntxPage)
                    IF (SELF:__Compare(node:KeyBytes, keyBuffer, bufferLen) <= 0)
                        minPos := foundPos + 1
                    ELSE
                        maxPos := foundPos
                    ENDIF
                ENDDO
                foundPos := minPos
            ENDIF
        CASE NtxSearchMode.Left
        CASE NtxSearchMode.LeftFound
            minPos := 0
            maxPos := nodeCount
            DO WHILE minPos < maxPos
                foundPos := (minPos + maxPos) / 2
                node:Fill(foundPos, ntxPage)
                IF (SELF:_Descending)
                    IF (SELF:__Compare(node:KeyBytes, keyBuffer, bufferLen) > 0)
                        minPos := foundPos + 1
                    ELSE
                        maxPos := foundPos
                    ENDIF
                ELSE
                    IF (SELF:__Compare(node:KeyBytes, keyBuffer, bufferLen) < 0)
                        minPos := foundPos + 1
                    ELSE
                        maxPos := foundPos
                    ENDIF
                ENDIF
            ENDDO
            foundPos := minPos
            node:Fill(foundPos, ntxPage)
            IF ((searchMode == NtxSearchMode.Left) .AND. (SELF:__Compare(node:KeyBytes, keyBuffer, bufferLen) == 0))
                searchMode := NtxSearchMode.LeftFound
            ENDIF
                    
        CASE NtxSearchMode.Bottom
            foundPos := nodeCount
            node:Fill(foundPos, ntxPage)
            IF ((node:PageNo == 0) .AND. (foundPos > 0))
                foundPos--
                node:Fill(foundPos, ntxPage)
            ENDIF
         CASE NtxSearchMode.Top
            foundPos := 0
            node:Fill(foundPos, ntxPage)
        END SWITCH
    // Add info in the stack
        SELF:_TopStack++
        SELF:_ntxStack[SELF:_TopStack]:Pos := foundPos
        SELF:_ntxStack[SELF:_TopStack]:Page := pageOffset
        SELF:_ntxStack[SELF:_TopStack]:Count := nodeCount
        //
        node:Fill(foundPos, ntxPage)
        IF (node:PageNo != 0)
            RETURN SELF:_locate(keyBuffer, bufferLen, searchMode, node:PageNo)
        ENDIF
        //
        IF (foundPos < nodeCount)
            BEGIN SWITCH searchMode
            CASE NtxSearchMode.LeftFound
            CASE NtxSearchMode.Bottom
            CASE NtxSearchMode.Top
                IF (SELF:_knownRecno != node:Recno)
                    SELF:_saveRecordState(node)
                ENDIF
                RETURN node:Recno
            CASE NtxSearchMode.Left
                IF (SELF:__Compare(node:KeyBytes, keyBuffer, bufferLen) == 0)
                    IF (SELF:_knownRecno != node:Recno)
                        SELF:_saveRecordState(node)
                    ENDIF
                    RETURN node:Recno
                ENDIF
                RETURN 0
            CASE NtxSearchMode.Right
                RETURN 0
            END SWITCH
        ELSE
            IF (searchMode == NtxSearchMode.LeftFound)
                DO WHILE (SELF:_TopStack != 0) .AND. (SELF:_ntxStack[SELF:_TopStack]:Pos == SELF:_ntxStack[SELF:_TopStack]:Count)
                    SELF:PopPage()
                ENDDO
                IF (SELF:_TopStack != 0)
                    ntxPage := SELF:_PageList:Read(SELF:_ntxStack[SELF:_TopStack]:Page)
                    IF (ntxPage == NULL)
                        SELF:ClearStack()
                        RETURN 0
                    ENDIF
                    node:Fill(SELF:_ntxStack[SELF:_TopStack]:Pos, ntxPage)
                    IF (SELF:_knownRecno != node:Recno)
                        SELF:_saveRecordState(node)
                    ENDIF
                    RETURN node:Recno
                ENDIF
            ENDIF
            ENDIF
            RETURN 0
            
            
    PRIVATE METHOD PopPage() AS VOID
        IF SELF:_TopStack != 0
            SELF:_ntxStack[SELF:_TopStack]:Clear()
            SELF:_TopStack--
        ENDIF
            
    PRIVATE METHOD ClearStack() AS VOID
        //
        FOREACH entry AS NtxStack IN SELF:_ntxStack 
            entry:Clear()
        NEXT
        SELF:_TopStack := 0
            
            
    PRIVATE METHOD AllocPage() AS NtxPage
        LOCAL ntxPage AS NtxPage
        LOCAL lNextPage AS LONG
        //
        IF SELF:_nextUnusedPageOffset > 0
            lNextPage := (INT)SELF:_nextUnusedPageOffset
            ntxPage := SELF:_PageList:Update(lNextPage)
            SELF:_nextUnusedPageOffset := (DWORD)ntxPage[0]:PageNo
        ELSE
            lNextPage := SELF:_fileSize
            SELF:_fileSize += NtxConst.BUFF_SIZE
            ntxPage := SELF:_PageList:Append(lNextPage)
        ENDIF
        RETURN ntxPage
            
            
        PRIVATE METHOD _lockForRead() AS LOGIC
            LOCAL locked AS LOGIC
            //
            locked := TRUE
            IF SELF:_Shared
                IF !SELF:_HPLocking
                    locked := SELF:_WriteLock()
                ELSE
                    locked := SELF:_ReadLock()
                ENDIF
                IF (!locked)
                    SELF:_oRdd:_dbfError(SubCodes.ERDD_READ_LOCK, GenCode.EG_LOCK, SELF:fileName)
                    RETURN FALSE
                ENDIF
            ENDIF
            RETURN locked
            
            
        PRIVATE METHOD _unLockForRead() AS LOGIC
            LOCAL result AS LOGIC
            //
            result := TRUE
            IF SELF:_Shared
                IF !SELF:_HPLocking
                    result := SELF:_WriteUnLock()
                ELSE
                    result := SELF:_ReadUnLock()
                ENDIF
            ENDIF
            RETURN result
            
            
        PRIVATE METHOD _ReadLock() AS LOGIC
            LOCAL isOk AS LOGIC
            //
            isOk := TRUE
            Trace.Assert(SELF:_writeLocks == 0, "Attempting read lock while holding write lock")
            IF SELF:_readLocks != 0
                SELF:_readLocks++
            ELSE
                REPEAT
                    isOk := TRUE
                    IF SELF:_HPLocking
                        IF !SELF:_TryReadLock()
                            isOk := FALSE
                        ELSE
                            SELF:_readLocks++
                        ENDIF
                    ELSE
                        IF (!SELF:_tryExclLock())
                            isOk := FALSE
                        ELSE
                            SELF:_readLocks++
                        ENDIF
                    ENDIF
                UNTIL (isOk)
                SELF:_LockStuff()
            ENDIF
            RETURN isOk
            
            
        PRIVATE METHOD _ReadUnLock() AS LOGIC
            LOCAL result AS LOGIC
            //
            result := TRUE
            Trace.Assert(SELF:_readLocks != 0, "Attempting read unlock with no pending locks")
            IF SELF:_readLocks != 0
                SELF:_readLocks--
                IF SELF:_readLocks == 0
                    Trace.Assert(!SELF:_Hot, "ntx unlock hot")
                    IF SELF:_HPLocking
                        IF (!SELF:_tryReadUNLOCK())
                            result := FALSE
                        ENDIF
                    ELSE
                        IF !SELF:_tryExclUnlock()
                            result := FALSE
                        ENDIF
                    ENDIF
                ENDIF
            ENDIF
            RETURN result
            
            
        PRIVATE METHOD _WriteLock() AS LOGIC
            LOCAL isOk AS LOGIC
            //
            isOk := TRUE
            IF SELF:_writeLocks != 0
                SELF:_writeLocks++
            ELSE
                REPEAT
                    isOk := TRUE
                    IF SELF:_HPLocking
                        IF !SELF:_TryWriteLock()
                            isOk := FALSE
                        ELSE
                            SELF:_writeLocks++
                        ENDIF
                    ELSE
                        IF !SELF:_TryExclLock()
                            isOk := FALSE
                        ELSE
                            SELF:_writeLocks++
                        ENDIF
                    ENDIF
                UNTIL (isOk)
                SELF:_LockStuff()
            ENDIF
            RETURN isOk
            
            
        PRIVATE METHOD _WriteUnLock() AS LOGIC
            LOCAL isOk AS LOGIC
            //
            isOk := TRUE
            IF SELF:_writeLocks != 0
                SELF:_writeLocks--
                IF SELF:_writeLocks == 0
                    IF SELF:_HPLocking
                        IF !SELF:_TryWriteUNLOCK()
                            isOk := FALSE
                        ENDIF
                    ELSE
                        IF !SELF:_tryExclUnlock()
                            isOk := FALSE
                        ENDIF
                    ENDIF
                ENDIF
            ENDIF
            RETURN isOk
            
            
        PRIVATE METHOD _LockStuff() AS VOID
            IF SELF:_getHeader()
                SELF:_PageList:Flush(FALSE)
                
                FSeek3( SELF:_hFile, 0, FS_END )
                SELF:_fileSize  := (LONG)FTell( SELF:_hFile ) 
                SELF:ClearStack()
            ENDIF
            
        PRIVATE METHOD _genSeed() AS LONG
            LOCAL dateTime AS DateTime
            //
            dateTime := DateTime{Environment.TickCount}
            RETURN ((dateTime:Hour * 60 + dateTime:Minute) * 60 + dateTime:Second) * 100 + dateTime:Millisecond
            
        PRIVATE METHOD _lockBytes( nOffset AS DWORD, nLong AS DWORD , retries AS DWORD ) AS LOGIC
            LOCAL isOk AS LOGIC
            LOCAL counter AS DWORD
            //
            isOk := FALSE
            counter := 0
            isOk := SELF:_lockBytes( nOffset, nLong )
            DO WHILE (!isOk) .AND. (counter++ < retries)
                isOk := SELF:_lockBytes( nOffset, nLong )
                Thread.Sleep(1)
            ENDDO
            RETURN isOk
            
        PRIVATE METHOD _lockBytes( nOffset AS DWORD, nLong AS DWORD  ) AS LOGIC
            LOCAL locked AS LOGIC
            //
            TRY
                locked := FFLock( SELF:_hFile, nOffset, nLong )
            CATCH ex AS Exception
                Trace.WriteLine("Lock Error:" + ex:Message)
                locked := FALSE
            END TRY
            //
            RETURN locked
            
        PRIVATE METHOD _unlockBytes( nOffset AS DWORD, nLong AS DWORD  ) AS LOGIC
            LOCAL unlocked AS LOGIC
            //
            TRY
                unlocked := FFUnLock( SELF:_hFile, nOffset, nLong )
            CATCH ex AS Exception
                Trace.WriteLine("UnLock Error:" + ex:Message)
                unlocked := FALSE
            END TRY
            //
            RETURN unlocked
            
        PRIVATE METHOD _lockGate( tag AS INT ) AS LOGIC
            LOCAL count AS DWORD
            LOCAL isOk AS LOGIC
            LOCAL liOffSet AS LONG
            //
            count := 0
            isOk := FALSE
            liOffSet := ~ SELF:_getParkLotGate( tag )
            DO WHILE (count++ < SELF:_maxLockTries ) .AND. (!isOk)
                isOk := SELF:_lockBytes((DWORD)liOffSet, 1)
            ENDDO
            RETURN isOk
            
        PRIVATE METHOD _lockInit() AS LOGIC
            LOCAL tries AS LONG
            LOCAL seed AS LONG
            //
            tries := 0
            seed := 0
            SELF:_parkPlace := 0
            seed := SELF:_genSeed()
            // MAX_TRIES := 50 
            DO WHILE (tries++ < NtxConst.MAX_TRIES ) .AND. (SELF:_parkPlace == 0)
                IF (seed <= 0)
                    seed := 1
                ENDIF
                seed := (seed * 1221 + 1) % ParkingLot:LOT_SIZE 
                SELF:_parkPlace := seed
                IF !SELF:_lockBytes( ~(SELF:_parkPlace + ParkingLot.TOKEN_AREA), 1)
                    RETURN FALSE
                ENDIF
            ENDDO
            //
            RETURN TRUE            
            
        PRIVATE METHOD _lockExit() AS LOGIC
            RETURN SELF:_unLockBytes( (DWORD)~(SELF:_parkPlace + 1), 1)
            
        PRIVATE METHOD _TryReadLock() AS LOGIC
            LOCAL result AS LOGIC
            LOCAL liOffSet AS LONG
            //
            result := FALSE
            IF _LockGate(SELF:_tagNumber)
                liOffSet := ~(SELF:_getParkLotPlace(SELF:_tagNumber) + SELF:_parkPlace)
                IF (!SELF:_lockBytes((DWORD)liOffSet, 1))
                    SELF:_unlockBytes( (DWORD)~SELF:_getParkLotGate( SELF:_tagNumber ), 1)
                    SELF:_LockExit()
                    SELF:_LockInit()
                ELSE
                    SELF:_unlockBytes( (DWORD)~SELF:_getParkLotGate( SELF:_tagNumber ), 1)
                    result := TRUE
                ENDIF
            ENDIF
            RETURN result
            
            
        PRIVATE METHOD _tryReadUnLock() AS LOGIC
            LOCAL liOffSet AS LONG
            //
            liOffSet := ~( SELF:_getParkLotPlace(SELF:_tagNumber) + SELF:_parkPlace )
            RETURN SELF:_unlockBytes( (DWORD)liOffSet, 1)
            
            
        PRIVATE METHOD _tryWriteUnLock() AS LOGIC
            LOCAL liOffSet AS LONG
            //
            liOffSet := ~( SELF:_getParkLotPlace(SELF:_tagNumber) + ParkingLot.LOT_SIZE )
            RETURN SELF:_unlockBytes( (DWORD)liOffSet, 1)
            
        PRIVATE METHOD _TryWriteLock() AS LOGIC
            LOCAL liOffSet AS LONG
            LOCAL maxTries AS DWORD
            LOCAL isOk AS LOGIC
            //
            liOffSet := 0
            maxTries := 990
            isOk := FALSE
            IF SELF:_lockGate( SELF:_tagNumber )
                DO WHILE (maxTries++ < SELF:_maxLockTries) .AND. (!isOk)
                    liOffSet := ~( SELF:_getParkLotPlace(SELF:_tagNumber) + ParkingLot.LOT_SIZE )
                    isOk := SELF:_lockBytes((DWORD)liOffSet, ParkingLot.LOT_SIZE)
                ENDDO
                IF (!isOk)
                    SELF:_unlockBytes( (DWORD)~SELF:_getParkLotGate( SELF:_tagNumber ), 1)
                ENDIF
            ENDIF
            RETURN isOk
            
        PRIVATE METHOD _getParkLotPlace( place AS LONG ) AS LONG
            RETURN ParkingLot.ROOT_LOT + ParkingLot:LOT_SIZE * place
            
        PRIVATE METHOD _getParkLotGate( tagNumber AS LONG ) AS LONG
            RETURN ParkingLot.ROOT_GATE + ParkingLot:LOT_SIZE * tagNumber
            
        PRIVATE METHOD _tryExclLock() AS LOGIC
            RETURN SELF:_lockBytes( (DWORD)SELF:_lockScheme:Offset, 1, (DWORD)SELF:_maxLockTries)
            
            
        PRIVATE METHOD _tryExclUnlock() AS LOGIC
            RETURN SELF:_unlockBytes( (DWORD)SELF:_lockScheme:Offset, 1)
            
        PRIVATE METHOD _getTypeCode(oValue AS OBJECT ) AS TypeCode
            LOCAL typeCde AS TypeCode
            //
            IF oValue == NULL
                typeCde := TypeCode.Empty
            ELSE
                typeCde := Type.GetTypeCode(oValue:GetType())
                SWITCH typeCde
                CASE TypeCode.SByte
                CASE TypeCode.Byte
                CASE TypeCode.Int16
                CASE TypeCode.UInt16
                CASE TypeCode.Int32
                   typeCde := TypeCode.Int32
                CASE TypeCode.UInt32
                CASE TypeCode.Int64
                CASE TypeCode.UInt64
                CASE TypeCode.Single
                CASE TypeCode.Double
                    typeCde := TypeCode.Double
                CASE TypeCode.Boolean
                    typeCde := TypeCode.Boolean
                CASE TypeCode.String
                    typeCde := TypeCode.String
                CASE TypeCode.DateTime
                    typeCde := TypeCode.DateTime
                CASE TypeCode.Object
                    IF oValue IS IDate
                        typeCde := TypeCode.DateTime
                    ELSEIF  oValue IS IFloat
                        typeCde := TypeCode.Double
                    ENDIF
                END SWITCH
            ENDIF
            RETURN typeCde   
            
            
        INTERNAL ENUM ParkingLot
            MEMBER SPACES_SIZE := 1024                              // 1K of token space
            MEMBER GATE_SIZE := 1
            MEMBER LOT_SIZE := SPACES_SIZE + GATE_SIZE              // All elements, including spaces and gate
            
            MEMBER TOKEN_AREA := 1                                  // parking space tokens
            MEMBER ROOT_GATE := TOKEN_AREA + SPACES_SIZE + 1        // root parking lot gate
            MEMBER ROOT_LOT := ROOT_GATE + GATE_SIZE                // root parking lot
        END ENUM
        
        INTERNAL ENUM NtxConst
            MEMBER  BUFF_SIZE	:= 1024
            MEMBER NTX_COUNT    := 16
            MEMBER NTX_S_COUNT  := 20
            
            MEMBER MIN_BYTE     := 0x01
            MEMBER MAX_BYTE     := 0xFF
            MEMBER MAX_KEY_LEN  := 256
            
            MEMBER MAX_TRIES    := 50
            
        END ENUM
        
        
    END CLASS
    
    
    
    
END NAMESPACE


