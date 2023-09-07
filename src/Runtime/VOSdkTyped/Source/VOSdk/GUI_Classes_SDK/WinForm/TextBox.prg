//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//

// textBox.prg
// This file contains subclasses Windows.Forms controls that are used in the
// XSharp GUI Classes, in particular several TextBox subclasses
//
// Also some On..() methods have been implemented that call the event handlers on the VO Window
// class that owns the control
USING SWF := System.Windows.Forms
USING System.Windows.Forms
USING VOSDK := XSharp.VO.SDK

class VOTextBox inherit SWF.TextBox   implements IVOControlProperties
	PROPERTY oEdit		AS VOSDK.Edit GET (VOSDK.Edit) SELF:Control
#undef DEFAULTVISUALSTYLE
	#include "PropControl.xh"
	method Initialize() as void strict
		SELF:AutoSize			:= FALSE
        SELF:oProperties:OnWndProc += OnWndProc
		RETURN

	CONSTRUCTOR(Owner AS VOSDK.Control, dwStyle AS LONG, dwExStyle AS LONG)
		SUPER()
			oProperties := VOControlProperties{SELF, Owner, dwStyle, dwExStyle}
		SELF:Initialize()
		SELF:SetVisualStyle()


	METHOD SetVisualStyle AS VOID STRICT
		IF SELF:oProperties != NULL_OBJECT
			LOCAL dwStyle AS LONG
			dwStyle					    := _AND(oProperties:Style , _NOT(oProperties:NotStyle))
			SELF:TabStop			    := _AND(dwStyle, WS_TABSTOP) == WS_TABSTOP
			SELF:UseSystemPasswordChar	:= _AND(dwStyle, ES_PASSWORD) == ES_PASSWORD
			SELF:AcceptsReturn		    := _AND(dwStyle, ES_WANTRETURN) == ES_WANTRETURN
			SELF:Multiline			    := _AND(dwStyle, ES_MULTILINE) == ES_MULTILINE
		ENDIF

	VIRTUAL PROPERTY Text AS STRING GET SUPER:Text SET SUPER:Text := Value

	#region Event Handlers
	VIRTUAL PROTECT METHOD OnTextChanged(e AS EventArgs) AS VOID
		LOCAL oWindow AS Window
		LOCAL oEvent AS ControlEvent
		SUPER:OnTextChanged(e)
		IF oProperties != NULL_OBJECT .and. SELF:oEdit != NULL_OBJECT
			oEvent := ControlEvent{SELF:oEdit}
			oWindow := (Window) SELF:oEdit:Owner
			IF oWindow != NULL_OBJECT
				oWindow:EditChange(oEvent)
			ENDIF
		ENDIF
		RETURN

	VIRTUAL PROTECT METHOD OnLeave(e AS EventArgs) AS VOID
		LOCAL oWindow AS Window
		LOCAL oEvent AS EditFocusChangeEvent
		SUPER:OnLeave(e)
		IF oProperties != NULL_OBJECT .and. SELF:oEdit != NULL_OBJECT
			oEvent := EditFocusChangeEvent{SELF:oEdit, FALSE}
			oWindow := (Window) SELF:oEdit:Owner
			IF oWindow != NULL_OBJECT
				oWindow:EditFocusChange(oEvent)
			ENDIF
		ENDIF
		RETURN


	VIRTUAL PROTECT METHOD OnEnter(e AS EventArgs) AS VOID
		LOCAL oWindow AS Window
		LOCAL oEvent AS EditFocusChangeEvent
		//Debout("TextBox:OnGotFocus", SELF:Control:NameSym,SELF:Control:ControlID, CRLF)
		SUPER:OnEnter(e)
		IF oProperties != NULL_OBJECT .and. SELF:oEdit != NULL_OBJECT
			oEvent := EditFocusChangeEvent{SELF:oEdit, TRUE}
			oWindow := (Window) SELF:oEdit:Owner
			IF oWindow != NULL_OBJECT
				oWindow:EditFocusChange(oEvent)
			ENDIF
		ENDIF
		RETURN

	PROTECT _lInPaint AS LOGIC

	METHOD OnWndProc(msg REF SWF.Message) AS VOID
		IF msg:Msg == WM_PASTE .AND. SELF:oEdit != NULL_OBJECT
			IF IsInstanceOf(oEdit, #SingleLineEdit)
				LOCAL oSle AS SingleLineEdit
				oSle := (SingleLineEdit) oEdit
				IF oSle:__EditString != NULL_OBJECT
					oSle:Paste(NULL)
				ENDIF
			ENDIF
		ENDIF
		RETURN
	#endregion

END CLASS

CLASS VOHotKeyTextBox INHERIT VOTextBox
	CONSTRUCTOR(Owner AS VOSDK.Control, dwStyle AS LONG, dwExStyle AS LONG)
		SUPER(Owner, dwStyle, dwExStyle)

	OVERRIDE PROTECTED PROPERTY CreateParams AS SWF.CreateParams
		GET
			LOCAL IMPLIED result := SUPER:CreateParams
			result:ClassName := HOTKEY_CLASS
			RETURN result
		END GET
	END PROPERTY
END CLASS

CLASS VOMLETextBox INHERIT VOTextBox
	CONSTRUCTOR(Owner AS VOSDK.Control, dwStyle AS LONG, dwExStyle AS LONG)
		SUPER(Owner,dwStyle,dwExStyle )
		SELF:Multiline := TRUE

	OVERRIDE PROTECTED PROPERTY CreateParams AS SWF.CreateParams
		GET
			LOCAL IMPLIED result := SUPER:CreateParams
			result:style |= (LONG)WS_VSCROLL
			RETURN result
		END GET
	END PROPERTY

	PROTECTED METHOD OnKeyDown (e AS SWF.KeyEventArgs) AS VOID STRICT
		// Suppress Escape. Was in VO in MultiLineEdit:Dispatch()
		IF e:KeyCode != SWF.Keys.Escape
			SUPER:OnKeyDown(e)
		ENDIF

END CLASS



CLASS VOIPAddressTextBox INHERIT VOTextBox
	CONSTRUCTOR(Owner AS VOSDK.Control, dwStyle AS LONG, dwExStyle AS LONG)
		SUPER(Owner,dwStyle,dwExStyle )

	OVERRIDE PROTECTED PROPERTY CreateParams AS SWF.CreateParams
		GET
			LOCAL IMPLIED result := SUPER:CreateParams
			result:ClassName := "SysIPAddress32"
			RETURN result
		END GET
    END PROPERTY
END CLASS


class VORichTextBox inherit SWF.RichTextBox implements IVOControlInitialize
    #include "PropControlStyle.xh"
	method Initialize() as void strict
		SELF:AutoSize			:= FALSE
		RETURN


	CONSTRUCTOR(Owner AS VOSDK.Control, dwStyle AS LONG, dwExStyle AS LONG)
		oProperties := VOControlProperties{SELF, Owner, dwStyle, dwExStyle}
		SUPER()
		SELF:Initialize()
		SELF:SetVisualStyle()



END CLASS


class VOSpinnerTextBox inherit SWF.NumericUpDown implements IVOControlProperties
	PROPERTY oEdit		AS VOSDK.SpinnerEdit GET (VOSDK.SpinnerEdit) SELF:Control
    #include "PropControlStyle.xh"

	CONSTRUCTOR(Owner AS VOSDK.Control, dwStyle AS LONG, dwExStyle AS LONG)
		oProperties := VOControlProperties{SELF, Owner, dwStyle, dwExStyle}
		SUPER()
		SELF:Minimum := 0
		SELF:Maximum := System.Int32.MaxValue
		SELF:SetVisualStyle()


	VIRTUAL PROTECT METHOD OnTextChanged(e AS EventArgs) AS VOID
		LOCAL oWindow AS Window
		LOCAL oEvent AS ControlEvent
		SUPER:OnTextChanged(e)
		IF oProperties != NULL_OBJECT .and. SELF:oEdit != NULL_OBJECT
			oEvent := ControlEvent{SELF:oEdit}
			oWindow := (Window) SELF:oEdit:Owner
			IF oWindow != NULL_OBJECT
				oWindow:EditChange(oEvent)
			ENDIF
		ENDIF

	VIRTUAL PROTECT METHOD OnEnter(e AS EventArgs) AS VOID
		LOCAL oWindow AS Window
		LOCAL oEvent AS EditFocusChangeEvent
		SUPER:OnEnter(e)
		IF oProperties != NULL_OBJECT
			oEvent := EditFocusChangeEvent{SELF:oEdit, FALSE}
			oWindow := (Window) SELF:oEdit:Owner
			IF oWindow != NULL_OBJECT
				oWindow:EditFocusChange(oEvent)
			ENDIF
		ENDIF
		RETURN


	VIRTUAL PROTECT METHOD OnLeave(e AS EventArgs) AS VOID
		LOCAL oWindow AS Window
		LOCAL oEvent AS EditFocusChangeEvent
		//Debout("TextBox:OnGotFocus", SELF:Control:NameSym,SELF:Control:ControlID, CRLF)
		SUPER:OnLeave(e)
		IF oProperties != NULL_OBJECT
			oEvent := EditFocusChangeEvent{SELF:oEdit, TRUE}
			oWindow := (Window) SELF:oEdit:Owner
			IF oWindow != NULL_OBJECT
				oWindow:EditFocusChange(oEvent)
			ENDIF
		ENDIF
		RETURN
	PROPERTY Text AS STRING
		GET
			RETURN SUPER:Text
		END GET
		SET
			IF STRING.IsNullOrWhiteSpace(VALUE)
				Value := SELF:Minimum:ToString()
			ENDIF
			SUPER:Text := VALUE
		END SET
    END PROPERTY
END CLASS


