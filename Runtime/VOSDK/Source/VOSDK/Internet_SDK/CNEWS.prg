/// <include file="Internet.xml" path="doc/CNews/*" />
CLASS CNews INHERIT CMessage
	PROTECT cExpires        AS STRING
	PROTECT cNewsGroups     AS STRING
	PROTECT cPath           AS STRING
	PROTECT cOrganization   AS STRING
	PROTECT cSender         AS STRING
	PROTECT cFollowUpTo		AS STRING
	PROTECT nSize			AS DWORD




 /// <exclude />
METHOD __GetFileName(cTemp) 
	LOCAL dwPos  AS DWORD
	LOCAL dwStop AS DWORD
	LOCAL cRet	  AS STRING


	dwPos := SLen(UUE_START_EMAIL)
	IF (dwStop := At3(CRLF, cTemp, dwPos)) > 0
		cRet := AllTrim(SubStr3(cTemp, dwPos, dwStop - dwPos))
	ENDIF


	RETURN cRet




/// <include file="Internet.xml" path="doc/CNews.FollowUpTo/*" />
ACCESS FollowUpTo() 
	RETURN SELF:cFollowUpTo


/// <include file="Internet.xml" path="doc/CNews.GetAttachInfo/*" />
METHOD GetAttachInfo(c) 


	LOCAL nPos      AS DWORD
	LOCAL nTemp     AS DWORD
	LOCAL cTemp     AS STRING
	LOCAL cFile     AS STRING
	LOCAL cRest     AS STRING
	LOCAL cBefore   AS STRING


	DEFAULT(@c, SELF:cAttach)


	IF SELF:cBoundary == DEFAULT_BOUNDARY
		cRest := c


		IF SLen(cRest) == 0
			cRest := SELF:cBody
		ENDIF


		nPos  := __CheckUUEncode(cRest)


		IF nPos > 0
			cBefore := SubStr3(cRest, 1, nPos - 1)


			DO WHILE nPos > 0
				cRest := SubStr2(cRest, nPos)
				nTemp := At3(UUE_START_NEWS, cRest, SLen(UUE_START_NEWS))
				nPos  := At3(UUE_END, cRest, SLen(UUE_START_NEWS))


				IF nPos > 0
					IF (nTemp > 0) .AND. (nPos > nTemp)
						nPos := nTemp
						cTemp := SubStr3(cRest, 1, nPos-1)
						cRest := SubStr2(cRest, nPos)
					ELSE
						cTemp := SubStr3(cRest, 1, nPos-1)
						nPos += SLen(ATTACHMENT_END)
						cRest := SubStr2(cRest, nPos)
					ENDIF


					cFile := SELF:__GetFileName(cTemp)
					AAdd(SELF:aAttachList, cTemp)
					AAdd(SELF:aFileList, cFile)
					AAdd(SELF:aTransferEncoding, CODING_TYPE_UUENCODE)


					nPos := __CheckUUEncode(cRest)
				ENDIF
			ENDDO
			IF ALen(SELF:aAttachList) > 0
				SELF:cBody := cBefore + SELF:FakeAttachmentList() + cRest
			ENDIF
		ENDIF
	ELSE
		SUPER:GetAttachInfo(c, .T. )
	ENDIF


	RETURN NIL


/// <include file="Internet.xml" path="doc/CNews.GetHeaderInfo/*" />
METHOD  GetHeaderInfo ()                              	
	LOCAL cTemp     AS STRING
	LOCAL cHeader   AS STRING


	cHeader := SELF:cHeader


	SUPER:GetHeaderInfo()


	cTemp := __GetMailInfo(cHeader, TEMP_POSTED, .F. )
	IF SLen(cTemp) > 0
		SELF:__GetMailTime(cTemp)
	ENDIF




	cTemp := __GetMailInfo(cHeader, TEMP_PATH, .F. )
	SELF:cPath := cTemp


	cTemp := __GetMailInfo(cHeader, TEMP_NEWSGROUPS, .F. )
	SELF:cNewsGroups := cTemp


	cTemp := __GetMailInfo(cHeader, TEMP_ORGANIZATION, .F. )
	SELF:cOrganization := cTemp


	cTemp := __GetMailInfo(cHeader, TEMP_SENDER, .F. )


	IF SLen(cTemp) > 0
		SELF:cSender := cTemp
	ELSE
		SELF:cSender := SELF:cFromName
	ENDIF


	cTemp := __GetMailInfo(cHeader, TEMP_FOLLOWUP, .F. )
	SELF:cFollowUpTo := cTemp


	RETURN TRUE


/// <include file="Internet.xml" path="doc/CNews.ctor/*" />
CONSTRUCTOR(xData) 
	LOCAL cRaw	AS STRING
	LOCAL dwPos	AS DWORD


	SUPER(xData)


	IF IsString(xData)
		cRaw  := xData
		dwPos := At2(CRLF, cRaw)
		IF dwPos > 0 .AND. dwPos < 80
			cRaw := SubStr2(cRaw, dwPos + 2)
		ENDIF
		SELF:nSize := SLen(cRaw)
		SELF:Decode(cRaw)
	ENDIF


	RETURN 


/// <include file="Internet.xml" path="doc/CNews.NewsGroups/*" />
ACCESS NewsGroups 
	RETURN SELF:cNewsGroups


/// <include file="Internet.xml" path="doc/CNews.NewsGroups/*" />
ASSIGN NewsGroups(cNew) 
	IF IsString(cNew)
		SELF:cNewsGroups := cNew
	ENDIF
	RETURN 


/// <include file="Internet.xml" path="doc/CNews.Organization/*" />
ACCESS Organization 
	RETURN SELF:cOrganization


/// <include file="Internet.xml" path="doc/CNews.Path/*" />
ACCESS Path 
	RETURN SELF:cPath


/// <include file="Internet.xml" path="doc/CNews.Path/*" />
ASSIGN Path(cNew) 
	IF IsString(cNew)
		SELF:cPath := cNew
	ENDIF
	RETURN 


/// <include file="Internet.xml" path="doc/CNews.Sender/*" />
ACCESS Sender 
	RETURN SELF:cSender


/// <include file="Internet.xml" path="doc/CNews.Size/*" />
ACCESS Size 
	RETURN SELF:nSize


END CLASS


