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


BEGIN NAMESPACE XSharp.VO.Tests

	CLASS DateTests

		[Fact, Trait("Category", "Date")];
		METHOD CTODTest() AS VOID 
			SetEpoch(1900)
			SetDateFormat("dd/mm/yyyy")
			Assert.Equal(2016.01.01 ,CToD("01/01/2016"))
			Assert.Equal(2016.02.13 ,CToD("13/02/2016"))
			Assert.Equal(0001.01.02 ,CToD("02/01/0001"))
			Assert.Equal(1901.01.01 ,CToD("01/01/01"))
			SetDateFormat("mm/dd/yyyy")	
			Assert.Equal(2016.01.01 ,CToD("01/01/2016"))
			Assert.Equal(2016.02.13 ,CToD("02/13/2016"))
			Assert.Equal(2016.03.13 ,CToD("03/13/2016"))

			Assert.Equal(2016.03.13 ,CToD("03 13-2016"))
			Assert.Equal(2016.03.13 ,CToD("03w13w2016"))
			Assert.Equal(2016.03.13 ,CToD("03*13*2016"))
		RETURN

 		

		[Fact, Trait("Category", "Date")];
		METHOD STODTest() AS VOID
			Assert.Equal(DATE{2016,05,06},SToD("20160506"))
			Assert.Equal(NULL_DATE, SToD("20181313"))
			Assert.Equal(NULL_DATE, SToD("AAAAAAAA"))
		RETURN

		[Fact, Trait("Category", "Date")];
		METHOD CDOWTest() AS VOID
			System.Threading.Thread.CurrentThread:CurrentCulture := CultureInfo{"en-US"}
			Assert.Equal("Tuesday",CDoW(ConDate(2016,5,24)))
			System.Threading.Thread.CurrentThread:CurrentCulture := CultureInfo{"de-DE"}
			Assert.Equal("Dienstag",CDoW(ConDate(2016,5,24)))
			System.Threading.Thread.CurrentThread:CurrentCulture := CultureInfo{"nl-NL"}
			Assert.Equal("dinsdag",CDoW(ConDate(2016,5,24)))
			Assert.Equal("", CDoW(NULL_DATE))
		RETURN

		[Fact, Trait("Category", "Date")];
		METHOD CMonthTest() AS VOID
			System.Threading.Thread.CurrentThread:CurrentCulture := CultureInfo{"en-US"}
			Assert.Equal("May",CMonth(ConDate(2016,5,24)))
			System.Threading.Thread.CurrentThread:CurrentCulture := CultureInfo{"de-DE"}
			Assert.Equal("Mai",CMonth(ConDate(2016,5,24)))
			System.Threading.Thread.CurrentThread:CurrentCulture := CultureInfo{"nl-NL"}
			Assert.Equal("mei",CMonth(ConDate(2016,5,24)))
			Assert.Equal("", CMonth(NULL_DATE))
		RETURN

		[Fact, Trait("Category", "Date")];
		METHOD DayTest() AS VOID
			Assert.Equal((DWORD)24,Day(ConDate(2016,5,24)))
			Assert.Equal((DWORD)0,Day(NULL_DATE))
		RETURN

		[Fact, Trait("Category", "Date")];
		METHOD DOWTest() AS VOID
			// DOW should return 0  for empty dates
			// 1 = Sunday, 2 = Monday, .... 7 = Saturday

			Assert.Equal((DWORD)3,DoW(ConDate(2016,5,24)))
			Assert.Equal((DWORD)4,DoW(ConDate(2018,6,13)))
			Assert.Equal((DWORD)0,DoW(ConDate(0,0,0)))
		RETURN

		[Fact, Trait("Category", "Date")];
		METHOD DTOCTest() AS VOID
			SetDateFormat("DD/MM/YYYY")
			Assert.Equal("24/05/2016",DToC(CToD("24/05/2016")))
			SetDateFormat("DD/MM/YY")
			Assert.Equal("24/05/16",DToC(CToD("24/05/2016")))
			SetDateFormat("MM/DD/YY")
			Assert.Equal("  /  /  ",DToC(CToD("24/05/2016")))
			SetDateFormat("mm-dd-YYYY")
			Assert.Equal("  -  -    ",DToC(CToD("24/05/2016")))
			SetDateFormat("dd-mm-YYYY")
			Assert.Equal("24-05-2016",DToC(CToD("24/05/2016")))
		RETURN

		[Fact, Trait("Category", "Date")];
		METHOD DTOSTest() AS VOID
			Assert.Equal("20160524",DToS(ConDate(2016,5,24)))
			Assert.Equal("        ", DToS(NULL_DATE))
		RETURN

		[Fact, Trait("Category", "Date")];
		METHOD MonthTest() AS VOID
			Assert.Equal((DWORD)5,Month(ConDate(2016,5,24)))
			Assert.Equal((DWORD)0,Month(NULL_DATE))
		RETURN

		[Fact, Trait("Category", "Date")];
		METHOD YearTest() AS VOID
			Assert.Equal((DWORD)2016,Year(ConDate(2016,5,24)))
			Assert.Equal((DWORD)0,Year(NULL_DATE))
		RETURN

		[Fact, Trait("Category", "Date")];
		METHOD CastTest() AS VOID
			LOCAL i AS LONG
			LOCAL dw AS DWORD
			VAR d := 2017.1.1
			i := (LONG) d
			dw := (DWORD) d
			Assert.Equal(d, (DATE) i)
			Assert.Equal(d, (DATE) dw)

		RETURN
		[Fact, Trait("Category", "Date")];
		METHOD CompareTest() AS VOID
		VAR d1 := DATE{2017,09,25}
		VAR d2 := DATE{2017,09,26}	// different day
		Assert.True(d1 < d2)
		Assert.True(d1 <= d2)
		Assert.True(d1+1 == d2)
		Assert.False(d1 > d2)
		Assert.False(d1 >= d2)

		d2 := DATE{2017,10,25}	// different month
		Assert.True(d1 < d2)
		Assert.True(d1 <= d2)
		Assert.False(d1 > d2)
		Assert.False(d1 >= d2)

		d2 := DATE{2018,09,24}	// different year
		Assert.True(d1 < d2)
		Assert.True(d1 <= d2)
		Assert.False(d1 > d2)
		Assert.False(d1 >= d2)

		Assert.True(d2 > d1)
		Assert.True(d2 >= d1)
		Assert.False(d2 < d1)
		Assert.False(d2 <= d1)
		
		VAR d3 := d1
		Assert.False(d3 > d1)
		Assert.True(d3 >= d1)
		Assert.False(d3 < d1)
		Assert.True(d3 <= d1)

		[Fact, Trait("Category", "Numeric")];
		METHOD NToCDoWTest() AS VOID
			SetDateFormat("DD/MM/YYYY")
			System.Threading.Thread.CurrentThread:CurrentCulture := CultureInfo{"en-US"}
			Assert.Equal("Friday",NToCDoW(DoW(CToD("27/05/2016"))))
			System.Threading.Thread.CurrentThread:CurrentCulture := CultureInfo{"de-DE"}
			Assert.Equal("Freitag",NToCDoW(DoW(CToD("27/05/2016"))))
			System.Threading.Thread.CurrentThread:CurrentCulture := CultureInfo{"nl-NL"}
			Assert.Equal("vrijdag",NToCDoW(DoW(CToD("27/05/2016"))))
		
		RETURN

		[Fact, Trait("Category", "Numeric")];
		METHOD NToCMonthTest() AS VOID
			System.Threading.Thread.CurrentThread:CurrentCulture := CultureInfo{"en-US"}
			Assert.Equal("June",NToCMonth((DWORD)6))
			System.Threading.Thread.CurrentThread:CurrentCulture := CultureInfo{"de-DE"}
			Assert.Equal("Juni",NToCMonth((DWORD)6))
			System.Threading.Thread.CurrentThread:CurrentCulture := CultureInfo{"nl-NL"}
			Assert.Equal("juni",NToCMonth((DWORD)6))
		
		RETURN		
		
		[Fact, Trait("Category", "Date")];
		METHOD CoNDateTest() AS VOID
			LOCAL d1918 AS DATE
			LOCAL d2018 AS DATE
			LOCAL dtest AS DATE
			LOCAL nEpoch := SetEpoch()
			SetEpoch(1900)
			d2018 := ConDate(2018,03,15)
			d1918 := ConDate(1918,03,15)
			dtest := ConDate(18,3,15)
			Assert.Equal(d1918, dtest)
			SetEpoch(2000)
			dtest := ConDate(18,3,15)
			Assert.Equal(d2018, dtest)
			SetEpoch(1917)
			dtest := ConDate(18,3,15)	// should be 1918
			Assert.Equal(d1918, dtest)
			SetEpoch(1917)
			dtest := ConDate(18,3,15) // should be 1918
			SetEpoch(1918)
			Assert.Equal(d1918, dtest)
			dtest := ConDate(18,3,15) // should be 1918
			SetEpoch(1919)
			Assert.Equal(d2018, dtest)
			SetEpoch(nEpoch)
		RETURN		
		[Fact, Trait("Category", "Date")];
		METHOD Date2BinTest() AS VOID
			LOCAL dwDate AS STRING
			LOCAL dDate1 AS DATE
			LOCAL dDate2 AS DATE

			dDate1 := Today()
			dwDate := Date2Bin(dDate1)
			dDate2 := Bin2Date(dwDate)
			Assert.Equal(dDate1, dDate2)


		[Fact, Trait("Category", "Date")];
		METHOD TStringTest() AS VOID
		//local r8 as real8
		//r8 := 12.0 * 60.0*60.0 
		//Assert.Equal("12:00:00", Tstring( r8))
		RETURN

		[Fact, Trait("Category", "Date")];
		METHOD SToDTests() AS VOID
			SetEpoch(1910)
			Assert.Equal(2005.01.31 , SToD("00050131"))
			Assert.Equal(1915.01.31 , SToD("00150131"))

		[Fact, Trait("Category", "Date")];
		METHOD InvalidLiteralDateTests() AS VOID
			Assert.Equal(NULL_DATE , 50.50.50)
			Assert.Equal(NULL_DATE , 0000.00.00)
			Assert.Equal(NULL_DATE , 00.00.00)
			Assert.Equal(NULL_DATE , 0.0.0)

		[Fact, Trait("Category", "Date")];
		METHOD SetDateCountryTests() AS VOID
			LOCAL dDate AS DATE
			
			LOCAL nOld AS DWORD
			nOld := SetDateCountry()

			dDate := 2000.01.31
			
			SetCentury(TRUE)

			SetDateCountry(0)
			Assert.Equal("01/31/2000", DToC(dDate))
			SetDateCountry(DateCountry.American) 
			Assert.Equal("01/31/2000", DToC(dDate))
			SetDateCountry(DateCountry.Ansi) 
			Assert.Equal("2000.01.31", DToC(dDate))
			SetDateCountry(DateCountry.British) 
			Assert.Equal("31/01/2000", DToC(dDate))
			SetDateCountry(DateCountry.French) 
			Assert.Equal("31/01/2000", DToC(dDate))
			SetDateCountry(DateCountry.German) 
			Assert.Equal("31.01.2000", DToC(dDate))
			SetDateCountry(DateCountry.Italian) 
			Assert.Equal("31-01-2000", DToC(dDate))
			SetDateCountry(DateCountry.Japanese) 
			Assert.Equal("2000/01/31", DToC(dDate))
			SetDateCountry(DateCountry.USA) 
			Assert.Equal("01-31-2000", DToC(dDate))
				 
			SetCentury(FALSE)

			SetDateCountry(0)
			Assert.Equal("01/31/00", DToC(dDate))
			SetDateCountry(DateCountry.American) 
			Assert.Equal("01/31/00", DToC(dDate))
			SetDateCountry(DateCountry.Ansi) 
			Assert.Equal("00.01.31", DToC(dDate))
			SetDateCountry(DateCountry.British) 
			Assert.Equal("31/01/00", DToC(dDate))
			SetDateCountry(DateCountry.French) 
			Assert.Equal("31/01/00", DToC(dDate))
			SetDateCountry(DateCountry.German) 
			Assert.Equal("31.01.00", DToC(dDate))
			SetDateCountry(DateCountry.Italian) 
			Assert.Equal("31-01-00", DToC(dDate))
			SetDateCountry(DateCountry.Japanese) 
			Assert.Equal("00/01/31", DToC(dDate))
			SetDateCountry(DateCountry.USA) 
			Assert.Equal("01-31-00", DToC(dDate))
			
			SetDateCountry(nOld)
			Assert.Equal(nOld, (DWORD)SetDateCountry())
				 
		[Fact, Trait("Category", "Time")];
		METHOD ConTimeTest() AS VOID
			Assert.Equal("13:34:54",ConTime(13,34,54))
		RETURN

		[Fact, Trait("Category", "Date")];
		METHOD DateFunctionTest() AS VOID
            LOCAL dwToDay AS DWORD
			Assert.Equal(DATE(), Today())
			Assert.Equal(DATE(2010,3,4), Condate(2010,3,4))
            dwToday := DWORD(_CAST , ToDay())
			Assert.Equal(DATE(dwToDay), Today())

            Assert.Equal(DateTime(), DateTime.Now)
            Assert.Equal(DateTime(2001,1,2), DateTime{2001,1,2})
            Assert.Equal(DateTime(2001,1,2,3), DateTime{2001,1,2,3,0,0})
            Assert.Equal(DateTime(2001,1,2,3,4), DateTime{2001,1,2,3,4,0})
            Assert.Equal(DateTime(2001,1,2,3,4,5), DateTime{2001,1,2,3,4,5})
            RETURN


	END CLASS
END NAMESPACE // XSharp.Runtime.Tests
