//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//


USING System.Data
USING System.Data.Common
USING System.Reflection
USING System.Runtime.InteropServices
USING System.Diagnostics


/// <include file="Sql.xml" path="doc/SQLStatement/*" />
[XSharp.Internal.TypesChanged];
[DebuggerDisplay( "{SQLString}" )] ;
CLASS SQLStatement
    #region VO compatible Ivars
    PROTECT oConn           AS SQLConnection
    PROTECT cStatement      AS STRING
    PROTECT oErrInfo        AS SQLErrorInfo
    PROTECT lPrepFlag       AS LOGIC
    PROTECT aParams[0]      AS ARRAY
    PROTECT nRows           AS INT
    #endregion


    #region DotNet IVars
    INTERNAL oNetConn       AS DbConnection
    INTERNAL oNetCmd        AS DbCommand
    INTERNAL oDataTable     AS DataTable
    INTERNAL oSchema        AS DataTable
    INTERNAL oDataSet		AS DataSet
    #endregion




    #region Constructors & Destructors
/// <include file="Sql.xml" path="doc/SQLStatement.ctor/*" />
    CONSTRUCTOR( cSQLStatement, oSQLConnection )
        SELF:PrepFlag := FALSE
        oErrInfo  := SQLErrorInfo{}
        IF IsString( cSQLStatement ) .AND. SLen( cSQLStatement ) > 0
            SELF:cStatement := cSQLStatement
        ENDIF
        IF IsNil(oSQLConnection)
            SELF:oConn := SQLSetConnection()
        ELSE
            SELF:oConn := oSQLConnection
        ENDIF
        // Create DotNet Command
        SELF:oNetConn := SELF:oConn:NetConn
        SELF:oNetCmd  := NULL


        IF oConn:Connected
            SELF:__AllocStmt()
        ELSE
            SELF:__GenerateSQLError( __CavoStr( __CAVOSTR_SQLCLASS__NOT_CONN ), #Init, NULL )
        ENDIF


        SELF:aParams := {}
        RETURN


/// <include file="Sql.xml" path="doc/SQLStatement.dtor/*" />
    DESTRUCTOR()
        SELF:Destroy()
        RETURN
/// <include file="Sql.xml" path="doc/SQLStatement.Destroy/*" />
    METHOD Destroy() AS USUAL CLIPPER
        IF oNetCmd != NULL .AND. oConn != NULL_OBJECT
            IF oConn:Connected
                SELF:__FreeParameters()
                SELF:__FreeStmt( SQL_DROP )
                SELF:oNetCmd := NULL_OBJECT
                UnRegisterAxit(SELF)
            ENDIF
        ENDIF
        IF SELF:oDataSet != NULL
            SELF:oDataSet:Dispose()
            SELF:oDataSet := NULL
        ENDIF
        IF SELF:oDataTable != NULL
            SELF:oDataTable:Dispose()
            SELF:oDataTable := NULL
        ENDIF
        IF SELF:oSchema != NULL
            SELF:oSchema:Dispose()
            SELF:oSchema := NULL
        ENDIF
        RETURN NIL
        #endregion


    #region Methods
/// <include file="Sql.xml" path="doc/SQLStatement.Commit/*" />
    METHOD Commit()
        RETURN SELF:Connection:Commit()


    STATIC METHOD FillErrorHandler(sender AS OBJECT , e AS FillErrorEventArgs ) AS VOID
        e:Continue := TRUE
    RETURN


    // Hier ist der Einsprungpunkt f�r den Translator
/// <include file="Sql.xml" path="doc/SQLStatement.Execute/*" />
    METHOD Execute( uParm )
        LOCAL nCount     AS DWORD
        LOCAL aArg       := NULL_ARRAY AS ARRAY
        LOCAL lRet       AS LOGIC
        LOCAL lNewParams := FALSE AS LOGIC


        IF SELF:oNetCmd == NULL
            SELF:__AllocStmt()
        ENDIF


        nCount := ALen( SELF:aParams )


        IF PCount() != 0
            IF PCount() = 1 .AND. UsualType( uParm ) = ARRAY
                    aArg   := uParm
                nCount := ALen( uParm )
            ELSE
                aArg := {}


                FOR nCount := 1 UPTO PCount()
                    AAdd( aArg, _GETMPARAM( nCount ) )
                NEXT
            ENDIF
            lNewParams := TRUE
        ENDIF


        IF nCount != 0
            IF ! lNewParams
                aArg := SELF:aParams
            ENDIF
            IF !SELF:__SetParameters( aArg )
                SELF:__FreeParameters()
                RETURN FALSE
            ENDIF
        ENDIF
        IF ALen(SELF:aParams) > 0 .AND. ! lPrepFlag
            SELF:Prepare()
        ENDIF
        LOCAL oDataReader := NULL AS DbDataReader
        TRY
                SELF:oNetCmd:CommandText  := oConn:Factory:TranslateStatement(cStatement)
                //		IF translator != NULL
                //			stmtIn := SELF:oNetCmd:CommandText
                //			LOCAL clock := Stopwatch{} AS Stopwatch
                //			clock:Start()
                //			stmtOut := translator:TranslateStatement(stmtIn)
                //			clock:Stop()
                //			elms := clock:ElapsedMilliseconds:ToString()
                //			IF stmtOut == "ERROR"
                //				stmtOut := translator:getErrorInfo()
                //				SELF:oNetCmd:CommandText := ""
                //			ELSE
                //				SELF:oNetCmd:CommandText := stmtOut
                //			ENDIF
                //		ENDIF
                oDataSet := DataSet{}


                oDataTable  := DataTable{}
                oDataTable:TableName := "Table"
                oDataSet:Tables:Add(oDataTable)
                oDataSet:EnforceConstraints := FALSE
                oDataReader := SELF:oNetCmd:ExecuteReader()
                nRows := oDataReader:RecordsAffected
                oDataReader := SELF:oConn:Factory:AfterOpen(oDataReader)
                //		IF oDataReader:FieldCount != 0 .AND. SELF:Connection:ProviderType == ProviderType.MySql
                //			// Adjust result set to avoid getting constraints in the DataReader which causes some resultsets
                //			// to only load the first row
                //			AdjustMySqlDataReaderColumnFlags(oDataReader)
                //		ENDIF
                oSchema     := oDataReader:GetSchemaTable()
                oDataTable:Load(oDataReader,LoadOption.OverwriteChanges)
                IF oDataTable:Rows:Count > 0
                    nRows := oDataTable:Rows:Count
                ENDIF
                lPrepFlag := TRUE
            lRet      := TRUE
        CATCH e AS Exception
            IF oDataReader != NULL_OBJECT
                oDataReader:Dispose()
            ENDIF
            SELF:MakeErrorInfo(SELF, #Execute, e)
            lRet      := FALSE
        END TRY
        //	IF translator != NULL
        //		translator:LogSuccess(stmtIn, stmtOut, lRet, elms, NULL)
        //	ENDIF
        RETURN lRet


    // the following properties are used by AdjustMySqlDataReaderColumnFlags
    STATIC PROTECTED oResultSetProperty AS PropertyInfo		// MySqlDataReader:ResultSet = MySql.Data.MySqlClient.ResultSet
    STATIC PROTECTED oFieldsProperty	AS PropertyInfo		// ResultSet:Fields = MySql.Data.MySqlClient.MySqlField[]
    STATIC PROTECTED oFlagsProperty		AS PropertyInfo		// Field:colFlags   = MySql.Data.MySqlClient.ColumnFlags
    STATIC PROTECTED oLengthField		AS FieldInfo		// Field:colFlags   = MySql.Data.MySqlClient.ColumnFlags


        //	STATIC METHOD AdjustMySqlDataReaderColumnFlags(oDataReader AS DbDataReader) AS VOID
        //		// This method removes the unique and primary key flags from the fields in the DataReader to prevent Contraints problems
        //		// Because some of the types and properties are "Internal" to the MySql.Data assembly
        //		// We need to use reflection to read and update the properties and fields.
        //		// The PropertyInfo and FieldInfo values are stored as static, since they will not change during the lifetime of the program
        //		LOCAL oMyRdr AS MySql.Data.MySqlClient.MySqlDataReader
        //		LOCAL oRdrType AS System.Type
        //		oMyRdr := (MySql.Data.MySqlClient.MySqlDataReader) oDataReader
        //		IF oResultSetProperty == NULL_OBJECT
        //			oRdrType := typeof(MySql.Data.MySqlClient.MySqlDataReader)
        //			oResultSetProperty := oRdrType:GetProperty("ResultSet", BindingFlags.Instance|BindingFlags.NonPublic|BindingFlags.FlattenHierarchy)
        //		ENDIF
        //		IF oResultSetProperty != NULL_OBJECT
        //			LOCAL oResultSet AS OBJECT
        //			oResultSet := oResultSetProperty:GetValue(oMyRdr,NULL)
        //			IF oResultSet != NULL_OBJECT
        //				IF oFieldsProperty  == NULL_OBJECT
        //					LOCAL oResultType := oResultSet:GetType() AS System.Type
        //					oFieldsProperty :=  oResultType:GetProperty("Fields", BindingFlags.Instance|BindingFlags.Public|BindingFlags.FlattenHierarchy)
        //				ENDIF
        //				IF oFieldsProperty != NULL_OBJECT
        //					LOCAL aFields AS OBJECT[]
        //					aFields := oFieldsProperty:GetValue(oResultSet,NULL)
        //					FOREACH oField AS OBJECT IN aFields
        //						LOCAL iLen AS LONG
        //						IF oFlagsProperty == NULL_OBJECT
        //							LOCAL oFieldType := oField:GetType() AS System.Type
        //							oFlagsProperty := oFieldType:GetProperty("Flags", BindingFlags.Instance|BindingFlags.Public|BindingFlags.FlattenHierarchy)
        //						ENDIF
        //						IF oLengthField == NULL_OBJECT
        //							LOCAL oFieldType := oField:GetType() AS System.Type
        //							oLengthField := oFieldType:GetField("ColumnLength", BindingFlags.Instance|BindingFlags.Public|BindingFlags.FlattenHierarchy)
        //						ENDIF
        //						IF oFlagsProperty != NULL_OBJECT
        //							LOCAL nFlags AS INT
        //							// Flags is a bitmap :
        //							//    internal enum ColumnFlags
        //							//    {
        //							//        AUTO_INCREMENT = 0x200,
        //							//        BINARY = 0x80,
        //							//        BLOB = 0x10,
        //							//        ENUM = 0x100,
        //							//        MULTIPLE_KEY = 8,
        //							//        NOT_NULL = 1,
        //							//        NUMBER = 0x8000,
        //							//        PRIMARY_KEY = 2,
        //							//        SET = 0x800,
        //							//        TIMESTAMP = 0x400,
        //							//        UNIQUE_KEY = 4,
        //							//        UNSIGNED = 0x20,
        //							//        ZERO_FILL = 0x40
        //							//    }
        //							//}
        //							// We remove the PRIMARY_KEY, UNIQUE_KEY , MULTIPLE_KEY and NOT_NULL flags here
        //							nFlags := (INT) oFlagsProperty:GetValue(oField)
        //							nFlags &= ~15		// 1 + 2 + 4 + 8
        //							IF (nFlags & 0x10) == 0x10		// Binary
        //								// Make sure length of field is set correctly
        //								// I have seen examples where the length was -1
        //								IF oLengthField != NULL_OBJECT
        //
        //									iLen := (INT) oLengthField:GetValue(oField)
        //									IF iLen == -1
        //										oLengthField:SetValue(oField, (LONG) 0x7FFFFFFF)
        //									ENDIF
        //								ENDIF
        //							ENDIF
        //
        //							oFlagsProperty:SetValue(oField, nFlags)
        //						ENDIF
        //					NEXT
        //				ENDIF
        //			ENDIF
        //		ENDIF
        //		RETURN




/// <include file="Sql.xml" path="doc/SQLStatement.FreeStmt/*" />
        METHOD FreeStmt( fOption := SQL_CLOSE AS WORD) AS LOGIC
            RETURN SELF:__FreeStmt( fOption )


/// <include file="Sql.xml" path="doc/SQLStatement.MakeErrorInfo/*" />
        METHOD MakeErrorInfo(oObject, symMethod, e)
            SELF:oErrInfo := SQLErrorInfo{  oObject, symMethod, e}
            RETURN SELF:oErrInfo


/// <include file="Sql.xml" path="doc/SQLStatement.Prepare/*" />
        METHOD Prepare()
            LOCAL lRet     := FALSE AS LOGIC
            LOCAL nPar     AS DWORD


            IF SELF:oNetCmd == NULL_OBJECT
                IF !SELF:__AllocStmt()
                    RETURN lRet
                ENDIF
            ENDIF


            TRY
                    SELF:oNetCmd:CommandText := cStatement
                    SELF:oNetCmd:Prepare()
                    FOR nPar := 1 TO ALen(SELF:aParams)
                        LOCAL oPar AS DbParameter
                        LOCAL oOurPar AS SqlParameter
                        oOurPar := aParams[nPar]
                        oPar    := SELF:_CreateDBParameter(oOurPar)
                        oNetCmd:Parameters:Add(oPar)
                    NEXT
                    SELF:oErrInfo:ErrorFlag := FALSE
                lRet := TRUE
            CATCH e AS Exception
                lRet := FALSE
                SELF:MakeErrorInfo(SELF, #Prepare,  e)


            END TRY


            RETURN lRet


/// <include file="Sql.xml" path="doc/SQLStatement._CreateDBParameter/*" />
        METHOD _CreateDBParameter(oPar AS SqlParameter) AS DbParameter STRICT
            LOCAL oDbPar AS DbParameter
            oDbPar := SELF:oConn:_CreateParameter()
            oDbPar:Value := oPar:Value
            IF oPar:IO == SQL_PARAM_INPUT
                oDbPar:Direction := ParameterDirection.Input
            ELSEIF oPar:IO == SQL_PARAM_OUTPUT
                oDbPar:Direction := ParameterDirection.Output
            ELSEIF oPar:IO == SQL_PARAM_INPUT_OUTPUT
                oDbPar:Direction := ParameterDirection.InputOutput
            ELSEIF oPar:IO == 5 // RETURN_VALUE SQL_PARAM_INPUT_OUTPUT
                oDbPar:Direction := ParameterDirection.ReturnValue
            ENDIF
            oDbPar:ParameterName := "Parameter"
            RETURN oDbPar


        #endregion


    #region Todo


/// <include file="Sql.xml" path="doc/SQLStatement.GetStatementOption/*" />
    [Obsolete];
        METHOD GetStatementOption( fOption )
    RETURN NIL


/// <include file="Sql.xml" path="doc/SQLStatement.SetStatementOption/*" />
    [Obsolete];
        METHOD SetStatementOption( fOption, uValue, lUser )
        RETURN TRUE
    #endregion


    #region Internal Methods
 /// <exclude />
    METHOD __AllocStmt() AS LOGIC STRICT
        LOCAL lRet := FALSE AS LOGIC
        TRY
            IF oNetCmd == NULL_OBJECT
                oNetCmd := SELF:oConn:_CreateCommand()
                oDataTable := DataTable{}
                SELF:Connection:__RegisterStmt(SELF)
                lRet := TRUE
            ENDIF
        CATCH e AS Exception
            SELF:__GenerateSQLError( "Beim Ausf�hren eines SQL-Statements ist ein Fehler aufgetreten. " + chr(13) + chr(10)  + chr(13) + chr(10) + e:Message  + chr(13) + chr(10)  + chr(13) + chr(10) + e:StackTrace, #AllocStmt, e )
            lRet := FALSE
        END TRY
        RETURN lRet


 /// <exclude />
    METHOD __FreeParameters()  AS LOGIC
        LOCAL nPar AS DWORD
        LOCAL oPar AS SqlParameter
        IF ! SELF:__FreeStmt(SQL_RESET_PARAMS)
            RETURN FALSE
        ENDIF
        // Destroy 'Our' Parameter objects
        FOR nPar := 1 TO ALen(SELF:aParams)
            IF (IsInstanceOfUsual(aParams[nPar], #SQLParameter))
                oPar := aParams[nPar]
                IF oPar:InternalParam
                    oPar:Destroy()
                ENDIF
            ENDIF
        NEXT
        ASize(SELF:aParams,0)
        IF SELF:oNetCmd != NULL
            SELF:oNetCmd:Parameters:Clear()
        ENDIF
        RETURN TRUE


 /// <exclude />
    METHOD __FreeStmt( nOption AS WORD) AS LOGIC STRICT
        LOCAL lRet     := FALSE AS LOGIC
        IF SELF:oNetCmd != NULL
            TRY
                oNetCmd:Parameters:Clear()
                IF SELF:oDataTable != NULL
                    SELF:oDataTable := NULL
                ENDIF
                oErrInfo:ErrorFlag := FALSE
                IF nOption = SQL_DROP
                    SELF:oConn:__UnregisterStmt( SELF )
                    //SELF:oNetCmd:Dispose()
                    SELF:oNetCmd:= NULL_OBJECT
                ENDIF
                lPrepFlag   := FALSE
                lRet        := TRUE
            CATCH e AS Exception
                SELF:MakeErrorInfo(SELF, #FreeStmt, e)
                lRet := FALSE
            END TRY
        ENDIF
        RETURN lRet


 /// <exclude />
    METHOD __GenerateSQLError( cErrorString AS STRING, symMethod AS SYMBOL, e := NULL AS Exception) AS SQLErrorInfo STRICT
        oErrInfo := SQLErrorInfo{SELF, symMethod, e}
        oErrInfo:ErrorMessage := __CavoStr( __CAVOSTR_SQLCLASS__ODBC_VO ) +      ;
        Symbol2String( ClassName( SELF ) ) +   ;
        ":" + Symbol2String( symMethod ) +    ;
        " " + cErrorString
        oErrInfo:NativeError:= 0
        oErrInfo:SQLState   := __CavoStr( __CAVOSTR_SQLCLASS__GENERAL_ERR )
        oErrInfo:ErrorFlag  := TRUE
        oErrInfo:SubSystem  := __CavoStr( __CAVOSTR_SQLCLASS_SUBSYS )
        oErrInfo:MethodSelf := SELF
        oErrInfo:FuncSym    := symMethod
        oErrInfo:CallFuncSym:= symMethod
        oErrInfo:Severity   := ES_ERROR
        oErrInfo:ReturnCode := SQL_SUCCESS


        RETURN oErrInfo




 /// <exclude />
    [Obsolete];
    PROPERTY __Params AS ARRAY GET SELF:aParams


 /// <exclude />
    [Obsolete];
        METHOD __Reset( ) AS LOGIC STRICT
    RETURN TRUE




 /// <exclude />
    [Obsolete];
        METHOD __SetDefaultStatementOptions() AS LOGIC STRICT
    RETURN TRUE


 /// <exclude />
    METHOD __SetParameters( aNewParams AS ARRAY) AS LOGIC STRICT
        LOCAL nIndex        AS DWORD
        LOCAL nNumParams    AS DWORD
        LOCAL nRetCode      AS INT
        LOCAL uParam		  AS USUAL
        LOCAL oParam		  AS SqlParameter


        IF ( ! SELF:__FreeStmt( SQL_RESET_PARAMS ) )
            RETURN FALSE
        ENDIF


        nNumParams := ALen( aNewParams )
        ASize(SELF:aParams, nNumParams)
        FOR nIndex := 1 UPTO nNumParams
            uParam 	:= aNewParams[nIndex]
            IF IsInstanceOfUsual(uParam, #SqlParameter)
                    oParam := uParam
                // Do not set the 'internalparam' flag
            ELSE
                oParam := SqlParameter{uParam}
                oParam:InternalParam := TRUE
            ENDIF
            SELF:aParams[nIndex] := oParam
            nRetCode := oParam:Bind(SELF, nIndex)


            IF ( nRetCode != SQL_SUCCESS )
                SELF:MakeErrorInfo(SELF, #SetParameters)
                RETURN FALSE
            ENDIF
        NEXT
        SELF:ErrInfo:ErrorFlag := FALSE
        RETURN TRUE


 /// <exclude />
    [Obsolete];
        METHOD __SetScrollOptions( nConcType AS DWORD, nKeySet AS DWORD, lAsync AS LOGIC) AS LOGIC STRICT
        RETURN TRUE
    #endregion
    #region Properties


/// <include file="Sql.xml" path="doc/SQLStatement.Connection/*" />
    PROPERTY Connection AS SQLConnection GET oConn




/// <include file="Sql.xml" path="doc/SQLStatement.CursorType/*" />
    [Obsolete];
    PROPERTY CursorType AS LONG GET 0


/// <include file="Sql.xml" path="doc/SQLStatement.ErrInfo/*" />
    PROPERTY ErrInfo AS SQLErrorInfo GET oErrInfo SET oErrInfo := VALUE


/// <include file="Sql.xml" path="doc/SQLStatement.HyperLabel/*" />
    PROPERTY HyperLabel AS HyperLabel
        GET
            LOCAL oHL       AS HyperLabel
            oHL := HyperLabel{  #Statement,     ;
            cStatement,     ;
            Symbol2String( ClassName( SELF ) )+ ": " + cStatement,  ;
            Symbol2String( ClassName( SELF ) )+ "_" + cStatement }
            RETURN oHL
        END GET
    END PROPERTY


/// <include file="Sql.xml" path="doc/SQLStatement.KeySet/*" />
    [Obsolete];
    PROPERTY KeySet AS LONG GET 0


/// <include file="Sql.xml" path="doc/SQLStatement.NativeSQL/*" />
    PROPERTY NativeSQL AS STRING GET SELF:SQLString


/// <include file="Sql.xml" path="doc/SQLStatement.NumParameters/*" />
    ACCESS NumParameters AS LONG
        SELF:Prepare()
        RETURN SELF:oNetCmd:Parameters:Count


/// <include file="Sql.xml" path="doc/SQLStatement.NumSuccessfulRows/*" />
    PROPERTY NumSuccessfulRows  AS LONG GET SELF:nRows


/// <include file="Sql.xml" path="doc/SQLStatement.Params/*" />
    PROPERTY Params AS ARRAY GET SELF:aParams


/// <include file="Sql.xml" path="doc/SQLStatement.PrepFlag/*" />
    PROPERTY PrepFlag AS LOGIC AUTO


/// <include file="Sql.xml" path="doc/SQLStatement.RecCount/*" />
    PROPERTY RecCount AS LONG GET SELF:NumSuccessfulRows


/// <include file="Sql.xml" path="doc/SQLStatement.RowSet/*" />
    [Obsolete];
    PROPERTY RowSet AS LONG GET 0


/// <include file="Sql.xml" path="doc/SQLStatement.ScrollConcurrency/*" />
    [Obsolete];
    PROPERTY ScrollConcurrency AS LONG GET 0


/// <include file="Sql.xml" path="doc/SQLStatement.SimulateCursor/*" />
    [Obsolete];
    PROPERTY SimulateCursor AS LONG GET 0


/// <include file="Sql.xml" path="doc/SQLStatement.SQLString/*" />
    PROPERTY SQLString AS STRING
        GET
            RETURN cStatement
        END GET


        SET
            LOCAL cRet  AS STRING


            //cRet := SqlDeleteWhiteSpace(value )
            cRet := value
            IF ( !lPrepFlag )
                SELF:cStatement := cRet
            ELSE
                SELF:FreeStmt( SQL_DROP )
                IF SELF:__AllocStmt()
                    SELF:cStatement := cRet
                ENDIF
            ENDIF
            RETURN
        END SET
    END PROPERTY


/// <include file="Sql.xml" path="doc/SQLStatement.StatementHandle/*" />
    PROPERTY StatementHandle AS DbCommand
        GET
            RETURN SELF:oNetCmd
        END GET
        SET
            IF SELF:oNetCmd == NULL
                    SELF:oNetCmd  := VALUE
                RETURN
            ELSE
                SELF:__GenerateSQLError( __CavoStr( __CAVOSTR_SQLCLASS__STMT_NOT_ALLOC ), #StatementHandle , NULL)
            ENDIF
            RETURN
        END SET
    END PROPERTY




/// <include file="Sql.xml" path="doc/SQLStatement.Status/*" />
    PROPERTY Status AS HyperLabel
        GET
            LOCAL   oRet  := NULL  AS HyperLabel


            IF SELF:oErrInfo:ErrorFlag
                oRet := HyperLabel{ oErrInfo:FuncSym,                           ;
                oErrInfo:SQLState,                          ;
                Symbol2String( ClassName( oErrInfo:MethodSelf ) ) + ": " + ;
                oErrInfo:ErrorMessage }
            ENDIF


            RETURN oRet
        END GET
    END PROPERTY
/// <include file="Sql.xml" path="doc/SQLStatement.Table/*" />
    PROPERTY Table AS DataTable GET oDataTable
/// <include file="Sql.xml" path="doc/SQLStatement.Schema/*" />
    PROPERTY Schema AS DataTable GET oSchema


    //// Methode, die Providerabh�ngig die Statementsyntax anpasst.
    //// Dies wird momentan nur f�r ODBC Syntax von Datumsfeldern in Oracle-Statements verwendet, es ist aber eine Anforderung, dass VEWA Statements zuk�nftig automatisch
    //// in die richtige Syntax bringt. Also z.B. ein MYSQL Statement auch in ORACLE richtig ausf�hrt.
    //METHOD AdjustStatement(cStatement AS STRING) AS STRING
    //	LOCAL cRet AS STRING
    //		cRet := cStatement
    //		IF SELF:oConn != NULL
    //			IF SELF:oConn:ProviderType == ProviderType.Oracle .AND. SELF:Connection:Translator == NULL
    //				// Datumswerte aus ODBC-Syntax �bersetzen
    //				// {d '2015-04-17'} -> '17.04.2015'
    //				cRet := oracleDate:Replace(cRet,"'${day}.${month}.${year}'")
    //			ENDIF
    //
    //		ENDIF
    //	RETURN cRet
    //
    //EXPORT STATIC oracleDate := System.Text.RegularExpressions.Regex{"\{d *\'(?<year>[0-9]{4})-(?<month>[0-9]{2})-(?<day>[0-9]{2})\' *\}", System.Text.RegularExpressions.RegexOptions.IgnoreCase} AS System.Text.RegularExpressions.Regex


    #endregion
END CLASS
