﻿USING System.Globalization

function start as void
    local p as psz
    p := String2Psz("abc")
    p := StringAlloc("def")
    MemFree(p)
	wait
  

FUNCTION Startx1 AS VOID
    setinternational ( #windows )
? "setinternational ( #windows )"
?
// set the default to true, and it´s in sync with the dateformat at startup.
// setcentury(TRUE) // <--------------------

? "Current SetCentury() default setting is " + setcentury() + " , should be TRUE"
? GetDateFormat()
?
setcentury( FALSE )
? "Setcentury(false)"
? GetDateFormat() + _chr(9) + "only ok, if it shows 'DD.MM.YY'"
?
setcentury( TRUE )
? "Setcentury(true)"
? GetDateFormat()
?
setcentury( FALSE )
? "Setcentury(false)"
? GetDateFormat()
?
setcentury( TRUE )
? "Setcentury(true)"
? GetDateFormat()
?
?
?
? "The initial Setinternational (#clipper ) behaviour is already compatible with VO"
SetInternational( #clipper)
? "SetInternational( #clipper)"

SetDatecountry ( 5 ) // "GERMAN" define in VO.
?
? Getdateformat() // "DD.MM.YY"
? setcentury() // false
?
setcentury( TRUE )
? "Setcentury(true)"
? GetDateFormat()
?
setcentury( FALSE )
? "Setcentury(false)"
? GetDateFormat()
?
// switch back to #Windows
setinternational ( #windows )
? "setinternational ( #windows )"
?
? "Current SetCentury() default setting is " + setcentury() + " , should be TRUE"
? GetDateFormat()
wait
RETURN

FUNCTION Start2a AS VOID
    LOCAL o AS OBJECT[]
    LOCAL a AS ARRAY
	a := {"aa", "bb", {1,2,3}}
    o := a
    a := o
	? o
    ? a
    Console.Read()
    RETURN

FUNCTION StartX AS VOID
	LOCAL cA, cB AS STRING
	LOCAL nI, nMax AS INT64
	LOCAL lOk AS LOGIC
	LOCAL p AS PTR
	p := MemAlloc(100)
	MemFree(p)
	SetInternational(#Clipper)
	SetNatDLL("ITALIAN")
	? DateTime.Now:DayOfWeek:ToString()
	? (INT) DateTime.Now:DayOfWeek
	? DOW(Today())
	? CDOW(Today())
	? CMonth(Today())
	wait

	nMax := 10000000// 40000000
	cA := "THE QUICK BROWN FOX JUMP OVER THE LAZY DOG"
	//cB := Left(CA, Slen(Ca)-1)+Lower(right(cA,1))
	cb := lower(ca)
	LOCAL aColl AS STRING[]
	aColl := <STRING>{"Windows", "Clipper","Unicode", "Ordinal"}
	FOREACH VAR s IN aColl
		SetCollation(s)
		LOCAL nSecs AS FLOAT
		nSecs := Seconds()
		FOR nI := 1 TO nMax
			lOk := cA <= cB
		NEXT
		? SetCollation(), transform(nMax,"999,999,999"), seconds() - nSecs
	NEXT
	_wait()
	RETURN

FUNCTION Start2 AS VOID
	LOCAL aDir AS ARRAY
	aDir := Directory("C:\XSharp\DevRt\Runtime", "AHSD")
	FOREACH VAR aFile IN aDir
		? aFile[1], aFile[2], aFile[3], aFile[4], aFile[5]
	NEXT
	LOCAL aFiles AS ARRAY

	aFiles := ArrayCreate(ADir("C:\XSharp\DevRt\Runtime\XSharp.Core\*.prg"))

	ADir("C:\XSharp\DevRt\Runtime\XSharp.Core\*.prg", aFiles)

	AEval(aFiles, {|element| QOut(element)})

	_Wait()
	RETURN

FUNCTION StartA() AS VOID
	LOCAL nX AS DWORD
	CultureInfo.DefaultThreadCurrentCulture := CultureInfo{"EN-us"}
	CultureInfo.DefaultThreadCurrentUICulture := CultureInfo{"EN-us"}

	? Version()
	? "Size of IntPtr", IntPtr.Size
	? "Size of USUAL", SIZEOF(USUAL)
	? "Size of FLOAT", SIZEOF(FLOAT)
	? "Size of DATE", SIZEOF(DATE)
	? "Size of SYMBOL", SIZEOF(SYMBOL)
	?
	? 1.234:ToString()
	? SetNatDLL("Dutch.DLL")
	? GetNatDLL()
	? GetAppLocaleID()
	? SetAppLocaleID(1043)
	? GetAppLocaleID()
	? 1.234:ToString()
	? __CavoStr(VOErrors.TMSG_PRESSANYKEY)
	? VO_Sprintf(VOErrors.__WCSLOADLIBRARYERROR, "CaTo3Cnt.DLL")
	? DosErrString(2)
	? ErrString(EG_ARG)
	Console.WriteLine("")
	LOCAL mem,mem2 AS INT64
	mem := GC.GetTotalMemory(TRUE)

	LOCAL a AS ARRAY
	a := ArrayCreate(1000000)

	mem2 := GC.GetTotalMemory(TRUE) - mem
	mem := mem2
	? "Memory for 1M element ARRAY", mem:ToString("###,### bytes")
	FOR nX := 1 TO 1000000
		a[nX] := 1
	NEXT
	? "Memory for 1M element ARRAY after assigning 1M values", mem:ToString("###,### bytes")
	a := NULL_ARRAY
	GC.Collect()
	a := ArrayCreate(0)
	mem := GC.GetTotalMemory(TRUE)
	FOR nX := 1 TO 1000000
		aadd(a, 1)
	NEXT
	mem2 := GC.GetTotalMemory(TRUE) - mem
	mem := mem2
	? "Memory for 1M element ARRAY after assigning 1M values with AAdd", mem:ToString("###,### bytes")

	TestUsualFloat()
	TestDate()
	GC.KeepAlive(a)

    _wait()
    RETURN

PROCEDURE TestUsualFloat()
	LOCAL u1,u2 AS USUAL
	LOCAL f1,f2 AS FLOAT

    ? "Testing USUAL & Float"
	? "25.000.000 iterations"

	LOCAL d AS DateTime
	d := DateTime.Now

	FOR LOCAL n := 1 AS INT UPTO 25000000
		u1 := 1.1d
		f1 := 1.3d
		u2 := u1 + f1
		f2 := u1 + u2 + f1
		f1 := f2 + u1
		f2 := f2 + u2
	NEXT

	? "Time elapsed:", (DateTime.Now - d):ToString()
	?
    RETURN



PROCEDURE testDate()
	LOCAL d1, d2 AS DATE
    ? "Testing DATE"
	? "25.000.000 iterations"

	LOCAL d AS DateTime
	d := DateTime.Now

	FOR LOCAL n := 1 AS INT UPTO 25000000
		d1 := 2018.04.15
		d2 := d1+1
		d1 := d2

	NEXT

	? "Time elapsed:", (DateTime.Now - d):ToString()
	?
    RETURN

