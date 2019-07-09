//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//


/// <exclude />
PUBLIC CLASS MemoHelpers
    /// <exclude/>	
	CONST BLANK      := 0x20 AS INT
    /// <exclude/>	
	CONST END_MEMO   := 0x1A AS INT // ^Z
    /// <exclude/>	
	CONST MAX_WIDTH  := 254 AS INT
    /// <exclude/>	
	CONST TAB		 := 9 AS INT
    /// <exclude/>	
	CONST LINE_FEED  := 10 AS INT
    /// <exclude/>	
	CONST HARD_CR    := 13 AS INT
    /// <exclude/>	
	CONST SOFT_CR    := 141 AS INT
    /// <exclude/>	
	CONST HARD_CR_LF := (HARD_CR << 8) | LINE_FEED AS INT
    /// <exclude/>	
	CONST SOFT_CR_LF := (SOFT_CR << 8) | LINE_FEED AS INT
    /// <exclude/>	
	CONST STD_TAB_WIDTH	:= 4 AS INT	
    /// <exclude/>	
	CONST STD_MEMO_WIDTH	 := 79	AS INT

    /// <exclude/>	
	STATIC METHOD  MLCount( cMemo AS STRING, nLineLen:= MemoHelpers.STD_MEMO_WIDTH AS INT, ;
		nTabSize := MemoHelpers.STD_TAB_WIDTH AS INT,  lWrap := TRUE AS LOGIC) AS DWORD 
		LOCAL nTempLen AS INT
		LOCAL nLines := 0 AS DWORD
		LOCAL nIndex := 0 AS INT
		IF cMemo == NULL
			RETURN 0
		ENDIF
		IF nLineLen > 0 .AND. nLineLen <= MemoHelpers.MAX_WIDTH
	
			IF nTabSize > nLineLen
				nTabSize := nLineLen
			ENDIF
		
			nTempLen := 1
			DO WHILE nTempLen != 0
				nTempLen := MemoHelpers.LineLen( cMemo, nIndex, nLineLen, nTabSize, lWrap )
				IF nTempLen != 0
					nIndex += nTempLen
					nLines ++
				ENDIF
			ENDDO
		ENDIF
		RETURN nLines

    /// <exclude/>	
	STATIC METHOD GetTabPos( nPos AS INT, nTabSize AS INT ) AS INT
		RETURN ( nPos + nTabSize ) - ( nPos % nTabSize )
    /// <exclude/>	
	STATIC METHOD MPosToLc(cMemo AS STRING,nLineLen AS INT,nPos AS INT,nTabSize AS INT,lWrap AS LOGIC) AS Tuple<INT, INT>
		LOCAL nLineNum := 0 AS INT
		LOCAL nColumn := 0 AS INT
		LOCAL nTempLen := 0 AS INT
		LOCAL nChar := 0 AS INT
		LOCAL nCrLf := 0 AS INT
		LOCAL nIndex:= 0  AS INT
		LOCAL nSrc  := 0 AS INT
		
		
		IF nPos <= cMemo:Length .AND. nLineLen > 0 .AND. nLineLen <= MemoHelpers.MAX_WIDTH
		
			IF nTabSize > nLineLen
				nTabSize := nLineLen
			ENDIF
			
			nTempLen := 1
			nLineNum := 1
			
			DO WHILE nIndex < nPos .AND. nTempLen != 0
				nTempLen := LineLen( cMemo, nIndex, nLineLen, nTabSize, lWrap )
				nIndex += nTempLen
				IF nIndex <= nPos
					nSrc := nIndex
					nLineNum ++
				ENDIF
			ENDDO
			DO WHILE nSrc < nPos
				nChar := cMemo[(INT) nSrc]
				DO CASE
					CASE nChar == TAB
						nColumn := GetTabPos( nColumn, nTabSize )
					CASE IsCrLf( cMemo, nSrc, nCrLf )
						nColumn += 2
					OTHERWISE
						nColumn ++
				END CASE
				nSrc ++
			ENDDO
		ENDIF
		
		RETURN Tuple<INT,INT>{ nLineNum, nColumn }
		
		
    /// <exclude/>	
	STATIC METHOD  MLcToPos( cMemo AS STRING, nLineLen AS INT, nLineNum AS INT, nColumn AS INT, nTabSize AS INT, lWrap AS LOGIC) AS DWORD 
		LOCAL nTempLen	:= 0 AS INT
		LOCAL nChar		:= 0 AS INT
		LOCAL nCrLf		:= 0 AS INT
		LOCAL nIndex	:= 0 AS INT
		LOCAL nPos		:= 0 AS INT
		
		
		IF  nLineNum > 0 .AND. nLineLen > 4 .AND. nLineLen <= MAX_WIDTH
		
			IF nTabSize >= nLineLen
				nTabSize := nLineLen - 1
			ENDIF
			
			nTempLen := 1
			
			nLineNum --
			DO WHILE nLineNum != 0 .AND. nTempLen != 0
				nTempLen := LineLen( cMemo, nIndex, nLineLen, nTabSize, lWrap )
				nIndex += nTempLen
				nLineNum --
			ENDDO
			
			//  If a soft or hard CR falls just past the length in the
			//  previous line it won't be counted.  We must add as two chars
			//  to the buffer position in order for it to work out correctly.
			
			IF IsCrLf( cMemo, nIndex, nCrLf ) .AND. nCrLf == SOFT_CR_LF
				nIndex += 2
			ENDIF
			
			DO WHILE nPos < nColumn
			
				IF nIndex < cMemo:Length
					nChar := cMemo[(INT) nIndex]
				ELSE
					nChar := END_MEMO
				ENDIF
				DO CASE
					CASE nCrLf == SOFT_CR_LF .OR. nCrLf == HARD_CR_LF .OR. nChar == END_MEMO
						nPos := nColumn
					CASE nChar == TAB
						nPos := GetTabPos( nPos, nTabSize )
						IF nPos <= nColumn
							nIndex ++
						ENDIF
					OTHERWISE
						nIndex += 1
						nPos += 1
				ENDCASE
				
			ENDDO
			
		ENDIF
		
		RETURN (DWORD) ( nIndex + 1 )

    /// <exclude/>	
	STATIC METHOD IsCrLf( cMemo AS STRING, nPos AS INT, nCrLf REF INT ) AS LOGIC
		LOCAL nChar AS INT
		
		nCrLf := 0
		IF nPos + 1 < cMemo:Length .AND. (INT) cMemo[(INT) nPos + 1] == LINE_FEED
			nChar := (INT) cMemo[(INT) nPos]
			SWITCH nCHar
			CASE HARD_CR
				nCrLf := HARD_CR_LF
			CASE SOFT_CR
				nCrLf := SOFT_CR_LF
			END SWITCH
		ENDIF
		RETURN nCRLF != 0

		
	/// <exclude/>	
	STATIC METHOD LineLen( cMemo AS STRING, nStart AS INT, nLineLen AS INT, nTabSize AS INT , lWrap AS LOGIC ) AS INT
	   LOCAL lCont AS LOGIC
		   LOCAL nChar AS INT
		   LOCAL nPos AS INT
		   LOCAL nWhite := 0 AS INT
		   LOCAL nWidth := 0 AS INT
		   LOCAL nLength AS INT
		   LOCAL nCrLf := 0 AS INT
   
		   nLength	:= cMemo:Length
		   nPos		:= nStart
		   lCont	:= TRUE
   
		   DO WHILE lCont .AND. nPos < nLength .AND. nWidth <= nLineLen
			  nChar := (INT) cMemo[nPos]
			  DO CASE
			  CASE nChar == TAB
				 nWhite := nPos
				 nWidth := GetTabPos( nWidth, nTabSize )
			  CASE nChar == BLANK
				 nWhite := nPos
				 nWidth ++
			  CASE IsCrLf( cMemo, nPos, nCrLf )
				 IF nCrLf == HARD_CR_LF
					lCont := FALSE
				 ELSE
					IF !lWrap
					   lCont := FALSE
					ENDIF
				 ENDIF
				 nPos ++
			  OTHERWISE
				 nWidth ++
			  END CASE
			  nPos ++
		   END DO
   
		   IF nWidth > nLineLen
			  IF lWrap
				 IF nWhite > 0
					nPos := nWhite + 1
				 ELSE
					nPos --
				 ENDIF
			  ELSE
				 nPos --
			  END IF
		   ENDIF
   
		   RETURN nPos - nStart
	/// <exclude/>	
	STATIC METHOD MLine( cMemo AS STRING, nLineNum AS INT, nLineLen AS INT, nTabSize AS INT, lWrap AS LOGIC, lJustCheck AS LOGIC, dOffset REF INT ) AS STRING
		LOCAL oBuilder := NULL AS System.Text.StringBuilder
		LOCAL nTempLen AS INT
		LOCAL nSrc, nDes AS INT
		LOCAL nChar AS INT
		LOCAL nCrLf := 0 AS INT
		LOCAL cRet AS STRING
		LOCAL nIndex AS INT
		
		IF ! lJustCheck
			oBuilder := System.Text.StringBuilder{ (INT) nLineLen }
		END IF
		
		IF nLineNum > 0 .AND. nLineLen > 0 .AND. nLineLen <= MAX_WIDTH
		
			IF nTabSize > nLineLen
				nTabSize := nLineLen
			ENDIF
			nIndex :=  dOffset
			nLineNum --
			nTempLen := 1
			DO WHILE nLineNum != 0 .AND. nTempLen != 0
				nTempLen := LineLen( cMemo, nIndex, nLineLen, nTabSize, lWrap )
				nIndex += nTempLen
				dOffset += nTempLen
				nLineNum --
			ENDDO
			
			IF nLineNum == 0 .AND. nTempLen != 0
				nTempLen := LineLen( cMemo, nIndex, nLineLen, nTabSize, lWrap )
				nSrc := 0
				nDes := 0
				DO WHILE nSrc < nTempLen .AND. nDes < nLineLen
					nChar := cMemo[ (INT) nSrc + nIndex]
					DO CASE
						CASE IsCrLf( cMemo, nSrc + nIndex, REF nCrLf )
							nSrc += 2
						CASE nChar == TAB
							LOCAL nTabPos AS INT
							nTabPos := GetTabPos( nDes, nTabSize )
							IF ! lJustCheck
								oBuilder:Append( ' ', (INT) nTabPos - nDes )
							END IF
							nDes := nTabPos
							nSrc ++
						OTHERWISE
							IF ! lJustCheck
								oBuilder:Append( (CHAR) nChar )
							END IF
							nSrc ++
							nDes ++
					END CASE
				ENDDO
			ENDIF
		ENDIF
		
		IF lJustCheck
			cRet := NULL
		ELSE
			IF oBuilder:Length < nLineLen
				oBuilder:Append( ' ',  (INT) nLineLen - oBuilder:Length )
			ENDIF
			cRet := oBuilder:ToString()
		ENDIF
		
		RETURN cRet
		END		 CLASS
		
		
	/// <summary>
	/// Extract a line of text from a string, specifying an optional offset argument.
	/// </summary>
	/// <param name="cMemo"></param>
	/// <param name="nLine"></param>
	/// <returns>
/// </returns>
FUNCTION MLine(cMemo AS STRING,nLineNum AS DWORD) AS STRING
	LOCAL nOffset := 0 AS DWORD
	RETURN MLine3(cMemo, nLineNum, REF nOffSet)
	
	
/// <summary>
/// Extract a line of text from a string, specifying an optional offset argument.
/// </summary>
/// <param name="cMemo"></param>
/// <param name="nLine"></param>
/// <param name="nOffset"></param>
/// <returns>
/// </returns>
FUNCTION MLine(cMemo AS STRING,nLineNum AS DWORD,nOffset REF DWORD) AS STRING
	RETURN MLine3(cMemo, nLineNum, REF nOffSet)
/// <summary>
/// Extract a line of text from a string, specifying an optional offset argument.
/// </summary>    
FUNCTION MLine(cMemo AS STRING,nLineNum AS DWORD,nOffset AS DWORD) AS STRING
	RETURN MLine3(cMemo, nLineNum, REF nOffSet)
	
	
/// <summary>
/// Extract a line of text from a string, specifying a required offset argument.
/// </summary>
/// <param name="cMemo"></param>
/// <param name="nLineNum"></param>
/// <param name="nOffSet"></param>
/// <returns>
/// </returns>
FUNCTION MLine3(cMemo AS STRING,nLineNum AS DWORD,nOffSet REF DWORD) AS STRING
	LOCAL cResult AS STRING
	LOCAL iOffSet := (INT) nOffSet AS INT
	IF nOffSet < cMemo:Length
		cResult := Trim(MemoHelpers.MLine( cMemo , (INT) nLineNum , MemoHelpers.STD_MEMO_WIDTH, MemoHelpers.STD_TAB_WIDTH, TRUE, FALSE, REF iOffSet ))
	ELSE
		cResult := ""
	ENDIF
	nOffSet := (DWORD) iOffSet
	RETURN cResult
	
	
/// <summary>
/// Extract a line of text from a string.
/// </summary>
/// <param name="cMemo"></param>
/// <param name="wWidth"></param>
/// <param name="wLineNum"></param> 
/// <param name="wTabSize"></param>
/// <param name="lWrap"></param>
/// <returns>
/// </returns>
FUNCTION MemoLine(cMemo AS STRING, nLineLen := MemoHelpers.STD_MEMO_WIDTH AS DWORD, nLineNum := 1 AS DWORD,;
nTabSize := MemoHelpers.STD_TAB_WIDTH AS DWORD,lWrap := TRUE AS LOGIC) AS STRING
	LOCAL dPos := 0 AS INT
	RETURN MemoHelpers.MLine(cMemo, (INT) nLineNum, (INT) nLineLen, (INT) nTabSize, lWrap, FALSE, REF DPos)
	
/// <summary>
/// Return the contents of a text file as a string. The system assumes the source file has a 8 bit character format.
/// For the conversion the system follows the global Ansi setting. The characters are encoded
/// using either the current Ansi Windows codepage, or the current OEM Windows Codepage.
/// </summary>
/// <param name="cFile">The name of the text file to read from disk, including an optional drive, directory, and extension.  SetDefault() and SetPath() settings are ignored; the Windows default is used unless you specify a drive and directory as part of the file name.  No extension is assumed</param>
/// <returns>The string as Unicode String
/// </returns>
/// <remarks>This function should NOT be used to read the contents of a binary file (such as a word document).
/// Use MemoReadBinary() in stead .</remarks>
/// <seealso cref='M:XSharp.Core.Functions.MemoReadBinary(System.String)' >MemoReadBinary</seealso>
/// <seealso cref='M:XSharp.Core.Functions.MemoWrit(System.String,System.String)' >MemoWrit</seealso>
FUNCTION MemoRead(cFile AS STRING) AS STRING
	LOCAL cResult AS STRING
	TRY
        XSharp.IO.File.clearErrorState()
		IF File(cFile)
			cFile := FPathName()
            IF RuntimeState.Ansi
			    cResult := System.IO.File.ReadAllText(cFile, RuntimeState.WinEncoding)
            ELSE
                cResult := System.IO.File.ReadAllText(cFile, RuntimeState.DosEncoding)
            ENDIF
		ELSE
			cResult := ""
		ENDIF
	CATCH e AS Exception
		XSharp.IO.File.setErrorState(e)
		cResult := ""
	END TRY
	RETURN cResult
	

/// <summary>
/// Return the contents of a binary file as an array of bytes.
/// Use this function in stead of MemoRead() to read the contents of a binary file.
/// </summary>
/// <param name="cFile">The name of the binary file to read from disk, including an optional drive, directory, and extension.  SetDefault() and SetPath() settings are ignored; the Windows default is used unless you specify a drive and directory as part of the file name.  No extension is assumed</param>
/// <returns>The file as an array of bytes</returns>
/// <seealso cref='M:XSharp.Core.Functions.MemoRead(System.String)' >MemoRead</seealso>
/// <seealso cref='M:XSharp.Core.Functions.MemoWritBinary(System.String,System.Byte[])' >MemoWritBinary</seealso>

FUNCTION MemoReadBinary(cFile AS STRING) AS BYTE[]
	LOCAL bResult AS BYTE[]
	TRY
        XSharp.IO.File.clearErrorState()
		IF File(cFile)
			cFile := FPathName()
            bResult := System.IO.File.ReadAllBytes(cFile)
		ELSE
			bResult := BYTE[]{0}
		ENDIF
	CATCH e AS Exception
		XSharp.IO.File.setErrorState(e)
		bResult := BYTE[]{0}
	END TRY
	RETURN bResult
	
	
/// <summary>
/// Write a string to a disk file. The text is written in 8 bit character format.
/// For the conversion the system follows the global Ansi setting. The characters are encoded
/// using either the current Ansi Windows codepage, or the current OEM Windows Codepage.
/// </summary>
/// <param name="cFile"></param>
/// <param name="c"></param>
/// <returns>
/// </returns>
/// <seealso cref='M:XSharp.Core.Functions.MemoRead(System.String)' >MemoRead</seealso>
/// <seealso cref='M:XSharp.Core.Functions.MemoWritBinary(System.String,System.Byte[])' >MemoWritBinary</seealso>
FUNCTION MemoWrit(cFile AS STRING,c AS STRING) AS LOGIC
	LOCAL lOk AS LOGIC
	TRY
        XSharp.IO.File.clearErrorState()
        IF RuntimeState.Ansi
			System.IO.File.WriteAllText(cFile, c, RuntimeState.WinEncoding)
        ELSE
            System.IO.File.WriteAllText(cFile, c, RuntimeState.DosEncoding)
        ENDIF
		
		lOk := TRUE
	CATCH e AS Exception
		XSharp.IO.File.setErrorState(e)
		lOk := FALSE
	END TRY
	RETURN lOk
	
/// <inheritdoc cref="M:XSharp.Core.Functions.MemoWritBinary(System.String,System.Byte[])" />

FUNCTION MemoWrit(cFile AS STRING,bData AS BYTE[]) AS LOGIC
    RETURN MemoWritBinary(cFile, bData)

/// <summary>
/// Write binary data  o a disk file. Use this function for binary files instead of MemoWrit(). This day may be read with MemoReadBinary().
/// </summary>
/// <param name="cFile">The name of the target disk file, including an optional drive, directory, and extension.
/// SetDefault() and SetPath() settings are ignored; the Windows default is used unless you specify a drive and
/// directory as part of the file name.  No extension is assumed.
/// If the file does not exist, it is created.  If it exists, this function attempts to open the file in exclusive
/// mode and, if successful, the file is overwritten without warning or error.  If access is denied because,
/// for example, another process is using the file, MemoWrit() returns FALSE and NetErr() is set to TRUE.</param>
/// <param name="bData">The contents to write</param>
/// <returns>TRUE if the writing operation is successful; otherwise, FALSE</returns>
/// <seealso cref='M:XSharp.Core.Functions.MemoReadBinary(System.String)' >MemoReadBinary</seealso>
/// <seealso cref='M:XSharp.Core.Functions.MemoWrit(System.String,System.String)' >MemoWrit</seealso>

FUNCTION MemoWritBinary(cFile AS STRING,bData AS BYTE[]) AS LOGIC
	LOCAL lOk AS LOGIC
	TRY
        XSharp.IO.File.clearErrorState()
		System.IO.File.WriteAllBytes(cFile, bData)
		lOk := TRUE
	CATCH e AS Exception
		XSharp.IO.File.setErrorState(e)
		lOk := FALSE
	END TRY
	RETURN lOk
	
	
/// <summary>
/// Determine the position of a line in a string.
/// </summary>
/// <param name="cMemo"></param>
/// <param name="nLineNum"></param>
/// <returns>
/// </returns>
FUNCTION MLPos2(cMemo AS STRING,nLineNum AS DWORD) AS DWORD
	LOCAL nIndex := 0 AS INT
	MemoHelpers.MLine( cMemo, (INT)  nLineNum, MemoHelpers.STD_MEMO_WIDTH, MemoHelpers.STD_TAB_WIDTH, TRUE, TRUE, REF nIndex )
	RETURN (DWORD) nIndex
	
	
	
	
	
/// <summary>
/// Count the number of lines in a string.
/// </summary>
/// <param name="cMemo"></param>
/// <returns>
/// </returns>
	
FUNCTION MLCount1( cMemo AS STRING) AS DWORD 
	RETURN MemoHelpers.MLCount(cMemo, MemoHelpers.STD_MEMO_WIDTH, MemoHelpers.STD_TAB_WIDTH , TRUE)
	
	
	
/// <summary>
/// Count the number of lines in a string or memo field.
/// </summary>
/// <param name="cMemo"></param>
/// <returns>
/// </returns>
FUNCTION MemLines(cMemo AS STRING) AS DWORD
	RETURN MemoHelpers.MLCount(cMemo, MemoHelpers.STD_MEMO_WIDTH, MemoHelpers.STD_TAB_WIDTH , TRUE)
	
/// <exclude />
FUNCTION _MPosToLc(cMemo AS STRING,nLineLen AS DWORD,nPos AS DWORD,nTabSize := MemoHelpers.STD_TAB_WIDTH AS DWORD,lWrap := TRUE AS LOGIC) AS Tuple<INT, INT>
	RETURN MemoHelpers.MPosToLc(cMemo, (INT) nLineLen, (INT) nPos, (INT) nTabSize, lWrap)

/// <summary>Return the position of a character in a formatted string.</summary>
FUNCTION MLcToPos( cMemo AS STRING, nLineLen AS DWORD, nLineNum AS DWORD, nColumn AS DWORD, nTabSize AS DWORD, lWrap AS LOGIC) AS DWORD CLIPPER
	RETURN MemoHelpers.MLcToPos(cMemo, (INT) nLineLen, (INT) nLineNum, (INT) nColumn, (INT) nTabSize, lWrap)
