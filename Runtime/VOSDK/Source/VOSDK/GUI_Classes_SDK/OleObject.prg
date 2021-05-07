STATIC DEFINE __WCOleContWindowClass := "_VOOLEContainer"


#ifdef USE_OLEOBJECT


/// <include file="Gui.xml" path="doc/OleObject/*" />
CLASS OleObject INHERIT Control
	PROTECT ObjHandle AS PTR
	// protect lFocused as logic
	PROTECT lCreated 	AS LOGIC
	//RvdH 041123 Added lActive to avoid unnecessary activation/deactivation
	PROTECT lActive	AS LOGIC
 /// <exclude />
	METHOD __GetName(dwType AS DWORD) AS STRING STRICT 
	LOCAL sRet AS STRING
	LOCAL pszRet AS PSZ
 	////_DebOut32(PSZ(__ENTITY))


	pszRet := MemAlloc(MAX_NAME + 1)
	IF (_VOOLEGetName(SELF:ObjHandle, dwType, pszRet, MAX_NAME))
		sRet := Psz2String(pszRet)
	ELSE
		sRet := "Unnamed Object"
	ENDIF
	MemFree(pszRet)


	RETURN sRet


 /// <exclude />
ASSIGN __Value(uNewValue AS USUAL)  STRICT 
	//PP-030903 Strong typing
 	////_DebOut32(PSZ(__ENTITY))
	SELF:RePaint()
	IF IsInstanceOfUsual(uNewValue, #OleDBStorage)
		uValue := uNewValue
		SELF:CreateFromDBStorage(uNewValue)
	ELSEIF IsInstanceOfUsual(uNewValue, #OleObject)
		uValue := uNewValue
	ELSE
		uValue := NIL
		SELF:DetachFromServer()
	ENDIF
	SELF:ValueChanged := TRUE
	SELF:Modified := FALSE


	RETURN 




/// <include file="Gui.xml" path="doc/OleObject.Activate/*" />
METHOD Activate() 
	//RvdH 041123 Added lActive to avoid unnecessary activation/deactivation
 	////_DebOut32(PSZ(__ENTITY))
	IF ! SELF:lActive
		///_DebOut32(PSZ(__ENTITY__+" "+SELF:Hyperlabel:Name))
		SELF:lActive := TRUE
		RETURN _VOOLEActivateObject(SELF:ObjHandle)
	ENDIF
	RETURN FALSE


/// <include file="Gui.xml" path="doc/OleObject.ActivateOnDblClk/*" />
ACCESS ActivateOnDblClk 
	LOCAL Props IS OleProps
 	//_DebOut32(PSZ(__ENTITY))


	_VOOLEGetProps(SELF:ObjHandle, @Props)
	RETURN Props:fActivateOnDblClk


/// <include file="Gui.xml" path="doc/OleObject.ActivateOnDblClk/*" />
ASSIGN ActivateOnDblClk(fNewValue) 
	LOCAL Props IS OleProps
 	//_DebOut32(PSZ(__ENTITY))


	Props:dwSelector := OLEPROP_ACTIVATEONDBLCLK
	Props:fActivateOnDblClk := fNewValue
	_VOOLESetProps(SELF:ObjHandle, @Props)
	RETURN 


/// <include file="Gui.xml" path="doc/OleObject.AddVerbMenu/*" />
METHOD AddVerbMenu(hMenu, iPos) 
 	//_DebOut32(PSZ(__ENTITY))
	RETURN _VOOLEAddVerbMenu(SELF:ObjHandle, hMenu, iPos)


/// <include file="Gui.xml" path="doc/OleObject.AllowDocView/*" />
ACCESS AllowDocView 
	LOCAL Props IS OleProps
 	//_DebOut32(PSZ(__ENTITY))


	_VOOLEGetProps(SELF:ObjHandle, @Props)
	RETURN Props:fAllowDocView


/// <include file="Gui.xml" path="doc/OleObject.AllowDocView/*" />
ASSIGN AllowDocView(fNewValue) 
	LOCAL Props IS OleProps
 	//_DebOut32(PSZ(__ENTITY))


	Props:dwSelector := OLEPROP_ALLOWDOCVIEW
	Props:fAllowDocView := fNewValue
	_VOOLESetProps(SELF:ObjHandle, @Props)
	RETURN 




/// <include file="Gui.xml" path="doc/OleObject.AllowInPlace/*" />
ACCESS AllowInPlace 
	LOCAL Props IS OleProps


	_VOOLEGetProps(SELF:ObjHandle, @Props)
	RETURN Props:fAllowInPlace


/// <include file="Gui.xml" path="doc/OleObject.AllowInPlace/*" />
ASSIGN AllowInPlace(fNewValue) 
	LOCAL Props IS OleProps


	Props:dwSelector := OLEPROP_ALLOWINPLACE
	Props:fAllowInPlace := fNewValue
	_VOOLESetProps(SELF:ObjHandle, @Props)
	RETURN 




/// <include file="Gui.xml" path="doc/OleObject.AllowResize/*" />
ACCESS AllowResize 
	LOCAL Props IS OleProps


	_VOOLEGetProps(SELF:ObjHandle, @Props)
	RETURN Props:fAllowResize


/// <include file="Gui.xml" path="doc/OleObject.AllowResize/*" />
ASSIGN AllowResize(fNewValue) 
	LOCAL Props IS OleProps


	Props:dwSelector 		:= OLEPROP_ALLOWRESIZE
	Props:fAllowResize 	:= fNewValue
	_VOOLESetProps(SELF:ObjHandle, @Props)
	RETURN 


/// <include file="Gui.xml" path="doc/OleObject.AutoSizeOnCreate/*" />
ACCESS AutoSizeOnCreate 
	LOCAL Props IS OleProps


	_VOOLEGetProps(SELF:ObjHandle, @Props)
	RETURN Props:fAutoSizeOnCreate


/// <include file="Gui.xml" path="doc/OleObject.AutoSizeOnCreate/*" />
ASSIGN AutoSizeOnCreate(fNewValue) 
	LOCAL Props IS OleProps


	Props:dwSelector := OLEPROP_AUTOSIZEONCREATE
	Props:fAutoSizeOnCreate := fNewValue
	_VOOLESetProps(SELF:ObjHandle, @Props)
	RETURN 


/// <include file="Gui.xml" path="doc/OleObject.CreateEmbedding/*" />
METHOD CreateEmbedding(cProgID) 
	RETURN (SELF:lCreated := _VOOLECreateEmbObject(SELF:ObjHandle, String2Psz(cProgID), FALSE, NULL_PSZ))


/// <include file="Gui.xml" path="doc/OleObject.CreateEmbeddingFromFile/*" />
METHOD CreateEmbeddingFromFile(cFileName) 
	RETURN (SELF:lCreated := _VOOLECreateEmbObjectFromFile(SELF:ObjHandle, String2Psz(cFileName)))


/// <include file="Gui.xml" path="doc/OleObject.CreateFromAppDocStorage/*" />
METHOD CreateFromAppDocStorage(oAppDocStg) 
	LOCAL e AS Error
	LOCAL oStg AS OleAppDocStorage


	IF !IsInstanceOf(oAppDocStg, #OleAppDocStorage)
		SELF:lCreated := FALSE
	ELSE
		oStg := oAppDocStg
		IF (SLen(oStg:DocFile) == 0)
			SELF:lCreated := FALSE
		ELSE
			SELF:lCreated := _VOOLECreateFromAppDocStorage(SELF:ObjHandle, oStg:DocFile, oStg:Form, oStg:OleObject)
		ENDIF
	ENDIF


	IF (!SELF:lCreated)
		e := ErrorNew()
		e:SUBSYSTEM 	:= __CavoStr(IDS_OLERUNTIME)
		e:CANDEFAULT 	:= TRUE
		e:ARG 			:= NULL_STRING
		e:FUNCSYM 		:= SysAddAtom(String2Psz(__ENTITY))
		e:Description 	:= __CavoStr(IDS_CREATEFAILED)
		Eval(ErrorBlock(), e)
	ENDIF


	RETURN SELF:lCreated


/// <include file="Gui.xml" path="doc/OleObject.CreateFromDBStorage/*" />
METHOD CreateFromDBStorage(oOleDBStg) 
	LOCAL oStg AS OleDBStorage
	IF !IsInstanceOf(oOleDBStg, #OleDBStorage)
		_VOOLEDetachFromServer(SELF:ObjHandle)
		SELF:lCreated := FALSE
	ELSE
		oStg := oOleDBStg
		(SELF:lCreated := _VOOLECreateFromDBStorage(SELF:ObjHandle, oStg:RootStorage, oStg:SubStorageName))
	ENDIF


	RETURN SELF:lCreated


/// <include file="Gui.xml" path="doc/OleObject.CreateFromInsertDialog/*" />
METHOD CreateFromInsertDialog(lShowControls) 
	DEFAULT(@lShowControls, FALSE)


	RETURN (SELF:lCreated := _VOOLECreateFromIODialog(SELF:ObjHandle, lShowControls))


/// <include file="Gui.xml" path="doc/OleObject.CreateFromOleDragEvent/*" />
METHOD CreateFromOleDragEvent(oOleDragEvent) 
	LOCAL oEvent AS OleDragEvent
	oEvent := oOleDragEvent
	RETURN (SELF:lCreated := _VOOLECreateFromOleDragEvent(SELF:ObjHandle, oEvent:DataObject, oEvent:Effect))


/// <include file="Gui.xml" path="doc/OleObject.CreateFromPasteDialog/*" />
METHOD CreateFromPasteDialog() 
	RETURN (SELF:lCreated := _VOOLECreateFromPSDialog(SELF:ObjHandle))


/// <include file="Gui.xml" path="doc/OleObject.CreateLink/*" />
METHOD CreateLink(cFileName) 
	RETURN (SELF:lCreated := _VOOLECreateLinkObject(SELF:ObjHandle, String2Psz(cFileName)))


/// <include file="Gui.xml" path="doc/OleObject.Deactivate/*" />
METHOD Deactivate() 
	//RvdH 041123 Added lActive to avoid unnecessary activation/deactivation
	IF SELF:lActive
		//_DebOut32(PSZ(__ENTITY__+" "+SELF:Hyperlabel:Name))
		SELF:lActive := FALSE
		RETURN _VOOLEDeactivateObject(SELF:ObjHandle)
	ENDIF
	RETURN FALSE


/// <include file="Gui.xml" path="doc/OleObject.Destroy/*" />
METHOD Destroy()  AS USUAL CLIPPER
	IF _VOOLEReleaseObject(SELF:ObjHandle)
		SELF:ObjHandle := NULL_PTR
	ENDIF
	SELF:lActive := FALSE
	RETURN SUPER:Destroy()


/// <include file="Gui.xml" path="doc/OleObject.DetachFromServer/*" />
METHOD DetachFromServer() 
	SELF:lCreated := FALSE


	RETURN _VOOLEDetachFromServer(SELF:ObjHandle)


/// <include file="Gui.xml" path="doc/OleObject.Dispatch/*" />
METHOD Dispatch(oEvent) 
	LOCAL oEvt := oEvent AS @@Event
	LOCAL msg := oEvt:uMsg AS DWORD
	LOCAL hwnd, hwndChild AS PTR
	LOCAL liRet AS LONGINT
	LOCAL wParam AS DWORD
	LOCAL wEvent AS WORD
	//LOCAL wId	 AS WORD
	LOCAL lActivate AS LOGIC
	SELF:EventReturnValue := 0L
	hwnd := SELF:handle()


	DO CASE
	CASE msg == WM_PAINT
	 	//_DebOut32(PSZ(__ENTITY+" PAINT"))
		SELF:Redraw()
		ValidateRect(hwnd, NULL)
 		SELF:EventReturnValue := 1L
 		RETURN 1L


	CASE msg == WM_LBUTTONDBLCLK
		IF SELF:ActivateOnDblClk
			SELF:Activate()
			RETURN 1L
		ENDIF


	CASE msg == WM_SIZE
	 	//_DebOut32(PSZ(__ENTITY+" SIZE"))
		liRet := SUPER:Dispatch(oEvt)
		_VOOLESetObjSize(SELF:ObjHandle)
		RETURN liRet


	CASE msg == WM_LBUTTONDOWN
		BringWindowToTop(hwnd)
		SELF:SetFocus()


	CASE msg == WM_SETFOCUS
	 	//_DebOut32(PSZ(__ENTITY+" SETFOCUS"))
		hwndChild := GetWindow(hwnd, GW_CHILD)
		IF (hwndChild != NULL_PTR)
			SetFocus(hwndChild)
		ENDIF


	CASE msg == WM_KILLFOCUS
	 	//_DebOut32(PSZ(__ENTITY+" KILLFOCUS"))
		//RvdH 050509
		IF SELF:lActive
			SELF:Deactivate()
		ENDIF


		//RvdH 041123 Activate and deactivate other objects to make sure
		// 			 correct OBJECT gets keyboard focus
	CASE Msg == WM_PARENTNOTIFY
	 	//_DebOut32(PSZ(__ENTITY+"PARENTNOTIFY"))
		wParam := oEvt:wParam
		wEvent := WORD(_AND(wParam, 0xFFFF))
		//wId	 := WORD(wParam>> 16)


		DO CASE
		CASE wEvent == WM_CREATE


		CASE wEvent == WM_DESTROy


		CASE wEvent == WM_LBUTTONDOWN
			lActivate := TRUE


		CASE wEvent == WM_MBUTTONDOWN
			lActivate := TRUE
		CASE wEvent == WM_RBUTTONDOWN
			lActivate := TRUE
		CASE wEvent == WM_XBUTTONDOWN
			lActivate := TRUE
		OTHERWISE
			lActivate := FALSE
		ENDCASE
        IF lActivate .AND. ! SELF:lActive


			IF IsMethod(oParent, #DeactivateAllOLEObjects)
				oParent:DeactivateAllOLEObjects(SELF)
			ENDIF
			SELF:Activate()
		ENDIF
	ENDCASE


	RETURN SUPER:Dispatch(oEvt)


/// <include file="Gui.xml" path="doc/OleObject.DoVerb/*" />
METHOD DoVerb(iVerb) 
	RETURN _VOOLEDoVerb(SELF:ObjHandle, iVerb)


/// <include file="Gui.xml" path="doc/OleObject.ExportToStorage/*" />
METHOD ExportToStorage(cFileName, cStorageName) 
	RETURN _VOOLEExportToStorage(SELF:ObjHandle, String2Psz(cFileName), String2Psz(cStorageName))


/// <include file="Gui.xml" path="doc/OleObject.HyperLabel/*" />
ASSIGN HyperLabel(oNewHL) 
	IF IsInstanceOfUsual(oNewHL, #HyperLabel)
		_VOOLESetInstName(SELF:ObjHandle, DWORD(_CAST, oNewHl:NameSym))
	ELSE
		_VOOLESetInstName(SELF:ObjHandle, 0)
	ENDIF


	RETURN SUPER:Hyperlabel := oNewHL


/// <include file="Gui.xml" path="doc/OleObject.ImportFromStorage/*" />
METHOD ImportFromStorage(cFileName, cStorageName) 
	RETURN _VOOLEImportFromStorage(SELF:ObjHandle, String2Psz(cFileName), String2Psz(cStorageName))


/// <include file="Gui.xml" path="doc/OleObject.ctor/*" />
CONSTRUCTOR(oOwner, xID, oPoint, oDimension, lDataAware) 
	LOCAL Props IS OleProps
	LOCAL oWindow AS OBJECT
	LOCAL hDocWnd, hFrameWnd AS PTR
	LOCAL hTemp AS PTR


	IF IsNil(lDataAware) .AND. !IsInstanceOf(SELF, #OLEControl)
		lDataAware := TRUE
	ENDIF


	IF IsInstanceOfUsual(xID, #ResourceID)
		SUPER(oOwner, xID, oPoint, oDimension, , WS_BORDER, lDataAware)
	ELSE
		IF !IsLong(xID)
			xID := 1
		ENDIF
		IF !IsInstanceOf(oPoint, #Point)
			oPoint := Point{0, 0}
		ENDIF
		IF !IsInstanceOf(oDimension, #Dimension)
			oDimension := Dimension{20, 20}
		ENDIF
		SUPER(oOwner, xID, oPoint, oDimension, __WCOleContWindowClass, WS_BORDER, lDataAware)
	ENDIF


	oWindow := oOwner


	IF IsInstanceOf(oWindow, #DataWindow) .AND. !IsInstanceOf(oWindow:Owner, #Window) // Standard SDI
		hFrameWnd := oWindow:Handle()
		hDocWnd   := oWindow:__FormWindow:Handle()
	ELSE // everything else
		hDocWnd := oWindow:Handle()
		DO WHILE (oWindow != NULL_OBJECT) .AND. ;
			!IsInstanceOf(oWindow, #ShellWindow) .AND. ;
			!IsInstanceOf(oWindow, #TopAppWindow) .AND. ;
			!IsInstanceOf(oWindow, #App)
			oWindow := oWindow:Owner
		ENDDO


		IF IsInstanceOf(oWindow, #Window)
			hFrameWnd := oWindow:Handle()
		ENDIF


		IF !IsWindow(hFrameWnd)
			hFrameWnd := hDocWnd
		ENDIF
	ENDIF


	IF (_VOOLEInitObject(SELF:Handle(), hDocWnd, hFrameWnd, PTR(_CAST, oParent), @hTemp))
		SELF:ObjHandle := hTemp
		UnregisterAxit(SELF)
		Props:dwSelector := OLEPROP_ALLOWINPLACE + OLEPROP_ACTIVATEONDBLCLK ;
			+OLEPROP_ALLOWRESIZE + OLEPROP_AUTOSIZEONCREATE + OLEPROP_READONLY


		Props:fActivateOnDblClk := TRUE
		_VOOLESetProps(SELF:ObjHandle, @Props)
	ENDIF


	SELF:lCreated := FALSE


	RETURN 


/// <include file="Gui.xml" path="doc/OleObject.IsInPlaceActive/*" />
ACCESS IsInPlaceActive 
	LOCAL Props IS OleProps


	_VOOLEGetProps(SELF:ObjHandle, @Props)
	RETURN Props:fIsActive


/// <include file="Gui.xml" path="doc/OleObject.LongName/*" />
ACCESS LongName 
	RETURN SELF:__GetName(USERCLASSTYPE_FULL)


/// <include file="Gui.xml" path="doc/OleObject.ReadOnly/*" />
ACCESS ReadOnly 
	LOCAL Props IS OleProps


	_VOOLEGetProps(SELF:ObjHandle, @Props)
	RETURN Props:fReadOnly


/// <include file="Gui.xml" path="doc/OleObject.ReadOnly/*" />
ASSIGN ReadOnly(fNewValue) 
	LOCAL Props IS OleProps


	Props:dwSelector := OLEPROP_READONLY
	Props:fReadOnly := fNewValue
	_VOOLESetProps(SELF:ObjHandle, @Props)
	RETURN 


/// <include file="Gui.xml" path="doc/OleObject.Redraw/*" />
METHOD Redraw() 
 	//_DebOut32(PSZ(__ENTITY))
	RETURN _VOOLERedrawObject(SELF:ObjHandle)


/// <include file="Gui.xml" path="doc/OleObject.RePaint/*" />
METHOD RePaint() 
 	//_DebOut32(PSZ(__ENTITY))
	InvalidateRect(hWnd, NULL_PTR, TRUE)
	RETURN NIL


/// <include file="Gui.xml" path="doc/OleObject.SaveToDBStorage/*" />
METHOD SaveToDBStorage(oOleDBStg) 
	RETURN _VOOLESaveToDBStorage(SELF:ObjHandle, oOleDBStg:RootStorage, oOleDBStg:SubStorageName)


/// <include file="Gui.xml" path="doc/OleObject.ServerName/*" />
ACCESS ServerName 
	RETURN SELF:__GetName(USERCLASSTYPE_APPNAME)


/// <include file="Gui.xml" path="doc/OleObject.SetHostNames/*" />
METHOD SetHostNames(cApp, cDoc) 
	RETURN _VOOLESetHostNames(SELF:ObjHandle, String2Psz(cApp), String2Psz(cDoc))


/// <include file="Gui.xml" path="doc/OleObject.ShortName/*" />
ACCESS ShortName 
	RETURN SELF:__GetName(USERCLASSTYPE_SHORT)


/// <include file="Gui.xml" path="doc/OleObject.UpdateTools/*" />
METHOD UpdateTools() 
	//_DebOut32(PSZ(__ENTITY))
	RETURN _VOOLEUpdateTools(SELF:ObjHandle)




END CLASS


 /// <exclude />
PROCEDURE __WCRegisterOleContWindow _INIT3
	LOCAL wc IS _WINWNDclass


	wc:style 		:= _OR(CS_DBLCLKS, CS_GLOBALCLASS)
#ifdef __VULCAN__
   LOCAL hDll := LoadLibraryW( "user32.dll" ) AS PTR
	wc:lpfnWndProc 	:= GetProcAddress( hDll, String2Psz( "DefWindowProcA" ) )
	FreeLibrary( hDll )
#else	
	wc:lpfnWndProc 	:= @DefWindowProc()
#endif	
	wc:hInstance 	:= _GetInst()
	wc:hIcon 		:= NULL_PTR // LoadIcon(0, IDI_APPLICATION)
	wc:hCursor 		:= LoadCursor(0, IDC_Arrow)
	wc:hbrBackground := (COLOR_WINDOW + 1)
	wc:lpszClassName := String2Psz(__WCOleContWindowClass)
	wc:cbWndExtra 	:= 0
	wc:cbClsExtra 	:= 0


	RegisterClass(@wc)
	RETURN
	
	
#endif
