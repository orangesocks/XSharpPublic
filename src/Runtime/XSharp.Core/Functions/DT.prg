//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
USING System.Runtime.CompilerServices
#define SECONDSPERMINUTE 60
#define SECONDSPERHOUR (60*SECONDSPERMINUTE)
#define SECONDSPERDAY (24*SECONDSPERHOUR)

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/ampm/*" />
FUNCTION AmPm(c24HrTime AS STRING) AS STRING
	LOCAL nSeconds AS DWORD
	LOCAL nHours AS DWORD
	LOCAL nMinutes AS DWORD
	IF String.IsNullOrEmpty(c24HrTime)
		RETURN ""
	ENDIF
	nSeconds := Secs(c24HrTime)
	IF (nSeconds) > SECONDSPERDAY
		RETURN ""
	ENDIF
	nSeconds := nSeconds % SECONDSPERDAY
	nHours   := nSeconds / SECONDSPERHOUR
	nSeconds := nSeconds % SECONDSPERHOUR
	nMinutes := nSeconds / SECONDSPERMINUTE
	nSeconds := nSeconds % SECONDSPERMINUTE
	RETURN _TimeString(nHours, nMinutes, nSeconds, TRUE, GetAMExt(), GetPMExt())


/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/elaptime/*" />
FUNCTION ElapTime(cStartTime AS STRING,cEndTime AS STRING) AS STRING
	LOCAL nStart AS DWORD
	LOCAL nEnd   AS DWORD
	LOCAL nDiff  AS DWORD
	nStart := Secs(cStartTime)
	nEnd   := Secs(cEndTime)
	IF nStart > nEnd
		nDiff := SECONDSPERDAY + nEnd - nStart
	ELSE
		nDiff := nEnd - nStart
	ENDIF
	RETURN TString(nDiff)

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/contime/*" />
FUNCTION ConTime(dwHour AS DWORD,dwMinute AS DWORD,dwSeconds AS DWORD) AS STRING
   RETURN _TimeString( dwHour, dwMinute, dwSeconds, FALSE, "", "" )


/// <summary>
/// Return the timestring from a DateTime structure
/// </summary>
/// <param name="dt">DateTime values that needs to be converted</param>
/// <returns>A (military) time that corresponds to the passed arguments in the format HH:MM:SS without AM/PM notation.</returns>
FUNCTION ConTime(dt AS DateTime) AS STRING
	RETURN _TimeString((DWORD) dt:Hour,(DWORD) dt:Minute,(DWORD) dt:Second, FALSE, "","")

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/ntocdow/*" />
FUNCTION NToCDoW(dwDayNum AS DWORD) AS STRING
	LOCAL result AS STRING
	IF dwDayNum < 1 .OR. dwDayNum > 7
		result := ""
	ELSEIF RuntimeState.International == CollationMode.Clipper
		result := __CavoStr(VOErrors.RT_MSG_DAY1 + dwDayNum -1)
	ELSE
		VAR culture := System.Globalization.CultureInfo.CurrentCulture
		result := culture:DateTimeFormat:GetDayName((DayOfWeek) (dwDayNum-1))
	ENDIF
	RETURN result

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/ntocmonth/*" />
FUNCTION NToCMonth(dwMonthNum AS DWORD) AS STRING
	LOCAL result AS STRING
	IF dwMonthNum < 1 .OR. dwMonthNum > 12
		result := ""
	ELSEIF RuntimeState.International == CollationMode.Clipper
		result := __CavoStr(VOErrors.RT_MSG_MONTH1 + dwMonthNum -1)
	ELSE
		VAR culture := System.Globalization.CultureInfo.CurrentCulture
		result := culture:DateTimeFormat:GetMonthName((INT)dwMonthNum)
	ENDIF
	RETURN result

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/secs/*" />
FUNCTION Secs(cTime AS STRING) AS DWORD
	// Note that VO "accepts" practically any format, even say "0:#23:&1" and returns semi random results, but we will not emulate all that
	// Instead, we support formats that make sense, like "HH", "HH:MM" and "HH:MM:SS". And, oh, we do support also "10:99:99" that VO allows as well..
	LOCAL cSeparator AS STRING
	LOCAL nHours AS INT
	LOCAL nMinutes AS INT
	LOCAL nSeconds AS INT
	LOCAL result AS DWORD
	IF String.IsNullOrEmpty(cTime)
		RETURN 0
	ENDIF
	cSeparator := Chr(GetTimeSep())
	LOCAL nOffSet := 0 AS INT
	TRY
		nHours   := Int32.Parse(cTime:Substring(nOffSet,2))
	CATCH
		nHours   := 0
	END TRY
	nOffSet += cSeparator:Length +2
	TRY
		nMinutes := Int32.Parse(cTime:Substring(nOffSet,2))
	CATCH
		nMinutes := 0
	END TRY
	nOffSet += cSeparator:Length +2
	TRY
		nSeconds := Int32.Parse(cTime:Substring(nOffSet,2))
	CATCH
		nSeconds := 0
	END TRY
	result := (DWORD) (nHours * SECONDSPERHOUR + nMinutes * SECONDSPERMINUTE + nSeconds)
	RETURN result

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/days/*" />
FUNCTION Days(nSeconds AS REAL8) AS INT
   RETURN (INT) (nSeconds / SECONDSPERDAY) // 24*60*60

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/seconds/*" />
FUNCTION Seconds() AS REAL8
	VAR dt := DateTime.Now
    LOCAL result AS REAL8
    result := dt:Hour * SECONDSPERHOUR + dt:Minute * SECONDSPERMINUTE + dt:Second + (REAL8) (dt:Millisecond)/1000.0
    IF XSharp.RuntimeState.Dialect == XSharpDialect.FoxPro
        result := Math.Round(result,3)
    ELSE
        result := Math.Round(result,2)
    ENDIF
	RETURN result



/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/time/*" />
FUNCTION Time() AS STRING
   VAR d := DateTime.Now
   RETURN _TimeString(d)

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/time24/*" />
FUNCTION Time24() AS STRING
   LOCAL d := DateTime.Now AS DateTime
   RETURN _TimeString((DWORD) d:Hour,(DWORD) d:Minute,(DWORD) d:Second,FALSE,"","")


/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/tstring/*" />
FUNCTION TString(nSeconds AS REAL8) AS STRING
   RETURN TString( (DWORD) Math.Round( nSeconds, MidpointRounding.ToEven ) )

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/tstring/*" />
FUNCTION TString(nSeconds AS DWORD) AS STRING
   LOCAL dwHours AS DWORD
   LOCAL dwMinutes AS DWORD
   // truncate to one day
   nSeconds := nSeconds % (SECONDSPERDAY)
   dwHours   := nSeconds / (SECONDSPERHOUR)
   nSeconds := nSeconds % (SECONDSPERHOUR)
   dwMinutes := nSeconds / SECONDSPERMINUTE
   nSeconds := nSeconds % SECONDSPERMINUTE
   RETURN _TimeString(dwHours, dwMinutes, nSeconds, GetAmPm(), GetAMExt(), GetPMExt())


INTERNAL FUNCTION _TimeString( d AS DateTime ) AS STRING
   RETURN _TimeString( (DWORD) d:Hour, (DWORD) d:Minute, (DWORD) d:Second, SetAmPm(), GetAMExt(), GetPMExt() )


INTERNAL FUNCTION _TimeString( h AS DWORD, m AS DWORD, s AS DWORD, lAMPM AS LOGIC, cAM AS STRING, cPM AS STRING ) AS STRING
   LOCAL cTimeSep   AS STRING
   LOCAL lAfternoon AS LOGIC
   // no exceptions, vo simply returns an empty string
   IF h < 0 || h > 23
      RETURN ""
   ELSEIF m < 0 || m > 59
      RETURN ""
   ELSEIF s < 0 || s > 59
      RETURN ""
   ENDIF

   IF s == 60
      s := 0
      m += 1
      IF m == 60
         m := 0
         h += 1
      ENDIF
      IF h == 24
         h := 0
      ENDIF
   ENDIF

   cTimeSep := Chr( GetTimeSep() )

   lAfternoon := h >= 12

   IF lAMPM
      IF h > 12
         h -= 12
      ELSEIF h == 0
         h := 12
      ENDIF
   ENDIF

   RETURN String.Format( "{0:00}{3}{1:00}{3}{2:00}{4}", h, m, s, cTimeSep, IIF( lAMPM, IIF( lAfternoon, cPM, cAM ), "" ) )



/// <summary>
/// Format a set of numbers representing a year, month, and day as a Date.
/// </summary>
/// <param name="dwY">A valid year.  If the century digits are not specified, the century is determined by the rules of SetEpoch(). </param>
/// <param name="dwM">A number from 1 through 12 representing a valid month. </param>
/// <param name="dwDay">A number representing a valid day of dwMonth.</param>
/// <returns>The date that corresponds to the passed arguments.  If any of the arguments specified do not represent a valid year, month, or day, a DateTime.MinValue is returned.</returns>
FUNCTION ConDateTime(dwY AS DWORD,dwM AS DWORD,dwDay AS DWORD) AS DateTime
    IF dwM == 0 .OR. dwDay == 0
        RETURN DateTime.MinValue
    ENDIF
    IF dwY < 100
		LOCAL lAfter AS LOGIC
		lAfter := dwY > XSharp.RuntimeState.EpochYear
		dwY += XSharp.RuntimeState.EpochCent
		IF lAfter
			dwY -= 100
		ENDIF
   ENDIF
   TRY
	    RETURN DateTime{(INT) dwY,(INT) dwM,(INT) dwDay}
   CATCH
        RETURN DateTime.MinValue
   END TRY
#pragma options ("az", on)
STATIC FUNCTION _SplitDate(cDate AS STRING) AS INT[]
	LOCAL aNums := INT[]{3} AS INT[]
	LOCAL nCurrent := 0 AS INT
    LOCAL lAfterDigit := FALSE AS LOGIC
    FOREACH cChar AS CHAR IN cDate
        IF cChar >= '0' .AND. cChar <= '9'
            aNums[nCurrent] *= 10
            aNums[nCurrent] += (cChar - c'0')
            lAfterDigit := TRUE
		ELSEIF lAfterDigit
            // Next number group, so also space after numbers is separator
			nCurrent++
			IF nCurrent > 2
				EXIT
            END IF
            lAfterDigit := FALSE
        ELSE
            // second and more non digits are ignored
            NOP
		END IF
	NEXT
RETURN aNums
#pragma options ("az", restore)

/// <summary>
/// Convert a Date string to DateTime.
/// </summary>
/// <param name="cDate">A string of numbers representing the month, day, and year, separated by any character other than a number.  The month, day, and year digits must be in the format set by SetDateFormat() or SetDateCountry().  If the century digits are not specified, the century is determined by the rules of SetEpoch().</param>
/// <param name="cDateFormat">A string representating the date format to use when converting the string to a date. Should consist of D, M and Y characters and separators.</param>
/// <returns>The DateTime value that corresponds to the numbers specified in <paramref name="cDate"/>.  If <paramref name="cDate"/> is not a valid date, CToDt() returns a DateTime.MinValue.
/// </returns>
FUNCTION CToDt(cDate AS STRING, cDateFormat AS STRING) AS DateTime
	LOCAL dDate AS DateTime
	LOCAL nDay, nMonth, nYear AS INT
	LOCAL nDayPos, nMonthPos, nYearPos AS INT
	dDate := DateTime.MinValue
	IF String.IsNullOrEmpty(cDate) .OR. String.IsNullOrEmpty(cDateFormat) .OR. cDate == RuntimeState.GetValue<STRING>(Set.DateFormatEmpty)
		RETURN dDate
	ENDIF
	LOCAL nPos AS INT
//	LOCAL cSep AS STRING
	nDayPos := nMonthPos := nYearPos := -1
//	cSep := "./-"
	nPos :=-1
	FOREACH c AS CHAR IN cDateFormat
		SWITCH c
		CASE 'D'
			IF nDayPos == -1
				++nPos
				nDayPos  := nPos
			ENDIF
		CASE 'M'
			IF nMonthPos == -1
				++nPos
				nMonthPos  := nPos
			ENDIF
		CASE 'Y'
			IF nYearPos == -1
				++nPos
				nYearPos  := nPos
			ENDIF
		OTHERWISE
			NOP
/*			IF cSep:IndexOf(c) == -1
				cSep += c:ToString()
			ENDIF*/
		END SWITCH
	NEXT
	IF nDayPos == -1 .OR. nMonthPos == -1 .OR. nYearPos == -1
		RETURN dDate
	ENDIF

	IF nYearPos == 2
		RETURN _CToDt_YearAtTheEnd(cDate, nDayPos, nMonthPos, nYearPos)
	END IF

	TRY
		// we now know the seperators and the positions in the string
		// LOCAL aNums := cDate:Split(cSep:ToCharArray()) AS STRING[]
		// VO's CToD() "correctly" parses dates with any char used as separator
		LOCAL aNums := _SplitDate(cDate) AS INT[]
        nDay := aNums[nDayPos]
        nMonth := aNums[nMonthPos]
        nYear := aNums[nYearPos]
        IF nDay != 0 .AND. nMonth != 0 .AND. nYear != 0
		    IF aNums[nYearPos] < 100 .and. cDate:Length != 10
			    // Century missing ?
			    dDate := ConDateTime((DWORD)nYear, (DWORD)nMonth, (DWORD)nDay)
		    ELSE
			    dDate := System.DateTime{nYear, nMonth, nDay}
            ENDIF
        ELSE
            dDate := DateTime.MinValue
        ENDIF
	CATCH
		dDate := DateTime.MinValue
	END TRY
	RETURN dDate


// We introduce a special version of the function that handles many of VO's strange behaviors when year is specified
// last in the date format template. If the year is not specified last, then the behavior is yet again very different
STATIC FUNCTION _CToDt_YearAtTheEnd(cDate AS STRING, nDayPos AS INT, nMonthPos AS INT, nYearPos AS INT) AS DateTime

	LOCAL FUNCTION Local_SplitDate(cDate AS STRING) AS INT[]
		LOCAL aNums := INT[]{3} AS INT[]
		LOCAL nCurChar := 0 AS INT
		LOCAL nCurGroup := 0 AS INT
		LOCAL nCurLength := 0 AS INT
		LOCAL cChar AS Char
		cDate := cDate:Trim()
		DO WHILE nCurChar < cDate:Length
			cChar := cDate[nCurChar]
			nCurChar ++
			IF cChar >= '0' .AND. cChar <= '9'
				nCurLength ++
				IF nCurLength > 2
					RETURN NULL
				END IF
				aNums[nCurGroup] *= 10
				aNums[nCurGroup] += (cChar - c'0')
			ELSE
		            // Next number group, so also space after numbers is separator
				nCurGroup ++
				nCurLength := 0
				IF nCurGroup > 1 // we handle the year part below
					EXIT
				END IF
			END IF
		END DO

		LOCAL cYear := cDate:Substring(nCurChar) AS STRING
		LOCAL nYear := 0 AS INT
		LOCAL nYearLength := 0 AS INT
		LOCAL nMultiplier := 1 AS INT
		nCurChar := cYear:Length - 1
		DO WHILE nCurChar >= 0
			cChar := cYear[nCurChar]
			nCurChar --
			IF cChar >= '0' .AND. cChar <= '9'
				nYearLength ++
				IF nYearLength > 4
					RETURN NULL
				END IF
				nYear += (cChar - c'0') * nMultiplier
				nMultiplier *= 10
			ELSE
				EXIT
			END IF
		ENDDO

		SWITCH nYearLength
		CASE 1
		CASE 2
		    	// VO behavior...
			IF (nYearLength == 1 .and. cYear:Length > 2) .or. (nYearLength == 2 .and. cYear:Length > 3)
				RETURN NULL
			END IF
			aNums[2] := - nYear // use SetEpoch() setting
		CASE 3
			RETURN NULL
		CASE 4
			aNums[2] := nYear
		OTHERWISE
			RETURN NULL
		    	// actually, if no year is specified, then VO uses the middle number also for the year!
		    	// so CToD("05.05") results to 05.05.2005
		    	// but this is too stupid, we will not emulate it
		END SWITCH
		RETURN aNums
	END FUNCTION


	LOCAL dDate AS DateTime
	dDate := DateTime.MinValue
	TRY
		LOCAL nDay, nMonth, nYear AS INT
		LOCAL aNums := Local_SplitDate(cDate) AS INT[]
		IF aNums == NULL
			RETURN DateTime.MinValue
		END IF
		nDay := aNums[nDayPos]
		nMonth := aNums[nMonthPos]
		nYear := aNums[nYearPos]
		IF nDay != 0 .AND. nMonth != 0
			IF nYear <= 0
				    // Century missing ?
				nYear := - nYear
				dDate := ConDateTime((DWORD)nYear, (DWORD)nMonth, (DWORD)nDay)
			ELSE
				dDate := System.DateTime{nYear, nMonth, nDay}
			ENDIF
		ELSE
			dDate := DateTime.MinValue
		ENDIF
	CATCH
		dDate := DateTime.MinValue
	END TRY
RETURN dDate


/// <summary>
/// Convert an ANSI date string to DateTime
/// </summary>
/// <param name="cDate">A string in the ANSI form yyyy.mm.dd, where yy, mm, and dd represent year, month, and day respectively.
/// The year, month, and day can be separated by any character other than a number.
/// cDate is always interpreted as an ANSI string and is not dependent on SetDateFormat() or SetDateCountry().
/// If the century digits are not specified, the century is determined by the rules of SetEpoch().</param>
/// <returns>The date value that corresponds to the numbers specified in <paramref name="cDate"/>.  If cDate is not a valid ANSI date, CToDAnsi() returns a DateTime.MinValue.
/// </returns>
FUNCTION CToDtAnsi(cDate AS STRING) AS DateTime
	RETURN CToDt(cDate, "YYYY.MM.DD")


/// <summary>
/// Convert a DateTime to a string.
/// </summary>
/// <param name="d">The DateTime to be converted.</param>
/// <returns>
/// A string representation of the given Date, formatted in the current Date format.
/// </returns>
FUNCTION DtToC(d AS DateTime) AS STRING
	LOCAL result:="" AS STRING
	LOCAL cFormat := XSharp.RuntimeState.GetValue<STRING>(Set.DateFormatNet) AS STRING
	IF d != DateTime.MinValue
		LOCAL dt := d AS DateTime
		result := dt:ToString(cFormat)
	ELSE
		result := RuntimeState.NullDateString
	ENDIF
	RETURN result

/// <summary>
/// Convert a DateTime value to a string formatted as string in ANSI format
/// </summary>
/// <param name="dDate">The DateTime to be converted</param>
/// <returns>
/// An 8-character string in the format yyyymmdd.  If dDate is a DateTime.MinValue, a string of eight spaces is returned.  The return value is not affected by the current date format.
/// </returns>
FUNCTION DtToS(dDate AS DateTime) AS STRING
	LOCAL result := NULL  AS STRING
	IF dDate != DateTime.MinValue
		result := dDate:ToString("yyyyMMdd")
    ELSE
        result:="        "
	ENDIF
	RETURN result

/// <summary>
/// Convert an Date string to DateTime
/// </summary>
/// <param name="cDate"></param>
/// <returns><inheritdoc cref='M:XSharp.RT.Functions.CToD(System.String)'/></returns>
FUNCTION SToDt(cDate AS STRING) AS DateTime
	LOCAL convertedDate AS DateTime
	TRY
        IF String.IsNullOrWhiteSpace(cDate)
            convertedDate := DateTime.MinValue
        ELSE
            IF cDate:Length == 8 .AND. cDate[0] == c'0' .AND. cDate[1] == c'0'
			    // VO adjusts date strings like "00yyMMdd" to epoch-based year
			    LOCAL dwY AS DWORD
			    dwY := UInt32.Parse(cDate:Substring(0,4))

			    // same code as in ConDate(), probably better adjust SToD() to use ConDate() directly
			    LOCAL lAfter AS LOGIC
			    lAfter := dwY > XSharp.RuntimeState.EpochYear
			    dwY += XSharp.RuntimeState.EpochCent
			    IF lAfter
				    dwY -= 100
			    ENDIF

			    cDate := dwY:ToString():PadLeft(4 , c'0') + cDate:Substring(4)
    		END IF
	    	convertedDate := DateTime.ParseExact(cDate, "yyyyMMdd", System.Globalization.CultureInfo.InvariantCulture)
        ENDIF

	CATCH
		convertedDate := DateTime.MinValue
	END TRY
	RETURN	 convertedDate

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/datetime/*" />
FUNCTION @@DateTime() AS DateTime
    RETURN DateTime.Now

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/datetime/*" />
FUNCTION @@DateTime(nYear AS INT, nMonth AS INT, nDay AS INT) AS DateTime
    RETURN System.DateTime{nYear, nMonth, nDay}

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/datetime/*" />
FUNCTION @@DateTime(nYear AS INT, nMonth AS INT, nDay AS INT, nHours AS INT) AS DateTime
    RETURN System.DateTime{nYear, nMonth, nDay,nHours, 0, 0}

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/datetime/*" />
FUNCTION @@DateTime(nYear AS INT, nMonth AS INT, nDay AS INT, nHours AS INT, nMinutes AS INT) AS DateTime
    RETURN System.DateTime{nYear, nMonth, nDay,nHours, nMinutes, 0}

/// <include file="VoFunctionDocs.xml" path="Runtimefunctions/datetime/*" />
FUNCTION @@DateTime(nYear AS INT, nMonth AS INT, nDay AS INT, nHours AS INT, nMinutes AS INT, nSeconds AS INT) AS DateTime
    RETURN System.DateTime{nYear, nMonth, nDay,nHours, nMinutes, nSeconds}


