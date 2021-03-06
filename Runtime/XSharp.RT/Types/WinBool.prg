﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
USING System.Collections
USING System.Collections.Generic
USING System.Linq
USING System.Diagnostics
USING System.Runtime.Serialization

BEGIN NAMESPACE XSharp	
	/// <summary>Internal type that implements the WIN32 Compatible LOGIC type in UNIONs and VOSTRUCTs</summary>
    [DebuggerDisplay("WinBool({ToString(),nq})", Type := "LOGIC")];
    [Serializable];
    PUBLIC STRUCT __WinBool IMPLEMENTS ISerializable
        [DebuggerBrowsable(DebuggerBrowsableState.Never)];
        PRIVATE STATIC trueValue := __WinBool{1}	AS __WinBool
        [DebuggerBrowsable(DebuggerBrowsableState.Never)];
        PRIVATE STATIC falseValue := __WinBool{0}	AS __WinBool
        [DebuggerBrowsable(DebuggerBrowsableState.Never)];
        PRIVATE INITONLY _value AS INT			// 0 = false, 1 = true

        PUBLIC PROPERTY @@Value AS LOGIC GET _value != 0

        PRIVATE CONSTRUCTOR(@@value AS INT)
            _value := @@value
            
       	/// <summary>This constructor is used in code generated by the compiler when needed.</summary>
        CONSTRUCTOR (lValue AS LOGIC)
            _value := IIF(lValue, 1, 0)

		/// <inheritdoc />
        OVERRIDE METHOD GetHashCode() AS INT
            RETURN _value:GetHashCode()
            
       /// <exclude />
	    METHOD GetTypeCode() AS TypeCode
            RETURN TypeCode.Boolean

       /// <inheritdoc />
	    OVERRIDE METHOD ToString() AS STRING
            RETURN IIF(_value != 0, "TRUE", "FALSE")

            
            #region Unary Operators
         /// <include file="RTComments.xml" path="Comments/Operator/*" />
         STATIC OPERATOR !(wb AS __WinBool) AS LOGIC
            RETURN wb:_value == 0
            #endregion
            
        #region Binary Operators
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        OPERATOR == (lhs AS __WinBool, rhs AS __WinBool) AS LOGIC
            RETURN lhs:_value == rhs:_value
            
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        OPERATOR != (lhs AS __WinBool, rhs AS __WinBool) AS LOGIC
            RETURN lhs:_value != rhs:_value
            
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        OPERATOR == (lhs AS __WinBool, rhs AS LOGIC) AS LOGIC
            RETURN IIF (rhs, lhs:_value != 0, lhs:_value == 0)
            
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        OPERATOR != (lhs AS __WinBool, rhs AS LOGIC) AS LOGIC
            RETURN IIF (rhs, lhs:_value == 0, lhs:_value != 0)
            
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        OPERATOR == (lhs AS LOGIC, rhs AS __WinBool) AS LOGIC
            RETURN IIF (lhs, rhs:_value != 0, rhs:_value == 0)
            
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        OPERATOR != (lhs AS LOGIC, rhs AS __WinBool) AS LOGIC
            RETURN IIF (lhs, rhs:_value == 0, rhs:_value != 0)
            
            /// <inheritdoc />
         PUBLIC OVERRIDE METHOD Equals(obj AS OBJECT) AS LOGIC
            IF obj IS __WinBool
                RETURN SELF:_value == ((__WinBool) obj):_value
            ENDIF
            RETURN FALSE
            #endregion 
            
        #region Implicit Converters
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR IMPLICIT(wb AS __WinBool) AS LOGIC
            RETURN wb:_value != 0
            
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR IMPLICIT(u AS USUAL) AS __WinBool
            RETURN __WinBool{(LOGIC) u}
            
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR IMPLICIT(l AS LOGIC) AS __WinBool
            RETURN IIF(l, trueValue, falseValue)
            
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR IMPLICIT(wb AS __WinBool) AS USUAL
            RETURN wb:_value != 0
            
            #endregion
        #region Logical operators
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR &(lhs AS __WinBool, rhs AS __WinBool) AS __WinBool
            RETURN IIF( lhs:_value == 1 .AND. rhs:_value == 1, trueValue, falseValue)
            
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR |(lhs AS __WinBool, rhs AS __WinBool) AS __WinBool
            RETURN IIF(lhs:_value == 1 .OR. rhs:_value == 1, trueValue, falseValue)
            
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR TRUE(wb AS __WinBool ) AS LOGIC
            RETURN wb:_value == 1
            
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR FALSE(wb AS __WinBool )AS LOGIC
            RETURN wb:_value == 0
            
            #endregion
        #region ISerializable
        /// <inheritdoc/>
        PUBLIC METHOD GetObjectData(info AS SerializationInfo, context AS StreamingContext) AS VOID
            IF info == NULL
                THROW System.ArgumentException{"info"}
            ENDIF
            info:AddValue("Value", _value)
            RETURN
            
        /// <include file="RTComments.xml" path="Comments/SerializeConstructor/*" />
        CONSTRUCTOR (info AS SerializationInfo, context AS StreamingContext)
            IF info == NULL
                THROW System.ArgumentException{"info"}
            ENDIF
            _value := info:GetInt32("Value")
            #endregion
            
    END	STRUCT
END NAMESPACE
