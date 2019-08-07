//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
USING System
USING System.Runtime.InteropServices
USING System.Runtime.CompilerServices
USING System.Diagnostics
USING System.Text
USING XSharp.Internal
BEGIN NAMESPACE XSharp
    /// <summary>Internal type that implements the VO Compatible USUAL type.<br/>
    /// This type has many operators and implicit converters that normally are never directly called from user code.
    /// </summary>
    [StructLayout(LayoutKind.Sequential, Pack := 4)];
    [DebuggerDisplay("{Value,nq} ({_usualType})", Type := "USUAL")];
    [DebuggerTypeProxy(TYPEOF(UsualDebugView))];
    PUBLIC STRUCTURE __Usual IMPLEMENTS IConvertible, ;
        IComparable, ;
        IComparable<__Usual>, ;
        IEquatable<__Usual>, ;
        IIndexedProperties, ;
        IIndexer
        #region STATIC fields
        /// <exclude />
        PUBLIC STATIC _NIL AS __Usual
        #endregion

        #region PRIVATE fields
        PRIVATE INITONLY _flags    	AS UsualFlags	// type, byref, width, decimals
        PRIVATE INITONLY _valueData	AS _UsualData		// for non GC data
        PRIVATE INITONLY _refData  	AS OBJECT			// for GC data
        #endregion

        #region constructors
        /// <exclude />
        STATIC CONSTRUCTOR
            _NIL := __Usual{__UsualType.Void}
            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(type AS __UsualType )
            SELF:_valueData := _UsualData{}
            SELF:_flags     := UsualFlags{type}
            SELF:_refData   := NULL

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(u AS __Usual)
            SELF:_flags     := u:_flags
            SELF:_valueData	:= u:_valueData
            SELF:_refData 	:= u:_refData

            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(f AS FLOAT)
            SELF(__UsualType.Float)
            SELF:_valueData:r8		:= f:Value
            SELF:_flags:Width		:= (Sbyte) f:Digits
            SELF:_flags:Decimals	:= (Sbyte) f:Decimals
            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(r8 AS REAL8)
            SELF(__UsualType.Float)
            SELF:_valueData:r8		:= r8
            SELF:_flags:Width		:= -1
            SELF:_flags:Decimals	:= -1
            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(VALUE AS LOGIC)
            SELF(__UsualType.Logic)
            SELF:_valueData:l		:= VALUE
            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(VALUE AS ARRAY)
            SELF(__UsualType.Array)
            SELF:_refData			:= VALUE
            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(VALUE AS DATE)
            SELF(__UsualType.DATE)
            SELF:_valueData:d		:= VALUE
            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(VALUE AS System.DateTime)
            SELF(__UsualType.DateTime)
            SELF:_valueData:dt		:= VALUE
            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(VALUE AS LONG)
            SELF(__UsualType.Long)
            _valueData:i			:= VALUE
            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(VALUE AS INT64)
            SELF(__UsualType.Int64)
            SELF:_valueData:i64		:= VALUE
            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(VALUE AS UINT64)
            IF VALUE < Int64.MaxValue
                SELF(__UsualType.Int64)
                SELF:_valueData:i64:= (INT64) VALUE
            ELSE
                SELF(__UsualType.Float)
                SELF:_valueData:r8 := VALUE
            ENDIF
            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(d AS System.Decimal)
            SELF(__UsualType.Decimal)
            SELF:_refdata	:= d

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(VALUE AS System.IntPtr)
            SELF(__UsualType.Ptr)
            SELF:_valueData:p		:= VALUE
            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(VALUE AS PSZ)
            SELF(__UsualType.String)
            SELF:_refData			:= Psz2String(VALUE)
            RETURN
            /// <summary>This constructor is used in code generated by the compiler when needed.</summary>
        PUBLIC CONSTRUCTOR(o AS OBJECT)
            SELF := __Usual._NIL
            IF o != NULL
                VAR vartype := o:GetType()
                //  decode type from typecode
                VAR typeCode := System.Type.GetTypeCode(vartype)
                SWITCH typeCode
                CASE  System.TypeCode.DBNull
                    // do nothing
                    NOP

                CASE System.TypeCode.Boolean
                    SELF:_flags				:= UsualFlags{__UsualType.Logic}
                    SELF:_valueData:l := (LOGIC)o

                CASE System.TypeCode.Char
                    SELF:_flags				:= UsualFlags{__UsualType.Long}
                    SELF:_valueData:i	:= (CHAR)o

                CASE System.TypeCode.SByte
                    SELF:_flags				:= UsualFlags{__UsualType.Long}
                    SELF:_valueData:i	:= (SByte)o

                CASE System.TypeCode.Byte
                    SELF:_flags				:= UsualFlags{__UsualType.Long}
                    SELF:_valueData:i	:= (BYTE)o

                CASE System.TypeCode.Int16
                    SELF:_flags				:= UsualFlags{__UsualType.Long}
                    SELF:_valueData:i	:= (SHORT)o

                CASE System.TypeCode.UInt16
                    SELF:_flags				:= UsualFlags{__UsualType.Long}
                    SELF:_valueData:i	:= (WORD)o

                CASE System.TypeCode.Int32
                    SELF:_flags				:= UsualFlags{__UsualType.Long}
                    SELF:_valueData:i	:= (LONG)o

                CASE System.TypeCode.UInt32
                    IF (DWORD)o  <= Int32.MaxValue
                        SELF:_flags				:= UsualFlags{__UsualType.Long}
                        SELF:_valueData:i := (LONG)(DWORD)o
                    ELSE
                        SELF:_flags				:= UsualFlags{__UsualType.Float}
                        SELF:_valueData:r8:= (REAL8) (UInt32) o
                        SELF:_flags:width	:= -1
                        SELF:_flags:decimals := -1
                    ENDIF
                CASE System.TypeCode.Int64
                    SELF:_flags				:= UsualFlags{__UsualType.Int64}
                    SELF:_valueData:i64	:= (INT64)o

                CASE System.TypeCode.UInt64
                    IF (UINT64) o  <= Int64.MaxValue
                        SELF:_flags				:= UsualFlags{__UsualType.Int64}
                        SELF:_valueData:i64		:= (INT64)(UINT64)o
                    ELSE
                        SELF:_flags				:= UsualFlags{__UsualType.Float}
                        SELF:_valueData:r8 := (REAL8)(UINT64)o
                        SELF:_flags:width	:= -1
                        SELF:_flags:decimals := -1
                    ENDIF
                CASE System.TypeCode.Single
                    SELF:_flags			:= UsualFlags{__UsualType.Float}
                    SELF:_valueData:r8	:= (REAL4)o
                    SELF:_flags:width	:= -1
                    SELF:_flags:decimals := -1

                CASE System.TypeCode.Double
                    SELF:_flags				:= UsualFlags{__UsualType.Float}
                    SELF:_valueData:r8 := (REAL8)o
                    SELF:_flags:width := -1
                    SELF:_flags:decimals := -1

                CASE System.TypeCode.Decimal
                    SELF:_flags				:= UsualFlags{__UsualType.Decimal}
                    SELF:_refData  := o

                CASE System.TypeCode.DateTime
                    SELF:_flags				:= UsualFlags{__UsualType.DateTime}
                    SELF:_valueData:dt := (System.DateTime) o

                CASE System.TypeCode.String
                    SELF:_flags				:= UsualFlags{__UsualType.String}
                    SELF:_refData  := (STRING)o

                OTHERWISE
                    IF vartype == typeof(__Usual)
                        // boxed __Usual
                        VAR u   := (__Usual)o
                        SELF    := u 
                    ELSEIF vartype == TYPEOF(ARRAY) 
                        SELF:_flags				:= UsualFlags{__UsualType.Array}
                        SELF:_refData           := (ARRAY) o
                    ELSEIF vartype == TYPEOF(DATE) 
                        SELF:_flags				:= UsualFlags{__UsualType.Date}
                        SELF:_valueData:d		:= (DATE) o
                    ELSEIF vartype == TYPEOF(SYMBOL) 
                        SELF:_flags				:= UsualFlags{__UsualType.Symbol}
                        SELF:_valueData:s		:= (SYMBOL) o
                    ELSEIF vartype == TYPEOF(IntPtr) 
                        SELF:_flags				:= UsualFlags{__UsualType.Ptr}
                        SELF:_valueData:p		:= (IntPtr) o
                    ELSEIF vartype == TYPEOF(System.Reflection.Pointer)
                        SELF:_flags				:= UsualFlags{__UsualType.Ptr}
                        SELF:_valueData:p		:= Intptr{System.Reflection.Pointer.UnBox(o)}
                    ELSEIF o IS IDate VAR d
                        SELF:_flags				:= UsualFlags{__UsualType.Date}
                        SELF:_valueData:d		:= DATE{d }
                    ELSEIF o IS IFloat VAR f
                        SELF:_flags				:= UsualFlags{__UsualType.Float}
                        SELF:_valueData:r8		:= f:Value
                        SELF:_flags:Width		:= (Sbyte) f:Digits
                        SELF:_flags:Decimals	:= (Sbyte) f:Decimals
                    ELSEIF o IS ICodeblock VAR cb
                        SELF:_flags				:= UsualFlags{__UsualType.Codeblock}
                        SELF:_refData           := cb
                    ELSEIF o IS OBJECT[]   VAR oArray
                        SELF:_flags				:= UsualFlags{__UsualType.ARRAY}
                        SELF:_refData           := ARRAY{oArray}
                    ELSE
                        SELF:_flags				:= UsualFlags{__UsualType.OBJECT}
                        SELF:_refData           := o
                    ENDIF
                END SWITCH
            ENDIF
            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(s AS STRING)
            SELF(__UsualType.String)
            SELF:_refData 			:= s
            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(s AS SYMBOL)
            SELF(__UsualType.Symbol)
            SELF:_valueData:s       := s
            RETURN

        [DebuggerStepThroughAttribute] [MethodImpl(MethodImplOptions.AggressiveInlining)];
        PRIVATE CONSTRUCTOR(o AS OBJECT, lIsNull AS LOGIC)
            SELF(__UsualType.Object)
        
            RETURN

        #endregion

        #region properties
        PRIVATE PROPERTY _isByRef		AS LOGIC	GET _flags:isByRef
        INTERNAL PROPERTY _usualType	AS __UsualType GET _flags:usualType

        /// No checks for typeflag. These private properties should always be accessed after checking the correct type
        PRIVATE PROPERTY _arrayValue    AS ARRAY			GET (ARRAY) _refData
        PRIVATE PROPERTY _codeblockValue AS ICodeBlock		GET (ICodeBlock) _refData
        PRIVATE PROPERTY _dateValue		AS DATE				GET _valueData:d
        PRIVATE PROPERTY _dateTimeValue AS DateTime			GET _valueData:dt
        PRIVATE PROPERTY _decimalValue	AS System.Decimal	GET (System.Decimal) _refData
        PRIVATE PROPERTY _floatValue    AS FLOAT			GET FLOAT{ _valueData:r8, _width, _decimals}
        PRIVATE PROPERTY _i64Value		AS INT64			GET _valueData:i64
        PRIVATE PROPERTY _intValue		AS INT				GET _valueData:i
        PRIVATE PROPERTY _logicValue	AS LOGIC			GET _valueData:l
        PRIVATE PROPERTY _ptrValue		AS IntPtr			GET _valueData:p
        PRIVATE PROPERTY _r8Value		AS REAL8			GET _valueData:r8
        PRIVATE PROPERTY _stringValue   AS STRING			GET (STRING) _refData
        PRIVATE PROPERTY _symValue		AS SYMBOL			GET _valueData:s

        // properties for floats
        PRIVATE PROPERTY _width			AS SBYTE GET _flags:width
        PRIVATE PROPERTY _decimals		AS SBYTE GET _flags:decimals
        // Is .. ?
        /// <summary>This property returns TRUE when the USUAL is of type ARRAY </summary>
        PUBLIC PROPERTY IsArray		AS LOGIC GET _usualtype == __UsualType.Array
        /// <summary>This property returns TRUE when the USUAL is of type CODEBLOCK </summary>
        PUBLIC PROPERTY IsCodeblock	AS LOGIC GET _usualtype == __UsualType.Codeblock
        /// <summary>This property returns TRUE when the USUAL is of type DATE </summary>
        PUBLIC PROPERTY IsDate		AS LOGIC GET _usualtype == __UsualType.Date
        /// <summary>This property returns TRUE when the USUAL is of type DateTime </summary>
        PUBLIC PROPERTY IsDateTime	AS LOGIC GET _usualtype == __UsualType.DateTime
        /// <summary>This property returns TRUE when the USUAL is of type Decimal </summary>
        PUBLIC PROPERTY IsDecimal	AS LOGIC GET _usualtype == __UsualType.Decimal
        /// <summary>This property returns TRUE when the USUAL is of type FLOAT </summary>
        PUBLIC PROPERTY IsFloat		AS LOGIC GET _usualtype == __UsualType.Float
        /// <summary>This property returns TRUE when the USUAL is of type Int64 </summary>
        PUBLIC PROPERTY IsInt64		AS LOGIC GET _usualtype == __UsualType.Int64
        /// <summary>This property returns TRUE when the USUAL is of type LOGIC </summary>
        PUBLIC PROPERTY IsLogic		AS LOGIC GET _usualtype == __UsualType.Logic
        /// <summary>This property returns TRUE when the USUAL is of type Long </summary>
        PUBLIC PROPERTY IsLong		AS LOGIC GET _usualtype == __UsualType.Long
        /// <summary>This property returns TRUE when the USUAL is of type LONG or INT64 </summary>
        PUBLIC PROPERTY IsInteger	AS LOGIC GET _usualtype == __UsualType.Long .OR. _usualtype == __UsualType.Int64
        /// <summary>This property returns the __UsualType of the USUAL </summary>
        PUBLIC PROPERTY Type		AS __UsualType GET _flags:usualType
        /// <summary>This property returns TRUE when the USUAL is of type LONG, Int64, FLOAT or Decimal</summary>
        PUBLIC PROPERTY IsNumeric AS LOGIC
            GET
                SWITCH _usualType
                CASE __UsualType.Long
                CASE __UsualType.Int64
                CASE __UsualType.Float
                CASE __UsualType.Decimal
                    RETURN TRUE
                OTHERWISE
                    RETURN FALSE
                END SWITCH
            END GET
        END PROPERTY

        /// <summary>This property returns TRUE when the USUAL is of type Object</summary>
        PUBLIC PROPERTY IsObject		AS LOGIC GET _usualtype == __UsualType.Object
        /// <summary>This property returns TRUE when the USUAL is of type Ptr (IntPtr)</summary>
        PUBLIC PROPERTY IsPtr			AS LOGIC GET _usualtype == __UsualType.Ptr
        /// <summary>This property returns TRUE when the USUAL is of type Symbol</summary>
        PUBLIC PROPERTY IsSymbol		AS LOGIC GET _usualtype == __UsualType.Symbol
        /// <summary>This property returns TRUE when the USUAL is of type String</summary>
        PUBLIC PROPERTY IsString		AS LOGIC GET _usualtype == __UsualType.String
        /// <summary>This property returns TRUE when the USUAL is passed by reference (not implemented yet)</summary>
        PUBLIC   PROPERTY IsByRef		AS LOGIC GET _isByRef
        /// <summary>This property returns TRUE when the USUAL is a reference type (Array, Decimal, Object, String)</summary>
        PRIVATE PROPERTY IsReferenceType AS LOGIC
            GET
                SWITCH _usualType
                CASE __UsualType.Array
                CASE __UsualType.Object
                CASE __UsualType.Decimal
                CASE __UsualType.String
                    RETURN TRUE
                OTHERWISE
                    RETURN FALSE
                END SWITCH
            END GET
        END PROPERTY
        /// <summary>This property returns TRUE when the USUAL Empty. </summary>
        INTERNAL PROPERTY IsEmpty AS LOGIC
            GET
                SWITCH _usualType
                CASE __UsualType.Array		; RETURN _arrayValue == NULL .OR. _arrayValue:Length == 0
                CASE __UsualType.Codeblock	; RETURN _codeblockValue == NULL
                CASE __UsualType.Date		; RETURN _dateValue:IsEmpty
                CASE __UsualType.DateTime	; RETURN _dateTimeValue == DateTime.MinValue
                CASE __UsualType.Decimal	; RETURN _decimalValue == 0
                CASE __UsualType.Float		; RETURN _floatValue == 0.0
                CASE __UsualType.Int64		; RETURN _i64Value == 0
                CASE __UsualType.Logic		; RETURN _logicValue == FALSE
                CASE __UsualType.Long		; RETURN _intValue == 0
                CASE __UsualType.Object		; RETURN _refData == NULL
                CASE __UsualType.Ptr		; RETURN _ptrValue == IntPtr.Zero
                CASE __UsualType.String		; RETURN EmptyString(_stringValue)
                CASE __UsualType.Symbol		; RETURN _symValue == 0
                CASE __UsualType.Void		; RETURN TRUE
                OTHERWISE
                    Debug.Fail( "Unhandled data type in Usual:Empty()" )
                END SWITCH
                RETURN FALSE
            END GET
        END PROPERTY

        /// <summary>This property returns TRUE when the USUAL is NIL, or when the usual is a reference type and NULL or when the isual is a PTR type and IntPtr.Zero</summary>
        INTERNAL PROPERTY IsNil AS LOGIC
            GET
                RETURN SELF:_usualType == __UsualType.Void .OR. ;
                (SELF:IsReferenceType .AND. SELF:_refData  == NULL) .OR. ;
                (SELF:_usualType == __UsualType.Ptr .AND. SELF:_ptrValue == IntPtr.Zero)

            END GET
        END PROPERTY

        /// <summary>This property returns the System.Type that represents the value of the usual.</summary>
        PUBLIC PROPERTY SystemType AS System.Type
            GET
                SWITCH _usualType
                CASE __UsualType.Array		; RETURN TYPEOF(ARRAY)
                CASE __UsualType.Codeblock	; RETURN TYPEOF(CODEBLOCK)
                CASE __UsualType.Date		; RETURN TYPEOF(DATE)
                CASE __UsualType.DateTime	; RETURN TYPEOF(System.DateTime)
                CASE __UsualType.Decimal	; RETURN TYPEOF(System.Decimal)
                CASE __UsualType.Float		; RETURN TYPEOF(FLOAT)
                CASE __UsualType.Int64		; RETURN TYPEOF(INT64)
                CASE __UsualType.Logic		; RETURN TYPEOF(LOGIC)
                CASE __UsualType.Long		; RETURN TYPEOF(INT)
                CASE __UsualType.Object		; RETURN TYPEOF(OBJECT)
                CASE __UsualType.Ptr		; RETURN TYPEOF(IntPtr)
                CASE __UsualType.String		; RETURN TYPEOF(STRING)
                CASE __UsualType.Symbol		; RETURN TYPEOF(SYMBOL)
                CASE __UsualType.Void		; RETURN TYPEOF(USUAL)
                OTHERWISE
                    Debug.Fail( "Unhandled data type in Usual:SystemType" )
                END SWITCH
                RETURN NULL
            END GET

        END PROPERTY

        #endregion
        #region Properties FOR the Debugger
        /// <exclude />
        PROPERTY Value AS OBJECT
            GET
                IF (_UsualType == __UsualType.Void)
                    RETURN "NIL"
                ELSE
                    RETURN __Usual.ToObject(SELF)
                ENDIF
            END GET
        END PROPERTY

        #endregion

        #region implementation IComparable<T>
        /// <include file="RTComments.xml" path="Comments/Operator/*" />
        /// <include file="RTComments.xml" path="Comments/UsualCompare/*" />
        PUBLIC METHOD CompareTo(rhs AS __Usual) AS LONG
            IF SELF:_UsualType == rhs:_UsualType
                // Compare ValueTypes
                SWITCH _UsualType
                CASE __UsualType.Date		; RETURN SELF:_dateValue:CompareTo(rhs:_dateValue)
                CASE __UsualType.DateTime	; RETURN SELF:_dateTimeValue:CompareTo(rhs:_dateTimeValue)
                CASE __UsualType.Decimal	; RETURN SELF:_decimalValue:CompareTo(rhs:_decimalValue)
                CASE __UsualType.Int64		; RETURN SELF:_i64Value:CompareTo(rhs:_i64Value)
                CASE __UsualType.Logic		; RETURN SELF:_logicValue:CompareTo(rhs:_logicValue)
                CASE __UsualType.Long		; RETURN SELF:_intValue:CompareTo(rhs:_intValue)
                CASE __UsualType.Ptr		; RETURN SELF:_ptrValue:ToInt64():CompareTo(rhs:_ptrValue:ToInt64())
                // Uses String Comparison rules
                CASE __UsualType.String
                    RETURN __StringCompare( SELF:_stringValue,  rhs:_stringValue)
                CASE __UsualType.Symbol		; RETURN __StringCompare( (STRING) SELF:_symValue, (STRING) rhs:_symValue)
                OTHERWISE					; RETURN 0
                END SWITCH
            ELSE
                // Type of LHS different from type of RHS
                SWITCH SELF:_UsualType
                CASE __UsualType.Void
                    RETURN -1
                CASE __UsualType.Date
                    // Upscale when needed to avoid overflow errors
                    SWITCH rhs:_UsualType
                    CASE __UsualType.DateTime	; RETURN _dateValue:CompareTo((DATE) rhs:_dateTimeValue)
                    CASE __UsualType.Decimal	; RETURN ((System.Decimal) (INT) _dateValue):CompareTo(rhs:_decimalValue)
                    CASE __UsualType.Float		; RETURN ((REAL8) (INT) _dateValue):CompareTo(rhs:_r8Value)
                    CASE __UsualType.Int64		; RETURN ( (INT64) (INT) _dateValue):CompareTo(rhs:_i64Value)
                    CASE __UsualType.Long		; RETURN ((INT) _dateValue):CompareTo(rhs:_intValue)
                    OTHERWISE
                        NOP	// uses comparison by type
                    END SWITCH

                CASE __UsualType.Float
                    SWITCH rhs:_usualType
                    CASE __UsualType.Date		; RETURN FLOAT{_r8Value}:CompareTo( FLOAT{(REAL8) (INT) rhs:_dateValue})
                    CASE __UsualType.Decimal	; RETURN FLOAT{_r8Value}:CompareTo( FLOAT{(REAL8) rhs:_decimalValue})
                    CASE __UsualType.Long		; RETURN FLOAT{_r8Value}:CompareTo( FLOAT{(REAL8) rhs:_intValue})
                    CASE __UsualType.Int64		; RETURN FLOAT{_r8Value}:CompareTo( FLOAT{(REAL8) rhs:_i64Value})
                    OTHERWISE                           
                        NOP	// uses comparison by type
                    END SWITCH

                CASE __UsualType.Long
                    // Upscale when needed to avoid overflow errors
                    SWITCH rhs:_usualType
                    CASE __UsualType.Date		; RETURN _intValue:CompareTo((INT) rhs:_dateValue)
                    CASE __UsualType.Int64		; RETURN ((INT64)_intValue):CompareTo(rhs:_i64Value)
                    CASE __UsualType.Float		; RETURN ((REAL8)_intValue):CompareTo(rhs:_r8Value)
                    CASE __UsualType.Decimal	; RETURN ((System.Decimal)_intValue):CompareTo(rhs:_decimalValue)
                    CASE __UsualType.Ptr	    ; RETURN _intValue:CompareTo(rhs:_ptrValue:ToInt32())
                    OTHERWISE
                        NOP	// uses comparison by type
                    END SWITCH

                CASE __UsualType.Int64
                    SWITCH rhs:_usualType
                    CASE __UsualType.Date		; RETURN _i64Value:CompareTo((INT) rhs:_dateValue)
                    CASE __UsualType.Long		; RETURN _i64Value:CompareTo( rhs:_intValue)
                    CASE __UsualType.Float		; RETURN _i64Value:CompareTo( rhs:_r8Value)
                    CASE __UsualType.Decimal	; RETURN _i64Value:CompareTo( rhs:_decimalValue)
                    CASE __UsualType.Ptr	    ; RETURN _i64Value:CompareTo( rhs:_ptrValue:ToInt64())
                    OTHERWISE
                        NOP	// uses comparison by type
                    END SWITCH

                CASE __UsualType.Decimal
                    SWITCH rhs:_usualType
                    CASE __UsualType.Date		; RETURN _decimalValue:CompareTo((INT) rhs:_dateValue)
                    CASE __UsualType.Long		; RETURN _decimalValue:CompareTo(rhs:_intValue)
                    CASE __UsualType.Float		; RETURN _decimalValue:CompareTo(rhs:_r8Value)
                    CASE __UsualType.Int64		; RETURN _decimalValue:CompareTo(rhs:_i64Value)
                    OTHERWISE
                        NOP	// uses comparison by type
                    END SWITCH
                 CASE __UsualType.Ptr
                    SWITCH rhs:_usualType
                    CASE __UsualType.Long		; RETURN (_ptrValue:ToInt32()):CompareTo(rhs:_intValue)
                    CASE __UsualType.Int64		; RETURN (_ptrValue:ToInt64()):CompareTo(rhs:_i64Value)
                    END SWITCH
                END SWITCH
            ENDIF
            IF rhs:_usualType == __UsualType.Void
                RETURN 1
            ELSEIF SELF:_usualType > rhs:_usualType
                RETURN 1
            ELSEIF SELF:_usualType < rhs:_usualType
                RETURN -1
            ENDIF
            RETURN 0

            #endregion

        #region implementation IComparable
        /// <summary>This method is needed to implement the IComparable interface.</summary>
        PUBLIC METHOD CompareTo(o AS OBJECT) AS LONG
            RETURN CompareTo((__Usual) o)
            #endregion

        #region Comparison Operators
        /// <include file="RTComments.xml" path="Comments/Operator/*" />
        /// <include file="RTComments.xml" path="Comments/UsualCompare/*" />
        STATIC OPERATOR >(lhs AS __Usual, rhs AS __Usual) AS LOGIC
            SWITCH lhs:_usualType
            CASE __UsualType.Void
                RETURN FALSE
            CASE __UsualType.Long
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN lhs:_intValue > rhs:_intValue
                CASE __UsualType.Int64		; RETURN lhs:_intValue > rhs:_i64Value
                CASE __UsualType.Float		; RETURN lhs:_intValue > rhs:_r8Value
                CASE __UsualType.Decimal	; RETURN lhs:_intValue > rhs:_decimalValue
                CASE __UsualType.Ptr	    ; RETURN lhs:_intValue > rhs:_ptrValue:ToInt32()
                OTHERWISE
                    THROW BinaryError(">", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH

            CASE __UsualType.Int64
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN lhs:_i64Value > rhs:_intValue
                CASE __UsualType.Int64		; RETURN lhs:_i64Value > rhs:_i64Value
                CASE __UsualType.Float		; RETURN lhs:_i64Value > rhs:_r8Value
                CASE __UsualType.Decimal	; RETURN lhs:_i64Value > rhs:_decimalValue
                CASE __UsualType.Ptr	    ; RETURN lhs:_i64Value > rhs:_ptrValue:ToInt64()
                OTHERWISE
                    THROW BinaryError(">", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH

            CASE __UsualType.Float
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN FLOAT{lhs:_r8Value } > FLOAT{rhs:_intValue}
                CASE __UsualType.Int64		; RETURN FLOAT{lhs:_r8Value } > FLOAT{rhs:_i64Value}
                CASE __UsualType.Float		; RETURN FLOAT{lhs:_r8Value } > FLOAT{rhs:_r8Value}
                CASE __UsualType.Decimal	; RETURN FLOAT{lhs:_r8Value } > FLOAT{(REAL8) rhs:_decimalValue}
                OTHERWISE
                    THROW BinaryError(">", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH

            CASE __UsualType.Decimal
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN lhs:_decimalValue > rhs:_intValue
                CASE __UsualType.Int64		; RETURN lhs:_decimalValue > rhs:_i64Value
                CASE __UsualType.Float		; RETURN lhs:_decimalValue > (System.Decimal) rhs:_r8Value
                CASE __UsualType.Decimal	; RETURN lhs:_decimalValue >  rhs:_decimalValue
                OTHERWISE
                    THROW BinaryError(">", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH

            CASE __UsualType.String
                IF rhs:_usualType == __UsualType.String
                    RETURN __StringCompare( lhs:_stringValue,  rhs:_stringValue) > 0
                ELSE
                    NOP // error below
                ENDIF

            CASE __UsualType.Symbol
                IF rhs:_usualType == __UsualType.Symbol
                    RETURN lhs:_symValue > rhs:_symValue
                ELSE
                    NOP // error below
                ENDIF
            CASE __UsualType.Date
                SWITCH (rhs:_usualType)
                CASE __UsualType.Date		; RETURN lhs:_dateValue > rhs:_dateValue
                CASE __UsualType.DateTime	; RETURN lhs:_dateValue > (DATE) rhs:_dateTimeValue
                OTHERWISE
                    NOP // error below
                END SWITCH
            CASE __UsualType.DateTime
                SWITCH (rhs:_usualType)
                CASE __UsualType.Date		; RETURN lhs:_dateTimeValue > (DateTime) rhs:_dateValue
                CASE __UsualType.DateTime	; RETURN lhs:_dateTimeValue > rhs:_dateTimeValue
                OTHERWISE
                    NOP // error below
                END SWITCH
            CASE __UsualType.Ptr
                SWITCH (rhs:_usualType)
                CASE __UsualType.Long	; RETURN lhs:_ptrValue:ToInt32() > rhs:_intValue
                CASE __UsualType.Int64	; RETURN lhs:_ptrValue:ToInt64() > rhs:_i64Value
                CASE __UsualType.Ptr	; RETURN lhs:_ptrValue:ToInt64() > rhs:_ptrValue:ToInt64()
                OTHERWISE
                    NOP // error below
                END SWITCH

            OTHERWISE
                NOP // error below
            END SWITCH
            THROW BinaryError(">", __CavoStr(VOErrors.ARGSINCOMPATIBLE), FALSE, lhs, rhs)

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        /// <include file="RTComments.xml" path="Comments/UsualCompare/*" />
        STATIC OPERATOR >=(lhs AS __Usual, rhs AS __Usual) AS LOGIC
            SWITCH lhs:_usualType
            CASE __UsualType.Void
                RETURN rhs:_usualType == __UsualType.Void
            CASE __UsualType.Long
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN lhs:_intValue >= rhs:_intValue
                CASE __UsualType.Int64		; RETURN lhs:_intValue >= rhs:_i64Value
                CASE __UsualType.Float		; RETURN lhs:_intValue >= rhs:_r8Value
                CASE __UsualType.Decimal	; RETURN lhs:_intValue >= rhs:_decimalValue
                CASE __UsualType.Ptr	    ; RETURN lhs:_intValue >= rhs:_ptrValue:ToInt32()
                OTHERWISE
                    THROW BinaryError(">=", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH
            CASE __UsualType.Int64
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN lhs:_i64Value >= rhs:_intValue
                CASE __UsualType.Int64		; RETURN lhs:_i64Value >= rhs:_i64Value
                CASE __UsualType.Float		; RETURN lhs:_i64Value >= rhs:_r8Value
                CASE __UsualType.Decimal	; RETURN lhs:_i64Value >= rhs:_decimalValue
                CASE __UsualType.Ptr	    ; RETURN lhs:_i64Value >= rhs:_ptrValue:ToInt64()
                OTHERWISE
                    THROW BinaryError(">=", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH
            CASE __UsualType.Float
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN FLOAT{lhs:_r8Value} >= FLOAT{ rhs:_intValue}
                CASE __UsualType.Int64		; RETURN FLOAT{lhs:_r8Value} >= FLOAT{ rhs:_i64Value}
                CASE __UsualType.Float		; RETURN FLOAT{lhs:_r8Value} >= FLOAT{ rhs:_r8Value}
                CASE __UsualType.Decimal	; RETURN FLOAT{lhs:_r8Value} >= FLOAT{ (REAL8) rhs:_decimalValue}
                OTHERWISE
                    THROW BinaryError(">=", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH

            CASE __UsualType.Decimal
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN lhs:_decimalValue >= rhs:_intValue
                CASE __UsualType.Int64		; RETURN lhs:_decimalValue >= rhs:_i64Value
                CASE __UsualType.Float		; RETURN lhs:_decimalValue >= (System.Decimal) rhs:_r8Value
                CASE __UsualType.Decimal	; RETURN lhs:_decimalValue >=  rhs:_decimalValue
                OTHERWISE
                    THROW BinaryError(">=", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH

            CASE __UsualType.String
                IF rhs:_usualType == __UsualType.String
                    RETURN __StringCompare( lhs:_stringValue,  rhs:_stringValue) >= 0
                ELSE
                    NOP // error below
                ENDIF

            CASE __UsualType.Symbol
                IF rhs:_usualType == __UsualType.Symbol
                    RETURN lhs:_symValue >= rhs:_symValue
                ELSE
                    NOP // error below
                ENDIF
            CASE __UsualType.Date
                SWITCH (rhs:_usualType)
                CASE __UsualType.Date		; RETURN lhs:_dateValue		>= rhs:_dateValue
                CASE __UsualType.DateTime	; RETURN lhs:_dateTimeValue >= rhs:_dateTimeValue
                OTHERWISE
                    NOP // error below
                END SWITCH
            CASE __UsualType.DateTime
                SWITCH (rhs:_usualType)
                CASE __UsualType.Date		; RETURN lhs:_dateTimeValue	>=  (DateTime) rhs:_dateValue
                CASE __UsualType.DateTime	; RETURN lhs:_dateTimeValue >=  rhs:_dateTimeValue
                OTHERWISE
                    NOP // error below
                END SWITCH
            CASE __UsualType.Ptr
                SWITCH (rhs:_usualType)
                CASE __UsualType.Long	; RETURN lhs:_ptrValue:ToInt32() >= rhs:_intValue
                CASE __UsualType.Int64	; RETURN lhs:_ptrValue:ToInt64() >= rhs:_i64Value
                CASE __UsualType.Ptr	; RETURN lhs:_ptrValue:ToInt64() >= rhs:_ptrValue:ToInt64()
                OTHERWISE
                    NOP // error below
                END SWITCH
            OTHERWISE
                THROW BinaryError(">=", __CavoStr(VOErrors.ARGSINCOMPATIBLE), TRUE, lhs, rhs)
            END SWITCH
            THROW BinaryError(">=", __CavoStr(VOErrors.ARGSINCOMPATIBLE), FALSE, lhs, rhs)

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        /// <include file="RTComments.xml" path="Comments/UsualCompare/*" />
        STATIC OPERATOR <(lhs AS __Usual, rhs AS __Usual) AS LOGIC
            SWITCH lhs:_usualType
            CASE __UsualType.Void
                RETURN FALSE
            CASE __UsualType.Long
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN lhs:_intValue < rhs:_intValue
                CASE __UsualType.Int64		; RETURN lhs:_intValue < rhs:_i64Value
                CASE __UsualType.Float		; RETURN lhs:_intValue < rhs:_r8Value
                CASE __UsualType.Decimal	; RETURN lhs:_intValue < rhs:_decimalValue
                CASE __UsualType.Ptr	    ; RETURN lhs:_intValue < rhs:_ptrValue:ToInt32()
                OTHERWISE
                    THROW BinaryError("<", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH
            CASE __UsualType.Int64
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN lhs:_i64Value < rhs:_intValue
                CASE __UsualType.Int64		; RETURN lhs:_i64Value < rhs:_i64Value
                CASE __UsualType.Float		; RETURN lhs:_i64Value < rhs:_r8Value
                CASE __UsualType.Decimal	; RETURN lhs:_i64Value < rhs:_decimalValue
                CASE __UsualType.Ptr	    ; RETURN lhs:_i64Value < rhs:_ptrValue:ToInt64()
                OTHERWISE
                    THROW BinaryError("<", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH
            CASE __UsualType.Float
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN FLOAT{lhs:_r8Value} < FLOAT{rhs:_intValue              }
                CASE __UsualType.Int64		; RETURN FLOAT{lhs:_r8Value} < FLOAT{rhs:_i64Value              }
                CASE __UsualType.Float		; RETURN FLOAT{lhs:_r8Value} < FLOAT{rhs:_r8Value               }
                CASE __UsualType.Decimal	; RETURN FLOAT{lhs:_r8Value} < FLOAT{(REAL8) rhs:_decimalValue  }
                OTHERWISE
                    THROW BinaryError("<", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH

            CASE __UsualType.Decimal
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN lhs:_decimalValue < rhs:_intValue
                CASE __UsualType.Int64		; RETURN lhs:_decimalValue < rhs:_i64Value
                CASE __UsualType.Float		; RETURN lhs:_decimalValue < (System.Decimal) rhs:_r8Value
                CASE __UsualType.Decimal	; RETURN lhs:_decimalValue <  rhs:_decimalValue
                OTHERWISE
                    THROW BinaryError("<", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH

            CASE __UsualType.String
                IF rhs:_usualType == __UsualType.String
                    RETURN __StringCompare( lhs:_stringValue,  rhs:_stringValue) < 0
                ELSE
                    NOP // error below
                ENDIF

            CASE __UsualType.Symbol
                IF rhs:_usualType == __UsualType.Symbol
                    RETURN lhs:_symValue < rhs:_symValue
                ELSE
                    NOP // error below
                ENDIF
            CASE __UsualType.Date
                SWITCH (rhs:_usualType)
                CASE __UsualType.Date		; RETURN lhs:_dateValue	< rhs:_dateValue
                CASE __UsualType.DateTime	; RETURN lhs:_dateValue < (DATE) rhs:_dateTimeValue
                OTHERWISE
                    NOP // error below
                END SWITCH
            CASE __UsualType.DateTime
                SWITCH (rhs:_usualType)
                CASE __UsualType.Date		; RETURN lhs:_dateTimeValue	<  (DateTime) rhs:_dateValue
                CASE __UsualType.DateTime	; RETURN lhs:_dateTimeValue <  rhs:_dateTimeValue
                OTHERWISE
                    NOP // error below
                END SWITCH
           CASE __UsualType.Ptr
                SWITCH (rhs:_usualType)
                CASE __UsualType.Long	; RETURN lhs:_ptrValue:ToInt32() < rhs:_intValue
                CASE __UsualType.Int64	; RETURN lhs:_ptrValue:ToInt64() < rhs:_i64Value
                CASE __UsualType.Ptr	; RETURN lhs:_ptrValue:ToInt64() < rhs:_ptrValue:ToInt64()
                OTHERWISE
                    NOP // error below
                END SWITCH
 
            OTHERWISE
                THROW BinaryError("<", __CavoStr(VOErrors.ARGSINCOMPATIBLE), TRUE, lhs, rhs)
            END SWITCH
            THROW BinaryError("<", __CavoStr(VOErrors.ARGSINCOMPATIBLE), FALSE, lhs, rhs)

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        /// <include file="RTComments.xml" path="Comments/UsualCompare/*" />
        STATIC OPERATOR <=(lhs AS __Usual, rhs AS __Usual) AS LOGIC
            SWITCH lhs:_usualType
            CASE __UsualType.Void
                RETURN rhs:_usualType == __UsualType.Void
            CASE __UsualType.Long
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN lhs:_intValue <= rhs:_intValue
                CASE __UsualType.Int64		; RETURN lhs:_intValue <= rhs:_i64Value
                CASE __UsualType.Float		; RETURN lhs:_intValue <= rhs:_r8Value
                CASE __UsualType.Decimal	; RETURN lhs:_intValue <= rhs:_decimalValue
                CASE __UsualType.Ptr	    ; RETURN lhs:_intValue <= rhs:_ptrValue:ToInt32()
                OTHERWISE
                    THROW BinaryError("<=", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH
            CASE __UsualType.Int64
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN lhs:_i64Value <= rhs:_intValue
                CASE __UsualType.Int64		; RETURN lhs:_i64Value <= rhs:_i64Value
                CASE __UsualType.Float		; RETURN lhs:_i64Value <= rhs:_r8Value
                CASE __UsualType.Decimal	; RETURN lhs:_i64Value <= rhs:_decimalValue
                CASE __UsualType.Ptr	    ; RETURN lhs:_i64Value <= rhs:_ptrValue:ToInt64()
                OTHERWISE
                    THROW BinaryError("<=", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH
            CASE __UsualType.Float
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN FLOAT{lhs:_r8Value} <= FLOAT{rhs:_intValue             } 
                CASE __UsualType.Int64		; RETURN FLOAT{lhs:_r8Value} <= FLOAT{rhs:_i64Value             } 
                CASE __UsualType.Float		; RETURN FLOAT{lhs:_r8Value} <= FLOAT{rhs:_r8Value              } 
                CASE __UsualType.Decimal	; RETURN FLOAT{lhs:_r8Value} <= FLOAT{(REAL8) rhs:_decimalValue } 
                OTHERWISE
                    THROW BinaryError("<=", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH

            CASE __UsualType.Decimal
                SWITCH rhs:_usualType
                CASE __UsualType.Long		; RETURN lhs:_decimalValue <= rhs:_intValue
                CASE __UsualType.Int64		; RETURN lhs:_decimalValue <= rhs:_i64Value
                CASE __UsualType.Float		; RETURN lhs:_decimalValue <= (System.Decimal) rhs:_r8Value
                CASE __UsualType.Decimal	; RETURN lhs:_decimalValue <=  rhs:_decimalValue
                OTHERWISE
                    THROW BinaryError("<=", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)
                END SWITCH

            CASE __UsualType.String
                IF rhs:_usualType == __UsualType.String
                    RETURN __StringCompare( lhs:_stringValue,  rhs:_stringValue) <= 0
                ELSE
                    NOP // error below
                ENDIF

            CASE __UsualType.Symbol
                IF rhs:_usualType == __UsualType.Symbol
                    RETURN lhs:_symValue <= rhs:_symValue
                ELSE
                    NOP // error below
                ENDIF
            CASE __UsualType.Date
                SWITCH (rhs:_usualType)
                CASE __UsualType.Date		; RETURN lhs:_dateValue	<= rhs:_dateValue
                CASE __UsualType.DateTime	; RETURN lhs:_dateValue <= (DATE) rhs:_dateTimeValue
                OTHERWISE
                    NOP // error below
                END SWITCH
            CASE __UsualType.DateTime
                SWITCH (rhs:_usualType)
                CASE __UsualType.Date		; RETURN lhs:_dateTimeValue	<=  (DateTime) rhs:_dateValue
                CASE __UsualType.DateTime	; RETURN lhs:_dateTimeValue <=  rhs:_dateTimeValue
                OTHERWISE
                    NOP // error below
                END SWITCH
           CASE __UsualType.Ptr
                SWITCH (rhs:_usualType)
                CASE __UsualType.Long	; RETURN lhs:_ptrValue:ToInt32() <= rhs:_intValue
                CASE __UsualType.Int64	; RETURN lhs:_ptrValue:ToInt64() <= rhs:_i64Value
                CASE __UsualType.Ptr	; RETURN lhs:_ptrValue:ToInt64() <= rhs:_ptrValue:ToInt64()
                OTHERWISE
                    NOP // error below
                END SWITCH
 

            OTHERWISE
                THROW BinaryError("<=", __CavoStr(VOErrors.ARGSINCOMPATIBLE), TRUE, lhs, rhs)
            END SWITCH
            THROW BinaryError("<=", __CavoStr(VOErrors.ARGSINCOMPATIBLE), FALSE, lhs, rhs)
            #endregion

        #region IEquatable<T>
        /// <inheritdoc />
        PUBLIC METHOD Equals(u AS __Usual) AS LOGIC
            IF u:IsNil
                RETURN SELF:IsNil
            ENDIF
            RETURN UsualEquals(u, "Usual.Equals()")

            #endregion
        #region Operators FOR Equality
        /// <inheritdoc />
        PUBLIC OVERRIDE METHOD Equals(obj AS OBJECT) AS LOGIC
            IF obj == NULL
                RETURN SELF:IsNil
            ENDIF
            RETURN UsualEquals((USUAL) obj, "Usual.Equals()")


            /// <inheritdoc />
        PUBLIC OVERRIDE METHOD GetHashCode() AS INT
            LOCAL oValue AS OBJECT
            oValue := SELF:Value
            IF oValue == NULL
                RETURN 0
            ENDIF
            RETURN oValue:GetHashCode()

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR ==(lhs AS __Usual, rhs AS __Usual) AS LOGIC
            RETURN lhs:UsualEquals(rhs, "==")

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR !=(lhs AS __Usual, rhs AS __Usual) AS LOGIC
            IF lhs:_usualType == __UsualType.String .AND. rhs:_usualType == __UsualType.String
                RETURN ! __StringEquals(  lhs:_stringValue, rhs:_stringValue)
            ELSE
                RETURN ! lhs:UsualEquals(rhs, "!=")
            ENDIF


        INTERNAL METHOD UsualEquals( rhs AS __Usual, op AS STRING) AS LOGIC
            IF rhs:IsNil
                RETURN SELF:IsNil
            ENDIF
            SWITCH SELF:_usualType
                CASE __UsualType.Object
                    IF rhs:_usualType == __UsualType.Object
                        RETURN SELF:_refData == rhs:_refData
                    ELSE
                        NOP // error below
                    ENDIF

                CASE __UsualType.Void
                    RETURN rhs:_usualType == __UsualType.Void

                CASE __UsualType.Long
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN SELF:_intValue == rhs:_intValue
                        CASE __UsualType.Int64		; RETURN (INT64) SELF:_intValue == rhs:_i64Value	// cast lhs to int64 to avoid overflow
                        CASE __UsualType.Float		; RETURN (REAL8) SELF:_intValue == rhs:_r8Value // cast lhs to real8 to avoid overflow
                        CASE __UsualType.Decimal	; RETURN (System.Decimal) SELF:_intValue == rhs:_decimalValue	// cast lhs to decimal to avoid overflow
                        CASE __UsualType.Logic		; RETURN rhs:_logicValue == (SELF:_intValue <> 0)
                        CASE __UsualType.Ptr        ; RETURN rhs:_ptrValue:ToInt32() == SELF:_intValue
                        OTHERWISE
                            NOP // error below
                        END SWITCH

                CASE __UsualType.Int64
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN _i64Value == (INT64) rhs:_intValue
                        CASE __UsualType.Int64		; RETURN _i64Value == rhs:_i64Value
                        CASE __UsualType.Float		; RETURN  FLOAT{(REAL8) _i64Value} == FLOAT{rhs:_r8Value}
                        CASE __UsualType.Decimal	; RETURN _i64Value == rhs:_decimalValue
                        CASE __UsualType.Logic		; RETURN rhs:_logicValue == (SELF:_i64Value <> 0)
                        CASE __UsualType.Ptr        ; RETURN rhs:_ptrValue:ToInt64() == SELF:_i64Value
                        OTHERWISE
                            NOP // error below
                        END SWITCH

                CASE __UsualType.Float
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN FLOAT{_r8Value} == FLOAT{(REAL8) rhs:_intValue}
                        CASE __UsualType.Int64		; RETURN FLOAT{_r8Value} == FLOAT{(REAL8) rhs:_i64Value}
                        CASE __UsualType.Float		; RETURN FLOAT{_r8Value} == FLOAT{ rhs:_r8Value}
                        CASE __UsualType.Decimal	; RETURN FLOAT{_r8Value} == FLOAT{ (REAL8) rhs:_decimalValue}
                        OTHERWISE
                            NOP // error below
                    END SWITCH

                CASE __UsualType.Decimal
                    SWITCH rhs:_usualType
                    CASE __UsualType.Long		; RETURN SELF:_decimalValue == rhs:_intValue
                        CASE __UsualType.Int64		; RETURN SELF:_decimalValue == rhs:_i64Value
                        CASE __UsualType.Float		; RETURN SELF:_decimalValue == (System.Decimal) rhs:_r8Value
                        CASE __UsualType.Decimal	; RETURN SELF:_decimalValue == rhs:_decimalValue
                        OTHERWISE
                            NOP // error below
                        END SWITCH

                CASE __UsualType.Logic
                    SWITCH rhs:_usualType
                    CASE __UsualType.Logic		; RETURN SELF:_logicValue == rhs:_logicValue
                        CASE __UsualType.Long		; RETURN SELF:_logicValue == (rhs:_intValue <> 0)
                        CASE __UsualType.Int64		; RETURN SELF:_logicValue == (rhs:_i64Value <> 0)
                        CASE __UsualType.Decimal	; RETURN SELF:_logicValue == (rhs:_decimalValue <> 0)
                        OTHERWISE
                            NOP // error below
                        END SWITCH

                CASE __UsualType.DATE
                    SWITCH rhs:_usualType
                        CASE __UsualType.DATE		; RETURN SELF:_dateValue == rhs:_dateValue
                        CASE __UsualType.DateTime	; RETURN SELF:_dateValue == (DATE) rhs:_dateTimeValue
                        OTHERWISE
                            NOP // error below
                    END SWITCH

                CASE __UsualType.DateTime
                    SWITCH rhs:_usualType
                        CASE __UsualType.DateTime	; RETURN SELF:_dateTimeValue == rhs:_dateTimeValue
                        CASE __UsualType.DATE		; RETURN SELF:_dateTimeValue == (DateTime) rhs:_dateValue
                        OTHERWISE
                            NOP // error below
                    END SWITCH

                CASE __UsualType.String
                    SWITCH rhs:_usualType
                        CASE __UsualType.String		; RETURN SELF:_stringValue == rhs:_stringValue
                        CASE __UsualType.Symbol		; RETURN SELF:_stringValue == rhs:_symValue
                        OTHERWISE
                            NOP // error below
                    END SWITCH

                CASE __UsualType.Array
                    SWITCH rhs:_usualType
                        CASE __UsualType.Array		; RETURN SELF:_refData == rhs:_refData
                        OTHERWISE
                            NOP // error below
                    END SWITCH

                CASE __UsualType.Codeblock
                    SWITCH rhs:_usualType
                    CASE __UsualType.Codeblock	; RETURN SELF:_refData == rhs:_refData
                        OTHERWISE
                            NOP // error below
                        END SWITCH

                CASE __UsualType.Ptr
                    SWITCH rhs:_usualType
                        CASE __UsualType.Ptr		; RETURN SELF:_ptrValue == rhs:_ptrValue
                        CASE __UsualType.Long		; RETURN SELF:_ptrValue:ToInt32() == rhs:_intValue
                        CASE __UsualType.Int64		; RETURN SELF:_ptrValue:ToInt64() == rhs:_i64Value
                        OTHERWISE
                            NOP // error below
                    END SWITCH

                CASE __UsualType.Symbol
                    SWITCH rhs:_usualType
                        CASE __UsualType.Symbol		; RETURN SELF:_symValue == rhs:_symValue
                        CASE __UsualType.String		; RETURN SELF:_symValue == rhs:_stringValue
                        OTHERWISE
                            NOP // error below
                    END SWITCH
                OTHERWISE
                    THROW BinaryError(op, __CavoStr(VOErrors.ARGSINCOMPATIBLE), TRUE, SELF, rhs)

            END SWITCH
            THROW BinaryError(op, __CavoStr(VOErrors.ARGSINCOMPATIBLE), FALSE, SELF, rhs)

            #endregion

        #region Unary Operators
        /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR !(u AS __Usual) AS LOGIC
            IF u:_usualType == __UsualType.Logic
                RETURN !u:_logicValue
            ENDIF
            THROW UnaryError("!", u)

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR ~(u AS __Usual) AS __Usual
            IF u:_usualType == __UsualType.Long
                RETURN ~u:_intValue
            ENDIF
            IF u:_usualType == __UsualType.Int64
                RETURN ~u:_i64Value
            ENDIF
            THROW UnaryError("~", u)

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR -(u AS __Usual) AS __Usual
            SWITCH u:_usualType
                CASE __UsualType.LONG		; RETURN -u:_intValue
                CASE __UsualType.Int64		; RETURN -u:_i64Value
                CASE __UsualType.Float		; RETURN -u:_floatValue
                CASE __UsualType.Decimal	; RETURN -u:_decimalValue
                OTHERWISE
                    THROW UnaryError("-", u)
                END SWITCH

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR +(u AS __Usual) AS __Usual
            SWITCH u:_usualType
                CASE __UsualType.LONG		; RETURN u:_intValue
                CASE __UsualType.Int64		; RETURN u:_i64Value
                CASE __UsualType.Float		; RETURN u:_floatValue
                CASE __UsualType.Decimal	; RETURN u:_decimalValue
                OTHERWISE
                    THROW UnaryError("+", u)
                END SWITCH

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR --(u AS __Usual) AS __Usual
            SWITCH u:_usualType
                CASE __UsualType.LONG		; RETURN u:_intValue - 1
                CASE __UsualType.Int64		; RETURN u:_i64Value - 1
                CASE __UsualType.Float		; RETURN u:_floatValue -1
                CASE __UsualType.Decimal	; RETURN u:_decimalValue - 1
                OTHERWISE
                    THROW UnaryError("--", u)
                END SWITCH

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR ++(u AS __Usual) AS __Usual
            SWITCH u:_usualType
                CASE __UsualType.LONG		; RETURN u:_intValue + 1
             CASE __UsualType.Int64		; RETURN u:_i64Value + 1
                CASE __UsualType.Float		; RETURN u:_floatValue +1
                CASE __UsualType.Decimal	; RETURN u:_decimalValue + 1
                OTHERWISE
                    THROW UnaryError("++", u)
                END SWITCH

            #endregion
        #region Numeric Operators FOR ADD, Delete etc (also FOR strings)

        /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR +(lhs AS __Usual, rhs AS __Usual) AS __Usual
            SWITCH lhs:_usualType
                CASE __UsualType.Long
                    SWITCH rhs:_usualType
                     CASE __UsualType.Long		; RETURN lhs:_intValue + rhs:_intValue
                        CASE __UsualType.Int64		; RETURN lhs:_intValue + rhs:_i64Value
                        CASE __UsualType.Float		; RETURN lhs:_intValue + rhs:_r8Value
                        CASE __UsualType.Decimal	; RETURN lhs:_intValue + rhs:_decimalValue
                        OTHERWISE					; NOP // error below
                    END SWITCH

                CASE __UsualType.Int64
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN lhs:_i64Value + rhs:_intValue
                        CASE __UsualType.Int64		; RETURN lhs:_i64Value + rhs:_i64Value
                        CASE __UsualType.Float		; RETURN lhs:_i64Value + rhs:_r8Value
                        CASE __UsualType.Decimal	; RETURN lhs:_i64Value + rhs:_decimalValue
                        OTHERWISE					; NOP // error below
                    END SWITCH

                CASE __UsualType.Float
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN FLOAT{lhs:_r8Value + rhs:_intValue, lhs:_width, lhs:_decimals}
                        CASE __UsualType.Int64		; RETURN FLOAT{lhs:_r8Value + rhs:_i64Value, lhs:_width, lhs:_decimals}
                        CASE __UsualType.Float		; RETURN FLOAT{lhs:_r8Value + rhs:_r8Value, lhs:_width, lhs:_decimals}
                        CASE __UsualType.Decimal	; RETURN FLOAT{lhs:_r8Value + (REAL8) rhs:_decimalValue, lhs:_width, lhs:_decimals}
                        OTHERWISE					; NOP // error below
                    END SWITCH

                CASE __UsualType.Decimal
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN lhs:_decimalValue + rhs:_intValue
                        CASE __UsualType.Int64		; RETURN lhs:_decimalValue + rhs:_i64Value
                        CASE __UsualType.Float		; RETURN lhs:_decimalValue + (System.Decimal) rhs:_r8Value
                        CASE __UsualType.Decimal	; RETURN lhs:_decimalValue + rhs:_decimalValue
                        OTHERWISE					; NOP // error below
                    END SWITCH

                CASE __UsualType.String
                    SWITCH rhs:_usualType
                        CASE __UsualType.String		; RETURN lhs:_stringValue+ rhs:_stringValue
                        OTHERWISE
                            THROW BinaryError("+", __CavoStr(VOErrors.ARGNOTSTRING), FALSE, lhs, rhs)
                    END SWITCH
                CASE __UsualType.Date
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN lhs:_dateValue + rhs:_intValue
                        CASE __UsualType.Int64	; RETURN lhs:_dateValue + rhs:_i64Value
                        CASE __UsualType.Float	; RETURN lhs:_dateValue + rhs:_r8Value
                            // Note We can't add dates, but we can subtract dates
                        OTHERWISE
                            THROW BinaryError("+", __CavoStr(VOErrors.DATE_ADD), FALSE, lhs, rhs)
                    END SWITCH
                CASE __UsualType.DateTime
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN lhs:_dateTimeValue:Add( TimeSpan.FromDays(rhs:_intValue ))
                        CASE __UsualType.Int64	; RETURN lhs:_dateTimeValue:Add(TimeSpan.FromDays(rhs:_i64Value))
                        CASE __UsualType.Float	; RETURN lhs:_dateTimeValue:Add(TimeSpan.FromDays(rhs:_r8Value))
                            // Note We can't add dates, but we can subtract dates
                        OTHERWISE
                            THROW BinaryError("+", __CavoStr(VOErrors.DATE_ADD), FALSE, lhs, rhs)
                    END SWITCH

                OTHERWISE
                    THROW BinaryError("+", __CavoStr(VOErrors.ARGSINCOMPATIBLE), TRUE, lhs, rhs)
            END SWITCH
            THROW BinaryError("+", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR -(lhs AS __Usual, rhs AS __Usual) AS __Usual
            SWITCH lhs:_usualType
                CASE __UsualType.Long
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN lhs:_intValue - rhs:_intValue
                        CASE __UsualType.Int64		; RETURN lhs:_intValue - rhs:_i64Value
                        CASE __UsualType.Float		; RETURN lhs:_intValue - rhs:_r8Value
                        CASE __UsualType.Decimal	; RETURN lhs:_intValue - rhs:_decimalValue
                        OTHERWISE					; NOP // error below
                    END SWITCH
                CASE __UsualType.Int64
                    SWITCH rhs:_usualType
                    CASE __UsualType.Long		; RETURN lhs:_i64Value - rhs:_intValue
                        CASE __UsualType.Int64		; RETURN lhs:_i64Value - rhs:_i64Value
                        CASE __UsualType.Float		; RETURN lhs:_i64Value - rhs:_r8Value
                        CASE __UsualType.Decimal	; RETURN lhs:_i64Value - rhs:_decimalValue
                        OTHERWISE					; NOP // error below
                        END SWITCH
                CASE __UsualType.Float
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN FLOAT{lhs:_r8Value - rhs:_intValue ,lhs:_width, lhs:_decimals}
                        CASE __UsualType.Int64		; RETURN FLOAT{lhs:_r8Value - rhs:_i64Value ,lhs:_width, lhs:_decimals}
                        CASE __UsualType.Float		; RETURN FLOAT{lhs:_r8Value - rhs:_r8Value	,lhs:_width, lhs:_decimals}
                        CASE __UsualType.Decimal	; RETURN FLOAT{lhs:_r8Value - (REAL8) rhs:_decimalValue ,lhs:_width, lhs:_decimals}
                        OTHERWISE					; NOP // error below
                    END SWITCH


                CASE __UsualType.Decimal
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN lhs:_decimalValue - rhs:_intValue
                        CASE __UsualType.Int64		; RETURN lhs:_decimalValue - rhs:_i64Value
                        CASE __UsualType.Float		; RETURN lhs:_decimalValue - (System.Decimal) rhs:_r8Value
                        CASE __UsualType.Decimal	; RETURN lhs:_decimalValue - rhs:_decimalValue
                        OTHERWISE					; NOP // error below
                    END SWITCH

                CASE __UsualType.String
                    SWITCH rhs:_usualType
                    CASE __UsualType.String		; RETURN CompilerServices.StringSubtract(lhs, rhs)
                        OTHERWISE					; THROW BinaryError("-", __CavoStr(VOErrors.ARGNOTSTRING), FALSE, lhs, rhs)
                    END SWITCH
                CASE __UsualType.Date
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN lhs:_dateValue - rhs:_intValue
                        CASE __UsualType.Int64		; RETURN lhs:_dateValue - rhs:_i64Value
                        CASE __UsualType.Float		; RETURN lhs:_dateValue - rhs:_r8Value
                        CASE __UsualType.Date			; RETURN lhs:_dateValue - rhs:_dateValue
                        CASE __UsualType.DateTime		; RETURN lhs:_dateValue - (DATE) rhs:_dateTimeValue
                        OTHERWISE					; THROW BinaryError("+", __CavoStr(VOErrors.DATE_SUBTRACT), FALSE, lhs, rhs)
                    END SWITCH

                CASE __UsualType.DateTime
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long			; RETURN lhs:_dateTimeValue:Subtract(TimeSpan{rhs:_intValue,0,0,0})
                        CASE __UsualType.Int64		; RETURN lhs:_dateTimeValue:Subtract( TimeSpan{(INT)rhs:_i64Value,0,0,0})
                        CASE __UsualType.Float		; RETURN lhs:_dateTimeValue:Subtract( TimeSpan{(INT)rhs:_r8Value,0,0,0})
                        CASE __UsualType.Date			; RETURN lhs:_dateTimeValue:Subtract((DateTime) rhs:_dateValue):Days
                        CASE __UsualType.DateTime		; RETURN lhs:_dateTimeValue:Subtract( rhs:_dateTimeValue):Days
                        OTHERWISE					; THROW BinaryError("+", __CavoStr(VOErrors.DATE_SUBTRACT), FALSE, lhs, rhs)
                    END SWITCH

                OTHERWISE
                    THROW BinaryError("-", __CavoStr(VOErrors.ARGSINCOMPATIBLE), TRUE, lhs, rhs)
            END SWITCH
            THROW BinaryError("-", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR /(lhs AS __Usual, rhs AS __Usual) AS __Usual

            SWITCH lhs:_usualType

                CASE __UsualType.Long
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long
                            LOCAL result AS INT
                            LOCAL remainder AS INT
                            result := Math.DivRem(lhs:_intValue, rhs:_intValue, OUT remainder)
                            IF remainder == 0
                                RETURN result
                            ELSE
                                RETURN (FLOAT)lhs:_intValue / (FLOAT)rhs:_intValue
                            ENDIF
                        CASE __UsualType.Int64
                            LOCAL result AS INT64
                            LOCAL remainder AS INT64
                            result := Math.DivRem((INT64) lhs:_intValue, rhs:_i64Value, OUT remainder)
                            IF remainder == 0
                                RETURN result
                            ELSE
                                RETURN (FLOAT)lhs:_intValue / (FLOAT)rhs:_i64Value
                            ENDIF
                        CASE __UsualType.Float
                            RETURN FLOAT{lhs:_intValue / rhs:_r8Value, rhs:_width, rhs:_decimals}

                        CASE __UsualType.Decimal
                            LOCAL result AS INT64
                            LOCAL remainder AS INT64
                            result := Math.DivRem((INT64) lhs:_intValue, (INT64) rhs:_decimalValue, OUT remainder)
                            IF remainder == 0
                                RETURN result
                            ELSE
                                RETURN lhs:_intValue / rhs:_decimalValue
                            ENDIF
                        OTHERWISE
                            NOP // error below
                    END SWITCH

                CASE __UsualType.Int64
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long
                            LOCAL result AS INT64
                            LOCAL remainder AS INT64
                            result := Math.DivRem(lhs:_i64Value, rhs:_intValue, OUT remainder)
                            IF remainder == 0
                                RETURN result
                            ELSE
                                RETURN (FLOAT)lhs:_i64Value / (FLOAT)rhs:_intValue
                            ENDIF
                        CASE __UsualType.Int64
                            LOCAL result AS INT64
                            LOCAL remainder AS INT64
                            result := Math.DivRem( lhs:_i64Value, rhs:_i64Value, OUT remainder)
                            IF remainder == 0
                                RETURN result
                            ELSE
                                RETURN (FLOAT)lhs:_i64Value / (FLOAT)rhs:_i64Value
                            ENDIF
                        CASE __UsualType.Float
                            RETURN FLOAT{lhs:_i64Value / rhs:_r8Value, rhs:_width, rhs:_decimals}

                        CASE __UsualType.Decimal
                            LOCAL result AS INT64
                            LOCAL remainder AS INT64
                            result := Math.DivRem(lhs:_i64Value, (INT64) rhs:_decimalValue, OUT remainder)
                            IF remainder == 0
                                RETURN result
                            ELSE
                                RETURN lhs:_i64Value / rhs:_decimalValue
                            ENDIF
                        OTHERWISE
                            NOP // error below
                    END SWITCH

                CASE __UsualType.Float
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN FLOAT{lhs:_r8Value / rhs:_intValue, lhs:_width, lhs:_decimals}
                        CASE __UsualType.Int64		; RETURN FLOAT{lhs:_r8Value / rhs:_i64Value, lhs:_width, lhs:_decimals}
                        CASE __UsualType.Float		; RETURN FLOAT{lhs:_r8Value / rhs:_r8Value, Math.Max(lhs:_width,rhs:_width), lhs:_decimals+ rhs:_decimals}
                        CASE __UsualType.Decimal	; RETURN FLOAT{lhs:_r8Value / (REAL8) rhs:_decimalValue, lhs:_width, lhs:_decimals}
                        OTHERWISE					; NOP // error below
                    END SWITCH

                CASE __UsualType.Decimal
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN lhs:_decimalValue / rhs:_intValue
                        CASE __UsualType.Int64		; RETURN lhs:_decimalValue / rhs:_i64Value
                        CASE __UsualType.Float		; RETURN lhs:_decimalValue / (System.Decimal) rhs:_r8Value
                        CASE __UsualType.Decimal	; RETURN lhs:_decimalValue / rhs:_decimalValue
                        OTHERWISE					; NOP // error below
                    END SWITCH

                OTHERWISE
                    THROW BinaryError("/", __CavoStr(VOErrors.ARGSINCOMPATIBLE), TRUE, lhs, rhs)
            END SWITCH
            THROW BinaryError("/", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR %(lhs AS __Usual, rhs AS __Usual) AS __Usual
            SWITCH lhs:_usualType
                CASE __UsualType.Long
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN lhs:_intValue % rhs:_intValue
                        CASE __UsualType.Int64		; RETURN lhs:_intValue % rhs:_i64Value
                        CASE __UsualType.Float		; RETURN FLOAT{lhs:_intValue % rhs:_r8Value, rhs:_width, rhs:_decimals}
                        CASE __UsualType.Decimal	; RETURN lhs:_intValue % rhs:_decimalValue
                        OTHERWISE					; NOP // error below
                    END SWITCH

                CASE __UsualType.Int64
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN lhs:_i64Value % rhs:_intValue
                        CASE __UsualType.Int64		; RETURN lhs:_i64Value % rhs:_i64Value
                        CASE __UsualType.Float		; RETURN FLOAT{lhs:_i64Value % rhs:_r8Value, rhs:_width, rhs:_decimals}
                        CASE __UsualType.Decimal	; RETURN lhs:_i64Value % rhs:_decimalValue
                        OTHERWISE					; NOP // error below
                     END SWITCH

                CASE __UsualType.Float
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN FLOAT{lhs:_r8Value % rhs:_intValue, lhs:_width, lhs:_decimals}
                        CASE __UsualType.Int64		; RETURN FLOAT{lhs:_r8Value % rhs:_i64Value, lhs:_width, lhs:_decimals}
                        CASE __UsualType.Float		; RETURN FLOAT{lhs:_r8Value % rhs:_r8Value, Math.Max(lhs:_width,rhs:_width), lhs:_decimals+ rhs:_decimals}
                        CASE __UsualType.Decimal	; RETURN FLOAT{lhs:_r8Value % (REAL8) rhs:_decimalValue, lhs:_width, lhs:_decimals}
                        OTHERWISE					; NOP // error below
                    END SWITCH

                CASE __UsualType.Decimal
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN lhs:_decimalValue % rhs:_intValue
                        CASE __UsualType.Int64		; RETURN lhs:_decimalValue % rhs:_i64Value
                        CASE __UsualType.Float		; RETURN lhs:_decimalValue % (System.Decimal) rhs:_r8Value
                        CASE __UsualType.Decimal	; RETURN lhs:_decimalValue %  rhs:_decimalValue
                        OTHERWISE					; NOP // error below
                    END SWITCH


                OTHERWISE
                    THROW BinaryError("%", __CavoStr(VOErrors.ARGSINCOMPATIBLE), TRUE, lhs, rhs)
            END SWITCH
            THROW BinaryError("%", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR *(lhs AS __Usual, rhs AS __Usual) AS __Usual
            SWITCH lhs:_usualType
                CASE __UsualType.Long
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN lhs:_intValue * rhs:_intValue
                        CASE __UsualType.Int64		; RETURN lhs:_intValue * rhs:_i64Value
                        CASE __UsualType.Float		; RETURN FLOAT{lhs:_intValue * rhs:_r8Value, rhs:_width, rhs:_decimals}
                        CASE __UsualType.Decimal	; RETURN lhs:_intValue * rhs:_decimalValue
                        OTHERWISE					; NOP // error below
                    END SWITCH

                CASE __UsualType.Int64
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN lhs:_i64Value * rhs:_intValue
                        CASE __UsualType.Int64		; RETURN lhs:_i64Value * rhs:_i64Value
                        CASE __UsualType.Float		; RETURN FLOAT{lhs:_i64Value * rhs:_r8Value, rhs:_width, rhs:_decimals}
                        CASE __UsualType.Decimal	; RETURN lhs:_i64Value * rhs:_decimalValue
                        OTHERWISE					; NOP // error below
                    END SWITCH

                CASE __UsualType.Float
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN FLOAT{lhs:_r8Value * rhs:_intValue, lhs:_width, lhs:_decimals}
                        CASE __UsualType.Int64		; RETURN FLOAT{lhs:_r8Value * rhs:_i64Value, lhs:_width, lhs:_decimals}
                        CASE __UsualType.Float		; RETURN FLOAT{lhs:_r8Value * rhs:_r8Value, Math.Max(lhs:_width,rhs:_width), lhs:_decimals+ rhs:_decimals}
                        CASE __UsualType.Decimal	; RETURN FLOAT{lhs:_r8Value * (REAL8) rhs:_decimalValue, lhs:_width, lhs:_decimals}
                        OTHERWISE					; NOP // error below
                    END SWITCH

                CASE __UsualType.Decimal
                    SWITCH rhs:_usualType
                        CASE __UsualType.Long		; RETURN lhs:_decimalValue * rhs:_intValue
                        CASE __UsualType.Int64		; RETURN lhs:_decimalValue * rhs:_i64Value
                        CASE __UsualType.Float		; RETURN lhs:_decimalValue * (System.Decimal) rhs:_r8Value
                        CASE __UsualType.Decimal	; RETURN lhs:_decimalValue *  rhs:_decimalValue
                        OTHERWISE					; NOP // error below
                    END SWITCH

                OTHERWISE
                    THROW BinaryError("*", __CavoStr(VOErrors.ARGSINCOMPATIBLE), TRUE, lhs, rhs)
            END SWITCH
            THROW BinaryError("*", __CavoStr(VOErrors.ARGNOTNUMERIC), FALSE, lhs, rhs)

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR >>(lhs AS __Usual, rhs AS INT) AS __Usual
            // Right shift
            SWITCH lhs:_usualType
                CASE __UsualType.Long	; RETURN lhs:_intValue >> rhs
            CASE __UsualType.Int64	; RETURN lhs:_i64Value >> rhs
                OTHERWISE
                    THROW BinaryError(">>", __CavoStr(VOErrors.ARGNOTINTEGER), TRUE, lhs, rhs)
                END SWITCH

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR <<(lhs AS __Usual, rhs AS LONG) AS __Usual
            // Left shift
            SWITCH (lhs:_usualType)
            CASE __UsualType.Long	; RETURN lhs:_intValue << rhs
                CASE __UsualType.Int64	; RETURN lhs:_i64Value << rhs
                OTHERWISE
                    THROW BinaryError("<<", __CavoStr(VOErrors.ARGNOTINTEGER), TRUE, lhs, rhs)
                END SWITCH


            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR &(lhs AS __Usual, rhs AS __Usual) AS __Usual
            // Bitwise And
            SWITCH (lhs:_usualType)
                CASE __UsualType.Long
                    SWITCH (rhs:_usualType)
                    CASE __UsualType.Long		; RETURN lhs:_intValue & rhs:_intValue
                    CASE __UsualType.Int64		; RETURN (INT64) lhs:_intValue & rhs:_i64Value
                    OTHERWISE					; NOP // error below
                    END SWITCH
                CASE __UsualType.Int64
                    SWITCH (rhs:_usualType)
                    CASE __UsualType.Long		; RETURN lhs:_i64Value & (INT64) rhs:_intValue
                    CASE __UsualType.Int64	    ; RETURN  lhs:_i64Value & rhs:_i64Value
                    OTHERWISE					; NOP // error below
                        END SWITCH
                OTHERWISE
                    THROW BinaryError("&", __CavoStr(VOErrors.ARGNOTINTEGER), TRUE, lhs, rhs)
            END SWITCH
            THROW BinaryError("&", __CavoStr(VOErrors.ARGNOTINTEGER), FALSE, lhs, rhs)

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        STATIC OPERATOR |(lhs AS __Usual, rhs AS __Usual) AS __Usual
            // Bitwise or
            SWITCH (lhs:_usualType)
                CASE __UsualType.Long
                    SWITCH (rhs:_usualType)
                    CASE __UsualType.Long		; RETURN lhs:_intValue | rhs:_intValue
                        CASE __UsualType.Int64		; RETURN (INT64) lhs:_intValue | rhs:_i64Value
                        OTHERWISE					; NOP // error below
                        END SWITCH
                CASE __UsualType.Int64
                    SWITCH (rhs:_usualType)
                        CASE __UsualType.Long		; RETURN lhs:_i64Value | (INT64) rhs:_intValue
                    CASE __UsualType.Int64		; RETURN  lhs:_i64Value | rhs:_i64Value
                        OTHERWISE					; NOP // error below
                        END SWITCH
                OTHERWISE
                    THROW BinaryError("|", __CavoStr(VOErrors.ARGNOTINTEGER), TRUE, lhs, rhs)
            END SWITCH
            THROW BinaryError("|", __CavoStr(VOErrors.ARGNOTINTEGER), FALSE, lhs, rhs)
            #endregion

        #region Implicit FROM USUAL TO Other Type

        /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS ARRAY
            SWITCH u:_usualType
                CASE __UsualType.Array	; RETURN u:_arrayValue
                CASE __UsualType.Void	; RETURN NULL_ARRAY
                CASE __UsualType.Object
                    IF u:_refData == NULL
                        RETURN NULL_ARRAY
                    ELSEIF u:_refData IS ARRAY      // can this happen ?
                        RETURN u:_arrayValue
                    ENDIF
            END SWITCH
            THROW ConversionError(ARRAY, TYPEOF(ARRAY), u)

        /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS CODEBLOCK
            SWITCH u:_usualType
                CASE __UsualType.Codeblock ; RETURN (CODEBLOCK) u:_codeblockValue
                CASE __UsualType.Void      ; RETURN NULL_CODEBLOCK
                CASE __UsualType.Object    
                    IF u:_refData == NULL
                        RETURN NULL_CODEBLOCK
                    ENDIF
            END SWITCH
            THROW ConversionError(CODEBLOCK, TYPEOF(CODEBLOCK), u)

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS LOGIC
            SWITCH u:_usualType
            CASE __UsualType.Logic		; RETURN u:_logicValue
            CASE __UsualType.Long		; RETURN u:_intValue != 0
            CASE __UsualType.Int64		; RETURN u:_i64Value != 0
            CASE __UsualType.Decimal	; RETURN u:_decimalValue != 0
            CASE __UsualType.Void		; RETURN FALSE
            OTHERWISE
                THROW ConversionError(LOGIC, TYPEOF(LOGIC), u)
            END SWITCH

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS DATE
            SWITCH u:_usualType
            CASE __UsualType.Date		; RETURN u:_dateValue
            CASE __UsualType.DateTime	; RETURN (DATE) u:_dateTimeValue
            CASE __UsualType.Void		; RETURN DATE{0}
            OTHERWISE
                THROW ConversionError(DATE, TYPEOF(DATE), u)
            END SWITCH

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS DateTime
            SWITCH u:_usualType
            CASE __UsualType.Date		; RETURN (DateTime) u:_dateValue
            CASE __UsualType.DateTime	; RETURN u:_dateTimeValue
            CASE __UsualType.Void		; RETURN DateTime.MinValue
            OTHERWISE
                THROW ConversionError(DATE, TYPEOF(DATE), u)
            END SWITCH

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS IntPtr
            // Note Vulcan has a different implementation for USUAL -> PTR and USUAL -> IntPtr
                SWITCH u:_usualType 
                CASE __UsualType.Ptr		; RETURN u:_ptrValue
                CASE __UsualType.Void 		; RETURN IntPtr.Zero
                OTHERWISE
                   THROW ConversionError(PTR, TYPEOF(IntPtr), u)
                END SWITCH
 
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS PTR
                // Note Vulcan has a different implementation for USUAL -> PTR and USUAL -> IntPtr
                SWITCH u:_usualType 
                CASE __UsualType.Ptr		; RETURN u:_ptrValue
                CASE __UsualType.Long		; RETURN (IntPtr) u:_intValue
                CASE __UsualType.Int64		; RETURN (IntPtr) u:_i64Value                    
                CASE __UsualType.Void 		; RETURN NULL_PTR
                OTHERWISE
                   THROW ConversionError(PTR, TYPEOF(IntPtr), u)
                END SWITCH



    /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS STRING
           SWITCH u:_usualType
            CASE __UsualType.String	
            CASE __UsualType.Symbol
                RETURN u:ToString()
            CASE __UsualType.Void
                RETURN ""
            OTHERWISE
                THROW ConversionError(STRING, TYPEOF(STRING), u)
            END SWITCH
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS SYMBOL
            SWITCH u:_usualType
            CASE __UsualType.Void	; RETURN NULL_SYMBOL
            CASE __UsualType.String	; RETURN __Symbol{u:_stringValue, TRUE}
            CASE __UsualType.Symbol	; RETURN u:_symValue
            OTHERWISE
                THROW ConversionError(SYMBOL, TYPEOF(SYMBOL), u)
            END SWITCH

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS PSZ
            SWITCH u:_usualType
            CASE __UsualType.Ptr	; RETURN PSZ{ u:_ptrValue }
            CASE __UsualType.String	; RETURN PSZ{u:_stringValue}
            CASE __UsualType.Void	; RETURN NULL_PSZ
            OTHERWISE
                THROW ConversionError(PSZ, TYPEOF(PSZ), u)
            END SWITCH

            #endregion
        #region Implicit Numeric Operators
        /// <include file="RTComments.xml" path="Comments/Operator/*" />
        /// <remarks>When the usual contains a value that does not fit inside a BYTE an overflow error will be generated, just like in VO.</remarks>
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS BYTE
            TRY
                SWITCH u:_usualType
                CASE __UsualType.Long		; RETURN UNCHECKED((BYTE) u:_intValue)
                CASE __UsualType.Int64		; RETURN UNCHECKED((BYTE) u:_i64Value)
                CASE __UsualType.Float
                    IF RuntimeState.CompilerOptionVO11
                        RETURN UNCHECKED(Convert.ToByte(u:_r8Value))
                    ELSE
                        RETURN UNCHECKED((BYTE) u:_r8Value)
                    ENDIF
                CASE __UsualType.Logic		; RETURN (BYTE) IIF(u:_logicValue, 1, 0)
                CASE __UsualType.Decimal
                    IF RuntimeState.CompilerOptionVO11
                        RETURN UNCHECKED(Convert.ToByte(u:_decimalValue ))
                    ELSE
                        RETURN UNCHECKED((BYTE) u:_decimalValue )
                    ENDIF
                CASE __UsualType.Void		; RETURN  0
                OTHERWISE
                    THROW ConversionError(BYTE, TYPEOF(BYTE), u)
                END SWITCH
            CATCH ex AS OverflowException
                THROW OverflowError(ex, "BYTE", TYPEOF(BYTE), u)
            END TRY
            

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
            /// <remarks>When the usual contains a value that does not fit inside a SHORT an overflow error will be generated, just like in VO.</remarks>
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS SHORT
            TRY
                SWITCH u:_usualType
                CASE __UsualType.Long	; RETURN UNCHECKED((SHORT) u:_intValue)
                CASE __UsualType.Int64	; RETURN UNCHECKED((SHORT) u:_i64Value)
                CASE __UsualType.Float
                    IF RuntimeState.CompilerOptionVO11
                        RETURN UNCHECKED(Convert.ToInt16(u:_r8value))
                    ELSE
                        RETURN UNCHECKED((SHORT) u:_r8Value)
                    ENDIF

                CASE __UsualType.Decimal
                    IF RuntimeState.CompilerOptionVO11
                        RETURN UNCHECKED(Convert.ToInt16(u:_decimalValue ))
                    ELSE
                        RETURN UNCHECKED((SHORT) u:_decimalValue )
                    ENDIF

                CASE __UsualType.Logic	; RETURN (SHORT) IIF(u:_logicValue, 1, 0)
                CASE __UsualType.Void	; RETURN 0
                OTHERWISE
                    THROW ConversionError(SHORT, TYPEOF(SHORT), u)
                END SWITCH
        CATCH ex AS OverflowException
                THROW OverflowError(ex, "SHORT", TYPEOF(SHORT), u)
            END TRY

        /// <include file="RTComments.xml" path="Comments/Operator/*" />
            /// <remarks>When the usual contains a value that does not fit inside a LONG an overflow error will be generated, just like in VO.</remarks>
            
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS LONG
            TRY
                SWITCH u:_usualType
                CASE __UsualType.Long	; RETURN u:_intValue
                CASE __UsualType.Int64	; RETURN (LONG) u:_i64Value
                CASE __UsualType.Float
                    IF RuntimeState.CompilerOptionVO11
                        RETURN CHECKED(Convert.ToInt32(u:_r8Value))
                    ELSE
                        RETURN  CHECKED((LONG) u:_r8Value)
                    ENDIF
                CASE __UsualType.Decimal
                    IF RuntimeState.CompilerOptionVO11
                        RETURN CHECKED(Convert.ToInt32(u:_decimalValue ))
                    ELSE
                        RETURN CHECKED((LONG) u:_decimalValue )
                    ENDIF
                CASE __UsualType.Logic	; RETURN IIF(u:_logicValue, 1, 0)
                CASE __UsualType.Void	; RETURN 0
                CASE __UsualType.Ptr
                    // this strange behavior is needed to be compatible with VO. 
                    IF IntPtr.Size == 4
                        RETURN u:_ptrValue:ToInt32()
                    ELSE
                        THROW OverflowError(OverFlowException{}, "LONG", TYPEOF(LONG), u)
                    ENDIF
                OTHERWISE
                    THROW ConversionError(LONG, TYPEOF(LONG), u)
                END SWITCH
            CATCH ex AS OverflowException
                THROW OverflowError(ex, "LONG", TYPEOF(LONG), u)
            END TRY

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        /// <remarks>When the usual contains a value that does not fit inside a LONG (such as a UInt36.MaxValue) NO overflow error will be generated, just like in VO. <br/>
        /// This may seem not logical, but the VO SDK code is full of code that will not run if we change this behavior</remarks>
            
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS INT64
            TRY
                SWITCH u:_usualType
                CASE __UsualType.Long	; RETURN u:_intValue
                CASE __UsualType.Int64	; RETURN (INT64) u:_i64Value
                CASE __UsualType.Float
                    IF RuntimeState.CompilerOptionVO11
                        RETURN Convert.ToInt64(u:_r8Value)
                    ELSE
                        RETURN  (INT64) u:_r8Value
                    ENDIF
                CASE __UsualType.Decimal
                    IF RuntimeState.CompilerOptionVO11
                        RETURN Convert.ToInt64(u:_decimalValue )
                    ELSE
                        RETURN (INT64) u:_decimalValue 
                    ENDIF
                CASE __UsualType.Ptr
                     RETURN u:_ptrValue:ToInt64()
   
                CASE __UsualType.Logic	; RETURN IIF(u:_logicValue, 1, 0)
                CASE __UsualType.Void	; RETURN 0
  
                OTHERWISE
                    THROW ConversionError(INT64, TYPEOF(INT64), u)
                END SWITCH
        CATCH ex AS OverflowException
                THROW OverflowError(ex, "INT64", TYPEOF(INT64), u)
            END TRY

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS System.Decimal
            TRY
                SWITCH u:_usualType
                CASE __UsualType.Long	; RETURN u:_intValue
                CASE __UsualType.Int64	; RETURN u:_i64Value
                CASE __UsualType.Float	; RETURN (System.Decimal) u:_r8Value
                CASE __UsualType.Decimal; RETURN u:_decimalValue
                CASE __UsualType.Logic	; RETURN IIF(u:_logicValue, 1, 0)
                CASE __UsualType.Void	; RETURN 0
                OTHERWISE
                    THROW ConversionError(__UsualType.DECIMAL, TYPEOF(INT64), u)
                END SWITCH
            CATCH ex AS OverflowException
                THROW OverflowError(ex, "DECIMAL", TYPEOF(INT64), u)
            END TRY

        /// <include file="RTComments.xml" path="Comments/Operator/*" />
        /// <remarks>When the usual contains a value that does not fit inside a SByte an overflow error will be generated, just like in VO.</remarks>
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS SByte
            TRY
                SWITCH u:_usualType
                CASE __UsualType.Long	; RETURN UNCHECKED( (SByte) u:_intValue)
                CASE __UsualType.Int64	; RETURN UNCHECKED( (SByte) u:_i64Value)
                CASE __UsualType.Float	; RETURN UNCHECKED( (SByte) u:_r8Value)
                CASE __UsualType.Decimal; RETURN UNCHECKED((SByte) u:_decimalValue )
                CASE __UsualType.Logic	; RETURN (SByte) IIF(u:_logicValue, 1, 0)
                CASE __UsualType.Void	; RETURN 0
                OTHERWISE
                    THROW ConversionError(BYTE, TYPEOF(SByte), u)
                END SWITCH
            CATCH ex AS OverflowException
                THROW OverflowError(ex, "SBYTE", TYPEOF(SByte), u)
            END TRY

            // Unsigned
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
           /// <remarks>When the usual contains a value that does not fit inside a WORD an overflow error will be generated, just like in VO.</remarks>

        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS WORD
            TRY
                SWITCH u:_usualType
                CASE __UsualType.Long	; RETURN UNCHECKED((WORD) u:_intValue)
                CASE __UsualType.Int64	; RETURN UNCHECKED((WORD) u:_i64Value)
                CASE __UsualType.Float	; RETURN UNCHECKED((WORD) u:_r8Value)
                CASE __UsualType.Decimal; RETURN UNCHECKED((WORD) u:_decimalValue )
                CASE __UsualType.Logic	; RETURN (WORD) IIF(u:_logicValue, 1, 0)
                CASE __UsualType.Void	; RETURN 0
                OTHERWISE
                    THROW ConversionError(WORD, TYPEOF(WORD), u)
                END SWITCH
            CATCH ex AS OverflowException
                THROW OverflowError(ex, "WORD", TYPEOF(WORD), u)
            END TRY

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        /// <remarks>When the usual contains a value that does not fit inside a DWORD (such as a -1) NO overflow error will be generated, just like in VO. <br/>
        /// This may seem not logical, but the VO SDK code is full of code that will not run if we change this behavior</remarks>
            
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS DWORD
            TRY
                SWITCH u:_usualType
                CASE __UsualType.Long     ; RETURN (DWORD) u:_intValue
                CASE __UsualType.Int64    ; RETURN (DWORD) u:_i64Value
                CASE __UsualType.Float    ; RETURN (DWORD) u:_r8Value
                CASE __UsualType.Decimal  ; RETURN (DWORD) u:_decimalValue 
                CASE __UsualType.Logic    ; RETURN (DWORD) IIF(u:_logicValue, 1, 0)
                CASE __UsualType.Void     ; RETURN 0
                CASE __UsualType.Ptr
                    // this strange behavior is needed to be compatible with VO. 
                    IF IntPtr.Size == 4
                        RETURN (DWORD) u:_ptrValue:ToInt32()
                    ELSE
                        THROW OverflowError(OverFlowException{}, "LONG", TYPEOF(LONG), u)
                    ENDIF
 
                OTHERWISE
                    THROW ConversionError(DWORD, TYPEOF(DWORD), u)
                END SWITCH
            CATCH ex AS OverflowException
                THROW OverflowError(ex, "DWORD", TYPEOF(DWORD), u)
            END TRY

           /// <include file="RTComments.xml" path="Comments/Operator/*" />
        /// <remarks>When the usual contains a value that does not fit inside a LONG (such as a -1) NO overflow error will be generated, just like in VO. <br/>
        /// This may seem not logical, but the VO SDK code is full of code that will not run if we change this behavior</remarks>
            
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS UINT64
            TRY
                SWITCH u:_usualType
                CASE __UsualType.Long	; RETURN (UINT64) u:_intValue
                CASE __UsualType.Int64	; RETURN (UINT64) u:_i64Value
                CASE __UsualType.Float	; RETURN (UINT64) u:_r8Value
                CASE __UsualType.Decimal; RETURN (UINT64) u:_decimalValue 
                CASE __UsualType.Logic	; RETURN IIF(u:_logicValue, 1, 0)
                CASE __UsualType.Void	; RETURN 0
                CASE __UsualType.Ptr    ; RETURN (UINT64) u:_ptrValue:ToInt64()

                OTHERWISE
                    THROW ConversionError(UINT64, TYPEOF(UINT64), u)
                END SWITCH
            CATCH ex AS OverflowException
                THROW OverflowError(ex, "UINT64", TYPEOF(UINT64), u)
            END TRY

            // Single, Double and FLoat
            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS REAL4
            TRY
                SWITCH u:_usualType
                    CASE __UsualType.Long	; RETURN (REAL4) u:_intValue
                    CASE __UsualType.Int64	; RETURN (REAL4) u:_i64Value
                    CASE __UsualType.Float	; RETURN (REAL4) u:_r8Value
                    CASE __UsualType.Decimal; RETURN (REAL4) u:_decimalValue 
                    CASE __UsualType.Logic	; RETURN IIF(u:_logicValue, 1, 0)
                    CASE __UsualType.Void	; RETURN 0
                    OTHERWISE
                        THROW ConversionError(REAL4, TYPEOF(REAL4), u)
                    END SWITCH
            CATCH ex AS OverflowException
                THROW OverflowError(ex, "REAL4", TYPEOF(REAL4), u)
            END TRY

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS REAL8
            TRY
                SWITCH u:_usualType
                CASE __UsualType.Long	; RETURN (REAL8) u:_intValue
                CASE __UsualType.Int64	; RETURN (REAL8) u:_i64Value
                CASE __UsualType.Float	; RETURN (REAL8) u:_r8Value
                CASE __UsualType.Decimal; RETURN (REAL8) u:_decimalValue 
                CASE __UsualType.Logic	; RETURN IIF(u:_logicValue, 1, 0)
                CASE __UsualType.Void	; RETURN 0
                OTHERWISE
                    THROW ConversionError(REAL8, TYPEOF(REAL8), u)
                END SWITCH
        CATCH ex AS OverflowException
                THROW OverflowError(ex, "REAL8", TYPEOF(REAL8), u)
            END TRY

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(u AS __Usual) AS FLOAT
            TRY
                SWITCH u:_usualType
                CASE __UsualType.Long	; RETURN FLOAT{(REAL8) u:_intValue,0}
                CASE __UsualType.Int64	; RETURN FLOAT{(REAL8) u:_i64Value,0}
                CASE __UsualType.Float	; RETURN u:_floatValue
                CASE __UsualType.Decimal; RETURN FLOAT{(REAL8) u:_decimalValue, -1}
                CASE __UsualType.Logic	; RETURN FLOAT{IIF(u:_logicValue, 1, 0),0}
                CASE __UsualType.Void	; RETURN FLOAT{0,0}
                OTHERWISE
                    THROW ConversionError(FLOAT, TYPEOF(FLOAT), u)
                END SWITCH
            CATCH ex AS OverflowException
                THROW OverflowError(ex, "FLOAT", TYPEOF(FLOAT), u)
            END TRY

            #endregion
        #region Implicit FROM Other Type TO USUAL

        /// <include file="RTComments.xml" path="Comments/Operator/*" />
        /// Note this generates error XS0553.
        /// However our compiler needs this one. Therefore disable XS0553
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS OBJECT) AS __Usual
            LOCAL result AS __Usual
            IF val == NULL
                result := __Usual._NIL
            ELSE
                result := __Usual{val}
            ENDIF
            RETURN result

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS LOGIC) AS __Usual
            RETURN __Usual{val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS BYTE) AS __Usual
            RETURN __Usual{(INT)val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS ARRAY) AS __Usual
            RETURN __Usual{val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS DATE) AS __Usual
            RETURN __Usual{val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS System.DateTime) AS __Usual
            RETURN __Usual{val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS FLOAT) AS __Usual
            RETURN __Usual{val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS REAL8) AS __Usual
            RETURN __Usual{val}


            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS SHORT) AS __Usual
            RETURN __Usual{(INT)val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS LONG) AS __Usual
            RETURN __Usual{val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS INT64) AS __Usual
            RETURN __Usual{val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS UINT64) AS __Usual
            RETURN __Usual{val}


            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS PSZ) AS __Usual
            RETURN __Usual{val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS SYMBOL) AS __Usual
            RETURN __Usual{val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS System.Decimal) AS __Usual
            RETURN __Usual{val}

        OPERATOR IMPLICIT( val AS PTR ) AS USUAL
            RETURN __Usual{ (IntPtr) val }

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS System.IntPtr) AS __Usual
            RETURN __Usual{val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS SByte) AS __Usual
            RETURN __Usual{(INT)val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS REAL4) AS __Usual
            RETURN __Usual{(REAL8)val }

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS STRING) AS __Usual
            RETURN __Usual{val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS WORD) AS __Usual
            RETURN __Usual{(INT)val}

            /// <include file="RTComments.xml" path="Comments/Operator/*" />
        [DebuggerStepThroughAttribute];
        STATIC OPERATOR IMPLICIT(val AS DWORD) AS __Usual
            RETURN IIF((val <= 0x7fffffff),__Usual{(LONG)val },__Usual{(FLOAT)val })
            #endregion

        #region implementation IConvertable
        /// <inheritdoc />
        PUBLIC METHOD IConvertible.ToBoolean(provider AS System.IFormatProvider) AS LOGIC
            RETURN (LOGIC) SELF

            /// <inheritdoc />
        PUBLIC METHOD IConvertible.ToByte(provider AS System.IFormatProvider) AS BYTE
            RETURN (BYTE) SELF

            /// <inheritdoc />
        PUBLIC METHOD IConvertible.ToChar(provider AS System.IFormatProvider) AS CHAR
            VAR o := __Usual.ToObject(SELF)
            IF o IS IConvertible
                RETURN ((IConvertible)o):ToChar(provider)
            ENDIF
            THROW InvalidCastException{}

            /// <inheritdoc />
        PUBLIC METHOD IConvertible.ToDateTime(provider AS System.IFormatProvider) AS System.DateTime
            RETURN (DATE) SELF

            /// <inheritdoc />
        PUBLIC METHOD IConvertible.ToDecimal(provider AS System.IFormatProvider) AS Decimal
            RETURN (Decimal) SELF

            /// <inheritdoc />
        PUBLIC METHOD IConvertible.ToDouble(provider AS System.IFormatProvider) AS REAL8
            RETURN (REAL8) SELF

            /// <inheritdoc />
        PUBLIC METHOD IConvertible.ToInt16(provider AS System.IFormatProvider) AS SHORT
            RETURN (SHORT) SELF

            /// <inheritdoc />
        PUBLIC METHOD IConvertible.ToInt32(provider AS System.IFormatProvider) AS LONG
            RETURN (LONG) SELF

            /// <inheritdoc />
        PUBLIC METHOD IConvertible.ToInt64(provider AS System.IFormatProvider) AS INT64
            RETURN (INT64) SELF

            /// <exclude />
        [DebuggerStepThroughAttribute];
        STATIC METHOD ToObject(u AS __Usual) AS OBJECT
            SWITCH u:_usualType
                CASE __UsualType.Array		; RETURN u:_arrayValue
                CASE __UsualType.Codeblock	; RETURN u:_codeblockValue
                CASE __UsualType.Date		; RETURN u:_dateValue
                CASE __UsualType.DateTime	; RETURN u:_dateTimeValue
                CASE __UsualType.Decimal	; RETURN u:_decimalValue
                CASE __UsualType.Float		; RETURN u:_floatValue
                CASE __UsualType.Int64		; RETURN u:_i64Value
                CASE __UsualType.Long		; RETURN u:_intValue
                CASE __UsualType.Logic		; RETURN u:_logicValue
                CASE __UsualType.Object		; RETURN u:_refData
                CASE __UsualType.Ptr		; RETURN u:_ptrValue
                CASE __UsualType.String		; RETURN u:_stringValue
                CASE __UsualType.Symbol		; RETURN u:_symValue
                CASE __UsualType.Void		; RETURN NULL
                OTHERWISE
                    Debug.Fail( "Unhandled data type in Usual:ToObject()" )
                END SWITCH
                RETURN NULL_OBJECT
                
            /// <inheritdoc />
        PUBLIC METHOD IConvertible.ToSByte(provider AS System.IFormatProvider) AS SByte
            RETURN SELF

            /// <inheritdoc />
        PUBLIC METHOD IConvertible.ToSingle(provider AS System.IFormatProvider) AS REAL4
            RETURN SELF

            /// <exclude />
        PUBLIC METHOD AsString() AS STRING STRICT
            RETURN SELF:ToString()

            /// <exclude />
        PUBLIC METHOD Clone() AS __Usual
            // clone types that need cloning
            LOCAL result AS __Usual
            SWITCH SELF:_usualType
                CASE __UsualType.Object
                    result := __Usual{SELF:value}
                CASE __UsualType.String
                    result := __Usual { String.Copy(SELF:_stringValue)}
                CASE __UsualType.Array
                    result := __Usual { AClone(SELF:_arrayValue) }
                OTHERWISE
                    result := SELF
            END SWITCH
            RETURN result

        /// <exclude/>
        PUBLIC OVERRIDE METHOD ToString() AS STRING
            LOCAL strResult AS STRING

            SWITCH (SELF:_usualType)
                CASE __UsualType.Array		; strResult := IIF (SELF:_refData == NULL, "NULL_ARRAY", SELF:_arrayValue:ToString())
                CASE __UsualType.Codeblock  ; strResult := IIF (SELF:_refData == NULL, "NULL_CODEBLOCK", SELF:_codeblockValue:ToString())
                CASE __UsualType.Object		; strResult := AsString(SELF)
                CASE __UsualType.Date		; strResult := SELF:_dateValue:ToString()
                CASE __UsualType.DateTime	; strResult := SELF:_dateTimeValue:ToString()
                CASE __UsualType.Decimal	; strResult := IIF (SELF:_refData == NULL, "0", SELF:_decimalValue:ToString())
                CASE __UsualType.Float		; strResult := SELF:_r8Value:ToString()
                CASE __UsualType.Long		; strResult := SELF:_intValue:ToString()
                CASE __UsualType.Int64		; strResult := SELF:_i64Value:ToString()
                CASE __UsualType.Logic		; strResult := IIF(!SELF:_logicValue , ".F." , ".T.")
                CASE __UsualType.Ptr		; strResult := SELF:_ptrValue:ToString()
                CASE __UsualType.String		; strResult := IIF (SELF:_refData == NULL, "NULL_STRING", SELF:_stringValue:ToString())
                CASE __UsualType.Symbol		; strResult := SELF:_symValue:ToString()
                CASE __UsualType.Void		; strResult := "NIL"
                OTHERWISE					; strResult := ""
                END SWITCH
            RETURN strResult


        /// <exclude/>
        PUBLIC METHOD ToString(provider AS System.IFormatProvider) AS STRING
            RETURN SELF:ToString()

        PUBLIC METHOD IConvertible.ToType(conversionType AS System.Type, provider AS System.IFormatProvider) AS OBJECT
            IF conversionType:IsPointer
                SWITCH SELF:_usualType
                CASE __UsualType.Ptr	; RETURN _ptrValue
                CASE __UsualType.Long	; RETURN (IntPtr) _intValue
                CASE __UsualType.Int64	; RETURN (IntPtr) _i64Value
                OTHERWISE
                        THROW InvalidCastException{}
                END SWITCH
            ELSE
                VAR o := __Usual:ToObject(SELF)
                IF conversionType:IsAssignableFrom(o:GetType())
                    RETURN o
                ELSEIF o IS IConvertible
                    RETURN ((IConvertible) o):Totype(conversionType, provider)
                ELSE
                    RETURN o
                ENDIF
            ENDIF

            /// <inheritdoc />
        PUBLIC METHOD IConvertible.ToUInt16(provider AS System.IFormatProvider) AS WORD
            RETURN (WORD) SELF

            /// <inheritdoc />
        PUBLIC METHOD IConvertible.ToUInt32(provider AS System.IFormatProvider) AS DWORD
            RETURN (DWORD) SELF

            /// <inheritdoc />
        PUBLIC METHOD IConvertible.ToUInt64(provider AS System.IFormatProvider) AS UINT64
            RETURN (UINT64) SELF

            /// <exclude />
        PUBLIC METHOD GetTypeCode() AS System.TypeCode
            SWITCH _usualType
            CASE __UsualType.Array	    ; RETURN TypeCode.Object
            CASE __UsualType.Codeblock  ; RETURN TypeCode.Object
            CASE __UsualType.Date	    ; RETURN TypeCode.Object
            CASE __UsualType.DateTime   ; RETURN TypeCode.DateTime
            CASE __UsualType.Decimal    ; RETURN TypeCode.Decimal
            CASE __UsualType.Float      ; RETURN TypeCode.Object
            CASE __UsualType.Int64	    ; RETURN TypeCode.Int64
            CASE __UsualType.Long	    ; RETURN TypeCode.Int32
            CASE __UsualType.Logic	    ; RETURN TypeCode.Boolean
            CASE __UsualType.Object	    ; RETURN TypeCode.Object
            CASE __UsualType.Ptr	    ; RETURN TypeCode.Object
            CASE __UsualType.String     ; RETURN TypeCode.String
            CASE __UsualType.Symbol     ; RETURN TypeCode.Object
            CASE __UsualType.Void       ; RETURN TypeCode.Object
            OTHERWISE
                 Debug.Fail( "Unhandled data type in Usual:GetTypeCode()" )
            END SWITCH
            RETURN TypeCode.Empty
            #endregion

        #region Error METHOD
        INTERNAL PROPERTY ValType AS STRING
            GET
                SWITCH SELF:_usualType
                CASE __UsualType.Array		; RETURN "A"
                CASE __UsualType.Codeblock	; RETURN "B"
                CASE __UsualType.Date		; RETURN "D"
                CASE __UsualType.DateTime	; RETURN "D"
                CASE __UsualType.Decimal	; RETURN "N"
                CASE __UsualType.Float		; RETURN "N"
                CASE __UsualType.Int64		; RETURN "N"
                CASE __UsualType.Long		; RETURN "N"
                CASE __UsualType.Logic		; RETURN "L"
                CASE __UsualType.Ptr		; RETURN "-"
                CASE __UsualType.String		; RETURN "C"
                CASE __UsualType.Object		; RETURN "O"
                CASE __UsualType.Symbol		; RETURN "#"
                CASE __UsualType.Void		; RETURN "U"
                OTHERWISE
                    Debug.Fail( "Unhandled data type in Usual:Valtype" )
                END SWITCH
                RETURN "?"
            END GET
        END PROPERTY
        STATIC INTERNAL METHOD ConversionError(toTypeString AS STRING, toType AS System.Type, u AS __Usual) AS Error
            VAR	cMessage	:= VO_Sprintf(VOErrors.USUALCONVERSIONERR, TypeString(UsualType(u)), toTypeString)
            VAR err			:= Error{GenCode.EG_DataType,"USUAL", cMessage}
            err:ArgTypeReqType:= toType
            err:ArgNum		:= 1
            err:FuncSym		:= "USUAL => "+toTypeString
            err:Args        := <OBJECT>{u}
            RETURN err

        STATIC INTERNAL METHOD ConversionError(typeNum AS DWORD, toType AS System.Type, u AS __Usual) AS Error
            VAR	cMessage	:= VO_Sprintf(VOErrors.USUALCONVERSIONERR, TypeString(UsualType(u)), TypeString(DWORD(typeNum)))
            VAR err			:= Error{GenCode.EG_DataType,"USUAL", cMessage}
            err:ArgTypeReqType:= toType
            err:ArgNum		:= 1
            err:FuncSym		:= "USUAL => "+TypeString((DWORD) typeNum)
            err:ArgType		:= typeNum
            err:Args        := <OBJECT>{u}
            RETURN err

        STATIC INTERNAL METHOD OverflowError(ex AS OverflowException, toTypeString AS STRING, toType AS System.Type, u AS __Usual) AS Error
            VAR message      := VO_Sprintf(VOErrors.USUALOVERFLOWERR, TypeString(UsualType(u)), toTypeString)
            VAR err			 := Error{GenCode.EG_NUMOVERFLOW, "USUAL", message}
            err:ArgTypeReqType := toType
            err:ArgNum		 := 1
            err:FuncSym		 := "USUAL => "+toTypeString
            err:Args		 := <OBJECT>{u}
            RETURN err

        STATIC INTERNAL METHOD BinaryError( cOperator AS STRING, message AS STRING, left AS LOGIC, lhs AS __Usual, rhs AS __Usual) AS Error
            VAR err			 := Error{ArgumentException{}}
            err:GenCode		 := GenCode.EG_ARG
            err:ArgNum		 := (DWORD) IIF (left, 1, 2)
            err:FuncSym		 := cOperator
            err:Description  := message
            err:Arg			 := IIF(left, "left operand" , "right operand")
            err:Args         := <OBJECT> {lhs, rhs}
            RETURN err

        STATIC INTERNAL METHOD UnaryError( cOperator AS STRING, u AS __Usual) AS Error
            VAR err			 := Error{ArgumentException{}}
            err:GenCode		 := GenCode.EG_ARG
            err:ArgNum		 := 1
            err:FuncSym		 := cOperator
            err:Description  := __CavoStr(VOErrors.INVALIDARGTYPE)
            err:Arg			 := "USUAL"
            err:Args         := <OBJECT> {u}
            RETURN err


            #endregion

        #region IIndexer
		/// <include file="RTComments.xml" path="Comments/ZeroBasedIndexProperty/*" /> 
		/// <param name="index"><include file="RTComments.xml" path="Comments/ZeroBasedIndexParam/*" /></param>
		/// <returns>The element stored at the indicated location in the collection.</returns>
        /// <remarks>When the contents of the USUAL is not an array or does not support indexed access then a runtime error is generated.</remarks>
        PROPERTY SELF[index AS INT[]] AS USUAL
            GET
              IF SELF:IsArray
                 RETURN  SELF:_arrayValue:__GetElement(index)

              ELSEIF SELF:IsObject .AND. _refData IS IIndexedProperties
                  VAR props := (IIndexedProperties) _refData
                  IF index:Length == 1
                      LOCAL pos AS LONG
                      pos := index[1]
                      RETURN props[pos]
                  ENDIF
              ENDIF

              THROW InvalidCastException{VO_Sprintf(VOErrors.USUALNOTINDEXED, typeof(IIndexedProperties):FullName)}
            END GET
            SET
              IF SELF:IsArray
                 SELF:_arrayValue:__SetElement(VALUE, index)
                 RETURN
              ELSEIF SELF:IsObject .AND. _refData IS IIndexedProperties
                  VAR props := (IIndexedProperties) _refData
                  IF index:Length == 1
                      LOCAL pos AS LONG
                      pos := index[1]
                      props[pos] := VALUE
                   ENDIF
                   RETURN
              ENDIF

              THROW InvalidCastException{VO_Sprintf(VOErrors.USUALNOTINDEXED, typeof(IIndexedProperties):FullName)}
            END SET
        END PROPERTY
        #endregion


        #region IIndexedProperties
		/// <include file="RTComments.xml" path="Comments/ZeroBasedIndexProperty/*" /> 
		/// <param name="index"><include file="RTComments.xml" path="Comments/ZeroBasedIndexParam/*" /></param>
		/// <returns>The element stored at the indicated location in the collection.</returns>
        /// <remarks>When the contents of the USUAL is not an array or does not support indexed access then a runtime error is generated.</remarks>

        PROPERTY SELF[index AS INT ] AS USUAL
            GET
                IF SELF:IsArray
                    VAR a := SELF:_arrayValue
                    RETURN a:__GetElement(index)
                ENDIF

                VAR indexer := _refData ASTYPE IIndexedProperties
                IF indexer == NULL
                    THROW InvalidCastException{VO_Sprintf(VOErrors.USUALNOTINDEXED, typeof(IIndexedProperties):FullName)}
                ENDIF
                RETURN indexer[index]                    
            END GET
            SET
                IF SELF:IsArray
                    VAR a := SELF:_arrayValue 
                    a:__SetElement(index,VALUE)
                    RETURN
                ENDIF
   
                VAR indexer := _refData ASTYPE IIndexedProperties
                IF indexer == NULL
                    THROW InvalidCastException{VO_Sprintf(VOErrors.USUALNOTINDEXED, typeof(IIndexedProperties):FullName)}
                ENDIF
                indexer[index] := VALUE
            END SET
        END PROPERTY

		/// <include file="RTComments.xml" path="Comments/ZeroBasedIndexProperty/*" /> 
        /// <param name="name"><include file="RTComments.xml" path="Comments/NameBasedIndexParam/*" /></param>
		/// <returns>The element stored at the indicated location in the collection.</returns>
        /// <remarks>When the contents of the USUAL is not an array or does not name based indexing  then a runtime error is generated.</remarks>

        PROPERTY SELF[name  AS STRING] AS USUAL 
            GET
                VAR indexer := _refData ASTYPE IIndexedProperties
                IF indexer == NULL
                    THROW InvalidCastException{VO_Sprintf(VOErrors.USUALNOTINDEXED, typeof(IIndexedProperties):FullName)}
                ENDIF
                RETURN indexer[name]                    
            END GET
            SET
                VAR indexer := _refData ASTYPE IIndexedProperties
                IF indexer == NULL
                    THROW InvalidCastException{VO_Sprintf(VOErrors.USUALNOTINDEXED, typeof(IIndexedProperties):FullName)}
                ENDIF
                indexer[name] := VALUE
            END SET
        END PROPERTY
        #endregion
        #region Special methods used BY the compiler
        /// <summary>This method is used by the compiler for code that does an inexact comparison between two usuals.</summary>
        STATIC METHOD __InexactEquals( lhs AS __Usual, rhs AS __Usual ) AS LOGIC
            IF lhs:IsString .AND. rhs:IsString
                RETURN __StringEquals( lhs:_stringValue, rhs:_stringValue)
            ELSE
                RETURN lhs:UsualEquals(rhs, "=")
            ENDIF

            /// <summary>This method is used by the compiler for code that does an inexact comparison between a usual and a string.</summary>
        STATIC METHOD __InexactEquals( lhs AS __Usual, rhs AS STRING ) AS LOGIC
            IF lhs:IsString
                RETURN __StringEquals( lhs:_stringValue, rhs)
            ELSEIF lhs:IsNil
            	RETURN FALSE
            ELSE
                THROW BinaryError("=", __CavoStr(VOErrors.ARGSINCOMPATIBLE), TRUE, lhs, rhs)
            ENDIF

            /// <summary>This method is used by the compiler for code that does an inexact comparison.</summary>
        STATIC METHOD __InexactNotEquals( lhs AS __Usual, rhs AS __Usual ) AS LOGIC
            // emulate VO behavior for "" and NIL
            // "" = NIL but also "" != NIL, NIL = "" and NIL != ""
            IF lhs:IsString
                IF rhs:IsString
                    RETURN __StringNotEquals( lhs:_stringValue, rhs:_stringValue)
                ELSEIF rhs:IsNil .AND. lhs:_stringValue != NULL .AND. lhs:_stringValue:Length == 0
                    RETURN FALSE
                ENDIF
            ENDIF
            IF rhs:IsString .AND. lhs:IsNil .AND. rhs:_stringValue != NULL .AND. rhs:_stringValue:Length == 0
                RETURN FALSE
            ELSE
                RETURN ! lhs:UsualEquals(rhs, "<>")
            ENDIF
            /// <summary>This method is used by the compiler for code that does an inexact comparison.</summary>
        STATIC METHOD __InexactNotEquals( lhs AS __Usual, rhs AS STRING ) AS LOGIC
            IF lhs:IsString
                RETURN __StringNotEquals( lhs:_stringValue, rhs)
            ELSE
                THROW BinaryError("<>", __CavoStr(VOErrors.ARGSINCOMPATIBLE), TRUE, lhs, rhs)
            ENDIF

            #endregion
        INTERNAL CLASS UsualDebugView
            PRIVATE _uvalue AS __Usual
            PUBLIC CONSTRUCTOR (u AS __Usual)
                _uvalue := u

            [DebuggerBrowsable(DebuggerBrowsableState.RootHidden)] ;
            PUBLIC PROPERTY Value AS OBJECT GET _uvalue:Value
            PUBLIC PROPERTY Type  AS __UsualType GET _uvalue:_usualType

        END CLASS
    END STRUCTURE


    [StructLayout(LayoutKind.Explicit)];
    INTERNAL STRUCTURE _UsualData
        // Fields
        [FieldOffset(0)] INTERNAL d     AS __Date
        [FieldOffset(0)] INTERNAL r8    AS REAL8
        [FieldOffset(0)] INTERNAL i     AS LONG
        [FieldOffset(0)] INTERNAL i64   AS INT64
        [FieldOffset(0)] INTERNAL l     AS LOGIC
        [FieldOffset(0)] INTERNAL p     AS System.IntPtr
        [FieldOffset(0)] INTERNAL s     AS SYMBOL
        [FieldOffset(0)] INTERNAL dt    AS System.DateTime
    END STRUCTURE


    [StructLayout(LayoutKind.Explicit, Pack := 1)];
    INTERNAL STRUCTURE UsualFlags
        [FieldOffset(0)] EXPORT usualType   AS __UsualType
        [FieldOffset(1)] EXPORT width       AS Sbyte
        [FieldOffset(2)] EXPORT decimals    AS Sbyte
        [FieldOffset(3)] EXPORT isByRef     AS LOGIC
        [DebuggerStepThroughAttribute];
        CONSTRUCTOR(type AS __UsualType)
            usualType := type
            width	  := 0
            decimals  := 0
            isByRef   := FALSE
            END STRUCTURE



END NAMESPACE

/// <summary>
/// Determine the data type of an expression.
/// </summary>
/// <param name="x"></param>
/// <returns>
/// </returns>
FUNCTION UsualType(u AS __Usual) AS DWORD
    RETURN (DWORD) u:Type

/// <summary>
/// Access contents of an address, whether it is passed by reference or not.
/// </summary>
/// <param name="u"></param>
/// <returns>
/// </returns>
FUNCTION UsualVal(u AS __Usual) AS __Usual
    RETURN u

/// <summary>
/// Determine the data type of an expression.
/// </summary>
/// <param name="u"></param>
/// <returns>
/// </returns>
FUNCTION ValType(u AS __Usual) AS STRING
    RETURN u:ValType


