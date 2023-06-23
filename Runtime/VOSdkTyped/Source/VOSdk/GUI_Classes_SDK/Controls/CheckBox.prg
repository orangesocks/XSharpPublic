/// <include file="Gui.xml" path="doc/CheckBox/*" />
[XSharp.Internal.TypesChanged];
CLASS CheckBox INHERIT Button
    PROTECT lSavedChecked AS LOGIC

    PROPERTY ControlType AS ControlType GET ControlType.CheckBox

    /// <include file="Gui.xml" path="doc/CheckBox.ctor/*" />
    CONSTRUCTOR( oOwner, xID, oPoint, oDimension, cText, kStyle)
        SUPER(oOwner, xID, oPoint, oDimension, cText, kStyle, TRUE)

        IF !(xID IS ResourceID) .AND. IsNil(kStyle)
            SELF:SetStyle(BS_AUTOCHECKBOX)
        ENDIF

        RETURN

    /// <exclude />
    METHOD OnHandleCreated(o AS OBJECT, e AS EventArgs) AS VOID
        SUPER:OnHandleCreated(o, e)
        GuiWin32.SetWindowLong(SELF:hWnd, GWL_STYLE, dwStyle)
        RETURN


    /// <exclude />
    PROPERTY __CheckBox AS VOCheckBox GET (VOCheckBox ) oCtrl

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
    PROPERTY Checked AS LOGIC
        GET
            IF SELF:ValidateControl()
                RETURN __CheckBox:Checked
            ELSE
                RETURN lSavedChecked
            ENDIF
        END GET
        SET
            IF SELF:ValidateControl()
                __CheckBox:Checked := value
            ENDIF

            __lModified := TRUE
            SELF:__Update()
        END SET
    END PROPERTY
    /// <include file="Gui.xml" path="doc/CheckBox.Destroy/*" />
    METHOD Destroy() AS USUAL
        IF SELF:__IsValid
            lSavedChecked := SELF:Checked
        ENDIF

        RETURN SUPER:Destroy()

    /// <include file="Gui.xml" path="doc/CheckBox.Image/*" />
    PROPERTY Image  AS VObject
        GET
            RETURN SELF:__GetImage()
        END GET
        SET
            IF ! SELF:__SetImage(value)
                SUPER:Image := value
            ENDIF
        END SET
    END PROPERTY






    /// <include file="Gui.xml" path="doc/CheckBox.TextValue/*" />
    PROPERTY TextValue  AS STRING
        GET
            LOCAL lTicked AS LOGIC
            LOCAL cTickValue AS STRING

            lTicked := SELF:Checked

            IF SELF:FieldSpec != NULL
                cTickValue := ((FieldSpec)SELF:FieldSpec):Transform(lTicked)
            ELSE
                cTickValue := AsString(lTicked)
            ENDIF

            RETURN cTickValue
        END GET
        SET
            LOCAL lOldTicked AS LOGIC
            LOCAL lTicked AS LOGIC
            LOCAL uTicked AS USUAL

            lOldTicked := SELF:Checked
            IF SELF:FieldSpec != NULL
                uTicked := SELF:FieldSpec:Val(value)
                IF IsNumeric(uTicked)
                    lTicked := (uTicked != 0)
                ELSEIF IsLogic(uTicked)
                    lTicked := uTicked
                ELSE
                    lTicked := FALSE
                ENDIF
            ELSE
                lTicked := Unformat(value, "", "L")
            ENDIF

            IF (lTicked != lOldTicked)
                SELF:Checked := lTicked
                SELF:Modified := .T.
            ENDIF

            RETURN
        END SET
    END PROPERTY
    /// <include file="Gui.xml" path="doc/CheckBox.Value/*" />
    PROPERTY Value AS USUAL
        GET
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
        END GET
    END PROPERTY
END CLASS

