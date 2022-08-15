


USING System.Windows.Forms
/// <include file="Gui.xml" path="doc/TopAppWindow/*" />

CLASS TopAppWindow INHERIT AppWindow

	METHOD __CreateForm() AS VOForm STRICT
		RETURN GuiFactory.Instance:CreateTopAppWindow(SELF)

 /// <exclude />
	METHOD __ResizeChild() AS TopAppWindow STRICT
		IF SELF:__IsValid .and. oWnd:MdiChildren:Length > 0
			LOCAL oChild AS Form
			oChild :=  oWnd:MdiChildren[1]
			oChild:Location := System.Drawing.Point{0,0}
			oChild:Size := oWnd:ClientSize
		ENDIF
		RETURN SELF


/// <include file="Gui.xml" path="doc/TopAppWindow.ctor/*" />
	CONSTRUCTOR(oOwner)
		SUPER(oOwner)

		SELF:EnableSystemMenu()
		SELF:EnableBorder()
		SELF:EnableMinBox()
		SELF:EnableMaxBox()
		IF oApp != NULL_OBJECT
			oApp:__WindowCount += 1
		ENDIF

		RETURN

	/// <inheritdoc />
	METHOD Destroy() AS USUAL
		SUPER:Destroy()
		// Tests if this is the last TopAppWindow
		IF (oApp != NULL_OBJECT)
			oApp:__WindowCount := oApp:__WindowCount - 1
			IF (oApp:__WindowCount <= 0)
				oApp:Quit()
			ENDIF
		ENDIF
		RETURN SELF

/// <include file="Gui.xml" path="doc/TopAppWindow.Resize/*" />
	METHOD Resize(oResizeEvent)
		SUPER:Resize(oResizeEvent)
		SELF:__ResizeChild()
		RETURN SELF

	METHOD ToolBarHeightChanged(oEvent AS ControlNotifyEvent)
		SELF:__ResizeChild()
		RETURN SELF
END CLASS

#region defines
DEFINE __WCTopAppWindowClass := "TopAppWindow"
#endregion
