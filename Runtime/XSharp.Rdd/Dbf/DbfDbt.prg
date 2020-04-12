//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
USING System.Text
USING XSharp.RDD.Enums
USING XSharp.RDD.Support

BEGIN NAMESPACE XSharp.RDD
    /// <summary>DBFDBT RDD. For DBF/DBT. No index support at this level</summary>
    CLASS DBFDBT INHERIT DBF
        PRIVATE _oDbtMemo AS DBTMemo
        PROPERTY Encoding AS Encoding GET SUPER:_Encoding

        CONSTRUCTOR
            SUPER()
            SELF:_Memo := _oDbtMemo := DBTMemo{SELF}
            
        VIRTUAL PROPERTY Driver AS STRING GET "DBFDBT"
        // Return the memo content as STRING
        METHOD GetValue(nFldPos AS LONG) AS OBJECT
            LOCAL buffer AS BYTE[]
            // not a memo ?
            IF SELF:_isMemoField( nFldPos )
                // At this level, the return value is the raw Data, in BYTE[]
                buffer := (BYTE[])SUPER:GetValue(nFldPos)
                IF ( buffer != NULL )
                    LOCAL str AS STRING
                    str :=  SELF:Encoding:GetString(buffer)
                    // Convert to String and return
                    RETURN str
                ELSE
                    // No Memo ?!, Empty String
                    RETURN String.Empty
                ENDIF
            ENDIF
            RETURN SUPER:GetValue(nFldPos)

        /// <inheritdoc />
        VIRTUAL METHOD Info(nOrdinal AS INT, oNewValue AS OBJECT) AS OBJECT
            LOCAL oResult AS OBJECT
            SWITCH nOrdinal
            CASE DbInfo.DBI_MEMOHANDLE
                IF ( SELF:_oDbtMemo != NULL .AND. SELF:_oDbtMemo:_Open)
                    oResult := SELF:_oDbtMemo:_hFile
                ELSE
                    oResult := IntPtr.Zero
                ENDIF
                    
            CASE DbInfo.DBI_MEMOEXT
                IF ( SELF:_oDbtMemo != NULL .AND. SELF:_oDbtMemo:_Open)
                    oResult := System.IO.Path.GetExtension(SELF:_oDbtMemo:_FileName)
                ELSE
                    oResult := DBT_MEMOEXT
                ENDIF
                IF oNewValue IS STRING VAR strExt
                    DBTMemo.DefExt := strExt
                ENDIF
            CASE DbInfo.DBI_MEMOBLOCKSIZE
                oResult := SELF:_oDbtMemo:BlockSize
            CASE DbInfo.DBI_MEMOFIELD
                SELF:ForceRel()
                oResult := ""
                IF oNewValue != NULL
                    TRY
                       LOCAL fldPos AS LONG
                       fldPos := Convert.ToInt32(oNewValue)
                       oResult := SELF:GetValue(fldPos)
                    CATCH ex AS Exception
                        oResult := ""   
                        SELF:_dbfError(ex, Subcodes.ERDD_DATATYPE, Gencode.EG_DATATYPE, "DBFDBT.Info")
                    END TRY
                ENDIF
			CASE DbInfo.DBI_MEMOTYPE
                oResult := DB_MEMO_DBT
            CASE DbInfo.DBI_MEMOVERSION
                oResult := DB_MEMOVER_STD
            OTHERWISE
                oResult := SUPER:Info(nOrdinal, oNewValue)
            END SWITCH
            RETURN oResult
            
            
     END CLASS
            
            
            
            
        /// <summary>DBT Memo class. Implements the DBT support.</summary>
        // See https://www.clicketyclick.dk/databases/xbase/format/dbt.html#DBT_STRUCT/
    //
    INTERNAL CLASS DBTMemo INHERIT BaseMemo IMPLEMENTS IMemo
        INTERNAL _hFile	    AS IntPtr
        INTERNAL _FileName  AS STRING
        INTERNAL _Open      AS LOGIC
        PROTECT _Shared     AS LOGIC
        PROTECT _ReadOnly   AS LOGIC
        PROTECT _oRdd       AS DBF
        PROTECT _blockSize  AS SHORT
        PROTECT _lockScheme AS DbfLocking
        PROPERTY Shared AS LOGIC GET _Shared
        PROTECTED PROPERTY IsOpen AS LOGIC GET SELF:_hFile != F_ERROR  .AND. SELF:_hFile != IntPtr.Zero      

        STATIC PROPERTY DefExt AS STRING AUTO
        STATIC CONSTRUCTOR
            DefExt := DBT_MEMOEXT
        
        VIRTUAL PROPERTY BlockSize 	 AS SHORT
            GET 
                RETURN SELF:_blockSize
            END GET
            
            SET 
                SELF:_blockSize := value
            END SET
            
        END PROPERTY
        
        
        
        INTERNAL CONST HeaderSize := 512 AS LONG
        
        CONSTRUCTOR (oRDD AS DBF)
            SUPER(oRDD)
            SELF:_oRdd := oRDD
            SELF:_hFile := F_ERROR
            SELF:_Shared := SELF:_oRdd:_Shared
            SELF:_ReadOnly := SELF:_oRdd:_ReadOnly
            // We should read the MEMOBLOCK setting here : 512 Per default
            SELF:_blockSize := 0
            
            
        VIRTUAL PROTECTED METHOD _initContext() AS VOID
            SELF:_blockSize := DBT_DEFBLOCKSIZE
            SELF:_lockScheme:Initialize( DbfLockingModel.Clipper52 )
            SELF:_Open  := TRUE
            
            
            /// <inheritdoc />
        METHOD Flush() 			AS LOGIC
            LOCAL isOk AS LOGIC
            isOk := ( SELF:_hFile != F_ERROR )
            IF isOk
                isOk := FFlush( SELF:_hFile )
            ENDIF
            RETURN isOk
            
            /// <inheritdoc />
        METHOD GetValue(nFldPos AS INT) AS OBJECT
            LOCAL blockNbr AS LONG
            LOCAL blockLen := 0 AS LONG
            LOCAL memoBlock := NULL AS BYTE[]
            //
            blockNbr := SELF:_oRdd:_getMemoBlockNumber( nFldPos )
            IF ( blockNbr > 0 )
                // Get the raw Length of the Memo
                blockLen := SELF:_getValueLength( nFldPos )
                IF blockLen > 0 
                    memoBlock := BYTE[]{ blockLen }
                    // Where do we start ?
                    LOCAL iOffset := blockNbr * SELF:BlockSize AS LONG
                    //
                    FSeek3( SELF:_hFile, iOffset, FS_SET )
                    // Max 512 Blocks
                    LOCAL isOk AS LOGIC
                    isOk := ( FRead3( SELF:_hFile, memoBlock, (DWORD)blockLen ) == blockLen )
                    IF ( !isOk )
                        memoBlock := NULL
                    ENDIF
                ENDIF
            ENDIF
            // At this level, the return value is the raw Data, in BYTE[]
            RETURN memoBlock
            
            /// <inheritdoc />
        METHOD GetValueFile(nFldPos AS INT, fileName AS STRING) AS LOGIC
            THROW NotImplementedException{}
            
            /// <inheritdoc />
        METHOD GetValueLength(nFldPos AS INT) AS INT
            RETURN SELF:_getValueLength( nFldPos )
            
            // Do the calculation for the MemoLength
        VIRTUAL PROTECTED METHOD _getValueLength(nFldPos AS INT) AS INT
            LOCAL blockNbr AS LONG
            LOCAL blockLen := 0 AS LONG
            // Where does the block start ?
            blockNbr := SELF:_oRdd:_getMemoBlockNumber( nFldPos )
            IF ( blockNbr > 0 ) 
                // File Open ?
                LOCAL isOk := ( SELF:_hFile != F_ERROR ) AS LOGIC
                IF isOk
                    // We don't need to store all the data, just read block by block
                    // in a temporary buffer, to count the needed size
                    LOCAL memoBlock AS BYTE[]
                    memoBlock := BYTE[]{SELF:BlockSize}
                    // Where do we start ?
                    LOCAL iOffset := blockNbr * SELF:BlockSize AS LONG
                    // Go to the blockNbr position
                    FSeek3( SELF:_hFile, iOffset, FS_SET )
                    // 
                    LOCAL sizeRead := 1 AS LONG
                    LOCAL endPos := -1 AS LONG
                    WHILE ( sizeRead > 0 ) .AND. ( endPos == - 1 )
                        sizeRead := (LONG)FRead3( SELF:_hFile, memoBlock, (DWORD)SELF:BlockSize )
                        IF ( sizeRead > 0 )
                            // Search for one field terminator (1Ah)
                            endPos := Array.FindIndex<BYTE>( memoBlock, { x => x == 0x1A } )
                            IF ( endPos == - 1 )
                                blockLen += sizeRead
                            ELSE
                                // Some docs says that Memo ends with two field teminator ???
                                // https://www.clicketyclick.dk/databases/xbase/format/dbt.html
                                // but ok, let say only one.
                                blockLen += endPos
                            ENDIF
                        ENDIF
                    ENDDO
                ENDIF
            ENDIF
            RETURN blockLen
            
            /// <inheritdoc />
        VIRTUAL METHOD PutValue(nFldPos AS INT, oValue AS OBJECT) AS LOGIC
            LOCAL objType AS System.Type
            LOCAL objTypeCode AS System.TypeCode
            LOCAL str := NULL AS STRING
            LOCAL memoBlock AS BYTE[]
            LOCAL isOk := FALSE AS LOGIC
            LOCAL locked := FALSE AS LOGIC
            //
            IF !SELF:IsOpen
                RETURN FALSE
            ENDIF
            //
            objType := oValue:GetType()
            objTypeCode := Type.GetTypeCode( objType )
            //
            IF ( objTypeCode == TypeCode.Char )
                str := STRING{ (CHAR)oValue, 1 }
            ELSEIF ( objTypeCode == TypeCode.String )
                str := oValue ASTYPE STRING
            ENDIF
            // Not a Char, Not a String
            IF ( str == NULL )
                memoBlock := (BYTE[])oValue
            ELSE
                LOCAL encoding AS Encoding //ASCIIEncoding
                memoBlock := BYTE[]{str:Length}
                encoding := SELF:_oRdd:_Encoding 
                encoding:GetBytes( str, 0, str:Length, memoBlock, 0 )
            ENDIF
            // Now, calculate where we will write the Datas
            LOCAL blockNbr AS LONG
            LOCAL blockLen := 0 AS LONG
            LOCAL newBlock AS LOGIC
            // Suppose we will have a new start of block
            newBlock := TRUE
            // Where are currently stored the datas ?
            blockNbr := SELF:_oRdd:_getMemoBlockNumber( nFldPos )
            IF ( blockNbr > 0 ) 
                // Existing block ? What is it's current raw length ?
                blockLen := SELF:_getValueLength( nFldPos )
                IF blockLen > 0 
                    // Compare the number of Blocks : Do we need more blocks ?
                    newBlock := ( memoBlock:Length / SELF:_blockSize ) > ( blockLen / SELF:BlockSize )
                ENDIF
            ENDIF
            IF newBlock
                IF SELF:Shared 
                    locked := SELF:_tryLock( (UINT64)SELF:_lockScheme:Offset, 1, (LONG)XSharp.RuntimeState.LockTries )
                ENDIF
                // Go to the end of end, where we will add the new data
                FSeek3( SELF:_hFile, 0, FS_END )
                LOCAL fileSize := (LONG)FTell( SELF:_hFile ) AS LONG
                // But first, check that the Size of Memo file is multiple of BlockSize
                LOCAL toAdd := fileSize % SELF:BlockSize AS LONG
                // No ! Fill the gap
                IF ( toAdd > 0 )
                    toAdd := SELF:BlockSize - toAdd
                    LOCAL dummy AS BYTE[]
                    dummy := BYTE[]{ toAdd }
                    FWrite3( SELF:_hFile, dummy, (DWORD)toAdd )
                    // so, new size is
                    fileSize := (LONG)FTell( SELF:_hFile )
                ENDIF
                // The new block Number to write to is (I supposed we should use NextAvailableBlock, no ?)
                blockNbr := fileSize / SELF:BlockSize
            ELSE
                // Go to the position of the blockNbr
                FSeek3( SELF:_hFile, blockNbr * SELF:BlockSize, FS_SET )
            ENDIF
            // Ok, now write the Datas
            isOk := ( FWrite3( SELF:_hFile, memoBlock, (DWORD)memoBlock:Length ) == memoBlock:Length )
            IF isOk
                // Don't forget to write an End Of Block terminator (1Ah) (Should it be two ??)
                LOCAL eob := <BYTE>{0x1A} AS BYTE[]
                isOk := ( FWrite3( SELF:_hFile, eob, 1 ) == 1 )
                IF isOk .AND. newBlock
                    // We have to update the next block info
                    LOCAL newPos AS LONG // FTell might do the job ?
                    newPos := blockNbr * SELF:BlockSize + memoBlock:Length + 1
                    newPos += SELF:BlockSize - newPos % SELF:BlockSize
                    SELF:NextAvailableBlock := newPos / SELF:BlockSize
                ENDIF
                IF isOk
                    isOk := SELF:Flush()
                ENDIF
            ENDIF
            IF ( locked )
                SELF:_unlock( (UINT64)SELF:_lockScheme:Offset, 1 )
            ENDIF
            //
            IF !isOk
                SELF:_oRdd:_dbfError( ERDD.WRITE, XSharp.Gencode.EG_WRITE )
            ENDIF
            // Now, update the information in the DBF, look at PutValue() in the DbfDbt Class
            SELF:LastWrittenBlockNumber := blockNbr
            RETURN isOk
            
            /// <inheritdoc />
        VIRTUAL METHOD PutValueFile(nFldPos AS INT, fileName AS STRING) AS LOGIC
            THROW NotImplementedException{}
            
            /// <inheritdoc />
        VIRTUAL METHOD CloseMemFile( ) AS LOGIC
            LOCAL isOk := FALSE AS LOGIC
            IF SELF:IsOpen
                //
                TRY
                    isOk := FClose( SELF:_hFile )

                CATCH ex AS Exception
                    isOk := FALSE
                    SELF:_oRdd:_dbfError(ex, Subcodes.ERDD_CLOSE_MEMO, Gencode.EG_CLOSE, "DBFDBT.CloseMemFile")

                END TRY
                SELF:_hFile := F_ERROR
                SELF:_Open  := FALSE
            ENDIF
            RETURN isOk
            
            /// <inheritdoc />
        VIRTUAL METHOD CreateMemFile(info AS DbOpenInfo) AS LOGIC
            LOCAL isOk AS LOGIC
            SELF:_FileName  := info:FileName
            SELF:_FileName  := System.IO.Path.ChangeExtension( SELF:_FileName, DefExt )
            SELF:_Shared    := info:Shared
            SELF:_ReadOnly  := info:ReadOnly
            //
            SELF:_hFile     := FCreate( SELF:_FileName) 
            isOk := SELF:IsOpen
            IF isOk
                // Per default, Header Block Size if 512
                LOCAL memoHeader AS BYTE[]
                LOCAL nextBlock AS LONG
                //
                memoHeader := BYTE[]{ DBTMemo.HeaderSize }
                nextBlock := 1
                Array.Copy(BitConverter.GetBytes(nextBlock),0, memoHeader, 0, SIZEOF(LONG))
                //
                FWrite3( SELF:_hFile, memoHeader, DBTMemo.HeaderSize )
                //
                SELF:_initContext()
            ELSE
                SELF:_oRdd:_dbfError( ERDD.CREATE_MEMO, XSharp.Gencode.EG_CREATE )
            ENDIF
            //
            RETURN isOk
            
            /// <inheritdoc />
        VIRTUAL METHOD OpenMemFile(info AS DbOpenInfo ) AS LOGIC
            LOCAL isOk AS LOGIC
            SELF:_FileName  := info:FileName
            SELF:_FileName  := System.IO.Path.ChangeExtension( SELF:_FileName, DefExt )
            SELF:_Shared    := info:Shared
            SELF:_ReadOnly  := info:ReadOnly
            IF File(_FileName)
                _FileName := FPathName()
            ENDIF

            SELF:_hFile     := FOpen(SELF:_FileName, info:FileMode)
            isOk := SELF:IsOpen
            IF isOk
                // Per default, Block Size if 512
                SELF:_initContext()
            ELSE
                SELF:_oRdd:_dbfError( ERDD.OPEN_MEMO, XSharp.Gencode.EG_OPEN )
                isOk := FALSE
            ENDIF
            //
            RETURN isOk
            
        PROPERTY NextAvailableBlock 	 AS LONG
            GET 
               LOCAL nBlock := 0 AS LONG
               IF SELF:IsOpen
                    LOCAL _memoBlock AS BYTE[]
                    // NextBlock is at the beginning of MemoFile
                    _memoBlock := BYTE[]{4}
                    LOCAL savedPos := FSeek3(SELF:_hFile, 0, FS_RELATIVE ) AS LONG
                    FSeek3( SELF:_hFile, 0, FS_SET )
                    IF ( FRead3( SELF:_hFile, _memoBlock, 4 ) == 4 )
                        nBlock := BitConverter.ToInt32( _memoBlock, 0)
                    ENDIF
                    FSeek3(SELF:_hFile, savedPos, FS_SET )
                ENDIF
                RETURN nBlock
            END GET
            
            SET 
                 IF SELF:IsOpen
                    LOCAL _memoBlock AS BYTE[]
                    _memoBlock := BYTE[]{4}
                    Array.Copy(BitConverter.GetBytes(value),0, _memoBlock, 0, SIZEOF(LONG))
                    LOCAL savedPos := FSeek3(SELF:_hFile, 0, FS_RELATIVE ) AS LONG
                    FSeek3( SELF:_hFile, 0, FS_SET )
                    FWrite3( SELF:_hFile, _memoBlock, 4 )
                    FSeek3(SELF:_hFile, savedPos, FS_SET )
                ENDIF
            END SET
            
        END PROPERTY
        
        // Place a lock : <nOffset> indicate where the lock should be; <nLong> indicate the number bytes to lock
        // If it fails, the operation is tried <nTries> times, waiting 1ms between each operation.
        // Return the result of the operation
        PROTECTED METHOD _tryLock( nOffset AS UINT64, nLong AS LONG, nTries AS LONG  ) AS LOGIC
            LOCAL locked AS LOGIC
            IF ! SELF:IsOpen
                RETURN FALSE
            ENDIF
  
            REPEAT
                TRY
                    locked := FFLock( SELF:_hFile, (DWORD)nOffset, (DWORD)nLong )
                CATCH ex AS Exception
                    locked := FALSE
                    SELF:_oRdd:_dbfError(ex, Subcodes.ERDD_INIT_LOCK, Gencode.EG_LOCK_ERROR, "DBFDBT._tryLock")
                END TRY
                IF ( !locked )
                    nTries --
                    IF ( nTries > 0 )
                        System.Threading.Thread.Sleep( 1 )
                    ENDIF
                ENDIF
            UNTIL ( locked .OR. (nTries==0) )
            //
            RETURN locked
            
        PROTECTED METHOD _unlock( nOffset AS UINT64, nLong AS LONG ) AS LOGIC
            LOCAL unlocked AS LOGIC
            //
            IF ! SELF:IsOpen
                RETURN FALSE
            ENDIF
            TRY
                unlocked := FFUnLock( SELF:_hFile, (DWORD)nOffset, (DWORD)nLong )
            CATCH ex AS Exception
                unlocked := FALSE
                SELF:_oRdd:_dbfError(ex, Subcodes.ERDD_UNLOCKED, Gencode.EG_UNLOCKED, "DBFDBT._unlock")

            END TRY
            RETURN unlocked
            
        VIRTUAL METHOD Zap() AS LOGIC
            IF SELF:IsOpen
                IF SELF:Shared
                    SELF:_oRdd:_dbfError(FException(), Subcodes.ERDD_SHARED, Gencode.EG_LOCK, "DbtMemo.Zap")
                ENDIF
                IF ! FChSize(SELF:_hFile, DBTMemo.HeaderSize)
                    SELF:_oRdd:_dbfError(FException(), Subcodes.ERDD_WRITE, Gencode.EG_WRITE, "DbtMemo.Zap")
                ENDIF
                SELF:NextAvailableBlock := 1
                RETURN SELF:Flush()
            ELSE
                SELF:_oRdd:_dbfError(FException(), Subcodes.EDB_NOTABLE, Gencode.EG_NOTABLE, "DbtMemo.Zap")
                RETURN FALSE
            ENDIF

            
      END CLASS    
    
    
    
    
END NAMESPACE
