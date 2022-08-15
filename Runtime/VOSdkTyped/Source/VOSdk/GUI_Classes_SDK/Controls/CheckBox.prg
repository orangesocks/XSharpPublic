/// <include file="Gui.xml" path="doc/CheckBox/*" />
[XSharp.Internal.TypesChanged];
CLASS CheckBox INHERIT Button
	PROTECT lSavedChecked AS LOGIC

    PROPERTY ControlType AS ControlType GET ControlType.CheckBox

/// <include file="Gui.xml" path="doc/CheckBox.ctor/*" />
	CONSTRUCTOR( oOwner, xID, oPoint, oDimension, cText, kStyle)
		SUPER(oOwner, xID, oPoint, oDimension, cText, kStyle, TRUE)

		IF !IsInstanceOfUsual(xID, #ResourceID) .AND. IsNil(kStyle)
			SELF:SetStyle(BS_AUTOCHECKBOX)
		ENDIF

		RETURN

	METHOD OnHandleCreated(o AS OBJECT, e AS EventArgs) AS VOID
		SUPER:OnHandleCreated(o, e)
		GuiWin32.SetWindowLong(SELF:hWnd, GWL_STYLE, dwStyle)
		RETURN


	ACCESS __CheckBox AS IVOCheckBox
		RETURN (IVOCheckBox ) oCtrl

	METHOD __SetImage(oNewImage AS VObject)  AS LOGIC
		IF oNewImage IS ButtonImageList
			LOCAL oBIL AS ButtonImageList
			oImage := oNewImage
			oBIL := (ButtonImageList) oNewImage
			SELF:__CheckBox:Image := oBIL:Image:__Image
            SELF:__CheckBox:Text := ""
			SELF:__CheckBox:FlatStyle := System.Windows.Forms.FlatStyle.Flat
			RETURN TRUE
		ELSEIF oNewImage IS Bitmap
			LOCAL oBM AS Bitmap
			oImage := oNewImage
			oBM := (Bitmap) oNewImage
			SELF:__CheckBox:Image := oBM:__Image
            SELF:__CheckBox:Text := ""
			SELF:__CheckBox:FlatStyle := System.Windows.Forms.FlatStyle.Flat
			RETURN TRUE
		ENDIF

		RETURN FALSE

/// <include file="Gui.xml" path="doc/CheckBox.Checked/*" />
	ACCESS Checked AS LOGIC
		IF SELF:ValidateControl()
			RETURN __CheckBox:Checked
		ELSE
			RETURN lSavedChecked
		ENDIF


/// <include file="Gui.xml" path="doc/CheckBox.Checked/*" />
	ASSIGN Checked(lChecked AS LOGIC)
		IF SELF:ValidateControl()
			IF !IsLogic(lChecked)
				WCError{#Checked,#CheckBox,__WCSTypeError,lChecked,1}:Throw()
			ENDIF
			__CheckBox:Checked := lChecked
		ENDIF

		__lModified := TRUE
		SELF:__Update()

		RETURN

/// <include file="Gui.xml" path="doc/CheckBox.Destroy/*" />
	METHOD Destroy() AS USUAL
		IF SELF:__IsValid
			lSavedChecked := SELF:Checked
		ENDIF

		RETURN SUPER:Destroy()

/// <include file="Gui.xml" path="doc/CheckBox.Image/*" />
	ACCESS Image  AS VObject
		RETURN SELF:__GetImage()


/// <include file="Gui.xml" path="doc/CheckBox.Image/*" />
	ASSIGN Image(oNewImage AS VObject)
		IF ! SELF:__SetImage(oNewImage)
			SUPER:Image := oNewImage
		ENDIF

		RETURN






/// <include file="Gui.xml" path="doc/CheckBox.TextValue/*" />
	ACCESS TextValue  AS STRING
		LOCAL lTicked AS LOGIC
		LOCAL cTickValue AS STRING

		lTicked := SELF:Checked

		IF IsInstanceOfUsual(SELF:FieldSpec, #FieldSpec)
			cTickValue := ((FieldSpec)SELF:FieldSpec):Transform(lTicked)
		ELSE
			cTickValue := AsString(lTicked)
		ENDIF

		RETURN cTickValue

/// <include file="Gui.xml" path="doc/CheckBox.TextValue/*" />
	ASSIGN TextValue(cNewValue  AS STRING)
		LOCAL lOldTicked AS LOGIC
		LOCAL lTicked AS LOGIC
		LOCAL uTicked AS USUAL

		lOldTicked := SELF:Checked
		IF IsInstanceOfUsual(SELF:FieldSpec, #FieldSpec)
			uTicked := ((FieldSpec)SELF:FieldSpec):Val(cNewValue)
			IF IsNumeric(uTicked)
				lTicked := (uTicked != 0)
			ELSEIF IsLogic(uTicked)
				lTicked := uTicked
			ELSE
				lTicked := FALSE
			ENDIF
		ELSE
			lTicked := Unformat(cNewValue, "", "L")
		ENDIF

		IF (lTicked != lOldTicked)
			SELF:Checked := lTicked
			SELF:Modified := .T.
		ENDIF

		RETURN

/// <include file="Gui.xml" path="doc/CheckBox.Value/*" />
	ACCESS Value
		LOCAL uVal AS USUAL
		IF SELF:Owner IS DataWindow
			uValue := SELF:Checked
			uVal := SUPER:Value
			IF IsString(uVal)
				RETURN (uVal == ".T.")
			ELSE
				RETURN uVal
			ENDIF
		ENDIF
		RETURN SELF:Checked

END CLASS

