//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
USING System.Collections.Generic
USING System.Diagnostics
USING XSharpModel
USING LanguageService.CodeAnalysis.XSharp

BEGIN NAMESPACE XSharpModel
	[DebuggerDisplay("{Kind}, {Name,nq}")];
	CLASS XTypeMember INHERIT XElement
		// Fields
		PRIVATE _parameters     AS List<XVariable>
        PRIVATE _typeParameters AS List<STRING>
        PRIVATE _constraints    AS List<STRING>
        PRIVATE _callconv       AS STRING
		
		#region constructors
		
		CONSTRUCTOR(name AS STRING, kind AS Kind, modifiers AS Modifiers, visibility AS Modifiers, span AS TextRange, position AS TextInterval, typeName AS STRING, isStatic := FALSE AS LOGIC)
			SUPER(name, kind, modifiers, visibility, span, position)
			SELF:Parent := NULL
			SELF:_parameters := List<XVariable>{}
			SELF:TypeName  := typeName
			SELF:_isStatic := isStatic
			
		STATIC METHOD create(oElement AS EntityObject, oInfo AS ParseResult, oFile AS XFile, oType AS XType, dialect AS XSharpDialect ) AS XTypeMember
			LOCAL cName := oElement:cName AS STRING
			LOCAL kind  := Etype2Kind(oElement:eType) AS Kind
			LOCAL cType := oElement:cRetType AS STRING
			LOCAL mods  := oElement:eModifiers:ToModifiers() AS Modifiers
			LOCAL vis   := oElement:eAccessLevel:ToModifiers() AS Modifiers
			LOCAL span   AS textRange
			LOCAL intv   AS TextInterval
			LOCAL isStat := oElement:lStatic AS LOGIC
			mods &=  ~Modifiers.VisibilityMask	// remove lower 2 nibbles which contain visibility
			CalculateRange(oElement, oInfo, OUT span, OUT intv)
			LOCAL result := XTypeMember{cName, kind, mods, vis, span, intv, cType, isStat} AS XTypeMember
			result:File := oFile
			result:Dialect := dialect
			IF oElement:aParams != NULL
				FOREACH oParam AS EntityParamsObject IN oElement:aParams
					LOCAL oVar AS XVariable
					span := TextRange{oElement:nStartLine, oParam:nCol, oElement:nStartLine, oParam:nCol+oParam:cName:Length}
					intv := TextInterval{oElement:nOffSet+oParam:nCol, oElement:nOffSet+oParam:nCol+oParam:cName:Length}
					oVar := XVariable{result, oParam:cName, Kind.Local,  span, intv, oParam:cType, TRUE}
					oVar:ParamType := oParam:nParamType
					result:AddParameter(oVar)
				NEXT
			ENDIF
			IF oElement:eType == EntityType._Define .or. oElement:eType == EntityType._EnumMember
				result:Value := oElement:cValue
			ENDIF
			RETURN result
			
			
		#endregion
		

        METHOD AddTypeParameter(name AS STRING) AS VOID
            IF SELF:_typeParameters == NULL
                SELF:_typeParameters := List<STRING>{}
            ENDIF
            SELF:_typeParameters:Add(name)
            RETURN

        METHOD AddConstraints(name AS STRING) AS VOID
            IF SELF:_constraints == NULL
                SELF:_constraints := List<STRING>{}
            ENDIF
            SELF:_constraints:Add(name)
            RETURN


        METHOD AddParameters( list AS ILIst<XVariable>) AS VOID
            IF list != NULL
                FOREACH VAR par IN list
                    SELF:AddParameter(par)
                NEXT
            ENDIF
            RETURN
            
		METHOD AddParameter(oVar AS XVariable) AS VOID
			oVar:Parent := SELF
			oVar:File := SELF:File
			_parameters:Add(oVar)
			RETURN
			
		METHOD Namesake() AS List<XTypeMember>
			VAR _namesake := List<XTypeMember>{}
			IF (SELF:Parent != NULL)
				FOREACH  oMember AS XTypeMember IN ((XType) SELF:Parent):Members
					IF String.Compare(oMember:FullName, SELF:FullName, TRUE) == 0 .AND. String.Compare(oMember:Prototype, SELF:Prototype, TRUE) > 0
						////
						_namesake:Add(oMember)
					ENDIF
				NEXT
			ENDIF
			RETURN _namesake
			//
			#region Properties
		PROPERTY Description AS STRING
			GET
				VAR modVis := ""
				IF (SUPER:Modifiers != Modifiers.None)
					modVis := modVis + SUPER:ModifiersKeyword
				ENDIF
				VAR desc := modVis + VisibilityKeyword
				IF ( SELF:IsStatic )
					desc += "STATIC "
				ENDIF 
				IF (SUPER:Kind != Kind.Field)
					desc := desc + SUPER:KindKeyword
					IF (SUPER:Kind == Kind.VODefine)
						RETURN desc + SUPER:Name
					ENDIF
				ENDIF
				RETURN desc + SELF:Prototype
			END GET
		END PROPERTY
		
		PROPERTY FullName AS STRING
			GET
				//
				IF (SELF:Parent != NULL)
					//
					RETURN SELF:Parent:FullName +"." + SUPER:Name
				ENDIF
				RETURN SUPER:Name
			END GET
		END PROPERTY
		
		PROPERTY HasParameters AS LOGIC GET SELF:Kind:HasParameters() .AND. SELF:_parameters:Count > 0
		PROPERTY ParameterCount  AS INT GET SELF:_parameters:Count

        PROPERTY CallingConvention AS STRING GET SELF:_callconv SET SELF:_callconv := value
        PROPERTY InitExit          AS STRING GET SELF:Value     SET SELF:Value:= value
        PROPERTY SubType           AS STRING GET SELF:Value     SET SELF:Value:= value
 
		NEW PROPERTY Parent AS XType GET (XType) SUPER:parent  SET SUPER:parent := VALUE
		
		PROPERTY ParameterList AS STRING
			GET
				VAR parameters := ""
				FOREACH variable AS XVariable IN SELF:Parameters
					IF (parameters:Length > 0)
						parameters := parameters + ", "
					ENDIF
					parameters += variable:Name
					IF variable:IsTyped
						parameters += variable:ParamTypeDesc + variable:TypeName
					ENDIF
				NEXT
				RETURN parameters
			END GET
		END PROPERTY
		
		PROPERTY ComboParameterList AS STRING
			GET
				VAR parameters := ""
				FOREACH variable AS XVariable IN SELF:Parameters
					IF (parameters:Length > 0)
						parameters := parameters + ", "
					ENDIF
					VAR cType := variable:ShortTypeName
					IF variable:IsTyped .AND. variable:ParamType != ParamType.As
						parameters += variable:ParamTypeDesc + cType
					ELSE
						parameters += cType
					ENDIF
				NEXT
				RETURN parameters
			END GET
		END PROPERTY
		
		PROPERTY Parameters AS IEnumerable<XVariable>
			GET
				RETURN SELF:_parameters
			END GET
		END PROPERTY
		
		PROPERTY Prototype AS STRING
			GET
				VAR vars := ""
				VAR desc := ""
				IF SELF:Kind:HasParameters()
					IF ( SELF:Kind == Kind.@@Constructor )
						vars := "{" + SELF:ParameterList + "}"
					ELSE
						vars := "(" + SELF:ParameterList + ")"
					ENDIF 
				ENDIF
				IF SELF:Kind == Kind.VODefine .OR. SELF:Kind == Kind.EnumMember
					vars := " "+SELF:Value
				ENDIF
				IF ( SELF:Kind == Kind.@@Constructor )
					desc := SELF:Parent:FullName + vars
				ELSE
					desc := SUPER:Name + vars
				ENDIF 
				// Maybe we should check the Dialect ?
				IF SELF:Kind:HasReturnType( SELF:Dialect ) .AND. ! String.IsNullOrEmpty(SELF:TypeName)
					desc := desc + AsKeyWord + SELF:TypeName
				ENDIF
				RETURN desc
			END GET
		END PROPERTY
		
		PROPERTY ComboPrototype AS STRING
			GET
				VAR vars := ""
				VAR desc := ""
				IF SELF:Kind:HasParameters()
					IF ( SELF:Kind == Kind.@@Constructor )
						vars := "{" + SELF:ComboParameterList + "}"
					ELSE
						vars := "(" + SELF:ComboParameterList + ")"
					ENDIF 
				ENDIF
				IF ( SELF:Kind == Kind.@@Constructor )
					desc := SELF:Parent:FullName + vars
				ELSE
					desc := SUPER:Name + vars
				ENDIF
				// Maybe we should check the Dialect ?
				IF SELF:Kind:HasReturnType( SELF:Dialect ) .AND. ! String.IsNullOrEmpty(SELF:TypeName)
					desc := desc + AsKeyWord + SELF:TypeName
				ENDIF
				RETURN desc
			END GET
		END PROPERTY
		
		#endregion
	END CLASS
	
END NAMESPACE

