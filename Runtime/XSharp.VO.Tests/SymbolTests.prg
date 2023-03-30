//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
USING System
USING System.Collections.Generic
USING System.Linq
USING System.Text
USING XUnit

BEGIN NAMESPACE XSharp.VO.Tests

	CLASS SymbolTests
	
		[Fact, Trait("Category", "Symbol")];
		METHOD CreateSymbolTest() AS VOID
			VAR sym := #TestSymbol
			Assert.Equal("TESTSYMBOL",sym:ToString())
		RETURN
		[Fact, Trait("Category", "Symbol")];
		METHOD CompareSymbolTest() AS VOID
			VAR sym1 := #TestSymbol
			VAR sym2 := #TestSymbol
			Assert.Equal(TRUE,sym1==sym2)
			Assert.Equal(TRUE,sym1=="TESTSYMBOL")
			Assert.Equal(FALSE,sym1==#TestSymbol1)
		RETURN

		[Fact, Trait("Category", "Symbol")];
		METHOD GreaterSymbolTest() AS VOID
			VAR sym1 := #TestSymbol1
            VAR sym2 := #TestSymbol2
            SetCollation(#Windows)
			Assert.Equal(#Windows,SetCollation())
			LOCAL uCollation AS USUAL
			uCollation := SetCollation(#Ordinal)
			Assert.Equal(TRUE,sym1<=sym2)
			Assert.Equal(TRUE,sym1<sym2)
			Assert.Equal(FALSE,sym1 > sym2)
			Assert.Equal(FALSE,sym1 >= sym2)
			Assert.Equal(TRUE,sym2 > sym1)
			Assert.Equal(TRUE,sym2 >= sym1)
			Assert.Equal(FALSE,sym2 < sym1)
			sym2 := #testSymbol
			Assert.Equal(FALSE,sym1=sym2)
			SetExact(FALSE)
			// with setequal FALSE then #TestSymbol1 == #testSymbol
			Assert.Equal(FALSE,sym1<sym2)
			Assert.Equal(TRUE,sym1<=sym2)
			SetCollation(uCollation)
		RETURN

		[Fact, Trait("Category", "Symbol")];
		METHOD ImplicitConverter() AS VOID
			LOCAL s AS STRING
			LOCAL sym AS SYMBOL
			sym := #Test
			s := sym
			Assert.Equal(s, sym:ToString())
			sym := s
			Assert.Equal(s, sym:ToString())

		[Fact, Trait("Category", "Symbol")];
		METHOD ExplicitConverter() AS VOID
			LOCAL d AS DWORD
			LOCAL sym1 AS SYMBOL
			LOCAL sym2 AS SYMBOL
			sym1 := #test
			d:= (DWORD) sym1
			sym2 := (SYMBOL) d
			Assert.Equal(sym1, sym2)
			sym2 := (SYMBOL) 0x42U
			Assert.NotEqual(sym1, sym2)
			
		[Fact, Trait("Category", "Symbol")];
		METHOD AtomTester() AS VOID
			LOCAL sym1 AS SYMBOL
			LOCAL sym2 AS SYMBOL
			LOCAL dwStart AS DWORD
			dwStart := MaxAtom()
			sym1 := SysAddAtom("Robert")
			sym2 := String2Symbol("Robert")
			Assert.Equal(MaxAtom(),dwstart+2)		// there are symbols defined in the global symbol table
			Assert.NotEqual(sym1, sym2)
			Assert.NotEqual(sym1:ToString(), sym2:ToString())
			Assert.Equal(sym1:ToString():ToUpper(), sym2:ToString())
			sym2 := SysFindAtom("Robert")
			Assert.Equal(sym1, sym2)
			sym2 := SysFindAtom("RobertIsNotThere")		// Find should not have added the new symbol
			Assert.Equal(MaxAtom(),dwstart+2)
			Assert.NotEqual(sym1, sym2)
			sym1 := ConcatAtom(#one, #two)
			Assert.Equal(sym1, #onetwo)
			sym1 := ConcatAtom3(#one, #two,#three)
			Assert.Equal(sym1, #onetwothree)
			sym1 := ConCatAtom5(#one, #two,#three,#four,#five)
			Assert.Equal(sym1, #onetwothreefourfive)
			Assert.Equal(MaxAtom(),dwstart+2)			// the literals do not create a new atom

        [Fact, Trait("Category", "Symbol")];
        METHOD UsualSymbolTest AS VOID
            // VO allows to compare usuals with symbol even when the usual does not contain a symbol!
            LOCAL uValue AS USUAL
            LOCAL symCompare AS SYMBOL

            uValue := NIL
            Assert.TRUE (uValue == NULL_SYMBOL)
            symCompare := #XSharpRules

            uValue := (DWORD) symCompare
            Assert.TRUE (uValue == symCompare)

            uValue := (INT64) uValue
            Assert.TRUE (uValue == symCompare)

            uValue := (FLOAT) uValue
            Assert.TRUE (uValue == symCompare)

            uValue :=  1m * uValue
            Assert.TRUE (uValue == symCompare)

        

	END CLASS
END NAMESPACE // XSharp.Runtime.Tests
