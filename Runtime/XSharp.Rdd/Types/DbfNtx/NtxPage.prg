﻿// NtxPage.prg
// Created by    : fabri
// Creation Date : 6/21/2018 5:31:55 PM
// Created for   : 
// WorkStation   : FABPORTABLE


USING System
USING System.Collections.Generic
USING System.Text
USING System.IO
USING System.Diagnostics

BEGIN NAMESPACE XSharp.RDD

    // the ntx file consists of pages of 1k. A Page contains Items (also called Nodes in some docs)
    // The first page is the Header => See NtxHeader Class
    // Based on the Key Size, we will have to calculate how many items a page can hold, and then determine the Max Number of Items
    // Each Item contains a key value, whose size depends on the Key Size.
    
    // The size of each item is: 8 + Key Size ( the last item doesn't contain a key value, only a pointer to a sub-tree.)
    // The structure of an Item is 
    // long page_offset - file offset (within ntx file) where sub-tree is. if there's no subtree, a 0 is stored.
    // long recno       - record number for this key value (in the dbf file)
    // char key_value[key_size]
    
    // The number of Items per page depends on the Key Size
    
    // A Page is organized as follows :
    // 0x00 - (WORD) Item Count - how many items this particular page holds.
    // 0x02 - (DWORD) Items Offset - This is an array of <Item Count> elements, that contains the offset within the page of each Item
    // 0x?? - The area where Item values are stored
    
    /// <summary>
    /// The NtxPage class.
    /// </summary>
    INTERNAL CLASS NtxPage
    
        PROTECTED _Order    AS NtxOrder
        PROTECTED _Offset   AS LONG
        PROTECTED _Hot      AS LOGIC
        
        PROTECTED _Bytes AS BYTE[]
        
        // Current Page Number
        //PROPERTY PageNo AS LONG GET SELF:_Number SET SELF:_Number := VALUE
		PROPERTY PageOffset AS LONG GET SELF:_Offset SET SELF:_Offset := VALUE
        
        PROPERTY Bytes AS BYTE[] GET SELF:_Bytes
        
        PROPERTY Hot AS LOGIC GET SELF:_Hot SET SELF:_Hot := VALUE
        
        PROPERTY NodeCount AS WORD
            GET
                LOCAL nCount := 0 AS WORD
                TRY
                    nCount := BitConverter.ToUInt16( SELF:_Bytes, 0)
                CATCH e AS Exception
                    Debug.WriteLine( "Ntx Error : " + e:Message )
                END TRY
                RETURN nCount
            END GET
            
            SET
                LOCAL nCount := VALUE AS WORD
                TRY
                    Array.Copy(BitConverter.GetBytes( nCount), 0, SELF:_bytes, 0, 2)
                CATCH e AS Exception
                    Debug.WriteLine( "Ntx Error : " + e:Message )
                END TRY
                
            END SET
        END PROPERTY
        
        PROPERTY SELF[ index AS LONG ] AS NtxItem
            GET
                LOCAL item := NULL AS NtxItem
                TRY
                    item := NtxItem{ SELF:_Order:_keySize , SELF:_Order:_oRdd }
                    item:Fill( index, SELF )
                CATCH e AS Exception
                    Debug.WriteLine( "Ntx Error : " + e:Message )
                END TRY
                RETURN item
            END GET
        END PROPERTY
        
        CONSTRUCTOR( order AS NtxOrder, pageNumber AS LONG )
            //
            SELF:_Order := order
            SELF:_Offset := pageNumber
            SELF:_Bytes := BYTE[]{NtxHeader.NTXOFFSETS.SIZE}
            SELF:_Hot := FALSE
            IF ( SELF:_Offset != 0 )
                SELF:Read()
            ENDIF
            RETURN
            
        METHOD Read() AS LOGIC
            LOCAL isOk AS LOGIC
            //
            isOk := TRUE
            IF ( SELF:_Hot )
                BEGIN LOCK SELF
                    isOk := SELF:Write()
                END LOCK
            ENDIF
            IF isOk
                TRY
                    // Move to top of Page
                    FSeek3( SELF:_Order:_hFile, SELF:_Offset /*  * NtxHeader.NTXOFFSETS.SIZE    */, SeekOrigin.Begin )
                    // Read Buffer
                    isOk := ( FRead3(SELF:_Order:_hFile, SELF:_Bytes, NtxHeader.NTXOFFSETS.SIZE) == NtxHeader.NTXOFFSETS.SIZE )
                CATCH e AS Exception
                    isOk := FALSE
                    Debug.WriteLine( "Ntx Error : " + e:Message )
                END TRY
            ENDIF
            RETURN isOk
            
        METHOD Write() AS LOGIC
            LOCAL isOk AS LOGIC
            //
            isOk := TRUE
            IF ( !SELF:_Hot )
                RETURN isOk
            ENDIF
            // Should it be <= ?
            IF ( SELF:_Offset < 0 )
                RETURN FALSE
            ENDIF
            TRY
                // Move to top of Page
                FSeek3( SELF:_Order:_hFile, SELF:_Offset  /* * NtxHeader.NTXOFFSETS.SIZE    */ , SeekOrigin.Begin )
                // Write Buffer
                isOk := ( FWrite3(SELF:_Order:_hFile, SELF:_Bytes, NtxHeader.NTXOFFSETS.SIZE) == NtxHeader.NTXOFFSETS.SIZE )
                SELF:_Hot := FALSE
            CATCH e AS Exception
                isOk := FALSE
                Debug.WriteLine( "Ntx Error : " + e:Message )
            END TRY
            RETURN isOk
            
        PUBLIC METHOD GetRef( pos AS LONG ) AS SHORT
            TRY
                RETURN BitConverter.ToInt16(SELF:_bytes, (pos+1) * 2)
            CATCH //Exception
                RETURN 0
            END TRY
            
            
        PUBLIC METHOD SetRef(pos AS LONG , newValue AS SHORT ) AS VOID
            Array.Copy(BitConverter.GetBytes( newValue), 0, SELF:_bytes, (pos+1) * 2, 2)
            SELF:Hot := TRUE
            
    END CLASS
    
END NAMESPACE 