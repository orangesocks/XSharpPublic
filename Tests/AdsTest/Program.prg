USING XSHarp.ADS
using static XSHarp.ADS
using static System.Console
using VO

FUNCTION MyThrow(e as Exception)
    THROW e

CLASS DbLogger IMPLEMENTS IDbNotify
    METHOD Notify(sender AS XSharp.RDD.IRdd, e AS DbNotifyEventArgs) AS VOID
        IF (sender != NULL)
            ?  sender:Alias, sender:Area, '#',sender:Recno, e:Type:ToString(), e:Data
        ELSE
            ? "no area", e:Type:ToString(), e:Data
        ENDIF

END CLASS
PROCEDURE Main AS VOID
    TRY
        LOCAL aStruct := {{"NAME","C",10,0},{"CITY","C",10,0}}
        local b as CODEBLOCK
            b := {||_FIELD->NAME} 
    RddSetDefault("AXDBFCDX")
    DbRegisterClient(DbLogger{})
    ? DbCreate("test1",aStruct)
    ? DbUseArea(TRUE, ,"Test1","test",TRUE)
    ? Header()

    ? OrdCreate("test1","NAME",,b)
    ? OrdCreate("test2","CITY","CITY")
    ? OrdCreate("test3","NAMECITY","NAME+CITY")
    ? DbClearIndex()
    SetDeleted(TRUE)
    ? DbSetIndex("test1")
    ? DbSetIndex("test2")
    ? DbSetIndex("test3")
    VAR aList := OrdList()
    LOCAL index
    FOR index := 1 TO aLen(aList)
        ? index, "CUrrent", OrdSetFocus()
        ? index, aList[index], OrdSetFocus(index), OrdKey()
        ? index, "After change", OrdSetFocus()
    NEXT
    DbAppend()
    DbAppend()
    DbAppend()
    DbAppend()
    DbAppend()
    DbAppend()
    DbAppend()
    DbAppend()
    DbAppend()
    DbAppend()
    DbSetFilter({||!empty(_FIELD->Name)})
    DbGoto(6)
    OrdSetFocus(0)

    DbRLockList()
    ? Recno()
    ? DbCloseArea()
    CATCH e AS Exception
        ? e:ToString()
    END TRY
    WAIT
    RETURN
