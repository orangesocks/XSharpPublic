/// <include file="Gui.xml" path="doc/FixedImage/*" />
CLASS FixedImage INHERIT Control
	PROTECT oImage AS OBJECT


	//PP-030828 Strong typing
 /// <exclude />
	METHOD __SetImage(uResId AS USUAL) AS OBJECT STRICT 
	//PP-030828 Strong typing
	RETURN NULL_OBJECT


/// <include file="Gui.xml" path="doc/FixedImage.Destroy/*" />
METHOD Destroy()  AS USUAL CLIPPER
	
	


	IF (oImage != NULL_OBJECT)
		oImage:Destroy()
		IF !InCollect()
			oImage := NULL_OBJECT
		ENDIF
	ENDIF
	SUPER:Destroy()


	RETURN SELF


/// <include file="Gui.xml" path="doc/FixedImage.ctor/*" />
CONSTRUCTOR(uOwner, uID, uPoint, uDimension, uResID) 
	
	


	IF  (uID IS ResourceID)
		SUPER(uOwner,uID,,,,,FALSE)
	ELSEIF IsLong(uID)
		SUPER(uOwner, uID,	uPoint, uDimension, "Static", , FALSE)


		IF !IsNil(uResID)
			SELF:__SetImage(uResID)
			cWindowName:="#"+LTrim(AsString(uResID:ID))
		ENDIF
	ELSE
		WCError{#Init,#FixedBitmap,__WCSTypeError}:Throw()
	ENDIF


	RETURN 


END CLASS


