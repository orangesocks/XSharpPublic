//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//

USING System.Globalization
// StringComparer class that takes care of Windows and Clipper string comparisons
/// <exclude />
STATIC CLASS XSharp.StringHelpers
	PRIVATE STATIC collationTable AS BYTE[]
	PRIVATE STATIC encDos	AS System.Text.Encoding
    PRIVATE STATIC encWin	AS System.Text.Encoding
	PRIVATE STATIC bLHS		AS BYTE[]       // cache byte array to avoid having to allocate bytes for every comparison
	PRIVATE STATIC bRHS		AS BYTE[]
	PRIVATE STATIC gate		AS OBJECT

    PUBLIC STATIC PROPERTY WinEncoding AS System.Text.Encoding GET encWin
    PUBLIC STATIC PROPERTY DosEncoding AS System.Text.Encoding GET encDos

    /// <exclude />
	STATIC CONSTRUCTOR
		// Register event Handlers, so we can reread tye DOS and Windows codepages
		// and collation table when the user changes these
		RuntimeState.OnCodePageChanged += Changed
		RuntimeState.OnCollationChanged += Changed
		GetValues()
		bLHS := BYTE[]{512}
		bRHS := BYTE[]{512}
		gate := OBJECT{}

    /// <exclude />
	STATIC METHOD Changed (o AS OBJECT, e AS EventArgs) AS VOID
        // This event gets called when the codepage has changed or the collation has changed
		GetValues()

    /// <exclude />
	STATIC METHOD GetValues() AS VOID
		collationTable	:= RuntimeState.CollationTable
		encDos			:= RuntimeState.DosEncoding
        encWin			:= RuntimeState.WinEncoding
		RETURN
		
    /// <exclude />
	STATIC METHOD CompareWindows(strLHS AS STRING, strRHS AS STRING) AS INT
		LOCAL nLen	AS INT
        LOCAL result AS INT
        LOCAL lhsLen AS INT
        LOCAL rhsLen AS INT
        LOCAL adjust AS INT
        lhsLen := strLHS:Length
        rhsLen := strRHS:Length
        IF lhsLen >= rhsLen
            nLen := rhsLen
            adjust := 0
        ELSE
            nLen := lhsLen
            adjust := 1
        ENDIF
		// Lock because we are using the same byte array for each comparison
        BEGIN LOCK gate
			IF nLen > bLHS:Length
				bLHS := BYTE[]{nLen}
				bRHS := BYTE[]{nLen}
			ENDIF
			encWin:GetBytes(strLHS, 0, nLen, bLHS, 0)
			encWin:GetBytes(strRHS, 0, nLen, bRHS, 0)
            result := CompareWindows(bLHS, bRHS, nLen)
            IF result == 0          // when equal: if lhs shorter than rhs then return -1
                result -= adjust    
            ENDIF

        END LOCK
        RETURN result

    STATIC METHOD CompareWindows(bLHS AS BYTE[], bRHS AS BYTE[], nLen AS LONG) AS INT
        LOCAL result AS INT
        result := Win32.CompareStringAnsi(CultureInfo.CurrentCulture:LCID, Win32.SORT_STRINGSORT,bLHS, nLen, bRHS, nLen)
        IF result != 0  // 0 = error, 1 = less, 2 = equal, 3 = greater
            result -= 2
        ELSE
            // what to do ?
            result := System.Runtime.InteropServices.Marshal.GetLastWin32Error()
            result := 0
        ENDIF
        RETURN result
		
		
    /// <exclude />
    STATIC METHOD CompareClipper(strLHS AS STRING, strRHS AS STRING) AS INT
		LOCAL rLen   AS INT
		LOCAL nLen	AS INT
		// when we get here then reference equality is not TRUE. THat has been checked
		// before this method is called.
		nLen := Math.Min(strLHS:Length, strRHS:Length)
        // Lock because we are using the same byte array for each comparison
		BEGIN LOCK gate
			IF nLen > bLHS:Length
				bLHS := BYTE[]{nLen}
				bRHS := BYTE[]{nLen}
			ENDIF
			encDos:GetBytes(strLHS, 0, nLen, bLHS, 0)
			encDos:GetBytes(strRHS, 0, nLen, bRHS, 0)
            VAR nResult := CompareClipper(bLHS, bRHS, nLen)
            IF nResult != 0
                RETURN nResult
            ENDIF
		END LOCK
		// all bytes that we compared are equal so return 0 when the strings have the same length
		// otherwise the shorter string is smaller than the longer string
		nLen := strLHS:Length
		rLen := strRHS:Length
		RETURN IIF(nLen ==rLen, 0, IIF(nLen < rLen, -1, 1))

   STATIC METHOD CompareClipper(bLHS AS BYTE[], bRHS AS BYTE[], nLen AS LONG) AS INT
		BEGIN UNCHECKED
            IF bLHS == NULL
                IF bRHS == NULL
                    RETURN 0
                ENDIF
                RETURN -1
            ELSEIF bRHS == NULL
                RETURN 1
            ENDIF
            nLen := Math.Min(nLen, Math.Min(bLHS:Length, bRHS:Length))
            IF collationTable == NULL
                VAR oErr := Error{Gencode.EG_NULLVAR,nameof(collationTable),"The collation table is not initialized"} 
                oErr:FuncSym := __FUNCTION__
                THROW oErr
            ELSEIF collationTable:Length < Byte.MaxValue+1
                VAR oErr := Error{Gencode.EG_LIMIT, nameof(collationTable), "The size of the collation table is too small: "+collationTable:Length:ToString()}
                oErr:FuncSym := __FUNCTION__
                THROW oErr
            ENDIF
			FOR VAR nPos := 0 TO nLen -1
				VAR nL := bLHS[nPos]
				VAR nR := bRHS[nPos]
				// no need to lookup the same character. The weight table will
				// have the same value for both
				IF nL != nR
					nL := collationTable[nL]
					nR := collationTable[nR]
					IF nL < nR
						RETURN -1
					ELSEIF nL > nR
						RETURN 1
					ELSE
						// equal, so continue with the next chars
						// this normally only happens when 2 characters are mapped to the same weight
						// that could for example happen when � and u have the same weight
						// I am not sure if this ever happens. If would make creating an index unreliable
						// most likely the � will be sorted between u and v. 
					ENDIF
				ENDIF
			NEXT
		END UNCHECKED
        RETURN 0

    STATIC METHOD CompareOrdinal(bLHS AS BYTE[], bRHS AS BYTE[], nLen AS LONG) AS INT
		BEGIN UNCHECKED
            IF bLHS == NULL
                IF bRHS == NULL
                    RETURN 0
                ENDIF
                RETURN -1
            ELSEIF bRHS == NULL
                RETURN 1
            ENDIF
            nLen := Math.Min(nLen, Math.Min(bLHS:Length, bRHS:Length))
			FOR VAR nPos := 0 TO nLen -1
				VAR nL := bLHS[nPos]
				VAR nR := bRHS[nPos]
				IF nL < nR
					RETURN -1
				ELSEIF nL > nR
					RETURN 1
				ELSE
					// equal, so continue with the next chars
				ENDIF
			NEXT
		END UNCHECKED
        RETURN 0
END CLASS


