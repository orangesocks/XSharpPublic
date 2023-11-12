// 622. Syntax for initializing multi-dim array
/*
In the following code, the most part of the array initialization code is being ignored, 
the compiler does not report any syntax errors, but not items are being added to the array either.
*/

FUNCTION Start( ) AS VOID       
	// this does not work
	LOCAL aMulti AS STRING[,]
	aMulti := STRING[,]{2,2}{{ "X#", "xsharp.info" }, { "C#", "microsoft.com" } }     

	xAssert(aMulti[1,1] == "X#")
	xAssert(aMulti[1,2] == "xsharp.info")
	xAssert(aMulti[2,1] == "C#")
	xAssert(aMulti[2,2] == "microsoft.com")
	// this works
	LOCAL aMulti2 AS STRING[][]
	aMulti2 :=  <STRING[]>{ {  "X#", "xsharp.info"},  { "C#", "microsoft.com" } }
	xAssert(aMulti2[1][1] == "X#")
	xAssert(aMulti2[1][2] == "xsharp.info")
	xAssert(aMulti2[2][1] == "C#")              
	xAssert(aMulti2[2][2] == "microsoft.com")
	
RETURN

PROC xAssert(l AS LOGIC)
IF l
	? "Assertion passed"
ELSE
	THROW Exception{"Incorrect result"}
END IF

