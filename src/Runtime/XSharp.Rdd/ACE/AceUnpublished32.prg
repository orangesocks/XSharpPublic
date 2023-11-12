USING System
USING System.Runtime.InteropServices

BEGIN NAMESPACE XSharp.ADS
 
    PUBLIC CLASS ACEUNPUB32
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsBuildKeyFromRecord(hTag AS IntPtr, mpucRecBuffer AS STRING , ulRecordLen AS DWORD , [InAttribute] [OutAttribute] pucKey AS CHAR[], pusKeyLen REF WORD ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsClearLastError() AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDeleteFile(hConnect AS IntPtr, pucFileName AS STRING ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDeleteTable(hTable AS IntPtr ) AS DWORD
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD  AdsMemCompare(hConnect AS IntPtr, pucStr1 AS STRING , ulStr1Len AS DWORD , pucStr2 AS STRING , ulStr2Len AS DWORD , usCharSet AS WORD , psResult OUT SHORT ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsMemCompare90(hConnect AS IntPtr, pucStr1 AS STRING , ulStr1Len AS DWORD , pucStr2 AS STRING , ulStr2Len AS DWORD , usCharSet AS WORD , ulCollationID AS DWORD , psResult OUT SHORT ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsMemICompare(hConnect AS IntPtr, pucStr1 AS STRING , ulStr1Len AS DWORD , pucStr2 AS STRING , ulStr2Len AS DWORD , usCharSet AS WORD , psResult OUT SHORT ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsMemICompare90(hConnect AS IntPtr, pucStr1 AS STRING , ulStr1Len AS DWORD , pucStr2 AS STRING , ulStr2Len AS DWORD , usCharSet AS WORD , ulCollationID AS DWORD , psResult OUT SHORT ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsMemLwr(hConnect AS IntPtr, pucStr AS STRING , usStrLen AS WORD , usCharSet AS WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsMemLwr90(hConnect AS IntPtr, pucStr AS STRING , usStrLen AS WORD , usCharSet AS WORD , ulCollationID AS DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetIndexFlags(hIndex AS IntPtr, pulFlags OUT DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsConvertKeyToDouble(pucKey AS STRING , pdValue OUT System.Double ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetNumSegments(hTag AS IntPtr, usSegments OUT WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetSegmentFieldname(hTag AS IntPtr, usSegmentNum AS WORD , [InAttribute] [OutAttribute] pucFieldname AS CHAR[], pusFldnameLen REF WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetSegmentOffset(hTag AS IntPtr, usSegmentNum AS WORD , usOffset OUT WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsIsSegmentDescending(hTag AS IntPtr, usSegmentNum AS WORD , pbDescending OUT WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetSegmentFieldNumbers(hTag AS IntPtr, pusNumSegments OUT WORD , [InAttribute] [OutAttribute] pusSegFieldNumbers AS WORD[] )AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetFieldRaw(hObj AS IntPtr, pucFldName AS STRING , [InAttribute] [OutAttribute] pucBuf AS BYTE[] , ulLen AS DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD  AdsSetFieldRaw(hObj AS IntPtr, lFieldOrdinal AS DWORD , [InAttribute] [OutAttribute] pucBuf AS BYTE[] , ulLen AS DWORD ) AS DWORD
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetFieldRaw(hTbl AS IntPtr, pucFldName AS STRING , [InAttribute] [OutAttribute] pucBuf AS BYTE[] , pulLen REF DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetFieldRaw(hTbl AS IntPtr, lFieldOrdinal AS DWORD , [InAttribute] [OutAttribute] pucBuf AS BYTE[] , pulLen REF DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetFlushFlag(hConnect AS IntPtr, usFlushEveryUpdate AS WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetTimeStampRaw(hObj AS IntPtr, pucFldName AS STRING , pucBuf REF UINT64 , ulLen AS DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetTimeStampRaw(hObj AS IntPtr, lFieldOrdinal AS DWORD , pucBuf REF UINT64 , ulLen AS DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetInternalError(ulErrCode AS DWORD , pucFile AS STRING , ulLine AS DWORD ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsValidateThread() AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetLastError(ulErrCode AS DWORD , pucDetails AS STRING ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetTableCharType(hTbl AS IntPtr, usCharType AS WORD ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi,EntryPoint := "AdsConvertJulianToString")];
        PUBLIC STATIC EXTERN METHOD AdsConvertJulianToString(dJulian AS REAL8 , [InAttribute] [OutAttribute] pucJulian AS CHAR[] , pusLen REF WORD ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi,EntryPoint:="AdsConvertStringToJulian")];
        PUBLIC STATIC EXTERN METHOD AdsConvertStringToJulian(pucJulian AS STRING , usLen AS WORD , pdJulian OUT REAL8 ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi,EntryPoint:="AdsConvertStringToJulian")];
        PUBLIC STATIC EXTERN METHOD AdsConvertStringToJulian([InAttribute] [OutAttribute] pucJulian AS CHAR[] , usLen AS WORD , pdJulian OUT REAL8 ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsConvertMillisecondsToString(ulMSeconds AS DWORD , [InAttribute] [OutAttribute] pucTime AS CHAR[] , pusLen REF WORD ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsConvertStringToMilliseconds(pucTime AS STRING , usLen AS WORD , pulMSeconds OUT DWORD ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetCollationSequence(pucSequence AS STRING ) AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetBOFFlag(hTbl AS IntPtr, usBOF AS WORD )AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDBFDateToString(pucDBFDate AS STRING , pucFormattedDate AS STRING )AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsActivateAOF(hTable AS IntPtr )AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDeactivateAOF(hTable AS IntPtr )AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsExtractPathPart(usPart AS WORD , pucFile AS STRING , [InAttribute] [OutAttribute] pucPart AS CHAR[] , pusPartLen REF WORD )AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsExpressionLongToShort(hTable AS IntPtr, pucLongExpr AS STRING ,  [InAttribute] [OutAttribute] pucShortExpr AS CHAR[] , pusBufferLen REF WORD )AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsExpressionShortToLong(hTable AS IntPtr, pucShortExpr AS STRING ,  [InAttribute] [OutAttribute] pucLongExpr AS CHAR[] , pusBufferLen REF WORD )AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsExpressionLongToShort90(hTable AS IntPtr, pucLongExpr AS STRING ,  [InAttribute] [OutAttribute] pucShortExpr AS CHAR[] , pulBufferLen REF DWORD ) AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsExpressionShortToLong90(hTable AS IntPtr, pucShortExpr AS STRING ,  [InAttribute] [OutAttribute] pucLongExpr AS CHAR[] , pulBufferLen REF DWORD ) AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSqlPeekStatement(hCursor AS IntPtr, IsLive OUT BYTE ) AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetCursorAOF(hTable AS IntPtr, pucFilter AS STRING , usResolve AS WORD ) AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetCursorAOF(hCursor AS IntPtr,  [InAttribute] [OutAttribute] pucFilter AS CHAR[] , pusFilterLen REF WORD ) AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsClearCursorAOF(hTable AS IntPtr ) AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsInternalCloseCachedTables(hConnect AS IntPtr, usOpen AS WORD ) AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsClearRecordBuffer(hTbl AS IntPtr, pucBuf AS STRING , ulLen AS DWORD ) AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD ObsAdsEncryptBuffer(pucPassword AS STRING , pucBuffer AS STRING , usLen AS WORD ) AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD ObsAdsDecryptBuffer(pucPassword AS STRING , pucBuffer AS STRING , usLen AS WORD ) AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsEvalExpr(hTable AS IntPtr, pucPCode AS STRING,  [InAttribute] [OutAttribute] pucResult AS CHAR[] , pusLen REF WORD ) AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsFreeExpr(hTable AS IntPtr, pucPCode AS STRING) AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsIsIndexExprValid(hTbl AS IntPtr, pucExpr AS STRING , pbValid OUT WORD ) AS DWORD

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsStepIndexKey(hIndex AS IntPtr, pucKey AS STRING , usLen AS WORD,  sDirection AS SHORT ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsPrepareSQLNow(hStatement AS IntPtr, pucSQL AS STRING ,  [InAttribute] [OutAttribute] pucFieldInfo AS CHAR[] , pusFieldInfoLen REF WORD ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetPreparedFields(hStatement AS IntPtr,  [InAttribute] [OutAttribute] pucBuffer AS CHAR[] , pulBufferLen REF DWORD , ulOptions AS DWORD ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsEcho(hConnect AS IntPtr, pucData AS STRING , usLen AS WORD ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsReadRecords(hObj AS IntPtr, ulRecordNum AS DWORD , cDirection AS BYTE ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsReadRecordNumbers(hObj AS IntPtr, ulRecordNum AS DWORD , ucDirection AS BYTE , pulRecords OUT DWORD , pulArrayLen REF DWORD , pusHitEOF OUT WORD ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsMergeAOF(hTable AS IntPtr ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetupRI(hConnection AS IntPtr , lTableID AS INT , ucOpen AS BYTE , ulServerWAN AS DWORD ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsPerformRI(hTable AS IntPtr, ulRecNum AS DWORD , pucRecBuffer AS STRING ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsLockRecordImplicitly(hTbl AS IntPtr, ulRec AS DWORD ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetBaseFieldNum(hCursor AS IntPtr , pucColumnName AS STRING , pusBaseFieldNum OUT WORD ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetBaseFieldName(hTbl AS IntPtr, usFld AS WORD ,  [InAttribute] [OutAttribute] pucName AS CHAR[] , pusBufLen REF WORD ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDOpen( pucDictionaryPath AS STRING, pucPassword AS STRING , phDictionary OUT IntPtr ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDClose(hDictionary AS IntPtr ) AS DWORD 

        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsRefreshView(phCursor OUT IntPtr ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDExecuteProcedure(hDictionary AS IntPtr, pucProcName AS STRING , pucInput AS STRING , pucOutput AS STRING , pulRowsAffected OUT DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetPacketSize(hConnect AS IntPtr, usPacketLength AS WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsVerifyRI(hConnect AS IntPtr, usExclusive AS WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsAddToAOF(hTable AS IntPtr, pucFilter AS STRING , usOperation AS WORD , usWhichAOF AS WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDVerifyUserRights(hObject AS IntPtr , pucTableName AS STRING , pulUserRights OUT DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetIndexPageSize(hIndex AS IntPtr, pulPageSize OUT DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDAutoCreateTable(hConnect AS IntPtr, pucTableName AS STRING , pucCollation AS STRING ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDAutoCreateIndex(hConnect AS IntPtr, pucTableName AS STRING , pucIndexName AS STRING , pucCollation AS STRING ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetROWIDPrefix(hTable AS IntPtr, pucRowIDPrefix AS STRING , usBufferLen AS WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetColumnPermissions(hTable AS IntPtr, usColumnNum AS WORD , pucPermissions AS STRING ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetSQLStmtParams(pucStatement AS STRING ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsRemoveSQLComments(pucStatement AS STRING ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetBaseTableAccess(hTbl AS IntPtr, usAccessBase AS WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsCopyTableTop(hObj AS IntPtr, hDestTbl AS IntPtr , ulNumTopRecords AS DWORD) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetNullRecord(hTbl AS IntPtr, pucBuf AS STRING , ulLen AS DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetProperty(hObj AS IntPtr, ulOperation AS DWORD , ulValue AS DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsCloseCachedTrigStatements(hConnection AS IntPtr , lTableID AS INT ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDCreateASA(hConnect AS IntPtr, pucDictionaryPath AS STRING , usEncrypt AS WORD , pucDescription AS STRING , pucPassword AS STRING ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGotoBOF(hObj AS IntPtr ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsCreateMemTable(hConnection AS IntPtr , pucName AS STRING , usTableType AS WORD , usCharType AS WORD , pucFields AS STRING , ulSize AS DWORD , phTable OUT IntPtr ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsCreateMemTable90(hConnection AS IntPtr , pucName AS STRING , usTableType AS WORD , usCharType AS WORD , pucFields AS STRING , ulSize AS DWORD , pucCollation AS STRING , phTable OUT IntPtr ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetTableWAN(hTable AS IntPtr, pusWAN OUT WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsGetFTSScore(hIndex AS IntPtr, ulRecord AS DWORD , pucKey AS STRING , usKeyLen AS WORD , usDataType AS WORD , usSeekType AS WORD , pulScore OUT DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsConvertDateToJulian(hConnect AS IntPtr, pucDate AS STRING , usLen AS WORD , pdJulian OUT System.Double ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDSetActiveDictionary(hConnect AS IntPtr, pucLinkName AS STRING , phDictionary OUT IntPtr ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDCreateLinkPre71(hDBConn AS IntPtr , pucLinkAlias AS STRING , pucLinkedDDPath AS STRING , pucUserName AS STRING , pucPassword AS STRING , ulOptions AS DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDDropLinkPre71(hDBConn AS IntPtr , pucLinkedDD AS STRING , usDropGlobal AS WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDDisableTriggers(hDictionary AS IntPtr, pucObjectName AS STRING , pucParent AS STRING , ulOptions AS DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDEnableTriggers(hDictionary AS IntPtr, pucObjectName AS STRING , pucParent AS STRING , ulOptions AS DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsCreateCriticalSection(hObj AS IntPtr, ulOptions AS DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsWaitForObject(hObj AS IntPtr, ulOptions AS DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsReleaseObject(hObj AS IntPtr ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsBackupDatabase(hConnect AS IntPtr, hOutputTable AS IntPtr , pucSourcePath AS STRING , pucSourceMask AS STRING , pucDestPath AS STRING , pucOptions AS STRING , pucFreeTablePasswords AS STRING , usCharType AS WORD , usLockingMode AS WORD , usCheckRights AS WORD , usTableType AS WORD , pucCollation AS STRING , ucDDConn AS BYTE ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsRestoreDatabase(hConnect AS IntPtr, hOutputTable AS IntPtr , pucSourcePath AS STRING , pucSourcePassword AS STRING , pucDestPath AS STRING , pucDestPassword AS STRING , pucOptions AS STRING , pucFreeTablePasswords AS STRING , usCharType AS WORD , usLockingMode AS WORD , usCheckRights AS WORD , usTableType AS WORD , pucCollation AS STRING , ucDDConn AS BYTE ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsSetRecordPartial(hObj AS IntPtr, pucRec AS STRING , ulLen AS DWORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDSetTriggerProperty(hDictionary AS IntPtr,  pucTriggerName AS STRING, usPropertyID AS WORD , pucProperty AS STRING , usPropertyLen AS WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDCreateFunction(hDictionary AS IntPtr, pucName AS STRING , pucReturnType AS STRING , usInputParamCnt AS WORD , pucInputParams AS STRING , pucFuncBody AS STRING , pucComments AS STRING ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDDropFunction(hDictionary AS IntPtr, pucName AS STRING ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDGetObjectProperty(hDictionary AS IntPtr, usObjectType AS WORD , pucParent AS STRING , pucName AS STRING , usPropertyID AS WORD ,  [InAttribute] [OutAttribute] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDGetObjectProperty(hDictionary AS IntPtr, usObjectType AS WORD , pucParent AS STRING , pucName AS STRING , usPropertyID AS WORD ,  [InAttribute] [OutAttribute] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDGetObjectProperty(hDictionary AS IntPtr, usObjectType AS WORD , pucParent AS STRING , pucName AS STRING , usPropertyID AS WORD , pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDSetObjectProperty(hDictionary AS IntPtr, usObjectType AS WORD , pucParent AS STRING , pucName AS STRING , usPropertyID AS WORD ,  [InAttribute] [OutAttribute] pvProperty AS BYTE[] , usPropertyLen AS WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDSetObjectProperty(hDictionary AS IntPtr, usObjectType AS WORD , pucParent AS STRING , pucName AS STRING , usPropertyID AS WORD ,  [InAttribute] [OutAttribute] pucProperty AS CHAR[] , usPropertyLen AS WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDSetObjectProperty(hDictionary AS IntPtr, usObjectType AS WORD , pucParent AS STRING , pucName AS STRING , usPropertyID AS WORD , pusProperty REF WORD , usPropertyLen AS WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDCreatePackage(hDictionary AS IntPtr, pucName AS STRING , pucComments AS STRING ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsDDDropPackage(hDictionary AS IntPtr, pucName AS STRING ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsCopyTableStructure81(hTable AS IntPtr, pucFile AS STRING , ulOptions AS DWORD ) AS DWORD
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsAccessVfpSystemField(hTable AS IntPtr, pucFldName AS STRING , pucBuffer AS STRING , ulOptions AS DWORD , puFlag OUT WORD ) AS DWORD 
        
        [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
        PUBLIC STATIC EXTERN METHOD AdsAccessVfpSystemField(hTable AS IntPtr, lFieldOrdinal AS DWORD , pucBuffer AS STRING , ulOptions AS DWORD , puFlag OUT WORD ) AS DWORD 
        
    END CLASS
END NAMESPACE
