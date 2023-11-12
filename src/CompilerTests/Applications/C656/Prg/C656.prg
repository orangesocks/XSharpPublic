// 656. error XS0029: Cannot implicitly convert type 'string' to 'string[]'
#pragma warnings (162, off) // unreachable code
CLASS TestClass
	EXPORT DIM aDim[3,3] AS STRING
END CLASS

FUNCTION Start( ) AS VOID
	LOCAL o AS TestClass
	o := TestClass{}
	? o:aDim[1,1]
	xAssert(o:aDim[1,1] == "")
	xAssert(o:aDim[2,2] == "")
	xAssert(o:aDim[3,3] == "")

	#warning note that this does not report a compiler error, although in VO it does. The array length is known at compile time
	IF FALSE
		? o:aDim[4,1]
	END IF
RETURN

PROC xAssert(l AS LOGIC)
IF l
	? "Assertion passed"
ELSE
	THROW Exception{"Incorrect result"}
END IF

