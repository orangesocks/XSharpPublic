//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//


#region defines
DEFINE SQL_NULL_DATA	:=	(-1)
DEFINE SQL_DATA_AT_EXEC	:=	(-2)
DEFINE SQL_SUCCESS	:=	0
DEFINE SQL_SUCCESS_WITH_INFO	:=	1
DEFINE SQL_NO_DATA	:=	100
DEFINE SQL_ERROR	:=	(-1)
DEFINE SQL_INVALID_HANDLE	:=	(-2)
DEFINE SQL_STILL_EXECUTING	:=	2
DEFINE SQL_NEED_DATA	:=	99
DEFINE SQL_NTS	:=	(-3)
DEFINE SQL_NTSL	:=	(-3L)
DEFINE SQL_MAX_MESSAGE_LENGTH	:=	512
DEFINE SQL_DATE_LEN	:=	10
DEFINE SQL_TIME_LEN	:=	8  /* add P+1 if precision is nonzero */
DEFINE SQL_TIMESTAMP_LEN	:=	19  /* add P+1 if precision is nonzero */
DEFINE SQL_HANDLE_ENV	:=	1
DEFINE SQL_HANDLE_DBC	:=	2
DEFINE SQL_HANDLE_STMT	:=	3
DEFINE SQL_HANDLE_DESC	:=	4
DEFINE SQL_ATTR_OUTPUT_NTS	:=	10001
DEFINE SQL_ATTR_AUTO_IPD	:=	10001
DEFINE SQL_ATTR_METADATA_ID	:=	10014
DEFINE SQL_ATTR_APP_ROW_DESC	:=	10010
DEFINE SQL_ATTR_APP_PARAM_DESC	:=	10011
DEFINE SQL_ATTR_IMP_ROW_DESC	:=	10012
DEFINE SQL_ATTR_IMP_PARAM_DESC	:=	10013
DEFINE SQL_ATTR_CURSOR_SCROLLABLE	:=	(-1)
DEFINE SQL_ATTR_CURSOR_SENSITIVITY	:=	(-2)
DEFINE SQL_NONSCROLLABLE	:=			0
DEFINE SQL_SCROLLABLE	:=				1
DEFINE SQL_DESC_COUNT	:=	1001
DEFINE SQL_DESC_TYPE	:=	1002
DEFINE SQL_DESC_LENGTH	:=	1003
DEFINE SQL_DESC_OCTET_LENGTH_PTR	:=	1004
DEFINE SQL_DESC_PRECISION	:=	1005
DEFINE SQL_DESC_SCALE	:=	1006
DEFINE SQL_DESC_DATETIME_INTERVAL_CODE	:=	1007
DEFINE SQL_DESC_NULLABLE	:=	1008
DEFINE SQL_DESC_INDICATOR_PTR	:=	1009
DEFINE SQL_DESC_DATA_PTR	:=	1010
DEFINE SQL_DESC_NAME	:=	1011
DEFINE SQL_DESC_UNNAMED	:=	1012
DEFINE SQL_DESC_OCTET_LENGTH	:=	1013
DEFINE SQL_DESC_ALLOC_TYPE	:=	1099
DEFINE SQL_DIAG_RETURNCODE	:=	1
DEFINE SQL_DIAG_NUMBER	:=	2
DEFINE SQL_DIAG_ROW_COUNT	:=	3
DEFINE SQL_DIAG_SQLSTATE	:=	4
DEFINE SQL_DIAG_NATIVE	:=	5
DEFINE SQL_DIAG_MESSAGE_TEXT	:=	6
DEFINE SQL_DIAG_DYNAMIC_FUNCTION	:=	7
DEFINE SQL_DIAG_CLASS_ORIGIN	:=	8
DEFINE SQL_DIAG_SUBCLASS_ORIGIN	:=	9
DEFINE SQL_DIAG_CONNECTION_NAME	:=	10
DEFINE SQL_DIAG_SERVER_NAME	:=	11
DEFINE SQL_DIAG_DYNAMIC_FUNCTION_CODE	:=	12
DEFINE SQL_DIAG_ALTER_DOMAIN	:=			3
DEFINE SQL_DIAG_ALTER_TABLE	:=	4
DEFINE SQL_DIAG_CALL	:=					7
DEFINE SQL_DIAG_CREATE_ASSERTION	:=		6
DEFINE SQL_DIAG_CREATE_CHARACTER_SET	:=	8
DEFINE SQL_DIAG_CREATE_COLLATION	:=		10
DEFINE SQL_DIAG_CREATE_DOMAIN	:=			23
DEFINE SQL_DIAG_CREATE_INDEX	:=	(-1)
DEFINE SQL_DIAG_CREATE_SCHEMA	:=			64
DEFINE SQL_DIAG_CREATE_TABLE	:=	77
DEFINE SQL_DIAG_CREATE_TRANSLATION	:=		79
DEFINE SQL_DIAG_CREATE_VIEW	:=	84
DEFINE SQL_DIAG_DELETE_WHERE	:=	19
DEFINE SQL_DIAG_DROP_ASSERTION	:=			24
DEFINE SQL_DIAG_DROP_CHARACTER_SET	:=		25
DEFINE SQL_DIAG_DROP_COLLATION	:=			26
DEFINE SQL_DIAG_DROP_DOMAIN	:=			27
DEFINE SQL_DIAG_DROP_INDEX	:=	(-2)
DEFINE SQL_DIAG_DROP_SCHEMA	:=			31
DEFINE SQL_DIAG_DROP_TABLE	:=	32
DEFINE SQL_DIAG_DROP_TRANSLATION	:=	33
DEFINE SQL_DIAG_DROP_VIEW	:=	36
DEFINE SQL_DIAG_DYNAMIC_DELETE_CURSOR	:=	38
DEFINE SQL_DIAG_DYNAMIC_UPDATE_CURSOR	:=	81
DEFINE SQL_DIAG_GRANT	:=	48
DEFINE SQL_DIAG_INSERT	:=	50
DEFINE SQL_DIAG_REVOKE	:=	59
DEFINE SQL_DIAG_SELECT_CURSOR	:=	85
DEFINE SQL_DIAG_UNKNOWN_STATEMENT	:=	0
DEFINE SQL_DIAG_UPDATE_WHERE	:=	82
DEFINE SQL_UNKNOWN_TYPE	:=	0
DEFINE SQL_CHAR	:=	1
DEFINE SQL_NUMERIC	:=	2
DEFINE SQL_DECIMAL	:=	3
DEFINE SQL_INTEGER	:=	4
DEFINE SQL_SMALLINT	:=	5
DEFINE SQL_FLOAT	:=	6
DEFINE SQL_REAL	:=	7
DEFINE SQL_DOUBLE	:=	8
DEFINE SQL_DATETIME	:=	9
DEFINE SQL_VARCHAR	:=	12
DEFINE SQL_TYPE_DATE	:=	91
DEFINE SQL_TYPE_TIME	:=	92
DEFINE SQL_TYPE_TIMESTAMP	:=	93
DEFINE SQL_UNSPECIFIED	:=	0
DEFINE SQL_INSENSITIVE	:=	1
DEFINE SQL_SENSITIVE	:=	2
DEFINE SQL_ALL_TYPES	:=	0
DEFINE SQL_DEFAULT	:=	99
DEFINE SQL_ARD_TYPE	:=	(-99)
DEFINE SQL_CODE_DATE	:=	1
DEFINE SQL_CODE_TIME	:=	2
DEFINE SQL_CODE_TIMESTAMP	:=	3
DEFINE SQL_FALSE	:=	0
DEFINE SQL_TRUE	:=	1
DEFINE SQL_NO_NULLS	:=	0
DEFINE SQL_NULLABLE	:=	1
DEFINE SQL_NULLABLE_UNKNOWN	:=	2
DEFINE SQL_PRED_NONE	:=	0
DEFINE SQL_PRED_CHAR	:=	1
DEFINE SQL_PRED_BASIC	:=	2
DEFINE SQL_NAMED	:=	0
DEFINE SQL_UNNAMED	:=	1
DEFINE SQL_DESC_ALLOC_AUTO	:=	1
DEFINE SQL_DESC_ALLOC_USER	:=	2
DEFINE SQL_CLOSE	:=	0
DEFINE SQL_DROP	:=	1
DEFINE SQL_UNBIND	:=	2
DEFINE SQL_RESET_PARAMS	:=	3
DEFINE SQL_FETCH_NEXT	:=	1
DEFINE SQL_FETCH_FIRST	:=	2
DEFINE SQL_FETCH_LAST	:=	3
DEFINE SQL_FETCH_PRIOR	:=	4
DEFINE SQL_FETCH_ABSOLUTE	:=	5
DEFINE SQL_FETCH_RELATIVE	:=	6
DEFINE SQL_COMMIT	:=	0
DEFINE SQL_ROLLBACK	:=	1
DEFINE SQL_NULL_HENV	:=	NULL_PTR
DEFINE SQL_NULL_HDBC	:=	NULL_PTR
DEFINE SQL_NULL_HSTMT	:=	NULL_PTR
DEFINE SQL_NULL_HDESC	:=	NULL_PTR
DEFINE SQL_NULL_HANDLE	:=	NULL_PTR
DEFINE SQL_SCOPE_CURROW	:=	0
DEFINE SQL_SCOPE_TRANSACTION	:=	1
DEFINE SQL_SCOPE_SESSION	:=	2
DEFINE SQL_PC_UNKNOWN	:=	0
DEFINE SQL_PC_NON_PSEUDO	:=	1
DEFINE SQL_PC_PSEUDO	:=	2
DEFINE SQL_ROW_IDENTIFIER	:=	1
DEFINE SQL_INDEX_UNIQUE	:=	0
DEFINE SQL_INDEX_ALL	:=	1
DEFINE SQL_INDEX_CLUSTERED	:=	1
DEFINE SQL_INDEX_HASHED	:=	2
DEFINE SQL_INDEX_OTHER	:=	3
DEFINE SQL_API_SQLALLOCCONNECT	:=	1
DEFINE SQL_API_SQLALLOCENV	:=	2
DEFINE SQL_API_SQLALLOCHANDLE	:=	1001
DEFINE SQL_API_SQLALLOCSTMT	:=	3
DEFINE SQL_API_SQLBINDCOL	:=	4
DEFINE SQL_API_SQLBINDPARAM	:=	1002
DEFINE SQL_API_SQLCANCEL	:=	5
DEFINE SQL_API_SQLCLOSECURSOR	:=	1003
DEFINE SQL_API_SQLCOLATTRIBUTE	:=	6
DEFINE SQL_API_SQLCOLUMNS	:=	40
DEFINE SQL_API_SQLCONNECT	:=	7
DEFINE SQL_API_SQLCOPYDESC	:=	1004
DEFINE SQL_API_SQLDATASOURCES	:=	57
DEFINE SQL_API_SQLDESCRIBECOL	:=	8
DEFINE SQL_API_SQLDISCONNECT	:=	9
DEFINE SQL_API_SQLENDTRAN	:=	1005
DEFINE SQL_API_SQLERROR	:=	10
DEFINE SQL_API_SQLEXECDIRECT	:=	11
DEFINE SQL_API_SQLEXECUTE	:=	12
DEFINE SQL_API_SQLFETCH	:=	13
DEFINE SQL_API_SQLFETCHSCROLL	:=	1021
DEFINE SQL_API_SQLFREECONNECT	:=	14
DEFINE SQL_API_SQLFREEENV	:=	15
DEFINE SQL_API_SQLFREEHANDLE	:=	1006
DEFINE SQL_API_SQLFREESTMT	:=	16
DEFINE SQL_API_SQLGETCONNECTATTR	:=	1007
DEFINE SQL_API_SQLGETCONNECTOPTION	:=	42
DEFINE SQL_API_SQLGETCURSORNAME	:=	17
DEFINE SQL_API_SQLGETDATA	:=	43
DEFINE SQL_API_SQLGETDESCFIELD	:=	1008
DEFINE SQL_API_SQLGETDESCREC	:=	1009
DEFINE SQL_API_SQLGETDIAGFIELD	:=	1010
DEFINE SQL_API_SQLGETDIAGREC	:=	1011
DEFINE SQL_API_SQLGETENVATTR	:=	1012
DEFINE SQL_API_SQLGETFUNCTIONS	:=	44
DEFINE SQL_API_SQLGETINFO	:=	45
DEFINE SQL_API_SQLGETSTMTATTR	:=	1014
DEFINE SQL_API_SQLGETSTMTOPTION	:=	46
DEFINE SQL_API_SQLGETTYPEINFO	:=	47
DEFINE SQL_API_SQLNUMRESULTCOLS	:=	18
DEFINE SQL_API_SQLPARAMDATA	:=	48
DEFINE SQL_API_SQLPREPARE	:=	19
DEFINE SQL_API_SQLPUTDATA	:=	49
DEFINE SQL_API_SQLROWCOUNT	:=	20
DEFINE SQL_API_SQLSETCONNECTATTR	:=	1016
DEFINE SQL_API_SQLSETCONNECTOPTION	:=	50
DEFINE SQL_API_SQLSETCURSORNAME	:=	21
DEFINE SQL_API_SQLSETDESCFIELD	:=	1017
DEFINE SQL_API_SQLSETDESCREC	:=	1018
DEFINE SQL_API_SQLSETENVATTR	:=	1019
DEFINE SQL_API_SQLSETPARAM	:=	22
DEFINE SQL_API_SQLSETSTMTATTR	:=	1020
DEFINE SQL_API_SQLSETSTMTOPTION	:=	51
DEFINE SQL_API_SQLSPECIALCOLUMNS	:=	52
DEFINE SQL_API_SQLSTATISTICS	:=	53
DEFINE SQL_API_SQLTABLES	:=	54
DEFINE SQL_API_SQLTRANSACT	:=	23
DEFINE SQL_MAX_DRIVER_CONNECTIONS	:=	0
DEFINE SQL_MAXIMUM_DRIVER_CONNECTIONS	:=		SQL_MAX_DRIVER_CONNECTIONS
DEFINE SQL_MAX_CONCURRENT_ACTIVITIES	:=	1
DEFINE SQL_MAXIMUM_CONCURRENT_ACTIVITIES	:=	SQL_MAX_CONCURRENT_ACTIVITIES
DEFINE SQL_DATA_SOURCE_NAME	:=	2
DEFINE SQL_FETCH_DIRECTION	:=	8
DEFINE SQL_SERVER_NAME	:=	13
DEFINE SQL_SEARCH_PATTERN_ESCAPE	:=	14
DEFINE SQL_DBMS_NAME	:=	17
DEFINE SQL_DBMS_VER	:=	18
DEFINE SQL_ACCESSIBLE_TABLES	:=	19
DEFINE SQL_ACCESSIBLE_PROCEDURES	:=		20
DEFINE SQL_CURSOR_COMMIT_BEHAVIOR	:=	23
DEFINE SQL_DATA_SOURCE_READ_ONLY	:=	25
DEFINE SQL_DEFAULT_TXN_ISOLATION	:=	26
DEFINE SQL_IDENTIFIER_CASE	:=	28
DEFINE SQL_IDENTIFIER_QUOTE_CHAR	:=	29
DEFINE SQL_MAX_COLUMN_NAME_LEN	:=	30
DEFINE SQL_MAXIMUM_COLUMN_NAME_LENGTH	:=		SQL_MAX_COLUMN_NAME_LEN
DEFINE SQL_MAX_CURSOR_NAME_LEN	:=	31
DEFINE SQL_MAXIMUM_CURSOR_NAME_LENGTH	:=		SQL_MAX_CURSOR_NAME_LEN
DEFINE SQL_MAX_SCHEMA_NAME_LEN	:=	32
DEFINE SQL_MAXIMUM_SCHEMA_NAME_LENGTH	:=		SQL_MAX_SCHEMA_NAME_LEN
DEFINE SQL_MAX_CATALOG_NAME_LEN	:=	34
DEFINE SQL_MAXIMUM_CATALOG_NAME_LENGTH	:=		SQL_MAX_CATALOG_NAME_LEN
DEFINE SQL_MAX_TABLE_NAME_LEN	:=	35
DEFINE SQL_SCROLL_CONCURRENCY	:=	43
DEFINE SQL_TXN_CAPABLE	:=	46
DEFINE SQL_TRANSACTION_CAPABLE	:=				SQL_TXN_CAPABLE
DEFINE SQL_USER_NAME	:=	47
DEFINE SQL_TXN_ISOLATION_OPTION	:=	72
DEFINE SQL_TRANSACTION_ISOLATION_OPTION	:=	SQL_TXN_ISOLATION_OPTION
DEFINE SQL_INTEGRITY	:=	73
DEFINE SQL_GETDATA_EXTENSIONS	:=	81
DEFINE SQL_NULL_COLLATION	:=	85
DEFINE SQL_ALTER_TABLE	:=	86
DEFINE SQL_ORDER_BY_COLUMNS_IN_SELECT	:=	90
DEFINE SQL_SPECIAL_CHARACTERS	:=	94
DEFINE SQL_MAX_COLUMNS_IN_GROUP_BY	:=	97
DEFINE SQL_MAXIMUM_COLUMNS_IN_GROUP_BY	:=		SQL_MAX_COLUMNS_IN_GROUP_BY
DEFINE SQL_MAX_COLUMNS_IN_INDEX	:=	98
DEFINE SQL_MAXIMUM_COLUMNS_IN_INDEX	:=		SQL_MAX_COLUMNS_IN_INDEX
DEFINE SQL_MAX_COLUMNS_IN_ORDER_BY	:=	99
DEFINE SQL_MAXIMUM_COLUMNS_IN_ORDER_BY	:=		SQL_MAX_COLUMNS_IN_ORDER_BY
DEFINE SQL_MAX_COLUMNS_IN_SELECT	:=	100
DEFINE SQL_MAXIMUM_COLUMNS_IN_SELECT	:=	SQL_MAX_COLUMNS_IN_SELECT
DEFINE SQL_MAX_COLUMNS_IN_TABLE	:=	101
DEFINE SQL_MAX_INDEX_SIZE	:=	102
DEFINE SQL_MAXIMUM_INDEX_SIZE	:=			   SQL_MAX_INDEX_SIZE
DEFINE SQL_MAX_ROW_SIZE	:=	104
DEFINE SQL_MAXIMUM_ROW_SIZE	:=			   SQL_MAX_ROW_SIZE
DEFINE SQL_MAX_STATEMENT_LEN	:=	105
DEFINE SQL_MAXIMUM_STATEMENT_LENGTH	:=	SQL_MAX_STATEMENT_LEN
DEFINE SQL_MAX_TABLES_IN_SELECT	:=	106
DEFINE SQL_MAXIMUM_TABLES_IN_SELECT	:=	SQL_MAX_TABLES_IN_SELECT
DEFINE SQL_MAX_USER_NAME_LEN	:=	107
DEFINE SQL_MAXIMUM_USER_NAME_LENGTH	:=	SQL_MAX_USER_NAME_LEN
DEFINE SQL_OJ_CAPABILITIES	:=	115
DEFINE SQL_OUTER_JOIN_CAPABILITIES	:=		   SQL_OJ_CAPABILITIES
DEFINE SQL_XOPEN_CLI_YEAR	:=	10000
DEFINE SQL_CURSOR_SENSITIVITY	:=	10001
DEFINE SQL_DESCRIBE_PARAMETER	:=	10002
DEFINE SQL_CATALOG_NAME	:=	10003
DEFINE SQL_COLLATION_SEQ	:=	10004
DEFINE SQL_MAX_IDENTIFIER_LEN	:=	10005
DEFINE SQL_MAXIMUM_IDENTIFIER_LENGTH	:=	SQL_MAX_IDENTIFIER_LEN
DEFINE SQL_AT_ADD_COLUMN	:=		0x00000001L
DEFINE SQL_AT_DROP_COLUMN	:=		0x00000002L
DEFINE SQL_AT_ADD_CONSTRAINT	:=		0x00000008L
DEFINE SQL_AM_NONE	:=	0
DEFINE SQL_AM_CONNECTION	:=	1
DEFINE SQL_AM_STATEMENT	:=	2
DEFINE SQL_CB_DELETE	:=	0
DEFINE SQL_CB_CLOSE	:=	1
DEFINE SQL_CB_PRESERVE	:=	2
DEFINE SQL_FD_FETCH_NEXT	:=	0x00000001L
DEFINE SQL_FD_FETCH_FIRST	:=	0x00000002L
DEFINE SQL_FD_FETCH_LAST	:=	0x00000004L
DEFINE SQL_FD_FETCH_PRIOR	:=	0x00000008L
DEFINE SQL_FD_FETCH_ABSOLUTE	:=	0x00000010L
DEFINE SQL_FD_FETCH_RELATIVE	:=	0x00000020L
DEFINE SQL_GD_ANY_COLUMN	:=	0x00000001L
DEFINE SQL_GD_ANY_ORDER	:=	0x00000002L
DEFINE SQL_IC_UPPER	:=	1
DEFINE SQL_IC_LOWER	:=	2
DEFINE SQL_IC_SENSITIVE	:=	3
DEFINE SQL_IC_MIXED	:=	4
DEFINE SQL_OJ_LEFT	:=	0x00000001L
DEFINE SQL_OJ_RIGHT	:=	0x00000002L
DEFINE SQL_OJ_FULL	:=	0x00000004L
DEFINE SQL_OJ_NESTED	:=	0x00000008L
DEFINE SQL_OJ_NOT_ORDERED	:=	0x00000010L
DEFINE SQL_OJ_INNER	:=	0x00000020L
DEFINE SQL_OJ_ALL_COMPARISON_OPS	:=	0x00000040L
DEFINE SQL_SCCO_READ_ONLY	:=	0x00000001L
DEFINE SQL_SCCO_LOCK	:=	0x00000002L
DEFINE SQL_SCCO_OPT_ROWVER	:=	0x00000004L
DEFINE SQL_SCCO_OPT_VALUES	:=	0x00000008L
DEFINE SQL_TC_NONE	:=	0
DEFINE SQL_TC_DML	:=	1
DEFINE SQL_TC_ALL	:=	2
DEFINE SQL_TC_DDL_COMMIT	:=	3
DEFINE SQL_TC_DDL_IGNORE	:=	4
DEFINE SQL_TXN_READ_UNCOMMITTED	:=	0x00000001L
DEFINE SQL_TRANSACTION_READ_UNCOMMITTED	:=	SQL_TXN_READ_UNCOMMITTED
DEFINE SQL_TXN_READ_COMMITTED	:=	0x00000002L
DEFINE SQL_TRANSACTION_READ_COMMITTED	:=		SQL_TXN_READ_COMMITTED
DEFINE SQL_TXN_REPEATABLE_READ	:=	0x00000004L
DEFINE SQL_TRANSACTION_REPEATABLE_READ	:=		SQL_TXN_REPEATABLE_READ
DEFINE SQL_TXN_SERIALIZABLE	:=	0x00000008L
DEFINE SQL_TRANSACTION_SERIALIZABLE	:=		SQL_TXN_SERIALIZABLE
DEFINE SQL_NC_HIGH	:=	0
DEFINE SQL_NC_LOW	:=	1
#endregion
