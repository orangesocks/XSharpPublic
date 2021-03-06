//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
USING System.Collections.Generic
USING System.Runtime.InteropServices
/// <summary>
/// This class contains helper code that is called by the compiler to support various XBase language constructs, such as the
/// automatic memory management of PSZ values created with String2Psz().
/// </summary>
STATIC CLASS XSharp.Internal.CompilerServices
	///<summary>
    /// Subtract 2 strings.
    ///</summary>
	STATIC METHOD StringSubtract (lhs AS STRING, rhs AS STRING) AS STRING
		IF lhs != NULL .AND. rhs != NULL
			VAR len := lhs:Length + rhs:Length
			RETURN (lhs:TrimEnd() + rhs:TrimEnd()):PadRight(len)
		ELSEIF lhs != NULL
			RETURN lhs
		ELSEIF rhs != NULL
			RETURN rhs
		ENDIF
		RETURN String.Empty
	
	///<summary>
    /// Allocate a PSZ and add it to the list
    ///</summary>
	STATIC METHOD String2Psz(s AS STRING, pszList AS List<IntPtr>) AS IntPtr
		LOCAL pResult AS IntPtr
		IF s == NULL || s:Length == 0
			pResult := MemAlloc(1)
            Marshal.WriteByte(pResult, 0, 0)	 // end of string
        ELSE
            pResult := String2Mem(s)
		ENDIF
		pszList:Add(pResult)
		RETURN pResult
	
	///<summary>
    /// Free all PSZ values in the List
    ///</summary>
	STATIC METHOD String2PszRelease(pszList AS List<IntPtr>) AS VOID
		FOREACH VAR p IN pszList
			TRY
				MemFree(p)
            CATCH as Exception
                NOP
			END TRY
		NEXT
		RETURN
    
	///<summary>
    /// Increment the SEQUENCE counter for a BEGIN SEQUENCE statement
    ///</summary>
    STATIC METHOD EnterBeginSequence AS VOID
		RuntimeState.GetInstance():BreakLevel+= 1

	///<summary>
    /// Decrement the SEQUENCE counter for a BEGIN SEQUENCE statement
    ///</summary>
    STATIC METHOD ExitBeginSequence	 AS VOID
		RuntimeState.GetInstance():BreakLevel-= 1

    ///<summary>
    /// Determine if we are inside a BEGIN SEQUENCE .. END by looking at the SEQUENCE counter in the runtime.
    ///</summary>
	STATIC METHOD CanBreak AS LOGIC
		RETURN RuntimeState.GetInstance():BreakLevel > 0

    STATIC METHOD StringArrayInit(a as System.Array) AS VOID
        LOCAL ranks     := a:Rank AS INT
        LOCAL counters  := INT[]{ranks} as INT[]
        LOCAL bounds    := INT[]{ranks} as INT[]
        FOR VAR i := 1 to ranks
            bounds[i] := a:GetLength(i-1)
        NEXT
        StringArrayInitHelper(a, counters, bounds, ranks)
        RETURN

    PRIVATE STATIC METHOD StringArrayInitHelper( s as System.Array, counters as  int[] , bounds as int[], rank as int) AS VOID
        if  rank == 1
            FOR VAR x:= 1 UPTO  bounds[1] STEP 1
                counters[rank] := x -1             // the counters array must be 0 based
                s:SetValue( "", counters )
            NEXT
        else
            FOR VAR x := 1 UPTO  bounds[rank]  STEP 1
                counters[rank] := x -1          // the counters array must be 0 based
                StringArrayInitHelper( s, counters, bounds, rank - 1 )
            NEXT
        ENDIF

END CLASS
