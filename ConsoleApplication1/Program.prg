﻿USING System
USING System.Collections
USING System.Collections.Generic
USING System.Linq
USING System.Data
USING System.Text
USING XSharp.Data
USING XSharp.RDD
USING System.Windows.Forms
USING System.Drawing

FUNCTION Start() AS VOID STRICT
TRY
    DbUseArea(TRUE,"DBFCDX","c:\cavo28SP3\Samples\Email\EMAIL.DBF")
    ? DbSetOrder(2)
    ? DbOrderInfo(DBOI_ORDERCOUNT)
    DbCloseArea()
    //TestProviders()
    //TestProvidersStringConnect()
    //TestBatch()
    //Test3Results()
    //testTransaction()
    
    // testMetaData()
    // testDataTable()
    //testHandles()
    //testAsynchronous()
    //testConnect()
    //testRddBrowse()
    //testCopyTo()
    //testDbSetOrder()
    //testSqlParameters()
    //testPG()
    //testExec2()
    //testFile()
    
CATCH e AS Exception
    ? MessageBox(e:ToString(), MB_ICONSTOP+MB_OK,"An error has occurred")
END TRY
WAIT
RETURN

FUNCTION TestFile() AS VOID
	? File("C:\temp\abc.def")	// T in X#
	? File("C:\temp\???.def")	// F
	? File("C:\temp\ab?.def")	// F
	? File("C:\temp\*.def")		// F
	? File("C:\temp\ab*.def")	// F

	// those all return FALSE in VO
	? File("C:\temp\ab*.*")	// F
	? File("C:\temp\*.*")	// T
	? File("C:\temp\*")	// T
RETURN

FUNCTION TestProviders() AS VOID STRICT
LOCAL nHandle AS LONG




VAR properties := <STRING>{"asynchronous" , "batchmode" , "connectbusy" , "connectstring" ,"connecttimeout" , "datasource", ;
"disconnectrollback", "displogin", "dispwarnings", "idletimeout" , "odbchdbc", "odbchstmt" ,;
"packetsize" , "password" , "querytimeout" , "shared" , "transactions" , "userid" , "waittime" }
VAR cProviders := <STRING>{"ODBC","OLEDB","SQL"}
VAR oProviders := <ISqlFactory>{XSharp.Data.OdbcFactory{}, XSharp.Data.OleDbFactory{}, XSharp.Data.SqlServerFactory{}}
VAR cConnectionStrings := <STRING>{ ;
"DSN=CURSADM;Trusted_Connection=Yes;",;
e"Provider=SQLNCLI11.1;Integrated Security=SSPI;Initial Catalog=\"CursAdm\";Data Source=(local)",;
"server=(LOCAL);trusted_connection=Yes;app=ConsoleApplication1;wsid=ARTEMIS;database=Cursadm"}
FOR VAR nProvider := 1 TO 3
    VAR oProvider           := oProviders[nProvider]
    VAR cConnectionString   := cConnectionStrings[nProvider]
    VAR f := Seconds()
    Console.Clear()
    SqlSetFactory(oProvider)
    oProvider := SqlSetFactory()
    nHandle := SqlStringConnect(cConnectionString,TRUE)
    ? "Properties for provider "+oProvider:Name
    FOREACH VAR sProp IN Properties
        ? sProp, SqlGetProp(nHandle,sProp )
    NEXT
    LOCAL aInfo AS ARRAY
    aInfo := {}
    ? SQLExec(nHandle, "Select * from CursusGroepen;Select * from Bedrijven;Select * from Personen;","Result",aInfo) // Select * from Bedrijven;Select * from Personen
    ShowArray(aInfo)
    ? seconds() - f
    WAIT
    SqlDisconnect(nHandle)
NEXT
RETURN	

FUNCTION TestProvidersStringConnect() AS VOID STRICT
LOCAL nHandle AS LONG
VAR cProviders := <STRING>{"ODBC","OLEDB","SQL"}
VAR oProviders := <ISqlFactory>{XSharp.Data.OdbcFactory{}, XSharp.Data.OleDbFactory{}, XSharp.Data.SqlServerFactory{}}
Console.Clear()
FOR VAR nProvider := 1 TO 3
    VAR oProvider           := oProviders[nProvider]
    VAR f := Seconds()
    ? "StringConnect for provider", cProviders[nProvider]
    SqlSetFactory(oProvider)
    oProvider := SqlSetFactory()
    nHandle := SqlStringConnect(FALSE)
    ? SqlGetProp(nHandle,"connectstring" )
    SqlDisconnect(nHandle)
NEXT
RETURN	

FUNCTION TestBatch() AS VOID
LOCAL nHandle AS LONG
? "Test more results 3 result sets"
SqlSetFactory("SQLServer")
VAR cConnectionString := "server=(LOCAL);trusted_connection=Yes;app=ConsoleApplication1;wsid=ARTEMIS;database=Cursadm;"
? nHandle := SqlStringConnect(cConnectionString,FALSE)
SqlSetProp(nHandle, "BatchMode", FALSE)
LOCAL aInfo AS ARRAY
aInfo := {}
VAR f := seconds()
SQLExec(nHandle, "Select * from CursusGroepen;Select * from Bedrijven;Select * from Personen;","Result",aInfo) // Select * from Bedrijven;Select * from Personen
ShowArray(aInfo)
DO WHILE SqlMoreResults(nHandle,,aInfo) != 0
    ShowArray(aInfo)
ENDDO
? seconds() - f
SqlDisconnect(nHandle)
RETURN	

FUNCTION Test3results() AS VOID
LOCAL nHandle AS LONG
? "Test single batch with 3 result sets"
SqlSetFactory("SQLServer")
VAR cConnectionString := "server=(LOCAL);trusted_connection=Yes;app=ConsoleApplication1;wsid=ARTEMIS;database=Cursadm;"
? nHandle := SqlStringConnect(cConnectionString,TRUE)
SqlSetProp(nHandle, SQLProperty.BatchMode, TRUE)
SqlSetProp(nHandle, SQLProperty.ConnectTimeOut, 1000)
LOCAL aInfo AS ARRAY
aInfo := {}
VAR f := seconds()
SQLExec(nHandle, "Select * from CursusGroepen;Select * from Bedrijven;Select * from Personen;","Result",aInfo) // Select * from Bedrijven;Select * from Personen
ShowArray(aInfo)
? seconds() - f
SqlDisconnect(nHandle)
RETURN	


FUNCTION TestTransaction() AS VOID
LOCAL nHandle AS LONG
? "Test transaction"
SqlSetFactory("SQLServer")
VAR cConnectionString := "server=(LOCAL);trusted_connection=Yes;database=Northwind;"
? nHandle := SqlStringConnect(cConnectionString,TRUE)
SqlSetProp(nHandle, SQLProperty.Transactions, DB_TRANSMANUAL )
VAR f := seconds()
SQLExec(nHandle, "create table test(test int) ")
? SQLExec(nHandle, "insert into test(test) values(1) ")
? SQLExec(nHandle, "insert into test(test) values(2) ")
? SQLExec(nHandle, "insert into test(test) values(3) ")
? SQLExec(nHandle, "insert into test(test) values(4) ")
? SQLExec(nHandle, "select * from test")
? SqlRollBack(nHandle)
? seconds() - f
SqlDisconnect(nHandle)
Browse()
RETURN	



FUNCTION TestMetaData() AS VOID
LOCAL nHandle AS LONG
? "Test metadata"
SqlSetFactory("sql")
VAR cConnectionString := "server=(LOCAL);trusted_connection=Yes;app=ConsoleApplication1;wsid=ARTEMIS;database=Cursadm;"
//VAR cConnectionString :=e"Provider=SQLNCLI11.1;Integrated Security=SSPI;Initial Catalog=\"CursAdm\";Data Source=(local)"
//VAR cConnectionString :="DSN=CURSADM;Trusted_Connection=Yes;"
? nHandle := SqlStringConnect(cConnectionString,TRUE)
SqlSetProp(nHandle, SQLProperty.Transactions, DB_TRANSMANUAL )
VAR f := seconds()
? SqlColumns(nHandle,"Bedrijven","NATIVE")
DbCopy("C:\temp\ColumnsXNATSQL")
? seconds() - f
f := seconds()
? SqlTables(nHandle,"TABLE,VIEW")
DbCopy("C:\temp\TablesXNATSQL")
? seconds() - f

SqlDisconnect(nHandle)
RETURN	

FUNCTION testDataTable() AS VOID
LOCAL nHandle AS LONG
? "Test datatable"
SqlSetFactory("SQLServer")
VAR cConnectionString := "server=(LOCAL);trusted_connection=Yes;database=NorthWind;"
? nHandle := SqlStringConnect(cConnectionString,TRUE)
SQLExec(nHandle, "Select a.* from Customers a, Customers b","Customers") // Select * from Bedrijven;Select * from Personen
Browse()
RETURN





FUNCTION Browse(oTable AS Object) AS VOID
LOCAL oForm AS Form
LOCAL oGrid AS DataGridView
oForm := Form{}
oForm:Text := "Browse table "+oTable:Name
oGrid := DataGridView{}
oForm:Controls:Add(oGrid)
oGrid:Location := System.Drawing.Point{0,0}
oGrid:Size     := System.Drawing.Size{oForm:Size:Width, oForm:Size:Height - 100}
oGrid:Dock     := DockStyle.Fill
oGrid:DataSource := oTable
oGrid:DataError += DataError
oGrid:KeyDown   += OnKeyDown

FOREACH oCol AS DataGridViewColumn IN oGrid:Columns
    IF oCol:ValueType == typeof(LONG)
        oCol:DefaultCellStyle:Alignment := DataGridViewContentAlignment.TopRight
    ELSEIF oCol:ValueType == typeof(SHORT)
        oCol:DefaultCellStyle:Alignment := DataGridViewContentAlignment.TopRight
    ELSEIF oCol:ValueType == typeof(REAL8)
        oCol:DefaultCellStyle:Alignment := DataGridViewContentAlignment.TopRight
    ELSEIF oCol:ValueType == typeof(System.Decimal)
        oCol:DefaultCellStyle:Alignment := DataGridViewContentAlignment.TopRight
    ELSE
        oCol:DefaultCellStyle:Alignment := DataGridViewContentAlignment.TopLeft
    ENDIF
NEXT
oGrid:AutoSizeRowsMode := DataGridViewAutoSizeRowsMode.None
oGrid:AllowUserToOrderColumns := TRUE
oGrid:AllowUserToResizeColumns := TRUE
oGrid:AllowUserToResizeRows := TRUE
oGrid:RowsDefaultCellStyle:BackColor := Color.LightGray
oGrid:AlternatingRowsDefaultCellStyle:BackColor := Color.White

oForm:Size := System.Drawing.Size{SystemInformation:PrimaryMonitorSize.Width/2, SystemInformation:PrimaryMonitorSize.Height/2}
oForm:ShowDialog()
//FOREACH oRow AS DbDataRow IN oTable:Rows
//    IF oRow:RowState != DataRowState.Unchanged
//        ?oRow:RecNo, oRow:RowState:ToString()
//    ENDIF
//NEXT    

RETURN

FUNCTION OnKeyDown(sender AS OBJECT, e AS KeyEventArgs) AS VOID
IF e:KeyData == Keys.Escape
    LOCAL grid := (DataGridView) sender AS DataGridView
    LOCAL form := (Form) grid:Parent AS Form
    form:Close()
ENDIF
RETURN



FUNCTION DataError(sender AS OBJECT, e AS DataGridViewDataErrorEventArgs) AS VOID
LOCAL ex AS exception
ex := e:Exception
MessageBox(ex:Message,,"Invalid data")
RETURN 



FUNCTION Browse() AS VOID STRICT
LOCAL oSource AS DbDataSource
oSource := DbDataSource()
IF oSource != NULL
    oSource:SupportsSorting := TRUE
    Browse(oSource)
ELSE
    VAR err := XSharp.RuntimeState.LastRddError
    IF err != NULL
        MessageBox(err:ToString(),MB_YESNO,"Error")
    ELSE
        MessageBox("Workarea not in use" ,MB_OK+ MB_ICONSTOP ,"Error")
    ENDIF
ENDIF
RETURN



FUNCTION TestHandles() AS VOID
SqlSetFactory("SQLServer")
VAR cConnectionString := "server=(LOCAL);trusted_connection=Yes;app=ConsoleApplication1;wsid=ARTEMIS;database=Cursadm;"
? SqlStringConnect(cConnectionString,FALSE)
? SqlStringConnect(cConnectionString,FALSE)
? SqlStringConnect(cConnectionString,FALSE)
LOCAL aInfo := {} AS ARRAY
LOCAL nHandle1 AS LONG
? nHandle1 := SqlStringConnect(cConnectionString,TRUE)
? SqlConnect(nHandle1)
? SqlConnect(nHandle1)
aSqlHandles(aInfo, nHandle1)
FOREACH element AS USUAL IN aInfo
    ? element
    ? SqlDisconnect(element)
NEXT
aSqlHandles(aInfo)
SqlDisconnect(0)
FOREACH element AS USUAL IN aInfo
    ? element
    ? SqlDisconnect(element)
NEXT

RETURN	



FUNCTION TestAsynchronous() AS VOID
LOCAL nHandle AS LONG
SqlSetFactory("SQLServer")
VAR cConnectionString := "server=(LOCAL);trusted_connection=Yes;database=Northwind;"
//VAR cConnectionString := "dsn=Northwind;"
? nHandle := SqlStringConnect(cConnectionString,FALSE)
LOCAL aInfo := {} AS ARRAY
LOCAL f := seconds() AS FLOAT
SqlSetProp(nHandle, "Asynchronous", TRUE)
VAR result := SqlExec(nHandle, "exec PPI_Db.dbo.ZoekProject 1, 9999, '' ,1", ,aInfo)
VAR counter := 0
DO WHILE result == 0
    counter += 1
    ? counter
    System.Threading.Thread.Sleep(1000)
    result := SqlExec(nHandle,,,aInfo)
ENDDO
? Seconds() - f, reccount()
ShowArray(aInfo)
IF Used()
Browse()
ENDIF
RETURN	



FUNCTION testConnect()
LOCAL handle AS LONG
TRY
    SqlSetFactory("ODBC")
    ? sqlSetprop(0, SqlProperty.ConnectTimeOut, 1) 
    ? SqlSetProp(0, "Displ",DB_PROMPTCOMPLETE)
    handle := SqlStringConnect("Dsn=Northwind;")
    IF handle > 0
        SqlExec(handle, "Select * from customers","Customers")
        SqlColumns(handle,"Customers","naTiVe")
        Browse()
    endif
CATCH e AS Exception
    ? e:ToString()
END TRY
WAIT

RETURN



FUNCTION testRddBrowse() AS VOID
    DbUseArea(TRUE,"DBFNTX","c:\cavo28SP3\Samples\Gstutor\customer.dbf","Customer",TRUE,TRUE)
    DbSetIndex("c:\cavo28SP3\Samples\Gstutor\CUSTNAME.NTX")
    DbSetIndex("c:\cavo28SP3\Samples\Gstutor\CUSTNO.NTX")
    DbSetOrder(1)
    Browse()
RETURN

FUNCTION TestCopyTo AS VOID
    SqlSetFactory("ODBC")
    ? sqlSetprop(0, SqlProperty.ConnectTimeOut, 1) 
    ? SqlSetProp(0, "Displ",DB_PROMPTCOMPLETE)
    handle := SqlStringConnect("Dsn=Northwind;")
    IF handle > 0
        //SqlColumns(handle,"Orders","native")
        SqlExec(handle, "Select * from orders","orders")
        COPY TO C:\Temp\Temp
    ENDIF

FUNCTION testDbSetOrder() AS VOID
    RddSetDefault("DBFNTX")
    DbCreate("test",{{"Name","C",10,0}})
    DbUseArea(TRUE, "DBFNTX", "test")
    ? DbSetOrder("test")
    ? RuntimeState.LastRddError:ToString()
    DbCloseArea()
    RETURN






FUNCTION TestSqlParameters AS VOID
    SqlSetFactory("ODBC")
    ? sqlSetprop(0, SqlProperty.ConnectTimeOut, 1) 
    ? SqlSetProp(0, "Displ",DB_PROMPTCOMPLETE)
    //SQLSetFactory("SQL")
    //LOCAL handle := SqlStringConnect("server=(LOCAL);trusted_connection=Yes;database=Northwind;")
     SqlSetFactory("ODBC")
     LOCAL handle := SqlStringConnect("Dsn=Northwind;")
    IF handle > 0
        // Declare local. Can be typed or untyped. A memvar would work as well.
        LOCAL CustomerId = 'ALFKI'
        // Create anonymous type. Has one property with the name CustomerId and value 'ALFKI'
        VAR oParams := CLASS{CustomerId}
        // Pass the parameters object to the backend
        SqlParameters(handle, oParams)
        // Execute a query with a parameter. We accept both a ? and a : as start of parameter name
        ? SqlExec(handle, "Select * from orders where customerId = :CustomerId","orders")
        ? SqlGetprop(handle, SqlProperty.NativeCommand)
        Browse()

ENDIF


FUNCTION TestPg()
     SqlSetFactory("ODBC")
     LOCAL handle := SqlStringConnect("Dsn=PG;")
    IF handle > 0
        // Declare local. Can be typed or untyped. A memvar would work as well.
        // Execute a query with a parameter. We accept both a ? and a : as start of parameter name
        ? SqlExec(handle, "Select * from test","test")
        COPY TO C:\Temp\Temp
        Browse()

ENDIF


FUNCTION testExec2()
     SqlSetFactory("ODBC")
     LOCAL handle := SqlStringConnect("Dsn=Northwind;")
    IF handle > 0
         LOCAL aInfo := {} AS ARRAY
        ? SqlExec(handle, "Select * from customers","test",aInfo)
        ShowArray(aInfo)
        ? SqlExec(handle, "Select * from categories","test",aInfo)
        ShowArray(aInfo)
ENDIF


