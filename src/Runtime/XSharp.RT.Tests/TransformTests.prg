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
USING System.Globalization


BEGIN NAMESPACE XSharp.RT.Tests

	CLASS TransFormTests

		[Fact, Trait("Category", "TransForm")];
		METHOD TransformLogicalTest() AS VOID
			// with @R other chars are appended, but only a single YN or TF flag is written. Other positions become a space
			Assert.Equal("Y", Transform(TRUE, "Y"))
			Assert.Equal("N", Transform(FALSE, "Y"))
			Assert.Equal("T", Transform(TRUE, "L"))
			Assert.Equal("F", Transform(FALSE, "L"))
			Assert.Equal("T x", Transform(TRUE, "@R L x"))
			Assert.Equal("F x", Transform(FALSE, "@R L x"))
			Assert.Equal("Y x", Transform(TRUE, "@R YYx"))
			Assert.Equal("N x", Transform(FALSE, "@R YYx"))
			SetNatDLL("French.DLL")
			Assert.Equal("O", Transform(TRUE, "Y"))
			Assert.Equal("N", Transform(FALSE, "Y"))
			Assert.Equal("T", Transform(TRUE, "L"))     // you would expect V but VO returns T
			Assert.Equal("F", Transform(FALSE, "L"))
			Assert.Equal("T x", Transform(TRUE, "@R L x"))  // you would expect V but VO returns T x
			Assert.Equal("F x", Transform(FALSE, "@R L x"))
			Assert.Equal("O x", Transform(TRUE, "@R YYx"))
			Assert.Equal("N x", Transform(FALSE, "@R YYx"))
			SetNatDLL("UK") // restore


		[Fact, Trait("Category", "TransForm")];
		METHOD TransformDateTest() AS VOID
			// with @R other chars are appended, but only a single YN or TF flag is written. Other positions become a space
			LOCAL cDF := GetDateFormat() AS STRING
            SetCentury(TRUE)
			SetDateFormat("dd/mm/yyyy")
			Assert.Equal("10/12/2010", Transform(2010.12.10,"@E"))
			Assert.Equal("20/11/2010", Transform(2010.11.20,"@E"))
			SetDateFormat("dd-mm-yyyy")
			Assert.Equal("20-11-2010", Transform(2010.11.20,"@D"))
			SetDateFormat("dd-mm-yy")
			Assert.Equal("20-11-10", Transform(2010.11.20,"@D"))
			SetDateFormat(cDF)

		[Fact, Trait("Category", "TransForm")];
		METHOD TransformStringTest() AS VOID
			Assert.Equal("ABC", Transform("abc", "@!"))
			Assert.Equal("AbC", Transform("abc", "!a!"))
			Assert.Equal("1234 AB", Transform("1234ab", "@R! 9999 AA"))
			Assert.Equal("1234 AB", Transform("1234ab", "@R 9999 !!"))

			Assert.Equal("ABCDEF", Transform("AbcdeF", "@!"))
			Assert.Equal("ABCDEF", Transform("AbcdeF", "@LLL!LLL"))
			Assert.Equal("ABCDEF", Transform("AbcdeF", "@A!L"))
			Assert.Equal("ABC", Transform("AbcdeF", "@! AAA"))

		[Fact, Trait("Category", "TransForm")];
		METHOD TransformLongTest() AS VOID
			SetDecimalSep('.')
			SetThousandSep(',')
			Assert.Equal("  1", Transform(1, "999"))
			Assert.Equal("123", Transform(123, "###"))
			Assert.Equal("**", Transform(123, "##"))
			Assert.Equal("**", Transform(123, "99"))
			Assert.Equal("(1)", Transform(-1, "@( 99"))
			Assert.Equal("(-1)", Transform(-1, "@( 999"))
			Assert.Equal("( -1)", Transform(-1, "@( 9999"))
			Assert.Equal("(-1)", Transform(-1, "@) 9999"))
			Assert.Equal(" (-1)", Transform(-1, "@) 99999"))
			Assert.Equal("   ", Transform(0, "@Z 999"))
			Assert.Equal(" -1 DB", Transform(-1, "@X 999"))
			Assert.Equal(" -1 DB", Transform(-1, "@XC 999"))
			Assert.Equal("  1 CR", Transform(1, "@XC 999"))
			Assert.Equal("  1 CR", Transform(1, "@C 999"))
			Assert.Equal("  0", Transform(0, "@C 999"))
			Assert.Equal("1,234", Transform(1234, "9,999"))
			SetDecimalSep(',')
			SetThousandSep('.')
			Assert.Equal("1.234", Transform(1234, "9,999"))

			Assert.Equal("***,**", Transform(-188.96, "999.99"))
			Assert.Equal("***,**%", Transform(-188.96, "@RE 999.99%"))
			Assert.Equal("188,96", Transform(188.96, "999.99"))
			Assert.Equal("***,**", Transform(1188.96, "999.99"))


		[Fact, Trait("Category", "TransForm")];
		METHOD TransformFLoatTest() AS VOID
			SetDecimalSep('.')
			SetThousandSep(',')
			Assert.Equal("1.23", Transform(1.23, "9.99"))
			Assert.Equal("1,23", Transform(1.23, "@E 9.99"))
			Assert.Equal("*.**", Transform(12.34, "9.99"))
        [Fact, Trait("Category", "TransForm")];
        METHOD TransformNumericTest AS VOID
			SetDecimalSep(',')
			SetThousandSep('.')
            Assert.Equal("      2,45", Transform (    2.45 , "@R 999,999.99" ) )
            Assert.Equal("     -2,45", Transform (   -2.45 , "@R 999,999.99" ) )
            Assert.Equal("    124,00", Transform (     124 , "@R 999,999.99" )  )
            Assert.Equal("   -124,00", Transform (    -124 , "@R 999,999.99" )  )

            Assert.Equal("  1", Transform(1, 	"@Z 999")  )
            Assert.Equal(" 10", Transform(10, 	"@Z 999")  )
            Assert.Equal(" 20", Transform(20, 	"@Z 999")  )
            Assert.Equal("100", Transform(100, 	"@Z 999")  )
            Assert.Equal("999", Transform(999, 	"@Z 999")  )

            Assert.Equal(" ", 		Transform(0, "@Z 9")  )
            Assert.Equal("   ", 	Transform(0, "@Z 999")  )
            Assert.Equal("     ", 	Transform(0, "@Z 99999")  )

            Assert.Equal(Space(11), 	Transform( 0.00, "@z 999,9999.99" )  )
            Assert.Equal(Space(11), 	Transform( 0, "@z 999,9999.99" )  )
            Assert.Equal(Space(14), 	Transform( 0, "@Z 999,9   999.99" )  )
            Assert.Equal(Space(16), 	Transform( 0, "@z 999,9 a b 999.99" )  )
            Assert.Equal(Space(3), 	    Transform( 0.0, "@ZC 9.9" )  )
            Assert.Equal(Space(2), 	    Transform( 0, "@z .9" )  )
            Assert.Equal(Space(1), 	    Transform( 0, "@CZ 9" )  )

            Assert.Equal(Space(10),     Transform( 0, "@z " )  )  // VO behavior...
            Assert.Equal(Space(1),      Transform( 0, "@z  " )  )
            Assert.Equal(Space(2),      Transform( 0, "@z   " )  )
            Assert.Equal(Space(3),      Transform( 0, "@z   a" )  )

        [Fact, Trait("Category", "TransForm")];
        METHOD TransformSymbolTest AS VOID
        	// VO behavior...
            Assert.Equal("",     Transform( #somesymbol, "" )  )
            Assert.Equal("",     Transform( #somesymbol, "@z " )  )
            Assert.Equal("",     Transform( #somesymbol, "XXXXXXXXXXXXX" )  )
            Assert.Equal("",     Transform( #somesymbol, "abc XXXXXXXXXXXXX def" )  )

            LOCAL uSymbol AS USUAL
            uSymbol := #somesymbol
            Assert.Equal("",     Transform( uSymbol, "" )  )
            Assert.Equal("",     Transform( uSymbol, "@z " )  )
            Assert.Equal("",     Transform( uSymbol, "XXXXXXXXXXXXX" )  )
            Assert.Equal("",     Transform( uSymbol, "abc XXXXXXXXXXXXX def" )  )


        [Fact, Trait("Category", "Unformat")];
        METHOD UnformatCTest AS VOID
            Assert.Equal("8161XV", Unformat("8161 XV", "@R! 9999 AA","C"))
            Assert.Equal("8161 XV", Unformat("8161 XV", "@! 9999 AA","C"))

       [Fact, Trait("Category", "Unformat")];
        METHOD UnformatNTest AS VOID
			SetDecimalSep(',')
			SetThousandSep('.')
            Assert.Equal( 1.234d, (REAL8)(FLOAT) Unformat("1,234", "9.999","N"))
            Assert.Equal( 1234567.89d, (REAL8)(FLOAT) Unformat("1.234.567,89", "9,999,999.99","N"))

            Assert.True( Unformat("", "@Z 99","N") == 0 )
            Assert.True( Unformat("", "99","N")    == 0 )
            Assert.True( Unformat("asd", "99","N") == 0 )
            Assert.True( Unformat("*", "999","N")  == 0 )
            Assert.True( Unformat("()", "999","N") == 0 )

	END CLASS
END NAMESPACE

