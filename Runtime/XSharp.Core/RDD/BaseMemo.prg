//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
USING System.Text
USING XSharp.RDD.Support

/// <summary>Base Memo class. Does not implement anything. </summary>
/// <seealso cref="T:XSharp.RDD.IMemo"/>
CLASS XSharp.RDD.BaseMemo IMPLEMENTS IMemo
    PROTECTED _oArea AS Workarea
    
    /// <summary>Create the BaseMemo object</summary>
    /// <param name="oArea">Workarea object that 'owns' this memo object </param>
    CONSTRUCTOR(oArea AS Workarea)
        _oArea := oArea
        
    VIRTUAL PROPERTY LastWrittenBlockNumber AS LONG AUTO GET SET
    
    // Read & Write		
    /// <inheritdoc />
    VIRTUAL METHOD GetValue(nFldPos AS INT) AS OBJECT
        THROW NotImplementedException{}
        
        /// <inheritdoc />
    VIRTUAL METHOD GetValueFile(nFldPos AS INT, fileName AS STRING) AS LOGIC
        THROW NotImplementedException{}
        
        /// <inheritdoc />
    VIRTUAL METHOD GetValueLength(nFldPos AS INT) AS INT
        THROW NotImplementedException{}
        
        /// <inheritdoc />
    VIRTUAL METHOD Flush() 			AS LOGIC
        THROW NotImplementedException{}
        
        /// <inheritdoc />
    VIRTUAL METHOD PutValue(nFldPos AS INT, oValue AS OBJECT) AS LOGIC
        THROW NotImplementedException{}
        
        /// <inheritdoc />
    VIRTUAL METHOD PutValueFile(nFldPos AS INT, fileName AS STRING) AS LOGIC
        THROW NotImplementedException{}
        
        // Memo File Access 
        /// <inheritdoc />
    VIRTUAL METHOD CloseMemFile( ) AS LOGIC
        THROW NotImplementedException{}
        
        /// <inheritdoc />
    VIRTUAL METHOD CreateMemFile(info AS DbOpenInfo) AS LOGIC
        THROW NotImplementedException{}
        
        /// <inheritdoc />
    VIRTUAL METHOD OpenMemFile(info AS DbOpenInfo ) AS LOGIC
        THROW NotImplementedException{}

    /// <inheritdoc />        
    VIRTUAL METHOD Zap() AS LOGIC
        THROW NotImplementedException{}
        
END CLASS
