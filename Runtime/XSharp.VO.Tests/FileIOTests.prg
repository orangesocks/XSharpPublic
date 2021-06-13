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


// Array tests are not working correctly yet with the current build
BEGIN NAMESPACE XSharp.VO.Tests

	CLASS FileIOTests

 		[Trait("Category", "File")];
		[Fact];
		METHOD FileTest() AS VOID
			LOCAL hFile AS PTR
			LOCAL cLine AS USUAL
			LOCAL cFile AS STRING
			LOCAL cText	AS STRING
			cFile := "test.txt"
			hFile := FCreate(cFile)
			cLine := "line1"
			FWriteLine(hFile, cLine)
			cLine := "line2"
			FWriteLine(hFile, cLine)
			FClose(hFile)
			cText := MemoRead(cFile)
			Assert.Equal(e"line1\r\nline2\r\n", cText)
            VAR aFiles := Directory("test.txt")
            Assert.Equal(1, (INT) Alen(aFiles))
            aFiles := Directory(System.Environment.CurrentDirectory+"\*.txt")
            Assert.True( Alen(aFiles) >= 1)
            // test readonly
            hFile := FOpen("test.txt", FO_READ )
            Assert.True(hFile != F_ERROR)
            Assert.Equal(TRUE, FClose(hFile))


			FErase(cFile)
            aFiles := Directory("test.txt")
            Assert.Equal(0, (INT) Alen(aFiles))
            aFiles := Directory("C:\XSharp\*.*","D")
		RETURN

	END CLASS
END NAMESPACE // XSharp.Runtime.Tests
