﻿//
// Start.prg
//

//#include "dbcmds.vh"
USING XSharp.RDD
USING System.IO
USING System.Threading
USING System.Reflection
USING System.Collections.Generic

[STAThread];      
FUNCTION Start() AS VOID
    TRY
         //FoxTags()
         //SeekSkipAndFoundFlag()
         OrdDescAndOrdScope()
         //OrdScopeBof()
         //OrderKeyCountAndSkipBack()
        //DumpWg1()
        //testUse()
        //testWg1()
        //TestCorruptCdx()
        //ReadVfpTableWithInfo()
        //ReadDbcProperties()
        //OrdDescTest2()
            //        VAR x := MemAlloc(80000)
            //        ? PtrLen(x)
            //        ? PtrLenWrite(x)
        //DeleteAllOrders()
        //TestZapJune()
        //TestChrisCorrupt()
        //TestChrisCorrupt2()
        //DumpKeesFiles()
        //TestIndexKey()
        //TestDateTimeAndCurrency()
        // testAppDelim()
        //testDelimWrite()
        //testUnique3()
        //BofAndScope()
        //testPruntGrup()
        //TestMsg05()
        // TestWriteError()
        //TestCdxCreate()
        //DbCloseAll()
        //testAdsAppendDb()
        //TestCreateRepeat()
        //TestUniquex()
        //AndreaLikesThis()
        //TestbBrowserImage()
        //UniDbf()
        //NorthWind()
        //CorruptDbf()
        //CorruptDbf2()        
        //AdsConnect60("abc",1,"","",0, OUT hConn)
        //testChrisOrdinal()
        //testLndRel()
        //TestCollationChris()
        //TestIndexCreate()
        //TestWord() 
        //CountAndSpeedTest()
        //TestSalary()
        //TestThreading()
        //TestCommitWolf()
        //TestNeg2()
        //TestNegative()
        //TestFpt()
        //TestWolfgang3()
        //testCecil()
        //TestWolfgang2()
        //TestEncoding()
        //TestXppFieldGetFieldPut()
        //DumpRateCdx()
        //TestRateCdx()
        //TestProj()
        //TestCorrupt2()
        //testCdxLock()
        //TestXppCollations()
        //TestNestedMacro()
//        testCreate()
//        testOverloads()
        //testScopes() 
        //testCorrupt3()
        //testtcc()
        //TestCorrupt2()
        //TestCorrupt1()
        //TestRel()
        //TestVfpClass()
        //TestNotifications()
        //testFilter()
        //testDbfNtxEmpty()
        //testvfpFile()
        //testAliasWhileCreate()
        //testadsmemo()
        //TestAdvantageSeek()
        //TestTimeStamp()
        //TestSeek()    
        //testDbfEncoding()
        //testDateInc()
        //TestEmptyDbf()
        //TestAnotherOrdScope()
        //TestFileGarbage()
        //TestPackNtx()  
        //TestZapNtx()
        //TestNullDate()
        //TestZap3()
        //SetNatDLL("TURKISH")    
        //TestZap2()
        //TestPack2()
        //DbSeekTest()
        //testAOtter()
        //Ticket127()
        //TestHexString()
        //FrankM()
        //Ticket118a()
        //Ticket118()
        //Ticket120()   
        //Ticket103a()
        //Ticket103()
        //Ticket119()
        //Ticket119a()
        //Ticket115Orig()
        //Ticket115()
        //TestDosErrors()
        //TestDBFTouch()
        //TestMemoAtEof()
        //TestAsHexString()
        //ContructorException()
        //testSetDefault()
        //FptLock()
        //DescOrderScope()
        //DirTest()
        //TestAutoIncrement()
        //TestOrdScope()
        //TestOrderCondition()
        //testOpenDbServer()
        //testseeknotfound()
        //testscope()
        //TestUniqueCdx()
        //TestGrowFpt()
        //TestNil()
        //OrdDescFreeze()
        //TestFreezeFilterDesc()
        // testGoTopGoTopCdx()
        //testFptCreate()
        //DescartesDbfTest()
        //FptMemoTest()
        //TestDbfFromChris()
        //TestIndexUpdates()
        //testVFPFiles()
        //testOrdNameInvalid()
        //aevalNil()
        //testFptMemo()
        //testUpdateCdx()
        //testOverFlow()
        //testIndexNoExtension()
        //testRelation()
        //testCustomIndex()
        //testOrdDescend()
        //testScopeDescend()
        //testScope()
        //TestRebuild()
        //Test__Str()
        //testOptValue()
        //testReal8Abs()
        //testIvarGet()
        //testUnlock()
        //testDelete()
        //testUnique2()
        //testCrypt()
        //TestLb()
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
    WAIT
   CATCH e AS Exception  
        IF ! (e IS Error) 
            e := Error{e}
        ENDIF
        ErrorDialog(e)
    END TRY
    RETURN

GLOBAL CONST gnIterations := 50_000 AS INT

USING System.Windows.Forms
USING System.Threading

GLOBAL gcPath := "c:\test\"


FUNCTION FoxTags( ) AS VOID 
LOCAL cPath, cDBF, cCDX AS STRING 

    ? RddSetDefault() // "DBFVFP"
    ?
    
	cPath = "d:\test\"
	
	cDBF = "small.dbf" 
	cCDX = "small1x.cdx" 
	
	
	DbUseArea ( TRUE, , cPath + cDBF )  // auto opens small.cdx  
	
	DbSetIndex ( cPath + cCDX )  // open small1x.cdx
	  
	DbSetOrder ( 5 )
	
	? "Total No. of Tags" , DbOrderInfo(DBOI_ORDERCOUNT )  // 6    ok 
	?  
	? "No. of SMALL Tags" ,  DbOrderInfo(DBOI_ORDERCOUNT , "SMALL" ) , "must show 3" // 6 instead of 3  , VO shows correctly 3
	? "TagCount() SMALL" , TagCount ( "SMALL" ) , "must show 3" // 6   instead of 3
	? 
	? "No. of SMALL1X Tags" , DbOrderInfo(DBOI_ORDERCOUNT , "SMALL1X" ) , "must show 3" // 6 instead of 3  , VO shows correctly 3
	? "TagCount() SMALL1X" , TagCount ( "SMALL1X" ) , "must show 3" // 6   instead of 3 
	? 
	?
    ? Cdx(1)
	? Cdx(2)
	FOR VAR i = 1 TO TagCount() 
		 ? Cdx (i) , TAG_FIX( i ) , TagNo ( Tag ( , i) ,Cdx(i) )  
	NEXT
    ? 
    
    // note: above, the active order was set to 5 . That´s "ORDER2" of the small1x.cdx  
    
	? "O" , Order("small",1)	// ok, "d:\test\small1x.cdx"
	? "O" , Order("small" )		// wrong  "d:\test\small1x.cdx"
	? "O" , Order( 1 )			// wrong  "d:\test\small1x.cdx"                                       
	? "O" , Order ()			// wrong  "d:\test\small1x.cdx"
	?	
	? "F" , Order_Fix("small",1)	// ok, "d:\test\small1x.cdx"
	? "F" , Order_Fix("small" )		// ok, "ORDER2" 
	? "F" , Order_Fix( 1 ) 			// ok, "ORDER2"                                        
	? "F" , Order_Fix ()    		// ok, "ORDER2" 
	? 
	
    DbSetOrder(0)
    
	// ok, shows empty strings only
	
	? "O" , Order("small",1) 
	? "O" , Order("small" ) 
	? "O" , Order( 1 )                                        
	? "O" , Order ()
	?
	? "F" , Order_Fix("small",1) 
	? "F" , Order_Fix("small" ) 
	? "F" , Order_Fix( 1 )                                        
	? "F" , Order_Fix ()    	   
    
    DbCloseArea()
      
RETURN

FUNCTION TAG_FIX ( CDXFileName, nTagNumber, uArea ) AS STRING CLIPPER
    
	// a param check is needed, something like ...
	
	IF PCount() = 1 
		IF IsNumeric ( CDXFileName )  
			nTagNumber = CdxFileName
			CdxFileName = NIL 			
		ENDIF 
	ENDIF 
			
	RETURN Tag ( CDXFileName , nTagNumber , uArea ) 
	
FUNCTION Order_Fix ( uArea, nPath) AS STRING 
	
	IF PCount() == 0 
		RETURN DbOrderInfo(DBOI_NAME, , 0) // Tag ( , 0) 
		
	ELSEIF PCount() == 1 
		RETURN (uArea)->DbOrderInfo(DBOI_NAME, , 0)  //nTag ( , 0) 
		
	ELSEIF PCount() == 2 
		IF IsNumeric ( nPath ) 
		   RETURN (uArea)-> DbOrderInfo(DBOI_BAGNAME) 
		ENDIF 
		
	ENDIF 
	
	RETURN ""	

FUNCTION SeekSkipAndFoundFlag() AS VOID 
LOCAL cDBF, cPfad, cIndex   AS STRING 
LOCAL aFields, aValues AS ARRAY 
LOCAL i  AS DWORD  


	RddSetDefault ( "DBFCDX" ) 
    

	cPfad := "D:\test\" 
 
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	FErase ( cIndex + IndexExt() )
		
	aFields := { { "LAST" , "C" , 20 , 0 } 	} 
	
	aValues := { "g6" , "o2", "g2" , "g1" , "g3" , "g5" , "B1" , "b2" , "p", "q" , "r" , "s" }	
	
	// ------------
	
	DbCreate( cDBF , AFields)
	DbUseArea( ,,cDBF )		

	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] )
	NEXT
	
	DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	DbCloseArea()
	
	// --------------
	
	DbUseArea( ,,cDBF )
	DbSetIndex ( cIndex )
	DbSetOrder ( 1 )
	
	
   
	DbSeek ( "G" ) 
	? "Skip to eof" 
	? "-----------"
	
	DO WHILE ! Eof()            
			
	  	? FieldGet ( 1 ) , "Found: " , Found() 
    	
  		DbSkip ( 1 ) 
  		
 		
	ENDDO 
	
	?
	
	DbSeek ( "G" )
	
	? "Skip to bof" 
	? "-----------"
		 
	
	DO WHILE ! Bof()            

	  	? FieldGet ( 1 ) , "Found: " , Found() 
    	
  		DbSkip ( -1 ) 
        
	ENDDO 
	
	?
	
	DbGoTop() 
	? "Go Top Found" , Found() 
	
	DbGoBottom() 
	? "Go bottom Found" , Found() 

		
    
	DbCloseArea() 
	
	RETURN 	

FUNCTION OrdDescAndOrdScope() AS VOID 
LOCAL cDBF, cPfad, cIndex   AS STRING 
LOCAL aFields, aValues AS ARRAY 
LOCAL i AS DWORD  
SetDeleted(FALSE)

    RddSetDefault ( "DBFCDX" ) 
    
    cPfad := "D:\test\" 
 
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	FErase ( cIndex + IndexExt() )
		
	aFields := { { "LAST" , "C" , 20 , 0 } 	} 
	
	aValues := { "g6" , "o2", "g2" , "g1" , "g3" , "g5" , "B1" , "b2" , "p", "q" , "r" , "s" }	
	
	// ------------
	
	DbCreate( cDBF , AFields)
	DbUseArea( ,,cDBF )		

	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] )
	NEXT
	
	DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	DbCloseArea()
	
	// --------------
	
	DbUseArea( ,,cDBF )
	DbSetIndex ( cIndex )
	DbSetOrder ( 1 ) 
	
	OrdDescend ( , , TRUE )  // switch to descend view

	OrdScope(TOPSCOPE, "B")     // Note: must be "R" !
	OrdScope(BOTTOMSCOPE, "R")  // Note: must be "B" !
	
	? "OrdKeyCount()" , OrdKeyCount()
	?     
	
	// -------------	
	
	DbGoTop()            
	? Bof() , Eof()  // both return .f. !


    DO WHILE ! Eof()
    	? FieldGet ( 1 ) 
    	DbSkip ( 1 )
    	
    ENDDO 	
           
   
    DbGoTop()       
    ? Bof() , Eof() // both return .f. !
    
    DbGoBottom()       
    ? Bof() , Eof() // both return .f. !


	DbCloseArea() 
	
	RETURN 	
FUNCTION OrdScopeBof() AS VOID 
LOCAL cDBF, cPfad, cIndex   AS STRING 
LOCAL aFields, aValues AS ARRAY 
LOCAL i AS DWORD  

    RddSetDefault ( "DBFCDX" ) 
    
    cPfad := "D:\test\" 
 
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	FErase ( cIndex + IndexExt() )
		
	aFields := { { "LAST" , "C" , 20 , 0 } 	} 
	
	aValues := { "g6" , "o2", "g2" , "g1" , "g3" , "g5" , "B1" , "b2" , "p", "q" , "r" , "s" }	
	
	// ------------
	
	DbCreate( cDBF , AFields)
	DbUseArea( ,,cDBF )		

	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] )
	NEXT
	
	DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	DbCloseArea()
	
	// --------------
	
	DbUseArea( ,,cDBF )
	DbSetIndex ( cIndex )
	DbSetOrder ( 1 ) 

	OrdScope(TOPSCOPE, "X")     // "A"
	OrdScope(BOTTOMSCOPE, "X")  // "A"
	
	? "OrdKeyCount()" , OrdKeyCount()
	?     
	
	// -------------	
	
	DbGoTop()            
	? Bof() , Eof() // .f. and .t.


    DO WHILE ! Eof()
    	? FieldGet ( 1 ) 
    	DbSkip ( 1 )
    	
    ENDDO 	
           
   
    DbGoTop()       
    ? Bof() , Eof()   // .f. and .t.
    
    DbGoBottom()       
    ? Bof() , Eof()   // .f. and .t.  
        
	DbCloseArea() 
	
	RETURN 		

FUNCTION OrderKeyCountAndSkipBack() AS VOID
LOCAL cDBF, cPfad, cIndex   AS STRING 
LOCAL aFields, aValues AS ARRAY 
LOCAL i  AS DWORD  


	RddSetDefault ( "DBFCDX" ) 
    

	cPfad := "D:\test\" 
 
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	FErase ( cIndex + IndexExt() )
		
	aFields := { { "LAST" , "C" , 20 , 0 } 	} 
	
	aValues := { "g6" , "o2", "g2" , "g1" , "g3" , "g5" , "B1" , "b2" , "p", "q" , "r" , "s" }	
	
	// ------------
	
	DbCreate( cDBF , AFields)
	DbUseArea( ,,cDBF )		

	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] )
	NEXT
	
	DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	DbCloseArea()
	
	// --------------
	
	DbUseArea( ,,cDBF )
	DbSetIndex ( cIndex )
	DbSetOrder ( 1 )
	
	
   
	DbSeek ( "G" ) 
	? "Skip to eof" 
	? "-----------"
	
	DO WHILE ! Eof()            
			
	  	? FieldGet ( 1 ) 
    	
  		DbSkip ( 1 ) 
  		
 		DbOrderInfo ( DBOI_POSITION )
 		DbOrderInfo ( DBOI_KEYCOUNT )
 		
	ENDDO 
	
	?
	
	DbSeek ( "G" )
	
	? "Skip to bof" 
	? "-----------"
		 

	DO WHILE ! Bof()            

	  	? FieldGet ( 1 ) 
    	
  		DbSkip ( -1 )
  		
  		? "Bof() before DBOI_KEYCOUNT" , Bof() 
// 		DbOrderInfo ( DBOI_POSITION )
 		DbOrderInfo ( DBOI_KEYCOUNT )
  		? "Bof() after DBOI_KEYCOUNT" , Bof()
        WAIT   		 
        
	ENDDO 
    
	DbCloseArea() 
	
	RETURN 		

FUNCTION testUse() AS INT
LOCAL cFilename AS STRING

cFilename:="c:\temp\test.dbf"

DbCreate(cFilename , {{"FLD","C",10,0}})

? VoDbUseArea(TRUE, "DBFCDX", cFileName , "c1", FALSE,FALSE)
? VoDbUseArea(TRUE, "DBFCDX", cFileName , "c2", FALSE,FALSE) // no error
DbCloseAll()

? DbUseArea(TRUE,"DBFCDX",cFileName+"X","c3",TRUE)
? DbUseArea(TRUE,"DBFCDX",cFileName,"c4",FALSE) // exception

WAIT
RETURN 0


FUNCTION DumpWg1() AS VOID
	LOCAL cPath			AS STRING
	cPath			:= "C:\test\Wolfgang"                                 
    RuntimeState.SetValue(Set.FoxLock, FALSE)
	? DbUseArea(TRUE, "DBFCDX" , cPath, ,FALSE,FALSE)
    DbSetOrder(1)
    DbOrderInfo(DBOI_USER+42)
    DbCloseArea()
    RETURN


FUNCTION testWg1() AS VOID
	LOCAL cPath			AS STRING
	LOCAL nI			AS DWORD
	LOCAL nLen			AS DWORD
	LOCAL aValues		AS ARRAY
	LOCAL aStruct AS ARRAY
	LOCAL n := 0 AS INT
    RuntimeState.SetValue(Set.FoxLock, FALSE)
    


	cPath			:= "C:\test\Wolfgang"                                 
	FErase(cPath + ".dbf")                                                                      
	FErase(cPath + ".cdx")
	
	aStruct := {{"AUFNR","N",10,0},{"JAHR","C",4,0},{"POSFORO","N",4,0},{"POSGRUP","N",4,0},{"POSNR","N",4,0}}
	                                                                                         
	? DbCreate(cPath , aStruct , "DBFCDX")
                                                                    
	? DbUseArea(TRUE, "DBFCDX" , cPath, ,FALSE,FALSE)
	? DbCreateIndex(cPath , "JAHR+STR(AUFNR,10)+STR(POSFORO,4)+STR(POSGRUP,4)+STR(POSNR,4)")
	? DbCloseArea()
	
	? DbUseArea(TRUE, "DBFCDX" , cPath, ,TRUE,FALSE)
	DbGoBottom()
	nLen				:= FCount()
	aValues				:= ArrayNew( nLen )                                     
	WHILE TRUE
		TRY
			FOR nI := 1 UPTO nLen
				aValues[nI]			:= FieldGet( nI )
			NEXT
			DbAppend( TRUE )                                                                              
			n ++
			FOR nI := 1 UPTO nLen
				FieldPut( nI, aValues[nI] )
			NEXT           
			FieldPut( 5, FieldGet( 5 ) + 1 )
			IF FieldGet( 5 ) > 900
				FieldPut( 5, 1 )
				FieldPut( 1, FieldGet( 1 ) + 1 )
			ENDIF
			DbCommit()
			DbUnLock()
		CATCH e AS Exception
			? e:ToString()      
			Console.ReadLine()
		END TRY
		? n
	END





FUNCTION testCorruptCdx() AS VOID

? DbUseArea(TRUE,"DBFCDX","c:\download\aufpos\AUFPOS.DBF",,FALSE)
FOR VAR i := 1 TO 10
    DbSetOrder(i)
    ? DbOrderInfo(DBOI_DUMP)
NEXT
DbCloseArea()


FUNCTION OrdDescTest2() AS VOID 
LOCAL cDBF, cPfad, cIndex   AS STRING 
LOCAL aFields, aValues AS ARRAY 
LOCAL i AS DWORD


	RddSetDefault ( "DBFCDX" )
   
   
    cPfad := "D:\test\" 
 
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	? FErase ( cIndex + IndexExt() )	

	//  ------------------
	    
	aFields := { { "LAST" , "C" , 20 , 0 } } 
	
	aValues := { "g6" , "o2", "g2" , "g1" , "g3" , "g5" , "A1" , "a2"  }	
	
	
	? DbCreate( cDBF , AFields)

	? DbUseArea( ,,cDBF)
	
	FOR i := 1 UPTO ALen ( aValues )
		
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] )
		
	NEXT			

	? DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _Field->LAST) } )
	? DbSetOrder ( 1 ) 
	?	 
	
	// Set the scope to "G" or "X" 
	OrdScope(BOTTOMSCOPE, "G")   
	OrdScope(TOPSCOPE, "G")      

	// ------------

/*			
	DbGoTop() 
	? "Ascending" , "OrdKeyCount()" , OrdKeyCount() 
	?
	DO WHILE !Eof() 
		? "*Do while" , FieldGet ( 1 ) , Eof() 
		DbSkip ( 1 )
	ENDDO 	
	
    ?
   	DbGoTop()
   	FOR i := 1 UPTO 8 
		? "*" , FieldGet ( 1 ) , Eof()
		DbSkip ( 1 )
   	NEXT	
*/ 		
	// ----------------		
	OrdDescend ( , , TRUE )
	// ----------------		 		
	?
		
	DbGoTop() 
	? "Descending" , "OrdKeyCount()" , OrdKeyCount() 
    ?
	
	DO WHILE !Eof() 
		? "*Do while" , Recno(), FieldGet ( 1 ) , Eof() 
		DbSkip ( 1 )
	ENDDO  	
    ? "EOF after the loop", Eof()
	?	
	? "--- skip(1) only results ---"  
    ?
    FOR i := 1 UPTO 30
		? "*" , Recno(), FieldGet ( 1 ) , Eof() 
		DbSkip ( 1 )
    NEXT
    ? "etc."	
		
	DbCloseArea() 
		
	RETURN		

Function ReadVfpTableWithInfo() as VOID
    RddSetDefault("DBFVFP")
    var tables := <String>{"employees","customers","orders","products","categories","region","orderdetails","employeeterritories","shippers"}
    var path := "c:\XSharp\DevRt\Runtime\XSharp.VFP\TestData\"
    FOREACH var table in tables
        ? "Table", table        
        DbUseArea(TRUE, "DBFVFP", path+table)
        FOR var I := 1 to FCount()
            ? "Column ", i, DbFieldInfo(DBS_NAME, i), DbFieldInfo(DBS_ALIAS, i),  DbFieldInfo(DBS_CAPTION, i), DbFieldInfo(DBS_DESCRIPTION, i)
        NEXT
        DbCloseArea()
    NEXT



function FoxToLong(b as byte[], pos as int) as LONG
    local result as long
    result := b[pos+3]
    result := result << 8
    result += b[pos+2]
    result := result << 8
    result += b[pos+1]
    result := result << 8
    return result + b[pos]

function FoxValue(b as byte[], pos as int) as LONG
    local result as long
    result := b[pos]
    result := result << 8
    result += b[pos+1]
    result := result << 8
    result += b[pos+2]
    result := result << 8
    return result + b[pos+3]

function FoxToShort(b as byte[], pos as int) as Short
    local result as long
    result := b[pos+1]
    result := result << 8
    result += b[pos]
    return result

#pragma options ("az", default)
FUNCTION TestChrisCorrupt2() AS VOID
	//DbfTest1.RunTest1()
	//DbfTest1.RunTest2()
	//DbfTest1.RunTest3()
	//DbfTest1.RunTest4()
	DbfTest1.RunTest5()
	//DbfTest1.RunTest6()
RETURN


FUNCTION DeleteAllOrders() AS VOID	
LOCAL cDBF, cPfad, cIndex AS STRING 
LOCAL aFields AS ARRAY 

//    SetExclusive ( TRUE )  //  or FALSE makes no difference

    RddSetDefault ( "DBFCDX" ) 
    
    cPfad := "D:\TEST\" 

	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	FErase ( cIndex + IndexExt() )
	

	aFields := { { "LAST" , "C" , 20 , 0 } ,;
				{ "CITY" , "C" , 20 , 0 }	 } 

		
    // -------------------
	
	? DbCreate( cDBF , AFields)
	? DbUseArea( ,,cDBF )		
	
		
	? DbCreateOrder ( "ORDER1"  , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	? DbCreateOrder ( "ORDER2"  , cIndex , "upper(CITY)" , { || Upper ( _FIELD->CITY) } )	
		
    
	DbCloseArea()
	
    ?
	? DbUseArea( ,,cDBF )	
	? DbSetIndex ( cIndex ) 
	
	? 
	? DbOrderInfo(DBOI_ORDERCOUNT)  // 2
	? DbDeleteOrder( "ORDER1" )	 
	? DbOrderInfo(DBOI_ORDERCOUNT)	// 1
	? DbDeleteOrder( "ORDER2" )	 
	? DbOrderInfo(DBOI_ORDERCOUNT)	// 0
	

	DbCloseArea()		
	
	?
	? "Does the file " + cIndex + IndexExt() + " still exist ? " , File ( cIndex + IndexExt() ) 
		
	RETURN	 

FUNCTION TestZapJune() AS VOID
LOCAL cDBF, cPfad, cDriver, cIndex AS STRING 
LOCAL aFields, aValues AS ARRAY
LOCAL i, dwWhich AS DWORD 	
LOCAL lDeleted AS LOGIC
		
		
   cDriver := RddSetDefault ( "DBFCDX" ) 
   lDeleted := SetDeleted ( FALSE )  // <---------NOTE ------------  
   
//   dwWhich := 1 // dbPack()   
//   dwWhich := 2 // dbZap()
   dwWhich := 3 // dbReindex()     
   
	cPfad := "D:\TEST\"	

	cDBF := cPfad + "Foo.dbf"
	cIndex := cPfad + "Foox.cdx"  
	
   	FErase ( cIndex ) 
		 
	aFields := { { "LAST" , "C" , 20 , 0 } } 

	aValues := { "a1" , "o5" , "g2", "g1" , "g8" , "g6"}	
		
    ? "-------------------"
	? "Create server + cdx"
	? "-------------------"
	? DbCreate( cDBF , AFields) 
	? DbUseArea( ,,cDBF , , FALSE )	// open shared 	
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] ) 
		
		IF InList ( Upper ( aValues [i] ) , "O5" ) 
			? "DBDelete()" , DbDelete()
			
		ENDIF 	
						
	NEXT 
	
 	? "Createorder" , DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
 	// create a conditional, descending order
	DbSetOrderCondition( "Upper(LAST) = 'G'" ,{ || Upper ( _FIELD->LAST) = "G" },,,,,,,,, TRUE) 
	? "Createorder" , DbCreateOrder ( "ORDER2" , cIndex , "upper(LAST)", { || Upper ( _FIELD->LAST) } )

	DbCloseArea()
	
	? DbUseArea( ,,cDBF , , FALSE )	
    ? DbSetIndex( cIndex )

    ?
	DbSetOrder ( 1 )  
	? DbOrderInfo(DBOI_NAME), "OrdCount:" , DbOrderInfo(DBOI_KEYCOUNT)  
	DbSetOrder ( 2 )  
	? DbOrderInfo(DBOI_NAME), "OrdCount:" , DbOrderInfo(DBOI_KEYCOUNT)                 
    ?	
    
    DbSetOrder ( 2 )  // <--------- NOTE ---------- 

    ? "--------------"
    ? "Reccount()", RecCount() 
  	DO CASE 
  	CASE dwWhich == 1
  		? "DBPack()" , DbPack()
  	CASE dwWhich == 2
		? "DBZap()" , DbZap()
  	CASE dwWhich == 3
		? "DbReindex()" , DbReindex()  
  	ENDCASE 		
	? "Reccount()", RecCount()
	? "--------------"    
    ?
	DbSetOrder ( 1 )  
	? DbOrderInfo(DBOI_NAME), "OrdCount:" , DbOrderInfo(DBOI_KEYCOUNT)  
	DbSetOrder ( 2 )  
	? DbOrderInfo(DBOI_NAME), "OrdCount:" , DbOrderInfo(DBOI_KEYCOUNT)  
    ?
	? "------------------------------"    
  	? "Close and open dbf + cdx again"
  	? "------------------------------"
    DbCloseArea() 
	DbUseArea( ,,cDBF , , TRUE )	 	
	DbSetIndex ( cIndex ) 
	
	DbSetOrder ( 1 )  
	? DbOrderInfo(DBOI_NAME), "OrdCount:" , DbOrderInfo(DBOI_KEYCOUNT)  
	DbSetOrder ( 2 ) 
	? DbOrderInfo(DBOI_NAME), "OrdCount:" , DbOrderInfo(DBOI_KEYCOUNT)  
	
    DbCloseArea() 
    
	cDriver := RddSetDefault ( cDriver ) 
	SetDeleted ( lDeleted )    
    
	RETURN	

CLASS DbfTest1
	STATIC PROTECT nIterations AS DWORD
	STATIC PROTECT lUseCommit AS LOGIC
	STATIC PROTECT cDbf AS STRING
	STATIC PROTECT nKeyLength AS DWORD
    STATIC PROTECT lShared AS LOGIC
	
	STATIC METHOD RunTest1() AS VOID
		? "Running test1"
		cDbf := gcPath + __FUNCTION__
		TRY
			nKeyLength := 20
            lShared := FALSE
			ResetFile()
			nIterations := 100_000
			lUseCommit := FALSE
			Test()
			CheckResults()
		CATCH e AS Exception
			MessageBox.Show(e:ToString(), "Error running test 1")
		END TRY
	RETURN

	STATIC METHOD RunTest2() AS VOID
		? "Running test2"
		cDbf := gcPath + __FUNCTION__
		TRY
			nKeyLength := 1
            lShared := FALSE
			ResetFile()
			nIterations := 300
			lUseCommit := TRUE
			Test()
			CheckResults()
		CATCH e AS Exception
			MessageBox.Show(e:ToString(), "Error running Test 2")
		END TRY
	RETURN

	STATIC METHOD RunTest3() AS VOID
		? "Running test3"
		cDbf := gcPath + __FUNCTION__
		TRY
			nKeyLength := 60
            lShared := FALSE
			ResetFile()
			nIterations := 10_000
			lUseCommit := TRUE
			Test()
			CheckResults()
		CATCH e AS Exception
			MessageBox.Show(e:ToString(), "Error running Test 3")
		END TRY
	RETURN

	STATIC METHOD RunTest4() AS VOID
		? "Running test4"
		cDbf := gcPath + __FUNCTION__
		TRY
			nKeyLength := 60
            lShared := FALSE
			ResetFile()
			nIterations := 100_000
			lUseCommit := TRUE
			Test()
			CheckResults()
		CATCH e AS Exception
			MessageBox.Show(e:ToString(), "Error running Test 4")
		END TRY
	RETURN

	STATIC METHOD RunTest5() AS VOID
		? "Running test5"
		cDbf := gcPath + __FUNCTION__

		nIterations := 100
		lUseCommit := TRUE
		nKeyLength := 60
        lShared := TRUE
		TRY
			ResetFile()
			LOCAL aThreads AS Thread[]
			aThreads := Thread[]{10}
			FOR LOCAL n := 1 AS INT UPTO 10
				aThreads[n] := Thread{Test}
				Thread.Sleep(100)
				aThreads[n]:Start()
			NEXT
			LOCAL lWait AS LOGIC
			lWait := TRUE
			DO WHILE lWait
				Thread.Sleep(100)
				lWait := FALSE
				FOR LOCAL n := 1 AS INT UPTO 10
					lWait := lWait .OR. aThreads[n]:IsAlive
				NEXT
			END DO
			CheckResults()
		CATCH e AS Exception
			MessageBox.Show(e:ToString(), "Error running test 5")
		END TRY
	RETURN

	STATIC METHOD RunTest6() AS VOID
		? "Running test6"
		cDbf := gcPath + __FUNCTION__

		nIterations := 10_000
		lUseCommit := TRUE
		nKeyLength := 10
        lShared := TRUE
		TRY
			ResetFile()
			LOCAL aThreads AS Thread[]
			aThreads := Thread[]{10}
			FOR LOCAL n := 1 AS INT UPTO 10
				aThreads[n] := Thread{Test}
                aThreads[n]:Name := "Thread "+n:ToString()
				Thread.Sleep(100)
				aThreads[n]:Start()
			NEXT
			LOCAL lWait AS LOGIC
			lWait := TRUE
			DO WHILE lWait
				Thread.Sleep(100)
				lWait := FALSE
				FOR LOCAL n := 1 AS INT UPTO 10
					lWait := lWait .OR. aThreads[n]:IsAlive
				NEXT
			END DO
			CheckResults()
		CATCH e AS Exception
			MessageBox.Show(e:ToString(), "Error running test 6")
		END TRY
	RETURN

	STATIC METHOD ResetFile() AS VOID
		TRY
			FErase(cDbf + ".dbf")
			FErase(cDbf + ".cdx")
		END TRY
		DbCreate(cDbf, {{"FNUM" , "N" , 5 , 0},{"FSTR" , "C" , nKeyLength , 0}})
		DbUseArea(,"DBFCDX",cDbf,,FALSE)
		DbCreateIndex(cDbf, "FSTR + Str(FNUM,3,0)")
		DbAppend()
		FieldPut(1, 123)
		FieldPut(2, "ABC")
		DbAppend()
		FieldPut(1, 456)
		FieldPut(2, "DEF")
		DbCloseArea()
	RETURN

	STATIC METHOD Test() AS VOID
		LOCAL oRand AS Random
		
		oRand := Random{112233}
		DbUseArea(,"DBFCDX",cDbf,,lShared)
                    cDbf := DbInfo(DBI_FULLPATH)
        VAR cFile := cDbf:ToUpper():Replace(".DBF",".CDX_RUNTEST1.DMP")
        DbSetOrder(1)
		TRY
            ? ProcName(1), nIterations, "iterations"
		FOR LOCAL n := 1 AS DWORD UPTO nIterations
			IF n % 1000 == 0
				? n, System.Threading.Thread.CurrentThread.Name
            END IF
            LOCAL nGoto AS LONG
			IF n % 31 == 0
				DbAppend()
                nGoto := LastRec()
            ELSE
                nGoto := oRand:@@Next() % (INT)LastRec() + 1
				DbGoto(nGoto)
				IF .NOT. RLock()
					LOOP
				ENDIF
            END IF
            VAR num := oRand:@@Next() % 100
            VAR str := left(Replicate( Chr(n % 10 + 65) + Chr(n % 13 + 65) + Chr(n % 15 + 65) , nKeyLength ),nKeyLength)
			FieldPut(1, num)
			FieldPut(2, str)
            //? recno(), num, str
			IF lUseCommit
				DbCommit()
			END IF
			DbUnLock()
        NEXT
        CATCH e AS Exception
            ? e:ToString()
            Console.Read()
        END TRY
		DbCloseArea()
	RETURN

	STATIC METHOD CheckResults() AS VOID
		LOCAL cOld,cNew AS STRING
		LOCAL nTotalErrors := 0 AS INT
		LOCAL nRecords AS DWORD
		cOld := ""
		
		DbUseArea(,"DBFCDX",cDbf,,FALSE)
        OrdSetFocus(1)
        DbOrderInfo(DBOI_USER+42)
		nRecords := LastRec()
		DbGoTop()
		DO WHILE !Eof()
			cNew := FieldGet(2) + Str(FieldGet(1),3,0)
			IF cNew < cOld
				? "Error at recno", RecNo(), "next and previous values:", cNew,cOld
				nTotalErrors ++
			END IF
			cOld := cNew
			DbSkip()
		END DO
		
		DbCloseArea()
		
		? nTotalErrors, "errors, out of", nRecords, "records"
		
		IF nTotalErrors != 0
			THROW Exception{"There were errors found whe validating index"}
		END IF
	RETURN

END CLASS




FUNCTION TestChrisCorrupt() AS VOID
LOCAL cDbf AS STRING
LOCAL hFile AS PTR
LOCAL nInstance AS LONG            
TRY
nInstance := 0
hFile := F_ERROR                         
DO WHILE hFile == F_ERROR                                           
	nInstance++
	hFile := FCreate2("c:\test\test"+StrZero(nInstance,4,0)+".txt",FC_NORMAL)
ENDDO		
Console.Title := "testing instance "+nInstance:ToString()
cDbf := "c:\test\letstest"
IF nInstance == 1
	FErase(cDbf + ".dbf")            
	FErase(cDbf + ".cdx")
	DbCreate(cDbf, {{"FNUM" , "N" , 5 , 0},{"FSTR" , "C" , 20 , 0}})
	DbUseArea(,"DBFCDX",cDbf,,FALSE)
	DbCreateIndex(cDbf, "FSTR + Str(FNUM,3,0)")
	DbCloseArea()
ENDIF

DbUseArea(,"DBFCDX",cDbf,,TRUE)          
? "running"
IF LastRec() == 0        
	DbAppend()
	FieldPut(1, 123)
	FieldPut(2, "ABC")
	DbAppend()
	FieldPut(1, 456)
	FieldPut(2, "DEF")
	DbUnLock()
END IF

FOR LOCAL n := 1 AS INT UPTO gnIterations       
	IF (n % 100 == 0)
		? n
	ENDIF
	IF n % 7 == 0
		DbAppend()
		FWriteLine(hFile, i"Appending record {Recno()}")
	ELSE                                                                  
//		DbGoto(oRand:@@Next() % (INT)LastRec() + 1)
		DbGoto(n * 15 % (INT)LastRec() + 1)                              
		FWriteLine(hFile, i"Updating record {Recno()}")
		IF .NOT. RLock()
			FWriteLine(hFile, i"Failed to lock record {Recno()}")
			LOOP                             
		ENDIF
	END IF
	FieldPut(1, n * 123 % 1000)
	FieldPut(2, Chr(n % 10 + 65) + Chr(n % 13 + 65) + Chr(n % 15 + 65))
	#warning try with and without DBCommit(), I get different results
	// DbCommit()
	DbUnLock()
NEXT
DbCloseArea()

WAIT "Press enter to start check. make sure dbf is not updated by other process"
	
LOCAL cOld,cNew AS STRING
LOCAL nTotalErrors := 0 AS INT
cOld := ""

IF nInstance == 1
	DbUseArea(,"DBFCDX",cDbf,,FALSE)
	DbGoTop()
	IF OrdKeyCount() != RecCount()
		VAR cLine := i"Error OrdKeyCount= {OrdKeyCount()} RecCount= {RecCount()}"
		? cLine
		FWriteLine(hFile, cLine)	
	ENDIF	
	DO WHILE !Eof()
		cNew := FieldGet(2) + Str(FieldGet(1),3,0)
		IF cNew < cOld
			VAR cLine := I"Error at recno {RecNo()} next and previous values: {cNew} {cOld}"
			? cLine
			FWriteLine(hFile, cLine)
			nTotalErrors ++
		END IF
		cOld := cNew
		DbSkip()
	END DO
	DbOrderInfo(DBOI_USER+42)
	DbCloseArea()
	VAR cLine1 := i"{nTotalErrors} errors, out of {gnIterations} iterations"
	? cLine1
	? FWriteLine(hFile, cLine1)
ENDIF


CATCH e AS Exception                  
	? e:ToString()
	FWriteLine(hFile, e:ToString())
	WAIT
END TRY	

FClose(hFile)

FUNCTION TestDateTimeAndCurrency() AS VOID
LOCAL dt AS DateTime
LOCAL c AS CURRENCY
 
dt := DateTime(2000,12,2)
c := 12.45

// ok, the FP and VO dialect show the same results
? dt  // 02.12.2020 00:00:00
? c   // 12,4500
?
// ok, the FP and VO dialect show the same results

? XSharp.RuntimeState.Dialect
? dt:GetType():ToString()  // System.DateTime
? c:GetType():ToString()   // XSharp.__Currency 
?
? "Test DateTime:"
TestUsual ( dt )
?
? "Test Currency:" 
TestUsual ( c ) 
?

RETURN 

FUNCTION TestIndexKey() AS VOID
        
    LOCAL aDbf AS ARRAY
    LOCAL cDBF AS STRING
    LOCAL aValues AS ARRAY
    LOCAL i AS DWORD
    
    RddSetDefault("DBFCDX")
    
    DbCloseAll()
    
    cDBF := "c:\test\abc"
    FErase(cDbf + ".cdx")
    
    RddSetDefault("DBFCDX")
    
    aValues := { 44 , 12, 34 , 21 }
    aDbf := {{ "AGE" , "N" , 2 , 0 }}
    
    DbCreate( cDBF , aDbf)
    DbUseArea(,"DBFCDX",cDBF,,FALSE)
    FOR i := 1 UPTO ALen ( aValues )
        DbAppend()
        FieldPut(1,aValues [i])
    NEXT
    DbCreateIndex( cDbf, "age" )
    DbGoTop()
    
    ? IndexKey() // EMPTY, should be "age"
    DbCloseArea() 
           
FUNCTION TestUsual ( u AS USUAL ) AS VOID 

/*	
 The VO dialect shows: 

	XSharp.__Usual
	XSharp.__Usual 
	
  while the FP dialect shows:
  
	System.DateTime
 	XSharp.__Currency

*/

? u:GetType():ToString()   

RETURN 

FUNCTION testAppDelim() AS VOID
LOCAL cPfad, cSource, cDbf AS STRING
	LOCAL lOK := FALSE AS LOGIC
	LOCAL oDB AS DbServer
	cPfad:= "C:\Download\"
	cSource:= "kv_lieferad.csv"
	cDbf:= "kv_Lieferad.dbf"
	oDB:= DbServer{cPfad+cDbf,FALSE}
	oDB:Zap()
?	lOK := oDB:AppendDelimited(cPfad+cSource,",")
	? oDb:LastRec
    oDb:Close()
    
FUNCTION TestAppend( ) AS VOID
LOCAL i AS DWORD 
LOCAL aFields AS ARRAY
LOCAL cDbf, cPfad AS STRING  
LOCAL f AS FLOAT 
                     
    RddSetDefault( "dbfcdx" )
    

	cPfad := "C:\TEST\"	

	cDBF := cPfad + "Foo.dbf"


	aFields := { { "LAST" , "C" , 10 , 0 } } 
    
	//SetExclusive ( TRUE )  
    // 10000 in 0.5 secs	      
    SetExclusive ( FALSE )   
	// 10000 in 0.95 secs	 
	
	? DbCreate( cDBF , AFields) 
	? DbUseArea( ,,cDBF )	

	f := Seconds()
		
	FOR i := 1 UPTO 10000
		DbAppend() 
		FieldPut ( 1 , PadL ( i , 10 , "0" ) )
						
	NEXT 

	? "Elapsed:" , Seconds() - f
	
	DbCloseArea()
	
RETURN 


Function TestDelimWrite() as VOID
    local f as float
    SetExclusive(TRUE)
    RddSetDefault("DBFNTX")
    DbUseArea(TRUE,"DBFNTX", "c:\Test\TEST10K.DBF")
    ? "Writing"
    f := Seconds()
    RuntimeState.Eof := FALSE
    DbCopyDelim("C:\test\test10k.txt",'"')
    ? "TXT", Seconds() - f
    f := Seconds()
    RuntimeState.DelimRDD := "CSV"
    DbCopyDelim("C:\test\test10k.csv",'"')
    ? "CSV",Seconds() - f
    f := Seconds()
    RuntimeState.DelimRDD := "TSV"
    DbCopyDelim("C:\test\test10k.tsv",'"')
    ? "TSV",Seconds() - f
    f := Seconds()
    DbCopySDF("C:\test\test10k.sdf")
    ? "SDF", Seconds() - f
    f := Seconds()
    DbCopyStruct("c:\Test\TESTEmpty.DBF")
    SetAnsi(TRUE)
    DbUseArea(FALSE,"DBFNTX", "c:\Test\TESTEmpty.DBF","TEST",FALSE)
    FConvertToMemoryStream(DbInfo(DBI_FILEHANDLE))
    f := Seconds()
    ? "Reading"
    DbZap()
    f := Seconds()
    DbAppSdf("C:\test\test10k.sdf")
    ? "SDF", Seconds() - f
    DbZap()
    RuntimeState.DelimRDD := "DELIM"
    DbAppDelim("C:\test\test10k.txt",'"')
    ? "TXT", Seconds() - f
//    DbZap()
//    f := Seconds()
//    RuntimeState.DelimRDD := "CSV"
//    DbAppDelim("C:\test\test10k.csv",'"')
//    ? "CSV", Seconds() - f
//    DbZap()
//    f := Seconds()
//    DbAppSdf("C:\test\test10k.sdf")
//    ? "SDF", Seconds() - f
    DbCloseAll()
    RETURN
Function ShowRec() as LOGIC
    if Recno() % 1000 == 0
        ?  "."
    ENDIF
    RETURN TRUE

FUNCTION testUnique3() AS VOID
	LOCAL cDbf AS STRING	
	LOCAL aValues AS ARRAY
	LOCAL i AS INT

	RddSetDefault ( "DBFNTX" )
	
	cDbf := "C:\TEST\foo"
	FErase ( cDbf + ".ntx" )
	FErase ( cDbf + ".cdx" )
	
	aValues := { "g1" , "o5" , "g2", "g1" , "g8" , "g1"}
	
	? DbCreate( cDBF , { { "LAST" , "C" , 20 , 0 } })
	? DbUseArea( ,,cDBF , , TRUE )  // open shared               
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend()
		FieldPut ( 1 , aValues [ i ] )
	NEXT
	
	DbCreateOrder ( "ORDER1" , cDbf , "upper(LAST)" , { || Upper ( _Field->LAST) } , TRUE) // Unique
	? "DBOI_UNIQUE", DbOrderInfo(DBOI_UNIQUE) // TRUE, correct
	
	? "Records in UNIQUE order:" // shows all 6, should be 4 only
	DbGoTop()
	DO WHILE .not. Eof()
		? RecNo(), FieldGet(1)
		DbSkip()
	END DO
	DbCloseArea()

	DbUseArea( ,,cDBF , , FALSE )    // open not shared
	DbSetIndex(cDbf)
	? "DBOI_UNIQUE", DbOrderInfo(DBOI_UNIQUE)  // TRUE, correct
	? "Now pack or zap or reindex"

	DbPack()
//	DBZap()
//	DbReindex()

	? "DBOI_UNIQUE", DbOrderInfo(DBOI_UNIQUE)  // TRUE, correct
	? "Records in UNIQUE order:" // now does not show any records, wrong
	DbGoTop()
	DO WHILE .not. Eof()
		? RecNo(), FieldGet(1)
		DbSkip()
	END DO
	DbCloseArea()

	? "--------------------------"   
	? "Close and reopen dbf + cdx"
	? "--------------------------"

	DbUseArea( ,,cDBF , , FALSE ) // FALSE, wrong
	DbSetIndex(cDbf)
	? "DBOI_UNIQUE", DbOrderInfo(DBOI_UNIQUE)
	? "Records in UNIQUE order:" // again no records
	DbGoTop()
	DO WHILE .not. Eof()
		? RecNo(), FieldGet(1)
		DbSkip()
	END DO
	DbCloseArea()
RETURN

FUNCTION BofAndScope() AS VOID STRICT
	LOCAL cDBF AS STRING 
	RddSetDefault ( "DBFNTX" ) 

	cDBF := "C:\test\mydbf" 
	FErase(cDbf + ".dbf")
	FErase(cDbf + ".cdx")
	
	DbCreate(cDbf, {{"CFIELD", "C" , 1, 0}})
	DbUseArea(TRUE,, cDbf)
	DbAppend();FieldPut(1 , "S")
	DbAppend();FieldPut(1 , "S")
	DbAppend();FieldPut(1 , "N")
	DbAppend();FieldPut(1 , "N")
	DbAppend();FieldPut(1 , "N")
	DbAppend();FieldPut(1 , "S")
	DbAppend();FieldPut(1 , "S")
	DbCreateIndex(cDbf , "CFIELD")
	DbCloseArea()
	
	
	? DbUseArea( TRUE ,,cDBF )		
	DbSetIndex(cDbf )
	? OrdScope(TOPSCOPE, "S")
	? OrdScope(BOTTOMSCOPE, "S")	
	?
	
	DbGoTop() 
	? "Performing DKSkip(+1) until EoF()"
	DO WHILE ! Eof() 
		? "recno", RecNo(), FieldGet(1)
		DbSkip ( 1 ) 		
	ENDDO   
	
	
	? "Recno:" , RecNo() , "Eof:" , Eof() , "Bof:" , Bof()
	
	// activate the DBGoBOttom() and the bof() below
	// behaves as expected after the DBSkip(-1)
	
	// DbGoBottom()  
	
	? 
	? "Performing DKSkip(-1) until BoF()"
	DO WHILE ! Bof()
		DbSkip ( -1 ) 
		? "recno", RecNo(), FieldGet(1)
		? "Bof" , Bof() // TRUE after the first DBSkip ( -1 ) 
	ENDDO 			
	
	? "Eof", Eof()
	DbCloseArea()
RETURN
RETURN

FUNCTION ScopeTestOldValue() AS VOID STRICT
	LOCAL cDBF AS STRING 
	RddSetDefault ( "DBFNTX" ) 

	cDBF := "C:\test\mydbf" 
	FErase(cDbf + ".dbf")
	FErase(cDbf + ".cdx")
	
	DbCreate(cDbf, {{"CFIELD", "C" , 1, 0}})
	DbUseArea(TRUE,, cDbf)
	DbAppend();FieldPut(1 , "S")
	DbAppend();FieldPut(1 , "S")
	DbAppend();FieldPut(1 , "N")
	DbCreateIndex(cDbf , "CFIELD")
	DbCloseArea()
	
	DbUseArea( TRUE ,,cDBF )
    DbSetIndex(cDbf)
	? OrdScope(TOPSCOPE, "S")
	? OrdScope(BOTTOMSCOPE, "S")
	? OrdScope(TOPSCOPE, "N")
	? OrdScope(BOTTOMSCOPE, "N")
	DbCloseArea()
RETURN
    FUNCTION    testPruntGrup AS VOID
    ? DbUseArea(,"DBFCDX","C:\test\PRINTGRP")
? DbCloseArea()
    RETURN
FUNCTION    TestMsg05() AS VOID
    LOCAL aStruct AS ARRAY
    DbUseArea(,,"c:\download\FieldPutDescartes\msg05.DBF")
    aStruct := DbStruct()
    DbCreate("test",aStruct)
    DbUseArea(,,"TEST")
    DbAppend()
    __FIeldSetWa("TEST","OPDSEQNR",1)
    DbCloseArea()
    RETURN

FUNCTION TestWriteError() AS VOID
    XSharp.RuntimeState.Dialect := XSharpDialect.FoxPro
    RddSetDefault("DBFNTX")
    DbCreate("test",{{"NUM","N",3,0}})
    DbUseArea(TRUE ,,"TEST")
    DbAppend()
    __FieldSetWa("TEST", "NUM", 1)
    DbCloseArea()
    DbUseArea(TRUE ,,"TEST")
    LOCAL u AS USUAL
    __FieldSetWa("TEST", "NUM", 1)
    __FieldSetWa("TEST", "NUM", 1.0)
    __FieldSetWa("TEST", "NUM", 1.0m)
    //__FieldSetWa("TEST", "NUM", 9999)
    //__FieldSetWa("TEST", "NUM", "aaa")
    DbCloseArea()
    RETURN
FUNCTION TestAdsAppendDb() AS VOID
    LOCAL oServer AS DbServer
    RddSetDefault("AXDBFNTX")
    oServer := DbServer{"c:\cavo28SP3\Samples\Gstutor\customer.dbf"}
    RddSetDefault("ADSADT")
    oServer:CopyDb("c:\temp\test")
    oServer:Close()
    RddSetDefault("ADSADT")
    oServer := DbServer{"c:\temp\test",FALSE}
    oServer:Zap()
    RddSetDefault("AXDBFNTX")
    oServer:AppendDB("c:\cavo28SP3\Samples\Gstutor\customer.dbf")
    oServer:Close()
    RETURN


FUNCTION TestCreateRepeat() AS VOID
LOCAL cDbf AS STRING
LOCAL cPath AS STRING
cPath := "c:\test\"
cDbf := "FooBar"
? DBCreate(cPath + cDbf, {{"FLD1" , "N" , 5, 1}} , "DBFCDX")
? DBUseArea(,"DBFCDX" , cPath + cDbf)
? DBCreateOrder(cDbf, "testing", "fld1+fld1")
? DBCloseArea()
? DBUseArea(,"DBFCDX" , cPath + cDbf)
? DBCreateOrder(cDbf, "testing", "fld1+fld1")
DbReindex()
? DBCloseArea()
RETURN
FUNCTION TestUniquex() AS VOID
	LOCAL cDbf AS STRING	
	LOCAL aValues AS ARRAY
	LOCAL i AS INT

	RddSetDefault ( "DBFCDX" )
	
	cDbf := "C:\TEST\foo"
	FErase ( cDbf + ".cdx" )
	
	aValues := { "g1" , "o5" , "g2", "g1" , "g8" , "g1"}
	
	? DbCreate( cDBF , { { "LAST" , "C" , 20 , 0 } })
	? DbUseArea( ,,cDBF , , TRUE )  // open shared               
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend()
		FieldPut ( 1 , aValues [ i ] )
	NEXT
	
	DbCreateOrder ( "ORDER1" , cDbf , "upper(LAST)" , { || Upper ( _FIELD->LAST) } , TRUE) // Unique
	? "DBOI_UNIQUE", DbOrderInfo(DBOI_UNIQUE) // TRUE, correct
	
	? "Records in UNIQUE order:" // shows all 6, should be 4 only
	DbGoTop()
	DO WHILE .NOT. Eof()
		? RecNo(), FieldGet(1)
		DbSkip()
	END DO
	DbCloseArea()

	DbUseArea( ,,cDBF , , FALSE )    // open not shared
	? "DBOI_UNIQUE", DbOrderInfo(DBOI_UNIQUE)  // TRUE, correct
	? "Now pack or zap or reindex"

//	DbPack()
//	DBZap()
	DbReindex()

	? "DBOI_UNIQUE", DbOrderInfo(DBOI_UNIQUE)  // TRUE, correct
	? "Records in UNIQUE order:" // now does not show any records, wrong
	DbGoTop()
	DO WHILE .NOT. Eof()
		? RecNo(), FieldGet(1)
		DbSkip()
	END DO
	DbCloseArea()

	? "--------------------------"   
	? "Close and reopen dbf + cdx"
	? "--------------------------"

	DbUseArea( ,,cDBF , , FALSE ) // FALSE, wrong
	? "DBOI_UNIQUE", DbOrderInfo(DBOI_UNIQUE)
	? "Records in UNIQUE order:" // again no records
	DbGoTop()
	DO WHILE .NOT. Eof()
		? RecNo(), FieldGet(1)
		DbSkip()
	END DO
	DbCloseArea()
RETURN

FUNCTION TestbBrowserImage() AS VOID
    LOCAL oServer AS DbServer
    LOCAL cDibData AS STRING
    RddSetDefault("DBFCDX")
    oServer := DBServer{"Image.dbf",,,"DBFCDX"}
    cDibData := oServer:FieldGet(#IMAGE)
	? Slen(cDibData)// 164432, OK
	cDibData := oServer:BLOBGet(#IMAGE) // XSharp.Error: 'Conversion Error from USUAL (OBJECT)  to STRING'
    oServer:BLOBExport(#Image, "D:\picture.bmp", BLOB_EXPORT_OVERWRITE)
    oServer:BLOBImport(#Image, "D:\picture.bmp")
	? Slen(cDibData) // should be 164432 again
    oServer:Close()
    RETURN
FUNCTION AndreaLikesThis() AS VOID

            LOCAL aStruct                           AS ARRAY

            LOCAL oDBServer                                 AS DBServer

            LOCAL oDBServerNew               AS DBServer

 

            aStruct             := {}

            AAdd( aStruct, { "Field1", "N", 10, 0 } )
            AAdd( aStruct, { "L1", "L", 10, 0 } )
            AAdd( aStruct, { "X1", "N", 10, 0 } )
            AAdd( aStruct, { "X2", "N", 10, 0 } )
            AAdd( aStruct, { "X3", "N", 10, 0 } )
            AAdd( aStruct, { "X4", "N", 10, 0 } )
            AAdd( aStruct, { "X5", "N", 10, 0 } )

            AAdd( aStruct, { "Field2", "M", 10, 0 } )

            DbCreate( "C:\temp\test.dbf", aStruct, "DBFCDX", TRUE, "TEST",, FALSE )        

            TEST->DbCloseArea()

 

            oDBServer                    := dbServer{ "C:\temp\test.dbf", TRUE, FALSE, "DBFCDX" }

            oDBServer:Append()

            oDBServer:FieldPut( #Field1, 1 )

            oDBServer:FieldPut( #Field2, "1111111111111111111111111111111111111" )

            oDBServer:Commit()

            oDBServer:Append()

            oDBServer:FieldPut( #Field1, 2 )

            oDBServer:FieldPut( #Field2, "2222222222222222222222222222222222222" )

            oDBServer:Commit()

            oDBServer:Append()

            oDBServer:FieldPut( #Field1, 3 )

            oDBServer:FieldPut( #Field2, "3333333333333333333333333333333333333" )

            oDBServer:Commit()

 

            oDBServer:CopyDB( "c:\temp\testNew.dbf",,,, DBSCOPEALL, "DBFCDX" )          

 

            ? "After CopyDB Value MemoField is empty"

            oDBServerNew              := dbServer{ "C:\temp\TestNew.dbf", TRUE, FALSE, "DBFCDX" }

            oDBServerNew:Gotop()

            WHILE ! oDBServerNew:EoF

                        ? Str( oDBServerNew:FieldGet( #Field1 ) ) + " -> " + oDBServerNew:FieldGet( #Field2 )          

                        oDBServerNew:Skip()

            ENDDO

           

            IF TRUE

                        ? "After CopyDB and Append Value MemoField has wrong References"

                        oDBServerNew:Append()

                        oDBServerNew:FieldPut( #Field1, 4 )

                        oDBServerNew:FieldPut( #Field2, "4444444444444444444444444444444444444" )

                        oDBServerNew:Commit()

                        oDBServerNew:Gotop()

                        WHILE ! oDBServerNew:EoF

                                    ? Str( oDBServerNew:RecNo ) + ": " + Str( oDBServerNew:FieldGet( #Field1 ) ) + " -> " + oDBServerNew:FieldGet( #Field2 )       

                                    oDBServerNew:Skip()

                        ENDDO

            ENDIF

           

            IF TRUE

                        ? "Modify old Value"

                        oDBServerNew:Goto( 3 )

                        oDBServerNew:FieldPut( #Field2, "333333333333333333333333333333333333333333333333333333333" )

                        oDBServerNew:Commit()

                        oDBServerNew:Gotop()

                        WHILE ! oDBServerNew:EoF

                                    ? Str( oDBServerNew:RecNo ) + ": " + Str( oDBServerNew:FieldGet( #Field1 ) ) + " -> " + oDBServerNew:FieldGet( #Field2 )       

                                    oDBServerNew:Skip()

                        ENDDO

            ENDIF

 

            ? "Orginal Table ist still working, update record 3 with '33333'"

            oDBServer:Goto( 3 )

            oDBServer:FieldPut( #Field2, "33333" )

            oDBServer:Commit()

            oDBServer:Gotop()

            WHILE ! oDBServer:EoF

                        ? Str( oDBServer:FieldGet( #Field1 ) ) + " -> " + oDBServer:FieldGet( #Field2 )           

                        oDBServer:Skip()

            ENDDO

 

RETURN

FUNCTION UniDbf() AS VOID
Console.OutputEncoding := System.Text.Encoding.Unicode
RddSetDefault("DBFVFP")
DbCreate("UNIDBF",{{"ID","I:+",4,0},{"NAME","C:U",50,0},{"COUNTRY","C",25,0},{"MONEY","Y",8,0}})
DbUseArea(TRUE , "DBFVFP", "UNIDBF","UNIDBF")
DbAppend()
FieldPut(2, "Robert")
FieldPut(3, "The Netherlands")
DbAppend()
FieldPut(2, "Χρίστος")
FieldPut(3, "Greece")
DbAppend()
FieldPut(2, "Nikos")
FieldPut(3, "Greece")
DbAppend()
FieldPut(2, "Fabrice")
FieldPut(3, "France")
DbCloseArea()
DbUseArea(TRUE , "DBFVFP", "UNIDBF","UNIDBF")
ShowArray(DbStruct())
? DbFieldInfo(DBS_STRUCT,1):ToString()
? DbFieldInfo(DBS_STRUCT,2):ToString()
? DbFieldInfo(DBS_STRUCT,3):ToString()
? DbFieldInfo(DBS_STRUCT,4):ToString()
DO WHILE ! Eof()
    ? FieldGet(1), FieldGet(2), FieldGet(3)
    DbSkip(1)
ENDDO
DbCloseArea()
RETURN


FUNCTION Northwind() AS VOID
RddSetDefault("DBFVFP")
DbUseArea(TRUE , "DBFVFP", "c:\Program Files (x86)\Microsoft Visual FoxPro 9\Samples\Northwind\customers.dbf")
LOCAL fld AS DWORD
FOR fld := 1 TO FCOunt()
    ? fld, FieldName(fld), DbFieldInfo(DBS_ALIAS, fld)
NEXT
RETURN


FUNCTION CorruptDbf2() AS VOID
RddSetDefault("DBFVFP")
CREATE _tmpstructure
APPEND BLANK
? RecNo() // 4294967283 (-13)
? RecCount() // -13
? DbCloseArea()
RETURN

FUNCTION CorruptDbf() AS VOID
    RddSetDefault("DBFCDX")
    DbUseArea(TRUE,"DBFCDX", "c:\download\fauftrag\FAuftrag.DBF")
    DbGoto(101)
    LOCAL fld AS DWORD
    FOR fld := 1 TO FCOunt()
        ? FieldName(fld), FieldGet(fld)
    NEXT
    DbCloseArea()
    RETURN

FUNCTION TestChrisOrdinal() AS VOID
     Console.WriteLine( SetCollation(#Ordinal))
    // RuntimeState.Dialect := XSharpDialect.XPP
     LOCAL cDBF AS STRING
     LOCAL aFields, aValues AS ARRAY
     LOCAL cPrev AS STRING
     LOCAL nCount AS INT
     LOCAL i AS DWORD

     RddSetDefault ( "DBFCDX" )

     aFields := { { "LAST" , "C" , 200 , 0 }}
        VAR start := 48934 //seconds()
     Rand(start)

FOR VAR nRepeat := 1 TO 1000
        Console.WriteLine( "Repeat " + nRepeat:ToString())
        //IF nRepeat == 31 //.OR. nRepeat == 1
        //    XSharp.RDD.DBFCDX.StartLogging()
        //ENDIF
     cDBF := "c:\test\mytest"+nRepeat:ToString()
     FErase ( cDbf + IndexExt() )
     FErase ( cDbf + ".DBF" )

     DbCreate( cDBF , AFields)
     DbUseArea(,,cDBF )
     FOR i := ASC("A") UPTO ASC("Z")
         DbAppend()
         FieldPut ( 1 , Replicate( chr(i) , 100) )
         DbAppend()
         FieldPut ( 1 , Replicate( chr(i+32) , 100) )
     NEXT
     //? "Written"   
     DbCreateIndex ( cDBF , "LAST" , {||_FIELD->LAST})
     FOR i := 1 TO RecCount() 
         VAR nChar := Rand()*32 + ASC("A")
         VAR nRec := Rand()*RecCount()
         nRec := System.Math.Min(nRec+1, RecCount())
         DbGoto(nRec)
         VAR len := Rand() * 50
         FieldPut(1, repl(chr(nChar),len))
         //DbCommit()
        //XSharp.RDD.DBFCDX.ValidateTree()
     NEXT
    //? "Replaced"

     cPrev := NULL
     nCount := 0
     DbGoTop()
     DO WHILE .NOT. EoF()
         nCount ++
         VAR cCurrent := FieldGet(1)
         //? recno(), "ordered value", Left(cCurrent,20)
         IF cPrev != NULL

             IF .NOT. cPrev <=  cCurrent
                 ? "Failed at values:"
                 ? Left(cPrev,10)
                 ? Left(cCurrent,10)
                    WAIT
             END IF
         END IF
         cPrev := cCurrent
         DbSkip()
     END DO

     DbCloseArea()
    //? "Checked"
    NEXT

RETURN

FUNCTION TestLndRel() AS VOID
    LOCAL nFld AS DWORD
    RddSetDefault("DBFNTX")
    SetCollationTable(COLLAT_AMERICAN)
    DbUseArea(TRUE,"DBFNTX","c:\Descartes\LndRel\lndrel.dbf","LNDREL")
    DbSetIndex("c:\Descartes\LndRel\lndrel1.ntx")
    ? DbSeek("BAV01IT")
    ? "Record", Recno(), "EOF", Eof(), "Found", Found()
    FOR nFld := 1 TO FCount()
        ? FIeldName(nFld), FieldGet(nFld)
    NEXT
    DbCloseArea()
    RETURN

FUNCTION TestCollationChris() AS VOID
    LOCAL hFile AS IntPtr
    hFile := FCreate("test.txt")
    FWriteLine(hFile, "aaa")
    FClose(hFile)
   
    ? SetCollation()
    ? SetCollation(#Ordinal)   
    ? SetCollation()
RETURN
FUNCTION TestIndexCreate() AS VOID
    LOCAL nCount AS LONG
?  DBUSEAREA(TRUE, "DBFCDX", "c:\Test\RATE.DBF")
   VAR oRDD := XSharp.RuntimeState.Workareas:GetRDD(SELECT())      
   oRDD := WrapperRDD{oRDD}
    
   ? DbSetIndex("c:\Test\RATEXS.CDX","MainRecno")
   
   ? DbGotop()
   nCount := 0
   DO WHILE ! EOF()                             
   	++nCount
   	DBSKIP(1)
   ENDDO
   ? nCount
    DBCLOSEAREA()
/*
RddSetDefault("DBFCDX")
    FERase("c:\Test\RATEXS.CDX")
    DbUseArea(TRUE, "DBFCDX", "c:\Test\RATE.DBF")
    DbCreateOrder("MainRecno","RATEXS","Str(MainRecno,10,0)")
    DbOrderInfo(DBOI_USER+42)
    DbCLoseArea()
*/    
RETURN

FUNCTION TestWord() AS VOID STRICT
    LOCAL oApp AS OBJECT
    LOCAL nCounter AS INT
    oApp := OleAutoObject{ "WORD.Application" }
    nCounter := oApp:System:Application:Documents:Count
    IF nCounter == 0
        oApp:Application:Quit()
        oApp := NULL
        Gc.Collect()
    ENDIF
    RETURN 

FUNCTION CountAndSpeedTest() AS VOID      
LOCAL cDBF, cIndex, cPfad  AS STRING 
LOCAL oDB AS DBServer
LOCAL fStart, fSum AS FLOAT
LOCAL dwHits AS DWORD
LOCAL lUseCDX AS LOGIC  
    
    
	lUseCDX := TRUE  // or FALSE - makes no difference 
		
   	RddSetDefault ( "DBFCDX" )
   	
    // -----------------
    cPfad := "c:\download\sumtest\" 
    // -----------------
    
	cDBF := cPfad + "large.dbf"
	cIndex := cPfad + "large1x.cdx"  
	
//    ? cdbf
//    ? cIndex
    
	IF ! File ( cIndex ) 
		
	   	? DbUseArea( ,,cDBF )
		fStart := Seconds()
		? DbCreateOrder ( "ORDER1"  , cIndex , "Upper(LAST)" , { || Upper ( _FIELD->LAST) } )
        ? "CDX creation:" , Seconds() - fStart
        DbCloseArea()
        ? 
        
	ENDIF	
 
    // -------------------  
    
	? DbUseArea( ,,cDBF )
	
	IF lUseCDX	
		? DbSetIndex ( cIndex)
		? DbSetOrder ( 1 )  
	ENDIF	
	
  
    DbGoTop()
    dwHits := 0 
    fSum := 0.00
    
    fStart := Seconds()
    
	DO WHILE ! Eof() 

		IF FieldGetSym( #LAST ) = "G"
		
			dwHits += 1 
	
//			fSum += FieldGetSym( #SALARY ) 
			fSum := fSum + FieldGetSym( #SALARY ) 
			                                       
		ENDIF
		
		DbSkip ( 1 )
	
	ENDDO 
	
    ?
	? "dbfuncs" ,IIF ( lUseCDX, "CDX used" , "No CDx used" )   	 
	? Seconds() - fStart 
	? dwHits
	? fSum
 	
      
 	DbCloseArea()  
 	
 	// ------------
 	?
 	
 	oDB :=  DBServer { cDBF }  
 	?  oDB:Used
 	
 	IF lUseCDX
	 	? oDB:SetIndex ( cIndex)
 		? oDB:Setorder ( 1 ) 
 	ENDIF	
 	
    oDB:GoTop()
    dwHits := 0
    fSum := 0.00 
      
//  oDB:Suspendnotification()
    
    fStart := Seconds()
    
	DO WHILE ! oDB:Eof 

		IF oDB:FieldGet ( #LAST) = "G"
		
			dwHits += 1 
	
			fSum += oDB:FieldGet ( #SALARY ) 
//			fSum := fSum + oDB:FieldGet ( #SALARY ) 
			                                       
		ENDIF
		
		oDB:Skip (1)	
	ENDDO 
	
//	oDB:ResetNotification()

    ?
	? "DBServer" ,IIF ( lUseCDX, "CDX used" , "No CDx used" )   	 
	? Seconds() - fStart 
	? dwHits
	? fSum
 	
    oDB:Close() 
    
	RETURN 
	
FUNCTION TestSalary() AS VOID
    DbUseArea(TRUE, "DBFNTX", "c:\download\sumtest\Large.DBF")
    DBGoto(1134)
    ? FieldGetSym("Salary")
    DbCLoseArea()
FUNCTION DoWork( oParam AS OBJECT ) AS VOID
    LOCAL nI                                  AS DWORD  
    LOCAL nParam              AS INT
    LOCAL nSleep               AS INT
    nParam                                    := INT( oParam )
    nSleep                          := 10 //* nParam
    DbUseArea( TRUE, "DBFCDX", "c:\temp\test.dbf", "TEST", TRUE, FALSE )
    DbCargo(Error{})
    FOR nI := 1 UPTO 1000
        nSleep                          := Rand(0) * 100
        System.Console.WriteLine( NTrim(nParam) + " -> " + NTrim(nI) + " Sleep: " + NTrim( nSleep ) )
        TEST->DbAppend()
        TEST->FIELD1 := nI
        TEST->FIELD2 := nParam
        IF ! TEST->DbCommit()
            DebOut(NTrim(nParam) +" Error by Commit" )
            Debout(RuntimeState:LastRDDError:ToString())
        ENDIF
        System.Threading.thread.Sleep( INT( nSleep ) )
    NEXT
    TEST->DbCloseArea()
RETURN

 

FUNCTION DoWork2( oParam AS OBJECT ) AS VOID
            LOCAL nI                  AS DWORD  
            LOCAL nParam              AS INT
            LOCAL nSleep              AS INT
            LOCAL oDBServer           AS DBServer
            nParam                    := INT( oParam )
            nSleep            := 10 * nParam
            oDBServer         := DBServer{ "c:\temp\test.dbf", TRUE, FALSE, "DBFCDX" }
            FOR nI := 1 UPTO 1000
                nSleep        :=  Rand(0) * 25
                System.Console.WriteLine( NTrim(nParam) + " -> " + NTrim(nI) + " Sleep: " + NTrim( nSleep ) )
                IF ! oDBServer:Append() 
                    System.Console.WriteLine( NTrim(nParam) +" Append Failed" )
                    System.Console.WriteLine(RuntimeState:LastRDDError:ToString())
                ENDIF
                oDBServer:FieldPut( #Field1, nI )
                oDBServer:FieldPut( #Field2, nParam )
                IF ! oDBServer:Commit()
                    System.Console.WriteLine( NTrim(nParam) +" Error by Commit" )
                    System.Console.WriteLine(RuntimeState:LastRDDError:ToString())
                ENDIF
                System.Threading.thread.Sleep( INT( nSleep ) )
            NEXT
            oDBServer:Close()

 

RETURN

CLASS DbLogger IMPLEMENTS IDbNotify
    METHOD Notify(sender AS XSharp.RDD.IRdd, e AS DbNotifyEventArgs) AS VOID
        IF (sender != NULL)
            DebOut( sender:Alias, sender:Area, e:Type:ToString(), e:Data)
        ELSE
            DebOut( "no area", e:Type:ToString(), e:Data)
        ENDIF
        
END CLASS
 

FUNCTION TestThreading() AS VOID

            LOCAL cPath                             AS STRING

            LOCAL cFileName                      AS STRING
            LOCAL aStruct               AS ARRAY
            LOCAL nI                                  AS DWORD
            LOCAL nCount               AS DWORD
            LOCAL oThread1                       AS system.Threading.Thread
            LOCAL oThread2                       AS system.Threading.Thread 
 
            System.Console.WriteLine( "Start" )
            //DbRegisterClient(DbLogger{})
            RddSetDefault( "DBFCDX" )     

            cPath                := "C:\Temp"
            cFileName         := cPath + "\" + "Test.DBF"
            FErase( cPath + "\" + "Test.DBF"  )
            FErase( cPath + "\" + "Test.CDX"  )

            aStruct              := {}
            AAdd( aStruct, { "Field1", "N", 10, 0 } )

            AAdd( aStruct, { "Field2", "N", 10, 0 } )

            DbCreate( cFileName, aStruct, "DBFCDX", TRUE, "TEST",, FALSE )        

             TEST->DbCreateOrder( "ORDER1",, "Str(FIELD1,10)", {|| Str( _FIELD->FIELD1,10 ) }, FALSE )
            TEST->DbCommit( )
            TEST->DbCloseArea()
            oThread1          := System.Threading.Thread{ DoWork2 }  
            oThread1:Start( 1 )
            oThread2          := System.Threading.Thread{ DoWork2}
            oThread2:Start( 2 )  
            oThread1:Join()
            oThread2:Join()

            DbUseArea( TRUE, "DBFCDX", "c:\temp\test.dbf", "TEST", TRUE, FALSE )
            ? "With order:"
            nCount                          := 0
            Test->DbSetOrder( "ORDER1" )
            Test->DbGoTop()
            WHILE ! Test->Eof()
                        //? NTrim( Test->Field1 ) + " <- " + NTrim( Test->Field2 ) + " - Recno: " + NTrim( Test->RecNo())
                        Test->DbSkip() 
                        nCount++                   
            ENDDO   
            ? "Count: " + NTrim( nCount )
            ? "Without order:"
            Test->DbSetOrder( 0 )
            Test->DbGoTop()
            nCount                          := 0
            WHILE ! Test->Eof()
                        //? NTrim( Test->Field1 ) + " <- " + NTrim( Test->Field2 ) + " - Recno: " + NTrim( Test->RecNo() )
                        Test->DbSkip()                       
                        nCount++
            ENDDO            
            ? "Count: " + NTrim( nCount )
            TEST->DbCloseArea()
                              

            RETURN

FUNCTION TestCommitWolf() AS VOID
            LOCAL cPath                             AS STRING
            LOCAL cFileName                      AS STRING
            LOCAL aStruct               AS ARRAY

            RddSetDefault( "DBFCDX" )
            cPath                                        := "C:\Temp"
            cFileName                                := cPath + "\" + "Test.DBF"
            FErase( cPath + "\" + "Test.DBF"  )
            FErase( cPath + "\" + "Test.CDX"  )

            aStruct   := { { "FIELD1", "N", 10, 0 } } 
            DbCreate( cFileName, aStruct, "DBFCDX", TRUE, "TEST",, FALSE )
            TEST->DbSetOrderCondition( "FIELD1 == 1", { || _FIELD->FIELD1 == 1 } ,,,,,,,,,,,,, )
            TEST->DbCreateOrder( "ORDER1",, "STR(FIELD1,10)", {|| Str( _FIELD->FIELD1, 10 ) }, FALSE )
            TEST->DbCloseArea()

            DbUseArea( TRUE, "DBFCDX", cFileName, "TEST", TRUE, FALSE )
            TEST->DbAppend()
            TEST->FIELD1 := 1
            ? "Bevor Commit"
            TEST->DbCommit()
            ? "After Commit"
            TEST->DbCloseArea()

FUNCTION testNeg2 AS VOID
      LOCAL cPath                AS STRING
       LOCAL cArtnr        AS STRING
        LOCAL f AS FLOAT
        f := Seconds()
       cPath               := "C:\Test\artikel.dbf"
       cArtnr              := "F"
       DbUseArea( TRUE, "DBFCDX", cPath, "ARTIKEL", FALSE, FALSE )
       OrdListRebuild()
       ARTIKEL->DBSeek( cArtnr, FALSE )
       IF ARTIKEL->Found()
             ? "Found:" + ARTIKEL->ARTNR + " " + ARTIKEL->Beschr1D
             ? "Preis:" + Str( ARTIKEL->PREIS, 10, 2 )
       ELSE
             ? "not found"
       ENDIF
       ARTIKEL->DbCloseArea()
        ? Seconds() - f

FUNCTION TestNegative() AS VOID
    LOCAL cPath                 AS STRING
    LOCAL cFileName             AS STRING
    LOCAL aStruct               AS ARRAY

    cPath                         := "C:\Temp"
    cFileName                     := cPath + "\" + "TestNum.DBF"
    FErase( cPath + "\" + "TestNum.DBF"  )
    FErase( cPath + "\" + "TestNum.CDX"  )

    aStruct                       := { { "FIELD1", "C", 10, 0 }, { "FIELD2", "N", 10, 2 } }
    DbCreate( cFileName, aStruct, "DBFCDX", TRUE, "TestNum",, FALSE )
    TESTNUM->DbCloseArea()
    DbUseArea( TRUE, "DBFCDX", cFileName, "TESTNUM", TRUE, FALSE )
    TESTNUM->DbAppend()
    TESTNUM->FIELD1     := NTrim( 1 )
    TESTNUM->FIELD2     := -10
    TESTNUM->DbGoTop()
    ? "Field1:" + TESTNUM->FIELD1 + ", Field2:" + Str( TESTNUM->FIELD2, 10, 2 )
    TESTNUM->DbAppend()
    TESTNUM->FIELD1     := NTrim( 2 )
    TESTNUM->FIELD2     := 10
    TESTNUM->DbGoBottom()
    ? "Field1:" + TESTNUM->FIELD1 + ", Field2:" + Str( TESTNUM->FIELD2, 10, 2 )
    TESTNUM->DbCloseArea()
    
FUNCTION TestFpt() AS VOID
    LOCAL i AS dword
    DbUSeArea(TRUE,"DBFCDX", "c:\download\ZENSTATS.DBF")
    FOR i := 1 TO FCount()
        ? FieldName(i), FieldGet(i)
    NEXT
    DbCLoseArea()

FUNCTION TestWolfgang3() AS VOID
            LOCAL cPath                             AS STRING
            LOCAL cFileName                      AS STRING
            LOCAL aStruct               AS ARRAY
            LOCAL nI                                  AS DWORD
            cPath                                        := "C:\Temp"
            cFileName                                := cPath + "\" + "Test.DBF"
            FErase( cPath + "\" + "Test.DBF"  )
            FErase( cPath + "\" + "Test.CDX"  )
            aStruct                                     := { { "FIELD1", "C", 10, 0 } }
            DbCreate( cFileName, aStruct, "DBFCDX", TRUE, "ORDERDBF",, FALSE )
            ORDERDBF->DbSetOrderCondition( "! DELETED()", {|| ! Deleted() } )
            ORDERDBF->DbCreateOrder( "ORDER1",, "UPPER(FIELD1)", {|| Upper( _FIELD->FIELD1 ) }, FALSE )
            ORDERDBF->DbCloseArea()
            DbUseArea( TRUE, "DBFCDX", cFileName, "ORDERDBF", TRUE, FALSE )
        
            FOR nI := 1 UPTO 10
                        ?( nI )
                        ORDERDBF->DbAppend()
                        ORDERDBF->FIELD1     := NTrim( nI )

// ORDERDBF->FIELD1  := NTrim( 10-nI )
            NEXT
            ? "Records", ORDERDBF->RecCount()
            ? "Keys",OrderDbf->(DbOrderInfo(DBOI_KEYCOUNT))
            ? "Start Test: First Record 2 Times"
            ORDERDBF->DbGoTop()
            WHILE ! ORDERDBF->Eof()
                        ? ORDERDBF->FIELD1
                        ORDERDBF->DbSkip()  
            ENDDO
            ORDERDBF->DbCloseArea()
            RETURN

FUNCTION TestCeCil() AS VOID
    SET DEFAULT TO C:\Test
    SET TIME TO SYSTEM
    ? Time()
    RddSetDefault("DBFVFP")
    DbUseArea(FALSE,,"Address.dbf")
    LOCAL i AS INT
    FOR i := 1 TO OrderCount()
        ? i, OrdKey(i), OrdFor(i)
    NEXT
    DbCLoseArea()
    RETURN
FUNCTION TestWolfgang2 AS VOID
            LOCAL cFileName          AS STRING

            LOCAL aStruct              AS ARRAY

            LOCAL oDBServer                     AS VO.DBServer

            LOCAL lShareMode        AS LOGIC

 

            lShareMode                               := TRUE

            cFileName                                := "C:\Temp\Test.DBF"

            aStruct                                     := { { "FIELD1", "C", 10, 0 }, { "FIELD2", "C", 10, 0 } }

            DbCreate( cFileName, aStruct, "DBFCDX", TRUE, "TEST",, FALSE )

            TEST->DbAppend()

            TEST->FIELD1 := "9"

            TEST->DbCommit()

 

            TEST->DbSetOrderCondition( "! DELETED()", {|| ! Deleted() } )

            TEST->DbCreateOrder( "ORDER1",, "UPPER(FIELD1)", {|| Upper( _FIELD->FIELD1 ) }, FALSE )

            TEST->DbAppend()

            TEST->FIELD1 := "8"

            TEST->DbCommit()      

 

            IF TRUE

                        TEST->DbSetOrderCondition( "! DELETED() .and. Left(FIELD1,1) == '9'", {|| ! Deleted() .AND. left(_FIELD->FIELD1,1) == "9" } )

                        TEST->DbCreateOrder( "ORDER2",, "UPPER(FIELD1)", {|| Upper( _FIELD->FIELD1 ) }, FALSE )

                        TEST->DbAppend()

                        TEST->FIELD1 := "3"

                        TEST->DbCommit()     

            ENDIF

            TEST->DbCloseArea()

           

            DbUseArea( TRUE, "DBFCDX", cFileName, "TEST2", lShareMode, FALSE )

            TEST2->DbAppend()

            TEST2->FIELD1            := "4"

            ? " OK bevor Commit"

            TEST2->DbCommit() 

            ? "Commit not working "          

            TEST2->DbCloseArea()

           

            oDBServer                    := VO.DbServer{ cFileName, lShareMode, FALSE, "DBFCDX"  }

            oDBServer:Append()

            oDBServer:FieldPut( #FIELD1, "7" )

            ? "OK bevor Commit"

            //oDBServer:Commit()

            ? "Commit not working"

            oDBServer:Close()

            oDBServer                    := NULL_OBJECT

            
FUNCTION TestWolfgang() AS VOID
           LOCAL cPath                             AS STRING

            LOCAL cFileName                      AS STRING

            LOCAL aStruct               AS ARRAY

            LOCAL nI                                  AS DWORD

           

            cPath                                        := "C:\Temp"

            cFileName                                := cPath + "\" + "Test.DBF"

            aStruct                                     := { { "FIELD1", "C", 10, 0 } }

            DbCreate( cFileName, aStruct, "DBFCDX", TRUE, "ORDERDBF",, FALSE )

            ORDERDBF->DbSetOrderCondition( "! DELETED()", {|| ! Deleted() } )

            ORDERDBF->DbCreateOrder( "ORDER1",, "UPPER(FIELD1)", {|| Upper( _FIELD->FIELD1 ) }, FALSE )

            ORDERDBF->DbCloseArea()

            DbUseArea( TRUE, "DBFCDX", cFileName, "ORDERDBF", TRUE, FALSE )

           

            FOR nI := 1 UPTO 120000
                            IF nI % 100 == 0
                        ? nI
                        ENDIF

                        ORDERDBF->DbAppend()

                        ORDERDBF->FIELD1     := NTrim( nI )

            NEXT

            ORDERDBF->DbCloseArea()
            
            
FUNCTION TestEncoding AS VOID
    LOCAL cValue AS STRING

    RddSetDefault("DBFNTX")
    Console.OutputEncoding := System.Text.UnicodeEncoding{}
    DbUseArea(TRUE,NIL,"c:\download\gid.DBF")
    DbGoBottom()
    cValue := FIeldGetSym(#AArdGoed)
    ? cValue
    DbCloseArea()
    
FUNCTION TestXppFieldGetFieldPut() AS VOID
    LOCAL aStruct := {{"NAAM","C",10,0}}
    RddSetDefault("DBFNTX")
    RuntimeState.Dialect := XSHarpDIalect.VO
    DbCreate("Klant",aStruct)
    DbUseArea(TRUE,,"KLANT","KLANT",FALSE,FALSE)
    //DbAppend()
    FieldPut("a", "Robert")
    ? FieldPos("NAAM")
    ? FieldGet(FieldPos("NAAM"))
    ? FieldGet(0)
    ? FieldPut(0, "abc")
    ? FieldPut(FieldPos("def"),"abc")
    ? FieldGet(FieldPos("NAAM"))
    ? Eval(FieldBlock("NAAM"))
    DbCloseARea()
RETURN    

FUNCTION DumpRateCdx() AS VOID
    RddSetDefault("DBFCDX")
    DBUSEAREA(TRUE, "DBFCDX", "c:\test\Rate.DBF", "Rate", FALSE)
//    DbGoto(360939)
//    ? FieldGetSym(#MainRecNo)
//    WAIT
    DbSetIndex("c:\test\RateVN.CDX")
    FOR VAR i := 1 TO 1 //(INT) DbOrderInfo(DBOI_ORDERCOUNT)
        DbSetOrder(i)
        ? OrdName()
        DbOrderInfo(DBOI_USER+42)
    NEXT
    DbCloseArea()
    DBUSEAREA(TRUE, "DBFCDX", "c:\test\Rate.DBF", "Rate", FALSE)      
    DbSetIndex("c:\test\RateX#.CDX")
    FOR VAR i := 1 TO 1 //(INT) DbOrderInfo(DBOI_ORDERCOUNT)
        DbSetOrder(i)
        ? OrdName()
        DbOrderInfo(DBOI_USER+42)
    NEXT
    DbCloseArea()    
    

FUNCTION TestRateCdx() AS VOID
    VAR f := Seconds()
    VAR f2 := Seconds()
    LOCAL cFile := "C:\Test\RateX#" AS STRING
    SET(_SET_OPTIMIZE, FALSE)
    RddSetDefault("DBFCDX")
	 FErase(cFile+".CDX")
    ? Time()               
    ? DELETED()             
    ? Version()
    DbUseArea(TRUE, "DBFCDX", "c:\test\Rate.DBF", "Rate", FALSE)
    ? LASTREC(), "Records"
    SETORDERCONDITION("Deleted() == .F.   .And. Recurse == .F.   .And. Undone == .F.")
    OrdCreate(cFile, "RateMain", "Str( MainRecno, 7 ) + '~' + DToS( ScaDov )") 
	 SHowInfo(f2)    
    f2 := Seconds()
    
    SETORDERCONDITION("Deleted() == .F.   .And. Recurse == .F.   .And. Undone == .F.   .ANd. TipoC == 'U'")
    OrdCreate(cFile, "RateUsu", "Str( MainRecno, 7 ) + '~' + DToS( ScaDov )")
	 SHowInfo(f2)    
    f2 := Seconds()
    
    SETORDERCONDITION("Deleted() == .F.   .And. Recurse == .F.   .And. Undone == .F.")
    OrdCreate(cFile, "RatePrev", "Str( PrevRecno, 7 ) + '~' + Mode + '~' + DToS( ScaDov )")
	 SHowInfo(f2)    
    f2 := Seconds()

    SETORDERCONDITION("Deleted() == .F.")
    OrdCreate(cFile, "RatePNor", "Str( PrevRecno, 7 ) + '~' + Mode + '~' + DToS( ScaDov )")
	 SHowInfo(f2)    
    f2 := Seconds()

    SETORDERCONDITION("Deleted() == .F.") 
    OrdCreate(cFile, "RateMNor", "Str( MainRecno, 7 ) + '~' + Mode + '~' + DToS( ScaDov )")
	 SHowInfo(f2)    
    f2 := Seconds()

    SETORDERCONDITION("Deleted() == .F.   .And. Recurse == .F.") 
    OrdCreate(cFile, "RateScop", "Str( MainRecno, 7 ) + '~' + Str( PrevRecno, 7 ) + '~' + Mode + '~' + DToS( ScaDov )")
	 SHowInfo(f2)    
    f2 := Seconds()

    SetOrderCondition("Deleted() == .F.   .And. Recurse == .F.   .And. Undone == .T.")
    OrdCreate(cFile, "RateUndo", "Str( PrevRecno, 7 ) + '~' + Mode + '~' + DToS( ScaDov )")
	 SHowInfo(f2)    
    f2 := Seconds()

    SETORDERCONDITION("Deleted() == .F.")
    OrdCreate(cFile, "RateTemp", "PrevRecno")
	 SHowInfo(f2)    
    f2 := Seconds()

    SETORDERCONDITION("Deleted() == .F.")
    OrdCreate(cFile, "RateData", "Str( MainRecno, 7 ) + '~' + DToS( ScaDov )")
	 SHowInfo(f2)    
    f2 := Seconds()

    SETORDERCONDITION("Deleted() == .F.")
    OrdCreate(cFile, "RateScoA", "Str( MainRecno, 7 ) + '~' + Str( PrevRecno, 7 ) + '~' + Mode")
	 SHowInfo(f2)    
    f2 := Seconds()
    DbCloseArea()
    ? Time()
    ? Seconds() - f
      
WAIT
RETURN NIL


FUNCTION SETORDERCONDITION(cFor)
LOCAL cbFor :=&("{|| "+cFor+" }")             
RETURN OrdCondSet(cFor, cbFor, TRUE) 


FUNCTION OrderCount
RETURN DbOrderInfo(DBOI_ORDERCOUNT)




FUNCTION SHowInfo(f2)
? Time(), Seconds() - f2,OrdKeyCount()  
? "NAME", OrdName(OrderCount())
? "KEY", ORDKEY(OrderCount())
? "FOR", ORDFOR(OrderCount())                  
? 
RETURN NIL




 
FUNCTION TestProj() AS VOID
    LOCAL i AS DWORD
    LOCAL uValue AS USUAL

    RddSetDefault("DBFVFP")
    DbUseArea(TRUE, "DBFVFP", "c:\cavo28SP3\Samples\Email\EMAIL.DBF", "Email", TRUE)
    
    ? RLock("1,2","Email")
    ? DbInfo(DBI_GETLOCKARRAY)
    DO WHILE ! EOF()
        ? "Record", Recno()
        FOR  i := 1 TO FCount()
            uValue := FieldGet(i)
            IF IsString(uValue)
                VAR sValue := (STRING) uValue
                uValue := sValue:TrimEnd()
            ENDIF
            ? i, FieldName(i), uValue
            
        NEXT
        DbSkip(1)
    ENDDO
    DbCloseArea()
    RETURN

FUNCTION TestCdxLock() AS VOID
LOCAL aFields AS ARRAY
LOCAL cFile AS STRING
//SET(Set.FOXLOCK, TRUE)
RddSetDefault ( "DBFCDX" )
cFile := "C:\Test\TestFpt"
aFields := { { "ID" , "N" , 2 , 0 },{ "MEMO" , "M" , 10 , 0 }}
DbCreate(cFile, aFields)
 VoDbUseArea(TRUE, "DBFCDX",cFile,"test" ,FALSE,FALSE)
OrdCreate("C:\Test\TestFpt","Test","ID")
DbAppend()
FieldPut(1, 1)
FieldPut(2, Replicate("X", 20))
DbCloseArea()
VoDbUseArea(TRUE, "DBFCDX",cFile,"test" ,TRUE,FALSE)
VoDbGoTop()
RLock()
FieldPut(1, 2)
FieldPut(2, Replicate("X", 24))
DbUnlock()
DbCloseArea()
VoDbUseArea(TRUE, "DBFCDX",cFile,"test" ,TRUE,FALSE)
VoDbGoTop()
RLock()
FieldPut(1, 3)
FieldPut(2, Replicate("X", 64))
DbUnlock()
DbCloseArea()
RETURN
    
/*
FUNCTION TestXppCollations() AS VOID
    SetAnsi(TRUE)
    DumpTable("A")
    SetAnsi(FALSE)
    DumpTable("O")
RETURN
*/
/*    
FUNCTION DumpTable(cChar)
LOCAL i,j
LOCAL cTable
LOCAL cResult
LOCAL aCollation 
DbCreate("Test"+cChar,{{"NUM","N",3,0},{"CHAR","C",10,0}},"DBFNTX")
DbUseArea(.T., "DBFNTX", "Test"+cChar)
FOR i = 0 TO 255
	DbAppend()
	FieldPut(1, i)
	FieldPut(2, Repl(CHR(I), 10))
NEXT
DbCommit()
DbCLoseArea()
FOR i := -1 TO 16
	aCollation := SetCollationTable(i)
	cTable := ""
	cResult := ""
	FOR j := 1 TO 256
		cTable += Chr(aCollation[j])
		cResult  += Str(j,3) + "=" +repl(chr(j),10)+str(aCollation[j],4,0)+chr(13)+chr(10)
	NEXT
	IF cChar == "A"
		MemoWrit("Ansi\Table"+ltrim(str(i)), cTable)
		MemoWrit("Ansi\List"+ltrim(str(i)), cResult)
	ELSE
		MemoWrit("Oem\Table"+ltrim(str(i)), cTable)
		MemoWrit("Oem\List"+ltrim(str(i)), cResult)
	ENDIF
NEXT
RETURN .T.
*/
FUNCTION TestNestedMacro() AS VOID
    LOCAL cMacro AS STRING
    LOCAL cb AS CODEBLOCK
    LOCAL cb2 AS CODEBLOCK
    LOCAL u AS USUAL
    cMacro := "{|e| iif(e, {|| TRUE}, {|| false} ) }"
    cb := &(cMacro)
    u := cb
    ? cMacro, valtype(u), u
    cb2 := EVal(cb, TRUE)
    u := cb2
    ? cMacro, valtype(u), u
    u := Eval(cb2)
    ? valtype(u), u

    cb2 := EVal(cb, False)
    u := cb2
    ? cMacro, valtype(u), u
    u := Eval(cb2)
    ? valtype(u), u

    cMacro := "{|e| '{|a,b,c|TRUE}' }"
    cb := &(cMacro)
    u := cb
    ? cMacro, valtype(u), u
    u := Eval(cb)
    ? cMacro, valtype(u), u
    cMacro := "{|e| iif(e, {|| TRUE}, '{|| FALSE}') }"
    cb := &(cMacro)
    u := cb
    ? valtype(u), u
    u := Eval(cb, FALSE)
    ? cMacro, valtype(u), u
    cMacro := "{|e| '|||||||' }"
    cb := &(cMacro)
    u := cb
    ? valtype(u), u
    u := Eval(cb, FALSE)
    ? cMacro, valtype(u), u
    

RETURN
    
    

function TestCreate() AS VOID
    LOCAL cDbf AS STRING
    SetAnsi(TRUE)
    RddSetDefault("DBFNTX")
    RuntimeState.Dialect := XSHarpDialect.XPP
    cDbf := "C:\Test\testxpp.dbf"
    DbCreate(cDbf, {{"FIELD1","C",10,0}})
    
    RuntimeState.Dialect := XSHarpDialect.VO
    cDbf := "C:\Test\testvo.dbf"
    DbCreate(cDbf, {{"FIELD1","C",10,0}})
    SetAnsi(FALSE)
    RddSetDefault("DBFNTX")
    RuntimeState.Dialect := XSHarpDialect.XPP
    cDbf := "C:\Test\testxppoem.dbf"
    DbCreate(cDbf, {{"FIELD1","C",10,0}})
    
    RuntimeState.Dialect := XSHarpDialect.VO
    cDbf := "C:\Test\testvooem.dbf"
    DbCreate(cDbf, {{"FIELD1","C",10,0}})
    RETURN
    
function Val(cString as STRING) AS LONG
    return 42

function Val(nString as LONG) AS LONG
    return 4242

function Val(dDate as DATE) AS LONG
    return 424242

Function GetSignature( m as MemberInfo) as STRING
    local name as string
    name :=m:DeclaringType:Name+"."+m:Name 
    IF m is ConstructorInfo
        LOCAL ci := (ConstructorInfo) m as ConstructorInfo
        var pars := ""
        FOREACH par AS ParameterInfo in ci:GetParameters()
            if Pars:Length > 0
                Pars += ","
            ENDIF
            pars += par:ParameterType:Name
        NEXT
        name +="{"+pars+"}"
    ELSEif m is MethodInfo 
        LOCAL mi := (MethodInfo) m as MethodInfo
        var pars := ""
        FOREACH par AS ParameterInfo in mi:GetParameters()
            if Pars:Length > 0
                Pars += ","
            ENDIF
            pars += par:ParameterType:Name
        NEXT
        name +="("+pars+")"
    elseif m is PropertyInfo 
        LOCAL pi := (PropertyInfo) m as PropertyInfo
        var pars := ""
        FOREACH par AS ParameterInfo in pi:GetGetMethod():GetParameters()
            if Pars:Length > 0
                Pars += ","
            ENDIF
            pars += par:ParameterType:Name
        NEXT
        name +="["+pars+"]"
    ENDIF
    RETURN name
        

function Resolver(m1 as MemberInfo, m2 as MemberInfo, argtypes as System.Type[]) as LONG
    ? argTypes:Length,": "
    foreach var o in argTypes
        ?? o:FullName,","
    next
    
    ? "Ambiguous 1", GetSignature(m1)
    ? "Ambiguous 2", GetSignature(m2)
    var result := 1
    ? "Choosing",result
    return result

function TestOverloads() as VOID
    SetMacroDuplicatesResolver(Resolver)
    ? Eval(MCompile("{|u| val(u)"),123):ToString()
    RETURN

function testScopes() as Void
    local cDbf as STRING
    cDbf := "C:\Test\test.dbf"
    DbCreate(cDbf, {{"FIELD1","C",10,0}})
    DbUseArea(TRUE, "DBFNTX",cDbf)
    FOR var i := 1 to 10
        DbAppend()
        FieldPut(1, "AAA")
        DbAppend()
        FieldPut(1, "BBB")
    NEXT
    DbAppend()
    FieldPut(1, "CCC")
    DbCommit()
    DbcreateIndex("test","FIELD1")
    DbSetScope(SCOPE_BOTH, "CCC")
        ? Recno(), FieldGet(1)
    DO WHILE TEST->FIELD1 = "CCC"
        ? Recno(), FieldGet(1)
        DbSkip(1)
    ENDDO
    ? "EOF", FieldGet(1)
    DbCloseArea()
    RETURN
        

function TestCorrupt3 as void
        DbUseArea(TRUE,"DBFNTX","c:\download\corrupt\CCIVoM.Lgi")  
        RETURN

function TestTCC as void
        local cString as string
        cString := "abcdefg"
        ? cString[1]
        wait
        DbUseArea(TRUE,"DBFNTX","c:\temp\tcc.DBF")
        DbSetIndex("c:\temp\tcc1.ntx")
        DbOrderInfo(DBOI_USER+42)
        wait
        RETURN

Function TestCorrupt2() as VOID
            LOCAL cDBF AS STRING
            LOCAL oDBF1 AS Vo.DbServer
            LOCAL oDBF2 AS Vo.DbServer

            cDbf := "c:\temp\testVO" 
            FErase(cDbf+ ".cdx")
            FErase(cDbf+ ".dbf")

            RddSetDefault("DBFCDX")
            DbCreate(cDbf, {{"CFIELD","C",10,0}})
            DbUseArea(TRUE,  , cDbf)
            DbCreateOrder("CFIELD", cDbf, "CFIELD", &( "{|| CFIELD}" ),)

            DbAppend()
            FieldPut(1,"AAAA")
            DbCommit()
            DbAppend()
            FieldPut(1,"BBBB")
            DbCommit()
            DbCloseArea()
                        
            ? "TestDB"  
            oDBF1  := Vo.DbServer{ cDbf + ".dbf", TRUE, FALSE, "DBFCDX" }
            oDBF2  := Vo.DbServer{ cDbf + ".dbf", TRUE, FALSE, "DBFCDX" } 
            //odbf2:SetOrder( 0 ) // without order no missing record during while
            
            oDBF1:Append()
            oDBF1:FieldPut( 1, "CCCC" )  
            oDBF1:Commit()
            oDBF1:Close()
            oDBF1  := null_object
            
            ? "DBF2"   
            oDBF2:GoTop()
            WHILE ! oDBF2:EoF
                        ? oDBF2:FieldGet( 1 ) 
                        oDBF2:Skip()
            ENDDO
            //? oDBF2:FieldGet( 1 )             // record found after EoF
            oDBF2:Close()
            
            ? ""
            ? "DBF2 New"  
            oDBF2  := Vo.DbServer{ cDbf + ".dbf", TRUE, FALSE, "DBFCDX" } 
            oDBF2:GoTop()
            WHILE ! oDBF2:EoF
                        ? oDBF2:FieldGet( 1 ) 
                        oDBF2:Skip()
            ENDDO
            oDBF2:Close()
            
            RETURN

    

FUNCTION TestCorrupt1() AS VOID
	LOCAL cDbf AS STRING
	cDbf := "c:\test\testVO"
	RddSetDefault("DBFCDX")
	DbCreate(cDbf, {{"CFIELD","C",10,0},{"MFIELD","M",10,0}})
	FErase(cDbf+ ".cdx")
	DbUseArea(TRUE,  , cDbf)
	DbCreateIndex(cDbf, "CFIELD")
	DbAppend()
	FieldPut(1,"asdf")
	FieldPut(2,"efgh")
	DbAppend()
	FieldPut(1,"ADJKSHA")
	FieldPut(2,"YUWED")
	DbCloseArea()
	
	DbUseArea(TRUE, , cDbf , , TRUE)
	RLock()
	FieldPut(1 , "aaaaa")
	? "Records in dbf", RecCount()
	WAIT "Now append a record from another app and press enter"
	DbCloseArea()
	
	DbUseArea(TRUE, , cDbf , , TRUE)
	? "Records in dbf", RecCount()
	DbCloseArea()
RETURN

FUNCTION TestRel() AS VOID
	LOCAL cPath AS STRING
	LOCAL cChild,cParent AS STRING
	cPath := "c:\test\"
	cChild := cPath + "child"
	cParent := cPath + "parent"

	RddSetDefault("DBFCDX")

	FErase(cChild+ ".cdx")
	FErase(cParent + ".cdx")
	? DbCreate(cParent, {{"RELFLD", "N" , 10 ,0}})
	? DbCreate(cChild,  {{"RELFLD", "N" , 10 ,0}})
	
	DbUseArea(TRUE , , cChild , "child")
	DbCreateIndex(cChild , "RELFLD")
	DbAppend()
	FieldPut(1,1)
	DbAppend()
	FieldPut(1,3)
	DbAppend()
	FieldPut(1,2)
	
	DbUseArea(TRUE , , cParent , "parent")
	DbCreateIndex(cParent , "RELFLD")
	DbAppend()
	FieldPut(1,1)
	DbAppend()
	FieldPut(1,2)
	DbAppend()
	FieldPut(1,3)
	
	? parent -> DbSetRelation("child" , {|| Parent->RELFLD})

	parent -> DbGoTop()
	? parent -> FieldGet(1) , child -> FieldGet(1) // 1,1 
	parent -> DbGoBottom()
	? parent -> FieldGet(1) , child -> FieldGet(1) // 3,1 error, should be 3,3
	parent -> DbSkip(-1)
	? parent -> FieldGet(1) , child -> FieldGet(1) // 2,1 error, should be 2,2
	
	child->DbCloseArea()
	parent->DbCloseArea()
RETURN
//CLASS MyVfpClass INHERIT XSharp.Vfp.Custom
//    PROPERTY Test AS USUAL GET _GetProperty("Test") SET _SetProperty("Test", VALUE)
//    METHOD Init(a,b,c) CLIPPER
//        ? a,b,c
//        RETURN TRUE
//    CONSTRUCTOR() CLIPPER
//       SUPER(_Args())
//        SELF:Test := 1
//END CLASS

//FUNCTION TestVfpClass AS VOID
////    local oC as MyVfpClass
////    oC := MyVfpClass{1,2,3}
////    ? oC:Name
//    LOCAL oColl AS Collection
//    oColl := Collection{}
//    oColl:AddObject("item a", "a")
//    oColl:AddObject("item A", "A")
//    oColl:AddObject("item B", "B")
//    oColl:AddObject("item b", "b")
//    oColl:AddObject("item C", "C","A")
//    //oColl:AddObject(1)
////    oColl:AddObject(2)
////    oColl:AddObject(3)
////    oColl:AddObject(4)
////    
////    oColl:AddObject(100,,2)
////    oColl:AddObject(200,,,3)
////    ? oColl:Count
////    ? oColl:Item(1)
////    ? oColl:Item(2)
//    oColl:KeySort := 3
//    FOREACH VAR o IN oColl
//        ? o, oCOll:GetKey(o)
//    NEXT
////    ? oColl:Item("a")
////    ? oColl:Item("A")
////    ? oColl:Item("b")
//    RETURN

FUNCTION NotifyRDDOperations(oRDD AS XSharp.RDD.IRdd, oEvent AS XSharp.DbNotifyEventArgs) AS VOID
    IF oRDD != NULL
        ? oRDD:Alias, oEvent:Type:ToString(), oEvent:Data
    ELSE
        ? "(no area)",oEvent:Type:ToString(), oEvent:Data
    ENDIF
    RETURN

CLASS Notifier IMPLEMENTS IDbnotify
     METHOD Notify(oRDD AS XSharp.RDD.IRdd, oEvent AS XSharp.DbNotifyEventArgs) AS VOID
        ? oRDD:Alias, oEvent:Type:ToString(), oEvent:Data
        RETURN
END CLASS

#define USECLASS
FUNCTION TestNotifications AS VOID
    LOCAL cDbf1  AS STRING
	cDbf1 := "C:\test\test"
    #ifdef USECLASS
        LOCAL oNot AS Notifier
        oNot := Notifier{}
        DbRegisterClient(oNot)
    #else
        CoreDb.Notify += NotifyRDDOperations
    #endif
    ? DbCreate(cDbf1, {{"FLD1" , "C" , 10 , 0} })
    ? DbUseArea(TRUE,"DBFNTX", cDbf1, "TEST",FALSE,FALSE)
    ? DbCreateIndex("test","FLD1")
    ? DbAppend()
    ? FieldPutSym("FLD1","12345")
    ? DbDelete()
    ? DbRecall()
    ? DbGoTop()
    ? DbSkip(1)
    ? DbGoBottom()
    ? DbReindex()
    ? DbPack()
    ? DbZap()
    ? DbCloseArea()
    #ifdef USECLASS
        DbUnRegisterClient(oNot)
    #else
        CoreDb.Notify -= NotifyRDDOperations
    #endif
    RETURN

FUNCTION testVfpFile() AS VOID
LOCAL cDbf AS STRING
    //? ICase(False,"a",False,"b","c")
	cDbf := "c:\download\vfp\wwbusinessobjects.dbf"
	DbUseArea(TRUE,"DBFVFP",cDbf,"WWBusinessObjects")
	? FieldGet(1)
	DbCloseArea()
RETURN


FUNCTION TestFilter() AS VOID
    LOCAL cDbf1  AS STRING
	cDbf1 := "C:\test\test"
	DbCreate(cDbf1, {{"FLD1" , "C" , 10 , 0} })
    DbUseArea(TRUE,"DBFCDX", cDbf1, "TEST",TRUE)
    VoDb.SetFilter(NULL, "FLD1='C'")
    ? DbFilter()
    WAIT
    DbSetFilter(,TRUE)
    ? DbSetFilter("FLD1='C'")
    ? DbSetFilter(&("{||FLD1='C'}"))
    ? DbSetFilter({||_FIELD->FLD1 = 'C'})
    RETURN

FUNCTION testDbfNtxEmpty() AS VOID
    LOCAL cDbf1  AS STRING
	cDbf1 := "C:\test\test"
	DbCreate(cDbf1, {{"FLD1" , "C" , 10 , 0} })
    DbUseArea(TRUE,"DBFNTX", cDbf1, "TEST",TRUE)
    DbCreateIndex("Test","FLD1")
    ? Eof()
    DbCloseArea()
    DbUseArea(TRUE,"DBFNTX", cDbf1, "TEST",TRUE)
    DbSetIndex("test")
    ? Eof()
    DbGoTop()
    ? Eof()
    RETURN



FUNCTION testAliasWhileCreate() AS VOID
    LOCAL cDbf1, cDbf2  AS STRING
	cDbf1 := "C:\test\testA"
	cDbf2 := "C:\test\test"
	DbCreate(cDbf1, {{"FLD1" , "C" , 10 , 0} })
    DbUseArea(TRUE,"DBFNTX", cDbf1, "TEST",TRUE)
    DbUseArea(TRUE,"DBFNTX", cDbf1, "TEST_1",TRUE)
    DbUseArea(TRUE,"DBFNTX", cDbf1, "TEST_2",TRUE)
    DbUseArea(TRUE,"DBFNTX", cDbf1, "TEST_3",TRUE)
	DbCreate(cDbf2, {{"FLD1" , "C" , 10 , 0} })
    DbUseArea(TRUE,"DBFNTX", cDbf2,"TEST2")
    DbCloseAll()



FUNCTION testadsmemo AS VOID       
LOCAL cDbf AS STRING
	cDbf := "C:\test\memodbf"
	FErase(cDbf + ".cdx")
	FErase(cDbf + ".fpt")
	FErase(cDbf + ".dbf")
	
	RddSetDefault("DBFCDX")
    RDDINFO(SET.MEMOBLOCKSIZE, 512)

	DbCreate(cDbf, {{"FLD1" , "C" , 10 , 0} , {"FLDM" , "M" , 10 , 0}})
	DbUseArea(,,cDbf)
	DbAppend()
	FieldPut(1, "abc")
	DbAppend()
	FieldPut(2, "this is a somewhat long text")
	DbCloseArea()
	

	RddSetDefault("AXDBFCDX")
	? XSharp.RDD.Functions.AX_SetServerType(FALSE,FALSE,TRUE)
	? DbUseArea(,,cDbf)
	? FieldGet(2)
	DbGoBottom()
	? FieldGet(2)
	? DbCloseArea()
RETURN


FUNCTION TestAdvantageSeek() AS VOID
	LOCAL cDbf AS STRING
	LOCAL cValue AS STRING

	cDbf := "C:\test\MyDbf"
	cValue := "abc"

	FErase(cDbf + ".dbf")
	FErase(cDbf + ".cdx")
	? DbCreate(cDbf , {{"TEST","C",10,0}})
	? DbUseArea(,"DBFCDX",cDbf)
	DbAppend()
	FieldPut(1,"abc")
	DbGoTop()
	? DbCreateOrder("MYORDER", cDbf , "TEST")
	? DbCloseArea()
	

	RddSetDefault("AXDBFCDX")
	? XSharp.RDD.Functions.AX_SetServerType(FALSE,FALSE,TRUE)
	? DbUseArea(,,cDbf)
	OrdSetFocus("MYORDER")
	TRY
        ? "OrdName", OrdName()
        ? "OrdKey", DbOrderInfo(DBOI_EXPRESSION)
        DbGoTop()
        ? "Key", DbOrderInfo(DBOI_KEYVAL)
		? "DBSeek() returns:"
		? DbSeek(padr(cValue,10))
	CATCH e AS Exception
		? "Exception occured!"
		?
		? "Message of exception:"
		?
		? e:Message
		WAIT
		?
		? "Exception ToString():"
		?
		? e:ToString()
	END TRY
	? DbCloseArea()
RETURN

FUNCTION TestTimeStamp() AS VOID
	LOCAL c AS STRING
	c := "c:\test\mytest.dbf"
	IF .NOT. File.Exists(c)
		DbCreate(c,{{"TEST","C",10,0}})
		DbUseArea(,,c)
		DbAppend()
		DbCloseArea()
		Thread.Sleep(1500)
	END IF
	? FileInfo{c}:LastWriteTime
	DbUseArea(,,c)
    DbGoTop()
	//DbCloseArea()
	? FileInfo{c}:LastWriteTime // different to above
RETURN

FUNCTION TestSeek() AS VOID
    RddSetDefault("DBFNTX")
    ? DbUseArea(TRUE,,"c:\Descartes\dbfseek\relatie.dbf")
    ? DbSetIndex("c:\Descartes\dbfseek\RELATIE1.ntx")
    ? DbSeek("BAV01")
    ? Found()
    ? DbCloseArea()
    RddSetDefault("DBFCDX")
    ? DbUseArea(TRUE,,"c:\Descartes\dbfseek\relatie.dbf")
    ? DbCreateIndex("c:\Descartes\dbfseek\RELATIE1.cdx","RELATIENR")
    ? DbSeek("BAV01")
    ? Found()
    ? DbCloseArea()
    RETURN

FUNCTION TestDbfEncoding() AS VOID
	LOCAL c AS STRING
	LOCAL cDbf AS STRING
	cDbf := "C:\test\strasse"
	c := "STRAßE"
	? c //"STRAßE", ok
	DbCreate(cDBF,{{c,"C",10,0} ,{"AÖÄÜ","C",10,0}})
	DbUseArea(,,cDBF)
	? FieldName(1) // "STRA?E"
	? FieldName(2) // A???
    DbCreateIndex("STRASSE", "STRAßE")
	DbCloseArea()
RETURN

FUNCTION TestDateInc() AS VOID
  LOCAL u AS USUAL
  LOCAL d AS DATE

  d := Today()
  ? ++ d // ok
  ? d ++ // ok
  ? d -- // ok

  u := Today()
  ? u 
  ? ++ u // exception
  ? u ++ // exception
  ? u -- // exception
  ? -- u // exception
  u := DateTime.Now
  ? u 
  ? ++ u // exception
  ? u ++ // exception
  ? u -- // exception
  ? -- u // exception

RETURN
FUNCTION TestEmptyDbf AS VOID
    DbCreate("Test",{{"VELD","C",10,0}},"DBFVFP")
    DbuseArea(TRUE,"DBFVFP","test")
    DbCreateOrder("VELD","TEST","VELD")
    DbCloseArea()
    DbuseArea(TRUE,"DBFVFP","test")
    ? Len(FieldGetSym("veld"))
    DbCloseArea()
    WAIT
    RETURN
FUNCTION TestAnotherOrdScope() AS VOID
	LOCAL cDbf AS STRING
	cDbf := "c:\test\mynewtest"
	
	RddSetDefault("DBFCDX")
	DbCreate(cDbf , {{"LAST" , "C" , 10,0}})
	
	DbUseArea(,,cDbf)
	DbCreateIndex(cDbf,"Upper(LAST)")
	
	LOCAL aValues AS ARRAY
    FOR VAR test := 1 TO 1000
	aValues := {"A", "DD", "BBB", "CC", "EEE", "DDD", "AA", "CC", "BBB", "EEE1"}
	FOR LOCAL n := 1 AS DWORD UPTO ALen(aValues)
		DbAppend()
		FieldPut(1,aValues[n])
	NEXT
    NEXT

	//? OrdScope(TOPSCOPE, "A")
	//? OrdScope(BOTTOMSCOPE, "C")
    DbOrderInfo(DBOI_USER+42)

	// following is OK
	DbGoTop()
	DO WHILE .NOT. Eof()
		? RecNo()
		DbSkip()
	END DO
	? 
	// this never ends, get's stuck at record 11 (records are 10 actually)
	DO WHILE .NOT. Bof()
		? RecNo()
		DbSkip(-1)
	END DO
	? 
	DbCloseArea()
RETURN

FUNCTION TestFileGarbage() AS VOID
LOCAL c AS STRING

c := "D:\t?est\FileDoesnotExist.txt"  


? File ( c ) 

RETURN

FUNCTION TestPackNtx() AS VOID
	
	LOCAL cDbf AS STRING
    LOCAL aArray AS ARRAY
    aArray := ARRAY{10}
	cDbf := "C:\test\dbfpack"
	RddSetDefault("DBFNTX")
	DbCreate(cDbf , {{"FLD" , "C" , 10 , 1}})
	DbUseArea(,, cDbf)
	DbAppend()
	FieldPut(1, "a")
	DbDelete()
	DbAppend()
	FieldPut(1, "b")
	DbDelete()
	DbCloseArea()
	DbUseArea(, , cDbf ,, FALSE , FALSE)
	DbPack()
	DbCloseArea()

	DbUseArea(, , cDbf ,, FALSE , FALSE)
	? "records after pack()", RecCount() // 2
	DbCloseArea()
RETURN

FUNCTION TestZapNtx() AS VOID
	
	LOCAL cDbf AS STRING
    SetAnsi(FALSE)
	cDbf := "C:\test\dbfzap"
	RddSetDefault("DBFNTX")
	DbCreate(cDbf , {{"FLD" , "C" , 10 , 1}})
	DbUseArea(,, cDbf)
	DbAppend()
	FieldPut(1, "a")
	DbDelete()
	DbAppend()
	FieldPut(1, "b")
	DbDelete()
	DbCloseArea()
	
	DbUseArea(, , cDbf ,, FALSE , FALSE)
	? DbZap()
	DbCloseArea()

	DbUseArea(, , cDbf ,, FALSE , FALSE)
	? RecCount() // 0, ok
	DBAPPEND()
	FIELDPUT(1, "aaa")
	DBCLOSEAREA()

	DbCloseArea()
RETURN

FUNCTION TestNullDate() AS VOID
    LOCAL aStruct AS ARRAY
    aStruct := {{"Date","D",8,0}}
    DbCreate("test.dbf", aStruct)
    DbUseArea(,,"test.dbf")
    DbAppend()
    FieldPut(1, CTOD(""))
    ? FieldGet(1)
    DbAppend()
    FieldPut(1, NULL_DATE)
    ? FieldGet(1)
    DbAppend()
    FieldPut(1, DateTime.MinValue)
    ? FieldGet(1)
    DbCloseArea()
    RETURN
FUNCTION TestZap3() AS VOID 	
LOCAL cDBF, cPfad, cDriver, cIndex AS STRING 
LOCAL aFields, aValues AS ARRAY 
LOCAL i AS DWORD

LOCAL lShowNIL AS LOGIC 

	// -------------
	lShowNIL := FALSE
	// ------------- 
 
    cDriver := RddSetDefault ( "DBFCDX" ) 
    
 
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	FErase ( cIndex + IndexExt() )
	

	aFields := { { "LAST" , "C" , 20 , 0 } } 

	aValues := { "a1" , "o5" , "g2", "g1" }	
	
		
    // -------------------
	
	? DbCreate( cDBF , AFields)
	? DbUseArea( ,,cDBF , , TRUE )	// open shared 	
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] ) 
		
		IF InList ( Upper ( aValues [i] ) , "G1" ) 
			? "DBDelete()" , DbDelete()
			
		ENDIF 	
						
	NEXT 
	
	
	? DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper (_FIELD->LAST) } )

	DbCloseAll()
	
    ?
   
	? DbUseArea( ,,cDBF , , FALSE )	 // open not shared
	? DbSetIndex ( cIndex ) 
	? DbSetOrder ( 1 )
		
	?
				
	? OrdKeyCount()  
	? RecCount() 
	? "DBZap()" , DbZap() 

	IF lShowNIL
		? OrdKeyCount()  //  <--------- shows NIL instead of 0
		? RecCount() 
	ENDIF 
   	
    ?
	? "DBGoTop()" , DbGoTop()  // <--------- causes a ArgumentNullException if lShowNIL is set to false 
	?
	? "eof()" , Eof() 
	? OrdKeyCount(), RecCount()
	?
	DO WHILE ! Eof()
		
		? FieldGet ( 1 )
		
		DbSkip ( 1) 
		
		
	ENDDO 
		
	
	RddSetDefault ( cDriver )
		
	RETURN	

FUNCTION TestZap2() AS VOID               

LOCAL cDBF, cPfad, cDriver, cIndex AS STRING

LOCAL aFields, aValues AS ARRAY

LOCAL i AS DWORD

 

 

    cDriver := RddSetDefault ( "DBFCDX" )

    

 

                cDBF := cPfad + "Foo"

                cIndex := cPfad + "Foox"

               

                FErase ( cIndex + IndexExt() )

               

 

                aFields := { { "LAST" , "C" , 20 , 0 } }

 

                aValues := { "a1" , "o5" , "g2", "g1" }      

               

                              

    // -------------------

               

                ? DbCreate( cDBF , AFields)

                ? DbUseArea( ,,cDBF , , TRUE )  // open shared               

               

                FOR i := 1 UPTO ALen ( aValues )

                               DbAppend()

                               FieldPut ( 1 , aValues [ i ] )

                              

                               IF InList ( Upper ( aValues [i] ) , "G1" )

                                               ? "DBDelete()" , DbDelete()

                                              

                               ENDIF  

                                                                                             

                NEXT

               

               

                ? DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )

 

                DbCloseAll()

               

    ?

  

                ? DbUseArea( ,,cDBF , , FALSE ) // open not shared

                ? DbSetIndex ( cIndex )

                              

                ?

                // Note: the OrdKeyCount() call below seems to be responsible that later on DBZap() throws a

                // RDD exception - no matter if the "DBFNTX" or "DBFCDX" driver is used !

                //

                // When you deactivate the OrdKeycount() call below, DBZap() returns true and the DBF has as expected

                // 0 records

                                                              

                ? OrdKeyCount()  // <---  activate/deactivate the line if the "DBFCDX" or "DBFNTX" driver is used.

                              

                ? RecCount()

                ? "DBZap()" , DbZap()

                ? OrdKeyCount()

                ? RecCount()

               

                DbGoTop()

               

                ?

                ? "eof()" , Eof()

                ? OrdKeyCount() , RecCount()

                ?

                DO WHILE ! Eof()

                              

                               ? FieldGet ( 1 )

                              

                               DbSkip ( 1)

                              

                              

                ENDDO

                              

               

                RddSetDefault ( cDriver )

                              

                RETURN        
    FUNCTION TestPack2() AS VOID 	
LOCAL cDBF, cPfad, cDriver, cIndex AS STRING 
LOCAL aFields, aValues AS ARRAY 
LOCAL i AS DWORD


    cDriver := RddSetDefault ( "DBFNTX" )

	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	FErase ( cIndex + IndexExt() )
	

	aFields := { { "LAST" , "C" , 20 , 0 } } 

	aValues := { "a1" , "o5" , "g2", "g1" }	
	
		
    // -------------------
	
	? DbCreate( cDBF , AFields)
	? DbUseArea( ,,cDBF , , TRUE )	// open shared 	
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] ) 
		
		IF InList ( Upper ( aValues [i] ) , "G1" ) 
			? "DBDelete()" , DbDelete()
			
		ENDIF 	
						
	NEXT 
	
	
	? DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper (_FIELD->LAST) } )

	DbCloseAll()
	
    ?
   
	? DbUseArea( ,,cDBF , , FALSE )	 // open not shared
	? DbSetIndex ( cIndex ) 
		
	?
	// Note: the OrdKeyCount() call below seems to be responsible that  later on DBPack() throws a 
	// RDD exception - but only if the "DBFNTX" driver is used ! 
	//
	// When you deactivate the OrdKeycount() call, DBPack() returns true and the DBF has as expected 
	// 3 records - but the NTX is damaged.
				
	? OrdKeyCount()  // <---  activate/deactivate this line if the "DBFNTX" driver is used
		
	? RecCount() 
	? "DBPack()" , DbPack()
	? OrdKeyCount()
	? RecCount() 
   	
	DbGoTop()
	 
	?
	? "eof()" , Eof() 
	? OrdKeyCount() , RecCount()
	?
	DO WHILE ! Eof()
		
		? FieldGet ( 1 )
		
		DbSkip ( 1) 
		
		
	ENDDO 
		
	
	RddSetDefault ( cDriver )
		
	RETURN
		FUNCTION DbSeekTest() AS VOID
			LOCAL cDbf AS STRING
			LOCAL cRet AS STRING

			RddSetDefault("DBFNTX")
			cDBF := "DbSeekTest"
			FErase ( cDbf + IndexExt() )
			
			DbCreate(cDbf, { { "LAST" , "C" , 20 , 0 } })

			DbUseArea( ,,cDBF , , TRUE )
            FOREACH VAR value IN { "u1" , "u2", "o2" , "o1"  }
                DbAppend()
                FieldPut(1, VALUE)
            NEXT
			DbCreateOrder ( "ORDER1" , cDbf , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
			DbSetOrder ( 1 )
			DbGoTop()
			cRet := ""
			DO WHILE ! Eof()
				cRet += AllTrim( FieldGet ( 1 ) )
				DbSkip ( 1 )                       
			ENDDO
            ?  "o1o2u1u2" == cRet
            ? DbSeek ( "P" , FALSE , TRUE )  // seek for last occurence       
			
			OrdDescend ( , , TRUE )
			DbGoTop()
			cRet := ""
			DO WHILE ! Eof()
				cRet += AllTrim( FieldGet ( 1 ) )
				DbSkip ( 1 )                       
			ENDDO               
			? "u2u1o2o1" = cRet 
			? DbSeek ( "P" , FALSE , TRUE )  // seek for last occurence       
		
			DbCloseAll()
    RETURN

FUNCTION TestAOtter() AS VOID

LOCAL cDBF, cPfad, cDriver, cIndex AS STRING
LOCAL aFields, aValues AS ARRAY
LOCAL i AS DWORD
LOCAL lUseGermanDll AS LOGIC

                 SetAnsi ( TRUE )

     SetCentury( TRUE )

     cDriver := RddSetDefault ( "DBFCDX" )

     // ----------------

                 lUseGermanDll := TRUE

                 // -------------

                 IF lUseGermanDll

                     SetInternational ( #clipper  )

                 SetCollation ( #clipper )

                                IF ! SetNatDLL ( "German" )

                                                ? "German not loaded"

                                ENDIF

                 SetDateCountry ( DateCountry.German )

                     SetThousandSep ( Asc ( "." ))

                 SetDecimalSep ( Asc ( "," ))

                 ELSE

//            SetAppLocaleID(MAKELCID(MAKELANGID(LANG_GERMAN, SUBLANG_GERMAN), SORT_GERMAN_PHONE_BOOK))  // Telefonbuch

// SetAppLocaleID(MAKELCID(MAKELANGID(LANG_GERMAN, SUBLANG_GERMAN), SORT_DEFAULT)) // Wörterbuch

ENDIF

                 cDBF := cPfad + "Foo"

                 cIndex := cPfad + "Foox"

                 FErase ( cIndex + IndexExt() )

                 aFields := { { "LAST" , "C" , 20 , 0 } }

                 aValues := { "Art" ,"Aero" , "Anfang",  "Goethe" , "Goldmann" ,"Ober" , "Otter" , "Unter" }


                 ? DbCreate( cDBF , AFields)

                 ? DbUseArea( ,,cDBF , , TRUE )

                 FOR i := 1 UPTO ALen ( aValues )

                                DbAppend()

                                FieldPut ( 1 , aValues [ i ] )

                 NEXT

                 ? DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
                 ? DbCreateOrder ( "ORDER2" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
                 ? DbCreateOrder ( "ORDER3" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )

                 ? DbSetOrder ( 1 )

                 DbGoTop()

                 ?

                 ? "Seek OTTER", DbSeek ( "OTTER")

                 ? DbRLock()

                 FieldPut ( 1 , "Aotter" )

                 ? DbCommit()

                 ? DbRUnLock()

     ?

                 ? "Seek AOTTER" , DbSeek ( "AOTTER")

                 ? DbRLock()

                 FieldPut ( 1 , "Otter" )
                 ? OrdKeyCount()
                 ? OrdKeyNo()
                 ? DbCommit()

                 ? DbRUnLock()

                 ?

                 DbGoTop()

                 DO WHILE ! Eof()

                                ? FieldGet ( 1 )

                                DbSkip ( 1 )

                 ENDDO

                 ?

                 DbCloseAll()

                 ? DbUseArea( ,,cDBF , , TRUE )

                 ? DbSetIndex ( cIndex )

                ? DbSetOrder ( 1 )

                 ? "Seek OTTER" , DbSeek ( "OTTER")

                 ? DbRLock()

                 FieldPut ( 1 , "Aotter" )

                 ? DbCommit()

                 ? DbRUnLock()

                 ?

                 DbGoTop()

                 DO WHILE ! Eof()

                                ? FieldGet ( 1 )

                                DbSkip ( 1 )

                 ENDDO

                 DbCloseAll()

                 RddSetDefault ( cDriver )

                 RETURN


    FUNCTION Ticket127() AS VOID
	LOCAL cDBF, cPfad, cIndex AS STRING

	RddSetDefault ( "DBFCDX" ) 
	
	cPfad := "c:\test\"

	cDBF := cPfad + "Test.dbf"
	cIndex := cPfad + "TestCDX.cdx"
	FErase(cDbf)
	FErase(cPfad + ".cdx")
	FErase(cIndex)
	? cDbf , File(cDbf)
	? cIndex , File(cIndex)

	? DbCreate( cDBF , { { "LAST" , "C" , 20 , 0 } } )
	? DbUseArea( ,,cDBF , , TRUE )
	// OK
	? DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	DbCloseArea()

	FErase(cDbf)
//	FErase(cIndex) // no error if file deleted in advance
	? DbCreate( cDBF , { { "LAST" , "C" , 20 , 0 } } )
	? DbUseArea( ,,cDBF , , TRUE )
	// exception here:
	? DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	DbCloseArea()
RETURN
FUNCTION TestHexString() AS VOID 
LOCAL x AS INT64 

	x := 30000 

	 ? "AsHexString" , AsHexString (  x )  // 0000000000007530	 	 
	 
	 ?
	 ? "AsHexString" , AsHexString ( (INT) x  )   //  00007530
	 
	  x := 222_222_222_344_234 
	 ? 
	 ? "AsHexString" , AsHexString ( x  )  //  0000CA1C249FC02A
	 ?
	 ? "AsHexString" , AsHexString ( "abcdef" )  // 616263646566  instead of  "61 62 63 64 65 66"            
	 ?
	 
	 RETURN 	

    FUNCTION FrankM(  ) AS VOID

	LOCAL DirList AS ARRAY
	DirList := Directory( "C:\*.*", "DRHS" )
	LOCAL Entry AS ARRAY
	LOCAL Info AS STRING
	LOCAL i AS DWORD
    ? ALen( DirList )
    WAIT
	FOR i := 1 TO ALen( DirList )
		Entry := DirList[i]
     ? Entry[F_NAME], Entry[F_SIZE],;
       Entry[F_DATE], Entry[F_TIME],;
       Entry[F_ATTR]
	NEXT
	
RETURN

FUNCTION Ticket118a() AS VOID

	LOCAL cDBF, cPfad, cIndex AS STRING 
	LOCAL aFields, aValues AS ARRAY 
	LOCAL i AS DWORD                  
	
	cPfad := "C:\test\"
	RddSetDefault ( "DBFCDX" )  
	
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	FErase ( cIndex + IndexExt() )	
	
	aFields := { { "LAST" , "C" , 20 , 0 } } 
	
	aValues := { "a1" , "a2", "a3" , "a4" , "a5" , "a6" ,"g1", "g2" , "g3" , "g4" , "g5" , "o1" , "o2" , "o3" , "o4" , "o5" , "u1", "u2","u3" , "u4" }	
	
	? DbCreate( cDBF , AFields)
	? DbUseArea( ,,cDBF , , TRUE )		
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] ) 
		IF InList ( Upper ( aValues [ i ] ) , "G1" , "G2" , "O5" ) 
			? "DBDelete()" , DbDelete() 			
		ENDIF 
	NEXT 
	
	// create a descending order 
	
	? DbSetOrderCondition( , , , , , , , , , ,TRUE )
	? DbCreateOrder ( "ORDER2" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	
	? DbSetOrder ( 1 )  
	?   
	
	DbGoTop() 
	
	DO WHILE ! Eof() 
		? FieldGet ( 1 ) 
		DbSkip ( 1 ) 
	ENDDO 	
	
	// ---------
	?
	
	SetDeleted ( FALSE ) 
	
	? OrdKeyCount() // 20  ok
	
	SetDeleted ( TRUE  ) 	 
	? OrdKeyCount() //  Here it hangs because SetDeleted() is true ... 
	
	? " This line is never reached ..."
	
	// -------------
	
	DbCloseAll() 
RETURN
FUNCTION Ticket118() AS VOID
	LOCAL cDBF, cPfad, cIndex AS STRING 
	LOCAL aFields, aValues AS ARRAY 
	LOCAL i AS DWORD                  
	
	cPfad := "C:\test\"
	
	RddSetDefault ( "DBFCDX" )  
	
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	FErase ( cIndex + IndexExt() )	
	
	aFields := { { "LAST" , "C" , 20 , 0 } } 
	
	aValues := { "a1" , "a2", "a3" , "a4" , "a5" , "a6" ,"g1", "g2" , "g3" , "g4" , "g5" , "o1" , "o2" , "o3" , "o4" , "o5" , "u1", "u2","u3" , "u4" }	
	
	? DbCreate( cDBF , AFields)
	? DbUseArea( ,,cDBF , , TRUE )		
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] ) 
		
		IF InList ( Upper ( aValues [ i ] ) , "G1" , "G2" , "O5" ) 
			? "DBDelete()" , DbDelete() 			
		ENDIF 
	NEXT 
	
	? DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	
	? DbSetOrder ( 1 )  
	?
	// ---------
	
	OrdScope ( TOPSCOPE, "G" ) 
	OrdScope ( BOTTOMSCOPE, "G" ) 
	
//	OrdScope ( TOPSCOPE, "A" ) 
//	OrdScope ( BOTTOMSCOPE, "G" ) 
	
	?  OrdKeyCount() 
	?
	
	SetDeleted ( TRUE )  // no problem if set to FALSE
	
	OrdDescend ( , , TRUE )
	DbGoTop()
	
	// SetDeleted(TRUE) causes a endless loop ...
	
	DO WHILE ! Eof()
		? AllTrim(FieldGet ( 1 ) ) , RecNo(), Eof(), Bof()
		DbSkip ( 1 ) 
	ENDDO
	
	?
	? "This line is never reached" 
	?
	?  OrdKeyCount(), "should be 3"
	
	DbCloseAll()
RETURN

FUNCTION Ticket120() AS VOID
	LOCAL cDBF, cPfad, cDriver, cIndex AS STRING 
	LOCAL aFields, aValues AS ARRAY 
	LOCAL i AS DWORD                  
	
	cPfad := "C:\test\"
	
	cDriver := RddSetDefault ( "DBFCDX" )  
	
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	FErase ( cIndex + IndexExt() )	
	
	aFields := { { "LAST" , "C" , 20 , 0 } } 
	aValues := { "a1" , "a2", "a3" , "a4" , "a5" , "a6" ,"g1", "g2" , "g3" , "g4" , "g5" , "o1" , "o2" , "o3" , "o4" , "o5" , "u1", "u2","u3" , "u4" }	
	
	? DbCreate( cDBF , AFields)
	? DbUseArea( ,,cDBF , , TRUE )		
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] ) 
		IF InList ( Upper ( aValues [ i ] ) , "G1" , "G2" , "O5" ) 
			? "DBDelete()" , DbDelete() 			
		ENDIF 
	NEXT 
	
	? DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	
	? DbSetOrder ( 1 )  
	?
	
	// ---------
	
	SetDeleted ( TRUE ) 
	
	OrdScope ( TOPSCOPE, "G" ) 
	OrdScope ( BOTTOMSCOPE, "G" ) 
// DbGoTop() 	
	
	? OrdKeyCount(), "should be 3" // 3 ok
	
	SetDeleted ( FALSE ) 
//	DbGoTop() 		
	
	? OrdKeyCount(), "should be 5" // 5 ok
	
	// -------------
	
	OrdScope ( TOPSCOPE, NIL ) 
	OrdScope ( BOTTOMSCOPE, NIL ) 
	
	// If TOPSCOPE and BOTTOMSCOPE is not equal 
	// OrdKeyCount() seems to ignore a SetDeleted( TRUE ) ?
	
	OrdScope ( TOPSCOPE, "A" ) 
	OrdScope ( BOTTOMSCOPE, "G" ) 
	
	?  
	SetDeleted( TRUE ) 	
	? OrdKeyCount(), "should be 9"    // 11	 but must show 9 

	SetDeleted( FALSE ) 
	? OrdKeyCount(), "should be 11"    // 11	ok
	//------------  
	
	DbCloseAll() 
RETURN
FUNCTION Ticket103a() AS VOID
	LOCAL cDBF, cPfad, cDriver, cIndex, cFilter AS STRING
	LOCAL aFields, aValues AS ARRAY
	LOCAL i AS DWORD       
	
	cDriver := RddSetDefault ( "DBFCDX" ) 
	
	cPfad := "C:\test\"
	
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox"
	
	FErase ( cIndex + IndexExt() )  
	
	aFields := { { "LAST" , "N" , 5 , 0 } }
	
	aValues := { 1,2,3,4,5,6,3,4 }
	
   // -------------------
	
	? DbCreate( cDBF , AFields)
	? DbUseArea( ,,cDBF , , TRUE )                
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend()
		FieldPut ( 1 , aValues [ i ] )
	NEXT        
	
	? DbCreateOrder ( "ORDER1" , cIndex , "LAST" , { || _FIELD->LAST } )
	? DbSetOrder ( 1 )

	OrdScope ( TOPSCOPE, 2 )
	OrdScope ( BOTTOMSCOPE, 5 )
	
	?
	? "OrdKeycount() Scope" , OrdKeyCount() , "must be 6" //  6, ok
	?               
	
	?  DbSetFilter ( { || _FIELD->LAST == 3  } , "LAST == 3")  
	DbGoTop()
	?
	? "Eof" , Eof()  // false
	
	? "OrdKeycount() after Filter on Scope" , OrdKeyCount() , "must be 2" //  0, must be 2
	
	? "Eof" , Eof()  // false
	DbGoTop()
	
//	 -------------
	
	DO WHILE ! Eof()
		? FieldGet ( 1 )
		DbSkip ( 1 )
	ENDDO
	
	DbCloseAll()     
	RddSetDefault ( cDriver )    
RETURN
FUNCTION Ticket103() AS VOID
	LOCAL cDBF, cPfad, cDriver, cIndex, cFilter AS STRING
	LOCAL aFields, aValues AS ARRAY
	LOCAL i AS DWORD       
	
	cDriver := RddSetDefault ( "DBFCDX" ) 
	
	cPfad := "C:\test\"
	
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox"
	
	FErase ( cIndex + IndexExt() )  
	
	aFields := { { "LAST" , "C" , 20 , 0 } }
	
	aValues := { "A1" ,"A3" , "A2",  "Go1" , "G1" , "g2" , "g3", "go2"  , "h2" , "h4" }
	
   // -------------------
	
	? DbCreate( cDBF , AFields)
	? DbUseArea( ,,cDBF , , TRUE )                
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend()
		FieldPut ( 1 , aValues [ i ] )
	NEXT        
	
	? DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	? DbSetOrder ( 1 )

	OrdScope ( TOPSCOPE, "A" )
	OrdScope ( BOTTOMSCOPE, "G" )
	
	?
	? "OrdKeycount() Scope" , OrdKeyCount() , "must be 8" //  8, ok
	?               
	
	cFilter := "GO" 
	
	?  DbSetFilter ( { || Upper ( _FIELD->LAST ) = cFilter  } , "Upper (LAST) = "+ cFilter )  
	DbGoTop()
	?
	? "Eof" , Eof()  // TRUE, should be false
	
	? "OrdKeycount() after Filter on Scope" , OrdKeyCount() , "must be 2" //  9, must be 2
	
	? "Eof" , Eof()  // TRUE, should be false
	DbGoTop()
	? "Eof" , Eof()  // TRUE, should be false
	
//	 -------------
	
//	 NOTE: eof () is already TRUE, so the DO WHILE will not be executed
	
	DO WHILE ! Eof()
		? FieldGet ( 1 )
		DbSkip ( 1 )
		
	ENDDO
	
	DbCloseAll()     
	RddSetDefault ( cDriver )    
RETURN

FUNCTION Ticket119a() AS VOID
	LOCAL cDBF, cPfad, cIndex, cFilter  AS STRING 
	LOCAL aFields, aValues AS ARRAY 
	LOCAL i AS DWORD                  
	
	cPfad := "C:\test\"
	
	RddSetDefault ( "DBFCDX" )  
	
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	FErase ( cIndex + IndexExt() )	
	
	aFields := { { "LAST" , "C" , 20 , 0 } } 
	aValues := { "a1" , "a2", "a3" , "a4" , "a5" , "a6" ,"g1", "g2" , "g3" , "g4" , "g5" , "o1" , "o2" , "o3" , "o4" , "o5" , "u1", "u2","u3" , "u4" }	
	
	? DbCreate( cDBF , AFields)
	? DbUseArea( ,,cDBF , , TRUE )		
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] ) 
		IF InList ( Upper ( aValues [ i ] ) , "G1" , "G2" , "O5" ) 
			? "DBDelete()" , DbDelete() 			
		ENDIF 
	NEXT 
	
	? DbCreateOrder ( "ORDER2" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	? DbSetOrder ( 1 )  
	? 
	
	// -----------
	
	cFilter := "A"  // result does include *no* deleted records  ! 
	
	?  DbSetFilter ( { || Upper ( _FIELD->LAST ) = cFilter  } , "Upper (LAST) = "+ cFilter )  
	?
	? OrdKeyCount() , "should be 6"  // 6 , ok 
	
	OrdDescend ( , , TRUE ) 
	
//	SetDeleted ( FALSE )
//	SetDeleted ( TRUE )  
	
	// OrdKeyCount() hangs no matter how the SetDeleted() setting is. 
	
	? OrdKeyCount()  , "should be 6" 
	
	
	// -------------
	
	DbCloseAll() 
RETURN
FUNCTION Ticket119() AS VOID
	LOCAL cDBF, cPfad, cIndex, cFilter  AS STRING 
	LOCAL aFields, aValues AS ARRAY 
	LOCAL i AS DWORD                  
	
	cPfad := "C:\test\"
	
	RddSetDefault ( "DBFCDX" )  
	
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	FErase ( cIndex + IndexExt() )	
	aFields := { { "LAST" , "C" , 20 , 0 } } 
	aValues := { "a1" , "a2", "a3" , "a4" , "a5" , "a6" ,"g1", "g2" , "g3" , "g4" , "g5" , "o1" , "o2" , "o3" , "o4" , "o5" , "u1", "u2","u3" , "u4" }	
	
	? DbCreate( cDBF , AFields)
	? DbUseArea( ,,cDBF , , TRUE )		
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] ) 
		IF InList ( Upper ( aValues [ i ] ) , "G1" , "G2" , "O5" ) 
			? "DBDelete()" , DbDelete() 			
		ENDIF 
	NEXT 
	
	? DbCreateOrder ( "ORDER2" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	
	? DbSetOrder ( 1 )  
	? 
	
	// -----------
	
	cFilter := "G"  // result does include deleted records  ! 
	
	SetDeleted ( FALSE ) 	    
	
	?
	? "DBSetFilter" , DbSetFilter ( { || Upper ( _FIELD->LAST ) = cFilter  } , "Upper (LAST) = "+ cFilter ) 
	?            
	
	DbGoTop()
	
	? OrdKeyCount() , "should be 5" //  5 ok
	
	SetDeleted ( TRUE  ) 	 
	
	#IFNDEF __XSHARP__ 
	
		// the __XSHARP__ Define is used because VO doesn´t refresh the filter - as X# does -
		// if SetDeleted() is changed on the fly . 
		//
		// NOTE: e.g. using a simple DBGoTop() instead doesn´t help. 
		//  
	
	DbSetFilter ( { || Upper ( _FIELD->LAST ) = cFilter  } , "Upper (LAST) = "+ cFilter )  
	
	#ENDIF	
	
	? OrdKeyCount(), "should be 3"  //  3 ok  
	
	
	// -------------  
	
	// now change the filter to descend sort on the fly 
	
	OrdDescend ( , , TRUE ) 
	
	// -------------
	
	? 
	
	SetDeleted ( FALSE )  
	
	#IFNDEF __XSHARP__ 
	DbSetFilter ( { || Upper ( _FIELD->LAST ) = cFilter  } , "Upper (LAST) = "+ cFilter )  
	#ENDIF	 
	
	? OrdKeyCount() , "should be 5" //  shows 0  ...
	
	SetDeleted ( TRUE  ) 
	
	#IFNDEF __XSHARP__ 
	DbSetFilter ( { || Upper ( _FIELD->LAST ) = cFilter  } , "Upper (LAST) = "+ cFilter )  
	#ENDIF		
	
	? OrdKeyCount(), "should be 3"  // 	shows 0  ...  
	
	// ---------
   // switch back to ascending sort
   // --------- 
	?
	
	OrdDescend ( , , FALSE ) 
	
	SetDeleted ( FALSE ) 
	
	#IFNDEF __XSHARP__ 
	DbSetFilter ( { || Upper ( _FIELD->LAST ) = cFilter  } , "Upper (LAST) = "+ cFilter )  
	#ENDIF
	
	? OrdKeyCount(), "should be 5"  //  5, ok
	
	SetDeleted ( TRUE ) 
	
	#IFNDEF __XSHARP__ 
	DbSetFilter ( { || Upper ( _FIELD->LAST ) = cFilter  } , "Upper (LAST) = "+ cFilter )
	#ENDIF
	
	? OrdKeyCount() , "should be 3" // 	3, ok
	
	// -------------
	
	DbCloseAll()
RETURN

FUNCTION TestDosErrors() AS VOID
    FOR VAR i := 1 TO 1000
        VAR cErr := DosErrString((DWORD) i)
        IF ! cErr:StartsWith("Unknown")
        ? i, cErr
        ENDIF
    NEXT
    RETURN
    FUNCTION Ticket115Orig( ) AS VOID
	LOCAL cDBF, cPfad, cDriver, cIndex AS STRING 
	LOCAL aFields, aValues AS ARRAY 
	LOCAL i AS DWORD 
	LOCAL lFound, lAddUmlauteName,lUseGermanDll AS LOGIC 
	
	SetAnsi ( TRUE ) 
	SetCentury( TRUE )   
	
	cDriver := RddSetDefault ( "DBFCDX" ) 
	
    // ---------------- 
	lUseGermanDll := TRUE
	// ------------- 
	
	IF lUseGermanDll
		
		SetInternational ( #clipper  ) 
		SetCollation ( #clipper ) 
		
		IF ! SetNatDLL ( "German" )  		   
			? "German not loaded" 
		ENDIF 	                           
		SetDateCountry ( DateCountry.German )
		SetThousandSep ( Asc ( "." ))   
		SetDecimalSep ( Asc ( "," ))   
	ELSE 
    	//SetAppLocaleID(MAKELCID(MAKELANGID(LANG_GERMAN, SUBLANG_GERMAN), SORT_GERMAN_PHONE_BOOK))  // Telefonbuch    	
		SetAppLocaleID(MAKELCID(MAKELANGID(LANG_GERMAN, SUBLANG_GERMAN), SORT_DEFAULT)) // Wörterbuch
	ENDIF  
	
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	FErase ( cIndex + IndexExt() )	
	
	aFields := { { "LAST" , "C" , 20 , 0 } } 
	
	aValues := { "Art" ,"Aero" , "Anfang",  "Goethe" , "Äffin" , "Ärger" , "Ärmlich", "Goldmann" ,;
				"Götz" , "Ober" , "Otter" , "Österreich" , "Östrogon" , "Ötzi" ,"Unter" , ;
				"Übel" , "Überheblich" , "Üblich" , "Göthe" }  
	
	// -------------
	
	lAddUmlauteName := FALSE 
	
	IF lAddUmlauteName				
		AAdd( aValues , "Göbel")
	ELSE 
		AAdd( aValues , "Gobel")
	ENDIF 		
	
    // -------------------
	
	? DbCreate( cDBF , AFields)
	? DbUseArea( ,,cDBF , , TRUE )		
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] ) 
	NEXT         
	
	? DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	
	? DbSetOrder ( 1 )  
	
	DbGoTop()
	
	?
	? "Seek ART", DbSeek ( "ART") 
	? DbRLock()
	FieldPut ( 1 , "Aart" ) 
	? DbCommit()
	? DbRUnLock()
	?
	? "Seek AART" , DbSeek ( "AART")
	? DbRLock()
	FieldPut ( 1 , "Art" ) 	
	? DbCommit()
	? DbRUnLock()
	?
	? "Seek GOETHE" , DbSeek ( "GOETHE")
	? DbRLock()
	FieldPut ( 1 , "Gooethe" ) 
	? DbCommit()
	? DbRUnLock()
	?
	? "Seek GOOETHE" , lFound:= DbSeek ( "GOOETHE")
	IF lFound
		? FieldGet ( 1 )
		? DbRLock()
		FieldPut ( 1 , "Goethe" ) 	
		? DbCommit()
		? DbRUnLock()
	ELSE 
		? "Not found " , Eof()
	ENDIF 		
	
	DbGoTop()
	
	?
	? "OrdKeyCount()", OrdKeyCount()
	? "Reccount()" , RecCount()
	?
	
	DO WHILE ! Eof() 
		
		? FieldGet ( 1 ) 
		DbSkip ( 1 ) 
		
	ENDDO 	

	
	DbCloseAll() 	
	RddSetDefault ( cDriver )
RETURN
FUNCTION Ticket115( ) AS VOID
	LOCAL cDBF AS STRING 
	LOCAL aFields, aValues AS ARRAY 
	LOCAL i AS DWORD 
	
	RddSetDefault ( "DBFCDX" ) 
	
	// makes no difference
//	SetCollation ( #clipper ) 
//	SetCollation ( #windows ) 
	
	cDBF := "c:\test\aaa"
	FErase ( cDBF + IndexExt() )	
	
	aFields := { { "LAST" , "C" , 20 , 0 } } 
	aValues := { "Art" ,"Aero" , "Anfang",  "Goethe" , "Äffin" , ;
				"Ärger" , "Ärmlich", "Goldmann" ,"Üblich" , "Göthe" }  
	
	DbCreate( cDBF , AFields)
	DbUseArea( ,,cDBF , , FALSE )		
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] ) 
	NEXT         
	
	DbCreateOrder ( "ORDER1" , cDBF , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	DbGoTop()
	
	// ? "Seek GOETHE" , DbSeek ( "GOETHE")
	DbGoto(4) // same result as with seek()
	FieldPut ( 1 , "GOOETHE" ) 
	? RecNo() // 4
	? DbCommit() // without this, it works correctly!
	?
	DbGoTop()
	? "Seek GOOETHE" , DbSeek ( "GOOETHE") // returns false, it should find it
	
	DbGoto(4)
	? "Record 4 has", FieldGet(1)
	?
	
	WAIT
	DbGoTop()
	?
	? "OrdKeyCount()", OrdKeyCount()
	? "Reccount()" , RecCount()
	?
	
	DO WHILE ! Eof() 
		? recno(), FieldGet ( 1 ) 
		DbSkip ( 1 ) 
	ENDDO 	
	DbCloseAll() 	
RETURN

FUNCTION TestDBFTouch() AS VOID
LOCAL cDbf AS STRING
cDbf := "C:\test\test.dbf"
? DbCreate(cDbf , {{"TEST","L",1,0}})
? File.GetLastWriteTime(cDbf)
System.Threading.Thread.Sleep(2000)
? DbUseArea(,,cDbf)
? File.GetLastWriteTime(cDbf)
? DbCloseArea()
? File.GetLastWriteTime(cDbf) // 2 seconds later than first one
RETURN

FUNCTION TestMemoAtEof() AS VOID
	LOCAL cDbf AS STRING
	cDbf := "C:\TEST\mytest"
	RddSetDefault("DBFCDX")
	DbCreate(cDbf , {{"MYCHAR","C",10,0},{"MYMEMO","M",10,0}})
	DbUseArea(,,cDbf)
	DbAppend()
	FieldPut(1,"str contents")
	FieldPut(2,"memo contents")
	DbSkip(+1)
	? Eof() // TRUE, correct
	? FieldGet(1) // empty string
	? FieldGet(2) // exception
	DbCloseArea()
RETURN
FUNCTION TestAsHexString() AS VOID
LOCAL s AS INT
s := -1
? AsHexString(s)
RETURN

FUNCTION ContructorException() AS VOID
	LOCAL u AS USUAL
	TRY
		//u := CreateInstance("TestClass1") // "No exported method 'CONSTRUCTOR'"
		u := TestClass1{}
		Send(u,"TestMethod") // "Argument" is not numeric, correct error message
	CATCH e AS Exception
		? e:ToString()
	END TRY
RETURN

CLASS TestClass1
	CONSTRUCTOR()
		CauseException()
	RETURN
	METHOD TestMethod() AS VOID
		CauseException()
	RETURN
END CLASS

PROCEDURE CauseException()
	LOCAL u AS USUAL
	u := 1
	? u + TRUE
RETURN 

FUNCTION TestSetDefault() AS VOID
    ? RddSetDefault(NULL_STRING)
    RETURN
FUNCTION FptLock() AS VOID
	LOCAL cDBF AS STRING 

 	cDbf := "C:\TEST\mydbf"

   	RddSetDefault ( "DBFCDX" ) 
	FErase ( cDbf + ".dbf" )	
	FErase ( cDbf + ".cdx" )	
	FErase ( cDbf + ".fpt" )	
	
	? DbCreate( cDBF , {{"MEMOFLD" , "M" , 10 , 0}},"DBFCDX")
	? DbUseArea( ,,cDBF , , TRUE )
	? DbAppend()
	FieldPut(1 , "memo contents")
	DbCommit()
	
	WAIT "Open dbf file from a VO app now"

	DbCloseAll() 

FUNCTION DescOrderScope() AS VOID 
LOCAL cDBF, cPfad, cIndex, cDriver AS STRING 
LOCAL aFields, aValues AS ARRAY  
LOCAL i AS DWORD
LOCAL lUseFirstScope AS LOGIC 
//LOCAL lSet AS LOGIC  

    
    lUseFirstScope := FALSE   
    
    

   	cDriver := RddSetDefault ( "DBFCDX" ) 
 	
	aFields := { { "LAST" , "C" , 20 , 0 }}  
	
	
//	aValues := { "b" , "d" , "c", "e" , "a" , "o" , "p" , "r" , "g" }
	
	aValues := { "b" , "d" , "c", "e" , "g1" , "g3" , "g45" , "a" , "o" , "p" , "r"}			
	         
	
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	
	FErase ( cIndex + IndexExt() )	
	
	// -----------------  
	
//	lSet := SetDeleted(FALSE)	
	
	? DbCreate( cDBF , aFields)
	? DbUseArea( ,"DBFCDX",cDBF , , TRUE )		
	
	FOR i := 1 UPTO ALen ( aValues )
		
		DbAppend() 
		
		FieldPut ( 1 , aValues [ i ] ) 			
		
	NEXT 

	? DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) }  )  		

	? DbSetOrder ( 1 ) 
	 
	?
	
	IF lUseFirstScope
		
	 	OrdScope(TOPSCOPE,  "A")   
		OrdScope(BOTTOMSCOPE, "O") 
		
		? "TopScope: 'A'"
		? "BottomScope: 'O'"		
	
	ELSE
	 	OrdScope(TOPSCOPE,  "G")   
		OrdScope(BOTTOMSCOPE, "G")
		
		? "TopScope: 'G'"
		? "BottomScope: 'G'"		
		
	ENDIF		
	
   	DbGoTop() 
   	
   	?
	? "OrderKeyCount()" , OrdKeyCount()   	
    ?
	DO WHILE ! Eof()
		
	   ? FieldGet ( 1)

		DbSkip ( 1)

	ENDDO  
	
    ?
//    ? "M", DbSeek("M",TRUE), Found(), Eof(), FieldGet(1)
//    ? "O", DbSeek("O",TRUE), Found(), Eof(), FieldGet(1)
//    ? "P", DbSeek("P",TRUE), Found(), Eof(), FieldGet(1)
    
	OrdDescend( , , TRUE)
	

   	DbGoTop()
   	
   	?
	? "OrderKeyCount()" , OrdKeyCount()   	 
	?
	DO WHILE ! Eof()
		
	   ? FieldGet ( 1)

		DbSkip ( 1)

	ENDDO
    IF lUseFirstScope
    ? "A", DbSeek("A",TRUE), Found(), Eof(), FieldGet(1)
    ? "B", DbSeek("B",TRUE), Found(), Eof(), FieldGet(1)
    ? "C", DbSeek("C",TRUE), Found(), Eof(), FieldGet(1)
    ? "D", DbSeek("D",TRUE), Found(), Eof(), FieldGet(1)
    ? "E", DbSeek("E",TRUE), Found(), Eof(), FieldGet(1)
    ? "F", DbSeek("F",TRUE), Found(), Eof(), FieldGet(1)
    ? "G", DbSeek("G",TRUE), Found(), Eof(), FieldGet(1)
    ? "M", DbSeek("M",TRUE), Found(), Eof(), FieldGet(1)
    ? "O", DbSeek("O",TRUE), Found(), Eof(), FieldGet(1)
    ? "P", DbSeek("P",TRUE), Found(), Eof(), FieldGet(1)
    ELSE
    ? "F", DbSeek("F",TRUE), Found(), Eof(), FieldGet(1)
    ? "G", DbSeek("G",TRUE), Found(), Eof(), FieldGet(1)
    ? "H", DbSeek("H",TRUE), Found(), Eof(), FieldGet(1)
    ENDIF
	
	
	DbCloseAll() 
	
	RddSetDefault ( cDriver )	 
//    SetDeleted(lSet)
	
	RETURN		

FUNCTION dirtest AS VOID
    LOCAL afiles AS ARRAY
    afiles := Directory( "C:\XSharp\*.*","D" )
    ShowArray(aFiles)
    //afiles := Directory( "c:\temp", "D" )
    //ShowArray(aFiles)
    RETURN

FUNCTION testAutoIncrement() AS VOID
    LOCAL cDbf AS STRING
    LOCAL aStruct AS ARRAY
    aStruct := { {"COUNTER","I+",4,0},;
            {"NAME", "C", 10, 0} }
    cDbf := "c:\Test\testvfp.dbf"
    RddSetDefault("DBFVFP")
    DbCreate(cDbf, aStruct, "DBFVFP")
    DbCloseArea()
    WAIT
    DbUseArea(,,cDbf, "TestVfp")
    DbFieldInfo(DBS_COUNTER, 1, 100)
    DbFieldInfo(DBS_STEP, 1, 2)
    DbCloseArea()
    WAIT
    DbUseArea(,,cDbf, "TestVfp")
    ShowArray(dBStruct())
    DbAppend()
    ? FieldGet(1)
    FieldPut(2, repl(chr(65+FieldGet(1)),10))
    ? DbFieldInfo(DBS_COUNTER, 1)
    ? DbFieldInfo(DBS_STEP, 1)
    ? DbFieldInfo(DBS_ISNULL, 1)
    DbFieldInfo(DBS_COUNTER, 1, 100)
    ? DbFieldInfo(DBS_COUNTER, 1)
    DbCommit()
    USE
    WAIT
    RETURN

FUNCTION TestOrdScope() AS VOID 
	LOCAL cDBF AS STRING 
	LOCAL dwCount AS DWORD
	
   	RddSetDefault ( "DBFCDX" ) 
	cDBf  := "C:\test\test1"

	FErase ( cDbf + ".dbf" )	
	FErase ( cDbf + ".cdx" )	

	DbCreate(cDbf , {{"LAST","C",10,0}})
	DbUseArea( ,"DBFCDX",cDBF , , TRUE )
	FOR LOCAL n := 1 AS DWORD UPTO 1000
		DbAppend()
		FieldPut(1, Chr(65 + (n % 5)) )
	NEXT
	DbGoTop()
	
	? DbCreateOrder( "ORDER1" , cDbf , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	
	DbSetOrder ( 1 ) 
	DbGoTop()
    OrdScope( TOPSCOPE, "C" )
	OrdScope( BOTTOMSCOPE, "C" )

	DbGoTop()

	? "OrdKeyCount()", OrdKeyCount()  

	DbGoTop()
	DO WHILE ! Eof()
		dwCount += 1
		DbSkip(1)
	ENDDO
	? "scope manually counted: " , dwCount
	
	DbGoTop()
	DbSkip(2)
	? Eof() // TRUE, should be false
	
	DbCloseAll()	
RETURN

FUNCTION TestOrderCondition() AS VOID
	LOCAL cDBF AS STRING 
	LOCAL dwCount AS DWORD
	LOCAL n AS DWORD
	
   	RddSetDefault ( "DBFCDX" ) 
	cDBf  := "C:\test\test1"

	FErase ( cDbf + ".dbf" )	
	FErase ( cDbf + ".cdx" )	

	DbCreate(cDbf , {{"LAST","C",10,0}})
	DbUseArea( ,"DBFCDX",cDBF , , TRUE )
	FOR n := 1 UPTO 6
		DbAppend()
		FieldPut(1, Chr(65 + (n % 3)) )
	NEXT

	DbSetOrderCondition (,,,,,,,6,,,,,,,)
	DbGoTop()
	DbCreateOrder( "ORDER1" , cDbf , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
	? OrdKeyCount() // 4, should be 6
	? 
	DbGoTop()
	dwCount := 0
	DO WHILE .NOT. eof()
		dwCount ++
		DbSkip()
	END DO
	? dwCount  // 4, should be 6
	DbCloseArea()
RETURN

FUNCTION testOpenDbServer() AS VOID
    LOCAL oServer AS DbServer
    LOCAL cPath AS STRING
    cPath := "c:\cavo28SP3\Samples\Email\EMAIL.DBF"
    oServer := DBServer{ cPath, TRUE, TRUE, "DBFVFP" }
    DO WHILE ! oServer:EoF
        ? oServer:FIELDGET(1)
        oServer:Skip(1)
    ENDDO
    ? oServer:Used
    oServer:Close()
    RETURN

FUNCTION testseeknotfound AS VOID

RddSetDefault("DBFVFP")
DbuseArea(TRUE, "DBFVFP", "c:\Descartes\testdbf\Robert\trajekt.dbf", "TRA")
? SELECT()
OrdListAdd("c:\Descartes\testdbf\Robert\TRAJEKT1.ntx")
OrdListAdd("c:\Descartes\testdbf\Robert\TRAJEKT2.ntx")
OrdListAdd("c:\Descartes\testdbf\Robert\TRAJEKT3.ntx")
OrdListAdd("c:\Descartes\testdbf\Robert\TRAJEKT4.ntx")
OrdListAdd("c:\Descartes\testdbf\Robert\TRAJEKT5.ntx")
OrdListAdd("c:\Descartes\testdbf\Robert\TRAJEKT6.ntx")
OrdListAdd("c:\Descartes\testdbf\Robert\TRAJEKT9.ntx")
OrdSetFocus(1)
? IndexCount()
DbSelectArea(0)

? SELECT()
LOCAL aValues := {"1190499", "1190893","1190926","1190976","1191145"}
TRA->(DbSetScope(0, "119"))
TRA->(DbClearScope())
FOR VAR nI := 1 TO alen(aValues)
    ? aValues[nI], TRA->(DbSeek(aValues[nI]+"1"))
NEXT
DbCloseArea()
RETURN



FUNCTION TestUniqueCdx() AS VOID

LOCAL cDBF, cPfad, cIndex, cDriver AS STRING 
LOCAL aFields, aValues AS ARRAY  
LOCAL i AS DWORD

   	cDriver := RddSetDefault ( "DBFCDX" ) 
 	
	aFields := { { "LAST" , "C" , 20 , 0 }}  
	aValues := { "d" , "c", "e" , "a" , "o" , "p" , "r" , "b" }	
	         
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	FErase ( cIndex + IndexExt() )	
	
	// -----------------  
	
	? DbCreate( cDBF , AFields)
	? DbUseArea( ,"DBFCDX",cDBF , , TRUE )		
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] ) 			
	NEXT 

	// TRUE == UNIQUE   
	? DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) } , TRUE  )  
	
	? DbSetOrder ( 1 )   
	
	
	DbAppend() 
	FieldPut ( 1 , "a" ) 			
	
	DbAppend() 
	FieldPut ( 1 , "b" ) 			
	
	DbGoTop()   	
			
   ?	
   ? "OrdIsUnique" ,  OrdIsUnique()   // TRUE ok
   ? "DBOrderinfo DBOI_UNIQUE", DbOrderInfo(DBOI_UNIQUE ) // TRUE ok
   ? "OrdKeyCount()" , OrdKeyCount() // must be 8 , but shows 12
   ? "DBOrderinfo DBOI_KEYCOUNT", DbOrderInfo(DBOI_KEYCOUNT ) // must be 8 , but shows 12
   ? "Reccount()", RecCount()    // 10 ok	
   ?
	
	DO WHILE ! Eof()
	   ? FieldGet ( 1)
		DbSkip ( 1) 
		
	ENDDO 
	
	
	DbCloseAll() 
	
	RddSetDefault ( cDriver )	 
	
	RETURN		

FUNCTION TestGrowFpt AS VOID
LOCAL aFields AS ARRAY
LOCAL cFile AS STRING
RddSetDefault ( "DBFCDX" )
cFile := "C:\Test\TestFpt"
aFields := { { "ID" , "N" , 2 , 0 },{ "MEMO" , "M" , 10 , 0 }}
DbCreate(cFile, aFields)
DbUseArea(, "DBFCDX", cFile)
DbAppend()
FieldPut(1, 1)
FieldPut(2, Repl("X", 20))
DbCloseArea()
DbUseArea(, "DBFCDX", cFile)
FieldPut(1, 1)
FieldPut(2, Repl("X", 24))
DbCloseArea()
DbUseArea(, "DBFCDX", cFile)
FieldPut(1, 1)
FieldPut(2, Repl("X", 64))
DbCloseArea()
RETURN

FUNCTION TestNil() AS VOID
? ValType(Evaluate("NIL")) // O, wrong
? ValType(NIL) // U, ok
    RETURN

FUNCTION OrdDescFreeze() AS VOID
LOCAL cDBF, cPfad, cIndex, cDriver AS STRING 
LOCAL aFields, aValues AS ARRAY  
LOCAL i AS DWORD
LOCAL lSet AS LOGIC  

   	cDriver := RddSetDefault ( "DBFCDX" ) 
 	
	aFields := { { "LAST" , "C" , 20 , 0 }}  
	aValues := { "b" , "d" , "c", "e" , "a" , "o" , "p" , "r"}	
	cPfad := "C:\test\"         
	cDBF := cPfad + "Foo"
	cIndex := cPfad + "Foox" 
	
	FErase ( cIndex + IndexExt() )	
	
	// -----------------  
	
	lSet := SetDeleted(TRUE)	// <------------  SetDeleted(TRUE) must be set to TRUE !!!
	
	? DbCreate( cDBF , aFields)
	? DbUseArea( ,"DBFCDX",cDBF , , TRUE )		
	
	FOR i := 1 UPTO ALen ( aValues )
		DbAppend() 
		FieldPut ( 1 , aValues [ i ] ) 			
	NEXT 

	? DbCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper ( _FIELD->LAST) }  )  		

	? DbSetOrder ( 1 )  
	
 	OrdScope(TOPSCOPE,  "A")   // <-------- Must be the *very* first order value !
	OrdScope(BOTTOMSCOPE, "O")
    ? "Ascending"
   	DbGoTop() 

	DO WHILE ! Eof()
	   ? recno(), FieldGet ( 1)
		DbSkip ( 1)
	ENDDO  
	
    	?

	OrdDescend( , , TRUE)
	? "Descending"
   	DbGoTop() 

	DO WHILE ! Eof()
	   ? recno(), FieldGet ( 1)
		DbSkip ( 1)
	ENDDO 
		
	DbCloseAll() 
	
	RddSetDefault ( cDriver )	 
    SetDeleted(lSet)
	
	RETURN	
FUNCTION TestFreezeFilterDesc() AS VOID

LOCAL cPath AS STRING
LOCAL cDbf AS STRING
cPath := "C:\test\"
cDbf := "mydbf"
? FErase ( cPath + cDbf + ".dbf" )
? FErase ( cPath + cDbf + ".cdx" )

RddSetDefault ( "DBFCDX" )
DbCreate(cPath + cDbf,{{"FIRST" , "C" , 10,0}})

DbUseArea(,"DBFCDX" , cPath + cDbf)
DbAppend()
FieldPut(1,"Karl-Heinz")
DbAppend()
FieldPut(1,"Robert")
DbAppend()
FieldPut(1,"Chris")
DbAppend()
FieldPut(1,"Karl")
DbGoTop()

? OrdCondSet(,,,,,,,,,,TRUE) // descending
? DbCreateOrder( "ORDER1" , cDbf + ".cdx" , "upper(FIRST)" , { || Upper (_FIELD->FIRST) } )

DbSetOrder(1)
DbGoTop()

DbSetFilter(,"upper(FIRST) = '" + "K" + "'" )
DbGoTop()
? Recno(), _FIELD->FIRST
DbSkip(1)
? Recno(), _FIELD->FIRST

DbGoTop()

LOCAL uRetVal AS USUAL
// program freeze here:
? VoDbOrderInfo( DBOI_POSITION, "", NIL, REF uRetVal )
? uRetVal
DbSkip(1)
? VoDbOrderInfo( DBOI_POSITION, "", NIL, REF uRetVal )
? uRetVal

RETURN



FUNCTION testGoTopGoTopCdx AS VOID
LOCAL cPath AS STRING
LOCAL cDbf AS STRING
cPath := "C:\test\"
cDbf := "mydbf"
? FErase ( cPath + cDbf + ".dbf" )
? FErase ( cPath + cDbf + ".cdx" )

RddSetDefault ( "DBFCDX" )
DbCreate(cPath + cDbf,{{"LAST" , "C" , 10,0}})
DbUseArea(,"DBFCDX" , cPath + cDbf)
FOR LOCAL n := 1 AS INT UPTO 1000
    DbAppend()
    FieldPut(1,"A"+AsString(n % 77))
NEXT
? DbCreateOrder( "ORDER1" , cDbf + ".cdx" , "upper(LAST)" , { || Upper ( _FIELD->LAST) } )
? DbCloseArea()

DbUseArea(,"DBFCDX" , cPath + cDbf)
DbGoTop()
DbGoTop()
LOCAL nCount := 0 AS INT
DO WHILE .NOT. VoDbEof()
    nCount ++
    // ? FieldGet(1), RecNo()
    DbSkip()
END DO
? "Count=", nCount // only 80
DbCloseArea()

FUNCTION TestFptCreate() AS VOID
    LOCAL aStruct AS ARRAY
    aStruct := { ;
        {"NUMBER","N", 10, 0} ,;
        {"MEMO","M", 10, 0} }
    DbCreate("C:\test\testFpt",aStruct, "DBFCDX")
    DbCLoseArea()
    DbUseArea(TRUE, "DBFCDX", "C:\test\testFpt", "TEST")
    FOR VAR i := 1 TO 10
        DbAppend()
        FieldPut(1, i)
        FieldPut(2, Repl("X", 10))
    NEXT
    DbCommit()
    DbCloseArea()
    RETURN

FUNCTION DescartesDbfTest AS VOID
	RDDSetDefault("DBFVFP")
	DbUseArea(TRUE, "DBFVFP", "c:\Descartes\testdbf\ZENSTATS.DBF","ZENSTATS")
    DbSetIndex("c:\Descartes\testdbf\ZENSTATS1Gen.NTX")
    DbOrderInfo(DBOI_USER+42)
    DbGoTop()
    ? DbSeek("117682820180906111733")
//    DbOrderInfo(DBOI_USER+42)
//    DbSetIndex("c:\Descartes\testdbf\zenstat2.ntx")
//    DbOrderInfo(DBOI_USER+42)
//    DbSetIndex("c:\Descartes\testdbf\zenstat3.ntx")
//    DbOrderInfo(DBOI_USER+42)
//    DbSetIndex("c:\Descartes\testdbf\zenstat9.ntx")
	FOR VAR i := 1 TO FCount()
        LOCAL oValue AS OBJECT
        oValue := FieldGet(i)
        ? i, oValue
	NEXT
	DBCloseArea()
	RETURN

FUNCTION FptMemoTest() AS VOID
	RDDSetDefault("DBFCDX")
	DbUseArea(TRUE, "DBFCDX", "c:\download\Memos X#\SETUP.DBF","MEMOS")
	FOR VAR i := 1 TO FCount()
        LOCAL oValue AS OBJECT
        oValue := FieldGet(i)
        IF IsArray(oValue)
            ShowArray(oValue, "Field"+Ntrim(i))
        ELSE
            ? i, oValue, FieldGetBytes((LONG) i)
        ENDIF

		
	NEXT
	DBCloseArea()
	RETURN
FUNCTION testDbfFromChris( ) AS VOID
LOCAL f AS FLOAT
f := seconds()
? DbUseArea(,"DBFCDX","C:\test\Foo")
? DbReindex() // null reference exception
? DbSetOrder(1)
? DbGoTop(), RecNo()
? DbGoBottom(), RecNo() // 2905
? DbSetOrder(0)
? DbGoTop(), RecNo()
? DbGoBottom(), RecNo() // 2964
? DbCloseArea()
? Seconds() - f
RETURN
DEFINE records := 50_000
DEFINE changes := 2000
FUNCTION TestIndexUpdates() 
    LOCAL aFields AS ARRAY
    LOCAL cDBF AS STRING
    LOCAL n AS DWORD
    LOCAL c AS STRING
    RddSetDefault("DBFCDX")
    cDBF := "C:\test\cdxtest"
    aFields := { { "LAST" , "C" , 40 , 0 } , { "FIRST" , "C" , 50 , 0 }}
    FErase(cDBF + ".cdx")
    
    DBCREATE( cDBF , AFields)
    
    DBUSEAREA(,,cDBF)
    DBCREATEINDEX(cDBF , "LAST" , {||_FIELD->LAST})
    FOR n := 1 UPTO records
        c := CHR( 65 + ((n * 41) % 26) )
        c := Replicate(c , 1 + ((n * 31) % 35) )
        DBAPPEND()
        FIELDPUT(1, c)
    NEXT
    DbCommit()
    ? "Commited"
    DbOrderInfo(DBOI_USER+42)
    ? "CheckOrder Start"
    CheckOrder()
    ? "CheckOrder Stop"
    WAIT
    _Quit()
    FOR  n := 1 UPTO changes
        VAR nRec := 1 + (n * 13) % (records - 1)
        DbGoto(nRec)
        c := CHR( 65 + ((n * 21) % 26) )
        c := Replicate(c , 1 + ((n * 23) % 35) )
        FIELDPUT(1, c)
    NEXT
    ? "CheckOrder 2"
    CheckOrder()
    DbOrderInfo(DBOI_USER+42)
    DBCLOSEALL()   
    WAIT
RETURN  NIL

PROCEDURE CheckOrder()
    LOCAL nCount := 0 AS INT
    LOCAL cPrev := NULL_STRING AS STRING
    DbGotop()
    DO WHILE .NOT. EOF()
        nCount ++
        IF cPrev != NULL_STRING
            IF cPrev > FIELDGET(1)
                ? "Wrong order at recno", RECNO(), cPrev, FieldGet(1)
            END IF
        END IF
        cPrev := FIELDGET(1)
        DBSKIP(1)
    END DO
    
    IF nCount != records
        ? "Wrong record count", nCount
    END IF
    
RETURN  

FUNCTION TestVFPFiles() AS VOID
LOCAL cDbf AS STRING
LOCAL aStruct AS ARRAY
RddSetDefault("DBFCDX")
//RddInfo(SET.AUTOOPEN, FALSE)
cDbf := "c:\test\bldquery.vcx"
cDbf := "c:\test\solution.scx"
cDbf := "c:\test\ADMKERTO.DBC"
DbUseArea(,,cDbf)
aStruct := DbStruct()
DbSetOrder(1)

DbSetFilter(,"ObjectType='Table'")
DbGoTop()
DO WHILE ! eof()
    ? recno()
    FOREACH aField AS ARRAY IN aStruct
        ?? /*aField[1], ":", */IIF(aField[1] != "OBJCODE", Trim(AsString(FieldGetSym(aField[1]))), "<binary>"),""
    NEXT
    ?
    DbSkip(1)
ENDDO
RETURN



FUNCTION TestOrdNameInvalid() AS VOID
LOCAL cDBF AS STRING
LOCAL aFields, aValues AS ARRAY
LOCAL i AS DWORD

RDDSetDefault ( "DBFNTX" )

aFields := { { "LAST" , "C" , 20 , 0 }}
aValues := { "b" , "c" , "d", "e" , "a" }

cDBF := "C:\test\mydbf"

? "Ferase" , FErase ( cDBF + IndexExt() )
// -----------------
? DBCreate( cDBF , AFields)
? DBUseArea(,,cDBF )

FOR i := 1 UPTO ALen ( aValues )
DBAppend()
FieldPut ( 1 , aValues [ i ] )
NEXT

FOR i := 1 UPTO 3
? DBCreateOrder ( "ORDER" +NTrim ( i ) , cDBF+NTrim ( i ) , "upper(LAST)" , { ||Upper ( _FIELD->LAST) } )
NEXT
DbClearIndex()
OrdListAdd(cDBF+"1")
OrdListAdd(cDBF+"2")
OrdListAdd(cDBF+"3")
?
DBSetOrder ( 2 )
? OrdBagName ( 1 ) // ok
? OrdBagName ( 2 ) // ok
? OrdBagName ( 3 ) // ok
? OrdBagName ( "order1" ) // ok
? OrdBagName ( 4 ) // order doesn/t exist, must return ""
? OrdBagName ( "order4" ) // order doesn/t exist, must return ""
?
? OrdNumber ( "order4") // order doesn/t exist, must return 0 instead of 2
? OrdNumber ( 4 ) // order doesn/t exist, must return 0 instead of 2
? OrdNumber() // ok , current order is 2
?
? OrdName() // ok, "ORDER2" is the current order
? OrdName(3) // ok, "ORDER3"
? OrdName("ORDER3") // ok, "ORDER3"
? OrdName(4) // order doesn/t exist, must return ""
? OrdName("ORDER4") // order doesn/t exist, must return ""

DBCloseAll()
RETURN

FUNCTION AevalNil() AS VOID
LOCAL aArr AS ARRAY

aArr := {1,2,3}
AEval(aArr, {|x| Console.WriteLine((INT)x)},NIL,NIL) 
RETURN

FUNCTION testFptMemo() AS VOID
LOCAL aFields AS ARRAY
LOCAL cDBF AS STRING

RDDSetDefault("DBFCDX")
cDBF := "c:\test\mytest"
aFields := { { "LAST" , "C" , 20 , 0 } , ;
{ "COMMENTS" , "M" , 10 , 0 }}
FErase(cDBF + ".dbt")
FErase(cDBF + ".fpt")

? DBCreate( cDBF , AFields) // generates .dbt file
// ? DBCreate( cDBF , AFields , "DBFCDX") // same

? File(cDBF + ".dbt")
? File(cDBF + ".fpt")

IF File(cDBF + ".dbt")
    FRename(cDBF + ".dbt",cDBF + ".fpt")
END IF
? DBUseArea(,,cDBF) // fails because it searchs for a .dbt file
DBCloseAll()
RETURN 

FUNCTION testUpdateCdx AS VOID
	LOCAL cDBF AS STRING
	LOCAL aFields, aValues AS ARRAY 
	LOCAL cPrev AS STRING
	LOCAL nCount AS INT
	LOCAL i AS DWORD
	
	RDDSetDefault ( "DBFCDX" )
	
	aFields := { { "NUM" , "N" , 8 , 0 },{ "LAST" , "C" , 100 , 0 }} 
	aValues := { "b" , "c" , "d", "e" , "a" , "r" , "t" , "g" , "m" , "n" , "t" , "b" , "h" , "f" , "y", "r", "t", "y", "z", "v", "e", "r", "b", "z", "b", "m", "w", "e" }
	
	cDBF := "C:\test\mycdx"
	? "Ferase" , FErase ( cDbf + IndexExt() )       

	DBCreate( cDBF , AFields)
	DBUseArea(,,cDBF )
	FOR i := 1 UPTO ALen ( aValues )
		DBAppend()
		FieldPut ( 1 , i )                                      
		FieldPut ( 2 , Replicate( aValues [ i ] , 50) )
	NEXT
	DBCreateIndex ( cDBF , "NUM" , {||_FIELD->NUM})
	DBCreateOrder ( "LAST" , cDBF , "LAST" , {||_FIELD->LAST})
	DBCloseAll()
	

	DBUseArea(,,cDBF )
	DBSetOrder(2)
	DBGoBottom()
	
	FieldPut(2, "a")
	DBSkip(-5)
	FieldPut(2, "d")
	DBSkip(5)
	FieldPut(2, "z")
	

	cPrev := NULL
	nCount := 0
	DBGoTop()
	DO WHILE .NOT. EoF()
		nCount ++
		? AllTrim(FieldGet(2))
		IF cPrev != NULL
			IF .NOT. (cPrev <= FieldGet(2))
				? " *** incorrect order ***"
			ENDIF
		END IF
		cPrev := FieldGet(2)
		DBSkip()
	END DO
	? ALen(aValues), nCount
	?
	? "no order"
	DBSetOrder(0)
	DBGoTop()
	DO WHILE .NOT. EoF()
		? AllTrim(FieldGet(2))
		DBSkip()
	END DO

	DBCloseArea()
RETURN

FUNCTION testOverflow() AS VOID
LOCAL cDBF AS STRING

cDBF := "c:\test\test"
FErase(cDBF + ".ntx")
FErase(cDBF + ".cdx")

RDDSetDefault("DBFNTX")

DBCreate( cDBF , {{ "AGE" , "N" , 4 , 1 }})
DBUseArea(,,cDBF, ,FALSE)
DBAppend()
FieldPut(1,12345)

? FieldGet(1) // exception

DBCreateIndex( cDbf, "age" ) // exception

DBCloseArea()
RETURN


FUNCTION TestIndexNoExtension AS VOID
LOCAL cDBF, cPfad, cIndex AS STRING
LOCAL aFields, aValues AS ARRAY
LOCAL i AS DWORD

RDDSetDefault("DBFNTX")
RDDSetDefault("DBFCDX")
aFields := { { "LAST" , "C" , 20 , 0 }}
aValues := { "b" , "c" , "d", "e" , "a" }

cPfad := "c:\test\"
cDBF := cPfad + "Foo"
cIndex := cPfad + "Foox"
? "Ferase" , FErase ( cIndex + IndexExt() )

? DBCreate( cDBF , AFields)
? DBUseArea(,,cDBF)
FOR i := 1 UPTO ALen ( aValues )
DBAppend()
FieldPut ( 1 , aValues [ i ] )
NEXT
? DBCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper (_FIELD->LAST) } )
? DBCloseAll()
? "Open oDB"

// When ".cdx" is added SetIndex() returns true
// cIndex := cIndex + IndexExt()
? DBUseArea(,,cDBF)
? VODBOrdListAdd(cIndex , NIL) // Returns FALSE, error
? DBCloseAll()
RETURN
FUNCTION TestRelation() AS VOID
 LOCAL cDBF1, cDBf2 AS STRING
LOCAL cINdex1, cINdex2 AS STRING
LOCAL cPfad AS STRING
LOCAL aFields, aValues AS ARRAY
LOCAL i AS DWORD

cPfad := "C:\TEST\" // "c:\xide\projects\project1\bin\debug\"
cDBF1 := cPfad + "relation1"
cDBf2 := cPfad + "relation2"

cINdex1 := cPfad + "relation1"
cINdex2 := cPfad + "relation2"
// ------- create Parent DBF --------------
aFields := { { "ID" , "C" , 5 , 0 }}

aValues := { "00002" , "00001" , "00003" }

? DBCREATE( cDBF1 , AFields)
? DBUSEAREA(,"DBFCDX",cDBF1 )

FOR i := 1 UPTO ALen ( aValues )
DBAPPEND()
FIELDPUT ( 1 , aValues [ i ] )
NEXT

? DBCREATEINDEX( cINdex1, "ID" )

// ------- create Child DBF --------------
aFields := { { "ID" , "C" , 5 , 0 },;
	{ "TEXT1" , "C" ,20 , 0 }}
aValues := { { "00002" , "Text1 00002" } , { "00001" , "Text2 00001" }, { "00001" , "Text1 00001"} ,;
{ "00001" , "Text3 00001" } , {"00003" , "Text1 00003" } , { "00002" , "Text2 00002"} ,;
{ "00003" , "Text3 00003" } , {"00002" , "Text3 00002" } , { "00001" , "Text4 00001"} ,;
{ "00003" , "Text2 00003" } , {"00003" , "Text4 00003" } }

? DBCREATE( cDBf2 , AFields)
? DBUSEAREA(,"DBFCDX",cDBf2 )

FOR i := 1 UPTO ALen ( aValues )
DBAPPEND()
FIELDPUT ( 1 , aValues [ i , 1 ] )
FIELDPUT ( 2 , aValues [ i , 2 ] )
NEXT

? DBCREATEINDEX( cINdex2, "ID + TEXT1" )

DBCloseAll()

// ------------------------
// open Parent DBF

? DBUseArea(TRUE ,"DBFNTX",cDBF1 )
? DBSetIndex( cINdex1 )
? DBSetOrder ( 1 )
? DBGoTop()

// open Child DBF
? DBUseArea(TRUE,"DBFNTX",cDBf2 )
? DBSetIndex( cINdex2 )
? DBSetOrder ( 1 )

DBSetSelect ( 1 )
// set the relation to the common field ID
? DBSetRelation(2, {|| _FIELD->ID } , "ID" )
?
DO WHILE ! a->EOF()
    DO WHILE a->FieldGet ( 1 ) == b->FieldGet ( 1 ) 

        // excepion here. Removing it makes DO WHILE never end
        ? a->FieldGet ( 1 ) , b->FieldGet ( 1 ) ,b->FieldGet ( 2 )
        b->DBSkip(1)
    ENDDO
    ?
    a->DBSkip(1)
ENDDO

DBCLOSEALL()
FUNCTION TestCustomIndex AS VOID
LOCAL cDBF, cPfad, cIndex, cDriver AS STRING
LOCAL aFields, aValues AS ARRAY
LOCAL i AS DWORD

cDriver := RddSetDefault ( "DBFCDX" )

aFields := { { "LAST" , "C" , 20 , 0 }}

aValues := { "Goethe" , "Goldmann" , "Ober",;
"Osterreich" , "Gothe" , "Gotz" , "Gobel" ,;
"Otter" , "Anfang" , "Art" , "Arger" }

cPfad := "c:\test\"
cDBF := cPfad + "Foo"
cIndex := cPfad + "Foox"

FErase ( cIndex + INDEXEXT() )
// -----------------
? DBCREATE( cDBF , AFields)
? DBUSEAREA(,"DBFCDX",cDBF )
FOR i := 1 UPTO ALen ( aValues )
DBAPPEND()
FIELDPUT ( 1 , aValues [ i ] )
NEXT

FOR i := 1 UPTO 2
DBSETORDERCONDITION()
IF i == 2
// second order should be a custom order.
DBSETORDERCONDITION(,,,,,,,,,,,,, TRUE)
ENDIF
? DBCREATEORDER ( "ORDER"+ NTrim(i) , cIndex , "upper(LAST)" , { ||Upper ( _FIELD->LAST) } )
// ? OrdCreate(cIndex, "ORDER"+NTrim(i), "upper(LAST)", { || Upper ( _Field->LAST) } ) // ok
NEXT

?
? DbSetOrder ( 1 )
? OrdName() // "ORDER1" ok
? ORDNUMBER() // 1 ok
? ORDKEY(1) // "UPPER(LAST)" ok
? DbOrderInfo ( DBOI_CUSTOM ) // returns FALSE ok
? DbOrderInfo ( DBOI_KEYCOUNT ) // ok, shows 11
? OrdKeyCount( 1 , cIndex ) // ok, shows 11
? OrdKeyCount( "ORDER1" , cIndex) // ok, shows 11
? OrdKeyCount( 1 )
? OrdKeyCount()
?
? DbSetOrder ( 2 )
? OrdName() // "ORDER2" ok
? OrdNumber() // 2 ok
? OrdKey(2) // "UPPER(LAST)" ok
? DBOrderInfo ( DBOI_CUSTOM ) // NOTE: returns FALSE instead of TRUE
? DBOrderInfo ( DBOI_KEYCOUNT ) // NOTE: shows 11 instead of 0
? OrdKeyCount( 2 , cIndex ) // NOTE: shows 11 instead of 0
? OrdKeyCount( "ORDER2" , cIndex) // NOTE: shows 11 instead of 0
? OrdKeyCount( 2 )
? OrdKeyCount()

?
? IndexCount() // 2 ok
?

// NOTE: ORDDESTROY() problem. if the order doesn´t exist the func returns TRUE and
// seems to do nothing. VO throws an error if a order doesn´exist.
? OrdDestroy("ORDER4") // NOTE: "ORDER4" does not exist
? IndexCount()
? IndexOrd()

DBCloseAll()

RddSetDefault ( cDriver )
RETURN
FUNCTION testOrdDescend() AS VOID
LOCAL cDBF, cPfad, cIndex, cDriver AS STRING
LOCAL aFields, aValues AS ARRAY
LOCAL i AS DWORD
cDriver := RDDSetDefault ( "DBFCDX" )
aFields := { { "LAST" , "C" , 20 , 0 }}
aValues := { "b" , "d" , "c", "e" , "a" }
cPfad := "c:\test\"
cDBF := cPfad + "Foo"
cIndex := cPfad + "Foox"
FErase ( cIndex + IndexExt() )
// -----------------
? DBCreate( cDBF , AFields)
? DBUseArea(,"DBFCDX",cDBF )
FOR i := 1 UPTO ALen ( aValues )
DBAppend()
FieldPut ( 1 , aValues [ i ] )
NEXT

? DBCreateOrder ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper(_FIELD->LAST) } )
? DBSetOrder ( 1 )
?
? "IsDesc" ,DBOrderInfo(DBOI_ISDESC) // false, correct
DBGoTop()
DO WHILE ! EOF()
// 5,1,3,2,4 correct
? FieldGet ( 1 ) , RecNo()
DBSkip(1)
ENDDO
?

? OrdDescend ( ,, TRUE )
? "IsDesc" ,DBOrderInfo(DBOI_ISDESC) // false, wrong

?
DBGoTop()
DO WHILE ! EOF()
// 5,1,3,2,4 again, wrong, should be 4,2,3,1,5
? FieldGet ( 1 ) , RecNo()
DBSkip(1)
ENDDO
DBCloseAll()
RDDSetDefault ( cDriver ) 

FUNCTION testScopeDescend() AS VOID
LOCAL cDbf AS STRING
cDBF := "testdbf"

DBCreate( cDBF , {{"FIELDN" , "N" ,5 , 0 } } )
DBUseArea(,"DBFCDX",cDBF)
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
DBOrderInfo( DBOI_SCOPEBOTTOM, "", NIL,2 )

// prints 3,2,1. If the order of scopes is
// changed to 2->3, then it prints 2,1
? "Down"
DbGotop()
DO WHILE .NOT. EOF()
    ? "val",FIELDGET(1) , "#",RECNO()
    DBSKIP()
ENDDO

? "Up"
DbGoBottom()
DO WHILE .NOT. BOF()
    ? "val",FIELDGET(1) , "#",RECNO()
    DBSKIP(-1)
ENDDO
? "Clear scopes"
DBOrderInfo( DBOI_SCOPETOPCLEAR )
DBOrderInfo( DBOI_SCOPEBOTTOMCLEAR)
? "Down"
DbGotop()
DO WHILE .NOT. EOF()
    ? "val",FIELDGET(1) , "#",RECNO()
    DBSKIP()
ENDDO

? "Up"
DbGoBottom()
DO WHILE .NOT. BOF()
    ? "val",FIELDGET(1) , "#",RECNO()
    DBSKIP(-1)
ENDDO

DBCloseArea()

FUNCTION testscope AS VOID
LOCAL cDBF AS STRING
LOCAL aFields, aValues AS ARRAY
LOCAL i AS DWORD

//RDDSetDefault("DBFNTX")
RDDSetDefault("DBFCDX")

cDbf := "C:\test\mycdx"
FErase(cDbf + ".ntx")
FErase(cDbf + ".cdx")

aValues := {"Gas" , "Abc", "Golden" , "Guru" , "Ddd" , "Aaa" , "Ggg"}
aFields := { {"CFIELD" , "C" , 10 , 0} }

DBCreate(cDbf , aFields)
DBUseArea(,,cDBF)
DBCreateIndex(cDbf , "Upper(CFIELD)")
FOR i := 1 UPTO ALen(aValues)
DBAppend()
FieldPut(1, aValues[i])
NEXT

DBGoTop()
? DBOrderInfo( DBOI_KEYCOUNT ) // 7, correct

? "Setting order scope"
OrdScope(TOPSCOPE, "G")
OrdScope(BOTTOMSCOPE, "G")
DBGoTop()

// X#: -2 with both CDX and NTX
// VO: -2 with NTX, 4 with CDX
? DBOrderInfo( DBOI_KEYCOUNT )

? DBSeek("G") // TRUE, correct
? DBSeek("GOLD") // TRUE with NTX, FALSE with CDX. VO TRUE in both

? "Clearing order scope"
OrdScope(TOPSCOPE, NIL)
OrdScope(BOTTOMSCOPE, NIL)
? DBOrderInfo( DBOI_KEYCOUNT )
? DBSeek("G")
? DBSeek("GOLD")

? "Setting order scope again"
OrdScope(TOPSCOPE, "G")
OrdScope(BOTTOMSCOPE, "G")
DBGoTop()
? DBOrderInfo( DBOI_KEYCOUNT )
? DBSeek("G")
? DBSeek("GOLD")

DBCloseArea()
RETURN
FUNCTION TestRebuild() AS VOID
LOCAL cDBF, cPfad, cIndex  AS STRING
LOCAL aFields, aValues AS ARRAY
LOCAL i AS DWORD
LOCAL lSHared AS LOGIC

lSHared := TRUE

RddSetDefault ( "DBFCDX" )

aFields := { { "LAST" , "C" , 20 , 0 }}
aValues := { "b" , "d" , "c", "e" , "a" }

cPfad := "C:\test\"
cDBF := cPfad + "Foo"
cIndex := cPfad + "Foox"

FErase ( cIndex + INDEXEXT() )

DBCREATE( cDBF , AFields)
DBUSEAREA(,"DBFNTX",cDBF , , lSHared )
FOR i := 1 UPTO ALen ( aValues )
DBAPPEND()
FIELDPUT ( 1 , aValues [ i ] )
NEXT

? DBCREATEORDER ( "ORDER1" , cIndex , "upper(LAST)" , { || Upper (_FIELD->LAST) } )

? DbSetOrder ( 1 )

// DBReindex()
//
// When the DBF is opened shared VO throws an "Shared error",
// while X# seems to allow a reindex , no matter if the DBF is openedshared or not.

? "Reindex", DBDRIVER(), DbReindex()

DBCLOSEALL()   
FUNCTION Test__Str AS VOID
    LOCAL r := 1.2354 AS REAL8
    ? __str(r,-1,-1)
    WAIT
    RETURN

FUNCTION testOptValue() AS VOID STRICT

       

    LOCAL oTEst AS TestOpt

    LOCAL oObject AS OBJECT

   

    oTest := TestOpt{}

    oOBject := TestOpt{}

   

    oTest:SetStyle(1)  //Default param is TRUE

    oOBject:SetStyle(1) //Default param is FALSE

    

    RETURN     

 

 

    CLASS TestOpt

       

        METHOD SetStyle(liStyle AS INT,lEnableStyle := TRUE AS LOGIC) AS VOID

       

        LOCAL lTest AS LOGIC

       

        lTest := lEnableStyle
        ? lTest

       

        RETURN

        

    END CLASS    
    FUNCTION TestReal8Abs AS VOID
        
        LOCAL rReal1, rReal2 AS REAL8        
        LOCAL uUsual AS USUAL
        LOCAL c1, c2 AS STRING
        LOCAL nMenge1 := 1 AS INT
        nMenge1 := Integer(nMenge1)
        rReal1 := 10.25
               
        uUsual := rReal1 //Decimals -1 - not evaluated?
        c1 := NTRIM(uUsual) //10.25
       
        rReal2 := Abs(rReal1)  // 10.25 - OK
        uUsual := Abs(rReal1) // Problem - FLOAT 10, Value is 10.25 but DECIMALS is 0
        
        c2 := NTRIM(uUsual) //10
        ? c1, c2
        WAIT

    FUNCTION TestIvarGet() AS VOID
    LOCAL n := 0 AS INT
    LOCAL c := "abc" AS STRING
    LOCAL uNil := NIL AS USUAL
    ? n == NIL
    ? n == uNil
    ? NIL == n
    ? uNil == n
    
    ? uNil == c
    ? c == NIL
    ? c == uNil
    
    LOCAL o AS USUAL
    o := TestClass{}
    ? o:NilMethod() == 1
    ? o:NilMethodUntyped() == 1
    ? o:NilMethodUntyped() == c

    ? o:NilAccess == 1
    ? o:NilAccess == ""

    ? o:DoesNotExistAccess == 1
    ? o:DoesNotExistMethod() == 1

    ? o:DoesNotExistMethodNil() == 1
    ? o:DoesNotExistMethodNil() == "abc"

    ? o:DoesNotExistAccessNil == 1 // exception here "Value does not fall within the expected range."
    ? o:DoesNotExistAccessNil == "abc" // exception
    ? o:DoesNotExistAccessNil == n // exception

    ? o:DoesNotExistAccessNil == NIL // OK, TRUE
RETURN

CLASS TestClass
    METHOD NilMethod() AS USUAL
    RETURN NIL
    METHOD NilMethodUntyped()
    RETURN NIL
    
    ACCESS NilAccess
    RETURN NIL
    
    METHOD NoMethod(c)
        ? c
        IF AsString(c) == "DOESNOTEXISTMETHOD"
            RETURN 2
        END IF
    RETURN NIL
    METHOD NoIVarGet(c)
        ? c
        IF AsString(c) == "DOESNOTEXISTACCESS"
            RETURN 2
        END IF
    RETURN NIL
END CLASS

FUNCTION testUnlock() AS VOID
LOCAL cDBF,cPath AS STRING
LOCAL aFields, aValues AS ARRAY
LOCAL i AS DWORD

RDDSetDefault("DBFCDX")
SetExclusive( FALSE )

cPath := "C:\TEST\"
cDBF := cPath + "small"
FErase(cDBF)
FErase(cDBF + ".cdx")

aFields := { { "CFIELD" , "C" , 5 , 0 }}
aValues := { "AAA" , "CCC" , "BBB" }

? DBCreate( cDBF , AFields)
? DBUseArea(,"DBFCDX",cDBF )
FOR i := 1 UPTO ALen(aValues)
DBAppend()
FieldPut(1 , aValues[i])
NEXT
? DBCreateIndex(cDbf , "CFIELD")
DBCloseAll()


? DBUseArea(,"DBFCDX",cDBF )
DBGoTop()
DBSkip()
? RecNo(), FieldGet(1)

? DBRLock()
? DBDelete()
? DBUnlock() // StackOverflow here

DBCloseAll()
RETURN
FUNCTION testDelete() AS VOID
LOCAL cDBF,cPath AS STRING
LOCAL AFields AS ARRAY
//LOCAL i AS DWORD

cPath := "C:\TEST\" // "c:\xide\projects\project1\bin\debug\"
cDBF := cPath + "mydbf"
// ------- create Parent DBF --------------
AFields := { { "ID" , "C" , 5 , 0 }}

RDDSetDefault("DBFNTX")
? DBCreate( cDBF , AFields)
? DBUseArea(,"DBFNTX",cDBF )
? DBCreateIndex(cDbf , "ID")

DBGoTop()
? RecNo(), FieldGet(1)

? DBRLock()
? DBDelete()
? DBUnlock()

DBCloseAll()
RETURN

FUNCTION testUnique2() AS VOID
LOCAL cDBF, cPfad, cIndex, cDriver AS STRING
LOCAL aFields, aValues AS ARRAY
LOCAL i AS DWORD
LOCAL lUnique AS LOGIC
cDriver := RDDSetDefault ( "DBFCDX" )
lUnique := SetUnique()

aFields := { { "LAST" , "C" , 20 , 0 }}
aValues := { "a" , "d" , "f", "c" }

cPfad := "C:\test\"
cDBF := cPfad + "Foo"
cIndex := cPfad + "Foox"

FErase ( cIndex + IndexExt() )
// -----------------
? DBCreate( cDBF , AFields)
? DBUseArea(,"DBFCDX",cDBF )
FOR i := 1 UPTO ALen ( aValues )
DBAppend()
FieldPut ( 1 , aValues [ i ] )
NEXT


OrdCondSet()
OrdCreate(cIndex, "ORDER1", "upper(LAST)", { || Upper ( _FIELD-> LAST) } )
DBSetOrder ( 1 )
? OrdName() // "ORDER1"
? "OrdIsUnique() unique", OrdIsUnique() // always returns true !
? "DBOrderinfo unique", DBOrderInfo(DBOI_UNIQUE ) // ok
? "desc" , DBOrderInfo(DBOI_ISDESC ) // ok
?

OrdCondSet()
// create a descend and unique order
? OrdCondSet(,,,,,,,,,,TRUE)
SetUnique ( TRUE )
OrdCreate(cIndex, "ORDER2", "upper(LAST)", { || Upper ( _FIELD-> LAST) } )

DBSetOrder ( 2 )
? OrdName() // "ORDER2"
? "OrdIsUnique() unique", OrdIsUnique() // always returns true !
? "DBOrderinfo unique", DBOrderInfo(DBOI_UNIQUE ) // ok
? "desc" , DBOrderInfo(DBOI_ISDESC ) // ok
DBCloseAll()
RDDSetDefault ( cDriver )
SetUnique ( lUnique )
RETURN 
DEFINE LANG_GERMAN := 0x07
DEFINE SUBLANG_GERMAN := 0x01 // German
DEFINE SORT_DEFAULT := 0x0 // sorting default
DEFINE SORT_GERMAN_PHONE_BOOK := 0x1 // German Phone Book order
    FUNCTION TestCrypt() AS VOID
        LOCAL cRes AS STRING
	    LOCAL pRes AS BYTE PTR 
	    ? cRes := Crypt("abc", "def")
	    pRes := StringAlloc(cRes)
	    ? pRes[1], pRes[2], pRes[3]
	    MemFree(pRes)
        cRes := Crypt(cRes, "def")
        ? cRes
	    WAIT
        RETURN
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

FUNCTION TestCopyStruct() AS VOID
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

FUNCTION TestDbf() AS VOID
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


FUNCTION TestUnique() AS VOID
LOCAL cDbf AS STRING
LOCAL aFields AS ARRAY
LOCAL nMax := 1000 AS LONG
LOCAL nCnt AS LONG
cDBF := "Foo"
aFields := {{ "NAME" , "C" , 10 , 0 }}
DBCreate( cDBF , aFields,"DBFCDX")
DBCloseAll()
DBUseArea( TRUE ,"DBFCDX",cDBF,"Foo",FALSE)
FOR VAR i := 1 TO nMax
    DbAppend()
    FieldPut(1, str(i,10,0))
NEXT
DbCreateIndex("Foo","Name",,TRUE)
DbGoTop()
DO WHILE ! EOF()
    ? Recno(), FieldGet(1)
    DbSkip(1)
ENDDO
WAIT
FOR VAR i := 1 TO nMax
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
WAIT
FOR VAR i := 1 TO nMax
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
RETURN




FUNCTION WaTest() AS VOID
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
? DBSymSelect( 1 ) // X# doesn´t throw a exceptions but returns 0

// e.g. VO throws an Data Type Error. type: string requested type: symbol
? DBSymSelect( "Foo1" ) // X# doesn´t throw a exceptions but returns 1

// e.g. VO throws an Data Type Error . type: codeblock requested type: symbol
? DBSymSelect( {|| } ) // X# doesn´t throw a exceptions but returns 0

DBCloseAll()
RETURN

FUNCTION BigDbf AS VOID
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
// DBUSEAREA() doesn ´t crash
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

FUNCTION TestClearOrderScope AS VOID
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
LOCAL f AS FLOAT
LOCAL nMax := 50000 AS LONG
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
SetAppLocaleID(MAKELCID(MAKELANGID(LANG_GERMAN, SUBLANG_GERMAN),SORT_DEFAULT)) // Wörterbuch

DBCreate(cDbf , {{"LAST","C",10,0}})
DBUseArea(,,cDBF)
DBAppend()
FieldPut(1 , "Ärger")
DBAppend()
FieldPut(1 , "Aaaaa")
DBCloseArea()


DBUseArea(,,cDBF)
DBCreateIndex(cDbf , "LAST")
? DBSeek("Ä") // FALSE in X#, TRUE in VO
? Recno(), Found(), FieldGet(1)
? DBSeek("Ärger") // TRUE in both
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
LOCAL aClon AS ARRAY
LOCAL i AS DWORD
LOCAL f AS FLOAT
f := Seconds()
? "Creating tags"
cDBF := "c:\test\Test10k"
RddSetDefault("DBFCDX")
aTags := {"AGE","CITY","FIRST","HIREDATE", "LAST","SALARY","STATE"}
cIndex := cDBF
Ferase(cIndex+".CDX")
FOR i := 1 TO ALen(aTags)
	VODBUSEAREA(TRUE,"DBFCDX",cDBF,"Test",FALSE,FALSE)
	aClon := AClone(aTags)
	ASize(aClon, i)
	AEval(aClon , {|cTag|  OrdCreate(cIndex, cTag, cTag) })
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
    LOCAL f AS FLOAT
    f := Seconds()
    ? VoDbUseArea(TRUE, "DBFCDX", "c:\XSharp\DevRt\Runtime\XSharp.Rdd.Tests\dbfs\TEST10K.DBF", "TEST",FALSE,FALSE)
    ? DbReindex()
    ? Seconds() - f
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
            LOCAL u := NIL AS USUAL
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



FUNCTION DumpDbfCdx(cFile AS STRING) AS VOID
    ? "Dumping index info for ", cFile
    RddSetDefault("DBFCDX")
    DBUSEAREA(TRUE, "DBFCDX", cFile, "test", FALSE)
    FOR VAR i := 1 TO DbOrderInfo(DBOI_ORDERCOUNT)
        DbSetOrder(i)
        VAR d = datetime.Now
        ? OrdName(), OrdKeyCount(), RecCount()
        LOCAL ts := DateTime.Now - d AS TimeSPan
        ? ts:Milliseconds, ts:Seconds
        DbOrderInfo(DBOI_USER+42)
    NEXT
    DbCloseArea()
    RETURN

FUNCTION DumpKeesFiles() AS STRING
DumpDbfCdx("c:\download\KeesB\ORDERS.DBF")
DumpDbfCdx("c:\download\KeesB\Seek_ORDERS.DBF")
RETURN ""
