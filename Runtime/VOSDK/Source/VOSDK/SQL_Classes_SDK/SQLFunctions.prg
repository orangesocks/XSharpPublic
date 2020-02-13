FUNCTION __SQLMaxStringSize( nValue )
   //  JSP 09/05/2000
   //  STATIC LOCAL nMaxStringSize := 10000    //MAX_LONGVARCHAR  AS DWORD
   STATIC LOCAL nMaxStringSize := 0x1000  AS DWORD  //MAX_LONGVARCHAR   AS DWORD

   IF IsNumeric( nValue )
      nMaxStringSize := nValue
   ENDIF

   RETURN nMaxStringSize

FUNCTION __SQLMaxDisplaySize( nValue )
   STATIC LOCAL nMaxDispSize := 256  AS DWORD

   IF IsNumeric( nValue )
      nMaxDispSize := nValue
   ENDIF

   RETURN nMaxDispSize

FUNCTION __GetSymString( uString AS USUAL ) AS STRING STRICT
   LOCAL nType AS DWORD
   LOCAL cRet  AS STRING

   nType := UsualType( uString )

   SWITCH nType
   CASE SYMBOL
      cRet := Symbol2String( uString )
   CASE STRING
      cRet := uString
   OTHERWISE
      cRet := NULL_STRING
   END SWITCH
   RETURN cRet

FUNCTION __GetStringFromODBCType( ODBCType AS SHORTINT ) AS STRING STRICT
   LOCAL cType     AS STRING

   SWITCH ODBCType
   CASE SQL_INTEGER   
   CASE SQL_SMALLINT  
   CASE SQL_FLOAT     
   CASE SQL_REAL      
   CASE SQL_TINYINT   
   CASE SQL_BIGINT    
   CASE SQL_DOUBLE
      cType := "N"

   CASE SQL_BIT
      cType := "L"

   CASE SQL_DATE
      cType := "D"

   CASE SQL_TIMESTAMP
      cType := "C"

   CASE SQL_NUMERIC 
   CASE SQL_DECIMAL
      cType := "N"

   CASE SQL_LONGVARCHAR 
   CASE SQL_LONGVARBINARY 
   CASE SQL_WLONGVARCHAR
      cType := "M"

   OTHERWISE
      cType := "C"

   END SWITCH

   RETURN cType

FUNCTION __AdjustString( c AS STRING ) AS STRING STRICT
   LOCAL nLen	AS DWORD
   LOCAL nSize	AS DWORD

   nLen  := SLen( c )
   nSize := PszLen( String2Psz( c ) )
   IF nSize < nLen
      c := SubStr3( c, 1, nSize )
   ENDIF
   RETURN c


FUNCTION __CheckHandles( hEnv AS USUAL, hDbc AS USUAL, hStmt AS USUAL ) AS LOGIC STRICT
   LOCAL lRet  AS LOGIC

   IF IsPtr( hEnv ) .AND. IsPtr( hDbc ) .AND. IsPtr( hStmt )
      lRet := TRUE
   ENDIF

   RETURN lRet

FUNCTION DToCSQL( dDate AS DATE ) AS STRING
   LOCAL cSveFormat    AS STRING
   LOCAL cDate         AS STRING

   cSveFormat := GetDateFormat( )
   SetDateFormat( "YYYY-MM-DD" )
   cDate := DToC( dDate )
   SetDateFormat( cSveFormat )
   RETURN cDate

FUNCTION MakeTimeStamp( dDate, nSeconds )
   LOCAL cTimestamp    AS STRING
   LOCAL wHours        AS WORD
   LOCAL wMinutes      AS WORD
   LOCAL cFrac         AS STRING
   LOCAL cTime         AS STRING

   DEFAULT(@dDate, Today( ))
   DEFAULT(@nSeconds, Seconds( ))
   IF nSeconds > 0.0
      cFrac    := LTrim( __Str( Frac( nSeconds ) ) )
      cFrac    := SubStr2( cFrac, At2( ".", cFrac ) + 1 )
      cFrac    := PadR( cFrac, 3, "0" )
      nSeconds := Integer( nSeconds )
   ELSE
      cFrac    := "000"
      nSeconds := 0

   ENDIF


   wHours   := Integer( nSeconds / 3600 )
   nSeconds := Mod( nSeconds, 3600 )
   wMinutes := Integer( nSeconds / 60 )
   nSeconds := Mod( nSeconds, 60 )

   cTime    := StrZero( wHours,   2, 0 ) + ":" + ;
      StrZero( wMinutes, 2, 0 ) + ":" + ;
      StrZero( nSeconds, 2, 0 ) + "." + cFrac

   cTimestamp := DToCSQL( dDate ) + " " + cTime

   RETURN cTimestamp   

FUNCTION  SQL_LEN_DATA_AT_EXEC( nLength AS INT ) AS INT STRICT

   RETURN -nLength + SQL_LEN_DATA_AT_EXEC_OFFSET


FUNCTION __SQLOutputDebug( cMsg AS STRING) AS VOID STRICT
   LOCAL I AS DWORD
    LOCAL cLine AS STRING
    FOR i := 1 TO SLen(cMsg) STEP 200
      cLine := SubStr(cMsg ,I, 200)
      IF I > 1
         cLine := "  .." + cLine
      ENDIF 
      DebOut32( cLine)
    NEXT
   RETURN

FUNCTION SqlSetStmtConcurrency( nNew ) AS INT
   STATIC nValue := __CAVO_SQL_CONCURRENCY AS INT
   LOCAL nResult AS INT
   nResult := nValue
   IF IsNumeric( nNew )
      nValue := nNew
   ENDIF
   RETURN nResult

FUNCTION SqlSetStmtCursorType( nNew ) AS INT
   STATIC nValue := __CAVO_SQL_CURSOR_TYPE AS INT
   LOCAL nResult AS INT
   nResult := nValue
   IF IsNumeric( nNew )
      nValue := nNew
   ENDIF
   RETURN nResult

FUNCTION SqlSetStmtSimulateCursor( nNew ) AS INT
   STATIC nValue := __CAVO_SQL_SIMULATE_CURSOR  AS INT
   LOCAL nResult AS INT
   nResult := nValue
   IF IsNumeric( nNew )
      nValue := nNew
   ENDIF
   RETURN nResult


FUNCTION SqlDeleteWhiteSpace( cString AS STRING ) AS STRING STRICT
   LOCAL cResult AS STRING
   LOCAL pString AS PSZ
   LOCAL pTarget AS PTR
   LOCAL pWalk   AS BYTE PTR
   LOCAL pTWalk  AS BYTE PTR
   LOCAL nSlen   AS DWORD
   LOCAL i       AS DWORD
   LOCAL cChar   AS STRING
   LOCAL lCopy   AS LOGIC
   LOCAL cCloseDelim AS STRING
   LOCAL cDelims     AS STRING
   LOCAL cWhitespace AS STRING

   LOCAL lWhiteSpace AS LOGIC

   lWhiteSpace := FALSE
   lCopy       := FALSE

   cDelims := "'"+e"\""+"["
   //Stripping out CRLF may be dangerous if they used end of line comments...
   cWhitespace := " "+_CHR(9) //+CHR(10)+CHR(13)+CHR(141)     

   nSLen   := SLen(cString)
   pString := StringAlloc(cString)
   pWalk   := PTR(_CAST,pString)
   IF (pWalk == NULL_PTR)
   	SQLThrowOutOfMemoryError()
   ENDIF
   
   pTWalk  := MemAlloc( nSLen+1 )                                 // f�rs zero terminated
   pTarget := PSZ(_CAST,pTWalk)                                   // merken zum freigeben

   FOR i:=1 UPTO nSLen+1
      cChar := Chr(BYTE(pWalk))                              // get character
      IF lCopy                                                   // innerhalb von delimitern wird einfach blind kopiert
         BYTE(pTWalk) := BYTE(pWalk)                             // kopieren
         pWalk  += 1
         pTWalk += 1
         lCopy := ( cChar != cCloseDelim )                       // wenn wir  den schlie�enden delimiter erreicht haben , kopieren aus
      ELSE
         DO CASE
         CASE At2(cChar,cDelims) > 0                          // wir kommen an einen delimitierten STRING
            lCopy := TRUE                                   // kopieren einschalten
            IF cChar == "["                                 //  Sonderfall, asymetrischer delimiter
               cCloseDelim := "]"
            ELSE
               cCloseDelim := cChar
            ENDIF
            BYTE(pTWalk) := BYTE(pWalk)                     // kopieren
            pWalk  += 1
            pTWalk += 1
            lWhiteSpace := FALSE
         CASE !lWhiteSpace .AND. At2(cChar,cWhitespace ) > 0  // erster Whitespace, als Space kopieren !
            BYTE(pTWalk) := Asc(" ")
            pWalk  += 1
            pTWalk += 1
            lWhiteSpace := TRUE
         CASE lWhiteSpace .AND. At2(cChar,cWhitespace ) > 0   // weiter  Whitspaces ignorieren
            pWalk += 1
         OTHERWISE                                            // Normalfall, einfach kopieren
            lWhiteSpace := FALSE
            BYTE(pTWalk) := BYTE(pWalk)                     // kopieren
            pWalk  += 1
            pTWalk += 1
         ENDCASE
      ENDIF
   NEXT
   cResult := Psz2String(pTarget)
   MemFree( pTarget )
   MemFree( pString )
   RETURN cResult



FUNCTION SQLThrowOutOfMemoryError() AS VOID STRICT
	LOCAL oError AS Error
	oError:=Error{}
	oError:SubSystem := __CavoStr( __CAVOSTR_SQLCLASS_SUBSYS )
	oError:Description:="Out of memory"
	Eval(ErrorBlock(),oError)
	RETURN
	
FUNCTION _SLen( c AS STRING ) AS SHORTINT STRICT
   RETURN SHORTINT( _CAST, SLen( c ) )

FUNCTION __GetDataValuePSZ( oSQLColumn AS SQLColumn, oSQLData AS SqlData, lEqual AS LOGIC, lUseIS AS LOGIC )
   LOCAL sValue                AS STRING
   LOCAL cTemp		       AS STRING
   LOCAL sVal                  AS STRING
   LOCAL uData                 AS SqlData_Union
   LOCAL nODBCType             AS SHORTINT
   LOCAL uiLen                 AS DWORD
   LOCAL pTemp                 AS PTR
   LOCAL fTemp                 AS FLOAT
   LOCAL nLow                  AS DWORD
   LOCAL nHigh                 AS LONGINT

   IF  oSQLData:Null
      IF lEqual
         IF lUseIS
            sValue := __CAVOSTR_SQLCLASS__IS_NULL
         ELSE
            sValue := __CAVOSTR_SQLCLASS__EQ_NULL
         ENDIF
      ELSE
         sValue := __CAVOSTR_SQLCLASS__NULL
      ENDIF

      // 		#IFDEF __DEBUG__
      // 			__SQLOutputDebug( "__GetDataValuePSZ( ) for NULL: " + sValue )
      // 		#ENDIF

   ELSE
      nODBCType := oSQLColumn:ODBCType
      IF lEqual
         sValue := __CAVOSTR_SQLCLASS__EQ
      ELSE
         sValue := " "
      ENDIF

      pTemp := oSQLData:ptrValue
      uData := pTemp
      SWITCH nODBCType
      CASE  SQL_SMALLINT

            sValue += LTrim(__Str( uData.siVal ))

      CASE SQL_INTEGER

            sValue += LTrim(__Str( uData.liVal ))

      CASE SQL_REAL

            sValue += LTrim(__Str( uData.fVal ))

      CASE SQL_FLOAT 
      CASE SQL_DOUBLE

            sValue += LTrim(__Str( uData.dVal ))

      CASE SQL_DECIMAL 
      CASE SQL_NUMERIC
         uiLen := oSQLColumn:__FieldSpec:Length

         cTemp := Mem2String( pTemp, uiLen )
         sValue += AllTrim( __AdjustString( cTemp ) )

      CASE SQL_BINARY
         sVal  := Mem2String(pTemp, oSQLData:Length)
         sValue += "'" + sVal + "'"

         #IFDEF __DEBUG__
            __SQLOutputDebug( "__GetDataValuePSZ() for BIN: " + cTemp )
         #ENDIF

      CASE SQL_BIT

        IF uData.bVal > 0x29
            sValue += Chr( uData.bVal )
         ELSE
            sValue += Str( uData.bVal,1,0 )
         ENDIF

      CASE SQL_DATE

         sVal := Mem2String(pTemp, PszLen(pTemp))
         sValue += "{d '" +RTrim(sVal)  + "'}"
         #IFDEF __DEBUG__
            __SQLOutputDebug( "__GetDataValuePSZ( ) for DATE: " + sValue )
         #ENDIF

      CASE SQL_TIMESTAMP

         sVal 	 := Mem2String(pTemp, PszLen(pTemp))
         sValue += "{ts '" + sVal + "'}"

      CASE SQL_TINYINT

        sValue += Str3( uData.bVal, 3, 0 )
         #IFDEF __DEBUG__
            __SQLOutputDebug( "__GetDataValuePSZ( ) for TINYINT: " + sValue )
         #ENDIF

      CASE SQL_BIGINT

         MemCopy( @nLow, pTemp, 4 )
         pTemp := PTR( _CAST, DWORD( _CAST, pTemp ) + 4 )
         MemCopy( @nHigh, pTemp, 4 )

         fTemp := nHigh * ( 2^32 )
         fTemp += nLow
         sValue += __Str( fTemp )

      CASE SQL_LONGVARCHAR 
      CASE SQL_LONGVARBINARY 
      CASE SQL_WLONGVARCHAR
         cTemp  := Space( 10 )
         sValue += "'" + cTemp +"'"

         #IFDEF __DEBUG__
            __SQLOutputDebug( "__GetDataValuePSZ( ) for SQL_LONGVARCHAR: " + sValue )
         #ENDIF

      OTHERWISE
      	uiLen := PszLen( pTemp )
      	IF uiLen > oSQLData:Length
      		uiLen := oSQLData:Length
      	ENDIF
         cTemp := Mem2String(pTemp, uiLen)
         cTemp := StrTran( cTemp, "'" , "''")

         sValue += "'" + Trim( cTemp )+ "'"

      END SWITCH
   ENDIF

   RETURN sValue

FUNCTION SQLType2CType( nODBCType AS SHORTINT ) AS SHORTINT STRICT
	LOCAL nType     AS SHORTINT
	SWITCH nODBCType
	CASE SQL_DATE 
	CASE SQL_TIME 
	CASE SQL_TIMESTAMP 
	CASE SQL_LONGVARCHAR
	CASE SQL_WLONGVARCHAR
	CASE SQL_GUID

      nType := SQL_C_CHAR

   CASE SQL_BINARY
      nType := SQL_C_BINARY

   OTHERWISE
      nType := SQL_C_DEFAULT
   END SWITCH

   RETURN nType

FUNCTION __ODBCType2FSpec( nODBCType AS SHORTINT, nPrecision REF DWORD, nScale REF SHORT ) AS STRING  PASCAL  // dcaton 070206 was nScale REF INT
    IF SqlIsLongType( nODBCType )
        nPrecision := 10
    ELSE
        IF nScale == 0
            IF nODBCType == SQL_FLOAT .OR. nODBCType == SQL_REAL .OR. nODBCType == SQL_DOUBLE
            nScale := SHORTINT( SetDecimal() ) // dcaton 070206 was INT( _CAST, SetDecimal( ) )
            ENDIF
        ENDIF
    ENDIF

    RETURN __GetStringFromODBCType( nODBCType )


UNION SqlData_Union
    MEMBER bVal  AS BYTE
    MEMBER siVal AS SHORTINT
    MEMBER liVal AS LONGINT
    MEMBER fVal  AS REAL4
    MEMBER dVal  AS REAL8

FUNCTION SqlIsBinaryType(nODBCType AS LONG) AS LOGIC
    SWITCH nODBCType
    CASE SQL_LONGVARBINARY
    CASE SQL_VARBINARY
    CASE SQL_BINARY
        RETURN TRUE
    END SWITCH
    RETURN FALSE


FUNCTION SqlIsCharType(nODBCType AS LONG) AS LOGIC
   SWITCH nODBCType
    CASE SQL_LONGVARCHAR
    CASE SQL_WLONGVARCHAR 
    CASE SQL_CHAR
    CASE SQL_VARCHAR
    CASE SQL_WCHAR
    CASE SQL_WVARCHAR
        RETURN TRUE
    END SWITCH
    RETURN FALSE

FUNCTION SqlIsLongType(nODBCType AS LONG) AS LOGIC
   SWITCH nODBCType
   CASE SQL_LONGVARCHAR
   CASE SQL_LONGVARBINARY
   CASE SQL_VARBINARY
   CASE SQL_WLONGVARCHAR   
        RETURN TRUE
    END SWITCH
    RETURN FALSE


