/// <include file="System.xml" path="doc/DbError/*" />
PARTIAL CLASS DbError   INHERIT Error


/// <include file="System.xml" path="doc/DbError.ctor/*" />
CONSTRUCTOR( oOriginator, symMethod, wErrorType, oHLErrorMessage, uMisc1, uMisc2 )  
    //RvdH 080609 Added call to super:Init to correctly fill the callstack
    SUPER()
	SubSystem := "Database"
	IF oOriginator# NIL
		MethodSelf := oOriginator
	ENDIF
	IF symMethod# NIL
		FuncSym := symMethod
		CallFuncSym := symMethod
	ENDIF
	IF wErrorType# NIL
		GenCode := wErrorType
	ELSE
		GenCode := EG_NOTABLE
	ENDIF
	IF oHLErrorMessage# NIL
		IF IsObject(oHLErrorMessage) .and. __Usual.ToObject(oHLErrorMessage) IS HyperLabel 
			Description := ((HyperLabel)oHLErrorMessage):Description
		ELSE
			Description := oHLErrorMessage
		ENDIF
	ENDIF
	IF GenCode = EG_ARG .OR. uMisc1 != NIL .OR. uMisc2 != NIL
		Args := { uMisc1 }
		Arg := uMisc2
	ENDIF
	Severity := ES_ERROR
	RETURN 


#ifdef __XSHARP_RT__
/// <include file="System.xml" path="doc/DbError.Throw/*" />
METHOD Throw() AS VOID STRICT
#else
/// <include file="System.xml" path="doc/DbError.Throw/*" />
METHOD Throw()
#endif


	IF CanBreak()
		BREAK SELF
	ENDIF
	RETURN Eval(ErrorBlock(), SELF)
END CLASS


