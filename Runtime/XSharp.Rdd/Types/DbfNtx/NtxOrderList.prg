﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//


USING System
USING System.Collections.Generic
USING System.Text
USING XSharp.RDD.Support

BEGIN NAMESPACE XSharp.RDD.NTX

    INTERNAL SEALED CLASS NtxOrderList
        PRIVATE _focusNtx AS LONG
        PRIVATE _Orders AS List<NtxOrder>
        PRIVATE _oRdd AS DBFNTX
        PRIVATE _currentOrder AS NtxOrder
        INTERNAL PROPERTY Count AS LONG GET _Orders:Count
        INTERNAL PROPERTY Focus AS LONG GET _focusNtx
            INTERNAL PROPERTY CurrentOrder AS NtxOrder GET _currentOrder
                INTERNAL PROPERTY SELF[index AS LONG ] AS NtxOrder
                    GET
                        IF ((index >= 0) .AND. (index < _Orders:Count))
                            RETURN _Orders[index]
                        ENDIF
                        RETURN NULL
                        
                    END GET
                END PROPERTY
                
                INTERNAL CONSTRUCTOR(area AS DBFNTX )
                    SELF:_focusNtx := 0
                    SELF:_Orders := List<NtxOrder>{}
                    SELF:_oRdd := area
                    SELF:_currentOrder := NULL
                    
                    
                INTERNAL METHOD Add(oi AS DbOrderInfo , filePath AS STRING ) AS LOGIC
                    LOCAL flag AS LOGIC
                    LOCAL ntxIndex AS NtxOrder
                    //
                    flag := FALSE
                    TRY
                        IF ((LONG)SELF:_Orders:Count >= 16L)
                            SELF:_oRdd:_dbfError(SubCodes.ERDD_NTXLIMIT, GenCode.EG_LIMIT,  filePath)
                            flag := FALSE
                        ELSE
                            ntxIndex := NtxOrder{SELF:_oRdd, filePath}
                            SELF:_Orders:Add(ntxIndex)
                            flag := ntxIndex:Open(oi)
                            IF (flag)
                                SELF:_focusNtx := SELF:_Orders:Count
                                SELF:_currentOrder := ntxIndex
                                oi:BagName := ntxIndex:FileName
                            ENDIF
                        ENDIF
                        
                    CATCH //Exception
                        flag := FALSE
                    END TRY
                    IF (!flag)
                        SELF:_focusNtx := 0
                        SELF:_currentOrder := NULL
                    ENDIF
                    RETURN flag
                    
                    
                INTERNAL METHOD Create(dboci AS DBORDERCREATEINFO ) AS LOGIC
                    LOCAL ntxIndex AS NtxOrder
                    LOCAL isOk AS LOGIC
                    //
                    TRY
                        ntxIndex := NtxOrder{SELF:_oRdd}
                        isOk := ntxIndex:Create(dboci)
                        IF (!isOk)
                            RETURN isOk
                        ENDIF
                        SELF:_Orders:Add(ntxIndex)
                        SELF:_focusNtx := SELF:_Orders:Count
                        SELF:_currentOrder := ntxIndex
                        ntxIndex:GoTop()
                        RETURN isOk
                        
                    CATCH e AS Exception
                        System.Diagnostics.Debug.WriteLine(e:Message)
                        RETURN FALSE
                    END TRY
                    
                INTERNAL METHOD Delete( orderInfo AS DbOrderInfo) AS LOGIC
                    LOCAL ntxIndex AS NtxOrder
                    LOCAL found AS LOGIC
                    LOCAL pos AS INT
                    //
                    IF (SELF:_Orders:Count == 0)
                        RETURN TRUE
                    ENDIF
                    //
                    IF ( orderInfo:AllTags )
                        RETURN SELF:CloseAll()
                    ENDIF
                    //
                    found := FALSE
                    pos := SELF:_Orders:Count
                    WHILE pos > 0
                        ntxIndex := SELF:_Orders[pos - 1]
                        IF ( ntxIndex:OrderName == orderInfo:BagName )
                            ntxIndex:Flush()
                            ntxIndex:Close()
                            //
                            SELF:_Orders:RemoveAt(pos - 1)
                            found := TRUE
                            EXIT
                        ENDIF
                    ENDDO
                    IF ( found ) 
                        IF ( SELF:_Orders:Count > 0 ) .AND. ( ( pos >= SELF:_focusNtx ) .AND. (pos < SELF:_Orders:Count ) )
                            SELF:_focusNtx :=- 1
                            SELF:_currentOrder := SELF:_Orders[pos - 1]
                        ELSE
                            SELF:_focusNtx := 0
                            SELF:_currentOrder := NULL
                        ENDIF
                    ENDIF
                    RETURN TRUE
                    
                INTERNAL METHOD CloseAll() AS LOGIC
                    LOCAL ntxIndex AS NtxOrder
                    //
                    IF (SELF:_Orders:Count == 0)
                        RETURN TRUE
                    ENDIF
                    //
                    WHILE SELF:_Orders:Count > 0
                        ntxIndex := SELF:_Orders[SELF:_Orders:Count - 1]
                        ntxIndex:Flush()
                        ntxIndex:Close()
                        //
                        SELF:_Orders:RemoveAt(SELF:_Orders:Count - 1)
                    ENDDO
                    SELF:_focusNtx := 0
                    SELF:_currentOrder := NULL
                    RETURN TRUE
                    
                    
                INTERNAL METHOD SetFocus(oi AS DbOrderInfo ) AS LOGIC
                    LOCAL currentOrder AS NtxOrder
                    LOCAL isOk AS LOGIC
                    //
                    currentOrder := SELF:_currentOrder
                    IF (currentOrder != NULL)
                        oi:BagName := currentOrder:FileName
                    ELSE
                        oi:BagName := NULL
                    ENDIF
                    SELF:_focusNtx := 0
                    SELF:_currentOrder := NULL
                    SELF:_focusNtx := SELF:FindOrder(oi:Order)
                    isOk := FALSE
                    IF (SELF:_focusNtx > 0)
                        isOk := SELF:_oRdd:GoCold()
                        currentOrder:SetOffLine()
                        IF (isOk)
                            SELF:_currentOrder := SELF:_Orders[SELF:_focusNtx - 1]
                            SELF:_currentOrder:SetOffLine()
                        ENDIF
                    ELSE
                        isOk := FALSE
                        SELF:_oRdd:_dbfError(SubCodes.ERDD_INVALID_ORDER, GenCode.EG_NOORDER,  NULL)
                    ENDIF
                    RETURN isOk
                    
                    
                INTERNAL METHOD Rebuild() AS LOGIC
                    LOCAL ordCondInfo AS DBORDERCONDINFO
                    LOCAL isOk AS LOGIC
                    //
                    ordCondInfo := SELF:_oRdd:_OrderCondInfo
                    isOk := SELF:GoCold()
                    IF (!isOk)
                        RETURN FALSE
                    ENDIF
                    //
                    FOREACH order AS NtxOrder IN SELF:_Orders 
                        isOk := order:Truncate()
                        IF (isOk)
                            IF !order:_Unique .AND. !order:_Conditional .AND. !order:_Descending .AND. !ordCondInfo:Scoped
                                isOk := order:_CreateIndex()
                            ELSE
                                isOk := order:_CreateUnique(ordCondInfo)
                            ENDIF
                        ENDIF
                    NEXT
                    IF (!isOk)
                        isOk := SELF:Flush()
                        IF (!isOk)
                            RETURN isOk
                        ENDIF
                        FOREACH order2 AS NtxOrder IN SELF:_Orders 
                            order2:_Hot := FALSE
                        NEXT
                        isOk := SELF:_oRdd:GoTop()
                    ENDIF
                    RETURN isOk
                    
                    
                PRIVATE METHOD __GetName(iOrder AS LONG , uiType AS DWORD , strValue REF STRING ) AS LOGIC
                    LOCAL result AS LOGIC
                    LOCAL ntxOrder AS NtxOrder
                    //
                    result := TRUE
                    IF ((iOrder > 0) .AND. (iOrder <= SELF:_Orders:Count))
                        ntxOrder := SELF:_Orders[iOrder - 1]
                        BEGIN SWITCH uiType
                    CASE 5
                        strValue := ntxOrder:OrderName
                    CASE 7
                        strValue := ntxOrder:FileName
                    OTHERWISE
                            strValue := NULL
                        result := FALSE
                    END SWITCH
                    ENDIF
                RETURN result
                
                
            INTERNAL METHOD FindOrder(uOrder AS OBJECT ) AS LONG
                LOCAL result AS LONG
                LOCAL num AS LONG
                //
                result := 0
                IF (uOrder == NULL)
                    RETURN SELF:_focusNtx
                ENDIF
                //
                BEGIN SWITCH Type.GetTypeCode(uOrder:GetType())
            CASE TypeCode.String
                result := SELF:__GetNamePos((STRING)uOrder)
            CASE TypeCode.Int16
            CASE TypeCode.Int32
            CASE TypeCode.Int64
            CASE TypeCode.Single
            CASE TypeCode.Double
                    num := (LONG)uOrder
                    IF ((num > 0) .AND. (num <= SELF:_Orders:Count))
                        result := num
                ENDIF
            OTHERWISE
                result := 0
            END SWITCH
            RETURN result
            
            
        INTERNAL METHOD Flush() AS LOGIC
            LOCAL isOk AS LOGIC
            LOCAL i AS LONG
            LOCAL ntxIndex AS NtxOrder
            //
            isOk := TRUE
            FOR i := 0 TO SELF:_Orders:Count-1
                ntxIndex := SELF:_Orders[i]
                isOk := ntxIndex:Commit()
                IF (!isOk)
                    EXIT
                ENDIF
            NEXT
            RETURN isOk
            
            
        INTERNAL METHOD GoCold() AS LOGIC
            LOCAL isOk AS LOGIC
            LOCAL i AS LONG
            LOCAL ntxIndex AS NtxOrder
            //
            isOk := TRUE
            FOR i := 0 TO SELF:_Orders:Count-1
                ntxIndex := SELF:_Orders[i]
                isOk := ntxIndex:GoCold()
                IF (!isOk)
                    EXIT
                ENDIF
            NEXT
            RETURN isOk
            
            
        INTERNAL METHOD GoHot() AS LOGIC
            LOCAL isOk AS LOGIC
            LOCAL i AS LONG
            LOCAL ntxIndex AS NtxOrder
            //
            isOk := TRUE
            FOR i := 0 TO SELF:_Orders:Count-1
                ntxIndex := SELF:_Orders[i]
                isOk := ntxIndex:_KeySave((DWORD)SELF:_oRdd:RecNo)
                IF (!isOk)
                    EXIT
                ENDIF
            NEXT
            RETURN isOk
            
            
        PRIVATE METHOD __GetNamePos(orderName AS STRING ) AS LONG
            LOCAL i AS LONG
            LOCAL ntxIndex AS NtxOrder
            //
            IF (SELF:_Orders:Count > 0)
                FOR i := 0 TO SELF:_Orders:Count-1
                    ntxIndex := SELF:_Orders[i]
                    IF (string.Equals(ntxIndex:OrderName, orderName, StringComparison.OrdinalIgnoreCase))
                        RETURN i + 1
                    ENDIF
                NEXT
            ENDIF
            RETURN 0
            
            
    END CLASS
    
    
END NAMESPACE
