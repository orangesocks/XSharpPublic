﻿// NtxPageList.prg
// Created by    : fabri
// Creation Date : 7/12/2018 5:54:15 PM
// Created for   : 
// WorkStation   : FABPORTABLE


USING System
USING System.Collections.Generic
USING System.Text

BEGIN NAMESPACE XSharp.RDD

    /// <summary>
    /// The NtxPageList class.
    /// </summary>
    INTERNAL CLASS NtxPageList
        PROTECT _Pages AS List<NtxPage>
        PROTECT _Order AS NtxOrder
        
        PRIVATE METHOD _FindPage( offset AS LONG ) AS NtxPage
            LOCAL ntxPage AS NtxPage
            //
            ntxPage := SELF:_Pages:Find( { p => p:PageOffset == offset } )
            RETURN ntxPage
            
            
        CONSTRUCTOR( order AS NtxOrder )
            SELF:_Pages := List<NtxPage>{}
            SELF:_Order := order
            
            
        METHOD Update( pageNo AS LONG ) AS NtxPage
            LOCAL ntxPage AS NtxPage
            //
            ntxPage := SELF:Read(pageNo)
            IF ( ntxPage != NULL )
                ntxPage:Hot := TRUE
            ENDIF
            RETURN ntxPage
            
            
        METHOD Append( offset AS LONG ) AS NtxPage
            LOCAL ntxPage AS NtxPage
            //
            ntxPage := SELF:_FindPage(offset)
            IF (ntxPage == NULL)
                ntxPage := NtxPage{SELF:_Order, 0L}
                ntxPage:PageOffset := offset
                SELF:_Pages:Add(ntxPage)
            ENDIF
            ntxPage:Hot := TRUE
            RETURN ntxPage
            
            
        METHOD Read(pageNo AS LONG ) AS NtxPage
            LOCAL ntxPage AS NtxPage
            //
            ntxPage := SELF:_FindPage(pageNo)
            IF (ntxPage == NULL)
                ntxPage := NtxPage{SELF:_Order, pageNo}
                SELF:_Pages:Add(ntxPage)
            ENDIF
            RETURN ntxPage
            
            
        METHOD Flush( keepData AS LOGIC ) AS LOGIC
            LOCAL isOk AS LOGIC
            //
            isOk := TRUE
            TRY
                FOREACH page AS NtxPage IN SELF:_Pages 
                    isOk := page:Write()
                    IF (!isOk)
                        EXIT
                    ENDIF
                NEXT
                IF (isOk)
					FFlush( SELF:_Order:_hFile )
                ENDIF
            CATCH AS Exception
                isOk := FALSE
            END TRY
            IF ((isOk) .AND. (!keepData))
                SELF:_Pages:Clear()
            ENDIF
            RETURN isOk
            
            
        METHOD Write(pageNo AS LONG ) AS LOGIC
            LOCAL ntxPage AS NtxPage
            //
            ntxPage := SELF:_FindPage(pageNo)
            IF (ntxPage != NULL)
                ntxPage:Hot := TRUE
                RETURN ntxPage:Write()
            ENDIF
            RETURN FALSE
            
            
    END CLASS
    
END NAMESPACE // global::XSharp.RDD.Types.DbfNtx