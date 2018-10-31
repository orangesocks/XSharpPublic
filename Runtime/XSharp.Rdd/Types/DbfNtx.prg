﻿//
// Copyright (c) B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
USING XSharp.RDD.Support



BEGIN NAMESPACE XSharp.RDD
	/// <summary>DBFNTX RDD. For DBF/DBT/NTX.</summary>
	CLASS DBFNTX INHERIT DBFDBT
	
		INTERNAL _ntxList AS NtxOrderList
		
		CONSTRUCTOR()
			SUPER()
			SELF:_ntxList := NtxOrderList{SELF}
			SELF:_oIndex := NtxOrder{SELF}
			RETURN
			
		PROPERTY SysName AS STRING GET TYPEOF(DbfNtx):ToString()	
		
		
		
		#REGION Order Support 
		VIRTUAL METHOD OrderCreate(orderInfo AS DBORDERCREATEINFO ) AS LOGIC
			RETURN SELF:_ntxList:Create(orderInfo)
			
		VIRTUAL METHOD OrderDestroy(orderInfo AS DBORDERINFO ) AS LOGIC
			RETURN SUPER:OrderDestroy(orderInfo)
			
			
		VIRTUAL METHOD OrderListAdd( orderInfo AS DbOrderInfo, fullPath AS STRING) AS LOGIC
			//
			BEGIN LOCK SELF
				//
				SELF:GoCold()
				RETURN SELF:_ntxList:Add(orderInfo, fullPath)
			END LOCK
			
		VIRTUAL METHOD OrderListDelete(orderInfo AS DbOrderInfo) AS LOGIC
			//
			BEGIN LOCK SELF
				//
				SELF:GoCold()
				RETURN SELF:_ntxList:CloseAll()
			END LOCK            
			
		VIRTUAL METHOD OrderListFocus(orderInfo AS DbOrderInfo) AS LOGIC
			//
			BEGIN LOCK SELF
				//
				SELF:GoCold()
				RETURN SELF:_ntxList:SetFocus(orderInfo)
			END LOCK
			
		VIRTUAL METHOD OrderListRebuild() AS LOGIC
			//
			BEGIN LOCK SELF
				//
				SELF:GoCold()
				RETURN SELF:_ntxList:Rebuild()
			END LOCK
			
			#endregion
			
		#region Pack, Zap
		METHOD Pack() AS LOGIC
			LOCAL isOk AS LOGIC
			//
			isOk := SUPER:Pack()
			IF (isOk)
				//
				isOk := SELF:OrderListRebuild()
			ENDIF
			RETURN isOk
			
			
		PUBLIC METHOD Zap() AS LOGIC
			LOCAL isOk AS LOGIC
			//
			isOk := SUPER:Zap()
			IF (isOk)
				isOk := SELF:OrderListRebuild()
			ENDIF
			RETURN isOk
			
			#endregion
			
		#REGION Open, Close, Create
		
		PUBLIC OVERRIDE METHOD Close() AS LOGIC
			LOCAL orderInfo AS DbOrderInfo
			//
			orderInfo := DbOrderInfo{}
			orderInfo:AllTags := TRUE
			SELF:OrderListDelete(orderInfo)
			RETURN SUPER:Close()
			
			
		PUBLIC OVERRIDE METHOD Create( openInfo AS DBOPENINFO ) AS LOGIC
			LOCAL isOk AS LOGIC
			//
			isOk := SUPER:Create(openInfo)
			IF ( XSharp.RuntimeState.Ansi .AND. isOk)
				VAR sig := SELF:_Header:Version
				// Set bit to Force Ansi Signature
				sig := sig |4
				// Should we also set the CodePage ??
				//SELF:_Header:DbfCodePage := DbfCodePage.CP_DBF_WIN_ANSI
				SELF:_Header:Version := sig
			ENDIF
			RETURN isOk
			
		#ENDREGION
		
		#REGION Move
		
		PUBLIC METHOD Seek(seekInfo AS DBSEEKINFO ) AS LOGIC
			LOCAL isOk AS LOGIC
			LOCAL ntxIndex AS NtxOrder
			//
			isOk := FALSE
			BEGIN LOCK SELF
				ntxIndex := SELF:_ntxList:CurrentOrder
				IF (ntxIndex != NULL)
					isOk := ntxIndex:Seek(seekInfo)
				ENDIF
				IF ( !isOk )
					SELF:_DbfError(SubCodes.ERDD_DATATYPE, GenCode.EG_NOORDER )
				ENDIF
			END LOCK
			RETURN isOk
			
		PUBLIC METHOD GoBottom() AS LOGIC
			BEGIN LOCK SELF
				IF SELF:_ntxList:CurrentOrder != NULL
					RETURN SELF:_ntxList:CurrentOrder:GoBottom()
				ELSE
					RETURN SUPER:GoBottom()
				ENDIF
			END LOCK
			
		PUBLIC METHOD GoTo(record AS INT ) AS LOGIC
			RETURN SUPER:GoTo(record)
			
			
		PUBLIC METHOD GoTop() AS LOGIC
			BEGIN LOCK SELF
				IF SELF:_ntxList:CurrentOrder != NULL
					RETURN SELF:_ntxList:CurrentOrder:GoTop()
				ELSE
					RETURN SUPER:GoTop()
				ENDIF
			END LOCK
			
		PUBLIC METHOD SkipRaw( move AS LONG ) AS LOGIC
			BEGIN LOCK SELF
				IF SELF:_ntxList:CurrentOrder != NULL
					RETURN SELF:_ntxList:CurrentOrder:SkipRaw(move)
				ELSE
					RETURN SUPER:SkipRaw(move)
				ENDIF
			END LOCK
			
		#ENDREGION
			
		#REGION GoCold, GoHot, Flush
		PUBLIC OVERRIDE METHOD GoCold() AS LOGIC
			LOCAL isOk AS LOGIC
			//
			isOk := TRUE
			BEGIN LOCK SELF
				IF ( !SELF:IsHot )
					RETURN isOk
				ENDIF
				isOk := SELF:_ntxList:GoCold()
				IF (!isOk)
					RETURN isOk
				ENDIF
				RETURN SUPER:GoCold()
			END LOCK

		PUBLIC OVERRIDE METHOD GoHot() AS LOGIC
			LOCAL isOk AS LOGIC
			//
			isOk := TRUE
			BEGIN LOCK SELF
				isOk := SUPER:GoHot()
				IF (!isOk)
					RETURN isOk
				ENDIF
				RETURN SELF:_ntxList:GoHot()
			END LOCK

		PUBLIC OVERRIDE METHOD Flush() AS LOGIC
			LOCAL isOk AS LOGIC
			//
			isOk := TRUE
			BEGIN LOCK SELF
				isOk := SUPER:Flush()
				RETURN SELF:_ntxList:Flush()
			END LOCK

		#ENDREGION
			
			
			
			
			
			
	END CLASS
	
END NAMESPACE
