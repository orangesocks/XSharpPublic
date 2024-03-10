/// <include file="Gui.xml" path="doc/AppWindow/*" />
CLASS AppWindow INHERIT Window
	PROTECT oVertScroll AS WindowVerticalScrollBar
	PROTECT oHorzScroll AS WindowHorizontalScrollBar
	PROTECT oSysMenu AS SystemMenu
	PROTECT oStatusBar AS StatusBar
	PROTECT lQuitOnClose AS LOGIC


	//PP-030828 Strong typing
 /// <exclude />
	METHOD __StatusMessageFromEvent(oEvent AS OBJECT, nType AS LONGINT) AS VOID STRICT
	//PP-030828 Strong typing
	LOCAL oHL AS HyperLabel


	oHL := oEvent:HyperLabel
	IF (oHL != NULL_OBJECT)
		SELF:StatusMessage(oHL, nType)
	ENDIF
	RETURN




 /// <exclude />
ACCESS __SysMenu AS SystemMenu STRICT
	//PP-030828 Strong typing

	IF (oSysMenu == NULL_OBJECT) .AND. (GetSystemMenu(SELF:Handle(), FALSE) != NULL_PTR)
		oSysMenu := SystemMenu{SELF}
	ENDIF

	RETURN oSysMenu


/// <include file="Gui.xml" path="doc/AppWindow.Default/*" />
METHOD Default(oEvent)
	LOCAL oEvt := oEvent AS @@Event


	SELF:EventReturnValue := DefWindowProc(oEvt:hWnd, oEvt:uMsg, oEvt:wParam, oEvt:lParam)
	RETURN SELF

/// <include file="Gui.xml" path="doc/AppWindow.Destroy/*" />
METHOD Destroy()   AS USUAL CLIPPER


	//SE-070501
	//__WCUnregisterMenu(oSysMenu)


	IF !InCollect()
		IF (oVertScroll != NULL_OBJECT)
			oVertScroll:Destroy()
			oVertScroll := NULL_OBJECT
		ENDIF
		IF oHorzScroll != NULL_OBJECT
			oHorzScroll:Destroy()
			oHorzScroll := NULL_OBJECT
		ENDIF
		IF oSysMenu != NULL_OBJECT
			oSysMenu:Destroy()
			oSysMenu := NULL_OBJECT
		ENDIF
		IF oStatusBar != NULL_OBJECT
			oStatusBar:Destroy()
			oStatusBar := NULL_OBJECT
		ENDIF
	ENDIF


	SUPER:Destroy()


	RETURN SELF






/// <include file="Gui.xml" path="doc/AppWindow.Dispatch/*" />
METHOD Dispatch(oEvent)
	LOCAL oEvt := oEvent AS @@Event
	LOCAL dwMsg AS DWORD


	LOCAL lHelpEnable AS LOGIC




	dwMsg := oEvt:Message


	DO CASE
	CASE (dwMsg == WM_MOUSEACTIVATE)
		IF lHelpOn
			IF lHelpcursorOn
				SELF:EventReturnValue := MA_ACTIVATEANDEAT
				RETURN SELF:EventReturnValue
			ELSE
				SELF:Default(oEvt)
			ENDIF
		ENDIF


	CASE (dwMsg == WM_SETCURSOR)
		IF lHelpOn
			IF lHelpcursorOn
				lHelpEnable := TRUE
			ELSE
				lHelpEnable := FALSE
			ENDIF
		ELSE
			lHelpEnable := FALSE
		ENDIF
		// last par. changed from true (bug report l. atkins)
		SELF:__HandlePointer(oEvt, lHelpEnable, FALSE)
		RETURN SELF:EventReturnValue


	CASE (dwMsg == WM_MENUSELECT)
		SELF:__StatusMessageFromEvent(MenuSelectEvent{oEvt}, MESSAGEMENU)
		//SELF:__StatusMessageFromEvent(__ObjectCastClassPtr(oEvt, __pCMenuSelectEvent), MESSAGEMENU)


	CASE (dwMsg == WM_NCLBUTTONDOWN)
		IF lHelpOn
			IF lHelpcursorOn
				RETURN SELF:EventReturnValue
			ENDIF
		ENDIF


	CASE (dwMsg == WM_LBUTTONDOWN)
		// ***********************************
		// Ignore if we're in Help Cursor mode
		// ***********************************
		IF !lHelpOn .OR. !lHelpcursorOn
			SELF:MouseButtonDown(MouseEvent{oEvt})
			//SELF:MouseButtonDown(__ObjectCastClassPtr(oEvt, __pCMouseEvent))
		ENDIF
		RETURN SELF:EventReturnValue


	CASE (dwMsg == WM_SIZE)
		// Allow this window to handle the resizing of its StatusBar
		IF SELF:StatusBar != NULL_OBJECT
			SendMessage(SELF:StatusBar:Handle(), dwMsg, oEvt:wParam, oEvt:lParam)
			SELF:StatusBar:__BuildItems()
		ENDIF


		//	CASE (dwMsg == WM_DRAWITEM)
		//PP-031006  Moved StatusBar drawinging to StatusBar:ODDrawItem()


	CASE (dwMsg == WM_CLOSE)
		//PP-040101 fix via S Ebert
		IF SELF:QueryClose(oEvt)
			SELF:__Close(oEvt)
			IF lQuitOnClose
				PostQuitMessage(0)
			ENDIF
		ENDIF
		RETURN SELF:EventReturnValue


	ENDCASE


	//PP-040101 Commented code below replaced with WM_CLOSE case above.
	// IF (dwMsg == WM_CLOSE) .and. lQuitOnClose
	// 	PostQuitMessage(0)
	// ENDIF


	RETURN SUPER:Dispatch(oEvt)




/// <include file="Gui.xml" path="doc/AppWindow.EnableBorder/*" />
METHOD EnableBorder(kBorderStyle)


	DEFAULT(@kBorderStyle, WINDOWSIZINGBORDER)


	DO CASE
	CASE kBorderStyle == WINDOWNOBORDER
		SELF:SetStyle(_OR(WS_BORDER, WS_THICKFRAME), FALSE)
	CASE kBorderStyle == WINDOWNONSIZINGBORDER
		SELF:SetStyle(WS_BORDER, TRUE)
		SELF:SetStyle(WS_THICKFRAME, FALSE)
	CASE kBorderStyle == WINDOWSIZINGBORDER
		SELF:SetStyle(_OR(WS_BORDER, WS_THICKFRAME), TRUE)
	END CASE


	IF (hWnd != NULL_PTR)
		SetWindowPos(hWnd, NULL_PTR, 0, 0, 0, 0, _OR(SWP_NOZORDER, SWP_NOMOVE, SWP_FRAMECHANGED, SWP_NOSIZE, SWP_NOACTIVATE))
	ENDIF


	RETURN NIL




/// <include file="Gui.xml" path="doc/AppWindow.EnableHorizontalScroll/*" />
METHOD EnableHorizontalScroll(lEnable)
	IF IsNil(lEnable) .OR. lEnable
		IF (oHorzScroll == NULL_OBJECT)
			oHorzScroll:=WindowHorizontalScrollBar{SELF}:Show()
		ENDIF
	ELSEIF (oHorzScroll != NULL_OBJECT)
		oHorzScroll:Destroy()
		oHorzScroll := NULL_OBJECT
	ENDIF


	RETURN oHorzScroll

/// <include file="Gui.xml" path="doc/AppWindow.EnableMaxBox/*" />
METHOD EnableMaxBox(lEnable)
	DEFAULT(@lEnable, TRUE)


	SELF:SetStyle(WS_MAXIMIZEBOX, lEnable)


	IF (hWnd != NULL_PTR)
		SetWindowPos(hWnd, NULL_PTR, 0, 0, 0, 0, _OR(SWP_NOZORDER, SWP_NOMOVE, SWP_FRAMECHANGED, SWP_NOSIZE, SWP_NOACTIVATE))
	ENDIF


	RETURN lEnable




/// <include file="Gui.xml" path="doc/AppWindow.EnableMinBox/*" />
METHOD EnableMinBox(lEnable)
	DEFAULT(@lEnable, TRUE)

	SELF:SetStyle(WS_MINIMIZEBOX, lEnable)


	IF (hWnd != NULL_PTR)
		SetWindowPos(hWnd, NULL_PTR, 0, 0, 0, 0, _OR(SWP_NOZORDER, SWP_NOMOVE, SWP_FRAMECHANGED, SWP_NOSIZE, SWP_NOACTIVATE))
	ENDIF

	RETURN lEnable
/// <include file="Gui.xml" path="doc/AppWindow.EnableOleDropTarget/*" />
METHOD EnableOleDropTarget(lEnable)
	// RvdH 030815 Moved method from Ole classes
#ifdef __VULCAN__
   // TODO
#else
	LOCAL pRegister AS  _VOOLERegisterDropTargetCallback  PTR
	pRegister := GetProcAddress(GetModuleHandle(String2Psz("VO28ORUN.DLL")), String2Psz("_VOOLERegisterDropTargetCallback"))
	IF pRegister != NULL_PTR
		IF (lEnable)
			RETURN PCALL(pRegister, SELF:owner:Handle(), SELF:Handle(), @__OleDropTargetCallback())
		ELSE
			RETURN PCALL(pRegister, SELF:owner:Handle(), SELF:Handle(), NULL_PTR)
		ENDIF
	ENDIF
#endif
	RETURN FALSE


/// <include file="Gui.xml" path="doc/AppWindow.EnableStatusBar/*" />
METHOD EnableStatusBar(lEnable)
	DEFAULT(@lEnable, TRUE)

	IF lEnable
		IF (SELF:StatusBar == NULL_OBJECT)
			SELF:StatusBar := StatusBar{SELF}
		ENDIF
		SELF:StatusBar:DisplayMessage()
		SELF:StatusBar:Create()
	ELSEIF SELF:StatusBar != NULL_OBJECT
		SELF:StatusBar:Destroy()
		SELF:StatusBar := NULL_OBJECT
	ENDIF

	RETURN SELF:StatusBar


/// <include file="Gui.xml" path="doc/AppWindow.EnableSystemMenu/*" />
METHOD EnableSystemMenu(lEnable)
	DEFAULT(@lEnable, TRUE)


	SELF:SetStyle(WS_SYSMENU, lEnable)
	IF ! lEnable
		//PP-030510 //Bug:20
		// Windows does not allow max/min without system menu (see CreateWindow)
		SELF:SetStyle(WS_MAXIMIZEBOX, lEnable)
		SELF:SetStyle(WS_MINIMIZEBOX, lEnable)
	ENDIF


	IF (oSysMenu != NULL_OBJECT)
		oSysMenu:Destroy()
		oSysMenu := NULL_OBJECT
	ENDIF


	IF lEnable
		oSysMenu := SystemMenu{SELF}
	ENDIF


	RETURN oSysMenu




/// <include file="Gui.xml" path="doc/AppWindow.EnableToolBar/*" />
METHOD EnableToolBar(lEnable)
	DEFAULT(@lEnable, TRUE)


	IF (SELF:ToolBar != NULL_OBJECT)
		IF lEnable
			SELF:ToolBar:Show()
		ELSE
			SELF:ToolBar:Hide()
		ENDIF
	ENDIF


	RETURN SELF:ToolBar
/// <include file="Gui.xml" path="doc/AppWindow.EnableVerticalScroll/*" />
METHOD EnableVerticalScroll(lEnable)
	DEFAULT(@lEnable, TRUE)


	IF lEnable
		IF (oVertScroll == NULL_OBJECT)
			oVertScroll := WindowVerticalScrollBar{SELF}:Show()
		ENDIF
	ELSEIF (oVertScroll != NULL_OBJECT)
		oVertScroll:Destroy()
		oVertScroll := NULL_OBJECT
	ENDIF

	RETURN oVertScroll


/// <include file="Gui.xml" path="doc/AppWindow.EndWindow/*" />
METHOD EndWindow(lSendMsg)
	IF IsLogic(lSendMsg) .AND. lSendMsg
		RETURN SendMessage(SELF:Handle(), WM_CLOSE, 0, 0)
	ENDIF
	RETURN PostMessage(SELF:Handle(), WM_CLOSE, 0, 0)


/// <include file="Gui.xml" path="doc/AppWindow.ErrorMessage/*" />
METHOD ErrorMessage(uText)
	ErrorBox{SELF, uText}
	RETURN SELF




/// <include file="Gui.xml" path="doc/AppWindow.ctor/*" />
CONSTRUCTOR(oOwner)


    SUPER(oOwner)




RETURN


//RvdH 080814 Added OLE Drag Message Handlers


/// <include file="Gui.xml" path="doc/AppWindow.OLEDragEnter/*" />
METHOD OLEDragEnter(oOleDragEvent)
    RETURN TRUE


/// <include file="Gui.xml" path="doc/AppWindow.OLEDragLeave/*" />
METHOD OLEDragLeave(oOleDragEvent)
    RETURN TRUE


/// <include file="Gui.xml" path="doc/AppWindow.OLEDragOver/*" />
METHOD OLEDragOver(oOleDragEvent)
    RETURN TRUE


/// <include file="Gui.xml" path="doc/AppWindow.OLEDrop/*" />
METHOD OLEDrop(oOleDragEvent)
    RETURN TRUE


//RvdH 080814 End of Additions


/// <include file="Gui.xml" path="doc/AppWindow.OLEInPlaceActivate/*" />
METHOD OLEInPlaceActivate()
	// RvdH 030815 Moved method from Ole classes
	RETURN NIL


/// <include file="Gui.xml" path="doc/AppWindow.OLEInPlaceDeactivate/*" />
METHOD OLEInPlaceDeactivate()
	// RvdH 030815 Moved method from Ole classes
	RETURN NIL

/// <include file="Gui.xml" path="doc/AppWindow.QuitOnClose/*" />
ACCESS QuitOnClose
	RETURN lQuitOnClose

/// <include file="Gui.xml" path="doc/AppWindow.QuitOnClose/*" />
ASSIGN QuitOnClose(lNewValue)
	RETURN (lQuitOnClose := lNewValue)

/// <include file="Gui.xml" path="doc/AppWindow.ReportException/*" />
METHOD ReportException(oRQ)
	RETURN NIL

/// <include file="Gui.xml" path="doc/AppWindow.ReportNotification/*" />
METHOD ReportNotification(oRQ)
	RETURN NIL


/// <include file="Gui.xml" path="doc/AppWindow.Show/*" />
METHOD Show(nShowState)
	IF oStatusBar != NULL_OBJECT
		oStatusBar:Show()
	ENDIF
	SUPER:Show(nShowState)
	RETURN NIL

/// <include file="Gui.xml" path="doc/AppWindow.StatusBar/*" />
ACCESS StatusBar
	RETURN oStatusBar

/// <include file="Gui.xml" path="doc/AppWindow.StatusBar/*" />
ASSIGN StatusBar(oNewStatusBar)
	oStatusBar := oNewStatusBar
	RETURN


/// <include file="Gui.xml" path="doc/AppWindow.StatusMessage/*" />
METHOD StatusMessage(oHL, nType)
	LOCAL Message AS STRING
	LOCAL oStatBar AS StatusBar
	LOCAL oOwner AS OBJECT


	DEFAULT(@nType, MESSAGETRANSIENT)


	IF SELF:StatusBar != NULL_OBJECT
		oStatBar := SELF:StatusBar
	ELSE
		oOwner := SELF:owner
		IF oOwner != NULL_OBJECT .AND. IsAccess(oOwner, #StatusBar)
			oStatBar := oOwner:StatusBar
		ENDIF
	ENDIF

	IF oStatBar != NULL_OBJECT
		DO CASE
		CASE oHL IS HyperLabel VAR oHL2 .AND. IsString(oHL2:Description)
			Message := oHL2:Description
		CASE IsString(oHL)
			Message := oHL
		OTHERWISE
			Message := ""
		ENDCASE


		oStatBar:setmessage(Message, nType)
	ENDIF

	RETURN NIL




/// <include file="Gui.xml" path="doc/AppWindow.SystemMenu/*" />
ACCESS SystemMenu AS SystemMenu
	RETURN oSysMenu




/// <include file="Gui.xml" path="doc/AppWindow.SystemMenu/*" />
ASSIGN SystemMenu (oMenu AS SystemMenu)
	oSysMenu := oMenu
    RETURN


/// <include file="Gui.xml" path="doc/AppWindow.WarningMessage/*" />
METHOD WarningMessage(aPlace1, aPlace2)
	RETURN WarningBox{SELF, aPlace1, aPlace2}:Show()


END CLASS


STATIC FUNCTION  _VOOLERegisterDropTargetCallback(hFrameWnd AS PTR, hDocWnd AS PTR, pCallBackFunc AS PTR) ;
		AS LOGIC STRICT
	RETURN FALSE




