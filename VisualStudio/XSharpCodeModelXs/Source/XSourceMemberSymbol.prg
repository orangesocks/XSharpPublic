//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
USING System.Collections.Generic
USING System.Diagnostics
USING XSharpModel
USING LanguageService.CodeAnalysis.XSharp
USING LanguageService.SyntaxTree
USING LanguageService.CodeAnalysis.XSharp.SyntaxParser

BEGIN NAMESPACE XSharpModel

   [DebuggerDisplay("{ToString(),nq}")];
   CLASS XSourceMemberSymbol INHERIT XSourceEntity IMPLEMENTS IXMemberSymbol
      // Fields
      PRIVATE _signature    AS XMemberSignature 
      PROPERTY InitExit     AS STRING AUTO
      PROPERTY SubType      AS Kind AUTO
      PROPERTY DeclaringType  AS STRING AUTO
      PROPERTY ReturnType   AS STRING GET TypeName SET TypeName := value
      PROPERTY SourceCode   AS STRING AUTO      
      #region constructors
      
      CONSTRUCTOR(name AS STRING, kind AS Kind, attributes AS Modifiers, ;
            span AS TextRange, position AS TextInterval, returnType AS STRING, isStatic := FALSE AS LOGIC)
         SUPER(name, kind, attributes, span, position)
         SELF:Parent       := NULL
         SELF:ReturnType   := returnType
         SELF:IsStatic     := isStatic
         SELF:_signature   := XMemberSignature{}
         
      CONSTRUCTOR(sig as XMemberSignature, kind AS Kind, attributes AS Modifiers,  ;
            span AS TextRange, position AS TextInterval, isStatic := FALSE AS LOGIC)
         SUPER(sig:Id, kind, attributes, span, position)
         SELF:Parent       := NULL
         SELF:ReturnType   := sig:DataType
         SELF:IsStatic     := isStatic
         SELF:_signature   := sig
         FOREACH var par in sig:Parameters
            par:Parent := SELF
         NEXT         
         #endregion
      
      
      METHOD AddParameters( list AS IList<XSourceParameterSymbol>) AS VOID
         IF list != NULL
            FOREACH VAR par IN list
               SELF:AddParameter(par)
            NEXT
         ENDIF
         RETURN
         
      METHOD AddParameter(oVar AS XSourceParameterSymbol) AS VOID
         oVar:Parent := SELF
         oVar:File   := SELF:File
         _signature:Parameters:Add(oVar)
         oVar:Parent := SELF
         RETURN
         
         
      #region Properties. Some are implemented as Extension methods, others forwarded to the signature
      PROPERTY Description AS STRING GET SELF:GetDescription()
 		PROPERTY FullName AS STRING GET SELF:GetFullName()
      
      PROPERTY HasParameters     AS LOGIC GET _signature:HasParameters
      PROPERTY ParameterCount    AS INT   GET _signature:ParameterCount
      
      PROPERTY ParameterList      AS STRING GET _signature:ParameterList
      
     PROPERTY ComboParameterList AS STRING
         GET
            VAR parameters := ""
            FOREACH variable AS IXVariableSymbol IN SELF:Parameters
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
      PROPERTY Parameters         AS IList<IXVariableSymbol> GET _signature:Parameters:ToArray()
      
      PROPERTY Signature         AS XMemberSignature  GET _signature SET _signature := @@value
      PROPERTY CallingConvention AS CallingConvention GET _signature:CallingConvention SET _signature:CallingConvention := @@value
      
      
      PROPERTY Prototype      AS STRING GET SELF:GetProtoType()
      
      PROPERTY ComboPrototype AS STRING 
         GET
            VAR vars := ""
            VAR desc := ""
            IF SELF:Kind:HasParameters()
               IF ( SELF:Kind == Kind.@@Constructor )
                  vars := "{" + SELF:ComboParameterList + "}"
               ELSEIF SELF:Kind:IsProperty()
                    IF SELF:ParameterCount > 0
                        vars := "[" + SELF:ComboParameterList + "]"
                    ENDIF
               ELSE
                  vars := "(" + SELF:ComboParameterList + ")"
               ENDIF 
            ENDIF
            IF ( SELF:Kind == Kind.@@Constructor )
               desc := SELF:Parent:Name + vars
            ELSE
               desc := SELF:Name + vars
            ENDIF
            IF SELF:Kind:HasReturnType()
               desc := desc +  XLiterals.AsKeyWord + SELF:TypeName
            ENDIF
            RETURN desc
         END GET
      END PROPERTY
         
      PROPERTY ParentType     AS IXTypeSymbol   
      GET 
         IF SELF:Parent IS IXTypeSymbol
            RETURN (IXTypeSymbol) SELF:Parent
         ENDIF
         IF SELF:Parent IS IXMemberSymbol
            RETURN ((IXMemberSymbol) SELF:Parent):ParentType
         ENDIF
         RETURN NULL
      END GET
      END PROPERTY
      PROPERTY IsExtension    AS LOGIC    GET _signature:IsExtension
      PROPERTY XMLSignature   AS STRING GET SELF:GetXmlSignature()
      PROPERTY OriginalTypeName  AS STRING               GET SELF:TypeName
      PROPERTY TypeParameters as IList<STRING>           GET SELF:_signature:TypeParameters:ToArray()
      PROPERTY TypeParametersList AS STRING              GET SELF:_signature:TypeParametersList
      PROPERTY TypeParameterConstraints as IList<STRING> GET SELF:_signature:TypeParameterContraints:ToArray()
      PROPERTY TypeParameterConstraintsList AS STRING    GET SELF:_signature:TypeParameterConstraintsList
      PROPERTY Location       AS STRING GET SELF:File:FullPath
      
      PROPERTY ModifiersKeyword as STRING
         GET
            IF SELF:Kind:IsLocal()
               RETURN ""
            ELSE
               RETURN SUPER:ModifiersKeyword
            ENDIF
         END GET
      END PROPERTY

      PROPERTY VisibilityKeyword as STRING
         GET
            IF SELF:Kind:IsLocal()
               RETURN "PRIVATE"
            ELSE
               RETURN SUPER:VisibilityKeyword
            ENDIF
         END GET
      END PROPERTY
         
      PROPERTY Glyph                   AS LONG
         GET 
            VAR glyph := SUPER:Glyph
            IF SELF:Name:EndsWith(XLiterals.XppDeclaration)
               glyph := glyph - (glyph % 6) + ImageListOverlay.ImageListOverlayArrow
            ENDIF
            RETURN glyph
         END GET
      END PROPERTY

     METHOD WithName(newName as STRING) AS IXMemberSymbol
        var clone := (XSourceMemberSymbol) SELF:MemberwiseClone()
        clone:Name := newName
        clone:_signature := SELF:_signature:Clone()
        RETURN (IXMemberSymbol) clone

//     METHOD WithGenericArgs(args as List<String>) AS IXMemberSymbol
//        var clone := (XSourceMemberSymbol) SELF:MemberwiseClone()
//        var orgTypeArgs     := List<String>{}
//        var orgParameters   := SELF:Parameters
//        clone:_signature := SELF:_signature:Clone()
//        orgTypeArgs:AddRange(SELF:TypeParameters)
//        clone:_signature:TypeParameters:Clear()
//        clone:_signature:TypeParameters:AddRange(args)
//        clone:_signature:Parameters := List<IXVariableSymbol>{}
//        if args:Count >= orgTypeArgs:Count
//            FOREACH par as IXVariableSymbol in orgParameters
//                var type := par:TypeName
//                var index := orgTypeArgs:IndexOf(type)
//                if index >= 0
//                    var newpar := par:Clone()
//                    newpar:TypeName := args[index]
//                    clone:_signature:Parameters:Add(newpar)  
//                else
//                  clone:_signature:Parameters:Add(par)  
//                
//                ENDIF
//            NEXT
//        ENDIF        
//        RETURN (IXMemberSymbol) clone


      METHOD ToString() AS STRING
         VAR result := i"{Kind} {Name}"
         if SELF:_signature != NULL .and. SELF:_signature:TypeParameters:Count > 0
            result += self:_signature:ToString()
         ENDIF
         RETURN result

      #endregion
   END CLASS
   
END NAMESPACE

