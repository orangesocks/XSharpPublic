

USING System.Windows.Forms.VisualStyles
USING VOSDK := XSharp.VO.SDK
CLASS DataWindow INHERIT ChildAppWindow IMPLEMENTS ILastFocus
	PROTECT sCurrentView AS SYMBOL
	PROTECT nCCMode AS INT
	PROTECT nLastLock AS INT
	
	//PROTECT lKickingTheBucket AS LOGIC
	PROTECT lChanged AS LOGIC
	PROTECT lLinked AS LOGIC
	PROTECT lControlsEnabled AS LOGIC
	PROTECT lSubForm AS LOGIC
	PROTECT lTopApp AS LOGIC
	PROTECT lAlreadyHasFlock AS LOGIC
	PROTECT lRecordDirty AS LOGIC
	PROTECT lDeleted AS LOGIC
	PROTECT lValidFlag AS LOGIC
	PROTECT lPreventAutoLayout AS LOGIC
	PROTECT lDeferUse AS LOGIC
	PROTECT oDeferUseServer AS DataServer
	PROTECT lAutoScroll AS LOGIC
	
	PROTECT aSubForms AS ARRAY
	PROTECT aControls AS ARRAY
	PROTECT aConditionalControls AS ARRAY
	PROTECT aRadioGroups AS ARRAY
	
	//PROTECT oFormFrame AS __FormFrame
	PROTECT oGBrowse AS DataBrowser

	PROTECT oHLStatus AS HyperLabel
	PROTECT oSurface AS VOSurfacePanel
	PROTECT oFrame	 as VOFramePanel
	PROTECT oAttachedServer AS DataServer
	PROTECT oDCCurrentControl AS OBJECT
	PROTECT oDCInvalidControl AS Control
	PROTECT oDCInvalidColumn AS DataColumn
	PROTECT lPendingToolBarShow AS LOGIC
	PROTECT lAllowServerClose AS LOGIC
	PROTECT symBrowserClass AS SYMBOL
	PROTECT symFormDialog AS SYMBOL
	PROTECT dwDialogStyle  AS DWORD //SE-070906
	PROTECT oLastFocus AS Control
	PROTECT oResourceID 	AS ResourceID


	INTERNAL lInAutoLayout AS LOGIC

	METHOD __CreateForm() AS VOForm STRICT
		LOCAL oDw AS VODataForm
		SELF:__ReadResource(oResourceID, oParent)
		IF oShell != NULL_OBJECT
			oDw := GuiFactory.Instance:CreateDataForm(SELF, oShell:__Form, SELF:oResourceDialog)
		ELSE
			oDw := GuiFactory.Instance:CreateDataForm(SELF, NULL_OBJECT, SELF:oResourceDialog)
		ENDIF
		SELF:oSurface := oDw:Surface
		SELF:oFrame	  := oDw:Frame
		RETURN oDw

	ACCESS __DataForm AS VODataForm 
		RETURN (VODataForm) SELF:__Form


	ACCESS __Frame AS VOFramePanel
		RETURN SELF:oFrame 


	[Obsolete];
	METHOD __AdjustForm() AS VOID STRICT 
		//Resizing happens automatically in the DataWinForm class
		RETURN 

	[Obsolete];
	METHOD __AdjustSurface() AS LOGIC STRICT 
		//Resizing happens automatically in the DataWinForm class
		RETURN TRUE

	ACCESS __aRadioGroups AS ARRAY STRICT 
		RETURN aRadioGroups
	
	METHOD __AutoCreateBrowser() AS DataWindow STRICT 
		IF oGBrowse == NULL_OBJECT
			IF symBrowserClass == #DataBrowser
				oGBrowse := DataBrowser{SELF}
				SELF:__DataForm:DataBrowser := oGBrowse:__Control
				//ELSEIF symBrowserClass == #DataListView
				//	oGBrowse := DataListView{SELF}
			ELSE
				oGBrowse := CreateInstance(symBrowserClass, SELF)
			ENDIF
		ENDIF
		DO CASE
		CASE (sCurrentView == #ViewSwitch)
			Send(oGBrowse, #__NOTIFYChanges, GBNFY_VIEWSWITCH)
		CASE (sCurrentView == #BrowseView)
			Send(oGBrowse, #__NOTIFYChanges, GBNFY_VIEWASBROWSER)
		CASE (sCurrentView == #FormView)
			Send(oGBrowse ,#__NOTIFYChanges, GBNFY_VIEWASFORM)
		END CASE
		
		IF (lLinked .and. oAttachedServer != NULL_OBJECT)
			Send(oGBrowse, #Use, oAttachedServer)
		ENDIF
		
		RETURN SELF
	

	METHOD __AutoLayout() AS DataWindow STRICT 
		LOCAL cField AS STRING
		LOCAL oDFField AS OBJECT
		LOCAL liFieldLen AS LONGINT
		LOCAL liStart AS LONGINT
		LOCAL liFields, liField, liLines AS LONGINT
		LOCAL newControl AS Control
		LOCAL oPoint AS Point
		LOCAL oDimension AS Dimension
		LOCAL oLabelDim AS Dimension
		LOCAL maxLblSize AS INT
		LOCAL maxFldSize AS INT
		LOCAL maxEditSize AS INT
		LOCAL editHeight AS INT
		LOCAL editGap AS INT
		LOCAL cType AS STRING
		LOCAL arUsedKeys AS ARRAY
		LOCAL lOleAvail := TRUE AS LOGIC
		LOCAL lMCAvail := TRUE
		LOCAL lOleWarningShown := FALSE AS LOGIC
		LOCAL lBidi := IsBiDi() AS LOGIC
		LOCAL iMaxWidth AS INT
		LOCAL iNewWidth AS INT 
		LOCAL CoordinateSystem AS LOGIC
		LOCAL iFontWidth AS INT
		
		IF lPreventAutoLayout
			RETURN SELF
		ENDIF
		lInAutoLayout := TRUE
		CoordinateSystem := WC.CoordinateSystem
		WC.CoordinateSystem := WC.WindowsCoordinates
		SELF:oSurface:SuspendLayout()
		
		//RvdH 070415 limited iMMaxWidth to half the width of the desktop (and not two third)
		iMaxWidth := System.Windows.Forms.Screen.GetWorkingArea(__Form):Width /2
		
		__DataForm:AutoLayout := TRUE
		__DataForm:ResetMinSize()
		
		arUsedKeys := {}
		
		// get Textmetric through Font
		// approx. - there is no width in font, use of VisualStyle Renderer Crashes in Windows Classic Scheme and getting the textmetrics through handle is not an option 
		// since the window is shown when the handle is created
		iFontWidth := SELF:oSurface:Font:Height 
		editHeight := iFontWidth + 4
		editGap := editHeight + 6
		
		// Find maximum field label size && number of lines
		liFields := (LONG) oAttachedServer:FCount
		FOR liField := 1 UPTO liFields
			oDFField := oAttachedServer:DataField(liField)
			IF (oDFField == NULL_OBJECT)
				LOOP
			ENDIF
			
			cType := oDFField:FieldSpec:ValType
			IF (cType != "O") .OR. lOleAvail
				liLines++
				cField 		:= __GetDFCaption(oDFField,{})
				oDimension := SELF:SizeText(cField)
				IF (oDimension:Width > maxLblSize)
					maxLblSize := oDimension:Width
					oLabelDim := oDimension
				ENDIF
				IF (cType == "M")
					liLines += 1
				ELSEIF ((cType == "O") .AND. lOleAvail) .OR. (cType == "X")
					liLines += 6
				ELSE
					maxFldSize := Max(maxFldSize, oDFField:FieldSpec:Length)
				ENDIF
			ELSEIF !lOLEWarningShown
				TextBox{SELF, ResourceString{__WCSWarning}:Value, ResourceString{__WCSNoOLESupport}:Value, BUTTONOKAY}:Show()
				lOleWarningShown := TRUE
			ENDIF
		NEXT //liStart
		
		//// Add the fields
		liField := 0
		maxEditSize := Min(iMaxWidth, (maxFldSize+1) * iFontWidth)
		
		oPoint := Point{IIF(lBidi, (25 + maxEditSize), 20), 0}
		
		FOR liStart:=1 UPTO liLines
			// get next datafield
			oDFField := NULL_OBJECT
			WHILE (oDFField == NULL_OBJECT) .AND. (liField <= liFields)
				liField++
				oDFField := SELF:oAttachedServer:DataField(liField)
			ENDDO
			
			IF liField>liFields
				EXIT
			ENDIF
			
			// Create label
			cType := oDFField:FieldSpec:ValType
			
			IF (cType != "O") .OR. lOleAvail
				cField := __GetDFCaption(oDFField,arUsedKeys)
				oPoint:Y := editGap * (liStart-1)
				newControl := FixedText{SELF, (100 + liField), oPoint, oLabelDim, cField}
				newControl:Show()
				
				// Create Data control
				liFieldLen := __GetFSDefaultLength(oDFField:FieldSpec)
				
				// get the new width first (we need that for BiDi)
				DO CASE
				CASE cType=="L"
					iNewWidth := 4*iFontWidth
				CASE cType=="M"
					iNewWidth := (maxFldSize+1)*iFontWidth
				CASE cType=="O" .OR. cType=="X"
					iNewWidth := 300
				CASE cType=="D" .AND. lMCAvail
					iNewWidth := 190
				OTHERWISE
					IF (cType == "C")
						iNewWidth := Max(liFieldLen, 2) * iFontWidth
					ELSE
						iNewWidth := (liFieldLen +1 ) * iFontWidth
					ENDIF
				ENDCASE
				
				IF (lBidi)
					// s.b. We have to add this otherwise the "C" type fields overlap the text captions.
					oPoint:X := 20 + maxEditSize - Min(iMaxWidth, iNewWidth)
				ELSE
					oPoint:X := 25 + maxLblSize
				ENDIF
				
				oPoint:Y := editGap * (liStart-1)
				
				DO CASE
				CASE cType=="L"
					newControl := CheckBox{SELF, 200+liField, oPoint, Dimension{iNewWidth, editHeight}, " ", BS_AUTOCHECKBOX}
				CASE cType=="M"
					liStart += 1
					oPoint:Y := editGap * (liLines - liStart + 1)
					newControl := MultiLineEdit{SELF, 200+liField, oPoint, Dimension{iNewWidth, editHeight*2}, ES_AUTOVSCROLL}
					#ifdef USE_OLEOBJECT	
				CASE cType=="O"
					liStart += 6
					oPoint:Y := editGap * (liLines - liStart + 1)
					oOle := OleObject{ SELF, 200+liField, oPoint, Dimension{iNewWidth, editGap*6+editHeight}, TRUE} 
					newControl := oOle
					oOle:AutoSizeOnCreate := FALSE
					oOle:AllowInPlace:= !IsInstanceOf(SELF, #DataDialog) /*.and. IsInstanceOf(oParent, #ShellWindow)*/
					oOle:ActivateOnDblClk:=  TRUE
					oOle:AllowResize:=  TRUE
					#endif				
				CASE cType=="X"
					liStart += 6
					oPoint:Y := editGap * (liLines - liStart + 1)
					newControl := MultiMediaContainer{SELF, 200+liField, oPoint, Dimension{iNewWidth, editGap*6+editHeight}}
				CASE cType=="D" .AND. lMCAvail
					newControl := DateTimePicker{SELF, 200+liField, oPoint, Dimension{iNewWidth, editHeight}, DTS_LONGDATEFORMAT}
				OTHERWISE
					IF (iNewWidth < iMaxWidth)
						newControl := SingleLineEdit{SELF, 200+liField, oPoint, Dimension{iNewWidth, editHeight}}
					ELSE
						newControl := SingleLineEdit{SELF, 200+liField, oPoint, Dimension{iMaxWidth, editHeight}, ES_AUTOHSCROLL}
					ENDIF
				ENDCASE
				// Link the data editor to the Server
				newControl:LinkDF(oAttachedServer, liField)
				// Show it
				newControl:Show()
				
				oPoint:X := IIF(lBidi, (25 + maxEditSize), 20)
			ENDIF
		NEXT
		SELF:oSurface:ResumeLayout()
		lInAutoLayout := FALSE
		WC.CoordinateSystem := CoordinateSystem
		__DataForm:AdjustFrameSize()
		
		RETURN SELF
	

	METHOD __CheckConditionalControls() AS DataWindow STRICT 
		LOCAL idx, iLen AS DWORD
		LOCAL oControl AS Control

		iLen := ALen(aControls)
		FOR idx :=1 TO iLen
			oControl := aControls[idx] 
			IF (oControl:Status != NULL_OBJECT)
				EXIT
			ENDIF
		NEXT
		
		IF !IsNil(oHLStatus) .OR. (idx != (iLen+1))
			SELF:DisableConditionalControls()
		ELSE
			SELF:EnableConditionalControls()
		ENDIF
		RETURN SELF
	

	METHOD __CheckRecordStatus() AS LOGIC STRICT 
		LOCAL oOldStatus AS HyperLabel
		LOCAL oTempStatus AS HyperLabel
		
		oOldStatus := oHLStatus
		
		IF (IsNil(oAttachedServer))
			oHLStatus := HyperLabel{#NoAttachedServer, #NoAttachedServer}
		ELSE
			SELF:__UpdateCurrent()
			IF !SELF:StatusOK()
				IF (sCurrentView == #FormView)
					IF (oDCInvalidControl != NULL_OBJECT)
						oTempStatus:=oHLStatus //Save status accross SetFocus
						oDCInvalidControl:SetFocus()
						oHLStatus := oTempStatus
					ENDIF
				ELSEIF (sCurrentView == #BrowseView)
					// Jump to error column for browse view
					IF (oDCInvalidColumn != NULL_OBJECT) .AND. IsMethod(oGBrowse, #SetColumnFocus)
						Send(oGBrowse, #SetColumnFocus, oDCInvalidColumn)
					ENDIF
				ENDIF
			ELSE
				IF !SELF:ValidateRecord()	//RH ValidateRecord is defined in our patches
					IF IsNil(oHLStatus)
						oHLStatus := HyperLabel{#InvalidRecord, #RecInvalid}
					ENDIF
				ENDIF
			ENDIF
			// Prevalidate based on status change
			IF (oHLStatus != oOldStatus)
				SELF:PreValidate()
			ENDIF
		ENDIF
		IF (!IsNil(oHLStatus))
			SELF:__UpdateStatus()
			RETURN FALSE
		ENDIF
		
		RETURN TRUE
	

	METHOD __Delete() AS LOGIC STRICT 
		// DataWindow : Delete
		// This method deletes the current record.
		// Depending on the setting of SET DELETE, the record may or may not be still
		// available for viewing. If SET DELETE is set to ON, the record will not be shown
		// in subsequent browsing of the DataServer.
		
		LOCAL lRetCode := FALSE AS LOGIC
		
		oHLStatus:= NULL_OBJECT // assume success
		IF oAttachedserver!=NULL_OBJECT
			IF SELF:__CheckRecordStatus()
				lRetCode := oAttachedServer:@@Delete()
				IF lRetCode
					IF SetDeleted() .OR. IsInstanceOf(oAttachedServer,#SQLSelect)
						SELF:Skip(1)
						oHLStatus:=oAttachedServer:Status
						IF oAttachedServer:EoF
							SELF:Skip(-1)
							oHLStatus:=oAttachedServer:Status
						ENDIF
					ENDIF
				ELSE
					oHLStatus:=oAttachedServer:Status
					IF IsNil(oHLStatus) // need default status info
						oHLStatus := HyperLabel { #NoDelete, ResourceString{__WCSDeleteFailed}:Value, ResourceString{__WCSDeleteFailedMSG}:Value}
					ENDIF
				ENDIF
			ELSE
				oHLStatus:=oAttachedServer:Status
			ENDIF
		ENDIF
		RETURN SELF:__UpdateStatus()
	
	

	METHOD __DoValidate(oControl AS Control) AS DataWindow STRICT 
		//RH Check fore Server on control in stead of Server on window
		LOCAL oServer AS DataServer
		IF oControl is RadioButton
			FOREACH oRBG AS RadioButtonGroup IN aRadioGroups
			
				IF oRBG:__IsElement( (RadioButton) oControl)
					oControl:__Update()
					oControl := oRBG
					EXIT
				ENDIF
			NEXT //dwI
		ENDIF
		
		IF oControl:Modified .or. oControl:ValueChanged
			oControl:__Update()
			IF oControl:ValueChanged
				IF !oControl:PerformValidations()
					oHLStatus := oControl:Status
					SELF:__UpdateStatus()
				ELSE
					oHLStatus := oControl:Status
					SELF:@@StatusMessage(NULL_STRING, MessageError)
					oServer := oControl:Server
					IF oServer != NULL_OBJECT
						IF !oControl:__Gather()
							oHLStatus := oServer:Status
							SELF:__UpdateStatus()
						ENDIF
					ENDIF
				ENDIF
				SELF:PreValidate()
			ENDIF
		ENDIF
		
		RETURN SELF
	

	METHOD __EnableHelpCursor(lEnabled AS LOGIC) AS Window STRICT 
		RETURN SUPER:__EnableHelpCursor(lEnabled)
	

	METHOD __FindControl(symName AS SYMBOL) AS Control STRICT 
		FOREACH oControl  AS Control IN aControls
			IF oControl:NameSym == symName
				RETURN oControl
			ENDIF
		NEXT  // dwI
		
		RETURN NULL_OBJECT
	

	METHOD __FindFieldSpec(SymName AS SYMBOL) AS FieldSpec STRICT 
		LOCAL oControl AS Control

		IF (oControl := SELF:__FindControl(SymName)) != NULL_OBJECT
			RETURN oControl:FieldSpec
		ENDIF
		
		RETURN NULL_OBJECT
	

	METHOD __FindHyperLabel(SymName AS SYMBOL) AS HyperLabel STRICT 
		LOCAL oControl AS Control
		
		IF (oControl := SELF:__FindControl(SymName)) != NULL_OBJECT
			RETURN oControl:HyperLabel
		ENDIF
		
		RETURN NULL_OBJECT
	

	METHOD __Gather() AS LOGIC STRICT 
		
		FOREACH oControl AS Control IN aControls
			oControl:__Gather()
		NEXT
		
		RETURN IsNil(oHLStatus)
	

	METHOD __GetFormSurface() AS VOSurfacePanel STRICT 
		RETURN oSurface
	

	METHOD __GetOLEObject(symMethod AS SYMBOL) AS DataWindow STRICT 
		#ifdef USE_OLEOBJECT	
		//RvdH 030825 Methods moved from Ole Classes
		LOCAL hFocus := GetFocus() AS PTR
		LOCAL oOle AS OleObject
		LOCAL dwI, dwCount AS DWORD
		LOCAL oControl AS Control
		LOCAL lRet AS LOGIC
		
		// neccessary???
		//SE-060526
		dwCount := ALen(aControls)
		FOR dwI := 1 UPTO dwCount
			oControl := aControls[dwI]
			IF oControl:Handle() == hFocus
				oControl := aControls[dwI]
				EXIT
			ENDIF
		NEXT  // dwI
		
		IF IsInstanceOf(oControl, #OleObject)
			oOle := OBJECT(_CAST, oControl)
			oOle:DetachFromServer()
			lRet := Send(oOle, symMethod)
			IF (oAttachedServer != NULL_OBJECT) .AND. (oOle:__GetDataFldPos > 0)
				IF (lRet)
					oOle:ValueChanged :=TRUE
					oOle:Modified :=TRUE
					oAttachedServer:RLOCK()
					SELF:FIELDPUT(oOle:__GetDataFldPos, oOle)
					oOle:__Scatter() // ???!!! correct ??
					oAttachedServer:Unlock()
				ELSE
					oOle:__Scatter() // ???!!! correct ??
				ENDIF
			ENDIF
			oOle:RePaint()
		ELSE
			MessageBox(0, String2Psz(ResourceString{IDS_NOINSERT}:VALUE),;
			String2Psz(ResourceString{IDS_OLERUNTIME}:VALUE),;
			_OR(MB_OK, MB_ICONHAND))
		ENDIF
		#endif
		RETURN SELF
	

	METHOD __HandleScrolling(oEvent AS OBJECT) AS DataWindow STRICT 
		LOCAL oControl AS OBJECT
		
		DO CASE
		CASE oEvent IS ScrollEvent
			oControl := ((ScrollEvent)oEvent):ScrollBar
		CASE oEvent IS SpinnerEvent
			oControl := ((SpinnerEvent)oEvent):Spinner
		CASE oEvent IS SliderEvent
			oControl := ((SliderEvent)oEvent):Slider
		ENDCASE
		
		IF (oControl != NULL_OBJECT)
			oControl:ThumbPosition := oEvent:Position
			oControl:Modified := TRUE // assume its modified
			SELF:__DoValidate(oControl)
		ENDIF
		
		RETURN SELF
	

	METHOD __RegisterFieldLinks(oDataServer AS DataServer) AS LOGIC STRICT 
		LOCAL oDC AS Control
		LOCAL dwIndex, dwControls AS DWORD
		LOCAL siDF AS LONG
		
		
		dwControls := ALen(aControls)
		IF dwControls > 0
			FOR dwIndex := 1 UPTO dwControls
				IF IsInstanceOfUsual(aControls[dwIndex], #Control)
					oDC := aControls[dwIndex]
					siDF := oDataServer:FieldPos(oDC:NameSym)
					IF siDF > 0 .AND. IsNil(oDC:Server) // Only one datafield per control
						oDC:LinkDF(oDataServer, siDF) // Exit here, only one control per
						lLinked := TRUE
					ENDIF
				ENDIF
			NEXT
		ELSE
			// Only autolayout if there are _no_ controls
			IF ALen(SELF:GetAllChildren()) == 0
				SELF:__AutoLayout()
				lLinked := TRUE
			ENDIF
		ENDIF
		
		IF lLinked
			oDataServer:RegisterClient(SELF)
		ENDIF
		
		RETURN lLinked
	

	METHOD __RegisterSubform(oSubForm AS DataWindow) AS DataWindow STRICT 
		AAdd(aSubForms, oSubForm)
		SELF:oSurface:Controls:Add(oSubForm:__Frame)
		// Set the parent of the __DataForm of the Subwindow to our parent
		oSubForm:__DataForm:Owner := SELF:__DataForm:Owner
		RETURN SELF
	

	METHOD __Scatter() AS DataWindow STRICT 
		
		IF (sCurrentView == #FormView)
			FOREACH oControl AS Control IN aControls
				oControl:__Scatter()
			NEXT
			lRecordDirty := FALSE
			SELF:PreValidate()
		ELSEIF (oGBrowse != NULL_OBJECT)
			Send(oGBrowse, #__RefreshData)
			lRecordDirty := FALSE
			SELF:PreValidate()
		ENDIF
		
		RETURN SELF



	METHOD __SetupDataControl(oDC AS Control) AS VOID
		IF IsInstanceOfUsual(oDC, #RadioButtonGroup)
			AAdd(aRadioGroups, oDC)
		ENDIF
		
		IF __DataForm:AutoLayout .AND. !(oDC IS FixedText)
			oDC:SetStyle(WS_TabStop)
		ENDIF
		AAdd(aControls, oDC)
		
		RETURN 
	

	METHOD __SetupNonDataControl(oDC AS Control) AS VOID
		IF __DataForm:AutoLayout .AND. !(oDC IS FixedText)
			oDC:SetStyle(WS_TabStop)
		ENDIF
		
		RETURN 
	

	METHOD __StatusMessage(uDescription AS USUAL, nMode AS LONGINT) AS DataWindow STRICT 
		LOCAL uTemp AS USUAL
		
		
		IF IsInstanceOfUsual(uDescription, #HyperLabel)
			uTemp := uDescription:Description
			IF Empty(uTemp) .OR. IsNil(uTemp)
				uTemp := NULL_STRING
			ENDIF
		ELSE
			uTemp := uDescription
		ENDIF
		
		// sTmp is now a symbol or String
		
		IF IsSymbol(uTemp)
			uTemp := Symbol2String(uTemp)
		ELSEIF IsNil(uTemp)
			uTemp := NULL_STRING
		ENDIF
		
		IF !IsString(uTemp)
			uTemp := ResourceString{__WCSUnknownStatusMSG}:Value
		ENDIF
		SELF:@@StatusMessage(uTemp, nMode)
		RETURN SELF
	

	ACCESS __SubForm AS LOGIC STRICT 
		RETURN lSubForm
	
	
	ACCESS __HasSurface AS LOGIC
		RETURN TRUE

	ACCESS __Surface AS System.Windows.Forms.Control
		RETURN oSurface

	METHOD __Unlink() AS LOGIC STRICT 
		
		IF oAttachedServer == NULL_OBJECT
			RETURN FALSE
		ENDIF
		FOREACH oControl AS Control IN aControls
			oControl:__Unlink()
		NEXT

		IF oGBrowse != NULL_OBJECT
			oGBrowse:__Unlink()
		ENDIF
		oAttachedServer:UnRegisterClient(SELF, lAllowServerClose)
		oAttachedServer := NULL_OBJECT
		lLinked := FALSE
		
		RETURN TRUE
	

	METHOD __UnRegisterDataControl(oControl AS Control) AS DataWindow STRICT 
		LOCAL dwI, dwCount AS DWORD
		
		
		// test???
		//RETURN SELF
		
		dwCount := ALen(aControls)
		FOR dwI := 1 UPTO dwCount
			IF aControls[dwI] = oControl
				ADel(aControls, dwI)
				ASize(aControls, dwCount-1)
				EXIT
			ENDIF
		NEXT  // dwI
		
		dwCount := ALen(aConditionalControls)
		FOR dwI := 1 UPTO dwCount
			IF aConditionalControls[dwI] = oControl
				ADel(aConditionalControls, dwI)
				ASize(aConditionalControls, dwCount-1)
				EXIT
			ENDIF
		NEXT  // dwI
		
		dwCount := ALen(aRadioGroups)
		FOR dwI := 1 UPTO dwCount
			IF aRadioGroups[dwI] = oControl
				ADel(aRadioGroups, dwI)
				ASize(aRadioGroups, dwCount-1)
				EXIT
			ENDIF
		NEXT  // dwI
		
		RETURN SELF
	

	METHOD __UnRegisterSubform(oSubForm AS OBJECT) AS DataWindow STRICT  
		LOCAL dwI, dwCount AS DWORD
		
		
		
		dwCount := ALen(aSubForms)
		FOR dwI := 1 UPTO dwCount
			IF aSubForms[dwI] == oSubForm
				ADel(aSubForms, dwI)
				ASize(aSubForms, dwCount - 1)
				EXIT
			ENDIF
		NEXT  // dwI
		
		RETURN SELF
	

	METHOD __UpdateActiveObject() AS DataWindow STRICT 
		LOCAL oOle AS OBJECT
		LOCAL i AS DWORD
		LOCAL aObjects 	AS ARRAY
		aObjects := SELF:__GetMyOleObjects()
		FOR i:= 1 TO ALen(aObjects)
			oOle := aObjects[i]
			IF oOle:IsInPlaceActive
				oOle:UpdateTools()
			ENDIF
		NEXT
		RETURN SELF
	
	

	METHOD __UpdateCurrent() AS DataWindow STRICT 
		LOCAL oColumn AS OBJECT
		
		
		IF (sCurrentView == #FormView)
			IF oDCCurrentControl IS Control VAR oC  .AND. oC:Modified
				SELF:__DoValidate(oDCCurrentControl)
			ENDIF
		ELSEIF (sCurrentView == #BrowseView) .AND. IsAccess(oGBrowse, #CurrentColumn)
			oColumn := IVarGet(oGBrowse, #CurrentColumn)
			IF (IsInstanceOfUsual(oColumn, #DataColumn) .AND. oColumn:Modified)
				SELF:__DoValidate(oColumn)
			ENDIF
		ENDIF
		RETURN SELF
	

	METHOD __UpdateStatus() AS LOGIC STRICT 
		
		IF oHLStatus != NULL_OBJECT
			IF IsInstanceOfUsual(oHLStatus, #HyperLabel)
				SELF:__StatusMessage(ResourceString{__WCSError2}:Value + oHLStatus:Description, MESSAGEERROR)
			ENDIF
			RETURN FALSE
		ENDIF
		// No error
		SELF:__StatusMessage(NULL_STRING, MessageError)
		
		RETURN TRUE
	

	METHOD __VerifyDataServer(oDataServer AS USUAL) AS LOGIC STRICT 
		LOCAL dwParmType AS DWORD
		
		dwParmType := UsualType(oDataServer)
		IF dwParmType == STRING
			oAttachedServer := CreateInstance(String2Symbol("DBServer"), oDataServer)
			oAttachedServer:ConcurrencyControl := nCCMode
		ELSEIF dwParmType == SYMBOL
			oAttachedServer := CreateInstance(String2Symbol("DBServer"), oDataServer)
			oAttachedServer:ConcurrencyControl := nCCMode
		ELSEIF dwParmType == OBJECT
			IF IsInstanceOfUsual(oDataServer, #DataServer)
				oAttachedServer := oDataServer
			ELSEIF IsInstanceOfUsual(oDataServer, #FileSpec)
				oAttachedServer := CreateInstance(String2Symbol("DBServer"), oDataServer)
				oAttachedServer:ConcurrencyControl := nCCMode
			ELSE
				RETURN FALSE
			ENDIF
		ELSE
			RETURN FALSE
		ENDIF
		
		IF IsInstanceOf(oAttachedServer, #DBServer)
			//Use the Used access and not the Status access because the last
			//operation issued before the Use() method may have failed
			IF !IVarGet(oAttachedServer,#Used)
				oHLStatus := oAttachedServer:Status
				IF oHLStatus == NULL_OBJECT
					oHLStatus := HyperLabel{#Use, , VO_Sprintf(__WCSDSNotOpen, AsString(oAttachedServer), IVarGet(oAttachedServer,#FileSpec):FullPath)}
				ENDIF
				RETURN FALSE
			ENDIF
			ELSEIF IsInstanceOf(oAttachedServer, #SQLSelect) .AND. ; //For SQL Server, check for error
			oAttachedServer:Status != NULL_OBJECT .AND. ; //on the Init method
			IVarGet(oAttachedServer,#ErrInfo):FuncSym == #INIT
				oHLStatus := oAttachedServer:Status
			RETURN FALSE
		ENDIF
		
		RETURN TRUE
	
	METHOD Activate (oEvent)
		IF (oFrame != NULL_OBJECT)
			WC.AppSetDialogWindow(oFrame)
		ENDIF	

		RETURN SELF:Default(oEvent)


	ACCESS AllowServerClose AS LOGIC
		RETURN lAllowServerClose
	
	ASSIGN AllowServerClose(lNewVal as LOGIC) 
		lAllowServerClose := lNewVal
	

	METHOD Append() CLIPPER
		// Adds new record to DataWindow
		LOCAL lRetCode := FALSE AS LOGIC
		
		oHLStatus := NULL_OBJECT // assume success
		IF (oAttachedServer != NULL_OBJECT) .AND. SELF:__CheckRecordStatus()
			IF !(lRetCode := oAttachedServer:Append())
				oHLStatus := oAttachedServer:Status
				SELF:__UpdateStatus()
			ELSE
				lRecordDirty := TRUE
				// The notification procedure will set up the controls
			ENDIF
		ENDIF
		
		RETURN lRetCode
	

	ACCESS AutoScroll  AS LOGIC
		RETURN lAutoScroll
	

	ASSIGN AutoScroll(lNewValue AS LOGIC) 
		lAutoScroll := lNewValue
	

	ACCESS Background AS Brush
		
		//Only an optimization to avoid unneeded Window:PaintBackground() calls of
		//the DataWindow object itself or the __FormFrame.
		IF oSurface != NULL_OBJECT
			RETURN Brush{(Color)oSurface:BackColor}
		ENDIF
		
		RETURN NULL_OBJECT
	

	ASSIGN Background(oBrush as Brush) 
		
		//Only an optimization to avoid unneeded Window:PaintBackground() calls of
		//the DataWindow object itself or the __FormFrame.
		IF oSurface != NULL_OBJECT 
			IF oBrush != NULL_OBJECT
				oSurface:BackColor := oBrush:Color
			ENDIF
		ENDIF
		
		RETURN 
	

	ACCESS Browser AS DataBrowser
		IF IsInstanceOf(oGBrowse, #DataBrowser)
			RETURN oGBrowse
		ENDIF
		RETURN NULL_OBJECT
	

	ASSIGN Browser(oDataBrowser AS DataBrowser) 
		oGBrowse := oDataBrowser
		__DataForm:DataBrowser := oDataBrowser:__DataGridView
		RETURN 
	
	ACCESS BrowserClass  AS SYMBOL
		RETURN symBrowserClass
	

	ASSIGN BrowserClass(symNewClass AS SYMBOL) 
		symBrowserClass := symNewClass
	

	METHOD ButtonClick(oControlEvent) 
		LOCAL oButton AS Control
		LOCAL oWindow AS Window
		LOCAL dwI, dwCount AS DWORD
		LOCAL oRBG AS RadioButtonGroup
		LOCAL aRadioGrps AS ARRAY
		LOCAL lUnchanged AS LOGIC
		
		
		oButton := oControlEvent:Control
		
		IF IsInstanceOfUsual((OBJECT) oButton:Owner, #Window)
			oWindow := (Window) oButton:Owner
		ELSE
			oWindow := SELF
		ENDIF
		IF IsInstanceOf(oButton, #Button)
			oButton:Modified := TRUE // assume its modified
			IF IsInstanceOf(oButton, #RadioButton)
				//SE-060526
				aRadioGrps := IVarGet(oWindow, #__aRadioGroups)
				dwCount := ALen(aRadioGrps)
				FOR dwI := 1 UPTO dwCount
					oRBG := aRadioGrps[dwI]
					IF oRBG:__IsElement(OBJECT(_CAST,oButton))
						lUnchanged := oRBG:__AlreadyHasFocus(OBJECT(_CAST,oButton))
						oRBG:__SetOn(OBJECT(_CAST,oButton))
						EXIT
					ENDIF
				NEXT  // dwI
			ELSEIF !IsInstanceOf(oButton, #CheckBox)
				lUnchanged := TRUE
			ENDIF
			((DataWindow) oWindow):__DoValidate(oButton)
			oButton:ValueChanged := !lUnchanged
		ENDIF
		SUPER:ButtonClick(oControlEvent)
		RETURN SELF
	

	METHOD Cancel() 
		LOCAL lRetCode := FALSE AS LOGIC
		lRetCode := TRUE
		IF IsMethod(oAttachedServer,#Refresh)
			lRetCode := Send(oAttachedServer,#Refresh)
		ENDIF
		SELF:EndWindow()
		
		RETURN lRetCode
	

	METHOD CanvasErase() 
		
		IF oSurface != NULL_OBJECT
			oSurface:Invalidate()
		ENDIF
		RETURN SUPER:CanvasErase()
	

	ASSIGN Caption(sNewCaption AS STRING) 
		IF !lTopApp .AND. (lSubForm) // .or. !IsInstanceOf(oParent, #ShellWindow))
			RETURN 
		ENDIF
		SUPER:Caption := sNewCaption
	

	METHOD ChangeFont(uFont, lUpdate) 
		LOCAL oFont AS Font
		IF !IsInstanceOfUsual(uFont,#Font)
			WCError{#ChangeFont,#DataWindow,__WCSTypeError,uFont,1}:@@Throw()
		ENDIF
		oFont := uFont
		
		IF !IsNil(lUpdate)
			IF !IsLogic(lUpdate)
				WCError{#ChangeFont,#DataWindow,__WCSTypeError,lUpdate,2}:@@Throw()
			ENDIF
		ELSE
			lUpdate := FALSE
		ENDIF
		
		SELF:Font := oFont
		IF oSurface != NULL_OBJECT
			oSurface:Font := oFont:__Font
		ENDIF
		
		RETURN oFont
	

	METHOD CheckStatus() 
		LOCAL oOldStatus AS OBJECT
		
		
		oOldStatus := oHLStatus
		IF !SELF:StatusOK()
			IF sCurrentView == #FormView
				IF (oDCInvalidControl != NULL_OBJECT)
					oDCInvalidControl:SetFocus()
				ENDIF
			ELSEIF (sCurrentView == #BrowseView)
				IF (oDCInvalidColumn != NULL_OBJECT) .AND. IsMethod(oGBrowse, #SetColumnFocus)
					Send(oGBrowse, #SetColumnFocus, oDCInvalidColumn)
				ENDIF
			ENDIF
		ENDIF
		
		// Prevalidate based on status change
		IF (oHLStatus != oOldStatus)
			SELF:PreValidate()
		ENDIF
		
		IF (!IsNil(oHLStatus))
			SELF:__UpdateStatus()
			RETURN FALSE
		ENDIF
		
		RETURN TRUE
	

	METHOD Clear() 
		
		IF sCurrentView == #FormView
			IF IsInstanceOf(oDCCurrentControl, #SingleLineEdit) .OR. ;
				IsInstanceOf(oDCCurrentControl, #MultiLineEdit) .OR. ;
				IsInstanceOf(oDCCurrentControl, #EditWindow)
				oDCCurrentControl:__SetText(NULL_STRING)
			ELSEIF IsInstanceOf(oDCCurrentControl, #ControlWindow)
				IF oDCCurrentControl:Control != NULL_OBJECT .AND. IsMethod(oDCCurrentControl, #Clear)
					oDCCurrentControl:Control:__SetText(NULL_STRING)
				ENDIF
			ENDIF
		ELSEIF sCurrentView == #BrowseView
			IF (oGBrowse != NULL_OBJECT) .AND. IsMethod(oGBrowse, #Clear)
				Send(oGBrowse, #Clear)
			ENDIF
		ENDIF
		
		RETURN SELF
	

	METHOD ClearRelations 
		
		IF oAttachedServer!=NULL_OBJECT
			RETURN Send(oAttachedServer,#ClearRelation)
		ENDIF
		RETURN FALSE
	

	ACCESS ClipperKeys 
		
		
		
		RETURN FALSE
	

	ASSIGN ClipperKeys(lNewValue) 
		
		
		
		
		RETURN	
	

	METHOD Close(oEvent) 
		
		
		IF (oAttachedServer != NULL_OBJECT)
			IF lRecordDirty .AND. IsNil(oHLStatus )
				IF IsMethod (oAttachedServer, #Commit) .AND. oAttachedServer:Commit()
					lRecordDirty := FALSE
				ENDIF
			ENDIF
			SELF:__Unlink()
		ENDIF
		// Workaround for TreeView Control Loosing focus bug
		//SetFocus(GuiWin32.GetParent(SELF:Handle()))
		SUPER:Close(oEvent)
		
		RETURN TRUE
	

	METHOD Commit() 
		LOCAL lRetCode := FALSE AS LOGIC
		
		oHLStatus:= NULL_OBJECT // assume success
		IF oAttachedServer!=NULL_OBJECT .AND. SELF:__CheckRecordStatus()
			IF !(lRetCode:=oAttachedServer:Commit())
				oHLStatus := oAttachedServer:Status
				SELF:__UpdateStatus()
			ELSE
				lRecordDirty := FALSE
			ENDIF
		ENDIF
		
		RETURN lRetCode
	

	ACCESS ConcurrencyControl 
		
		
		IF IsNil(oAttachedServer)
			RETURN SELF: nCCMode
		ENDIF
		
		RETURN oAttachedServer:ConcurrencyControl
	

	ASSIGN ConcurrencyControl( nMode) 
		LOCAL newMode AS INT
		
		
		IF IsString(nMode)
			nMode := String2Symbol(nMode)
		ENDIF
		
		IF IsSymbol(nMode)
			DO CASE
			CASE nMode == #ccNone
				newMode := ccNone
			CASE nMode == #ccOptimistic
				newMode := ccOptimistic
			CASE nMode == #ccStable
				newMode := ccStable
			CASE nMode == #ccRepeatable
				newMode := ccRepeatable
			CASE nMode == #ccFile
				newMode := ccFile
			OTHERWISE
				WCError{#ConcurrencyControl,#DataWindow,__WCSTypeError,nMode,1}:@@Throw()
			ENDCASE
		ELSEIF IsNumeric(nMode)
			newMode := nMode
		ELSE
			WCError{#ConcurrencyControl,#DataWindow,__WCSTypeError,nMode,1}:@@Throw()
		ENDIF
		
		SELF:nCCMode := newMode
		IF oAttachedServer!=NULL_OBJECT
			oAttachedServer:ConcurrencyControl:=nCCMode
		ENDIF
		RETURN 
	

	ASSIGN ContextMenu(oNewMenu as Menu)
		SELF:SetContextMenu(oNewMenu, #Both)
		RETURN


	METHOD SetContextMenu(oNewMenu as Menu, symView as Symbol) as VOID
		LOCAL lForm    AS LOGIC
		LOCAL lBrowser AS LOGIC
		
		IF symView = #BrowseView
			lBrowser := TRUE
		ELSEIF symView = #FormView
			lForm := TRUE
		ELSE
			lForm := lBrowser := TRUE
		ENDIF
		
		IF lForm
			//Todo ?
			//IF oSurface != NULL_OBJECT
			//	oSurface:ContextMenu := oNewMenu:__Menu
			//ENDIF
			SUPER:ContextMenu := oNewMenu
		ENDIF
		
		IF lBrowser
			IF oGBrowse != NULL_OBJECT
				oGBrowse:ContextMenu := oNewMenu
			ENDIF
		ENDIF
		
		RETURN 

	ACCESS Controls AS ARRAY
		// DHer: 18/12/2008
		RETURN SELF:aControls

	METHOD ControlFocusChange(oControlFocusChangeEvent AS  ControlFocusChangeEvent) AS USUAL STRICT
		LOCAL oControl AS Control
		LOCAL cMessage AS STRING
		LOCAL dwI, dwCount AS DWORD
		LOCAL oRBG AS RadioButtonGroup
		LOCAL oDCHyperLabel AS OBJECT
		LOCAL oCFCE := oControlFocusChangeEvent AS  ControlFocusChangeEvent
		
		
		IF oSurface != NULL_OBJECT
			
			oControl := oCFCE:Control
			
			IF oCFCE:GotFocus
				
				IF SELF:AutoScroll
					oControl:__EnsureVisibity()
				ENDIF
				SELF:LastFocus := oControl
				
				WC.AppSetDialogWindow(SELF:oFrame)
				IF ! oControl == NULL_OBJECT
					IF IsInstanceOf(oControl, #RadioButton)
						//SE-060526
						dwCount := ALen(aRadioGroups)
						FOR dwI := 1 UPTO dwCount
							oRBG := aRadioGroups[dwI]
							IF oRBG:__IsElement(OBJECT(_CAST, oControl))
								oControl := oRBG
								EXIT
							ENDIF
						NEXT  // dwI
					ENDIF
					
					// save active control
					oDCCurrentControl := oControl
					
					// if there is an outstanding error on the control - display it
					IF oDCCurrentControl:Status != NULL_OBJECT
						IF IsString(oDCCurrentControl:Status:Description)
							cMessage := oDCCurrentControl:Status:Description
						ELSE
							cMessage := ResourceString{__WCSUnknownStatus}:Value
						ENDIF
					ENDIF
					SELF:__StatusMessage(cMessage, MessageError)
					
					// Reset message for control
					cMessage := NULL_STRING
					
					// SetUp Prompt
					oDCHyperLabel := oDCCurrentControl:HyperLabel
					IF oDCHyperLabel != NULL_OBJECT
						cMessage := oDCHyperLabel:Description
					ENDIF
					SELF:__StatusMessage(cMessage, MessageControl)
				ELSE
					SELF:__StatusMessage(NULL_STRING, MessageError)
					SELF:__StatusMessage(NULL_STRING, MessageControl)
					oDCCurrentControl := NULL_OBJECT
				ENDIF
				
			ELSE
				SELF:__DoValidate(oControl)
			ENDIF
		ENDIF
		
		RETURN NIL
	

	METHOD Copy() CLIPPER
		
		
		IF (sCurrentView == #FormView)
			IF IsInstanceOf(oDCCurrentControl, #SingleLineEdit) .OR. ;
				IsInstanceOf(oDCCurrentControl, #MultiLineEdit) .OR. ;
				IsInstanceOf(oDCCurrentControl, #EditWindow)
				oDCCurrentControl:Copy()
			ELSEIF IsInstanceOf(oDCCurrentControl, #ControlWindow)
				IF oDCCurrentControl:Control != NULL_OBJECT .AND. IsMethod(oDCCurrentControl, #Copy)
					oDCCurrentControl:Control:Copy()
				ENDIF
			ENDIF
		ELSEIF (sCurrentView == #BrowseView)
			IF (oGBrowse != NULL_OBJECT) .AND. IsMethod(oGBrowse, #copy)
				Send(oGBrowse, #Copy)
			ENDIF
		ENDIF
		
		RETURN SELF
	

	PROPERTY CurrentControl  as Object GET oDCCurrentControl SET oDCCurrentControl := Value

	ACCESS CurrentView as Symbol
		RETURN SELF:sCurrentView

	METHOD Cut() 
		IF (sCurrentView == #FormView)
			IF IsInstanceOf(oDCCurrentControl, #SingleLineEdit) .OR. ;
				IsInstanceOf(oDCCurrentControl, #MultiLineEdit) .OR. ;
				IsInstanceOf(oDCCurrentControl, #EditWindow)
				oDCCurrentControl:Cut()
			ELSEIF IsInstanceOf(oDCCurrentControl, #ControlWindow)
				IF oDCCurrentControl:Control != NULL_OBJECT .AND. IsMethod(oDCCurrentControl, #Cut)
					oDCCurrentControl:Control:Cut()
				ENDIF
			ENDIF
		ELSEIF (sCurrentView == #BrowseView)
			IF (oGBrowse != NULL_OBJECT) .AND. IsMethod(oGBrowse, #cut)
				Send(oGBrowse, #Cut)
			ENDIF
		ENDIF
		
		RETURN SELF
	

	METHOD DeActivate(oEvent) 
		//RvdH 030825 Call to DeactivateAllOLEObjects moved to Window
		RETURN SUPER:DeActivate(oEvent)
	

	METHOD DeactivateAllOLEObjects(oExcept) 
		SUPER:DeactivateAllOLEObjects(oExcept)
		IF !lTopApp .AND. IsMethod(SELF:Owner, #__AdjustClient)
			SELF:Owner:__AdjustClient()
			//ELSE
			//	SELF:__AdjustSurface()
		ENDIF
		RETURN SELF
	

	ACCESS DeferUse AS LOGIC
		RETURN lDeferUse
	
	ASSIGN DeferUse(lNewVal AS LOGIC) 
		lDeferUse := lNewVal
		RETURN
	
	METHOD @@Delete() CLIPPER
		LOCAL nRecno AS LONGINT
		LOCAL nLastRec AS LONGINT
		LOCAL fSQL AS LOGIC
		LOCAL fBrowse AS LOGIC
		LOCAL fRet AS LOGIC
		
		IF oAttachedServer != NULL_OBJECT
			nRecno := oAttachedServer:Recno
			nLastRec:= oAttachedServer:LASTREC
			fBrowse := SELF:sCurrentView = #BROWSE
			fSQL := IsInstanceOfUsual( oAttachedServer, #SQLSELECT)
			
		ENDIF
		
		fRet := SELF:__Delete()
		
		IF fSQL .AND. fRet
			
			
			IF nLastRec < nRecno
				SELF:GoTop()
				SELF:GoBottom()
				RETURN fRet
			ENDIF
			
			IF oAttachedServer:EOF .AND. oAttachedServer:BOF
				SELF:GoTop()
			ELSE
				IF fBrowse
					SELF:Skip()
				ELSE
					IF nRecno = 1
						SELF:GoTo(1)
					ELSE
						SELF:GoTo(nRecno-1)
					ENDIF
				ENDIF
			ENDIF
		ENDIF
		
		RETURN(fRet)
	
	

	METHOD DeleteValidated 
		LOCAL lRetCode := FALSE AS LOGIC
		
		oHLStatus:= NULL_OBJECT // assume success
		IF oAttachedServer!=NULL_OBJECT .AND. SELF:__CheckRecordStatus()
			IF !(lRetCode:=SELF:__Delete())
				oHLStatus:=oAttachedServer:Status
				SELF:__UpdateStatus()
			ENDIF
		ENDIF
		RETURN lRetCode
	

	METHOD Destroy() AS USUAL CLIPPER
		LOCAL oSubForm AS Window
		
		IF oAttachedServer != NULL_OBJECT
			SELF:__Unlink()
		ENDIF
		
		IF lSubForm .and. IsMethod(oParent, #__UnRegisterSubForm)
			oParent:__UnRegisterSubForm(SELF)
		ENDIF
		
		// If this window has subforms destroy them first
		DO WHILE ALen(aSubForms) > 0
			oSubForm := aSubForms[1] 
			oSubForm:Close()
			oSubForm:Destroy()
		END DO
		aSubForms := NULL_ARRAY
		
		IF oGBrowse != NULL_OBJECT
			oGBrowse:__Unlink()
			oGBrowse:Destroy()
			oGBrowse:= NULL_OBJECT
		ENDIF
		IF WC.AppGetDialogWindow() == oFrame
			WC.AppSetDialogWindow(NULL_OBJECT)
		ENDIF	
		IF oFrame != NULL_OBJECT
			oFrame:CleanUp()
			oFrame:Dispose()
			oFrame := NULL_OBJECT
		ENDIF
		IF oSurface != NULL_OBJECT
			oSurface:CleanUp()
			oSurface:Dispose()
			oSurface := NULL_OBJECT
		ENDIF
		aControls := NULL_ARRAY
		
		oDCCurrentControl := NULL_OBJECT
		SELF:lValidFlag := FALSE
		SELF:oLastFocus := NULL_OBJECT
		
		SUPER:Destroy()
		
		RETURN SELF
	

	METHOD DisableConditionalControls()
		IF lControlsEnabled
			FOREACH oControl AS Control IN aConditionalControls
				oControl:Disable()
			NEXT
			lControlsEnabled := FALSE
		ENDIF
		RETURN SELF
	

	METHOD Draw(oDrawObject) 
		//  Todo ?
		IF oSurface != NULL_OBJECT
			//oSurface:Draw(oDrawObject)
		ENDIF
		
		RETURN SELF

	METHOD EditChange(oControlEvent) 
		LOCAL oCurrentControl := NULL_OBJECT AS OBJECT
		LOCAL oCE := oControlEvent AS ControlEvent
		
		oCurrentControl := oCE:Control
		IF IsInstanceOfUsual(oCurrentControl, #ListBox) .OR. IsInstanceOfUsual(oCurrentControl, #IPAddress)
			oCurrentControl:Modified := TRUE // mark it as modified
		ENDIF
		
		IF (oDCCurrentControl == oCurrentControl)
			SELF:__StatusMessage("", MessageError)
		ENDIF
		SUPER:EditChange(oControlEvent)
		RETURN SELF
	
	METHOD EditFocusChange(oEditFocusChangeEvent) 
		LOCAL uRetCode AS USUAL
		LOCAL oEFCE AS EditFocusChangeEvent
		oEFCE := oEditFocusChangeEvent 
		uRetCode := SUPER:EditFocusChange(oEFCE)
		
		IF !oEFCE:GotFocus
			IF oEFCE:Control != NULL_OBJECT
				oEFCE:Control:__Update()
			ENDIF
		ENDIF
		
		RETURN uRetCode
	
	METHOD EnableConditionalControls() 
		IF !lControlsEnabled
			FOREACH oControl AS Control IN aConditionalControls
				oControl:Enable()
			NEXT
			lControlsEnabled := TRUE
		ENDIF
		RETURN SELF

	METHOD EnableDragDropClient(lEnable AS LOGIC, lSurfaceOnly := TRUE AS LOGIC) AS VOID
        SELF:__Surface:AllowDrop := TRUE

		SUPER:EnableDragDropClient(lEnable)



    METHOD EnableStatusBar(lEnable AS LOGIC) AS StatusBar
		
		
		SUPER:EnableStatusBar(lEnable)

		// No need to resize. __DataForm handles this 
		RETURN SELF:StatusBar
	

	//METHOD EnableToolTips(lEnable) 
	
	
	//	RETURN oSurface:EnableToolTips(lEnable)
	

	METHOD Error(oErrorObj) 
		RETURN SELF
	

	METHOD Expose(oExposeEvent) 
		
		
		SUPER:Expose(oExposeEvent)
		
		RETURN SELF
	

	METHOD FieldGet(uFieldID AS USUAL)  AS USUAL
		LOCAL oError AS USUAL
		LOCAL oFieldObject AS OBJECT
        LOCAL uRetVal := NIL AS USUAL
		
		BEGIN SEQUENCE
			
			IF (sCurrentView == #BrowseView) .AND. IsMethod(oGBrowse, #GetColumn)
				oFieldObject := Send(oGBrowse, #GetColumn, uFieldID)
			ELSE
				IF IsNumeric(uFieldID)
					oFieldObject := aControls[uFieldID]
				ELSEIF IsSymbol(uFieldID)
					oFieldObject := SELF:__FindControl(uFieldID)
				ELSEIF IsString(uFieldID)
					oFieldObject := SELF:__FindControl(String2Symbol(uFieldID))
				ENDIF
			ENDIF
			
			IF oFieldObject == NULL_OBJECT
				IF oAttachedServer != NULL_OBJECT
					uRetVal := oAttachedServer:FIELDGET(uFieldID)
				ELSE
					uRetVal := NIL
				ENDIF
			ELSEIF oFieldObject IS CheckBox VAR cb
				uRetVal := cb:Checked
			ELSEIF oFieldObject IS RadioButton VAR rb
				uRetVal := rb:Pressed
			ELSE
				uRetVal := oFieldObject:Value
			ENDIF
			
		RECOVER USING oError
			
			BREAK oError
			
		END SEQUENCE
		RETURN uRetVal
	

	METHOD FieldPut(uFieldId AS USUAL, uNewValue AS USUAL) AS USUAL
		// Retrieves the current value of the indicated string
		// uFieldPosition is numeric, symbol or string: the field position as numeric,
		// or the field name as a symbol or a string
		LOCAL oError AS USUAL
		LOCAL oFieldObject AS USUAL
		LOCAL dwFieldObject AS DWORD
        LOCAL uRetVal := NIL AS USUAL
		
		
		BEGIN SEQUENCE
			
			IF (sCurrentView == #BrowseView) .AND. IsMethod(oGBrowse, #GetColumn)
				oFieldObject := Send(oGBrowse, #GetColumn, uFieldId)
			ELSE
				IF IsNumeric(uFieldId)
					//SE-060526 this was not the same as in method FieldGet()
					//dwFieldObject := AScan(aControls, {|x| x:__GetDataFldPos == uField})
					oFieldObject := aControls[uFieldId]
				ELSEIF IsSymbol(uFieldId)
					oFieldObject := SELF:__FindControl(uFieldId)
				ELSEIF IsString(uFieldId)
					oFieldObject := SELF:__FindControl(String2Symbol(uFieldId))
				ENDIF
				
			ENDIF
			IF dwFieldObject > 0
				oFieldObject := aControls[dwFieldObject]
			ENDIF
			
			// Field object should contain control or column
			IF IsNil(oFieldObject)
				IF oAttachedServer != NULL_OBJECT
					uRetVal := oAttachedServer:FIELDPUT(uFieldId, uNewValue)
				ELSE
				    uRetVal := NIL
				ENDIF
			ELSE
			    uRetVal := oFieldObject:Value := uNewValue
			ENDIF
			
		RECOVER USING oError
			
			BREAK oError
			
		END SEQUENCE
		RETURN uRetVal
	

	METHOD FocusChange(oFocusChangeEvent) 
		IF oFocusChangeEvent:GotFocus  .and. __DataForm != NULL_OBJECT
			__DataForm:SetFocusToForm()
		ENDIF
		SUPER:FocusChange(oFocusChangeEvent)
		RETURN SELF
	

	ASSIGN Foreground( oBrush AS Brush) 
		SUPER:Foreground := oBrush
		IF ( oSurface != NULL_OBJECT )
			oSurface:ForeColor := oBrush:Color
		ENDIF
		RETURN 
	

	METHOD GoBottom() CLIPPER
		LOCAL lRetCode := FALSE AS LOGIC
		
		oHLStatus:=NULL_OBJECT // assume success
		IF oAttachedServer!=NULL_OBJECT .AND. SELF:__CheckRecordStatus() // send data to Server
			IF !(lRetCode:=oAttachedServer:GoBottom()) // if Skip is successful...
				oHLStatus:=oAttachedServer:Status // pick up Server's reason code
				SELF:__UpdateStatus()
			ENDIF
		ENDIF
		RETURN lRetCode
	

	METHOD GoTo( nRecNo ) 
		LOCAL lRetCode := FALSE AS LOGIC
		
		oHLStatus:=NULL_OBJECT // assume success
		IF(oAttachedServer!=NULL_OBJECT .AND. SELF:lValidFlag)
			IF SELF:__CheckRecordStatus()
				IF !(lRetCode:=oAttachedServer:GoTo( nRecNo ))
					oHLStatus:=oAttachedServer:Status
					SELF:__UpdateStatus()
				ENDIF
			ENDIF
		ENDIF
		RETURN lRetCode
	

	METHOD GoTop() CLIPPER
		LOCAL lRetCode := FALSE AS LOGIC
		
		oHLStatus:=NULL_OBJECT // assume success
		IF oAttachedServer!=NULL_OBJECT .AND. SELF:__CheckRecordStatus() // send data to Server
			IF !(lRetCode:=oAttachedServer:GoTop()) // if Skip is unsuccessful...
				oHLStatus:=oAttachedServer:Status // pick up Server's reason code
				SELF:__UpdateStatus()
			ENDIF
		ENDIF
		RETURN lRetCode

	METHOD Hide() AS VOID STRICT
		IF lSubForm
			SELF:__DataForm:HideSubForm()
		ELSE
			Super:Hide()
		ENDIF
		RETURN 
	
	ACCESS HyperLabel AS HyperLabel
		RETURN SUPER:HyperLabel

	ASSIGN HyperLabel (oHL AS HyperLabel) 
		SUPER:HyperLabel := oHL
		IF oHL != NULL_OBJECT
			SELF:__Surface:Text := "Surface: "+oHL:Name
			SELF:__Frame:Text	:= "Frame: "+oHL:Name
		ENDIF
	

	METHOD HorizontalScroll(oScrollEvent) 
		SELF:__HandleScrolling(oScrollEvent)
		RETURN SELF:Default(oScrollEvent)
	

	METHOD HorizontalSlide(oSlideEvent) 
		SELF:__HandleScrolling(oSlideEvent)
		RETURN SELF:Default(oSlideEvent)
	
	METHOD HorizontalSpin(oSpinEvent) 
		SELF:__HandleScrolling(oSpinEvent)
		RETURN SELF:Default(oSpinEvent)
	
	CONSTRUCTOR(oOwner, oSource, nResourceID, nDialogStyle)  
		LOCAL oResID AS ResourceID
		LOCAL oObject AS OBJECT
		LOCAL oDwOwner AS DataWindow
		
		DEFAULT(@oOwner, GetAppObject())
		IF IsLong(nDialogStyle)
			dwDialogStyle := nDialogStyle
		ENDIF     
		
		IF dwDialogStyle > 0
			oParent := oOwner
			//__DDImp{SELF, TRUE, dwDialogStyle}
		ENDIF

		IF IsNil(oSource)
			oResID := ResourceID{ -1 }
		ELSEIF IsString(oSource) .OR. IsLong(oSource)
			oResID := ResourceID{oSource}
		ELSE
			oResID := oSource
		ENDIF
		SELF:oResourceID := oResID


		IF IsObject(oOwner)
			oObject := oOwner
			IF IsInstanceOf(oObject, #App)
				SUPER(NIL, FALSE)
				lTopApp := TRUE
				// lQuitOnClose := true
			ELSEIF oObject IS ShellWindow
				SUPER(oOwner, TRUE)
			ELSEIF oObject IS DataWindow
				// Create sub form if we're a regular DataWindow
				Default(@nResourceID, 0)
				lSubForm := (dwDialogStyle = 0)
				oDwOwner := oOwner
				SUPER(oOwner, FALSE, FALSE)
			ELSEIF oObject IS ChildAppWindow
				SUPER(oOwner)
			ELSEIF oObject IS TopAppWindow
				SUPER(oOwner)
			ELSEIF oObject IS DialogWindow
				SUPER(oOwner, TRUE)
			ELSEIF oObject IS Window
				// <XXX> invalid Owner - throw error
				WCError{#Init,#DataWindow,__WCSTypeError,oOwner,1}:@@Throw()
			ELSE
				SUPER(oOwner)
			ENDIF
		ELSE
			SUPER(oOwner)
		ENDIF
		
		IF IsObject(oOwner) .AND. IsMethod(oOwner, #HelpDisplay)
			SELF:oCurrentHelp := oOwner:Helpdisplay
		ENDIF
		sCurrentView := #FormView
		SELF:Caption := ResourceString{__WCSDWUntitled}:Value
		aControls		:= {}
		aRadioGroups	:= {}
		aConditionalControls := {}
		nCCMode			:= CCOptimistic
		SELF:lValidFlag := TRUE
		lControlsEnabled := TRUE
		lAutoScroll		:= TRUE
		lAllowServerClose := TRUE
		aSubForms		:= {}
		symBrowserClass := #DataBrowser
		
		IF lSubForm 
			__DataForm:CreateSubForm(nResourceID,oDwOwner:ResourceDialog)
			oDwOwner:__RegisterSubForm(SELF)
		ENDIF
		IF ( SELF:Background != NULL_OBJECT )
			oSurface:BackColor := SELF:Background:Color
		ENDIF
		
		//IF oContextMenu != NULL_OBJECT
		//	oSurface:ContextMenu   := oContextMenu:__Menu
		//ENDIF
		
		RETURN 
	

	METHOD InsertObject() 
		//RvdH 030825 Method moved from Ole Classes
		RETURN SELF:__GetOLEObject(#CreateFromInsertDialog)
	
	METHOD IsDialog()
		//SE-070906
		RETURN dwDialogStyle > 0

	METHOD IsVisible()  AS LOGIC
		IF lSubForm
			RETURN SELF:oSurface:Visible
		ENDIF
		RETURN SUPER:IsVisible()

	ACCESS LastFocus AS Control
		IF sCurrentView == #BrowseView
			RETURN oGBrowse
		ENDIF
		RETURN oLastFocus

	ASSIGN LastFocus (oControl as Control) 
		IF ! IsInstanceOf(oControl, #DataBrowser)
			IF lSubForm
				IF IsAssign(oParent, #LastFocus)
					IVarPut(oParent, #LastFocus, oControl)
				ENDIF
			ENDIF
			oLastFocus := oControl
		ENDIF
		RETURN 
	

	METHOD LineTo(uPoint) 
		//Todo	
		
		IF (oSurface != NULL_OBJECT)
			//oSurface:LineTo(uPoint)
		ENDIF
		RETURN SELF
	

	METHOD ListBoxClick(oControlEvent) 
		LOCAL oListBox AS ListBox
		LOCAL oCE := oControlEvent AS ControlEvent
		oListBox := (OBJECT) oCE:Control
		oListBox:Modified := TRUE // assume its modified
		SELF:__DoValidate(oListBox)
		SUPER:ListBoxClick(oCE)
		RETURN SELF
	

	METHOD ListBoxSelect(oControlEvent) 
		LOCAL oListBox AS BaseListBox
		LOCAL oCE := oControlEvent AS ControlEvent
		oListBox := (OBJECT) oCE:Control
		oListBox:Modified := TRUE // assume its modified
		oListBox:__SetText(oListBox:CurrentItem)
		SELF:__DoValidate(oListBox)
		SUPER:ListBoxSelect(oCE)
		RETURN SELF
	
	ASSIGN Menu(oNewMenu AS VOSDK.Menu) 
		SUPER:Menu := oNewMenu
		IF oParent IS ShellWindow
			// No need to resize. __DataForm handles this 
			//__DataForm:ResizeParent()
		ENDIF
		RETURN 
	

	METHOD MouseButtonDown(oMouseEvent) 
		//RvdH 030825 Method moved from Ole Classes
		
		SELF:DeactivateAllOLEObjects()
		
		RETURN SUPER:MouseButtonDown(oMouseEvent)
	

	METHOD MoveTo(oPoint AS Point)  AS Point
		//Todo	
		
		IF (oSurface != NULL_OBJECT)
			//oSurface:MoveTo(oPoint)
		ENDIF
		
		RETURN oPoint
	

	METHOD Notify(kNotification, uDescription) 
		LOCAL oTB AS OBJECT
		LOCAL i, iLen AS INT
		LOCAL lThisRecDeleted AS LOGIC
		LOCAL oDF AS DataField
		LOCAL oControl AS Control
		
		DO CASE
		CASE (kNotification == NOTIFYCOMPLETION)
			// Do nothing, __NotifyCompletion had no code in it
			
		CASE (kNotification == NOTIFYINTENTTOMOVE)
			//RvdH MOved from OleDataWindow
			SELF:DeactivateAllOLEObjects()
			
			IF (oAttachedServer == NULL_OBJECT)
				RETURN TRUE
			ENDIF
			IF !SELF:CheckStatus()
				oTB:=TextBox{SELF, ResourceString{__WCSWarning}:Value, ResourceString{__WCSChgDiscard}:Value}
				oTB:Type:=BUTTONOKAYCANCEL+BOXICONHAND
				IF oTB:Show()!=BOXREPLYOKAY
					RETURN FALSE
				ELSE
					//Put original data back if moving to another record
					IF (sCurrentView == #BrowseView)
						SELF:__Scatter()
						Send(oGBrowse, #__NotifyChanges, GBNFY_FIELDCHANGE)
					ENDIF
				ENDIF
			ENDIF
			RETURN TRUE
			
		CASE (kNotification == NOTIFYFILECHANGE)
			SELF:__Scatter()
			
		CASE (kNotification == NOTIFYFIELDCHANGE)
			lRecordDirty := TRUE
			IF (sCurrentView == #FormView)
				iLen := INT(ALen(aControls))
				FOR i:= 1 TO iLen
					oControl := aControls[i] 
					oDF := oControl:__DataField
					IF (oDF != NULL_OBJECT) .AND. (oDF:NameSym == uDescription)
						oControl:__Scatter()
					ENDIF
				NEXT
				// RvdH 060529 This is done in the DataBrowser:Notify as well
				//ELSEIF (sCurrentView == #BrowseView)
				//	// Refresh current record and field from data Server
				//	Send(oGBrowse, #__RefreshField, uDescription)
			ENDIF
			
		CASE (kNotification == NOTIFYCLOSE)
			// Data Server has closed
			// if sCurrentView == #BrowseView
			//
			// Free up any internal buffers in the browse view and release any
			// memory used to maintain them.
			//
			// elseif sCurrentView == #FormView
			// self:__Unlink()
			// endif
			// Data Server has closed
			IF !SELF:CheckStatus()
				oTB:=TextBox{SELF, ResourceString{__WCSWarning}:Value, ResourceString{__WCSChgDiscard}:Value}
				oTB:Type:=BUTTONOKAY+BOXICONHAND
				oTB:Show()
			ENDIF
			SELF:__Unlink()
			
		CASE (kNotification == NOTIFYRECORDCHANGE) .OR. (kNotification == NOTIFYGOBOTTOM) .OR. ;
			(kNotification == NOTIFYGOTOP) .OR. (kNotification == NOTIFYDELETE) .OR. (kNotification == NOTIFYAPPEND)
			// record position has changed
			lThisRecDeleted:=IVarGet(oAttachedServer,#Deleted)
			// Disable or enable controls depending on deletion state
			// this logic only applies if deleted records are included in view
			// Use SET DELETE to exclude / include deleted records in view.
			IF lThisRecDeleted
				// Do we need to disable controls
				SELF:__StatusMessage(ResourceString{__WCSDeletedRecord}:Value, MESSAGEPERMANENT)
			ELSE
				SELF:__StatusMessage("", MESSAGEPERMANENT)
			ENDIF
			lDeleted := lThisRecDeleted

            oHLStatus := NULL_OBJECT
			SELF:__Scatter()
			
			IF (kNotification == NOTIFYAPPEND)
				//Set HLStatus for all controls
				FOREACH oC AS Control IN aControls
					oC:PerformValidations()
				NEXT
			ENDIF
		END CASE
		
		RETURN SELF
	

	METHOD OK() 
		
		IF SELF:Commit()
			SELF:EndWindow()
			RETURN TRUE
		ENDIF
		RETURN FALSE
	

	METHOD OLEInPlaceActivate() 
		//RvdH 030825 Method moved from Ole Classes
		LOCAL oTB AS ToolBar
		
		IF IsInstanceOf(oParent, #ShellWindow)
			oTB := oParent:ToolBar
		ELSE
			oTB := SELF:ToolBar
		ENDIF
		
		IF (oTB != NULL_OBJECT) .AND. oTB:IsVisible()
			oTB:Hide()
			lPendingToolBarShow := TRUE
		ENDIF
		
		RETURN SUPER:OLEInPlaceActivate()
	

	METHOD OLEInPlaceDeactivate() 
		//RvdH 030825 Method moved from Ole Classes
		LOCAL oTB AS ToolBar
		
		IF IsInstanceOf(oParent, #ShellWindow)
			oTB := oParent:ToolBar
		ELSE
			oTB := SELF:ToolBar
			//__DataForm:ResizeParent()
		ENDIF
		
		IF (oTB != NULL_OBJECT) .AND. !oTB:IsVisible() .AND. lPendingToolBarShow
			oTB:Show()
		ENDIF
		
		lPendingToolBarShow := FALSE
		
		RETURN SUPER:OLEInPlaceDeactivate()
	

	ACCESS Origin AS Point
		IF SELF:lSubForm
			RETURN SELF:__Frame:Location
		ENDIF
		RETURN SUPER:Origin
	

	ASSIGN Origin(oPoint AS Point) 
		IF SELF:lSubForm
			SELF:__Frame:Location := oPoint
		ELSE
			SUPER:Origin:=oPoint
		ENDIF
	
	ASSIGN OwnerAlignment(iNewVal AS USUAL) 
		LOCAL lDone AS LOGIC
		IF SELF:lSubForm
			lDone := Control.OwnerAlignmentHandledByWinForms(__Frame, iNewVal)
		ENDIF
		IF ! lDone
			oParent:__AddAlign(SELF, iNewVal)
		ENDIF
		RETURN 			

	ACCESS OwnerServer 
		IF IsInstanceOf(SELF:Owner, #DataWindow)
			RETURN SELF:Owner:Server
		ENDIF
		RETURN NIL
	

	METHOD PaintBoundingBox(oBB,kPM) 
		//Todo		
		IF oSurface != NULL_OBJECT
			//oSurface:PaintBackground(oBB,kPM)
		ENDIF
		RETURN SELF
	

	METHOD Paste() 
		IF sCurrentView == #FormView
			IF IsInstanceOf(oDCCurrentControl, #SingleLineEdit) .OR. ;
				IsInstanceOf(oDCCurrentControl, #MultiLineEdit) .OR. ;
				IsInstanceOf(oDCCurrentControl, #EditWindow)
				oDCCurrentControl:Paste()
			ELSEIF IsInstanceOf(oDCCurrentControl, #ControlWindow)
				IF oDCCurrentControl:Control != NULL_OBJECT .AND. IsMethod(oDCCurrentControl, #Paste)
					oDCCurrentControl:Control:Paste()
				ENDIF
			ENDIF
		ELSEIF sCurrentView == #BrowseView
			IF (oGBrowse != NULL_OBJECT) .AND. IsMethod(oGBrowse, #Paste)
				Send(oGBrowse, #Paste)
			ENDIF
		ENDIF
		
		RETURN SELF
	

	METHOD PasteSpecial() 
		//RvdH 030825 Method moved from Ole Classes
		RETURN SELF:__GetOLEObject(#CreateFromPasteDialog)
	

	ASSIGN Pen(oPen as Pen) 
		
		SUPER:Pen := oPen
		IF oSurface != NULL_OBJECT
		ENDIF
		RETURN 
	

	ACCESS Pointer  AS Pointer
		IF (sCurrentView == #FormView) .OR. !IsAccess(oGBrowse, #pointer)
			IF (oSurface != NULL_OBJECT)
				RETURN oSurface:Cursor
			ENDIF
		ELSE
			RETURN IVarGet(oGBrowse, #pointer)
		ENDIF
		
		RETURN SUPER:Pointer
	

	ASSIGN Pointer(oPointer AS Pointer) 
		IF (oSurface != NULL_OBJECT)
			oSurface:Cursor:=oPointer
		ENDIF
		IF IsAssign(oGBrowse, #databrowser)
			IVarPut(oGBrowse, #pointer, oPointer)
		ENDIF
		RETURN 
	

	METHOD PreValidate() 
		
		//self:EnableConditionalControls()
		SELF:__CheckConditionalControls()
		RETURN SELF
	

	ACCESS PreventAutoLayout AS LOGIC
		
		
		RETURN lPreventAutoLayout
	
	ASSIGN PreventAutoLayout(lNewValue AS LOGIC) 
		
		
		lPreventAutoLayout := lNewValue
		
		RETURN 
	

	METHOD QueryClose(oQCE) 
		// If there are outstanding changes which have not
		// been written to the dataServer - ask the user.
		LOCAL oTB AS TextBox
		
		
		
		IF oAttachedServer==NULL_OBJECT
			RETURN TRUE
		ENDIF
		
		SELF:SetFocus()
		IF !SELF:CheckStatus()
			oTB := TextBox{ SELF,;
			ResourceString{__WCSWarning}:Value,;
			VO_Sprintf(__WCSDataWindow,SELF:Caption)+CHR(10)+ResourceString{__WCSChgDiscard}:Value}
			oTB:Type := ButtonOkayCancel + BoxICONHand
			IF (oTB:Show() != BOXREPLYOkay)
				RETURN FALSE
			ENDIF
		ENDIF
		
		RETURN TRUE

	ACCESS RadioGroups AS ARRAY
		// DHer: 18/12/2008
		RETURN SELF:aRadioGroups
	

	METHOD RegisterConditionalControls(oCC)
		//SE-060526
		LOCAL dwI, dwCount AS DWORD
		
		
		
		dwCount := ALen(aConditionalControls)
		FOR dwI := 1 UPTO dwCount
			IF aConditionalControls[dwI] == oCC
				RETURN SELF
			ENDIF
		NEXT  
		AAdd(aConditionalControls,oCC)
		
		RETURN SELF
	

	METHOD RePaint() AS VOID STRICT
		IF oSurface != NULL_OBJECT
			oSurface:Invalidate()
		ENDIF
		RETURN 
	

	METHOD RepaintBoundingBox(oBB AS BoundingBox) AS VOID STRICT
		
		IF (oSurface != NULL_OBJECT)
			oSurface:Invalidate((System.Drawing.Rectangle) oBB)
		ENDIF
		
		RETURN 
	

	METHOD Seek(uValue, lSoftSeek) 
		LOCAL lRetCode := FALSE AS LOGIC
		IF oAttachedServer!=NULL_OBJECT
			oHLStatus := NULL_OBJECT // assume success
			IF SELF:__CheckRecordStatus()
				IF !(lRetCode := oAttachedServer:Seek(uValue, lSoftSeek))
					oHLStatus := oAttachedServer:Status
					//oHLStatus := HyperLabel{#Seek, "Seek Failed, key not found"}
					SELF:__UpdateStatus()
				ENDIF
			ENDIF
		ENDIF
		
		RETURN lRetCode
	

	ACCESS Server as Object
		RETURN oAttachedServer
	
	METHOD SetAlignStartSize(oSize AS Dimension)  AS VOID
		Super:SetAlignStartSize(oSize)
		RETURN 

	METHOD SetDialog(lResizable, lMaximizeBox, lMinimizeBox)
		//can be used in PreInit() method or befor super:init()
		IF oWnd == NULL_OBJECT
			
			dwDialogStyle := _OR(dwDialogStyle, WS_DLGFRAME)
			
			IF IsLogic(lResizable) .AND. lResizable 
				dwDialogStyle := _OR(dwDialogStyle, WS_THICKFRAME)
			ENDIF
			IF IsLogic(lMaximizeBox) .AND. lMaximizeBox 
				dwDialogStyle := _OR(dwDialogStyle, WS_MAXIMIZEBOX, WS_SYSMENU)
			ENDIF
			IF IsLogic(lMinimizeBox) .AND. lMinimizeBox 
				dwDialogStyle := _OR(dwDialogStyle, WS_MINIMIZEBOX, WS_SYSMENU)
			ENDIF
			
		ENDIF	
		
		RETURN SELF
	

	METHOD SetRelation( oDWChild, uRelation, cRelation ) 
		LOCAL lRetCode := FALSE AS LOGIC
		
		oHLStatus:=NULL_OBJECT // assume success
		IF oAttachedServer!=NULL_OBJECT .AND. SELF:lValidFlag
			IF SELF:__CheckRecordStatus()
				IF !(lRetCode:=Send(oAttachedServer,#SetRelation,oDWChild:Server, uRelation, cRelation ))
					oHLStatus:=oAttachedServer:Status
					SELF:__UpdateStatus()
				ENDIF
			ENDIF
		ENDIF
		RETURN lRetCode
	

	METHOD SetSelectiveRelation( oDWChild, uRelation, cRelation ) 
		LOCAL lRetCode := FALSE AS LOGIC
		
		
		oHLStatus := NULL_OBJECT // assume success
		IF oAttachedServer != NULL_OBJECT .AND. SELF:lValidFlag
			IF SELF:__CheckRecordStatus()
				IF !(lRetCode:=Send(oAttachedServer,#SetSelectiveRelation,oDWChild:Server, uRelation, cRelation ))
					oHLStatus:=oAttachedServer:Status
					SELF:__UpdateStatus()
				ENDIF
			ENDIF
		ENDIF
		
		RETURN lRetCode
	

	
	METHOD Show(nShowState AS LONG)  AS VOID

		IF lDeferUse .AND. (oDeferUseServer != NULL_OBJECT)
			lDeferUse := FALSE
			SELF:Use(oDeferUseServer)
			oDeferUseServer := NULL_OBJECT
		ENDIF
		
		IF (SELF:ToolBar != NULL_OBJECT)
			SELF:ToolBar:Show()
		ENDIF
		
		IF !lSubForm
			IF SELF:lValidFlag
				SUPER:Show(nShowState)
			ELSE
				SELF:Destroy()
			ENDIF
		ELSE
			SELF:__DataForm:ShowSubForm()
		ENDIF		
		
		
		RETURN 
	

	ACCESS Size AS Dimension
		IF SELF:lSubForm
			RETURN SELF:__Frame:Size
		ENDIF
		RETURN SUPER:Size
	

	ASSIGN Size(oDimension AS Dimension) 
		IF SELF:lSubForm
			SELF:__Frame:Size := oDimension
			SELF:__Frame:DefinedSize := SELF:__Frame:Size
			SELF:__DataForm:AdjustSizes()
		ELSE
			SUPER:Size := oDimension
		ENDIF


	METHOD Skip(uRelativePosition) 
		LOCAL lRetCode := FALSE AS LOGIC
		
		oHLStatus := NULL_OBJECT // assume success
		IF oAttachedServer != NULL_OBJECT .AND. SELF:__CheckRecordStatus()
			IF !(lRetCode := oAttachedServer:Skip(uRelativePosition))
				oHLStatus := oAttachedServer:Status
				SELF:__UpdateStatus()
			ENDIF
		ENDIF
		
		RETURN lRetCode
	

	METHOD SkipNext() CLIPPER
		LOCAL lRetCode := FALSE AS LOGIC
		
		
		lRetCode := SELF:Skip(1)
		
		IF lRetCode = TRUE .AND. oAttachedServer:EoF
			SELF:GoBottom()
		ENDIF
		
		RETURN lRetCode
	

	METHOD SkipPrevious() CLIPPER
		
		RETURN SELF:Skip(-1)
	

	ACCESS Status AS HyperLabel
		
		RETURN SELF:oHLStatus
	

	ASSIGN Status(oStatus AS HyperLabel) 
		
		oHLStatus := oStatus
	

	ACCESS StatusBar AS StatusBar
		//SE-070906
		IF dwDialogStyle > 0
			// Support of a StatusBar a DataDialog - Window
			RETURN oStatusBar
		ENDIF
		RETURN SUPER:StatusBar
	
	ASSIGN StatusBar(oNewStatusBar AS StatusBar)
		//SE-070906
		IF dwDialogStyle > 0
			// Support of a StatusBar a DataDialog - Window
			oStatusBar := oNewStatusBar
		ENDIF
		SUPER:StatusBar := oNewStatusBar
		IF oNewStatusBar != NULL_OBJECT
			SELF:__DataForm:StatusBar := SELF:StatusBar:__StatusStrip
		ELSE
			SELF:__DataForm:StatusBar := NULL_OBJECT
		ENDIF
		
		RETURN

	
	METHOD StatusOK() AS LOGIC
		LOCAL dwInvalidControl, iLen AS DWORD
		
		
		oDCInvalidControl := NULL_OBJECT
		oDCInvalidColumn := NULL_OBJECT
		oHLStatus := NULL_OBJECT
		
		IF (oAttachedServer == NULL_OBJECT)
			oHLStatus := HyperLabel{#NoAttachedServer, #NoAttachedServer}
		ELSE
			SELF:__UpdateCurrent()
			IF !oAttachedServer:EoF //Don't validate the EOF record
				IF (sCurrentView == #FormView)
					iLen := ALen(aControls)
					FOR dwInvalidControl := 1 TO iLen
						IF (aControls[dwInvalidControl]:Status != NULL_OBJECT)
							EXIT
						ENDIF
					NEXT
					//dwInvalidControl := AScan(aControls, {|oControl| oControl:Status != NULL_OBJECT})
					IF (dwInvalidControl != (iLen+1))
						oDCInvalidControl := aControls[dwInvalidControl]
						IF (oHLStatus := oDCInvalidControl:Status) == NULL_OBJECT
							oHLStatus := HyperLabel{#InvalidControl, #RecInvalid}
						ENDIF
					ENDIF
				ELSEIF (sCurrentView == #BrowseView)
					IF oGBrowse != NULL_OBJECT
						IF (oDCInvalidColumn := Send(oGBrowse, #__StatusOK)) != NULL_OBJECT
							IF (oHLStatus := oDCInvalidColumn:Status) == NULL_OBJECT
								oHLStatus := HyperLabel{#InvalidColumn, #RecInvalid}
							ENDIF
						ENDIF
					ENDIF
				ENDIF
			ENDIF
		ENDIF
		
		RETURN oHLStatus == NULL_OBJECT

	ACCESS SubForms 
		// DHer: 18/12/2008
		RETURN SELF:aSubForms
	
	ACCESS Surface as VOPanel
		// DHer: 18/12/2008
		RETURN SELF:oSurface


	METHOD TextPrint(cText, oPoint) 
		// Todo		
		IF oSurface != NULL_OBJECT
			//oSurface:TextPrint(cText, oPoint)
		ENDIF
		RETURN SELF
	
	ASSIGN ToolBar(oNewToolBar AS ToolBar) 
		
		
		SUPER:ToolBar := oNewToolBar
		IF oNewToolBar != NULL_OBJECT
			SELF:__DataForm:ToolBar := oNewToolBar:__ToolBar
			//ELSE
			//	SELF:__DataForm:ToolBar := NULL_OBJECT
		ENDIF		
		// No need to resize. __DataForm handles this 
		RETURN 
	


	METHOD Undo() 
		
		
		IF (sCurrentView == #FormView)
			IF IsInstanceOf(oDCCurrentControl, #Edit)
				oDCCurrentControl:Undo()
			ENDIF
		ELSEIF (sCurrentView == #BrowseView)
			IF (oGBrowse != NULL_OBJECT) .AND. IsMethod(oGBrowse, #Undo)
				Send(oGBrowse, #Undo)
			ENDIF
		ENDIF
		RETURN SELF
	
	METHOD UndoAll() 
		IF oAttachedServer!=NULL_OBJECT
			Send(oAttachedServer,#Refresh)
		ENDIF
		
		RETURN NIL
	

	METHOD UpdateActiveObject() 
		RETURN SELF:__UpdateActiveObject()
	

	METHOD Use(oDataServer) 
		LOCAL lRetCode := FALSE AS LOGIC
		
		IF lDeferUse .AND. IsInstanceOfUsual(oDataServer, #DATAServer)
			oDeferUseServer := oDataServer
			RETURN TRUE
		ENDIF
		
		IF (oAttachedServer != oDataServer) .AND. (oAttachedServer != NULL_OBJECT)
			SELF:__Unlink()
			IF __DataForm:AutoLayout
				IF (oSurface != NULL_OBJECT)
					oSurface:Controls:Clear()
					oSurface:Size := Dimension{0, 0}
				ENDIF
				aControls := {}
				aRadioGroups := {}
				aConditionalControls := {}
				
				IF (oGBrowse != NULL_OBJECT)
					oGBrowse:Destroy()
					oGBrowse := NULL_OBJECT
				ENDIF
			ENDIF
		ENDIF
		
		IF (oDataServer != NULL_OBJECT)
			IF SELF:__VerifyDataServer(oDataServer)
				oDataServer:RegisterClient(SELF)
				
				lRetCode := SELF:__RegisterFieldLinks(oDataServer)
				IF (sCurrentView == #BrowseView)
					IF (oGBrowse != NULL_OBJECT)
						Send(oGBrowse, #Use, oDataServer)
						SELF:__Scatter() // new insert, since ViewAs already does a Scatter()
					ELSE
						sCurrentView := #ViewSwitch
						SELF:ViewAs(#BrowseView)
					ENDIF
				ELSEIF (sCurrentView == #FormView)
					sCurrentView := #ViewSwitch
					SELF:ViewAs(#FormView)
				ENDIF
				//self:__Scatter() // removed, see above
			ELSE
				IF (oHLStatus != NULL_OBJECT)
					ErrorBox{, oHLStatus}:Show()
				ELSE
					WCError{#oDataServer,#DataWindow,__WCSTypeError,oDataServer,1}:@@Throw()
				ENDIF
				SELF:lValidFlag := FALSE
			ENDIF
		ENDIF
		
		RETURN lRetCode
	
	METHOD ValidateRecord() CLIPPER
		RETURN TRUE


	METHOD VerticalScroll(oScrollEvent) 
		SELF:__HandleScrolling(oScrollEvent)
		RETURN SELF:Default(oScrollEvent)
	

	METHOD VerticalSlide(oSlideEvent) 
		SELF:__HandleScrolling(oSlideEvent)
		RETURN SELF:Default(oSlideEvent)
	

	METHOD VerticalSpin(oSpinEvent) 
		SELF:__HandleScrolling(oSpinEvent)
		RETURN SELF:Default(oSpinEvent)
	

	METHOD ViewAs(symViewType as symbol) 
		LOCAL oTextBox AS TextBox
		#ifdef USE_OLEOBJECT	
		LOCAL oOleObj as OleObject
		#endif	
		LOCAL oControl AS Control
		//RvdH 041123 Added call to __GetMyOleObjects to retrieve the objects

		IF (sCurrentView == symViewType)
			// No change in view -> do nothing
			RETURN SELF
		ENDIF
		SELF:DeactivateAllOLEObjects()
		
		// Save data in current view
		IF lLinked
			IF !SELF:__CheckRecordStatus() // check validation status
				// continuing now may lose changes
				oTextBox := TextBox{SELF, ResourceString{__WCSWarning}:Value, ResourceString{__WCSChangingView}:Value}
				oTextBox:Type := BUTTONOKAYCANCEL + BOXICONHAND
				IF oTextBox:Show() != BOXREPLYOKAY
					RETURN SELF
				ELSE
					//Put original data back
					IF (sCurrentView == #BrowseView)
						SELF:__Scatter()
						Send(oGBrowse, #__NotifyChanges, GBNFY_FIELDCHANGE)
					ENDIF
				ENDIF
			ENDIF
		ENDIF
		
		IF (symViewType == #BrowseView)
			// Show as browser
			// Hide form frame
			// Check if autocreating browser
			// flush changes to form so they are reflected in browser
			TRY
				sCurrentView := #ViewSwitch
				#ifdef USE_OLEOBJECT			
				FOR i:=1 TO iLen
					oOleObj := aObjects[i]
					IF oOleObj:Server != NULL_OBJECT
						
						oOleObj:DetachFromServer()
					ENDIF
				NEXT
				#endif			
				SELF:__AutoCreateBrowser()
				__DataForm:DataBrowser := oGBrowse:__DataGridView
				
			END TRY
			sCurrentView := #BrowseView
			IF oGBrowse != NULL_OBJECT
				oGBrowse:SuspendUpdate()
				__DataForm:ViewAs(TRUE) // view as browse
				oGBrowse:RestoreUpdate()
				Send(oGBrowse, #__NOTIFYChanges, GBNFY_VIEWASBROWSER)
			ENDIF
		ELSE
			// Show as form
			IF (oGBrowse != NULL_OBJECT)
				Send(oGBrowse, #__NOTIFYCHANGES, GBNFY_VIEWASFORM)
			ENDIF
			IF ALen(SELF:GetAllChildren()) == 0
				SELF:__AutoLayout()
			ENDIF
			__DataForm:ViewAs(FALSE) // view as form
			IF ALen(aControls) > 0
				LOCAL nControl AS LONG
				nControl := 1
				DO WHILE nControl <= aLen(aControls)
					oControl := aControls[nControl] 
					IF ! IsInstanceOf(oControl,#FixedText) .and. ! IsInstanceOf(oControl,#GroupBox) .and. !IsInstanceOf(oControl,#Window)
						oControl:SetFocus()
						IF IsInstanceOf(oControl, #SingleLineEdit) .AND. oControl:IsEnabled()
							LOCAL oSle AS SingleLineEdit
							oSle := (SingleLineEdit) oControl
							oSle:Selection := Selection{0,0}
						ENDIF
						EXIT
					ENDIF
					nControl += 1
				ENDDO
			ENDIF
			
			sCurrentView := #FormView
		ENDIF
		SELF:__Scatter()
		RETURN SELF
	

	METHOD ViewForm() CLIPPER
		
		SELF:ViewAs(#FormView)
		RETURN SELF

	METHOD ViewTable() CLIPPER
		
		SELF:ViewAs(#BrowseView)
		RETURN SELF
	
	STATIC INTERNAL glUseColonInAutoLayoutCaptions := TRUE AS LOGIC
END CLASS

FUNCTION UseColonInAutoLayoutCaptions(lUse AS LOGIC) AS VOID
	DataWindow.glUseColonInAutoLayoutCaptions := lUse
	RETURN

FUNCTION __GetDFCaption (oDF AS DataField, arUsedKeys AS ARRAY)  AS STRING
	LOCAL cText 	AS STRING
	LOCAL cHotKey 	AS STRING
	LOCAL dwI, dwCount AS DWORD
	LOCAL i 			AS DWORD
	
	
	//	IF (IsInstanceOfUsual(oDF, #DataField) .AND. (!IsNil(oDF:HyperLabel)))
	IF !IsNil(oDF:HyperLabel)
		cText := oDF:HyperLabel:Caption
		// 	ELSEIF (IsInstanceOfUsual(oDF, #DataServer) .AND. (!IsNil(fldIndex)))
		// 		cText := LTrim(AsString(oDF:FieldName(fldIndex)))
	ELSE
		cText := ResourceString{__WCSUnknown}:Value
	ENDIF
	
	cText := Proper(cText) //RTrim(Left(cText, 1) + Lower(SubStr(cText, 2)))
	
	//	IF !IsNil(arUsedKeys)
	IF (dwCount := ALen(arUsedKeys)) > 0
		FOR i := 1 TO SLen(cText)
			cHotKey := Lower(SubStr(cText, i ,1))
			//SE-060526
			FOR dwI := 1 UPTO dwCount
				IF arUsedKeys[dwI] = cHotKey
					EXIT
				ENDIF
			NEXT  // dwI
			IF dwI > dwCount
				AADD(arUsedKeys, cHotKey)
				cText := Left(cText, i-1) + "&" + SubStr(cText, i)
				EXIT
			ENDIF
		NEXT
	ENDIF
	
	IF DataWindow.glUseColonInAutoLayoutCaptions
		IF !IsBiDi()
			IF !(Right(cText, 1) == ":")
				cText := cText +":"
			ENDIF
		ELSE
			IF !(Left(cText, 1) == ":")
				cText := ":" + cText
			ENDIF
		ENDIF
	ENDIF
	
	RETURN cText

FUNCTION __GetFSDefaultLength(oFS AS USUAL) AS INT
	LOCAL liRetVal, liExtra AS LONGINT
	LOCAL uType AS USUAL
	LOCAL cFunction AS STRING
	
	
	IF !IsInstanceOfUsual(oFS, #FieldSpec)
		liRetVal := 10
	ELSE
		liRetVal := oFS:Length
		uType := oFS:UsualType
		
		DO CASE
		CASE (uType == LOGIC)
			liRetVal := Max(liRetVal, 3)
		CASE (uType == DATE)
			IF (SetCentury() == TRUE)
				liRetVal := 10
			ELSE
				liRetVal := Max(liRetVal, 8)
			ENDIF
		CASE (uType == STRING) .AND. oFS:ValType == "M"
			liRetVal := Max(liRetVal, 40)
			liRetVal := Min(liRetVal, 120)
		ENDCASE
		//RvdH 060608 optimized
		//IF (NULL_STRING != oFS:Picture) .AND. !Empty(oFS:Picture)
		IF SLen(oFS:Picture)> 0
			IF SubStr(oFS:Picture, 1, 1) != "@"
				//there is no associated function
				liRetVal := LONGINT(_CAST,SLen(oFS:Picture))
			ELSE
				//store the function character
				cFunction := SubStr(oFS:Picture, 2, 1)
				IF cFunction == "C" .OR. cFunction == "X"
					//"@C" and "@X" functions require a " CR" or a " DB" respectively
					//at the end of the string, so tag on three extra bytes
					liExtra := 3
				ENDIF
				IF At(" ", oFS:Picture) != 0
					//the actual picture will now start after the space between the function
					//and the template, so calculate the length from this point
					liRetVal := LONGINT(_CAST,SLen(SubStr(oFS:Picture, At(" ", oFS:Picture) + 1)))
				ENDIF
				liRetVal += liExtra
			ENDIF
		ENDIF
	ENDIF
	
	IF (oFS:Length > liRetVal)
		RETURN oFS:Length
	ENDIF
	
	RETURN liRetVal


