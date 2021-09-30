﻿// AbstractMemo.prg
// Created by    : robert
// Creation Date : 4/1/2020 10:21:25 AM
// Created for   :
// WorkStation   : ARTEMIS


USING System
USING System.Collections.Generic
USING System.Text
USING XSharp.RDD.Enums
USING XSharp.RDD.Support
USING System.IO

BEGIN NAMESPACE XSharp.RDD
    /// <summary>FPT Memo class. Implements the FTP support.</summary>
    // To also support FPT files created with FlexFile we also need to read the FlexFile header and decode that.

    INTERNAL CLASS FPTMemo INHERIT AbstractMemo IMPLEMENTS IMemo
        PROTECT _isFlex     AS LOGIC
        PRIVATE _blockData AS BYTE[]
        PRIVATE _fptHeader AS FptHeader
        PRIVATE _flexHeader AS FlexHeader
        PRIVATE _lockCount AS LONG
        PRIVATE _nextFree   AS LONG
        INTERNAL CONST FPT_HEADER_SIZE          := 512 AS LONG
        INTERNAL CONST MIN_FOXPRO_BLOCKSIZE     := 32 AS LONG
        INTERNAL CONST FLEX_HEADER_OFFSET       := 512 AS LONG
        INTERNAL CONST FLEX_HEADER_SIZE         := 512 AS LONG
        INTERNAL CONST VERSION_MAJOR := 2   AS LONG
        INTERNAL CONST VERSION_MINOR := 8   AS LONG
        PRIVATE _hotHeader AS LOGIC


        STATIC PROPERTY DefExt AS STRING AUTO
        INTERNAL PROPERTY IsFlex AS LOGIC GET _isFlex
        STATIC CONSTRUCTOR
            DefExt := FPT_MEMOEXT


        PRIVATE METHOD LockHeader(refreshHeaders AS LOGIC) AS LOGIC
            LOCAL lOk := TRUE AS LOGIC
            IF SELF:Shared
                IF SELF:_lockCount == 0
                    DO WHILE ! SELF:_tryLock(0, 1, 10)
                        SELF:_lockCount := 1
                    ENDDO
                    SELF:_lockCount := 1
                ELSE
                    SELF:_lockCount += 1
                ENDIF
                IF refreshHeaders
                    IF SELF:ReadHeader()
                        IF SELF:IsFlex
                            // Deal with indexes of deleted blocks
                        ENDIF
                    ELSE
                        SELF:Error(FException(), Subcodes.ERDD_READ, Gencode.EG_READ, "FPTMemo.LockHeader")
                    ENDIF
                ENDIF
            ELSE
                SELF:_lockCount += 1
            ENDIF
            RETURN lOk


        PRIVATE METHOD UnLockHeader(updated AS LOGIC) AS LOGIC
            IF updated
               SELF:_hotHeader := TRUE
            ENDIF
            IF SELF:_lockCount <= 1
                IF SELF:_hotHeader
                    SELF:WriteHeader()
                ENDIF
                IF SELF:Shared
                    _oStream:Flush()
                    IF ! SELF:_unlock(0,1)
                    ENDIF
                ENDIF
                SELF:_lockCount := 0
            ELSE
                SELF:_lockCount -= 1
            ENDIF
            RETURN TRUE

        PRIVATE METHOD GetMemoExtFromDbfExt(cDbfName AS STRING) AS STRING
            SWITCH System.IO.Path.GetExtension(cDbfName:ToLower())
            CASE ".vcx"         // Control Library
                RETURN ".VCT"
            CASE ".scx"         // Screen
                RETURN ".SCT"
            CASE ".pjx"         // Project
                RETURN ".PJT"
            CASE ".frx"         // Report
                RETURN ".FRT"
            CASE ".lbx"         // Label
                RETURN ".LBT"
            CASE ".mnx"         // Menu
                RETURN ".MNT"
            CASE ".dbc"         // database container
                RETURN ".dct"
            END SWITCH
            RETURN DefExt


        CONSTRUCTOR (oRDD AS DBF)
            SUPER(oRDD)
            SELF:_blockData := BYTE[]{8}
            SELF:_fptHeader   := FptHeader{}
            SELF:_flexHeader  := FlexHeader{}
            SELF:_lockCount   := 0


        VIRTUAL PROTECTED METHOD _initContext() AS VOID
            SELF:_lockScheme:Initialize( DbfLockingModel.FoxPro )
            SELF:ReadHeader()
            IF ( SELF:BlockSize == 0 )
                //SELF:BlockSize := FPT_DEFBLOCKSIZE
                SELF:BlockSize := Convert.ToUInt16(XSharp.RuntimeState.MemoBlockSize)
                SELF:WriteHeader()
            ENDIF



            /// <inheritdoc />
        METHOD GetValue(nFldPos AS INT) AS OBJECT
            LOCAL blockNbr AS LONG
            LOCAL blockLen := 0 AS LONG
            LOCAL block := NULL AS BYTE[]
            blockNbr := SELF:_oRdd:_getMemoBlockNumber( nFldPos )
            IF ( blockNbr > 0 )
                // Get the raw Length of the Memo, this included the token
                blockLen := SELF:_getValueLength( nFldPos )
		        IF blockLen != Int32.MaxValue
	                IF SELF:_setBlockPos(blockNbr)
        	            block := BYTE[]{blockLen}
                        IF !_oStream:SafeRead( block, blockLen )
                        	block := NULL
	                    ENDIF
			        ENDIF
                ELSE
                    SELF:Error(FException(),Subcodes.ERDD_READ, Gencode.EG_CORRUPTION, "FPTMemo.GetValue")
                ENDIF
            ENDIF
            // At this level, the return value is the raw Data, in BYTE[]
            RETURN block

            /// <inheritdoc />
         OVERRIDE METHOD GetValueFile(nFldPos AS LONG, fileName AS STRING) AS LOGIC
          IF SELF:_oRdd:_isMemoField( nFldPos )
                // At this level, the return value is the raw Data, in BYTE[]
                TRY
                    IF File(fileName)
                        fileName := FPathName()
                    ENDIF
                    VAR rawData := (BYTE[])SELF:GetValue(nFldPos)
                    IF rawData != NULL
                        // So, extract the "real" Data
                        VAR oDbfFpt := SELF:_oRdd ASTYPE DBFFPT
                        IF oDbfFpt:_iExportMode == BLOB_EXPORT_APPEND
                            LOCAL file := System.IO.File.OpenWrite(fileName) AS FileStream
                            file:Seek(0, SeekOrigin.End)
                            file:Write(rawData, 8, rawData:Length-8)
                            file:Close()
                        ELSE
                            LOCAL file := System.IO.File.Create(fileName) AS FileStream
                            file:Write(rawData, 8, rawData:Length-8)
                            file:Close()
                        ENDIF
                        RETURN TRUE
                    ENDIF
                CATCH ex AS Exception
                    SELF:Error(ex, Subcodes.ERDD_READ, Gencode.EG_READ, "DBFFPT.GetValueFile")
                END TRY
            ENDIF
            RETURN SUPER:GetValueFile(nFldPos, fileName)

            /// <inheritdoc />
        METHOD GetValueLength(nFldPos AS INT) AS LONG
            VAR blockLen := SELF:_getValueLength( nFldPos )
            // Don't forget to remove the 8 Bytes
            IF blockLen >= 8
                blockLen := blockLen - 8
            ENDIF
            RETURN (LONG) blockLen

        INTERNAL METHOD _setBlockPos(blockNbr AS LONG) AS LOGIC
            // Get the raw data length
            IF blockNbr > 0
                LOCAL iOffset := blockNbr * SELF:_blockSize AS LONG
                // Go to the blockNbr position
                RETURN _oStream:SafeSetPos(iOffset)
            ENDIF
            RETURN FALSE

        VIRTUAL PROTECTED METHOD _getValueLength(nFldPos AS INT) AS LONG
            // In FPT :
            // The first 4 Bytes contains the type of Memo Data
            // The next 4 Bytes contains the length of Memo data, including the first 8 bytes
            LOCAL blockNbr AS LONG
            LOCAL blockLen := 0 AS INT
            // File Open ?
            IF SELF:IsOpen
                // Where does the block start ?
                blockNbr := SELF:_oRdd:_getMemoBlockNumber( nFldPos )
                IF SELF:_setBlockPos(blockNbr)
                    LOCAL token AS FtpMemoToken
                    token := FtpMemoToken{SELF:_blockData}
                    IF token:Read(SELF:_oStream)
                        blockLen     := token:Length+8
                    ELSE
                        blockLen     := Int32.MaxValue
                    ENDIF
                ENDIF
            ENDIF
            RETURN blockLen

            /// <inheritdoc />

        PRIVATE METHOD WriteFiller(nToWrite AS LONG, lDeleted AS LOGIC) AS VOID
            LOCAL filler AS BYTE[]
            LOCAL fillByte AS BYTE
            LOCAL lIsVfp   AS LOGIC
            lIsVfp   := SELF:_oRdd IS DBFVFP
            fillByte := (BYTE) IIF(lDeleted, 0xF0, IIF(lIsVfp, 0x00, 0xAF))
            filler := BYTE[]{ nToWrite}
            IF fillByte != 0x00
                FOR VAR i := 0 TO nToWrite-1
                    filler[i] := fillByte
                NEXT
            ENDIF
            IF ! _oStream:SafeWrite(filler)
                SELF:Error(FException(), Subcodes.ERDD_WRITE, Gencode.EG_WRITE, "FPTMemo.WriteFiller")
            ENDIF
            RETURN

        PROTECTED INTERNAL METHOD DeleteBlock(blockNbr AS LONG) AS VOID
            // Todo: add deleted block to FlexFile deleted blocks list
            IF SELF:_setBlockPos(blockNbr)
                VAR block := BYTE[]{8}
                _oStream:SafeRead(block, 8)
                LOCAL token AS FtpMemoToken
                token := FtpMemoToken{block}
                token:DataType := FlexFieldType.Delete
                // Adjust the length to the whole of the block. Flexfile also does that
                token:Length   := SELF:RoundToBlockSize(token:Length +8)  - 8
                IF SELF:LockHeader(TRUE)
                    SELF:_setBlockPos(blockNbr)
                    IF ! _oStream:SafeWrite(block, 8)
                        SELF:Error(FException(), Subcodes.ERDD_WRITE, Gencode.EG_WRITE, "FPTMemo.DeleteBlock")
                    ENDIF
                    // Clear the data. FlexFiles does not do that, but I think it's better to clean up.
                    SELF:WriteFiller(token:Length, TRUE)
                    SELF:UnLockHeader(TRUE)
                ENDIF
            ENDIF
            RETURN


        METHOD _WriteBlock (bytes AS BYTE[]) AS LOGIC
            IF ! _oStream:SafeWrite(bytes)
                SELF:Error(FException(), Subcodes.ERDD_WRITE, Gencode.EG_WRITE, "FPTMemo._WriteBlock")
            ENDIF
            // write remainder of block
            LOCAL nToWrite AS LONG
            nToWrite := SELF:CalculateFillerSpace( bytes:Length)
            IF nToWrite != 0
                SELF:WriteFiller(nToWrite, FALSE)
            ENDIF
            RETURN TRUE

        VIRTUAL METHOD PutValue(nFldPos AS INT, oValue AS OBJECT) AS LOGIC
            IF !SELF:IsOpen
                RETURN FALSE
            ENDIF
            VAR bytes := oValue ASTYPE BYTE[]
            IF bytes == NULL
                RETURN FALSE
            ENDIF
            // AT this level the bytes[] array already contains the header with type and length
            LOCAL nCurrentLen AS LONG
            LOCAL blockNbr AS LONG
            LOCAL lNewBlock := FALSE AS LOGIC
            // length including header block
            blockNbr := SELF:_oRdd:_getMemoBlockNumber( nFldPos )
            IF blockNbr != 0
                nCurrentLen := SELF:_getValueLength(nFldPos)
                nCurrentLen := SELF:RoundToBlockSize(nCurrentLen)
                VAR needed := SELF:RoundToBlockSize(bytes:Length)
                IF nCurrentLen >= needed
                    IF SELF:_setBlockPos(blockNbr)
                        IF SELF:LockHeader(TRUE)
                            SELF:_WriteBlock(bytes)
                            SELF:UnLockHeader(TRUE)
                            SELF:LastWrittenBlockNumber := blockNbr
                            RETURN TRUE
                        ENDIF
                    ENDIF
                    SELF:Error(FException(), Subcodes.ERDD_WRITE, Gencode.EG_WRITE, "FPTMemo.PutValue")
                ELSE
                    // Deallocate block and allocate new
                    SELF:DeleteBlock(blockNbr)
                    lNewBlock := TRUE
                ENDIF
            ELSE
                // Allocate block at the end or from free blocks
                // write the block
                lNewBlock := TRUE
            ENDIF
            IF lNewBlock
                IF SELF:LockHeader(TRUE)
                    LOCAL nPos AS LONG
                    nPos := _nextFree  * _blockSize
                    _oStream:SafeSetPos(nPos)
                    SELF:_WriteBlock(bytes)
                    VAR nFileSize := _oStream:Length
                    SELF:_nextFree    := (LONG) nFileSize / _blockSize
                    SELF:LastWrittenBlockNumber := (LONG) (nPos / _blockSize )
                    SELF:UnLockHeader(TRUE)
                ENDIF
                RETURN TRUE
            ENDIF
            RETURN FALSE

            /// <inheritdoc />
        VIRTUAL METHOD PutValueFile(nFldPos AS INT, fileName AS STRING) AS LOGIC
            TRY
                VAR oColumn := SELF:_oRdd:_GetColumn(nFldPos) ASTYPE DbfColumn
                IF oColumn != NULL .AND. oColumn:IsMemo
                    LOCAL bFile AS BYTE[]
                    IF File(fileName)
                        fileName := FPathName()
                        bFile := System.IO.File.ReadAllBytes(fileName)
                        VAR bData := BYTE[] { bFile:Length+8}
                        VAR token := FtpMemoToken{bData}
                        IF bFile:Length > UInt16.MaxValue
                            token:DataType := FlexFieldType.StringLong
                        ELSE
                            token:DataType := FlexFieldType.String
                        ENDIF
                        token:Length   := bFile:Length
                        System.Array.Copy(bFile,0, bData,8, bFile:Length)
                        IF SELF:PutValue(nFldPos, bData)
                            // Update the Field Info with the new MemoBlock Position
                            RETURN oColumn:PutValue(SELF:LastWrittenBlockNumber, SELF:_oRdd:RecordBuffer)
                        ENDIF
                    ENDIF
                ENDIF
            CATCH ex AS Exception
                SELF:Error(ex, Subcodes.ERDD_WRITE, Gencode.EG_WRITE, "FPTMemo.PutValueFile")
            END TRY
            RETURN FALSE

        METHOD RoundToBlockSize(nSize AS LONG) AS LONG
            IF SELF:_blockSize > 1
                VAR nDiff := nSize % _blockSize
                IF nDiff != 0
                    nSize += _blockSize - nDiff
                ENDIF
            ENDIF
            RETURN nSize
        METHOD CalculateFillerSpace(nSize AS LONG) AS LONG
            IF SELF:_blockSize > 1
                LOCAL nToFill AS LONG
                nToFill := nSize %  SELF:_blockSize
                IF nToFill > 0
                    nToFill := SELF:_blockSize - nToFill
                    RETURN  nToFill
                ENDIF
            ENDIF
            RETURN 0

            /// <inheritdoc />
        VIRTUAL METHOD CreateMemFile(info AS DbOpenInfo) AS LOGIC
            LOCAL isOk      AS LOGIC
            SELF:Extension := SELF:GetMemoExtFromDbfExt(info:FileName)
            isOk := SUPER:CreateMemFile(info)
            IF isOk

                IF ! SELF:_fptHeader:Write(SELF:_oStream)
                    SELF:Error(FException(), Subcodes.ERDD_CREATE_MEMO, Gencode.EG_WRITE, "FPTMemo.CreateMemFile")
                ENDIF
                SELF:_flexHeader:Create()
                IF ! SELF:_flexHeader:Write(SELF:_oStream)
                    SELF:Error(FException(), Subcodes.ERDD_CREATE_MEMO, Gencode.EG_WRITE, "FPTMemo.CreateMemFile")
                ENDIF
                SELF:_initContext()
                _nextFree :=  SELF:RoundToBlockSize(FPT_HEADER_SIZE + FLEX_HEADER_SIZE) / _blockSize
                SELF:WriteHeader()
            ELSE
                SELF:Error( FException(), ERDD.CREATE_MEMO, XSharp.Gencode.EG_CREATE, "FPTMemo.CreateMemFile")
            ENDIF

            RETURN isOk

            /// <inheritdoc />
        VIRTUAL METHOD OpenMemFile(info AS DbOpenInfo ) AS LOGIC
            LOCAL isOk AS LOGIC
            SELF:Extension := SELF:GetMemoExtFromDbfExt(info:FileName)
            isOk := SUPER:OpenMemFile(info)
            IF isOk
                // Per default, Block Size if 512
                IF SELF:LockHeader(FALSE)
                    SELF:_initContext()
                    SELF:UnLockHeader(FALSE)
                ENDIF
            ELSE
                SELF:Error( FException(),ERDD.OPEN_MEMO, XSharp.Gencode.EG_OPEN ,"FPTMemo.OpenMemFile")
                isOk := FALSE
            ENDIF
            //
            RETURN isOk

        OVERRIDE PROPERTY BlockSize 	 AS WORD
            GET
                RETURN _blockSize
            END GET
            SET
                _blockSize := value
                IF value >= MIN_FOXPRO_BLOCKSIZE
                    SELF:_fptHeader:BlockSize := value
                ENDIF
                IF SELF:_isFlex
                    IF value >= MIN_FOXPRO_BLOCKSIZE
                        SELF:_flexHeader:AltBlockSize := 0
                    ELSE
                        SELF:_flexHeader:AltBlockSize := value
                    ENDIF
                ENDIF
            END SET
            END PROPERTY


        // Place a lock : <nOffset> indicate where the lock should be; <nLong> indicate the number bytes to lock
        // If it fails, the operation is tried <nTries> times, waiting 1ms between each operation.
        // Return the result of the operation
        PROTECTED METHOD _tryLock( nOffset AS INT64, nLong AS LONG, nTries AS LONG  ) AS LOGIC
            LOCAL locked AS LOGIC
            IF ! SELF:IsOpen
                RETURN FALSE
            ENDIF
            REPEAT
                locked := _oStream:SafeLock(nOffset, nLong )
//                IF ! locked
//                    SELF:Error(FException(), Subcodes.ERDD_INIT_LOCK, Gencode.EG_LOCK_ERROR, "FPTMemo._tryLock")
//                ENDIF
                IF ( !locked )
                    nTries --
                    IF ( nTries > 0 )
                        System.Threading.Thread.Sleep( 1 )
                    ENDIF
                ENDIF
            UNTIL ( locked .OR. (nTries==0) )
            //
            RETURN locked

        PROTECTED METHOD _unlock( nOffset AS INT64, nLong AS LONG ) AS LOGIC
            LOCAL unlocked AS LOGIC
            IF ! SELF:IsOpen
                RETURN FALSE
            ENDIF

            TRY
                _oStream:Unlock( nOffset, nLong )
                unlocked := TRUE
            CATCH ex AS Exception
                unlocked := FALSE
                SELF:Error(ex, Subcodes.ERDD_UNLOCKED, Gencode.EG_UNLOCKED, "FPTMemo._unlock")

            END TRY
            RETURN unlocked


        VIRTUAL METHOD Zap() AS LOGIC
            IF SELF:IsOpen
                IF SELF:Shared
                    SELF:Error(FException(), Subcodes.ERDD_SHARED, Gencode.EG_LOCK, "FPTMemo.Zap")
                ENDIF
                _oStream:SafeSetLength(0)
                SELF:_fptHeader:Clear()
                SELF:_flexHeader:Clear()
                SELF:WriteHeader()
                RETURN TRUE
            ELSE
                SELF:Error(FException(), Subcodes.EDB_NOTABLE, Gencode.EG_NOTABLE, "FPTMemo.Zap")
            ENDIF
            RETURN FALSE

        PRIVATE METHOD ReadHeader() AS LOGIC
            VAR savedPos := _oStream:Position
            VAR nFileLen := _oStream:Length

            IF ! SELF:_fptHeader:Read(SELF:_oStream)
                SELF:Error(FException(), Subcodes.ERDD_READ, Gencode.EG_READ, "FPTMemo.ReadHeader")
            ENDIF
            _blockSize := SELF:_fptHeader:BlockSize
            _nextFree  := SELF:_fptHeader:NextFree
            // read Flex Header
            IF nFileLen >= 1024
                IF ! SELF:_flexHeader:Read(SELF:_oStream)
                     SELF:Error(FException(), Subcodes.ERDD_READ, Gencode.EG_READ, "FPTMemo.ReadHeader")
                ENDIF
                _isFlex := SELF:_flexHeader:Valid
                IF _blockSize == 0 .AND. SELF:_flexHeader:AltBlockSize != 0
                    SELF:_blockSize     := SELF:_flexHeader:AltBlockSize
                ENDIF
            ELSE
                _isFlex := FALSE
            ENDIF
            _oStream:SafeSetPos(savedPos)
            RETURN TRUE

        METHOD WriteHeader() AS VOID
            IF SELF:IsOpen .AND. ! SELF:_oRdd:ReadOnly
                IF SELF:_blockSize >= MIN_FOXPRO_BLOCKSIZE
                    SELF:_fptHeader:BlockSize := _blockSize
                ENDIF
                SELF:_fptHeader:NextFree   := _nextFree
                IF ! SELF:_fptHeader:Write(SELF:_oStream)
                    SELF:Error(FException(), Subcodes.ERDD_WRITE, Gencode.EG_WRITE, "FPTMemo.WriteHeader")
                ENDIF
                // write flex header
                IF SELF:IsFlex
                    IF SELF:_blockSize >= MIN_FOXPRO_BLOCKSIZE
                        SELF:_flexHeader:AltBlockSize := 0
                    ELSE
                        SELF:_flexHeader:AltBlockSize := SELF:_blockSize
                    ENDIF
                    IF ! SELF:_flexHeader:Write(SELF:_oStream)
                        SELF:Error(FException(), Subcodes.ERDD_WRITE, Gencode.EG_WRITE, "FPTMemo.WriteHeader")
                     ENDIF
                ENDIF
            ENDIF
            SELF:_hotHeader := FALSE
            RETURN


    END CLASS

END NAMESPACE

