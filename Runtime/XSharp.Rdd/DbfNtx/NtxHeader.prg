//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//


USING System
USING System.Collections.Generic
USING System.Text
USING System.IO
USING System.Runtime.CompilerServices

BEGIN NAMESPACE XSharp.RDD.NTX

	/// <summary>
	/// The NtxHeader class.
	/// </summary>
	INTERNAL SEALED CLASS NtxHeader
		// Fixed Buffer of 1024 bytes
		// https://www.clicketyclick.dk/databases/xbase/format/ntx.html#NTX_STRUCT  
		// Read/Write to/from the Stream with the Buffer 
		// and access individual values using the other fields
		PRIVATE _hFile AS IntPtr
		PRIVATE Buffer   AS BYTE[]
		// Hot ?  => Header has changed ?
		INTERNAL isHot	AS LOGIC
        PRIVATE _Order as NtxOrder
        PRIVATE PROPERTY Encoding as System.Text.Encoding GET _Order:Encoding
		
		INTERNAL METHOD Read() AS LOGIC
			LOCAL isOk AS LOGIC
			// Move to top
			FSeek3( SELF:_hFile, 0, SeekOrigin.Begin )
			// Read Buffer
			isOk := FRead3(SELF:_hFile, SELF:Buffer, NTXHEADER_SIZE) == NTXHEADER_SIZE 
			//
			RETURN isOk
			
		INTERNAL METHOD Write() AS LOGIC
			LOCAL isOk AS LOGIC
			// Move to top
			FSeek3( SELF:_hFile, 0, SeekOrigin.Begin )
			// Write Buffer
			isOk :=  FWrite3(SELF:_hFile, SELF:Buffer, NTXHEADER_SIZE) == NTXHEADER_SIZE 
			RETURN isOk
			
			
			
		INTERNAL CONSTRUCTOR( oOrder as NtxOrder, fileHandle AS IntPtr )
			SELF:_hFile := fileHandle
            SELF:_Order := oOrder
			Buffer := BYTE[]{NTXHEADER_SIZE}
			isHot  := FALSE
			
			RETURN
			
			
			
        [MethodImpl(MethodImplOptions.AggressiveInlining)];        
		PRIVATE METHOD _GetString(nOffSet AS INT, nSize AS INT) AS STRING
			LOCAL tmp := BYTE[]{nSize} AS BYTE[]
			Array.Copy( Buffer, nOffSet, tmp, 0, nSize )
			LOCAL count := Array.FindIndex<BYTE>( tmp, 0, { sz => sz == 0 } ) AS INT
			IF count == -1
				count := nSize
			ENDIF
			LOCAL str := SELF:Encoding:GetString( tmp,0, count ) AS STRING
			IF  str == NULL 
				str := String.Empty
			ENDIF
			str := str:Trim()
			RETURN str
				
        [MethodImpl(MethodImplOptions.AggressiveInlining)];        
		PRIVATE METHOD _SetString(nOffSet AS INT, nSize AS INT, sValue AS STRING) AS VOID
			// Be sure to fill the Buffer with 0
			Array.Clear( Buffer, nOffSet, nSize )
			SELF:Encoding:GetBytes( sValue, 0, Math.Min(nSize,sValue:Length), Buffer, nOffSet)
			isHot := TRUE
				
        [MethodImpl(MethodImplOptions.AggressiveInlining)];        
		PRIVATE METHOD _GetWord(nOffSet AS INT) AS WORD
			RETURN BitConverter.ToUInt16(Buffer, nOffSet)
				
        [MethodImpl(MethodImplOptions.AggressiveInlining)];        
		PRIVATE METHOD _SetWord(nOffSet AS INT, wValue AS WORD) AS VOID
			Array.Copy(BitConverter.GetBytes(wValue),0, Buffer, nOffSet, SIZEOF(WORD))
			isHot := TRUE
				
        [MethodImpl(MethodImplOptions.AggressiveInlining)];        
		PRIVATE METHOD _GetLong(nOffSet AS INT) AS LONG
            RETURN BitConverter.ToInt32(Buffer, nOffSet)

        [MethodImpl(MethodImplOptions.AggressiveInlining)];        
		PRIVATE METHOD _SetLong(nOffSet AS INT, nValue AS LONG) AS VOID
            Array.Copy(BitConverter.GetBytes(nValue), 0, Buffer, nOffSet, sizeof(LONG))
            isHot := TRUE

 		INTERNAL PROPERTY Signature  AS NtxHeaderFlags	;
		    GET (NtxHeaderFlags) _GetWord(NTXOFFSET_SIG) ;
		    SET _SetWord(NTXOFFSET_SIG, value)
			
		INTERNAL PROPERTY IndexingVersion		AS WORD			;
		    GET _GetWord(NTXOFFSET_INDEXING_VER);
		    SET _SetWord(NTXOFFSET_INDEXING_VER, value)
			
		INTERNAL PROPERTY FirstPageOffset		AS LONG			;
		    GET _GetLong(NTXOFFSET_FPAGE_OFFSET);
		    SET _SetLong(NTXOFFSET_FPAGE_OFFSET, value)
			
		INTERNAL PROPERTY NextUnusedPageOffset		AS LONG			;
		    GET _GetLong(NTXOFFSET_NUPAGE_OFFSET)	;
		    SET _SetLong(NTXOFFSET_NUPAGE_OFFSET, value)
			
		// keysize + 2 longs. ie.e Left pointer + record no.
		INTERNAL PROPERTY EntrySize		AS WORD			;
		    GET _GetWord(NTXOFFSET_ENTRYSIZE);
		    SET _SetWord(NTXOFFSET_ENTRYSIZE, value)
			
		INTERNAL PROPERTY KeySize		AS WORD			;
		    GET _GetWord(NTXOFFSET_KEYSIZE);
		    SET _SetWord(NTXOFFSET_KEYSIZE, value)
			
		INTERNAL PROPERTY KeyDecimals	AS WORD			;
		    GET _GetWord(NTXOFFSET_KEYDECIMALS);
		    SET _SetWord(NTXOFFSET_KEYDECIMALS, value)
			
		INTERNAL PROPERTY MaxItem	AS WORD			;
		    GET _GetWord(NTXOFFSET_MAXITEM);
		    SET _SetWord(NTXOFFSET_MAXITEM, value)
			
		INTERNAL PROPERTY HalfPage	AS WORD			;
		    GET _GetWord(NTXOFFSET_HALFPAGE);
		    SET _SetWord(NTXOFFSET_HALFPAGE, value)
			
		INTERNAL PROPERTY KeyExpression	 AS STRING ;
		    GET _GetString(NTXOFFSET_KEYEXPRESSION, NTXOFFSET_EXPRESSION_SIZE ) ;
		    SET _SetString(NTXOFFSET_KEYEXPRESSION, NTXOFFSET_EXPRESSION_SIZE, value)
			
		INTERNAL PROPERTY Unique	AS LOGIC  ;
		    GET _GetWord( NTXOFFSET_UNIQUE) != 0 ;
		    SET _SetWord( NTXOFFSET_UNIQUE , (WORD) IIF(value,1,0)), isHot := TRUE

		INTERNAL PROPERTY Descending	AS LOGIC  ;
		    GET _GetWord( NTXOFFSET_DESCENDING) != 0 ;
		    SET _SetWord( NTXOFFSET_DESCENDING, (WORD) IIF(value,1,0)), isHot := TRUE
			
		INTERNAL PROPERTY ForExpression	 AS STRING ;
		    GET _GetString(NTXOFFSET_FOREXPRESSION, NTXOFFSET_EXPRESSION_SIZE ) ;
		    SET _SetString(NTXOFFSET_FOREXPRESSION, NTXOFFSET_EXPRESSION_SIZE, value)
			
		INTERNAL PROPERTY OrdName	 AS STRING ;
		    GET _GetString(NTXOFFSET_ORDNAME, NTXOFFSET_EXPRESSION_SIZE );
		    SET _SetString(NTXOFFSET_ORDNAME, NTXOFFSET_EXPRESSION_SIZE, Upper(value))
			
		PRIVATE CONST NTXOFFSET_SIG			    := 0   AS WORD
		PRIVATE CONST NTXOFFSET_INDEXING_VER    := 2   AS WORD
		PRIVATE CONST NTXOFFSET_FPAGE_OFFSET    := 4   AS WORD
		PRIVATE CONST NTXOFFSET_NUPAGE_OFFSET   := 8   AS WORD
		PRIVATE CONST NTXOFFSET_ENTRYSIZE       := 12  AS WORD
		PRIVATE CONST NTXOFFSET_KEYSIZE         := 14  AS WORD
		PRIVATE CONST NTXOFFSET_KEYDECIMALS     := 16  AS WORD
		PRIVATE CONST NTXOFFSET_MAXITEM         := 18  AS WORD
		PRIVATE CONST NTXOFFSET_HALFPAGE        := 20  AS WORD
		PRIVATE CONST NTXOFFSET_KEYEXPRESSION   := 22  AS WORD
		PRIVATE CONST NTXOFFSET_EXPRESSION_SIZE := 256 AS WORD
		PRIVATE CONST NTXOFFSET_UNIQUE          := 278 AS WORD
		PRIVATE CONST NTXOFFSET_DESCENDING      := 280 AS WORD
		PRIVATE CONST NTXOFFSET_FOREXPRESSION   := 282 AS WORD
		PRIVATE CONST NTXOFFSET_ORDNAME         := 538 AS WORD
		PRIVATE CONST NTXHEADER_SIZE            := 1024 AS WORD
        
	INTERNAL METHOD Dump(cText AS STRING) AS STRING
            VAR sb := System.Text.StringBuilder{}
            sb:AppendLine( String.Format("NTX Header {0}", cText))
            sb:AppendLine( "----------------------------------------------")
            sb:AppendLine( String.Format("Signature {0}, Version {1}, First page {2:X6}, Unused Page {3:X6}", SELF:Signature, SELF:IndexingVersion, SELF:FirstPageOffset, SELF:NextUnusedPageOffset))
            sb:AppendLine( String.Format("Item size {0}, Key Size {1}, Decimals {2}, Max Items {3}, HalfPage {4}", SELF:EntrySize, SELF:KeySize, SELF:KeyDecimals, SELF:MaxItem, SELF:HalfPage))
            sb:AppendLine( String.Format("Key Expression: {0}, Unique {1}, Descending {2}", SELF:KeyExpression, SELF:Unique, SELF:Descending))
            sb:AppendLine( String.Format("For Expression: {0}", SELF:ForExpression))
            sb:AppendLine( String.Format("Order name    : {0}", SELF:OrdName))
            sb:AppendLine( "----------------------------------------------")
            RETURN sb:ToString()

		
    END CLASS
    [Flags];        
    INTERNAL ENUM NtxHeaderFlags AS WORD
        MEMBER Default      := 0x0006
        MEMBER Conditional  := 0x0001
        MEMBER Partial      := 0x0008
        MEMBER NewLock      := 0x0010
        MEMBER HpLock       := 0x0020
        // from Harbour, not used (yet)
        MEMBER ChangeOnly   := 0x0040
        MEMBER Template     := 0x0080
        MEMBER SortRecno    := 0x0100
        MEMBER LargeFile    := 0x0200
        MEMBER MultiKey     := 0x0400
        MEMBER Compound     := 0x8000
        MEMBER Flag_Mask    := 0x87FF
     END ENUM
END NAMESPACE // global::XSharp.RDD.Types.DbfNtx

