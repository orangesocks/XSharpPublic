
USING System
USING System.Collections.Generic
USING System.Text
USING System.IO
USING System.Runtime.CompilerServices
USING System.Reflection
USING System.Reflection.Emit
USING System.Runtime.InteropServices
USING System.Diagnostics

BEGIN NAMESPACE XSharp.RDD.CDX

    INTERNAL STATIC CLASS CdxHelpers
        STATIC METHOD ToAscii (SELF bytes AS BYTE[]) AS STRING
            RETURN ToAscii(bytes, FALSE)

        STATIC METHOD ToAscii (SELF bytes AS BYTE[], lHex AS LOGIC) AS STRING
            VAR sb := System.Text.StringBuilder{}
            IF bytes == NULL
                RETURN ""
            ENDIF
            IF lHex
                FOREACH VAR b IN bytes
                    //IF b > 0
                        sb:Append( String.Format("{0:X2}",b))
                    //ENDIF
                NEXT
                sb:Append(" ")
            ENDIF
            FOREACH VAR b IN bytes
                IF b > 31 .AND. b < 128
                    sb:Append( (CHAR) b)
                ELSE
                    sb:Append('.')
                ENDIF
            NEXT
            RETURN sb:ToString()
        STATIC CONSTRUCTOR
            KeyBitsTable := Dictionary <WORD, BYTE>{}

        INTERNAL STATIC KeyBitsTable AS Dictionary <WORD, BYTE>
        INTERNAL STATIC METHOD GetBits(wLength AS WORD) AS BYTE
            LOCAL bits AS BYTE
            
            IF KeyBitsTable:TryGetValue(wLength, OUT bits)
                RETURN bits
            ENDIF
            bits := 0
            LOCAL original := wLength AS WORD
            DO WHILE wLength > 0
                bits++
                wLength >>= 1
            ENDDO
            KeyBitsTable:Add(original, bits)
            RETURN bits
    END CLASS


    [DebuggerDisplay("{Page} {Pos}")];
    INTERNAL SEALED CLASS CdxStackEntry
        PROPERTY Page AS CdxTreePage AUTO
        PROPERTY Pos  AS WORD AUTO
    END CLASS

    [DebuggerDisplay("Stack: {Count}")];
    INTERNAL SEALED CLASS CdxPageStack
        PRIVATE _pages AS List<CdxStackEntry>
        CONSTRUCTOR(tag AS CdxTag)
            _pages := List<CdxStackEntry>{20}

        PROPERTY Count AS LONG GET _pages:Count
        // for debugging: easy access to the levels on the stack
        INTERNAL PROPERTY Entries AS List<CdxStackEntry> GET _pages
        METHOD Push(page AS CdxTreePage, nPos AS WORD)  AS LONG
            VAR entry := CdxStackEntry{}{ Page := page, Pos := nPos}
            _pages:Add(entry)
            RETURN _pages:Count

        METHOD Pop() AS LOGIC
            IF _pages:Count > 0
                _pages:RemoveAt(_pages:Count-1)
                RETURN TRUE
            ENDIF
            RETURN FALSE

        PROPERTY Top AS CdxStackEntry
            GET
                IF _pages:Count > 0
                    RETURN _pages[_pages:Count-1]
                ENDIF
                RETURN NULL
            END GET
        END PROPERTY

        PROPERTY Empty AS LOGIC GET _pages:Count == 0

        PROPERTY Root AS CdxStackEntry
            GET
                IF _pages:Count > 0
                    RETURN _pages[0]
                ENDIF
                RETURN NULL
            END GET
        END PROPERTY

        METHOD FindPage(nPage AS LONG) AS LONG     
            IF _pages:Count > 0
                FOR VAR i := 0 TO _pages:Count -1
                    IF _pages[i]:Page:PageNo == nPage
                        RETURN i
                    ENDIF
                NEXT
            ENDIF
            RETURN -1

        METHOD ReplacePage(nIndex AS LONG, oNewPage AS CdxTreePage) AS LOGIC
            IF nIndex >= 0 .AND. nIndex < SELF:_pages:Count
                VAR entry := _pages[nIndex]
                entry:Page := oNewPage
                RETURN TRUE
            ENDIF
            RETURN FALSE

        METHOD FindPage(oPage AS CdxTreePage) AS LONG
            RETURN SELF:FindPage(oPage:PageNo)

        METHOD Replace(originalPage AS CdxTreePage, newPage AS CdxTreePage, nPos := 0 AS WORD) AS LOGIC
            VAR index := SELF:FindPage(originalPage)
            IF index >= 0
                _pages[index] := CdxStackEntry{}{Page := newPage, Pos := nPos}
                 RETURN TRUE
            ENDIF
            RETURN FALSE
        
        METHOD InsertOnTop(newPage AS CdxTreePage) AS LOGIC
            _pages:Insert(0,CdxStackEntry{}{Page := newPage, Pos := 0})
             RETURN TRUE

        METHOD SetPos(oPage AS CdxTreePage, nPos AS WORD) AS LOGIC
            VAR index := SELF:FindPage(oPage)
            IF index >= 0
                _pages[index]:Pos := nPos
                RETURN TRUE
            ENDIF
            RETURN FALSE
            
        METHOD GetParent(oPage AS CdxTreePage) AS CdxTreePage
            VAR index := SELF:FindPage(oPage)
            IF index > 0
                RETURN _pages[index-1]:Page
            ENDIF
            RETURN NULL
            
        METHOD Clear() AS VOID
            SELF:_pages:Clear()
            RETURN
    END CLASS


    [DebuggerDisplay("Action {Type}")];
    INTERNAL SEALED CLASS CdxAction
        INTERNAL Type  	       AS CdxActionType 
        INTERNAL PageNo  := -1 AS LONG   
        INTERNAL PageNo2 := -1 AS LONG   
        INTERNAL Pos   	:= -1  AS LONG    
        INTERNAL Recno 	:= -1  AS LONG    
        INTERNAL Key   	:= NULL AS BYTE[] 
        INTERNAL ChildPage := -1 AS LONG  
        PRIVATE STATIC _Ok AS CdxAction

        STATIC CONSTRUCTOR
            _Ok := CdxAction{CdxActionType.Ok}

        PRIVATE CONSTRUCTOR(nType AS CdxActionType)
            Type   	:= nType

        STATIC PROPERTY Ok AS CdxAction GET _Ok

        METHOD IsOk AS LOGIC
            RETURN SELF:Type == CdxActionType.Ok

        INTERNAL STATIC METHOD AddKey( nRecno AS LONG, bKey AS BYTE[]) AS CdxAction
            RETURN CdxAction{CdxActionType.AddKey}{Recno := nRecno, Key := bKey}

        INTERNAL STATIC METHOD DeleteKey(oPage AS CdxTreePage, nPos AS LONG) AS CdxAction
            RETURN CdxAction{CdxActionType.DeleteKey}{PageNo := oPage:PageNo, Pos := nPos}

        INTERNAL STATIC METHOD AddLeaf(oLeaf AS CdxTreePage, nRecno AS LONG, bKey AS BYTE[] ) AS CdxAction
            RETURN CdxAction{CdxActionType.AddLeaf}{ PageNo := oLeaf:PageNo, Recno := nRecno, Key := bKey, Pos := -1}

        INTERNAL STATIC METHOD SplitLeaf(oLeaf AS CdxTreePage, nRecno AS LONG, bKey AS BYTE[], nPos AS LONG ) AS CdxAction
            RETURN CdxAction{CdxActionType.AddLeaf}{ PageNo := oLeaf:PageNo, Recno := nRecno, Key := bKey, Pos := nPos}

        INTERNAL STATIC METHOD InsertKey(oPage AS CdxTreePage, nPos AS LONG, nRecno AS LONG, bKey AS BYTE[]) AS CdxAction
            RETURN CdxAction{CdxActionType.InsertKey}{PageNo := oPage:PageNo, Pos := nPos,Recno := nRecno, Key := bKey}
            
        INTERNAL STATIC METHOD DeletePage(oPage AS CdxTreePage) AS CdxAction
            RETURN CdxAction{CdxActionType.DeletePage}{PageNo := oPage:PageNo}

        INTERNAL STATIC METHOD InsertParent(oPage AS CdxTreePage) AS CdxAction
            RETURN CdxAction{CdxActionType.InsertParent}{PageNo := oPage:PageNo}

        INTERNAL STATIC METHOD ChangeParent(oPage AS CdxTreePage) AS CdxAction
            RETURN CdxAction{CdxActionType.ChangeParent}{PageNo := oPage:PageNo}

        INTERNAL STATIC METHOD ChangeParent(oPage1 AS CdxTreePage, oPage2 AS CdxTreePage) AS CdxAction
            RETURN CdxAction{CdxActionType.ChangeParent}{PageNo := oPage1:PageNo, PageNo2 := oPage2:PageNo}

        INTERNAL STATIC METHOD AddBranch(oPage AS CdxTreePage,  nChild AS LONG, nRecno AS LONG, bKey AS BYTE[]) AS CdxAction
            RETURN CdxAction{CdxActionType.AddBranch}{PageNo := oPage:PageNo, ChildPage := nChild, Recno := nRecno, Key := bKey, Pos := -1}

        INTERNAL STATIC METHOD SplitBranch(oPage AS CdxTreePage,  nChild AS LONG, nRecno AS LONG, bKey AS BYTE[], nPos AS INT) AS CdxAction
            RETURN CdxAction{CdxActionType.AddBranch}{PageNo := oPage:PageNo, ChildPage := nChild, Recno := nRecno, Key := bKey, Pos := nPos}

        INTERNAL STATIC METHOD DeleteFromParent(oPage AS CdxTreePage) AS CdxAction
            RETURN CdxAction{CdxActionType.DeleteFromParent}{PageNo := oPage:PageNo}

        INTERNAL STATIC METHOD ExpandRecnos(oPage AS CdxLeafPage, nRecno AS LONG, bKey AS BYTE[], nPos AS INT) AS CdxAction
            RETURN CdxAction{CdxActionType.ExpandRecnos}{PageNo := oPage:PageNo, Recno := nRecno, Key := bKey, Pos := nPos}

        INTERNAL STATIC METHOD Balance(oPage AS CdxTreePage) AS CdxAction
            RETURN CdxAction{CdxActionType.Balance}{PageNo := oPage:PageNo}

        INTERNAL STATIC METHOD OutOfBounds(oPage AS CdxTreePage) AS CdxAction
            RETURN CdxAction{CdxActionType.OutOfBounds}{PageNo := oPage:PageNo}
            
    END CLASS

END NAMESPACE
