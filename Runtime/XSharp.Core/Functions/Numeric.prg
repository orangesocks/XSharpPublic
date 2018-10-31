//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//

/// <summary>
/// Return the absolute value of a strongly typed numeric expression, regardless of its sign.
/// </summary>
/// <param name="i"></param>
/// <returns>
/// </returns>
FUNCTION AbsInt(i AS LONGINT) AS LONG
	RETURN Math.Abs(i)

/// <summary>
/// Return the absolute value of a strongly typed numeric expression, regardless of its sign.
/// </summary>
/// <param name="li"></param>
/// <returns>
/// </returns>
FUNCTION AbsLong(li AS LONGINT) AS LONG
	RETURN Math.Abs(li)

/// <summary>
/// Return the absolute value of a strongly typed numeric expression, regardless of its sign.
/// </summary>
/// <param name="r4"></param>
/// <returns>
/// </returns>
FUNCTION AbsReal4(r4 AS REAL4) AS REAL4
	RETURN Math.Abs(r4)

/// <summary>
/// Return the absolute value of a strongly typed numeric expression, regardless of its sign.
/// </summary>
/// <param name="r8"></param>
/// <returns>
/// </returns>
FUNCTION AbsReal8(r8 AS REAL8) AS REAL8
	RETURN Math.Abs(r8)

/// <summary>
/// Return the absolute value of a strongly typed numeric expression, regardless of its sign.
/// </summary>
/// <param name="si"></param>
/// <returns>
/// </returns>
FUNCTION AbsShort(si AS SHORT) AS LONG
	RETURN Math.Abs(si)


/// <summary>
/// Return the remainder of one number divided by another number
/// </summary>
/// <param name="dividend">The dividend of the division operation</param>
/// <param name="divisor">The divisor of the division operation</param>
/// <returns>A number representing the remainder of <paramref name="dividend"/> divided by <paramref name="divisor"/>.</returns>
FUNCTION Mod(dividend AS REAL8, divisor AS REAL8) AS REAL8
	RETURN dividend % divisor

/// <summary>
/// Return the remainder of one number divided by another number
/// </summary>
/// <param name="dividend">The dividend of the division operation</param>
/// <param name="divisor">The divisor of the division operation</param>
/// <returns>A number representing the remainder of <paramref name="dividend"/> divided by <paramref name="divisor"/>.</returns>
FUNCTION Mod(dividend AS INT64, divisor AS INT64) AS INT64
	RETURN dividend % divisor


/// <summary>
/// Return the remainder of one number divided by another number
/// </summary>
/// <param name="dividend">The dividend of the division operation</param>
/// <param name="divisor">The divisor of the division operation</param>
/// <returns>A number representing the remainder of <paramref name="dividend"/> divided by <paramref name="divisor"/>.</returns>
FUNCTION Mod(dividend AS LONG, divisor AS LONG) AS LONG
	RETURN dividend % divisor

/// <summary>
/// Exchange the right and left halves of a byte.
/// </summary>
/// <param name="b">The byte whose nibbles should be swaped.</param>
/// <returns>
/// New value with the nibbles swapped.
/// </returns>
FUNCTION SwapByte(b AS BYTE) AS BYTE
	RETURN (b << 4) | (b >> 4)

/// <summary>
/// Exchange the right and left halves of a double word.
/// </summary>
/// <param name="dw"></param>
/// <returns>
/// </returns>
FUNCTION SwapDWord(dw AS DWORD) AS DWORD
	LOCAL dw1, dw2 AS DWORD
	dw1 := (dw & 0x0000ffff) << 16
	dw2 := (dw >> 16) & 0x0000ffff
	dw := dw1 | dw2
RETURN	dw

/// <summary>
/// Exchange the right and left halves of an integer.
/// </summary>
/// <param name="li"></param>
/// <returns>
/// </returns>
FUNCTION SwapInt(li AS LONG) AS LONG
	RETURN SwapLong(li) 

/// <summary>
/// Exchange the right and left halves of a long integer.
/// </summary>
/// <param name="li"></param>
/// <returns>
/// </returns>
FUNCTION SwapLong(li AS LONG) AS LONG
	LOCAL li1, li2 AS LONG
	li1 := (li & 0x0000ffff) << 16
	li2 := (li >> 16) & 0x0000ffff
	li := li1 | li2
	RETURN li


/// <summary>
/// Exchange the right and left halves of a Int64
/// </summary>
/// <param name="i64"></param>
/// <returns>
/// </returns>
FUNCTION SwapInt64( i64 AS INT64 ) AS INT64
   RETURN (INT64)  ( i64 << 32 ) | ( i64 >> 32 ) 

/// <summary>
/// Exchange the right and left halves of a short integer.
/// </summary>
/// <param name="si"></param>
/// <returns>
/// </returns>
FUNCTION SwapShort(si AS SHORT) AS SHORT
RETURN	 ((SHORT)((si & 0x00ff) << 8) | ((si >> 8) & 0x00ff))

/// <summary>
/// Exchange the right and left halves of a word.
/// </summary>
/// <param name="w"></param>
/// <returns>
/// </returns>
FUNCTION SwapWord(w AS WORD) AS WORD
RETURN ((WORD)((w & 0x00ff) << 8) | ((w >> 8) & 0x00ff))



FUNCTION SwapQWord( qw AS UINT64 ) AS UINT64
   RETURN (UINT64)  ( qw << 32 ) | ( qw >> 32 ) 

 



FUNCTION MakeDWord( wLow AS WORD, wHigh AS WORD ) AS DWORD
	RETURN DWORD( ( DWORD(wHigh) << 16 ) | wLow )

FUNCTION MakeLong( wLow AS WORD, wHigh AS WORD ) AS INT
	RETURN INT( ( DWORD(wHigh) << 16 ) | wLow )

FUNCTION MakeWord( bLow AS BYTE, bHigh AS BYTE ) AS WORD
	RETURN WORD( ( WORD(bHigh) << 8 ) | bLow )

/// <summary>
/// Get a particular Windows color.
/// </summary>
/// <param name="bR"></param>
/// <param name="bG"></param>
/// <param name="bB"></param>
/// <returns>
/// </returns>
FUNCTION RGB(bR AS BYTE,bG AS BYTE,bB AS BYTE) AS DWORD
	RETURN (DWORD(bB) << 16) + (DWORD(bG) << 8) + DWORD(bR)

