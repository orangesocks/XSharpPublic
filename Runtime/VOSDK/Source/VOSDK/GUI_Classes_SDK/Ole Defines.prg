/// <exclude/>
VOSTRUCT OleProps
	MEMBER dwSelector AS DWORD
	MEMBER fAllowInPlace AS LOGIC
	MEMBER fActivateOnDblClk AS LOGIC
	MEMBER fAllowResize AS LOGIC
	MEMBER fAutoSizeOnCreate AS LOGIC
	MEMBER fReadOnly AS LOGIC
	MEMBER fIsActive AS LOGIC
	MEMBER fAllowDocView AS LOGIC


 /// <exclude />
FUNCTION __OleDropTargetCallback(DragInfo AS OleDragEventInfo) AS LOGIC /* WINCALL */
	LOCAL oAppWnd   AS AppWindow
	LOCAL oWnd      AS OBJECT
	LOCAL oOleDragEvent AS OleDragEvent
	LOCAL lRet AS USUAL
    // RvdH 080814 Added the methods to the AppWindow class, so we could 
    // get rid of the IsMethod checks
	lRet := FALSE


	oWnd := __WCGetWindowByHandle(DragInfo:hDocWnd):owner
	IF !IsInstanceOf(oWnd, #AppWindow)
		RETURN lRet
	ENDIF
    oAppWnd := oWnd
	oOleDragEvent := OleDragEvent{DragInfo}
	DO CASE
	CASE DragInfo:dwDragEvent = OLE_DDEVENT_DRAGENTER
		//IF IsMethod(oAppWnd, #OleDragEnter)
			lRet := oAppWnd:OleDragEnter(oOleDragEvent)
		//ENDIF
	CASE DragInfo:dwDragEvent = OLE_DDEVENT_DRAGLEAVE
		//IF IsMethod(oAppWnd, #OleDragLeave)
			lRet := oAppWnd:OleDragLeave(oOleDragEvent)
		//ENDIF
	CASE DragInfo:dwDragEvent = OLE_DDEVENT_DRAGOVER
		//IF IsMethod(oAppWnd, #OleDragOver)
			lRet := oAppWnd:OleDragOver(oOleDragEvent)
		//ENDIF
	CASE DragInfo:dwDragEvent = OLE_DDEVENT_DROP
		//IF IsMethod(oAppWnd, #OleDrop)
			lRet := oAppWnd:OleDrop(oOleDragEvent)
		//ENDIF
	ENDCASE
	DragInfo:dwEffect := DWORD(_CAST, oOleDragEvent:Effect)


	IF UsualType(lRet) != LOGIC
		lRet := FALSE
	ENDIF
	RETURN lRet


 /// <exclude />
FUNCTION __OleStatusCallback(hwnd AS PTR, StatusMsg AS PSZ) AS DWORD /* WINCALL */
	LOCAL oShellWindow AS OBJECT


	oShellWindow := __WCGetWindowByHandle(hwnd)
	IF (oShellWindow != NULL_OBJECT) .AND. IsInstanceOf(oShellWindow, #ShellWindow)
		IF IsMethod(oShellWindow, #OnOleStatusMessage)
			oShellWindow:OnOleStatusMessage(Psz2String(StatusMsg))
			RETURN 0
		ENDIF
	ENDIF
	RETURN 1


	// RvdH 030815 Moved method to AppWindow Module
	//METHOD EnableOleDropTarget(lEnable) CLASS AppWindow
	//   IF (lEnable)
	//      RETURN _VOOLERegisterDropTargetCallback(SELF:owner:handle(), SELF:Handle(), @__OleDropTargetCallback())
	//   ELSE
	//      RETURN _VOOLERegisterDropTargetCallback(SELF:owner:handle(), SELF:Handle(), NULL_PTR)
	//   ENDIF


	//RvdH 030825 Moved function below to the module CavoOle
	//FUNCTION DeleteStorage(cFileName, cStorage) AS LOGIC
	//   RETURN _VOOLEDeleteStorage(String2Psz(cFileName), String2Psz(cStorage))






#region defines
DEFINE OLEPROP_ACTIVATEONDBLCLK := 0x00000002L
//RvdH 030825 This code has been moved from the Ole Classes
DEFINE OLEPROP_ALLOWDOCVIEW := 0x00000040L
DEFINE OLEPROP_ALLOWINPLACE := 0X00000001L
DEFINE OLEPROP_ALLOWRESIZE := 0x00000004L
DEFINE OLEPROP_AUTOSIZEONCREATE := 0x00000008L
DEFINE OLEPROP_ISACTIVE := 0x00000020L
DEFINE OLEPROP_READONLY := 0x00000010L
DEFINE USERclassTYPE_APPNAME := 3
DEFINE USERclassTYPE_FULL := 1
DEFINE USERclassTYPE_SHORT := 2
//DEFINE DROPEFFECT_COPY := 1
//DEFINE DROPEFFECT_LINK := 4
//DEFINE DROPEFFECT_MOVE := 2
//DEFINE DROPEFFECT_NONE := 0
DEFINE IDM_OLE_CONVERT := 57343
DEFINE IDM_OLE_VERB_FIRST := 57280
DEFINE IDM_OLE_VERB_LAST := 57342
DEFINE MAX_NAME := 260
DEFINE OLE_DDEVENT_DRAGENTER := 1
DEFINE OLE_DDEVENT_DRAGLEAVE := 2
DEFINE OLE_DDEVENT_DRAGOVER := 3
DEFINE OLE_DDEVENT_DROP := 4
DEFINE OLECMDEXECOPT_DODEFAULT := 0
DEFINE OLECMDEXECOPT_DONTPROMPTUSER := 2
DEFINE OLECMDEXECOPT_PROMPTUSER := 1
DEFINE OLECMDEXECOPT_SHOWHELP := 3
DEFINE OLECMDID_CLEARSELECTION := 18
DEFINE OLECMDID_COPY := 12
DEFINE OLECMDID_CUT := 11
DEFINE OLECMDID_GETZOOMRANGE := 20
DEFINE OLECMDID_HIDETOOLBARS := 24
DEFINE OLECMDID_NEW := 2
DEFINE OLECMDID_OPEN := 1
DEFINE OLECMDID_PAGESETUP := 8
DEFINE OLECMDID_PASTE := 13
DEFINE OLECMDID_PASTESPECIAL := 14
DEFINE OLECMDID_PRINT := 6
DEFINE OLECMDID_PRINTPREVIEW := 7
DEFINE OLECMDID_PROPERTIES := 10
DEFINE OLECMDID_REDO := 16
DEFINE OLECMDID_REFRESH := 22
DEFINE OLECMDID_SAVE := 3
DEFINE OLECMDID_SAVEAS := 4
DEFINE OLECMDID_SAVECOPYAS := 5
DEFINE OLECMDID_SELECTALL := 17
DEFINE OLECMDID_SETDOWNLOADSTATE := 29
DEFINE OLECMDID_SETPROGRESSMAX := 25
DEFINE OLECMDID_SETPROGRESSPOS := 26
DEFINE OLECMDID_SETPROGRESSTEXT := 27
DEFINE OLECMDID_SETTITLE := 28
DEFINE OLECMDID_SPELL := 9
DEFINE OLECMDID_STOP := 23
DEFINE OLECMDID_STOPDOWNLOAD := 30
DEFINE OLECMDID_UNDO := 15
DEFINE OLECMDID_UPDATECOMMANDS := 21
DEFINE OLECMDID_ZOOM := 19
#endregion
