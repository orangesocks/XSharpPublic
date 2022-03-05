GLOBAL DefaultWindAppClassName := #__WindApp AS SYMBOL
/// <exclude />
CLASS __WindApp INHERIT AppWindow
	PROTECT lTopApp AS LOGIC


 /// <exclude />
METHOD Default(oEvent)
	LOCAL oEvt := oEvent AS @@Event




	oParent:EventReturnValue := DefWindowProc(oEvt:hWnd, oEvt:uMsg, oEvt:wParam, oEvt:lParam)


	RETURN SELF


 /// <exclude />
METHOD Dispatch(oEvent)
	LOCAL oEvt := oEvent AS @@Event
	LOCAL uMsg AS DWORD






	oParent:EventReturnValue := 0L
	uMsg := oEvt:uMsg


	IF (oParent != NULL_OBJECT)
		oEvt:oWindow := oParent
	ENDIF


	SWITCH uMsg
	CASE WM_CREATE
		hWnd := oEvt:hWnd
		SELF:owner:__Imp := SELF
		SELF:Owner:SetHandle(hWnd)
        IF oParent IS Window VAR oWnd
            oWnd:Dispatch(oEvt)
        ELSE
            oParent:Dispatch(oEvt)
        ENDIF


	CASE WM_QUERYENDSESSION
		oParent:EventReturnValue := oParent:QueryClose(oEvt)


    OTHERWISE
        LOCAL oWnd AS Window
		IF ((uMsg == WM_MENUSELECT) .OR. (uMsg == WM_COMMAND)) .AND. (oParent IS __FormFrame VAR oFF .AND. oFF:DataWindow != NULL_OBJECT)
            oWnd := oFF:DataWindow
            oWnd:Dispatch(oEvt)
			oParent:EventReturnValue := oWnd:EventReturnValue
        ELSE
            oWnd := oParent
			oWnd:Dispatch(oEvt)
		ENDIF


	END SWITCH
	RETURN oParent:EventReturnValue


 /// <exclude />
CONSTRUCTOR(oOwner, lClientEdge)
	LOCAL dwExStyle AS DWORD
	LOCAL hParent := NULL_PTR AS PTR
	LOCAL oParentOwner AS OBJECT
	LOCAL o AS OBJECT






	dwExStyle := (DWORD) IIF(lClientEdge, WS_EX_STATICEDGE, 0) //WS_EX_CONTROLPARENT)


	// needed (for now) since we end up in an infinite
	// WM_GETDLGCODE loop otherwise
	o := oOwner
	WHILE (o != NULL_OBJECT) .AND. !IsInstanceOf(o, #App) .AND. !IsInstanceOf(o, #DataDialog)
		o := o:Owner
	END


	IF IsInstanceOf(o, #DataDialog)
		dwExStyle := _AND(dwExStyle, DWORD(_CAST, _NOT(WS_EX_CONTROLPARENT)))
	ENDIF
	dwStyle := _OR(dwStyle, DWORD(_CAST, WS_CLIPCHILDREN), DWORD(_CAST, WS_CHILD))


	SUPER(oOwner)


	oParentOwner := oParent:Owner


	IF (IsInstanceOf(oParentOwner, #Window) .AND. IsWindow(oParentOwner:Handle()))
		hParent := oParentOwner:Handle()
	ELSE
		hParent := oOwner:Handle()
	ENDIF


	IF (hParent == NULL_PTR)
		dwStyle := _AND(dwStyle, DWORD(_CAST, _NOT(WS_CHILD)))
		dwStyle := _OR(dwStyle, DWORD(_CAST, WS_OVERLAPPEDWINDOW), DWORD(_CAST, WS_THICKFRAME))
	ENDIF




	IF __WCRegisterWndAppWindow(_GetInst())
		hWnd := CreateWindowEx(dwExStyle,	PSZ(_CAST, __WCWndAppWindowClass), NULL_PSZ,;
			dwStyle,	0, 0, 0, 0, hParent, 0,	_GetInst(), ptrSelfPtr)


	ENDIF


	RETURN


 /// <exclude />
ASSIGN Menu(oNewMenu)
	RETURN


 /// <exclude />
METHOD SetOwner(oNewOwner)
	// 2.5b new, otherwise event in subDWs are not properly handled
	// called in __FormFrame:DataWindow:ASSIGN
	// dummy not needed anymore
	RETURN SELF


 /// <exclude />
METHOD Show(kShowState)




	SUPER:Show(kShowState)
	//BringWindowToTop(hWnd) // needed ?? does destroy the correct tab order


	RETURN SELF


END CLASS


STATIC FUNCTION __WCRegisterWndAppWindow(hInst AS PTR) AS LOGIC
	STATIC LOCAL lretVal AS LOGIC
	LOCAL wc IS _WINWNDCLASS


	IF !lretVal
		// 2.5c REDRAW_FLAGS removed - lead to flicker !!!
		wc:style := CS_DBLCLKS //, CS_HREDRAW, CS_VREDRAW) //, CS_CLASSDC)
#ifdef __VULCAN__
      STATIC LOCAL WCWndAppWndProcDelegate AS __WCWndAppWndProcDelegate
      IF WCWndAppWndProcDelegate == NULL
         WCWndAppWndProcDelegate := __WCWndAppWndProcDelegate{ NULL, @__WCWndAppWndProc() }
      ENDIF
		wc:lpfnWndProc := System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate((System.Delegate) WCWndAppWndProcDelegate )
#else
		wc:lpfnWndProc := PTR(_CAST, @__WCWndAppWndProc())
#endif
		wc:hInstance := hInst
		wc:hIcon := LoadIcon(0, IDI_APPLICATION)
		wc:hCursor := LoadCursor(0, IDC_Arrow)
		wc:hbrBackground := (COLOR_WINDOW + 1)
		wc:lpszClassName := String2Psz( __WCWndAppWindowClass)
		wc:cbWndExtra := 12


		lretVal := (RegisterClass(@wc)!=0)
	ENDIF


	RETURN lretVal


#ifdef __VULCAN__
/// <exclude/>
   DELEGATE __WCWndAppWndProcDelegate( hWnd AS PTR, uMsg AS DWORD, wParam AS DWORD, lParam AS LONGINT ) AS LONGINT
#endif


 /// <exclude />
FUNCTION __WCWndAppWndProc(hWnd AS PTR, uMsg AS DWORD, wParam AS DWORD, lParam AS LONGINT) AS LONGINT /* WINCALL */
	LOCAL oWindow AS Window
	LOCAL strucCreateStruct AS _WinCreateStruct




	IF (uMsg == WM_CREATE)
		strucCreateStruct := PTR(_CAST,lParam)
		SetWindowLong(hWnd, DWL_User, LONGINT(_CAST,strucCreateStruct:lpCreateParams))
	ENDIF


	oWindow := __WCGetWindowByHandle(hWnd)


	IF oWindow != NULL_OBJECT
		RETURN oWindow:Dispatch(@@Event{ hWnd, uMsg, wParam, lParam, oWindow})
	ENDIF
	RETURN DefWindowProc(hWnd, uMsg, wParam, lParam)






#region defines
DEFINE __WCWndAppWindowClass	:= "WndAppWindow"
#endregion
