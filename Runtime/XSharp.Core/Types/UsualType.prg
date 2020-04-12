﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//


USING System
USING System.Collections.Generic
USING System.Text

BEGIN NAMESPACE XSharp
  /// <summary>This enum is used to describe the type of USUAL values in the X# Runtime.
  /// It is based on the original USUAL type values in the VO runtime and has been extended with some additional type numbers.
  /// </summary>
  ENUM __UsualType AS BYTE
        // These numbers must match with the types defined in the compiler
        // They also match with the USUAL types in VO (BaseType.h)
        /// <summary>The usual contains a NIL.</summary>
        MEMBER Void		:=0
        /// <summary>The usual contains a LONG value</summary>
        MEMBER Long		:=1
        /// <summary>The usual contains a DATE value</summary>
        MEMBER Date		:=2
        /// <summary>The usual contains a FLOAT value</summary>
        MEMBER Float	:=3
        /// <summary>This value is NEVER used for USUALs (this was also defined in VO but never used).</summary>
        MEMBER Fixed    := 4 
        /// <summary>The usual contains an ARRAY value</summary>
        MEMBER Array	:=5
        /// <summary>The usual contains an OBJECT value</summary>
        MEMBER Object	:=6
        /// <summary>The usual contains an STRING value</summary>
        MEMBER String	:=7
        /// <summary>The usual contains an LOGIC value</summary>
        MEMBER Logic	:=8
        /// <summary>The usual contains an CODEBLOCK value</summary>
        MEMBER Codeblock:=9
        /// <summary>The usual contains an SYMBOL value</summary>
        MEMBER Symbol	:=10
        // see below for missing values
        // The follow numbers are defined but never stored inside a USUAL in VO and Vulcan
        /// <summary>This value is in the enum for completeness but never used inside a usual. Byte values are stored as LONG.</summary>
        MEMBER Byte		:=11
        /// <summary>This value is in the enum for completeness but never used inside a usual. Short values are stored as LONG.</summary>
        MEMBER ShortInt	:=12
        /// <summary>This value is in the enum for completeness but never used inside a usual. Word values are stored as LONG.</summary>
        MEMBER Word		:=13
        /// <summary>This value is in the enum for completeness but never used inside a usual. DWord values are stored as LONG or FLOAT.</summary>
        MEMBER DWord	:=14
        /// <summary>This value is in the enum for completeness but never used inside a usual. Real4 values are stored as FLOAT</summary>
        MEMBER Real4	:=15
        /// <summary>This value is in the enum for completeness but never used inside a usual. Real8 values are stored as FLOAT.</summary>
        MEMBER Real8	:=16
        /// <summary>This value is in the enum for completeness but never used inside a usual.</summary>
        /// <summary>The usual contains an PSZ value</summary>
        MEMBER Psz		:=17
        /// <summary>The usual contains an PTR value</summary>
        MEMBER Ptr		:=18
        /// <exclude/>	
        MEMBER Usual	:=19	// USUAL by Ref, not implemented in Vulcan

        // 20 and 21 not used

        /// <summary>The usual contains an INT64 value (new in Vulcan and X#).</summary>
        MEMBER Int64		:=22
        /// <summary>The usual contains an UINT64 value (new in Vulcan and X#).</summary>
        MEMBER UInt64     :=23
        /// <summary>This value is in the enum for completeness but never used inside a usual. Char values are stored as LONG</summary>
        MEMBER Char		:=24    // not stored in a usual
        /// <summary>This value is in the enum for completeness but never used inside a usual. Dynamic values are stored as OBJECT</summary>
        MEMBER Dynamic    :=25
        /// <summary>The usual contains a DateTime value (new in X#).</summary>
        MEMBER DateTime	:=26
        /// <summary>The usual contains a Decimal value (new in X#).</summary>
        MEMBER Decimal	:=27
        /// <summary>The usual contains a Currency value (new in X#).</summary>
        MEMBER Currency	:=28
        /// <summary>The usual contains an Memo value. This value is there for compatibility with VO but never used.</summary>
        MEMBER Memo		:=32	// Used in RDD system in VO
        /// <summary>Invalid Usual Type.</summary>
        MEMBER Invalid    :=99
    END ENUM

END NAMESPACE // global::XSharp.Types
