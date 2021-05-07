// ListViewprg.prg

// This file contains a subclass of the Windows.Forms.ListView control
// Also some On..() methods have been implemented that call the event handles on the VO Window
// class that owns the control

USING System.Collections.Generic
USING System.Windows.Forms
USING VOSDK := XSharp.VO.SDK
USING SWF := System.Windows.Forms
CLASS VOListView INHERIT SWF.ListView IMPLEMENTS IVOListView
	PROPERTY ListView     AS VOSDK.ListView GET (VOSDK.ListView) oProperties:Control
	#include "PropControl.vh"

	METHOD Initialize() AS VOID STRICT
		SELF:View := System.Windows.Forms.View.Details

	CONSTRUCTOR(Owner AS VOSDK.Control, dwStyle AS LONG, dwExStyle AS LONG)
		oProperties := VOControlProperties{SELF, Owner, dwStyle, dwExStyle}
		SUPER()
		SELF:Initialize()
		SELF:SetVisualStyle()


	METHOD SetVisualStyle AS VOID STRICT
		IF oProperties != NULL_OBJECT
			SELF:TabStop := (_AND(oProperties:Style, WS_TABSTOP) == WS_TABSTOP)
		ENDIF

    METHOD ContainsColumn(sName AS STRING) AS LOGIC
        RETURN SUPER:Columns:ContainsKey(sName)

    METHOD RemoveColumn(sName AS STRING) AS VOID
        SUPER:Columns:RemoveByKey(sName)
        RETURN


    NEW PROPERTY Columns AS IList<IVOColumnHeader> GET (IList<IVOColumnHeader> ) SUPER:Columns
    NEW PROPERTY Groups AS IList<SWF.ListViewGroup> GET (IList<SWF.ListViewGroup> ) SUPER:Groups
	NEW PROPERTY Items AS IList<IVOListViewItem> GET (IList<IVOListViewItem>) SUPER:Items
	
	#region Event Handlers		
	
	VIRTUAL PROTECTED METHOD OnAfterLabelEdit(e AS LabelEditEventArgs) AS VOID
		LOCAL oWindow AS Window
		SUPER:OnAfterLabelEdit(e)
		oWindow := (Window) SELF:Control:Owner
		oWindow:ListViewItemEdit(ListViewEditEvent{SELF:ListView, e, FALSE})
		RETURN
	
	VIRTUAL PROTECTED METHOD OnBeforeLabelEdit(e AS LabelEditEventArgs) AS VOID
		LOCAL oWindow AS Window
		SUPER:OnBeforeLabelEdit(e)
		oWindow := (Window) SELF:Control:Owner
		oWindow:ListViewItemEdit(ListViewEditEvent{SELF:ListView, e, TRUE})
		RETURN

	VIRTUAL PROTECTED METHOD OnColumnClick(e AS ColumnClickEventArgs ) AS VOID
		LOCAL oWindow AS Window
		SUPER:OnColumnClick(e)
		oWindow := (Window) SELF:Control:Owner
		oWindow:ListViewColumnClick(ListViewColumnClickEvent{SELF:ListView, e})
		RETURN

	
	VIRTUAL PROTECTED METHOD OnItemChecked(e AS ItemCheckedEventArgs ) AS VOID
		LOCAL oWindow AS Window
		SUPER:OnItemChecked(e)
		oWindow := (Window) SELF:Control:Owner
		oWindow:ListViewItemChanged(ListViewItemEvent{SELF:ListView, e})
		RETURN

	VIRTUAL PROTECTED METHOD OnItemDrag(e AS ItemDragEventArgs ) AS VOID
		LOCAL oWindow AS Window
		SUPER:OnItemDrag(e)
		oWindow := (Window) SELF:Control:Owner
		oWindow:ListViewItemDrag(ListViewDragEvent{SELF:ListView, e})
		RETURN


	VIRTUAL PROTECTED METHOD OnItemSelectionChanged(e AS ListViewItemSelectionChangedEventArgs ) AS VOID
		LOCAL oWindow AS Window
		SUPER:OnItemSelectionChanged(e)
		oWindow := (Window) SELF:Control:Owner
		oWindow:ListViewItemChanged(ListViewItemEvent{SELF:ListView, e})
		RETURN

	VIRTUAL PROTECTED METHOD OnMouseDown(e AS MouseEventArgs) AS VOID
		LOCAL oWindow AS Window
		SUPER:OnMouseDown(e)
		oWindow := (Window) SELF:Control:Owner
		oWindow:ListViewMouseButtonDown(ListViewMouseEvent{SELF:ListView, e})
		RETURN

	VIRTUAL PROTECTED METHOD OnMouseDoubleClick(e AS MouseEventArgs) AS VOID
		LOCAL oWindow AS Window
		SUPER:OnMouseDoubleClick(e)
		oWindow := (Window) SELF:Control:Owner
		oWindow:ListViewMouseButtonDoubleClick(ListViewMouseEvent{SELF:ListView, e})
		RETURN

	VIRTUAL PROTECTED METHOD OnSelectedIndexChanged(e AS EventArgs ) AS VOID
		LOCAL oWindow AS Window
		SUPER:OnSelectedIndexChanged(e)
		oWindow := (Window) SELF:Control:Owner
		oWindow:ListViewItemChanged(ListViewItemEvent{SELF:ListView, e})
		RETURN
	
	VIRTUAL PROTECT METHOD OnKeyDown(e AS KeyEventArgs) AS VOID
		LOCAL oWindow AS Window
		SUPER:OnKeyDown(e)
		oWindow := (Window) SELF:Control:Owner
		oWindow:ListViewKeyDown(ListViewKeyEvent{SELF:ListView, e})
		RETURN

	//VIRTUAL PROTECT METHOD WndProc(msg REF Message) AS VOID	
	//	IF oProperties == NULL_OBJECT
	//		RETURN SUPER:WndProc(msg)
	//	ELSEIF ! oProperties:WndProc(msg)
	//		SUPER:WndProc(msg) 
	//	ENDIF
	//	RETURN

	
	#endregion		

END CLASS


CLASS VODataListView INHERIT VOListView 

	CONSTRUCTOR(Owner AS VOSDK.Control, dwStyle AS LONG, dwExStyle AS LONG)
		SUPER(Owner, dwStyle, dwExStyle)
		SELF:VirtualMode := TRUE
	
END CLASS


CLASS VOColumnHeader INHERIT System.Windows.Forms.ColumnHeader IMPLEMENTS IVOColumnHeader
	PROPERTY Column AS VOSDK.ListViewColumn AUTO
	
	METHOD LinkTo(oColumn AS VOSDK.ListViewColumn) AS VOID STRICT
		SELF:Column := oColumn
		SELF:Tag	:= oColumn
		IF oColumn:HyperLabel != NULL_OBJECT
			SELF:Name := oColumn:HyperLabel:Name
		ENDIF
	
	CONSTRUCTOR(oColumn AS VOSDK.ListViewColumn) STRICT
		SUPER()
		SELF:LinkTo(oColumn)	
END CLASS



CLASS VOListViewItem INHERIT System.Windows.Forms.ListViewItem IMPLEMENTS IVOListViewItem
	PROPERTY Item AS VOSDK.ListViewItem AUTO 
	
	
	METHOD LinkTo(oItem AS VOSDK.ListViewItem) AS VOID STRICT
		SELF:Item  := oItem
		SELF:Tag   := oItem
	
	CONSTRUCTOR(oItem AS VOSDK.ListViewItem) STRICT
		SUPER()
		SELF:LinkTo(oItem)
	
END CLASS

// Cannot create subclass from ListViewGroup because it is sealed

//CLASS VOListViewGroup INHERIT System.Windows.Forms.ListViewGroup IMPLEMENTS IVOListViewGroup
//    CONSTRUCTOR(cName)
//        SUPER(cName) 
//END CLASS
