//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//

USING System
USING System.Runtime.InteropServices
USING System.Text
BEGIN NAMESPACE XSharp.ADS
    PUBLIC STATIC CLASS ACE32
    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsAddCustomKey(hIndex AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsAppendRecord(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsApplicationExit() AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsAtBOF(hTable AS IntPtr , pbBof OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsAtEOF(hTable AS IntPtr , pbEof OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsBeginTransaction(hConnect AS IntPtr) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsBinaryToFile(hTable AS IntPtr , pucFldName AS STRING , pucFileName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsBinaryToFile(hTable AS IntPtr , lFieldOrdinal AS DWORD, pucFileName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCacheOpenCursors(usOpen AS WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCacheOpenTables(usOpen AS WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCacheRecords(hTable AS IntPtr , usNumRecords AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCancelUpdate(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCancelUpdate90(hTable AS IntPtr , ulOptions AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCheckExistence(hConnect AS IntPtr, pucFileName AS STRING , pusOnDisk OUT WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsClearAllScopes(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsClearDefault() AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsClearFilter(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsClearRelation(hTableParent AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsClearScope(hIndex AS IntPtr , usScopeOption AS WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCloneTable(hTable AS IntPtr , phClone OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCloseAllIndexes(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCloseAllTables() AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCloseIndex(hIndex AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCloseTable(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCloseCachedTables(hConnection AS IntPtr) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCommitTransaction(hConnect AS IntPtr) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsConnect(pucServerName AS STRING , phConnect OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsConnect26(pucServerName AS STRING , usServerTypes AS WORD, phConnect OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsConnect60(pucServerPath AS STRING , usServerTypes AS WORD, pucUserName AS STRING , pucPassword AS STRING , ulOptions AS DWORD, phConnect OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsConnectionAlive(hConnect AS IntPtr, pbConnectionIsAlive OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsContinue(hTable AS IntPtr , pbFound OUT WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsConvertTable(hObj AS IntPtr ,  usFilterOption AS WORD, pucFile AS STRING , usTableType AS WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCopyTable(hObj AS IntPtr , usFilterOption AS WORD , pucFile AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCopyTableContents(hObjFrom AS IntPtr , hTableTo AS IntPtr , usFilterOption AS WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCopyTableStructure(hTable AS IntPtr , pucFile AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCreateIndex(hObj AS IntPtr , pucFileName AS STRING , pucTag AS STRING , pucExpr AS STRING , pucCondition AS STRING , pucWhile AS STRING , ulOptions AS DWORD, phIndex OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCreateIndex61(hObj AS IntPtr , pucFileName AS STRING , pucTag AS STRING , pucExpr AS STRING , pucCondition AS STRING , pucWhile AS STRING , ulOptions AS DWORD, ulPageSize AS DWORD , phIndex OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCreateIndex90(hObj AS IntPtr , pucFileName AS STRING , pucTag AS STRING , pucExpr AS STRING , pucCondition AS STRING , pucWhile AS STRING , ulOptions AS DWORD, ulPageSize AS DWORD , pucCollation AS STRING , phIndex OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCreateFTSIndex(hTable AS IntPtr , pucFileName AS STRING , pucTag AS STRING , pucField AS STRING , ulPageSize AS DWORD , ulMinWordLen AS DWORD , ulMaxWordLen AS DWORD , usUseDefaultDelim AS WORD , pucDelimiters AS STRING , usUseDefaultNoise AS WORD , pucNoiseWords AS STRING , usUseDefaultDrop AS WORD , pucDropChars AS STRING , usUseDefaultConditionals AS WORD , pucConditionalChars AS STRING , pucReserved1 AS STRING , pucReserved2 AS STRING , ulOptions AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCreateTable(hConnect AS IntPtr, pucName AS STRING , pucAlias AS STRING , usTableType AS WORD, usCharType AS WORD , usLockType AS WORD , usCheckRights AS WORD , usMemoSize AS WORD , pucFields AS STRING , phTable OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCreateTable71(hConnect AS IntPtr, pucName AS STRING , pucDBObjName AS STRING , usTableType AS WORD, usCharType AS WORD , usLockType AS WORD , usCheckRights AS WORD , usMemoSize AS WORD , pucFields AS STRING , ulOptions AS DWORD, phTable OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCreateTable90(hConnect AS IntPtr, pucName AS STRING , pucDBObjName AS STRING , usTableType AS WORD, usCharType AS WORD , usLockType AS WORD , usCheckRights AS WORD , usMemoSize AS WORD , pucFields AS STRING , ulOptions AS DWORD, pucCollation AS STRING , phTable OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDCreate(pucDictionaryPath AS STRING , usEncrypt AS WORD, pucDescription AS STRING , phDictionary OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDCreateRefIntegrity(hDictionary AS IntPtr , pucRIName AS STRING , pucFailTable AS STRING , pucParentTableName AS STRING , pucParentTagName AS STRING , pucChildTableName AS STRING , pucChildTagName AS STRING , usUpdateRule AS WORD , usDeleteRule AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDCreateRefIntegrity62(hDictionary AS IntPtr , pucRIName AS STRING , pucFailTable AS STRING , pucParentTableName AS STRING , pucParentTagName AS STRING , pucChildTableName AS STRING , pucChildTagName AS STRING , usUpdateRule AS WORD , usDeleteRule AS WORD , pucNoPrimaryError AS STRING , pucCascadeError AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDRemoveRefIntegrity(hDictionary AS IntPtr , pucRIName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetDatabaseProperty(hObject AS IntPtr, usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetDatabaseProperty(hObject AS IntPtr, usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetDatabaseProperty(hObject AS IntPtr, usPropertyID AS WORD, pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetFieldProperty(hObject AS IntPtr, pucTableName AS STRING , pucFieldName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetFieldProperty(hObject AS IntPtr, pucTableName AS STRING , pucFieldName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetFieldProperty(hObject AS IntPtr, pucTableName AS STRING , pucFieldName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD

        /*
        UNSIGNED32 AdsGetFTSIndexInfo
        (
        ADSHANDLE hIndex,
        UNSIGNED8 *pucOutput,
        UNSIGNED32 *pulBufLen,
        UNSIGNED8 **ppucField,
        UNSIGNED32 *pulMinWordLen,
        UNSIGNED32 *pulMaxWordLen,
        UNSIGNED8 **ppucDelimiters,
        UNSIGNED8 **ppucNoiseWords,
        UNSIGNED8 **ppucDropChars,
        UNSIGNED8 **ppucConditionalChars,
        UNSIGNED8 **ppucReserved1,
        UNSIGNED8 **ppucReserved2,
        UNSIGNED32 *pulOptions
        */
    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetFTSIndexInfo(hIndex as IntPtr, [@@In] [@@Out] pucOutput AS BYTE[], pulBufLen REF DWORD, ppucField OUT BYTE PTR,pulMinWordLen OUT DWORD , pulMaxWordLen OUT DWORD, ;
            [@@Out] ppucDelimiters OUT BYTE PTR, [@@Out] ppucNoiseWords OUT BYTE PTR, [@@Out] ppucDropChars OUT BYTE PTR, [@@Out] ppucConditionalChars OUT BYTE PTR, [@@Out] ppucReserved1 AS BYTE[], [@@Out] ppucReserved2 AS BYTE[], pulOptions OUT DWORD)  AS DWORD


    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetIndexFileProperty(hObject AS IntPtr, pucTableName AS STRING , pucIndexFileName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetIndexFileProperty(hObject AS IntPtr, pucTableName AS STRING , pucIndexFileName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetIndexFileProperty(hObject AS IntPtr, pucTableName AS STRING , pucIndexFileName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetIndexProperty(hObject AS IntPtr, pucTableName AS STRING , pucIndexName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetIndexProperty(hObject AS IntPtr, pucTableName AS STRING , pucIndexName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetIndexProperty(hObject AS IntPtr, pucTableName AS STRING , pucIndexName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetLinkProperty(hConnect AS IntPtr, pucLinkName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetLinkProperty(hConnect AS IntPtr, pucLinkName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetLinkProperty(hConnect AS IntPtr, pucLinkName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetTableProperty(hObject AS IntPtr, pucTableName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetTableProperty(hObject AS IntPtr, pucTableName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetTableProperty(hObject AS IntPtr, pucTableName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetUserGroupProperty(hObject AS IntPtr, pucUserGroupName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetUserGroupProperty(hObject AS IntPtr, pucUserGroupName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetUserGroupProperty(hObject AS IntPtr, pucUserGroupName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetUserProperty(hObject AS IntPtr, pucUserName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetUserProperty(hObject AS IntPtr, pucUserName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetUserProperty(hObject AS IntPtr, pucUserName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetViewProperty(hObject AS IntPtr, pucViewName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetViewProperty(hObject AS IntPtr, pucViewName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetViewProperty(hObject AS IntPtr, pucViewName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetTriggerProperty(hObject AS IntPtr, pucTriggerName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetTriggerProperty(hObject AS IntPtr, pucTriggerName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetTriggerProperty(hObject AS IntPtr, pucTriggerName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetProcedureProperty(hObject AS IntPtr, pucProcName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetProcedureProperty(hObject AS IntPtr, pucProcName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetProcedureProperty(hObject AS IntPtr, pucProcName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetRefIntegrityProperty(hObject AS IntPtr, pucRIName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetPermissions(hDBConn AS IntPtr , pucGrantee AS STRING , usObjectType AS WORD, pucObjectName AS STRING , pucParentName AS STRING , usGetInherited AS WORD , pulPermissions OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGrantPermission(hAdminConn AS IntPtr , usObjectType AS WORD, pucObjectName AS STRING , pucParentName AS STRING , pucGrantee AS STRING , ulPermissions AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDRevokePermission(hAdminConn AS IntPtr , usObjectType AS WORD, pucObjectName AS STRING , pucParentName AS STRING , pucGrantee AS STRING , ulPermissions AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetDatabaseProperty(hDictionary AS IntPtr , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetDatabaseProperty(hDictionary AS IntPtr , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetDatabaseProperty(hDictionary AS IntPtr , usPropertyID AS WORD, pusProperty REF WORD , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetFieldProperty(hDictionary AS IntPtr , pucTableName AS STRING , pucFieldName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , usPropertyLen AS WORD , usValidateOption AS WORD , pucFailTable AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetFieldProperty(hDictionary AS IntPtr , pucTableName AS STRING , pucFieldName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , usPropertyLen AS WORD , usValidateOption AS WORD , pucFailTable AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetFieldProperty(hDictionary AS IntPtr , pucTableName AS STRING , pucFieldName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , usPropertyLen AS WORD , usValidateOption AS WORD , pucFailTable AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetProcedureProperty(hDictionary AS IntPtr , pucProcedureName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetProcedureProperty(hDictionary AS IntPtr , pucProcedureName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetProcedureProperty(hDictionary AS IntPtr , pucProcedureName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetTableProperty(hDictionary AS IntPtr , pucTableName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , usPropertyLen AS WORD , usValidateOption AS WORD , pucFailTable AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetTableProperty(hDictionary AS IntPtr , pucTableName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , usPropertyLen AS WORD , usValidateOption AS WORD , pucFailTable AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetTableProperty(hDictionary AS IntPtr , pucTableName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , usPropertyLen AS WORD , usValidateOption AS WORD , pucFailTable AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetUserGroupProperty(hDictionary AS IntPtr , pucUserGroupName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetUserGroupProperty(hDictionary AS IntPtr , pucUserGroupName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetUserGroupProperty(hDictionary AS IntPtr , pucUserGroupName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetUserProperty(hDictionary AS IntPtr , pucUserName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetUserProperty(hDictionary AS IntPtr , pucUserName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetUserProperty(hDictionary AS IntPtr , pucUserName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetViewProperty(hDictionary AS IntPtr , pucViewName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetViewProperty(hDictionary AS IntPtr , pucViewName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetViewProperty(hDictionary AS IntPtr , pucViewName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetObjectAccessRights(hDictionary AS IntPtr , pucObjectName AS STRING , pucAccessorName AS STRING , pucAllowedAccess AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDAddProcedure(hDictionary AS IntPtr , pucName AS STRING , pucContainer AS STRING , pucProcName AS STRING , ulInvokeOption AS DWORD , pucInParams AS STRING , pucOutParams AS STRING , pucComments AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDAddTable(hDictionary AS IntPtr , pucTableName AS STRING , pucTablePath AS STRING , usTableType AS WORD, usCharType AS WORD , pucIndexFiles AS STRING , pucComments AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDAddTable90(hDictionary AS IntPtr , pucTableName AS STRING , pucTablePath AS STRING , usTableType AS WORD, usCharType AS WORD , pucIndexFiles AS STRING , pucComments AS STRING , pucCollation AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDAddView(hDictionary AS IntPtr , pucName AS STRING , pucComments AS STRING , pucSQL AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDCreateTrigger(hDictionary AS IntPtr , pucName AS STRING , pucTableName AS STRING ,  ulTriggerType AS DWORD, ulEventTypes AS DWORD , ulContainerType AS DWORD , pucContainer AS STRING , pucFunctionName AS STRING , ulPriority AS DWORD , pucComments AS STRING , ulOptions AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDRemoveTrigger(hDictionary AS IntPtr , pucName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDAddIndexFile(hDictionary AS IntPtr , pucTableName AS STRING , pucIndexFilePath AS STRING , pucComment AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDCreateUser(hDictionary AS IntPtr , pucGroupName AS STRING , pucUserName AS STRING , pucPassword AS STRING , pucDescription AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDAddUserToGroup(hDictionary AS IntPtr , pucGroupName AS STRING , pucUserName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDRemoveUserFromGroup(hDictionary AS IntPtr , pucGroupName AS STRING , pucUserName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDDeleteUser(hDictionary AS IntPtr , pucUserName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDCreateUserGroup(hDictionary AS IntPtr , pucGroupName AS STRING , pucDescription AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDDeleteUserGroup(hDictionary AS IntPtr , pucGroupName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDDeleteIndex(hDictionary AS IntPtr , pucTableName AS STRING , pucIndexName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDRemoveIndexFile(hDictionary AS IntPtr , pucTableName AS STRING , pucIndexFileName AS STRING , usDeleteFile AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDRemoveProcedure(hDictionary AS IntPtr , pucName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDRemoveTable(hObject AS IntPtr, pucTableName AS STRING , usDeleteFiles AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDRemoveView(hDictionary AS IntPtr , pucName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDRenameObject(hDictionary AS IntPtr , pucObjectName AS STRING , pucNewObjectName AS STRING , usObjectType AS WORD, ulOptions AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDMoveObjectFile(hDictionary AS IntPtr , usObjectType AS WORD, pucObjectName AS STRING , pucNewPath AS STRING , pucIndexFiles AS STRING , pucParent AS STRING , ulOptions AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDFindFirstObject(hObject AS IntPtr, usFindObjectType AS WORD , pucParentName AS STRING , [@@In] [@@Out] pucObjectName AS CHAR[] , pusObjectNameLen REF WORD , phFindHandle OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDFindNextObject(hObject AS IntPtr, hFindHandle AS IntPtr , [@@In] [@@Out] pucObjectName AS CHAR[] , pusObjectNameLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDFindClose(hObject AS IntPtr, hFindHandle AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDCreateLink(hDBConn AS IntPtr , pucLinkAlias AS STRING , pucLinkedDDPath AS STRING , pucUserName AS STRING , pucPassword AS STRING , ulOptions AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDModifyLink(hDBConn AS IntPtr , pucLinkAlias AS STRING , pucLinkedDDPath AS STRING , pucUserName AS STRING , pucPassword AS STRING , ulOptions AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDDropLink(hDBConn AS IntPtr , pucLinkedDD AS STRING , usDropGlobal AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDCreatePublication(hDictionary AS IntPtr , pucPublicationName AS STRING , pucComments AS STRING , ulOptions AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetPublicationProperty(hObject AS IntPtr, pucPublicationName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetPublicationProperty(hObject AS IntPtr, pucPublicationName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetPublicationProperty(hObject AS IntPtr, pucPublicationName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetPublicationProperty(hDictionary AS IntPtr , pucPublicationName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetPublicationProperty(hDictionary AS IntPtr , pucPublicationName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetPublicationProperty(hDictionary AS IntPtr , pucPublicationName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDDeletePublication(hDictionary AS IntPtr , pucPublicationName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDCreateArticle(hDictionary AS IntPtr , pucPublicationName AS STRING , pucObjectName AS STRING , pucRowIdentColumns AS STRING , pucFilter AS STRING , ulOptions AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetArticleProperty(hObject AS IntPtr, pucPublicationName AS STRING , pucObjectName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetArticleProperty(hObject AS IntPtr, pucPublicationName AS STRING , pucObjectName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetArticleProperty(hObject AS IntPtr, pucPublicationName AS STRING , pucObjectName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetArticleProperty(hDictionary AS IntPtr , pucPublicationName AS STRING , pucObjectName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetArticleProperty(hDictionary AS IntPtr , pucPublicationName AS STRING , pucObjectName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetArticleProperty(hDictionary AS IntPtr , pucPublicationName AS STRING , pucObjectName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDDeleteArticle(hDictionary AS IntPtr , pucPublicationName AS STRING , pucObjectName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDCreateSubscription(hDictionary AS IntPtr , pucSubscriptionName AS STRING , pucPublicationName AS STRING , pucTarget AS STRING , pucUser AS STRING , pucPassword AS STRING , pucReplicationQueue AS STRING , usForward AS WORD , pucComments AS STRING , ulOptions AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetSubscriptionProperty(hObject AS IntPtr, pucSubscriptionName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetSubscriptionProperty(hObject AS IntPtr, pucSubscriptionName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDGetSubscriptionProperty(hObject AS IntPtr, pucSubscriptionName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , pusPropertyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetSubscriptionProperty(hDictionary AS IntPtr , pucSubscriptionName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetSubscriptionProperty(hDictionary AS IntPtr , pucSubscriptionName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetSubscriptionProperty(hDictionary AS IntPtr , pucSubscriptionName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDDeleteSubscription(hDictionary AS IntPtr , pucSubscriptionName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDecryptRecord(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDecryptTable(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDeleteCustomKey(hIndex AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDeleteIndex(hIndex AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDeleteRecord(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetKeyColumn(hCursor AS IntPtr , [@@In] [@@Out] pucKeyColumn AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDisableEncryption(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDisableLocalConnections() AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDisconnect(hConnect AS IntPtr) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsEnableEncryption(hTable AS IntPtr , pucPassword AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsEncryptRecord(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsEncryptTable(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsEvalLogicalExpr(hTable AS IntPtr , pucExpr AS STRING , pbResult OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsEvalNumericExpr(hTable AS IntPtr , pucExpr AS STRING , pdResult OUT System.Double ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsEvalStringExpr(hTable AS IntPtr , pucExpr AS STRING , [@@In] [@@Out] pucResult AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsEvalTestExpr(hTable AS IntPtr , pucExpr AS STRING , pusType OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsExtractKey(hIndex AS IntPtr , [@@In] [@@Out] pucKey AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsFailedTransactionRecovery(pucServer AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsFileToBinary(hTable AS IntPtr , pucFldName AS STRING , usBinaryType AS WORD , pucFileName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsFileToBinary(hTable AS IntPtr , lFieldOrdinal AS DWORD, usBinaryType AS WORD , pucFileName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsFindConnection(pucServerName AS STRING , phConnect OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsFindConnection25(pucFullPath AS STRING , phConnect OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsFindClose(hConnect AS IntPtr, lHandle AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsFindFirstTable(hConnect AS IntPtr, pucFileMask AS STRING , [@@In] [@@Out] pucFirstFile AS CHAR[] , pusFileLen REF WORD , plHandle OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsFindNextTable(hConnect AS IntPtr, lHandle AS IntPtr , [@@In] [@@Out] pucFileName AS CHAR[] , pusFileLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsFindFirstTable62(hConnect AS IntPtr, pucFileMask AS STRING , [@@In] [@@Out] pucFirstDD AS CHAR[] , pusDDLen REF WORD , [@@In] [@@Out] pucFirstFile AS CHAR[] , pusFileLen REF WORD , plHandle OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsFindNextTable62(hConnect AS IntPtr, lHandle AS IntPtr , [@@In] [@@Out] pucDDName AS CHAR[] , pusDDLen REF WORD , [@@In] [@@Out] pucFileName AS CHAR[] , pusFileLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetAllIndexes(hTable AS IntPtr , [@@In] [@@Out] ahIndex AS IntPtr[] , pusArrayLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetFTSIndexes(hTable AS IntPtr , [@@In] [@@Out] ahIndex AS IntPtr[] , pusArrayLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetAllLocks(hTable AS IntPtr , [@@In] [@@Out] aulLocks AS DWORD[] , pusArrayLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetAllTables([@@In] [@@Out] ahTable AS IntPtr[] , pusArrayLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetBinary(hTable AS IntPtr , pucFldName AS STRING , ulOffset AS DWORD , [@@In] [@@Out] pucBuf AS BYTE[] , pulLen REF DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetBinary(hTable AS IntPtr , lFieldOrdinal AS DWORD, ulOffset AS DWORD , [@@In] [@@Out] pucBuf AS BYTE[] , pulLen REF DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetBinaryLength(hTable AS IntPtr , pucFldName AS STRING , pulLength OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetBinaryLength(hTable AS IntPtr , lFieldOrdinal AS DWORD, pulLength OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetBookmark(hTable AS IntPtr , phBookmark OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetBookmark60(hObj AS IntPtr , [@@In] [@@Out] pucBookmark AS CHAR[] , pulLength REF DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetBookmarkLength(hObj AS IntPtr , pulLength REF DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCompareBookmarks(pucBookmark1 AS STRING , pucBookmark2 AS STRING , plResult OUT INT ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetCollationLang([@@In] [@@Out] pucLang AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetCollation(hConnect AS IntPtr, [@@In] [@@Out] pucCollation AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetConnectionType(hConnect AS IntPtr, pusConnectType OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetConnectionPath(hConnect AS IntPtr, [@@In] [@@Out] pucConnectionPath AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetConnectionProperty(hConnect AS IntPtr, usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , pulPropertyLen REF DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetDate(hTable AS IntPtr , pucFldName AS STRING , [@@In] [@@Out] pucBuf AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetDate(hTable AS IntPtr , lFieldOrdinal AS DWORD, [@@In] [@@Out] pucBuf AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetDateFormat([@@In] [@@Out] pucFormat AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetDateFormat60(hConnect AS IntPtr, [@@In] [@@Out] pucFormat AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetDecimals(pusDecimals OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetDefault([@@In] [@@Out] pucDefault AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetDeleted(pbUseDeleted OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetDouble(hTable AS IntPtr , pucFldName AS STRING , pdValue OUT System.Double ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetDouble(hTable AS IntPtr , lFieldOrdinal AS DWORD, pdValue OUT System.Double ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetEpoch(pusCentury OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetErrorString(ulErrCode AS DWORD , [@@In] [@@Out] pucBuf AS CHAR[] , pusBufLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetExact(pbExact OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetExact22(hObj AS IntPtr , pbExact OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetField(hTable AS IntPtr , pucFldName AS STRING , [@@In] [@@Out] pucBuf AS CHAR[] , pulLen REF DWORD , usOption AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetField(hTable AS IntPtr , lFieldOrdinal AS DWORD, [@@In] [@@Out] pucBuf AS CHAR[] , pulLen REF DWORD , usOption AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetField(hTable AS IntPtr , pucFldName AS STRING , [@@In] [@@Out] abBuf AS BYTE[] , pulLen REF DWORD , usOption AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetField(hTable AS IntPtr , lFieldOrdinal AS DWORD, [@@In] [@@Out] abBuf AS BYTE[] , pulLen REF DWORD , usOption AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetFieldDecimals(hTable AS IntPtr , pucFldName AS STRING , pusDecimals OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetFieldDecimals(hTable AS IntPtr , lFieldOrdinal AS DWORD, pusDecimals OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetFieldLength(hTable AS IntPtr , pucFldName AS STRING , pulLength OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetFieldLength(hTable AS IntPtr , lFieldOrdinal AS DWORD, pulLength OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetFieldName(hTable AS IntPtr , usFld AS WORD , [@@In] [@@Out] pucName AS CHAR[] , pusBufLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetFieldNum(hTable AS IntPtr , pucFldName AS STRING , pusNum OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetFieldNum(hTable AS IntPtr , lFieldOrdinal AS DWORD, pusNum OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetFieldOffset(hTable AS IntPtr , pucFldName AS STRING , pulOffset OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetFieldOffset(hTable AS IntPtr , lFieldOrdinal AS DWORD, pulOffset OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetFieldType(hTable AS IntPtr , pucFldName AS STRING , pusType OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetFieldType(hTable AS IntPtr , lFieldOrdinal AS DWORD, pusType OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetFilter(hTable AS IntPtr , [@@In] [@@Out] pucFilter AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetHandleINT64(hObj AS IntPtr , pulVal OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetHandleType(hObj AS IntPtr , pusType OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetIndexCondition(hIndex AS IntPtr , [@@In] [@@Out] pucExpr AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetIndexExpr(hIndex AS IntPtr , [@@In] [@@Out] pucExpr AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetIndexFilename(hIndex AS IntPtr , usOption AS WORD , [@@In] [@@Out] pucName AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetIndexHandle(hTable AS IntPtr , pucIndexOrder AS STRING , phIndex OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetIndexHandleByOrder(hTable AS IntPtr , usOrderNum AS WORD , phIndex OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetIndexHandleByExpr(hTable AS IntPtr , pucExpr AS STRING , ulDescending AS DWORD , phIndex OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetIndexName(hIndex AS IntPtr , [@@In] [@@Out] pucName AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetIndexOrderByHandle(hIndex AS IntPtr , pusIndexOrder OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetJulian(hTable AS IntPtr , pucFldName AS STRING , plDate OUT INT ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetJulian(hTable AS IntPtr , lFieldOrdinal AS DWORD, plDate OUT INT ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetKeyCount(hIndex AS IntPtr , usFilterOption AS WORD, pulCount OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetKeyNum(hIndex AS IntPtr , usFilterOption AS WORD, pulKey OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetKeyLength(hIndex AS IntPtr , pusKeyLength OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetKeyType(hIndex AS IntPtr , usKeyType OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetLastError(pulErrCode OUT DWORD , [@@In] [@@Out] pucBuf AS CHAR[] , pusBufLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetLastTableUpdate(hTable AS IntPtr , [@@In] [@@Out] pucDate AS CHAR[] , pusDateLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetLogical(hTable AS IntPtr , pucFldName AS STRING , pbValue OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetLogical(hTable AS IntPtr , lFieldOrdinal AS DWORD, pbValue OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetLong(hTable AS IntPtr , pucFldName AS STRING , plValue OUT LONG ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetLong(hTable AS IntPtr , lFieldOrdinal AS DWORD, plValue OUT LONG ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetLongLong(hTable AS IntPtr , pucFldName AS STRING , pqValue OUT INT64 ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetLongLong(hTable AS IntPtr , lFieldOrdinal AS DWORD, pqValue OUT INT64 ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetMemoBlockSize(hTable AS IntPtr , pusBlockSize OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetMemoLength(hTable AS IntPtr , pucFldName AS STRING , pulLength OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetMemoLength(hTable AS IntPtr , lFieldOrdinal AS DWORD, pulLength OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetMemoDataType(hTable AS IntPtr , pucFldName AS STRING , pusType OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetMemoDataType(hTable AS IntPtr , lFieldOrdinal AS DWORD, pusType OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetMilliseconds(hTable AS IntPtr , pucFldName AS STRING , plTime OUT INT ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetMilliseconds(hTable AS IntPtr , lFieldOrdinal AS DWORD, plTime OUT INT ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetMoney(hTbl AS IntPtr , pucFldName AS STRING , pqValue OUT INT64 ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetMoney(hTbl AS IntPtr , lFieldOrdinal AS DWORD, pqValue OUT INT64 ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetActiveLinkInfo(hDBConn AS IntPtr , usLinkNum AS WORD , [@@In] [@@Out] pucLinkInfo AS CHAR[] , pusBufferLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetNumActiveLinks(hDBConn AS IntPtr , pusNumLinks OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetNumFields(hTable AS IntPtr , pusCount OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetNumIndexes(hTable AS IntPtr , pusNum OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetNumFTSIndexes(hTable AS IntPtr , pusNum OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetNumLocks(hTable AS IntPtr , pusNum OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetNumOpenTables(pusNum OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetRecord(hTable AS IntPtr , [@@In] [@@Out] pucRec AS BYTE[] , pulLen REF DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetRecordCount(hTable AS IntPtr , usFilterOption AS WORD, pulCount OUT DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetRecordNum(hTable AS IntPtr , usFilterOption AS WORD, pulRec OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetRecordLength(hTable AS IntPtr , pulLength OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetRecordCRC(hTable AS IntPtr , pulCRC OUT DWORD , ulOptions AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetRelKeyPos(hIndex AS IntPtr , pdPos OUT System.Double ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetScope(hIndex AS IntPtr , usScopeOption AS WORD, [@@In] [@@Out] pucScope AS CHAR[] , pusBufLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetSearchPath([@@In] [@@Out] pucPath AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetServerName(hConnect AS IntPtr, [@@In] [@@Out] pucName AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetServerTime(hConnect AS IntPtr,  [@@In] [@@Out] pucDateBuf AS CHAR[], pusDateBufLen REF WORD , plTime OUT INT , [@@In] [@@Out] pucTimeBuf AS CHAR[] , pusTimeBufLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetShort(hTable AS IntPtr , pucFldName AS STRING , psValue OUT SHORT ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetShort(hTable AS IntPtr , lFieldOrdinal AS DWORD, psValue OUT SHORT ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetString(hTable AS IntPtr , pucFldName AS STRING , [@@In] [@@Out] pucBuf AS CHAR[] , pulLen REF DWORD , usOption AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetString(hTable AS IntPtr , lFieldOrdinal AS DWORD, [@@In] [@@Out] pucBuf AS CHAR[] , pulLen REF DWORD , usOption AS WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Unicode)];
    PUBLIC STATIC EXTERN METHOD AdsGetStringW(hTable AS IntPtr , [MarshalAs(UnmanagedType.LPStr)] pucFldName AS STRING , [@@In] [@@Out] pucBuf AS CHAR[] , pulLen REF DWORD , usOption AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Unicode)];
    PUBLIC STATIC EXTERN METHOD AdsGetStringW(hTable AS IntPtr , lFieldOrdinal AS DWORD, [@@In] [@@Out] pucBuf AS CHAR[] , pulLen REF DWORD , usOption AS WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetTableAlias(hTable AS IntPtr , [@@In] [@@Out] pucAlias AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetTableCharType(hTable AS IntPtr , pusCharType OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetTableConnection(hTable AS IntPtr , phConnect OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetTableFilename(hTable AS IntPtr , usOption AS WORD , [@@In] [@@Out] pucName AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetTableHandle(pucName AS STRING , phTable OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetTableHandle25(hConnect AS IntPtr, pucName AS STRING , phTable OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetTableLockType(hTable AS IntPtr , pusLockType OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetTableMemoSize(hTable AS IntPtr , pusMemoSize OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetTableOpenOptions(hTable AS IntPtr , pulOptions OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetTableRights(hTable AS IntPtr , pusRights OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetTableType(hTable AS IntPtr , pusType OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetTime(hTable AS IntPtr , pucFldName AS STRING , [@@In] [@@Out] pucBuf AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetTime(hTable AS IntPtr , lFieldOrdinal AS DWORD, [@@In] [@@Out] pucBuf AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetVersion(pulMajor OUT DWORD , pulMinor OUT DWORD , pucLetter AS STRING , [@@In] [@@Out] pucDesc AS CHAR[] , pusDescLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGotoBookmark(hTable AS IntPtr , hBookmark AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGotoBookmark60(hObj AS IntPtr , pucBookmark AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGotoBottom(hObj AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGotoRecord(hTable AS IntPtr , ulRec AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGotoTop(hObj AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsImageToClipboard(hTable AS IntPtr , pucFldName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsInTransaction(hConnect AS IntPtr, pbInTrans OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsEmpty(hTable AS IntPtr , pucFldName AS STRING , pbEmpty OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsEmpty(hTable AS IntPtr , lFieldOrdinal AS DWORD, pbEmpty OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsExprValid(hTable AS IntPtr , pucExpr AS STRING , pbValid OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsFound(hObj AS IntPtr , pbFound OUT WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsIndexCompound(hIndex AS IntPtr , pbCompound OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsIndexCandidate(hIndex AS IntPtr , pbCandidate OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsIndexNullable(hIndex AS IntPtr , pbNullable OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsIndexCustom(hIndex AS IntPtr , pbCustom OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsIndexDescending(hIndex AS IntPtr , pbDescending OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsIndexPrimaryKey(hIndex AS IntPtr , pbPrimaryKey OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsIndexFTS(hIndex AS IntPtr , pbFTS OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsIndexUnique(hIndex AS IntPtr , pbUnique OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsRecordDeleted(hTable AS IntPtr , pbDeleted OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsRecordEncrypted(hTable AS IntPtr , pbEncrypted OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsRecordLocked(hTable AS IntPtr , ulRec AS DWORD , pbLocked OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsRecordVisible(hObj AS IntPtr , pbVisible OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsServerLoaded(pucServer AS STRING , pbLoaded OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsTableEncrypted(hTable AS IntPtr , pbEncrypted OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsTableLocked(hTable AS IntPtr , pbLocked OUT WORD ) AS DWORD


    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsTableTransactionFree(hTable AS IntPtr , pusTransFree OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsLocate(hTable AS IntPtr , pucExpr AS STRING , bForward AS WORD , pbFound OUT WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsLockRecord(hTable AS IntPtr , ulRec AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsLockTable(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsLookupKey(hIndex AS IntPtr , pucKey AS STRING , usKeyLen AS WORD, usDataType AS WORD, pbFound OUT WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgConnect( pucServerName AS STRING, pucUserName AS STRING, pucPassword AS STRING, phMgmtHandle OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgDisconnect( hMgmtHandle AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgGetActivityInfo( hMgmtHandle AS IntPtr, [@@In] [@@Out] pstActivityInfo AS IntPtr, pusStructSize REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgGetCommStats( hMgmtHandle AS IntPtr, [@@In] [@@Out] pstCommStats AS IntPtr, pusStructSize REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgGetConfigInfo( hMgmtHandle AS IntPtr, [@@In] [@@Out] pstConfigValues AS IntPtr, pusConfigValuesStructSize REF WORD, [@@In] [@@Out] pstConfigMemory AS IntPtr, pusConfigMemoryStructSize REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgGetInstallInfo( hMgmtHandle AS IntPtr, [@@In] [@@Out] pstInstallInfo AS IntPtr,  pusStructSize REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgGetLockOwner( hMgmtHandle AS IntPtr, pucTableName AS STRING, ulRecordNumber AS DWORD, [@@In] [@@Out] pstUserInfo AS IntPtr, pusStructSize REF WORD, pusLockType REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgGetLocks( hMgmtHandle AS IntPtr, pucTableName AS STRING, pucUserName AS STRING, usConnNumber AS WORD, [@@In] [@@Out] astRecordInfo AS IntPtr, pusArrayLen REF WORD,pusStructSize REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgGetOpenIndexes( hMgmtHandle AS IntPtr, pucTableName AS STRING, pucUserName AS STRING, usConnNumber AS WORD, [@@In] [@@Out] astOpenIndexInfo AS IntPtr, pusArrayLen REF WORD,  pusStructSize REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgGetOpenTables( hMgmtHandle AS IntPtr, pucUserName AS STRING, usConnNumber AS WORD, [@@In] [@@Out] astOpenTableInfo AS IntPtr, pusArrayLen REF WORD,  pusStructSize REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgGetUserNames( hMgmtHandle AS IntPtr, pucFileName AS STRING, [@@In] [@@Out] astUserInfo AS IntPtr, pusArrayLen REF WORD,  pusStructSize REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgGetWorkerThreadActivity( hMgmtHandle AS IntPtr, [@@In] [@@Out] astWorkerThreadActivity AS IntPtr,  pusArrayLen REF WORD, pusStructSize REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgResetCommStats( hMgmtHandle AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgDumpInternalTables( hMgmtHandle AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgGetServerType( hMgmtHandle AS IntPtr, pusServerType OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsMgKillUser( hMgmtHandle AS IntPtr, pucUserName AS STRING, usConnNumber AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsNullTerminateStrings(bNullTerminate AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsOpenIndex(hTable AS IntPtr , pucName AS STRING , [@@In] [@@Out] ahIndex AS IntPtr[] , pusArrayLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsOpenTable(hConnect AS IntPtr, pucName AS STRING , pucAlias AS STRING , usTableType AS WORD, usCharType AS WORD , usLockType AS WORD , usCheckRights AS WORD , ulOptions AS DWORD, phTable OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsOpenTable90(hConnect AS IntPtr, pucName AS STRING , pucAlias AS STRING , usTableType AS WORD, usCharType AS WORD , usLockType AS WORD , usCheckRights AS WORD , ulOptions AS DWORD, pucCollation AS STRING , phTable OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsPackTable(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsRecallRecord(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsRecallAllRecords(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsRefreshRecord(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsClearProgressCallback() AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsRegisterCallbackFunction(pfn AS CallbackFn , ulCallBackID AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsClearCallbackFunction() AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsReindex(hObject AS IntPtr) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsReindex61(hObject AS IntPtr, ulPageSize AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsReindexFTS(hObject AS IntPtr, ulPageSize AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsResetConnection(hConnect AS IntPtr) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsRollbackTransaction(hConnect AS IntPtr) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSeek(hIndex AS IntPtr , pucKey AS STRING , usKeyLen AS WORD, usDataType AS WORD, usSeekType AS WORD, pbFound OUT WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSeek(hIndex AS IntPtr , abKey AS BYTE[] , usKeyLen AS WORD, usDataType AS WORD, usSeekType AS WORD, pbFound OUT WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSeekLast(hIndex AS IntPtr , pucKey AS STRING , usKeyLen AS WORD, usDataType AS WORD, pbFound OUT WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSeekLast(hIndex AS IntPtr , abKey AS BYTE[] , usKeyLen AS WORD, usDataType AS WORD, pbFound OUT WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetBinary(hTable AS IntPtr , pucFldName AS STRING , usBinaryType AS WORD , ulTotalLength AS DWORD , ulOffset AS DWORD , pucBuf AS BYTE[] , ulLen AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetBinary(hTable AS IntPtr , lFieldOrdinal AS DWORD, usBinaryType AS WORD , ulTotalLength AS DWORD , ulOffset AS DWORD , pucBuf AS BYTE[] , ulLen AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetCollationLang(pucLang AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetCollation(hConnect AS IntPtr, pucCollation AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetDate(hObj AS IntPtr , pucFldName AS STRING , pucValue AS STRING , usLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetDate(hObj AS IntPtr , lFieldOrdinal AS DWORD, pucValue AS STRING , usLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetDateFormat(pucFormat AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetDateFormat60(hConnect AS IntPtr, pucFormat AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetDecimals(usDecimals AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetDefault(pucDefault AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsShowDeleted(bShowDeleted AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetDouble(hObj AS IntPtr , pucFldName AS STRING , dValue AS REAL8) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetDouble(hObj AS IntPtr , lFieldOrdinal AS DWORD, dValue AS REAL8) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetEmpty(hObj AS IntPtr , pucFldName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetEmpty(hObj AS IntPtr , lFieldOrdinal AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetEpoch(usCentury AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetExact(bExact AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetExact22(hObj AS IntPtr , bExact AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetField(hObj AS IntPtr , pucFldName AS STRING , pucBuf AS STRING , ulLen AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetField(hObj AS IntPtr , lFieldOrdinal AS DWORD, pucBuf AS STRING , ulLen AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetField(hObj AS IntPtr , pucFldName AS STRING , abBuf AS BYTE[] , ulLen AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetField(hObj AS IntPtr , lFieldOrdinal AS DWORD, abBuf AS BYTE[] , ulLen AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetFilter(hTable AS IntPtr , pucFilter AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetHandleINT64(hObj AS IntPtr , ulVal AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetJulian(hObj AS IntPtr , pucFldName AS STRING , lDate AS INT ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetJulian(hObj AS IntPtr , lFieldOrdinal AS DWORD, lDate AS INT) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetLogical(hObj AS IntPtr , pucFldName AS STRING , bValue AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetLogical(hObj AS IntPtr , lFieldOrdinal AS DWORD, bValue AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetLong(hObj AS IntPtr , pucFldName AS STRING , lValue AS LONG ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetLong(hObj AS IntPtr , lFieldOrdinal AS DWORD, lValue AS LONG ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetLongLong(hObj AS IntPtr , pucFldName AS STRING , qValue AS INT64 ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetLongLong(hObj AS IntPtr , lFieldOrdinal AS DWORD, qValue AS INT64 ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetMilliseconds(hObj AS IntPtr , pucFldName AS STRING , lTime AS INT ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetMilliseconds(hObj AS IntPtr , lFieldOrdinal AS DWORD, lTime AS INT ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetMoney(hObj AS IntPtr , pucFldName AS STRING , qValue AS INT64 ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetMoney(hObj AS IntPtr , lFieldOrdinal AS DWORD, qValue AS INT64 ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetRecord(hObj AS IntPtr , pucRec AS BYTE[] , ulLen AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetRelation(hTableParent AS IntPtr , hIndexChild AS IntPtr , pucExpr AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetRelKeyPos(hIndex AS IntPtr , dPos AS REAL8) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetScope(hIndex AS IntPtr , usScopeOption AS WORD, pucScope AS STRING , usScopeLen AS WORD , usDataType AS WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetScope(hIndex AS IntPtr , usScopeOption AS WORD, abScope AS BYTE[] , usScopeLen AS WORD , usDataType AS WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetScopedRelation(hTableParent AS IntPtr , hIndexChild AS IntPtr , pucExpr AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetSearchPath(pucPath AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetServerType(usServerOptions AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetShort(hObj AS IntPtr , pucFldName AS STRING , sValue AS SHORT ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetShort(hObj AS IntPtr , lFieldOrdinal AS DWORD, sValue AS SHORT ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetString(hObj AS IntPtr , pucFldName AS STRING , pucBuf AS STRING , ulLen AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetString(hObj AS IntPtr , lFieldOrdinal AS DWORD, pucBuf AS STRING , ulLen AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Unicode)];
    PUBLIC STATIC EXTERN METHOD AdsSetStringW(hObj AS IntPtr , [MarshalAs(UnmanagedType.LPStr)] pucFldName AS STRING , pucBuf AS STRING , ulLen AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Unicode)];
    PUBLIC STATIC EXTERN METHOD AdsSetStringW(hObj AS IntPtr , lFieldOrdinal AS DWORD, pucBuf AS STRING , ulLen AS DWORD ) AS DWORD


    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetTableTransactionFree(hTable as IntPtr, usTransFree as WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetTime(hObj AS IntPtr , pucFldName AS STRING , pucValue AS STRING , usLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetTime(hObj AS IntPtr , lFieldOrdinal AS DWORD, pucValue AS STRING , usLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsShowError(pucTitle AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSkip(hObj AS IntPtr , lRecs AS INT) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSkipUnique(hIndex AS IntPtr , lRecs AS INT) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsThreadExit() AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsUnlockRecord(hTable AS IntPtr , ulRec AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsUnlockTable(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsVerifyPassword(hTable AS IntPtr , pusEnabled OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsEncryptionEnabled(hTable AS IntPtr , pusEnabled OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsWriteAllRecords() AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsWriteRecord(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsZapTable(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetAOF(hTable AS IntPtr , pucFilter AS STRING , usOptions AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsEvalAOF(hTable AS IntPtr , pucFilter AS STRING , pusOptLevel OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsClearAOF(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsRefreshAOF(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetAOF(hTable AS IntPtr , [@@In] [@@Out] pucFilter AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetAOFOptLevel(hTable AS IntPtr , pusOptLevel OUT WORD , [@@In] [@@Out] pucNonOpt AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsRecordInAOF(hTable AS IntPtr , ulRecordNum AS DWORD , pusIsInAOF OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCustomizeAOF(hTable AS IntPtr , ulNumRecords AS DWORD , pulRecords OUT DWORD , usOption AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsInitRawKey(hIndex AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsBuildRawKey(hIndex AS IntPtr , [@@In] [@@Out] pucKey AS BYTE[] , pusKeyLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCreateSQLStatement(hConnect AS IntPtr, phStatement OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsPrepareSQL(hStatement AS IntPtr , pucSQL AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsExecuteSQL(hStatement AS IntPtr , phCursor OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsExecuteSQLDirect(hStatement AS IntPtr , pucSQL AS STRING , phCursor OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCloseSQLStatement(hStatement AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsStmtSetTableRights(hStatement AS IntPtr , usCheckRights AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsStmtSetTableReadOnly(hStatement AS IntPtr , usReadOnly AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsStmtSetTableLockType(hStatement AS IntPtr , usLockType AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsStmtSetTableCharType(hStatement AS IntPtr , usCharType AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsStmtSetTableType(hStatement AS IntPtr , usTableType AS WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsStmtSetTableCollation(hStatement AS IntPtr , pucCollation AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsStmtConstrainUpdates(hStatement AS IntPtr , usConstrain AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsStmtEnableEncryption(hStatement AS IntPtr , pucPassword AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsStmtDisableEncryption(hStatement AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsStmtSetTablePassword(hStatement AS IntPtr , pucTableName AS STRING , pucPassword AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsStmtClearTablePasswords(hStatement AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsStmtReadAllColumns(hStatement AS IntPtr , usReadColumns AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsClearSQLParams(hStatement AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetTimeStamp(hObj AS IntPtr , pucFldName AS STRING , pucBuf AS STRING , ulLen AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetTimeStamp(hObj AS IntPtr , lFieldOrdinal AS DWORD, pucBuf AS STRING , ulLen AS DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsClearSQLAbortFunc() AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetNumParams(hStatement AS IntPtr , pusNumParams OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetLastAutoinc(hObj AS IntPtr , pulAutoIncVal OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsIndexUserDefined(hIndex AS IntPtr , pbUserDefined OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsRestructureTable(hObj AS IntPtr , pucName AS STRING , pucPassword AS STRING , usTableType AS WORD, usCharType AS WORD , usLockType AS WORD , usCheckRights AS WORD , pucAddFields AS STRING , pucDeleteFields AS STRING , pucChangeFields AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsRestructureTable90(hObj AS IntPtr , pucName AS STRING , pucPassword AS STRING , usTableType AS WORD, usCharType AS WORD , usLockType AS WORD , usCheckRights AS WORD , pucAddFields AS STRING , pucDeleteFields AS STRING , pucChangeFields AS STRING , pucCollation AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetSQLStatementHandle(hCursor AS IntPtr , phStmt OUT IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetSQLStatement(hStmt AS IntPtr , [@@In] [@@Out] pucSQL AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsFlushFileBuffers(hTable AS IntPtr ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDDeployDatabase(pucDestination AS STRING , pucDestinationPassword AS STRING , pucSource AS STRING , pucSourcePassword AS STRING , usServerTypes AS WORD, usValidateOption AS WORD , usBackupFiles AS WORD , ulOptions AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsVerifySQL(hStatement AS IntPtr , pucSQL AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDisableUniqueEnforcement(hConnect AS IntPtr) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsEnableUniqueEnforcement(hConnect AS IntPtr) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDisableRI(hConnect AS IntPtr) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsEnableRI(hConnect AS IntPtr) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDisableAutoIncEnforcement(hConnection AS IntPtr) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsEnableAutoIncEnforcement(hConnection AS IntPtr) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsRollbackTransaction80(hConnect AS IntPtr, pucSavepoint AS STRING , ulOptions AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsCreateSavepoint(hConnect AS IntPtr, pucSavepoint AS STRING , ulOptions AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDFreeTable(pucTableName AS STRING , pucPassword AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetIndexProperty(hAdminConn AS IntPtr , pucTableName AS STRING , pucIndexName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pvProperty AS BYTE[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetIndexProperty(hAdminConn AS IntPtr , pucTableName AS STRING , pucIndexName AS STRING , usPropertyID AS WORD, [@@In] [@@Out] pucProperty AS CHAR[] , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsDDSetIndexProperty(hAdminConn AS IntPtr , pucTableName AS STRING , pucIndexName AS STRING , usPropertyID AS WORD, pusProperty REF WORD , usPropertyLen AS WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsFieldBinary(hTable AS IntPtr , pucFldName AS STRING , pbBinary OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsFieldBinary(hTable AS IntPtr , lFieldOrdinal AS DWORD, pbBinary OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsNull(hTable AS IntPtr , pucFldName AS STRING , pbNull OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsNull(hTable AS IntPtr , lFieldOrdinal AS DWORD, pbNull OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsNullable(hTable AS IntPtr , pucFldName AS STRING , pbNullable OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsIsNullable(hTable AS IntPtr , lFieldOrdinal AS DWORD, pbNullable OUT WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetNull(hTable AS IntPtr , pucFldName AS STRING ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetNull(hTable AS IntPtr , lFieldOrdinal AS DWORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetTableCollation(hTbl AS IntPtr , [@@In] [@@Out] pucCollation AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetIndexCollation(hIndex AS IntPtr , [@@In] [@@Out] pucCollation AS CHAR[] , pusLen REF WORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetDataLength(hTable AS IntPtr , pucFldName AS STRING , ulOptions AS DWORD, pulLength OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsGetDataLength(hTable AS IntPtr , lFieldOrdinal AS DWORD, ulOptions AS DWORD, pulLength OUT DWORD ) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetIndexDirection(hIndex AS IntPtr ,  usReverseDirection AS WORD) AS DWORD

    [DllImport("ace32.dll", CharSet := CharSet.Ansi)];
    PUBLIC STATIC EXTERN METHOD AdsSetProperty90(hObj AS IntPtr , ulOperation AS DWORD , uqValue REF UINT64 ) AS DWORD


    END CLASS
END NAMESPACE
