//
// Start.prg
//
#include "dbcmds.vh"
USING XSharp.RDD
FUNCTION Start() AS VOID
    LOCAL cb AS CODEBLOCK
    TRY
        TestLb()
        // TestCopyStruct()
        //TestDbf()
        //WaTest()
        //bigDbf()
        //testReplace()
        //testRebuild()
        //testUnique()
        //testClearOrderScope()
        //testReplaceTag()
        //TestCdxCreateConditional()
        //TestCloseArea()
//        TestGermanSeek()
//        wait
//        TestCdxForward()
//        wait
//        TestCdxBackward()
//        wait
        //TestCdxSeek()
        //TestCdxCount()
        //TestCdxNumSeek()
        //CloseCdx()
        //TestDescend()
        //TestCdxDateSeek()
        //DumpNtx()
        //Start1a()
        //Start1b()
        //Start2()
        //Start3()
        //Start4()
        //Start5()
        //Start6()
        //Start7()
        //Start8()
        //Start9()
        //Start10()
        //Start11()
        CATCH e
        ErrorDialog(e)
    END TRY
    WAIT
    RETURN
DEFINE LANG_GERMAN := 0x07
DEFINE SUBLANG_GERMAN := 0x01 // German
DEFINE SORT_DEFAULT := 0x0 // sorting default
DEFINE SORT_GERMAN_PHONE_BOOK := 0x1 // German Phone Book order

	FUNCTION testLb() AS VOID STRICT
        LOCAL x AS TestLbClass
        LOCAL o AS OBJECT
        o := CreateInstance("TestLbClass2")
        x := TestLbClass{}
        o := x
        TRY
            o:ThisPropertyDoesNotExist := Today()
            CATCH Ex AS Error
            LOCAL y AS Error
            y := Ex
            ? y:ToString()
        END TRY
        
    RETURN      


    CLASS TestLbClass 
        
        PUBLIC CONSTRUCTOR() 
        
        RETURN 
        
                 
        
    END CLASS 

function TestCopyStruct() AS VOID
LOCAL cDBF, cPfad, cCopyStructTo AS STRING
LOCAL aFields AS ARRAY

aFields := { { "LAST" , "C" , 512 , 0 },;
           { "AGE" , "N" , 3 , 0 } ,;
           { "SALARY" , "N" , 10 , 2 },;
           { "HIREDATE" , "D" , 8 , 0 },;
           { "MARRIED" , "L" , 1 , 0 }}

cPfad := ""
cDBF := cPfad + "Foo"
cCopyStructTo := "D:\test\foonew"

? DBCreate( cDBF , AFields)
? DBUseArea(,"DBFNTX",cDBF )

// "The name 'DBCopyStruct' does not exist in the current context"
// ? DBCopyStruct( cCopyStructTo )

? DBCopyStruct(cCopyStructTo, { "last" , "age" , "married" } )   // ok
DBCloseAll()
RETURN 

function TestDbf() as void
LOCAL cDBF, cPfad AS STRING
LOCAL aFields AS ARRAY

// DBF() throws an EG_NOTABLE error, but should return "" if no table is
// opened in the current workarea

? DBF() // exception

aFields := { { "LAST" , "C" , 10 , 0 }}
cPfad := ""
cDBF := cPfad + "Foo"
            // -----------------
? DBCreate( cDBF , AFields)
? DBUseArea(,"DBFNTX",cDBF , "FOOALIAS")

? DBF() // Returns the fullpath instead of the alias name

DBCloseAll()

? DBF() // should return empty string
RETURN 


function TestUnique() as void
local cDbf as STRING
local aFields as ARRAY
local nMax := 1000 as long
local nCnt as long
cDBF := "Foo"
aFields := {{ "NAME" , "C" , 10 , 0 }}
DBCreate( cDBF , aFields,"DBFCDX")
DBCloseAll()
DBUseArea( TRUE ,"DBFCDX",cDBF,"Foo",FALSE)
FOR var i := 1 to nMax
    DbAppend()
    FieldPut(1, str(i,10,0))
NEXT
DbCreateIndex("Foo","Name",,TRUE)
DbGoTop()
DO WHILE ! EOF()
    ? Recno(), FieldGet(1)
    DbSkip(1)
ENDDO
wait
FOR var i := 1 to nMax
    DbGoto(i)
    FieldPut(1, "AAAAAAAAAA")
NEXT
DbGoTop()
nCnt := 0
DO WHILE ! EOF()
    ? Recno(), FieldGet(1)
    DbSkip(1)
    nCnt++
ENDDO
? nCnt, "records"
Wait
FOR var i := 1 to nMax
    DbGoto(i)
    FieldPut(1, str(i,10,0))
NEXT
DbGoTop()
nCnt := 0
DO WHILE ! EOF()
    ? Recno(), FieldGet(1)
    DbSkip(1)
    nCnt++
ENDDO
? nCnt, "records"

DbCloseAll()
return
function testRebuild() as void
LOCAL cDbf AS STRING
cDbf := "c:\test\TEST10K"
? DBUseArea(,"DBFCDX",cDbf)
? DbReindex()
RETURN 



function WaTest() as void
LOCAL cDBF AS STRING
LOCAL aFields AS ARRAY
LOCAL dwStartWA, dwMaxWA AS DWORD

RDDSetDefault ( "DBFNTX" )

cDBF := "Foo"
aFields := {{ "AGE" , "N" , 2 , 0 }}
DBCreate( cDBF , aFields)
DBCloseAll()

DBUseArea( TRUE ,"DBFNTX",cDBF,"FOO1",TRUE)
DBUseArea( TRUE ,"DBFNTX",cDBF,"FOO2",TRUE)

dwStartWA := DBGetSelect() // 2

? DBSetSelect (0 ) // 3 ok, shows the next unused workarea
? SELECT (0) // 3 ok, shows the next unused workarea
?
// ok, -1 returns the max workarea
dwMaxWA := DBSetSelect ( -1 ) // x# 4096 , VO 1023
? dwMaxWA

// if a workArea ( dwMaxWa + 1 ) is selected
// X# should return 0 as VO does, currently X# throws an argument exception instead
//
? DBSetSelect ( dwMaxWA + 1 ) // X# throws a exception, VO returns 0
? SELECT ( dwMaxWA + 1 ) // X# throws a exception, VO returns 0
?
// each param -1, e.g. -4, should be treated like a param 0, that shows the next unused workarea.
// in X# currently something like -4 returns (0xffffffff -4 ) + 1
? DBSetSelect ( - 4 ) // X# 4294967292 , VO 3
? SELECT ( - 4 ) // X# 4294967292 , VO 3
?
// switch back to the workarea 2
DBSetSelect ( dwStartWA )
?
? "DbSymSelect results"
?
? DBSymSelect() // 2 , ok - current work area

? DBSymSelect( #Foo2 ) // ok , 2
//
// VO throws an DataType Error if a param != symbol is used
//
// e.g. VO throws an Data Type Error type: longint requested type: symbol
? DBSymSelect( 1 ) // X# doesn�t throw a exceptions but returns 0

// e.g. VO throws an Data Type Error. type: string requested type: symbol
? DBSymSelect( "Foo1" ) // X# doesn�t throw a exceptions but returns 1

// e.g. VO throws an Data Type Error . type: codeblock requested type: symbol
? DBSymSelect( {|| } ) // X# doesn�t throw a exceptions but returns 0

DBCloseAll()
RETURN

Function BigDbf as void
LOCAL aFields AS ARRAY
LOCAL cDBF, cPath AS STRING

RDDSetDefault ( "DBFNTX" )

aFields := {{ "LAST" , "C" , 511 , 0 } ,{ "AGE" , "N" , 3 , 0 }}
cPath := "c:\test\"

cDBF := cPath + "foo"

? DBCreate( cDBF , AFields , "DBFNTX" ) // true
? DBUseArea(,"DBFNTX",cDBF,,FALSE) // true
DbAppend()
// NOTE: the size of the "LAST" field is 255 and not as expected 511
// DBUSEAREA() doesn �t crash
DBCloseAll()
// ------------------------------------------
cDBF := cPath + "foo2"
// Note: the size of the "LAST" field should be now 2048
aFields := {{ "LAST" , "C" , 2048 , 0 } , { "AGE" , "N" , 3 , 0 }}

? DBCreate( cDBF , AFields , "DBFNTX") // true

? DBUseArea(,"DBFNTX",cDBF,,FALSE) // exception
DbAppend()
// NOTE: the size of the "LAST" field shown is 0 and not 2048 !
// so DBUSEAREA crashes.

DBCloseAll()
RETURN

Function TestClearOrderScope as void
    LOCAL cDbf AS STRING
    LOCAL aValues AS ARRAY
    LOCAL i AS DWORD
    
    cDBF := "c:\test\tmp1"

    RDDSetDefault("DBFNTX")

    aValues := { "vvv" , "abb", "acb" , "aaa"  , "bbb" }
    DBCreate( cDBF , {{"LAST" , "C" ,10 , 0 } })
    DBUseArea(,"DBFNTX",cDBF,,FALSE)
    FOR i := 1 UPTO ALen ( aValues )
        DBAppend()
        FieldPut(1,aValues [i])
    NEXT
    DBCloseArea()

    DBUseArea(,"DBFNTX",cDBF,,TRUE)
    DBCreateIndex(cDbf, "Upper(LAST)" )
    ? DBOrderInfo( DBOI_KEYCOUNT ) // 5 ok

    LOCAL u AS USUAL
    u := "A"
    ? VODBOrderInfo( DBOI_SCOPETOP, "", NIL, REF u )
    ? VODBOrderInfo( DBOI_SCOPEBOTTOM, "", NIL, REF u )
    ? DBOrderInfo( DBOI_KEYCOUNT ) // 3 ok

    
    // clear scope
    u := NIL // it is called in the SDK this way
    ? VODBOrderInfo( DBOI_SCOPETOPCLEAR, "", NIL, REF u )
    ? VODBOrderInfo( DBOI_SCOPEBOTTOMCLEAR, "", NIL, REF u )
    ? DBOrderInfo( DBOI_KEYCOUNT ) // 3 again, should be 5
    ?
    DBGoTop()
    // not all records are shown
    DO WHILE ! EOF()
        ? FieldGet(1)
        DBSkip(1)
    ENDDO

    DBCloseArea()
RETURN 

FUNCTION TestReplace() AS VOID
LOCAL cDBF AS STRING
local f as float
local nMax := 50000 as Long
cDBF := "c:\test\TestRepl"
FErase(cDbf+".dbf")
FErase(cDbf+".cdx")
DBCreate(cDbf , {{"FIELDC","C",10,0},{"FIELDL","L",1,0}})
DBUseArea(,"DBFCDX",cDBF)

FOR VAR i := 1 TO nMax
    DbAppend()
    FieldPut(1, Str(i,10))
    FieldPut(2, TRUE)
NEXT
DBSETORDERCONDITION("FIELDL",{||_FIELD->FIELDL})
f := Seconds()
DbCreateIndex(cDbf, "FIELDC",,FALSE)
? Seconds() - f
? DbOrderInfo(DBOI_KEYCOUNT)
f := Seconds()
FOR VAR i := 1 TO nMax
    DbGoto(i)
    FieldPut(2, FALSE)
NEXT
? "update 1", Seconds() - f
//
DbSetOrder(1)
? DbOrderInfo(DBOI_KEYCOUNT)
? DbOrderInfo(DBOI_USER+42)
f := Seconds()

FOR VAR i := 1 TO nMax
    DbGoto(i)
    FieldPut(2, TRUE)
NEXT
? "update 2", Seconds() - f

? DbOrderInfo(DBOI_KEYCOUNT)


DbCloseArea()
RETURN


FUNCTION TestReplaceTag() AS VOID
LOCAL cDBF AS STRING
cDBF := "c:\test\Test10k"
RddSetDefault("DBFCDX")
DBUSEAREA(TRUE,"DBFCDX",cDBF,"Test",FALSE,FALSE)
DbCreateOrder("Salary",, "Salary")
DbCreateOrder("Age",, "AGE")
? DbOrderInfo(DBOI_ORDERCOUNT)
WAIT
DbCloseArea()
DBUSEAREA(TRUE,"DBFCDX",cDBF,"Test",FALSE,FALSE)
? DbOrderInfo(DBOI_ORDERCOUNT)
OrdDestroy("Age")
DbCreateOrder("Age",, "AGE")
WAIT
? DbOrderInfo(DBOI_ORDERCOUNT)
DbCLoseArea()
RETURN

FUNCTION TestCdxCreateConditional() AS VOID
LOCAL cDBF AS STRING
LOCAL f AS FLOAT
f := Seconds()
? "Creating tags"
cDBF := "c:\test\Test10k"
RddSetDefault("DBFCDX")
DBUSEAREA(TRUE,"DBFCDX",cDBF,"Test",FALSE,FALSE)
// Descending
? "Age"
DBSETORDERCONDITION("State='MT'",{||_FIELD->STATE='MT'},,,{|e|Qout(Recno()),TRUE},1000)
DBCREATEINDEX("Age", "AGE")         
? DbOrderInfo(DBOI_KEYCOUNT)
? "AgeDesc"
DBSETORDERCONDITION(,,,,,,,,,,TRUE)
DBCREATEINDEX("AgeDesc", "AGE")
? DbOrderInfo(DBOI_KEYCOUNT)
DBSETORDERCONDITION(,,FALSE,,,,1,10)
DBCREATEINDEX("Age10", "AGE")
DBSETORDERCONDITION("Age>40",,,,,,,,,,TRUE)
DBCREATEINDEX("STATE", "STATE")

? DbOrderInfo(DBOI_KEYCOUNT)
DBCLOSEALL()
RETURN

FUNCTION TestGermanSeek() AS VOID
LOCAL cDBF AS STRING
cDbf := "C:\Test\TESTDBF"
RDDSetDefault("DBFNTX")

SetCollation(#WINDOWS)
//SetAppLocaleId(MAKELCID(MAKELANGID(LANG_GERMAN, SUBLANG_GERMAN),SORT_GERMAN_PHONE_BOOK)) // Telefonbuch
SetAppLocaleID(MAKELCID(MAKELANGID(LANG_GERMAN, SUBLANG_GERMAN),SORT_DEFAULT)) // W�rterbuch

DBCreate(cDbf , {{"LAST","C",10,0}})
DBUseArea(,,cDBF)
DBAppend()
FieldPut(1 , "�rger")
DBAppend()
FieldPut(1 , "Aaaaa")
DBCloseArea()


DBUseArea(,,cDBF)
DBCreateIndex(cDbf , "LAST")
? DBSeek("�") // FALSE in X#, TRUE in VO
? Recno(), Found(), FieldGet(1)
? DBSeek("�rger") // TRUE in both
? Recno(), Found(), FieldGet(1)
DBGoTop()
DO WHILE .NOT. eof()
? Recno(), FieldGet(1)
DBSkip()
END DO
DBCloseArea()
RETURN
FUNCTION TestDbApp() AS VOID
LOCAL aFields, aValues AS ARRAY
LOCAL cDbf, cPath AS STRING
LOCAL i AS DWORD

cPath := "c:\test\"
// --------- create From.dbf ----------
cDbf := cPath + "from.dbf"

aFields := {{ "GRUPPE" , "C" , 30 , 0 } ,;
{ "ID" , "C" , 5 , 0 } }

aValues := { { "Grp1" , "00001" } ,;
{ "Grp2" , "00002" } }

? DBCreate( cDbf , aFields , "DBFNTX" )
? DBUseArea(,"DBFNTX",cDbf,,FALSE)
FOR VAR j :=1 TO 100000
FOR i := 1 UPTO ALen ( aValues )
DBAppend()
FieldPut ( 1 , aValues [ i , 1 ] )
FieldPut ( 2 , aValues [ i , 2 ] )
NEXT
NEXT
// --------- create To.dbf ----------
cDbf := cPath + "To.dbf"

// error happens also without that
AAdd ( aFields , { "ID2", "N" , 5 , 0 } )

? DBCreate( cDbf , aFields , "DBFNTX" )
DBCloseAll()
// ---- append the From.dbf content to the To.dbf ----
cDbf := cPath + "To.dbf"
? DBUseArea(,"DBFNTX",cDbf,,FALSE)
VAR f := seconds()
? DBApp ( cPath + "From.dbf" ) // ------- IndexOutofRangeException
? seconds() - f
DBCloseAll()
RETURN
FUNCTION TestCloseArea() AS VOID
LOCAL aFields AS ARRAY
LOCAL cDbf, cPath AS STRING


cPath := ""
cDbf := "Foo.dbf"

// ----------------


cDbf := cPath + cDBF

aFields := {{ "LAST" , "C" , 10 , 0 } }


? DBCreate( cDbf , aFields , "DBFNTX" )

?
? DBUseArea( TRUE ,"DBFNTX",cDbf, "FOO1", TRUE)
? DBGetSelect() // 1 ok

?
? DBUseArea( TRUE ,"DBFNTX",cDbf, "FOO2", TRUE)
? DBGetSelect() // 2 ok

?
? DBUseArea( TRUE ,"DBFNTX",cDbf, "FOO3", TRUE)
? DBGetSelect() // 3 ok

?
? DBUseArea( TRUE ,"DBFNTX",cDbf, "FOO4", TRUE)
? DBGetSelect() // 4 ok
?
? DBSetSelect ( 3 ) // 3 ok
?
?
? DBCloseAll()
? DBGetSelect() // Shows 3 instead of 1
? SELECT() // Shows 3 instead of 1

?

? DBUseArea( ,"DBFNTX",cDbf, "FOO1", TRUE)
? DBGetSelect() // shows 3 instead of 1

? DBUseArea( TRUE ,"DBFNTX",cDbf, "FOO2", TRUE)
? DBGetSelect() // shows 1 instead of 2

RETURN
FUNCTION TestChris() AS VOID
LOCAL aValues AS ARRAY
	LOCAL i AS DWORD
	LOCAL cDBF AS STRING
	LOCAL cCdx AS STRING

	RddSetDefault("DBFCDX")

	aValues := { 44 , 12, 34 , 21 }                                
	cDBF := "testcdx"
	cCdx := cDBF + ".cdx"
	FErase(cCdx)
	DBCREATE( cDBF , {{"AGE" , "N" , 3 , 0 } })                                        
	DBUSEAREA(,"DBFCDX",cDBF,,FALSE)
	? DbOrderInfo( DBOI_KEYCOUNT ) 
	FOR i := 1 UPTO ALen ( aValues )
		DBAPPEND()
		FIELDPUT(1,aValues [i]) 
	NEXT
	? DbOrderInfo( DBOI_KEYCOUNT  ) 
	? DbOrderInfo( DBOI_NUMBER )    


	DBCREATEINDEX( cCdx, "age" )
	DBCLOSEAREA()
	
	DBUSEAREA(,"DBFCDX",cDBF,,FALSE)
	DbSetOrder(1)
	
	DbGotop()
	DO WHILE ! EOF()
		DBSKIP(1)
	ENDDO

	? DBCLEARINDEX( )
    ? DbOrderInfo( DBOI_ORDERCOUNT )

	DbGotop()
	? RECNO()

	?  DbSetIndex ( cCdx ) 

	? DbOrderInfo( DBOI_KEYCOUNT )  // 4, ok
	? DbOrderInfo( DBOI_NUMBER )  // still  -1 , but should show  1
	?  DbOrderInfo( DBOI_NAME )   // ok , "TESTDBF"
	DBCLOSEAREA ()
DBCloseArea()
RETURN
FUNCTION TestCdxCreate() AS VOID
LOCAL cDBF AS STRING
LOCAL cIndex AS STRING
LOCAL aTags AS ARRAY
LOCAL aClone AS ARRAY
LOCAL i AS DWORD
LOCAL f AS FLOAT
f := Seconds()
? "Creating tags"
cDBF := "c:\test\Test10k"
RddSetDefault("DBFCDX")
aTags := {"AGE","CITY","FIRST","HIREDATE", "LAST","SALARY","STATE"}
FOR i := 1 TO ALen(aTags)
	VODBUSEAREA(TRUE,"DBFCDX",cDBF,"Test",FALSE,FALSE)
	aClone := AClone(aTags)
	cIndex := cDBF+NTrim(i)
    Ferase(cIndex+".CDX")
	ASize(aClone, i)
	AEval(aClone , {|cTag|  OrdCreate(cIndex, cTag, cTag) })
	DBCLOSEAREA()
NEXT
VODBUSEAREA(TRUE,"DBFCDX",cDBF,"Test",FALSE,FALSE)
AEval(aTags, {|cTag| OrdCreate(cDbf, cTag, cTag)})
? Seconds() - f
FOREACH cTag AS STRING IN aTags
    ? "Dumping tag ",cTag
    DbSetOrder(cTag)
    DbOrderInfo(DBOI_USER+42)
NEXT

RETURN


FUNCTION TestCdxCreate1() AS VOID
LOCAL cDbf AS STRING
LOCAL i AS LONG
cDbf := "c:\test\TestCreate"
RddSetDefault("DBFCDX")
DBCreate( cDbf , {{"CFIELD" , "C" , 10 , 0 }})
DBUseArea(,"DBFCDX",cDbf)
FOR i := 1 TO 100
DbAppend()
FieldPut(1, "AAA")
DbAppend()
FieldPut(1, "ABC")
NEXT
OrdCreate(cDBF, "CFIELD" ,"CFIELD")
DBCloseArea()
RETURN

FUNCTION TestDescend() AS VOID
LOCAL cDbf AS STRING
cDbf := "c:\test\Names"
DBUseArea(,"DBFCDX",cDbf)
DbSeek("Chris")
DO WHILE .NOT. EOF()
    ? Recno(), FieldGet(1) // should show 4,3
    DBSkip()
END DO
DBCloseArea()
RETURN

FUNCTION CloseCdx AS VOID
	LOCAL cDbf AS STRING
	LOCAL cCdx AS STRING
    RDDSetDefault("DBFCDX")
	cDbf := "C:\test\testcdx"
	cCdx := cDbf + ".cdx"
    FErase(cCdx)
			
	DBCreate( cDbf , {{"CFIELD" , "C" , 10 , 0 }})
	DBUseArea(,,cDbf,,FALSE)
	DBAppend()
	FieldPut ( 1 , "B")
	DBAppend()
	FieldPut ( 1 , "A")
	DBCloseArea()
			
	DBUseArea(,,cDbf,,TRUE)
	System.IO.File.WriteAllBytes(cCdx , Convert.FromBase64String("AAQAAAAAAAAAAAAACgDgAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQABAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAQD//////////94B//8AAA8PEAQEAwAGMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABURVNUQ0RYAAoAAAAAAAAAAAAACgBgAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABwABAAAABwBDRklFTEQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAgD//////////+AB//8AAA8PEAQEAwIAkAEAkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEJB"))
    DBCloseArea()
			
	DBUseArea(,,cDbf,,FALSE)
	//DBSetIndex(cCdx)
    DBSetOrder(1)
	DBGoTop()
	DBCloseArea()

	? DBUseArea(,,cDbf,,FALSE)
	DBCloseArea()
			
			
    ? FErase(cDbf + ".dbf")
    ? FErase(cCdx)

RETURN


    
FUNCTION Start1() AS VOID
LOCAL cDbf AS STRING
cDBF := "testdbf"

DBCreate( cDBF , {{"FIELDN" , "N" ,5 , 0 } } )
DBUseArea(,"DBFNTX",cDBF)
DBAppend()
FieldPut(1,3)
DBAppend()
FieldPut(1,1)
DBAppend()
FieldPut(1,4)
DBAppend()
FieldPut(1,2)

DBSetOrderCondition(,,,,,,,,,,TRUE)
DBCreateIndex(cDbf, "FIELDN" )

DBOrderInfo( DBOI_SCOPETOP, "", NIL, 3 )
DBOrderInfo( DBOI_SCOPEBOTTOM, "", NIL, 2 )

// prints 3,2,1. If the order of scopes is
// changed to 2->3, then it prints 2,1
DBGoTop()
DO WHILE .NOT. EoF()
? FieldGet(1)
DBSkip()
END DO
DBCloseArea()
RETURN
    FUNCTION TestCdxNumSeek AS VOID
    ? VoDBUSEAREA(TRUE, typeof(DBFCDX), "c:\XSharp\DevRt\Runtime\XSharp.Rdd.Tests\dbfs\TEST10K.DBF", "TEST",TRUE,TRUE)
    DbSetOrder("Age")
    FOR VAR i := 20 TO 90
        IF DbSeek(i,TRUE,FALSE)
            ? FieldGetSym(#Age), str(Recno(),4), FieldGetSym(#First), FieldGetSym(#Last)
        ENDIF
        IF DbSeek(i,TRUE,TRUE)
            ? FieldGetSym(#Age), str(Recno(),4), FieldGetSym(#First), FieldGetSym(#Last)
        ENDIF
    NEXT
    RETURN
    FUNCTION TestCdxDateSeek AS VOID
    ? VoDBUSEAREA(TRUE, typeof(DBFCDX), "c:\XSharp\DevRt\Runtime\XSharp.Rdd.Tests\dbfs\TEST10K.DBF", "TEST",TRUE,TRUE)
    DbSetOrder("Hiredate")
    ? DbSeek(1989.06.15,TRUE,FALSE)
    ? Recno(), FieldGetSym(#First), FieldGetSym(#Last), FieldGetSym(#HireDate)
    RETURN
    FUNCTION TestCdxCount() AS VOID
    LOCAL aTags AS ARRAY
    LOCAL f AS FLOAT
    f := seconds()

    ? VoDbUseArea(TRUE, TYPEOF(DBFCDX), "c:\XSharp\DevRt\Runtime\XSharp.Rdd.Tests\dbfs\TEST10K.DBF", "TEST",TRUE,TRUE)
    aTags := {"AGE", "CITY", "STATE", "FIRST","LAST","HIREDATE","SALARY"} 
    FOR VAR i := 1 TO  alen(aTags)
        DbSetOrder(aTags[i])
        ? aTags[i], DbOrderInfo(DBOI_KeyCount)
    NEXT
    ? Seconds() - f
    RETURN    

FUNCTION TestCdxSeek() AS VOID
    //LOCAL aTags AS ARRAY
    ? VoDbUseArea(TRUE, TYPEOF(DBFCDX), "c:\XSharp\DevRt\Runtime\XSharp.Rdd.Tests\dbfs\TEST10K.DBF", "TEST",TRUE,TRUE)
    //aTags := {"AGE", "CITY", "STATE", "FIRST","LAST","HIREDATE","SALARY"} 
    //FOR VAR i := 1 TO  alen(aTags)
    VAR nCount := 0
    /*
    ? DbSetOrder("LAST")
    ? "Seek Peters"
    ? DbSeek("Peters",TRUE, FALSE), Found(), Eof()
    DO WHILE ! EOF() .AND. FieldGetSym(#Last) = "Peters"
        ? Recno(), FieldGetSym(#First), FieldGetSym(#Last)
        ++nCount
        VoDbSkip(1)
    ENDDO

    ? nCount
    ? DbSeek("Peters",TRUE, TRUE), Found(), Eof()
    nCount := 0
    DO WHILE ! BOF() .AND. FieldGetSym(#Last) = "Peters"
        ? Recno(), FieldGetSym(#First), FieldGetSym(#Last)
        ++nCount
        VoDbSkip(-1)
    ENDDO
    ? nCount
    wait

    ? "Seek State MI"
    ? DbSetOrder("STATE")
    nCount := 0
    ? DbSeek("MI",TRUE, FALSE), Found(), Eof()
    DO WHILE ! EOF() .AND. FieldGetSym(#State) == "MI"
        ? Recno(), FieldGetSym(#First), FieldGetSym(#Last), FieldGetSym(#State)
        ++nCount
        VoDbSkip(1)
    ENDDO
    ? nCount
    wait
    ? "Seek last State MI"
    ? DbSeek("MI",TRUE, TRUE), Found(), Eof()
    nCount := 0
    DO WHILE ! BOF() .AND. FieldGetSym(#State) = "MI"
        ? Recno(), FieldGetSym(#First), FieldGetSym(#Last), FieldGetSym(#State)
        ++nCount
        VoDbSkip(-1)
    ENDDO
    ? nCount
    */
    ? "Seek First Yao"
    ? DbSetOrder("FIRST")
    nCount := 0
    //? DbSeek("Yao",TRUE, FALSE), Found(), Eof()
    DbGoto(81)
    DO WHILE ! EOF() .AND. FieldGetSym(#First) = "Yao"
        ? Recno(), FieldGetSym(#First), FieldGetSym(#Last)
        ++nCount
        VoDbSkip(1)
    ENDDO
    ? nCount
    WAIT
    ? "Seek last Yao"
    ? DbSeek("Yao",TRUE, TRUE), Found(), Eof()
    nCount := 0
    DO WHILE ! BOF() .AND. FieldGetSym(#First) = "Yao"
        ? Recno(), FieldGetSym(#First), FieldGetSym(#Last)
        ++nCount
        VoDbSkip(-1)
    ENDDO

    ? nCount
    VoDbCLoseArea()

    RETURN
FUNCTION TestCdxForward() AS VOID
    LOCAL f AS FLOAT
    ? VoDbUseArea(TRUE, TYPEOF(DBFCDX), "c:\XSharp\DevRt\Runtime\XSharp.Rdd.Tests\dbfs\TEST10K.DBF", "TEST",TRUE,TRUE)
    LOCAL aTags AS ARRAY
    f := seconds()
    aTags := {"AGE", "CITY", "STATE", "FIRST","LAST","HIREDATE","SALARY"}
    ? " Count skip +1"
    FOR VAR i := 1 TO  alen(aTags)
        DbSetOrder(aTags[i])
        ? aTags[i]
        //DbOrderInfo(DBOI_USER+42,,aTags[i])
        VoDbGoTop()
        //? Recno(), FieldGetSym(#First), FieldGetSym(#Last), FieldGetSym(AsSymbol(aTags[i]))
        VAR nCount := 0
        DO WHILE ! VoDbEof()
            nCount++
            LOCAL u AS USUAL
            VoDbFIeldGet(1, REF u)
            VoDbSkip(1)
        ENDDO
        //DbGoBottom()
        //? Recno(), FieldGetSym(#First), FieldGetSym(#Last), FieldGetSym(AsSymbol(aTags[i]))
        ? nCount
     
    NEXT
    ? Seconds() - f
    DbCloseArea()
    RETURN
FUNCTION TestCdxBackward() AS VOID
    LOCAL f AS FLOAT
    ? VoDbUseArea(TRUE, TYPEOF(DBFCDX), "c:\XSharp\DevRt\Runtime\XSharp.Rdd.Tests\dbfs\TEST10K.DBF", "TEST",TRUE,TRUE)
    LOCAL aTags AS ARRAY
    f := seconds()
    aTags := {"AGE", "CITY", "STATE", "FIRST","LAST","HIREDATE","SALARY"}
    ? " Count skip -1"
    FOR VAR i := 1 TO  alen(aTags)
        DbSetOrder(aTags[i])
        ? aTags[i]
        //DbOrderInfo(DBOI_USER+42,,aTags[i])
        VoDbGoBottom()
        ? Recno(), FieldGetSym(#First), FieldGetSym(#Last), FieldGetSym(AsSymbol(aTags[i]))
        VAR nCount := 0
        DO WHILE ! VoDbBof()
            nCount++
            VoDbSkip(-1)
        ENDDO
        ? Recno(), FieldGetSym(#First), FieldGetSym(#Last), FieldGetSym(AsSymbol(aTags[i]))

        ? nCount
     
    NEXT
    DbCloseArea()
    ? Seconds() - f
    RETURN    
FUNCTION DumpNtx() AS VOID
    SetAnsi(TRUE)
    SetCollation(#Windows)
    USE "c:\XSharp\DevRt\Runtime\XSharp.Rdd.Tests\dbfs\TEST10K.DBF"
    DbCreateIndex("10kName.xxx", "upper(Last+First)")
    DbCreateIndex("10kState", "State")
    DbCreateIndex("10kSalary", "Salary")
    DbCreateIndex("10kDate", "Hiredate")
    DbSetIndex()
    // Dump the indexes
    DbSetIndex("c:\XSharp\DevRt\Runtime\XSharp.Rdd.Tests\dbfs\10kName.xxx")
    DbOrderInfo(DBOI_USER+42)
    DbSetIndex("c:\XSharp\DevRt\Runtime\XSharp.Rdd.Tests\dbfs\10kSalary.ntx")
    DbOrderInfo(DBOI_USER+42)
    DbSetIndex("c:\XSharp\DevRt\Runtime\XSharp.Rdd.Tests\dbfs\10kState.ntx")
    DbOrderInfo(DBOI_USER+42)
    DbSetIndex("c:\XSharp\DevRt\Runtime\XSharp.Rdd.Tests\dbfs\10kDate.ntx")
    DbOrderInfo(DBOI_USER+42)
    DbCloseArea()
    WAIT
    RETURN
    
    
    
FUNCTION Start1a() AS VOID
    LOCAL aStruct AS ARRAY
    LOCAL i AS DWORD
    aStruct := {{"CHARFIELD","C",10,0},{"NUMFIELD","N",3,0},{"DATEFIELD","D", 8,0}}
    SetAnsi(TRUE)
    SetCollation(#Windows)
    SetNatDLL("german2.dll")
    DBCREATE("Test1Ansi",aStruct, "DBFNTX")
    DBCLOSEAREA()
    USE Test1Ansi       
    FOR i := 1 TO 255
        DBAPPEND()
        _FIELD->CHARFIELD := Replicate(CHR(i),10)
        _FIELD->NUMFIELD  := i
        _FIELD->DATEFIELD := ConDate(1800 + i, 1 + i % 12, 1 + i % 28)
    NEXT
    DBCREATEINDEX("test1Ansi1","CHARFIELD")
    DBCREATEINDEX("test1Ansi2","NUMFIELD")
    DBCREATEINDEX("test1Ansi3","DATEFIELD")
    
    DBCLOSEAREA()
    SetAnsi(FALSE)
    DBCREATE("Test1OEM",aStruct, "DBFNTX")
    DBCLOSEAREA()
    USE Test1OEM       
    FOR i := 1 TO 255
        DBAPPEND()
        _FIELD->CHARFIELD := Replicate(CHR(i),10)
        _FIELD->NUMFIELD  := i
        _FIELD->DATEFIELD := ConDate(1800 + i, 1 + i % 12, 1 + i % 28)
    NEXT                  
    SetCollation(#Clipper)
    DBCREATEINDEX("test1Oem1","CHARFIELD")
    DBCREATEINDEX("test1Oem2","NUMFIELD")
    DBCREATEINDEX("test1Oem3","DATEFIELD")
    DBCLOSEAREA()
    RETURN
    
FUNCTION Start1b() AS VOID
    LOCAL aStruct AS ARRAY
    LOCAL i AS DWORD
    aStruct := {{"CHARFIELD","C",10,0},{"NUMFIELD","N",3,0},{"DATEFIELD","D", 8,0}}
    SetAnsi(TRUE)
    ? XSharp.RuntimeState.WinCodePage
    SetCollation(#Windows)
    DBCREATE("Test2Ansi",aStruct, "DBFNTX")
    DBCLOSEAREA()
    USE Test2Ansi       
    FOR i := 32 TO 255
        DBAPPEND()
        _FIELD->CHARFIELD := Replicate(CHR(i),10)
        _FIELD->NUMFIELD  := i
        _FIELD->DATEFIELD := ConDate(1800 + i, 1 + i % 12, 1 + i % 28)
    NEXT
    DBCREATEINDEX("test2Ansi1","CHARFIELD")
    DBCREATEINDEX("test2Ansi2","NUMFIELD")
    DBCREATEINDEX("test2Ansi3","DATEFIELD")
    DbClearIndex()
    DbSetIndex("test2Ansi1")
    DbSetIndex("test2Ansi2")
    DbSetIndex("test2Ansi3")
    OrdSetFocus(0)
    DO WHILE ! EOF()
        _FIELD->CHARFIELD := ""
        _FIELD->NUMFIELD  := 0
        _FIELD->DATEFIELD := ToDay()
        DBSKIP(1)
    ENDDO
    DbCommit()
    OrdSetFocus(1,"TEST2ANSI1")
    DbOrderInfo(DBOI_USER+42)
    OrdSetFocus(2)
    DbOrderInfo(DBOI_USER+42)
    OrdSetFocus(3)
    DbOrderInfo(DBOI_USER+42)
    DBCLOSEAREA()
    RETURN
    
    
    
FUNCTION Start2() AS VOID
    LOCAL f AS FLOAT
    f := seconds()
    USE "c:\XSharp\DevRt\Runtime\XSharp.Rdd.Tests\dbfs\TEST10K.DBF"
    DbCreateIndex("10kName.xxx", "upper(Last+First)")
    DbCreateIndex("10kState", "State")
    DbCreateIndex("10kDate", "Hiredate")
    DbCreateIndex("10kSalary", "Salary")
    DbCloseArea()
    ? Seconds() - f
    WAIT
    RETURN
    
    
FUNCTION Start3() AS VOID
    LOCAL cFileName AS STRING
    cFileName := "C:\Test\teest.dbf"
    ? DBCreate(cFileName, {{"FLD1","C",10,0}})
    
    ? DBUseArea ( TRUE , , cFileName , "a1")
    ? DBGetSelect() // 1
    ? DBCloseArea()
    
    ? DBUseArea ( TRUE , , cFileName , "a2")
    ? DBGetSelect() // 2
    ? DBCloseArea()
    
    ? DBUseArea ( TRUE , , cFileName , "a3")
    ? DBGetSelect() // 3
    ? DBCloseArea()
    RETURN
    
    
    
FUNCTION Start4() AS VOID
    LOCAL cFileName AS STRING
    cFileName := "C:\test\laaarge"
    ? DBCreate(cFileName, {{"FLD1","C",10,0},{"FLD2","N",10,0}})
    ? DBUseArea( , , cFileName , , FALSE)
    FOR LOCAL n := 1 AS INT UPTO 10
        DBAppend()
        FieldPut(1, n:ToString())
        FieldPut(2, n)
    NEXT
    ? DBCreateIndex(cFileName + ".ntx" , "FLD2")
    ? DBCloseArea()
    ? "created"
    ? DBUseArea( , , cFileName , , FALSE)
    ? DBSetIndex(cFileName + ".ntx")
    ? DBGoTop()
    ? "skipping"
    DO WHILE ! EOF()
        ? FieldGet(2) , RecNo()
        ? EOF()
        DBSkip()
    END DO
    ? DBCloseArea()
    RETURN
    
    
FUNCTION Start5() AS VOID
    LOCAL cDbf AS STRING
    LOCAL cNtx AS STRING
    
    cDbf := "C:\test\testdbf"
    cNtx := cDbf + ".ntx"
    
    ? DBCreate( cDbf , {{"CFIELD" , "C" , 10 , 0 }})
    ? DBUseArea(,,cDbf)
    ? DBAppend()
    FieldPut ( 1 , "ABC")
    ? DBAppend()
    FieldPut ( 1 , "GHI")
    ? DBAppend()
    FieldPut ( 1 , "DEF")
    ? DBAppend()
    FieldPut ( 1 , "K")
    ? DBCloseArea()
    
    ? DBUseArea(,,cDbf)
    ? DBCreateIndex(cNtx , "CFIELD")
    ? DBCloseArea()
    
    ? DBUseArea(,,cDbf,,FALSE) // check also with TRUE
    ? DBSetIndex(cNtx)
    ShowRecords()
    // should be ABC, DEF, GHI, K
    
    DBGoTop()
    ? FieldGet(1)
    DBSkip()
    ? FieldGet(1)
    FieldPut(1,"HHH")
    DbCommit()
    ShowRecords()
    // should be ABC, GHI, HHH, K
    
    ? DBCloseArea()
    
FUNCTION ShowRecords() AS VOID
    DBGoTop()
    ? "========="
    ? " Records:"
    DO WHILE .NOT. Eof()
        ? FieldGet(1)
        ? DBSkip() // exception here
    END DO
    RETURN
    
    
FUNCTION Start6() AS VOID
    LOCAL cDbf AS STRING
    cDbf := "c:\test\testdbf"
    
    ? DBCreate( cDbf , {{"CFIELD" , "C" , 10 , 0 },;
    {"DFIELD" , "D" , 8 , 0 }})
    ? DBUseArea(,,cDbf)
    ? DBAppend()
    FieldPut ( 1 , "B")
    ? DBAppend()
    FieldPut ( 1 , "A")
    ? DBCloseArea()
    
    ? DBUseArea(,,cDbf)
    LOCAL u AS USUAL
    u := FieldGet(2) // it should be a NULL_DATE
    ? u
    ? u == NULL_DATE
    FieldPut(2,u) // exception
    FieldPut(2,NULL_DATE) // exception
    ? DBCloseArea()
    
FUNCTION Start7() AS VOID
    LOCAL cDbf AS STRING
    LOCAL cNtx AS STRING
    cDbf := "C:\Test\testdbf"
    cNtx := cDbf + ".ntx"
    
    ? DBCreate( cDbf , {{"CFIELD" , "C" , 10 , 0 }})
    ? DBUseArea(,,cDbf,,FALSE)
    ? DBAppend()
    FieldPut ( 1 , "B")
    ? DBAppend()
    FieldPut ( 1 , "A")
    ? DBCloseArea()
    
    ? DBUseArea(,,cDbf,,TRUE) // ----- opening in SHARED mode
    ? DBCreateIndex(cNtx , "CFIELD") // returns TRUE
    ? DBCloseArea()
    
    ? DBUseArea(,,cDbf,,FALSE)
    ? DBSetIndex(cNtx)
    ? DBCloseArea() // XSharp.RDD.RddError here
    
    
FUNCTION Start8() AS VOID
    LOCAL cDbf AS STRING
    cDbf := System.Environment.CurrentDirectory + "\testdbf"
    ? DBCreate( cDbf , {{"CFIELD" , "C" , 10 , 0 }})
    ? DBUseArea(,,cDbf,,TRUE)
    ? DBAppend()
    ? DBRLock ()
    FieldPut ( 1 , "A")
    //? DBCommit() // makes no difference
    //? DBUnlock() // makes no difference
    ? DBCloseArea() // exception here
    
    
    
FUNCTION Start9() AS VOID
    LOCAL cFileName AS STRING
    LOCAL f AS FLOAT
    LOCAL n AS INT
    f := Seconds()
    ? "Generating dbf and index"
    cFileName := "C:\test\laaarge"
    ? DBCREATE(cFileName, {{"FLD1","C",10,0},{"FLD2","N",10,0}})
    ? "created file , time elapsed:",Seconds() - f 
    ? DBUSEAREA( , , cFileName , , FALSE)
    FOR n := 1 UPTO 100000
        DBAPPEND()
        FIELDPUT(1, AsString(n))
        FIELDPUT(2, 50000-n)
    NEXT
    ? "created records , time elapsed:",Seconds() - f 
    f := Seconds()
    ? DBCREATEINDEX(cFileName + ".ntx" , "FLD1")
    ? DBCLOSEAREA()
    ? "created index, time elapsed:",Seconds() - f 
    ? DBUSEAREA( , , cFileName , , FALSE)
    ? DbSetIndex(cFileName + ".ntx")
    ? DbGotop()
    ? 
    ? "started skipping with index:"
    f := Seconds()
    FOR  n := 1 UPTO 100000 - 1
        DBSKIP()
    NEXT
    ? "skipped, time elapsed:",Seconds() - f
    ? DBCLOSEAREA()
    WAIT
    RETURN 
    
    
FUNCTION Start10() AS VOID
    ? DBAppend()
    RETURN
    
    
FUNCTION Start11() AS VOID
    LOCAL a AS ARRAY
    LOCAL i AS DWORD
    
    setexclusive ( FALSE )
    
    
    IF dbcreate ( "test" , { {"id", "C", 5, 0} })
    
        IF dbuseArea ( , , "test" )
        
            dbappend()
            dbappend()
            dbAppend()
            
            dbGotop()
            
            ?
            ? "Record: " + ntrim ( Recno() )
            ? dbrlock ( Recno() )
            ? dbRecordInfo ( DBRI_LOCKED ) , "Should show TRUE"
            ? IsRlocked()
            ?
            
            dbSkip()
            // record 2 - no lock
            ? "Record: " + ntrim ( Recno() )
            ? dbRecordInfo ( DBRI_LOCKED )
            ? IsRlocked()
            ?
            
            dbskip()
            ? "Record: " + ntrim ( Recno() )
            ? dbrlock ( Recno() )
            ? dbRecordInfo ( DBRI_LOCKED ) , "Should show TRUE"
            ? IsRlocked()
            ?
            
            ? "length of Locklist-Array: " , alen ( a:= DBRlocklist() ) , "(must be 2)"
            ? "Locked records:" , "must show 1 and 3"
            FOR i := 1 UPTO alen ( a )
                ? a [i]
                
            NEXT
            
            
            dbclosearea()
            
        ENDIF
    ENDIF
    
    
    RETURN
    
FUNCTION IsRlocked() AS LOGIC // Helper func

    RETURN ascan ( DBRlocklist() , recno() ) > 0

