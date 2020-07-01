//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
USING System.Collections
USING System.Collections.Generic
USING System.Linq
USING System.Diagnostics
USING System.Reflection
USING System.Text
USING XSharp
BEGIN NAMESPACE XSharp
    /// <summary>Internal type that implements the VO Compatible ARRAY type.<br/>
    /// This type has methods and properties that normally are never directly called from user code.
    /// </summary>
    /// <seealso cref='T:XSharp.IIndexer' />
    /// <include file="RTComments.xml" path="Comments/ZeroBasedIndex/*" /> 
    //[DebuggerTypeProxy(TYPEOF(ArrayDebugView))];
    [DebuggerDisplay("{DebuggerString(),nq}", Type := "ARRAY")] ;
    PUBLIC SEALED CLASS __Array INHERIT __ArrayBase<USUAL> IMPLEMENTS IIndexer

        /// <inheritdoc />
        CONSTRUCTOR()
            SUPER()

            /// <inheritdoc />
        CONSTRUCTOR(capacity AS DWORD)
            SUPER(capacity)

            /// <inheritdoc />
        CONSTRUCTOR(capacity AS DWORD, fill AS LOGIC)
            SUPER(capacity, fill)

            /// <summary>Create an array and fill it with elements from an existing .Net array of USUALS</summary>
        CONSTRUCTOR( elements AS USUAL[] )
            SELF()
            IF elements == NULL
                THROW Error{ArgumentNullException{NAMEOF(elements)}}
            ENDIF
            _internalList:Capacity := elements:Length
            _internalList:AddRange(elements)
            RETURN

            /// <inheritdoc />
        CONSTRUCTOR( elements AS OBJECT[] )
            SELF()
            IF elements == NULL
                RETURN // empty array
            ENDIF
            FOREACH element AS OBJECT IN elements
                IF element == NULL
                    _internalList:Add(NIL)
                ELSEIF element IS OBJECT[]
                    LOCAL objects AS OBJECT[]
                    objects := (OBJECT[]) element
                    _internalList:Add( __Array{ objects})
                ELSE
                    _internalList:Add( USUAL{ element})
                ENDIF
            NEXT
            RETURN

        INTERNAL STATIC METHOD ArrayCreate(dimensions PARAMS INT[] ) AS ARRAY
            LOCAL count := dimensions:Length AS INT
            IF count <= 0
                THROW Error{ArgumentException{"No dimensions provided.",nameof(dimensions)}}
            ENDIF
            LOCAL initializer := OBJECT[]{dimensions[1]} AS OBJECT[]
            LOCAL arrayNew AS ARRAY
            arrayNew := ARRAY{initializer}

            IF count > 1
                LOCAL i AS INT
                FOR i:=0+__ARRAYBASE__  UPTO dimensions[1]-1+__ARRAYBASE__
                    LOCAL newParams := INT[]{count-1} AS INT[]
                    Array.Copy(dimensions,1,newParams,0,count-1)
                    arrayNew:_internalList[(INT) i-__ARRAYBASE__ ] := __ArrayNew(newParams)
                NEXT
            ENDIF
            RETURN arrayNew

        /// <exclude/>
        STATIC METHOD __ArrayNew( dimensions PARAMS INT[] ) AS __Array
            LOCAL newArray AS ARRAY
            IF dimensions:Length != 0
                newArray := __ArrayNewHelper(dimensions,1)
            ELSE
                newArray := ARRAY{}
            ENDIF
            RETURN newArray

        INTERNAL STATIC METHOD __ArrayNewHelper(dimensions AS INT[], currentDim AS INT) AS ARRAY
            LOCAL size AS DWORD
            LOCAL newArray AS ARRAY
            size := (DWORD) dimensions[currentDim]
            newArray := ARRAY{size, TRUE} 
            IF currentDim != dimensions:Length
                LOCAL nextDim := currentDim+1 AS INT
                LOCAL index   := 1 AS INT
                DO WHILE index <= size
                    newArray[index - 1 + __ARRAYBASE__] := USUAL{__ArrayNewHelper(dimensions,nextDim)}
                    index+=1
                ENDDO
                RETURN newArray
            ENDIF
            RETURN newArray

        INTERNAL NEW METHOD Clone() AS ARRAY
            LOCAL aResult AS ARRAY
            LOCAL nCount AS DWORD
            nCount := (DWORD) _internalList:Count
            aResult := ARRAY{nCount, TRUE}
            IF nCount == 0
                // warning, nCount-1 below will become MAXDWORD for nCount == 0
                RETURN aResult
            END IF
            FOR VAR i := 0 TO nCount-1
                VAR u := _internalList[i]
                IF u:IsArray
                    VAR aElement := (ARRAY) u
                    IF aElement != NULL_ARRAY
                        aResult:_internalList[i] := aElement:Clone()
                    ELSE
                        aResult:_internalList[i] := aElement
                    ENDIF
                ELSE
                    aResult:_internalList[i] := u
                ENDIF
            NEXT
            RETURN aResult

        INTERNAL METHOD CloneShallow() AS ARRAY
            RETURN (ARRAY) SUPER:Clone()


        /// <include file="RTComments.xml" path="Comments/ZeroBasedIndexProperty/*" /> 
        /// <param name="index"><include file="RTComments.xml" path="Comments/ZeroBasedIndexParam/*" /></param>
        /// <returns>The value of the property of the element stored at the indicated location in the array.</returns>
        NEW PUBLIC PROPERTY SELF[index AS INT] AS USUAL
            GET
                RETURN __GetElement(index)
            END GET
            SET
                SELF:__SetElement(value,index)
            END SET
        END PROPERTY


        /// <include file="RTComments.xml" path="Comments/ZeroBasedIndexProperty/*" /> 
        /// <param name="index"><include file="RTComments.xml" path="Comments/ZeroBasedIndexParam/*" /></param>
        /// <param name="index2"><include file="RTComments.xml" path="Comments/ZeroBasedIndexParam/*" /></param>
        /// <returns>The value of the property of the element stored at the indicated location in the array.</returns>
        NEW PUBLIC PROPERTY SELF[index AS INT, index2 AS INT] AS USUAL
            GET
                RETURN __GetElement(index,index2)
            END GET
            SET
                SELF:__SetElement(value,index,index2)
            END SET
        END PROPERTY



        /// <include file="RTComments.xml" path="Comments/ZeroBasedIndexProperty/*" /> 
        /// <param name="indices"><include file="RTComments.xml" path="Comments/ZeroBasedIndexParam/*" /></param>
        /// <returns>The value of the property of the element stored at the indicated location in the array.</returns>
        PUBLIC PROPERTY SELF[indices PARAMS INT[]] AS USUAL
            GET
                RETURN __GetElement(indices)
            END GET
            SET
                SELF:__SetElement(value,indices)
            END SET
        END PROPERTY

        /// <summary>Returns the default value for array elements when arrays are resized or initialized. This is NIL.</summary>
        [DebuggerBrowsable(DebuggerBrowsableState.Never)];
        PUBLIC OVERRIDE PROPERTY DefaultValue AS USUAL GET NIL

        NEW INTERNAL METHOD Swap(position AS INT, element AS USUAL) AS USUAL
            RETURN SUPER:Swap(position, element)



        /// <include file="RTComments.xml" path="Comments/ZeroBasedIndexProperty/*" />
        /// <param name="index"><include file="RTComments.xml" path="Comments/ZeroBasedIndexParam/*" /></param>
        /// <returns>The element stored at the specified location in the array.</returns>
        NEW PUBLIC METHOD __GetElement(index AS INT) AS USUAL
			RETURN SELF:_internalList[ index ]

        /// <include file="RTComments.xml" path="Comments/ZeroBasedIndexProperty/*" />
        /// <param name="index"><include file="RTComments.xml" path="Comments/ZeroBasedIndexParam/*" /></param>
        /// <returns>The element stored at the specified location in the array.</returns>
        PUBLIC METHOD __GetElement(index AS INT, index2 AS INT) AS USUAL
            VAR u := SELF:_internalList[ index ]
            IF !u:IsArray
                THROW Error{ArgumentOutOfRangeException{nameof(index2)}}
            ENDIF
			VAR a := (ARRAY) u
            RETURN a:_internalList [index2]


        /// <include file="RTComments.xml" path="Comments/ZeroBasedIndexProperty/*" />
        /// <param name="indices"><include file="RTComments.xml" path="Comments/ZeroBasedIndexParam/*" /></param>
        /// <returns>The element stored at the specified location in the array.</returns>
        PUBLIC METHOD __GetElement(indices PARAMS INT[]) AS USUAL
            LOCAL length := indices:Length AS INT
            LOCAL currentArray AS ARRAY
            LOCAL i AS INT
            currentArray := SELF
            FOR i:= 1  UPTO length  -1 // walk all but the last level
                LOCAL u := currentArray:_internalList[ indices[i] ] AS USUAL
                IF u:IsNil
                    RETURN u
                ENDIF
                IF (OBJECT) u IS IIndexedProperties .AND. i == length-1
                    LOCAL o := (IIndexedProperties) (OBJECT) u AS IIndexedProperties
                    RETURN o[indices[length]]
                ENDIF
                IF !u:IsArray
                    THROW Error{ArgumentOutOfRangeException{nameof(indices)}}
                ENDIF
                currentArray := (ARRAY) u
            NEXT
            RETURN currentArray:_internalList[ indices[length] ]

        INTERNAL METHOD DebuggerString() AS STRING
            LOCAL sb AS StringBuilder
            LOCAL cnt, tot AS LONG
            sb := StringBuilder{}
            sb:Append(SELF:ToString())
            sb:Append("{")
            tot := _internalList:Count
            cnt := 0
            FOREACH VAR element IN SELF:_internalList
                IF cnt > 0
                    sb:Append(",")
                ENDIF
                sb:Append(element:ToString())
                cnt++
                IF cnt > 5
                    IF cnt < tot
                        sb:Append(",..")
                    ENDIF
                    EXIT
                ENDIF
            NEXT
            sb:Append("}")
            RETURN sb:ToString()


        /// <include file="RTComments.xml" path="Comments/ZeroBasedIndexProperty/*" />
        /// <param name="index"><include file="RTComments.xml" path="Comments/ZeroBasedIndexParam/*" /></param>
        /// <returns>The element stored at the specified location in the array.</returns>
        NEW PUBLIC METHOD __SetElement(u AS USUAL, index AS INT) AS USUAL
			IF SELF:CheckLock()
			    SELF:_internalList[ index ] := u
            ENDIF
            RETURN u


        /// <include file="RTComments.xml" path="Comments/ZeroBasedIndexProperty/*" />
        /// <param name="index"><include file="RTComments.xml" path="Comments/ZeroBasedIndexParam/*" /></param>
        /// <param name="index2"><include file="RTComments.xml" path="Comments/ZeroBasedIndexParam/*" /></param>
        /// <returns>The element stored at the specified location in the array.</returns>
        PUBLIC METHOD __SetElement(u AS USUAL, index AS INT, index2 AS INT) AS USUAL
            IF SELF:CheckLock()
			    VAR uElement := SELF:_internalList[ index ]
                IF !uElement:IsArray
                    THROW Error{ArgumentOutOfRangeException{nameof(index2)}}
                ENDIF
			    VAR a := (ARRAY) uElement
                a:_internalList [index2] := u
            ENDIF
            RETURN u



        /// <include file="RTComments.xml" path="Comments/ZeroBasedIndexProperty/*" />
        /// <param name="indices"><include file="RTComments.xml" path="Comments/ZeroBasedIndexParam/*" /></param>
        /// <param name='u'>New element to store in the array at the position specified</param>
        /// <returns>The new element</returns>
        PUBLIC METHOD __SetElement(u AS USUAL, indices PARAMS INT[] ) AS USUAL
            // indices are 0 based
            IF SELF:CheckLock()
                LOCAL length := indices:Length AS INT
                LOCAL currentArray := SELF AS ARRAY
                FOR VAR i := 1 UPTO length-1
                    LOCAL uArray := currentArray:_internalList[indices[i]] AS USUAL
                    IF (OBJECT) u IS IIndexedProperties .AND. i == length-1
                        LOCAL o := (IIndexedProperties) (OBJECT) u AS IIndexedProperties
                        o[indices[length]] := u
                        RETURN u
                    ENDIF
                    IF ! uArray:IsArray
                        THROW Error{ArgumentOutOfRangeException{nameof(indices)}}
                    ENDIF
                    currentArray := (ARRAY) uArray
                NEXT
                currentArray:_internalList[indices[length]] := u
            ENDIF
            RETURN u

       /// <summary>Implicit conversion to OBJECT[]. SubArrays become nested OBJECT[] arrays.</summary>
        STATIC OPERATOR IMPLICIT ( a AS __Array) AS OBJECT[]
            LOCAL aResult := List<OBJECT>{} AS List<OBJECT>
            FOREACH VAR uElement IN a
                IF uElement:IsArray
                    LOCAL aSubArray AS ARRAY
                    aSubArray := uElement
                    aResult:Add( (OBJECT[]) aSubArray)
                ELSE
                    aResult:Add(  (OBJECT) uElement)
                ENDIF
            NEXT
            RETURN aResult:ToArray()

        /// <exclude/>
        STATIC OPERATOR IMPLICIT ( a AS OBJECT[]) AS __Array
            RETURN __Array{a}

        INTERNAL STATIC METHOD Copy(aSource AS ARRAY,aTarget AS ARRAY,;
            start AS LONG, sourceLen AS LONG, offSet AS LONG, targetLen AS LONG ) AS VOID
            LOCAL x AS LONG
            // Adjust
            start-=1
            offSet-=1
            sourceLen-=1
            targetLen-=1
            IF start < sourceLen
                FOR x := start UPTO sourceLen
                    aTarget:_internalList[offSet] := aSource:_internalList[ x]
                    offSet++
                    IF offSet > targetLen
                        EXIT
                    ENDIF
                NEXT
            ELSE
                FOR x := start DOWNTO sourceLen
                    aTarget:_internalList[offSet] := aSource:_internalList[x]
                    offSet++
                    IF offSet > targetLen
                        EXIT
                    ENDIF
                NEXT
            ENDIF
            RETURN

        NEW INTERNAL METHOD Sort(startIndex AS INT, count AS INT, comparer AS IComparer<__Usual>) AS VOID
           IF startIndex <= 0
                startIndex := 1
            ENDIF
            IF count < 0
                count := _internalList:Count - startIndex + __ARRAYBASE__
            ENDIF
            _internalList:Sort(startIndex-__ARRAYBASE__ ,count,comparer)
            RETURN
        /// <exclude/>
        PUBLIC METHOD Invoke(index PARAMS INT[]) AS USUAL
            FOR VAR i := 1 TO index:Length 
                index[i] -= 1
            NEXT
            RETURN SELF:__GetElement(index)

        INTERNAL CLASS ArrayDebugView
            PRIVATE _value AS ARRAY
            PUBLIC CONSTRUCTOR (a AS ARRAY)
                _value := a
                //[DebuggerBrowsable(DebuggerBrowsableState.RootHidden)] ;
           PUBLIC PROPERTY Elements AS List<USUAL> GET _value:_internalList


        END CLASS

    END	CLASS


END NAMESPACE
