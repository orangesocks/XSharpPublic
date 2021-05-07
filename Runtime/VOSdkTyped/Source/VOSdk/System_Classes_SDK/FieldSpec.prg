//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
#pragma options ("enforceself", on)
/// <include file="System.xml" path="doc/FieldSpec/*" />
[XSharp.Internal.TypesChanged];
CLASS FieldSpec
	// Class that contains a number of properties of database fields and form fields ( controls )
	// HyperLabel   describes the FieldSpec
	// Status           describes the current status of the field or control associated with the FieldSpec,
	//                      after a validation ( NIL if the validation passed )
	// Type             the underlying storage type ( number, string, logic, date, memo )
	// Length           the field length
	// Decimals     the number of decimals
	// MinLength        the minimum number of characters ( for example, a STATE field may be defined with
	//                      Length and MinLength of 2, while a PASSWORD may have a Length of 10 and a MinLength of 4
	// Min, Max     the data range
	// Validation       codeblock. Also note that a FieldSpec subclass may be given a Validation method, which overrides
	//                      the codeblock.
	// Picture          formatting string
	// Diagnostics  HyperLabels for each of the validation rules. Note that a HyperLabel contains not only
	//                      a diagnostic message, but also a help context to provide for context sensitive help
	//                      after a validation failure.
	PROTECT oHyperLabel     AS HyperLabel
	PROTECT oHLStatus 	    AS HyperLabel
	PROTECT wType 			AS DWORD        
	PROTECT cType 			AS STRING
	PROTECT lNumeric 		AS LOGIC
	PROTECT oHLType 		AS HyperLabel
	PROTECT wLength 		AS DWORD		
	PROTECT oHLLength 	    AS HyperLabel
	PROTECT wDecimals 	    AS DWORD         
	PROTECT lRequired 	    AS LOGIC
	PROTECT oHLRequired     AS HyperLabel
	PROTECT wMinLength 	    AS DWORD
	PROTECT oHLMinLength    AS HyperLabel
	PROTECT uMin, uMax      AS USUAL
	PROTECT oHLRange 		AS HyperLabel
	PROTECT cbValidation    AS USUAL // AS CODEBLOCK
	PROTECT oHLValidation   AS HyperLabel
	PROTECT cPicture 		AS STRING
	PROTECT lNullable AS LOGIC


 /// <exclude />
	METHOD __GetHLRange  AS VOID STRICT 
	    IF SELF:oHLRange == NULL_OBJECT
		    IF IsNil(SELF:uMin) .AND. IsNil(SELF:uMax)
			    RETURN
		    ENDIF
		    IF IsNil(SELF:uMin) .AND. !IsNil(SELF:uMax)
			    SELF:oHLRange := HyperLabel{ #FieldSpecRange, ,  ;
				    VO_Sprintf(__CAVOSTR_DBFCLASS_INVALIDMAX,oHyperLabel:Name,AsString( SELF:uMax ) ) }
		    ENDIF
		    IF !IsNil(SELF:uMin) .AND. IsNil(SELF:uMax)
			    SELF:oHLRange := HyperLabel{ #FieldSpecRange, ,  ;
				    VO_Sprintf(__CAVOSTR_DBFCLASS_INVALIDMIN,oHyperLabel:Name,AsString( SELF:uMin ) ) }
		    ENDIF
		    IF !IsNil(SELF:uMin) .AND. !IsNil(SELF:uMax)
			    SELF:oHLRange := HyperLabel{ #FieldSpecRange, ,  ;
				    VO_Sprintf(__CAVOSTR_DBFCLASS_INVALIDRANGE,oHyperLabel:Name,AsString(SELF:uMin),AsString( SELF:uMax )) } 
		    ENDIF
	    ENDIF
	    RETURN
    
    
/// <include file="System.xml" path="doc/FieldSpec.AsString/*" />
METHOD AsString( ) AS STRING STRICT                             
	RETURN oHyperLabel:Caption


/// <include file="System.xml" path="doc/FieldSpec.Decimals/*" />
ACCESS Decimals   AS DWORD                              
	// Returns the number of decimals
	RETURN SELF:wDecimals




/// <include file="System.xml" path="doc/FieldSpec.Decimals/*" />
ASSIGN Decimals (uDecimals AS DWORD )                    
	SELF:wDecimals := uDecimals
	RETURN 


/// <include file="System.xml" path="doc/FieldSpec.HyperLabel/*" />
ACCESS HyperLabel AS HyperLabel                            
	// Returns the HyperLabel object
	RETURN oHyperLabel


/// <include file="System.xml" path="doc/FieldSpec.ctor/*" />
CONSTRUCTOR( oHLName AS STRING, uType:= NIL AS USUAL, uLength := 0 AS DWORD, uDecimals := 0 AS DWORD) 
    SELF(HyperLabel{oHLName}, uType, uLength, uDecimals)
    
    
/// <include file="System.xml" path="doc/FieldSpec.ctor/*" />
CONSTRUCTOR( oHLName AS HyperLabel, uType:= NIL AS USUAL, uLength := 0 AS DWORD, uDecimals := 0 AS DWORD) 
	// Instantiation parameters for FieldSpec
	// oHLName      ( required ) HyperLabel
	// uType            ( required ) the type, either as one of the data type keywords (STRING, INT, LOGIC, etc.)
	//                      or as a 1-char string ("N","C","D","L","M")
	// uLength          ( required for some data types, not for LOGIC for example )
	// uDecimals        ( optional ) defaults to 0
	oHyperLabel := oHLName


	IF IsString( uType )
		cType := Upper(uType)
        SWITCH cType
		CASE "C"
        CASE "M"
			wType := __UsualType.String
		CASE "N"
        CASE "F"
			wType := __UsualType.Float
			lNumeric:=TRUE
			cType := "N"
		CASE "L"
			wType := __UsualType.Logic
		CASE "D"
			wType := __UsualType.Date
		CASE "O"
			wType := __UsualType.Object
		CASE "X"
			wType := TYPE_MULTIMEDIA
		CASE "Y"
			wType := __UsualType.Currency
		CASE "I"
			wType := __UsualType.Long
		CASE "T"
			wType := __UsualType.DateTime
		OTHERWISE
			cType := ""
			DbError{ SELF, #Init, EG_ARG, __CavoStr(__CAVOSTR_DBFCLASS_BADTYPE), uType, "uType" }:Throw()
		END SWITCH
	ELSEIF IsNumeric(uType)
		wType := uType
        SWITCH wType
        CASE __UsualType.String
			cType := "C"
		CASE __UsualType.Logic
			cType := "L"
		CASE __UsualType.Date
			cType := "D"
        CASE __UsualType.Long
		CASE __UsualType.Float
		CASE __UsualType.Byte
		CASE __UsualType.ShortInt
		CASE __UsualType.Word
		CASE __UsualType.DWord
		CASE __UsualType.Real4
		CASE __UsualType.Real8        
			cType := "N"
            lNumeric := TRUE
		CASE __UsualType.Currency
			cType := "Y"
            lNumeric := TRUE
        CASE __UsualType.DateTime
            cType := "T"
		CASE TYPE_MULTIMEDIA
			cType := "X"
		OTHERWISE
			wType := 0
			DbError{ SELF, #Init, EG_ARG, __CavoStr(__CAVOSTR_DBFCLASS_BADTYPE), uType, "uType" }:Throw()
		END SWITCH
    ELSE
       DbError{ SELF, #Init, EG_ARG, __CavoStr(__CAVOSTR_DBFCLASS_BADTYPE), uType, "uType" }:Throw()
    ENDIF


	SELF:wLength := uLength
	SELF:wDecimals := uDecimals
	RETURN 




/// <include file="System.xml" path="doc/FieldSpec.Length/*" />
ACCESS Length AS DWORD                                  
	// Returns the length of the field
	RETURN SELF:wLength


/// <include file="System.xml" path="doc/FieldSpec.Maximum/*" />
ACCESS Maximum   AS USUAL                               
	RETURN SELF:uMax


/// <include file="System.xml" path="doc/FieldSpec.Minimum/*" />
ACCESS Minimum   AS USUAL                               
	RETURN SELF:uMin


/// <include file="System.xml" path="doc/FieldSpec.MinLength/*" />
ACCESS MinLength AS DWORD                               
	RETURN wMinLength


/// <include file="System.xml" path="doc/FieldSpec.Nullable/*" />
ACCESS Nullable  AS LOGIC
	RETURN SELF:lNullable


/// <include file="System.xml" path="doc/FieldSpec.Nullable/*" />
ASSIGN Nullable( lNew AS LOGIC)                         
	SELF:lNullable := lNew


/// <include file="System.xml" path="doc/FieldSpec.PerformValidations/*" />
METHOD PerformValidations(uValue AS USUAL)  AS LOGIC
	// Performs all the validations on the specified value: required field, data type compliance, range, etc.
	// Returns a LOGIC indicating whether the validation succeeded.
	// Also sets the STATUS to the appropriate HyperLabel for the validation rule that failed,
	// sets it to NIL if it succeeded
	//
	LOCAL cValue      AS STRING
	LOCAL wLen, wDecLen:=0, i  AS DWORD
	LOCAL cDecSep, cTmp   AS STRING


	SELF:oHLStatus := NULL_OBJECT


	IF SELF:lNullable .AND. IsNil(uValue)
		RETURN .T. 
	ENDIF


	IF (IsString(uValue) .AND. Empty(AllTrim(uValue))) .OR. ;  
		(IsDate(uValue) .AND. uValue == NULL_DATE)         
		// Check required
		IF lRequired
			IF SELF:oHLRequired == NULL_OBJECT
				SELF:oHLRequired := HyperLabel{ #FieldSpecRequired, , VO_Sprintf(__CAVOSTR_DBFCLASS_REQUIRED,oHyperLabel:Name) }
			ENDIF


			SELF:oHLStatus := SELF:oHLRequired
			RETURN FALSE
		ENDIF
	ELSE
		IF IsNil(uValue) .AND. SELF:wType == OBJECT
			RETURN .T. 
		ENDIF


		// Check data type (no conversions here!)
		IF !(UsualType(uValue) == wType .OR. (lNumeric .AND. IsNumeric(uValue)) .OR. ((wType == TYPE_MULTIMEDIA) .AND. IsString(uValue)))
			IF SELF:oHLType == NULL_OBJECT
				SELF:oHLType := HyperLabel{ #FieldSpecType, , VO_Sprintf(__CAVOSTR_DBFCLASS_INVALIDTYPE,oHyperLabel:Name,TypeAsString(wType)) }
			ENDIF
			SELF:oHLStatus := SELF:oHLType


			RETURN FALSE
		ENDIF


		// Check max and min length
		IF lNumeric
			IF IsNil(uValue)
				cValue := NULL_STRING
			ELSE
				cValue := AllTrim(AsString(uValue))
			ENDIF


			IF !Empty(SELF:cPicture)
				cDecSep := Chr(SetDecimalSep())


				// NOTE: picture templates need to be in U.S. format for output
				// to be correct when set from control panel.
				IF At2(".", SELF:cPicture) > 0
					// get decimal locations according to picture
					cTmp := SubStr2(SELF:cPicture, At2(".", SELF:cPicture) + 1)


					wLen := SLen(cTmp)
                    i := 0
                    DO WHILE i < wLen
						IF Char.IsDigit( cTmp, (INT) i ) 
							wDecLen++
						ENDIF
						i++
					ENDDO	


					// substring cValue based on control panel's decimal sep.
					cValue := SubStr3(cValue, 1, At2(cDecSep, cValue) + wDecLen)


				ENDIF
			ENDIF
		ELSEIF wType == STRING
			cValue := uValue
		ENDIF


		wLen := SLen(cValue)


		IF wLen > SELF:wLength .AND. !(cType == "M" ) 


			IF SELF:oHLLength == NULL_OBJECT
				SELF:oHLLength := HyperLabel{ #FieldSpecLength, , VO_Sprintf(__CAVOSTR_DBFCLASS_INVALIDLENGTH,oHyperLabel:Name,Str( SELF:wLength ) ) }
			ENDIF


			SELF:oHLStatus := SELF:oHLLength
			RETURN FALSE


		ELSEIF wType == STRING .AND. wLen < wMinLength
			IF  SELF:oHLMinLength = NULL_OBJECT
				SELF:oHLMinLength := HyperLabel{ #FieldSpecMinLength, ,  ;
					VO_Sprintf(__CAVOSTR_DBFCLASS_INVALIDMINLENGTH,oHyperLabel:Name,Str( wMinLength ) ) }
			ENDIF
			SELF:oHLStatus := SELF:oHLMinLength
			RETURN FALSE
		ENDIF


		// Check range
		IF !IsNil(SELF:uMin) .AND. uValue < SELF:uMin
			IF SELF:oHLRange == NULL_OBJECT
				SELF:__GetHLRange( )
			ENDIF
			SELF:oHLStatus := SELF:oHLRange
			RETURN FALSE
		ENDIF


		IF !IsNil(SELF:uMax) .AND. uValue > SELF:uMax
			IF SELF:oHLRange == NULL_OBJECT
				SELF:__GetHLRange( )
			ENDIF
			SELF:oHLStatus := SELF:oHLRange


			RETURN FALSE
		ENDIF
	ENDIF


	// Check validation method or codeblock
	IF !SELF:Validate(uValue)
		IF SELF:oHLStatus == NULL_OBJECT
			IF SELF:oHLValidation == NULL_OBJECT
				SELF:oHLValidation := HyperLabel{ #FieldSpecValidate, , VO_Sprintf(__CAVOSTR_DBFCLASS_INVALIDVALUE,oHyperLabel:Name) }
			ENDIF
			SELF:oHLStatus := SELF:oHLValidation      // Fill in status if not done by client code
		ENDIF


		RETURN FALSE
	ENDIF


	RETURN TRUE


/// <include file="System.xml" path="doc/FieldSpec.Picture/*" />
ACCESS Picture  AS STRING                                
	RETURN cPicture


/// <include file="System.xml" path="doc/FieldSpec.Picture/*" />
ASSIGN Picture( cNewPicture AS STRING)                   
	//ASSERT _DYNCHECKERRORBOX( )
	cPicture := cNewPicture


/// <include file="System.xml" path="doc/FieldSpec.Required/*" />
ACCESS Required  AS LOGIC                               
	RETURN lRequired


/// <include file="System.xml" path="doc/FieldSpec.SetLength/*" />
METHOD SetLength( w  AS DWORD, oHL := NULL AS HyperLabel )  AS VOID                      
	// The length is set through the instantiation parameter, and is not normally changed later
	// This method does allow changing the length and, more usefully,
	// the HyperLabel diagnostic for the length check
	// Both parameters are optional, if one is not provided the corresponding value is not changed
    SELF:wLength := w
	IF oHL # NULL_OBJECT
		SELF:oHLLength := oHL
	ENDIF
	RETURN 


/// <include file="System.xml" path="doc/FieldSpec.SetMinLength/*" />
METHOD SetMinLength( w  AS DWORD, oHL := NULL AS HyperLabel) AS VOID                  
	// This method is used to set the minimum length,
	// and the HyperLabel diagnostic for the minlength check (applies to string data only)
	// Both parameters are optional, if one is not provided the corresponding value is not changed
	wMinLength := w
	IF oHL != NULL_OBJECT
		SELF:oHLMinLength := oHL
	ENDIF
	RETURN 


/// <include file="System.xml" path="doc/FieldSpec.SetRange/*" />
METHOD SetRange( uMinimum AS USUAL, uMaximum AS USUAL, oHL := NULL AS HyperLabel ) AS VOID   
	// Sets the range and the HyperLabel for the range check error message
	// All parameters are optional, if one is not provided the corresponding value is not changed
	IF !IsNil(uMinimum)
		SELF:uMin := uMinimum
	ENDIF
	IF !IsNil(uMaximum)
		SELF:uMax := uMaximum
	ENDIF
	IF oHL != NULL_OBJECT
		SELF:oHLRange := oHL
	ENDIF
	RETURN 


/// <include file="System.xml" path="doc/FieldSpec.SetRequired/*" />
METHOD SetRequired( lReq := TRUE AS LOGIC, oHL := NULL AS HyperLabel) AS VOID                   
	// This method is used to specify whether this is a required field,
	// and the HyperLabel diagnostic for the required check
	// Both parameters are optional; if lReq is omitted TRUE is assumed;
	// if the HyperLabel is not provided the current value is not changed
	lRequired := lReq
	IF oHL != NULL_OBJECT
		SELF:oHLRequired := oHL
	ENDIF
	RETURN 


/// <include file="System.xml" path="doc/FieldSpec.SetType/*" />
METHOD SetType( uType AS USUAL, oHL := NULL AS HyperLabel) AS VOID                  
	// The storage type is normally set as an instantiation parameter and is not changed later.
	// This method does allow the storage type to be changed and, more usefully,
	// the HyperLabel diagnostic for the storage type check
	// Both parameters are optional, if one is not provided the corresponding value is not changed
	IF !IsNil(uType)
		IF IsString( uType )
			cType := Upper(uType)
			IF cType == "C" .OR. cType == "M"
				wType := STRING
			ELSEIF cType == "N" .OR. cType == "F"
				wType := FLOAT
				lNumeric:=TRUE
				cType := "N"
			ELSEIF cType == "L"
				wType := LOGIC
			ELSEIF cType == "D"
				wType := DATE


				// SABR01 12/28/95
				// O is an OLE object
			ELSEIF cType == "O"
				wType := OBJECT


				// Ansgar 7/9/97 added Bitmap
			ELSEIF cType == "B"
				wType := TYPE_MULTIMEDIA


			ELSE
				cType := ""
				DbError{ SELF, #SetType, EG_ARG, __CavoStr(__CAVOSTR_DBFCLASS_BADTYPE), uType, "uType" }:Throw()
			ENDIF
		ELSE
			wType := uType
			IF wType = STRING
				cType := "C"
			ELSEIF wType = LOGIC
				cType := "L"
			ELSEIF wType = DATE
				cType := "D"
			ELSEIF lNumeric:=   wType=INT   .OR.; // also Long
				wType=FLOAT .OR.;
				wType=BYTE  .OR.;
				wType=SHORTINT .OR.;
				wType=WORD  .OR.;
				wType=DWORD .OR.;
				wType=REAL4 .OR.;
				wType=REAL8
				cType := "N"
			ELSEIF (wType == TYPE_MULTIMEDIA)
				cType := "B"


			ELSE
				wType := 0
				DbError{ SELF, #Init, EG_ARG, __CavoStr(__CAVOSTR_DBFCLASS_BADTYPE), uType, "uType" }:Throw()
			ENDIF
		ENDIF
	ENDIF
	IF oHL != NULL_OBJECT
		SELF:oHLType := oHL
	ENDIF
	RETURN 




/// <include file="System.xml" path="doc/FieldSpec.SetValidation/*" />
METHOD SetValidation( cb AS USUAL, oHL := NULL_OBJECT AS HyperLabel) AS VOID                  
	// Used to set the validation codeblock and its corresponding HyperLabel diagnostic
	// The validation rule may be specified as a codeblock or a string
	// Both parameters are optional, if one is not provided the corresponding value is not changed
	IF !IsNil(cb)
		IF __CanEval( cb )
			cbValidation := cb
		ELSEIF IsString( cb )
			cbValidation := &( "{ | |" + cb + " }" )
		ELSE
			DbError{ SELF, #SetValidation, EG_ARG, __CavoStr(__CAVOSTR_DBFCLASS_BADCB), cb, "cb" }:Throw()
		ENDIF
	ENDIF
	IF oHL != NULL_OBJECT
		SELF:oHLValidation := oHL
	ENDIF
	RETURN 




/// <include file="System.xml" path="doc/FieldSpec.Status/*" />
ACCESS Status  AS HyperLabel                                 
	// Returns the Status HyperLabel object; NIL if status is OK. Status reflects the
	// most recently made validation ( see METHOD PerformValidations ).
	RETURN SELF:oHLStatus


/// <include file="System.xml" path="doc/FieldSpec.Status/*" />
ASSIGN Status (oHL AS HyperLabel)
    SELF:oHLStatus := oHL
	RETURN 


/// <include file="System.xml" path="doc/FieldSpec.Transform/*" />
METHOD Transform( uValue AS USUAL) AS STRING                     
	// Format the value into a string according to the picture clause
	// should default to windows formats


	LOCAL cResult   AS STRING
	LOCAL cTemp     AS STRING   
	LOCAL lScience  AS LOGIC    
	LOCAL lZero :=FALSE   AS LOGIC    


	IF cPicture == NULL_STRING
		IF lNumeric
			IF SELF:wDecimals=0
				cResult := Transform(uValue,Replicate("9",SELF:wLength))
			ELSE
				cResult := Transform(uValue,Replicate("9",SELF:wLength-SELF:wDecimals-1)+"."+Replicate("9",SELF:wDecimals))
			ENDIF


			IF SubStr3(cResult,1,1) == "*"
				lScience := SetScience(TRUE)
				cTemp := AsString(uValue)
				SetScience(lScience)
				IF SLen(cTemp)>SELF:wLength //if<overall length, trim it.
					cTemp:=AllTrim(StrTran(cTemp,Chr(0)))
					IF SLen(cTemp)>SELF:wLength
						IF lZero //Still too long
							cResult:=StrTran(cResult,"0","*")
						ENDIF
					ELSE
						// PadL() not available yet
						//            cResult:=PadL(cTemp,wLength)
						IF SLen(cTemp) <= SELF:wLength
							cResult := Left(cTemp, SELF:wLength)
						ELSE
							cResult := Space(SELF:wLength - SLen(cTemp))+cTemp
						ENDIF
					ENDIF
				ELSE
					cResult:=cTemp
				ENDIF
			ENDIF
		ELSEIF uValue==NIL .AND. wType==STRING 
			cResult := NULL_STRING             
		ELSE
			cResult := AsString(uValue)
		ENDIF
	ELSE
		cResult := Transform(uValue,cPicture)
	ENDIF


	RETURN cResult




/// <include file="System.xml" path="doc/FieldSpec.UsualType/*" />
ACCESS UsualType  AS DWORD                              
	// Returns the storage type as a keyword (INT, STRING, etc.)
	RETURN wType


/// <include file="System.xml" path="doc/FieldSpec.Val/*" />
METHOD Val( cString AS STRING) AS USUAL                          
	// Converts a string to the appropriate data type


	LOCAL xRet  := NIL AS USUAL
	LOCAL cType AS STRING


	IF lNumeric
		IF SELF:lNullable
			cType := "N0"
		ELSE
			cType := "N"
		ENDIF
		xRet := Unformat( cString, cPicture, cType)


	ELSEIF wType = DATE
		IF SELF:lNullable
			cType := "D0"
		ELSE
			cType := "D"
		ENDIF
		xRet := Unformat( cString, cPicture, cType)


	ELSEIF wType = LOGIC
		IF SELF:lNullable
			cType := "L0"
		ELSE
			cType := "L"
		ENDIF
		xRet := Unformat( cString, cPicture, cType)


	ELSEIF wType = STRING
		IF SELF:lNullable
			cType := "C0"
		ELSE
			cType := "C"
		ENDIF
		xRet := Unformat( cString, cPicture, cType)
	ENDIF


	RETURN xRet


/// <include file="System.xml" path="doc/FieldSpec.Validate/*" />
METHOD Validate( uValue AS USUAL, arg := NIL AS USUAL) AS LOGIC                       


	RETURN cbValidation = NIL .OR. Eval( cbValidation, uValue, arg )


/// <include file="System.xml" path="doc/FieldSpec.Validation/*" />
ACCESS Validation  AS USUAL                             
	RETURN cbValidation


/// <include file="System.xml" path="doc/FieldSpec.ValType/*" />
ACCESS ValType AS STRING                                 
	// Returns the storage type as a keyword (INT, STRING, etc.)
	RETURN cType




/// <include file="System.xml" path="doc/FieldSpec.MinLengthHL/*" />
ACCESS MinLengthHL AS HyperLabel
	RETURN SELF:oHLMinLength


/// <include file="System.xml" path="doc/FieldSpec.RangeHL/*" />
ACCESS RangeHL AS HyperLabel
	RETURN SELF:oHLRange


/// <include file="System.xml" path="doc/FieldSpec.RequiredHL/*" />
ACCESS RequiredHL AS HyperLabel
	RETURN SELF:oHLRequired


/// <include file="System.xml" path="doc/FieldSpec.ValidationHL/*" />
ACCESS ValidationHL AS HyperLabel
	RETURN SELF:oHLValidation


END CLASS


/// <include file="System.xml" path="doc/DateFS/*" />
PARTIAL CLASS DateFS INHERIT FieldSpec


/// <include file="System.xml" path="doc/DateFS.ctor/*" />
CONSTRUCTOR( oHLName := "__DateFS" AS STRING)                      
    SELF(HyperLabel{oHLName})
    
    
/// <include file="System.xml" path="doc/DateFS.ctor/*" />
CONSTRUCTOR( oHLName AS HyperLabel)                      
	SUPER(oHLName,"D",8,0)
	RETURN 
END CLASS


/// <include file="System.xml" path="doc/IntegerFS/*" />
PARTIAL CLASS IntegerFS INHERIT FieldSpec
/// <include file="System.xml" path="doc/IntegerFS.ctor/*" />
CONSTRUCTOR( oHLName := "__MoneyFS" AS STRING, uLength := 10 AS DWORD)   
    SELF(HyperLabel{oHLName}, uLength)


/// <include file="System.xml" path="doc/IntegerFS.ctor/*" />
CONSTRUCTOR( oHLName AS HyperLabel, uLength := 10 AS DWORD)   
	SUPER(oHLName,"N",uLength,0)
	SELF:Picture := " 9,999"
	RETURN 
END CLASS


/// <include file="System.xml" path="doc/LogicFS/*" />
PARTIAL CLASS LogicFS INHERIT FieldSpec


/// <include file="System.xml" path="doc/LogicFS.ctor/*" />
CONSTRUCTOR(oHLName := "__LogicFS" AS STRING)   
    SELF(HyperLabel{oHLName})
    
    
/// <include file="System.xml" path="doc/LogicFS.ctor/*" />
CONSTRUCTOR(oHLName AS HyperLabel)   
	SUPER(oHLName,"L",1,0)
	RETURN 
END CLASS


/// <include file="System.xml" path="doc/MoneyFS/*" />
PARTIAL CLASS MoneyFS INHERIT NumberFS


/// <include file="System.xml" path="doc/MoneyFS.ctor/*" />
CONSTRUCTOR( oHLName := "__MoneyFS" AS STRING, uLength := 12 AS DWORD, uDecimals := 2 AS DWORD)   
	SUPER(oHLName,uLength,uDecimals)




/// <include file="System.xml" path="doc/MoneyFS.ctor/*" />
CONSTRUCTOR( oHLName AS HyperLabel, uLength := 12 AS DWORD, uDecimals := 2 AS DWORD)   
	SUPER(oHLName,uLength,uDecimals)




END CLASS


/// <include file="System.xml" path="doc/NumberFS/*" />
PARTIAL CLASS NumberFS INHERIT FieldSpec


/// <include file="System.xml" path="doc/NumberFS.ctor/*" />
CONSTRUCTOR(oHLName := "__NumberFS" AS STRING, uLength := 12 AS DWORD, uDecimals := 2 AS DWORD)    
    SELF( HyperLabel{oHLName}, uLength, uDecimals)


/// <include file="System.xml" path="doc/NumberFS.ctor/*" />
CONSTRUCTOR(oHLName AS HyperLabel, uLength := 12 AS DWORD, uDecimals := 2 AS DWORD)    
	SUPER(oHLName,"N",uLength,uDecimals)


	IF  uDecimals > 0
		SELF:Picture := Replicate("9",uLength-uDecimals-1) + "." +;
			Replicate("9",uDecimals)
	ELSE
		SELF:Picture := Replicate("9",uLength)
	ENDIF
	RETURN 


END CLASS


/// <include file="System.xml" path="doc/StringFS/*" />
PARTIAL CLASS StringFS INHERIT FieldSpec


/// <include file="System.xml" path="doc/StringFS.ctor/*" />
CONSTRUCTOR( oHLName := "__StringFS" AS STRING, uLength := 10 AS DWORD)              
	SELF(HyperLabel{oHLName},uLength)
	RETURN 


/// <include file="System.xml" path="doc/StringFS.ctor/*" />
CONSTRUCTOR( oHLName AS HyperLabel, uLength := 10 AS DWORD)              
	SUPER(oHLName,"C",uLength,0)
	RETURN 


END CLASS


INTERNAL FUNCTION TypeAsString(wType AS DWORD) AS STRING
	IF wType = STRING
		RETURN "string"
	ELSEIF wType=DATE
		RETURN "date"
	ELSEIF wType=LOGIC
		RETURN "logic"
	ELSEIF wType=FLOAT
		RETURN "number"
	ELSE
		RETURN "integer"
	ENDIF


