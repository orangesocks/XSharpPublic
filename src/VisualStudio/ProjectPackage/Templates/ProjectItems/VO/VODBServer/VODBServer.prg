﻿#ifndef __XSHARP_RT__
#include "VOSystemClasses.vh"
#include "VOSystemLibrary.vh"
#endif

CLASS $safeitemrootname$ INHERIT DBSERVER
	INSTANCE cDBFPath	  := "" AS STRING
	INSTANCE cName		  := "$safeitemrootname$" AS STRING
	INSTANCE xDriver	  := "DBFNTX"		 AS USUAL
	INSTANCE lReadOnlyMode:= FALSE		 AS LOGIC
	INSTANCE lSharedMode  := NIL	 AS USUAL
	INSTANCE nOrder 	  := 0	 AS INT


CONSTRUCTOR(cDBF, lShare, lRO, xRdd)
	LOCAL oFS		  AS FILESPEC
	LOCAL i 		  AS DWORD
	LOCAL nFields	  AS DWORD
	LOCAL aFieldDesc  AS ARRAY
	LOCAL aIndex	  AS ARRAY
	LOCAL nIndexCount AS DWORD
	LOCAL oFSIndex	  AS FILESPEC
	LOCAL nPos		  AS DWORD
	LOCAL lTemp 	  AS LOGIC
	LOCAL oFSTemp	  AS FILESPEC


	IF IsLogic(lShare)
		SELF:lSharedMode := lShare
	ELSE
		IF !IsLogic(SELF:lSharedMode)
			SELF:lSharedMode := !SetExclusive()
		ENDIF
	ENDIF

	IF IsLogic(lRO)
		SELF:lReadOnlyMode := lRO
	ENDIF

	IF IsString(xRdd) .OR. IsArray(xRdd)
		SELF:xDriver := xRdd
	ENDIF

	SELF:PreInit()

	IF IsString(cDBF)
		//	UH 01/18/2000
		oFSTemp := FileSpec{SELF:cDBFPath + SELF:cName}
		oFS 	:= FileSpec{cDBF}

		IF SLen(oFS:Drive) = 0
			oFS:Drive := CurDrive()
		ENDIF
		IF SLen(oFS:Path) = 0
			oFS:Path  := "\" + CurDir()
		ENDIF

		IF SLen(oFS:FileName) = 0
			oFS:Filename := SELF:cName
		ENDIF

		IF oFS:FullPath == oFSTemp:Fullpath
			lTemp := .T.
		ELSE
		   IF Left(cDBF, 2) =="\\"  // Unc path, for example \\Server\Share\FileName.DBF
				SELF:cDBFPath := oFS:Path
		   ELSE
				SELF:cDBFPath := oFS:Drive + oFS:Path
		   ENDIF
				SELF:cName := oFS:FileName + oFS:Extension
				oFS := FileSpec{SELF:cDBFPath + SELF:cName}
		ENDIF
	ELSE
		oFS 	 := FileSpec{SELF:cName}
		oFS:Path := SELF:cDBFPath
	ENDIF


	SUPER(oFS, SELF:lSharedMode, SELF:lReadOnlyMode , SELF:xDriver )

	oHyperLabel := HyperLabel{#$safeitemrootname$, "$safeitemrootname$", "$safeitemrootname$", "$safeitemrootname$"}

	IF oHLStatus = NIL
		nFields := ALen(aFieldDesc := SELF:FieldDesc)
		FOR i:=1 UPTO nFields
			nPos := SELF:FieldPos( aFieldDesc[i][DBC_NAME] )

			SELF:SetDataField( nPos,;
				DataField{aFieldDesc[i][DBC_SYMBOL],aFieldDesc[i][DBC_FIELDSPEC]} )

			IF String2Symbol(aFieldDesc[i][DBC_NAME]) != aFieldDesc[i][DBC_SYMBOL]
				SELF:FieldInfo(DBS_ALIAS, nPos, Symbol2String(aFieldDesc[i][DBC_SYMBOL]) )
			ENDIF
		NEXT

		nIndexCount := ALen(aIndex:=SELF:IndexList)

		FOR i:=1 UPTO nIndexCount
			oFSIndex := FileSpec{ aIndex[i][DBC_INDEXNAME] }
			oFSIndex:Path := SELF:cDBFPath

			IF lTemp .AND. !Empty( aIndex[i][DBC_INDEXPATH] )
				oFSIndex:Path := aIndex[i][DBC_INDEXPATH]
			ENDIF

			IF oFSIndex:Find()
				lTemp := SELF:SetIndex( oFSIndex )
			ENDIF
		NEXT

		//	UH 01/18/2000
		//	SELF:nOrder > 0
		IF lTemp .AND. SELF:nOrder > 0
			SELF:SetOrder(SELF:nOrder)
		ENDIF

		SELF:GoTop()
	ENDIF

	SELF:PostInit()

	RETURN


OVERRIDE ACCESS FieldDesc
	//
	//	Describes all fields selected by DBServer-Editor
	//
	LOCAL aRet		AS ARRAY
	LOCAL nFields	AS DWORD

	nFields := 0

	IF nFields > 0
		aRet := ArrayCreate(nFields)

		//
		//	The following code creates an array of field
		//	descriptors with these items for each
		//	selected field:
		//
		//	{ <symFieldName>, <cFieldName>, <oFieldSpec> }
		//
		//	Use following predefined constants to access
		//	each subarray:
		//
		//	DBC_SYMBOL
		//	DBC_NAME
		//	DBC_FIELDSPEC
		//

	ELSE
		aRet := {}
	ENDIF


	RETURN aRet


OVERRIDE ACCESS IndexList
	//
	//	Describes all index files created or selected
	//	by DBServer-Editor
	//
	LOCAL aRet			AS ARRAY
	LOCAL nIndexCount	AS DWORD

	nIndexCount := 0

	IF nIndexCount > 0
		aRet := ArrayCreate(nIndexCount)

		//
		//	The following code creates an array of index
		//	file descriptors with these items for each
		//	selected index file:
		//
		//	{ <cFileName>, <cPathName>, <aOrders> }
		//
		//	Use following predefined constants to access
		//	each subarray:
		//
		//	DBC_INDEXNAME
		//	DBC_INDEXPATH
		//	DBC_ORDERS
		//
		//	Array <aOrders> contains an array of
		//	order descriptors with these items for each
		//	order:
		//
		//	{ <cOrder>, <lDuplicates>, <lAscending>, <cKey>, <cFor> }
		//
		//	Use following predefined constants to access
		//	aOrder subarrays:
		//
		//	DBC_TAGNAME
		//	DBC_DUPLICATE
		//	DBC_ASCENDING
		//	DBC_KEYEXP
		//	DBC_FOREXP
		//


	ELSE
		aRet := {}
	ENDIF

	RETURN aRet


END CLASS
