//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
USING System
USING System.Linq
USING System.Collections.Generic
USING LanguageService.CodeAnalysis.Text
USING LanguageService.CodeAnalysis.XSharp
USING System.Diagnostics

BEGIN NAMESPACE XSharpModel
   /// <summary>
      /// Model for Namespace, Class, Interface, Structure, Enum
   /// </summary>
   [DebuggerDisplay("{ToString(),nq}")];
   CLASS XSourceTypeSymbol INHERIT XSourceEntity IMPLEMENTS IXTypeSymbol
      PRIVATE _isPartial      AS LOGIC
      PRIVATE _members        AS IList<XSourceMemberSymbol>
      PRIVATE _children       AS List<XSourceTypeSymbol>
      PRIVATE _signature      AS XTypeSignature
      PRIVATE _isClone        AS LOGIC
      PROPERTY SourceCode     AS STRING AUTO
      PROPERTY ShortName      AS STRING  GET IIF(!SELF:IsGeneric, SELF:Name, SELF:Name:Substring(0, SELF:Name:IndexOf("<")-1))
            
      
      CONSTRUCTOR(name AS STRING, kind AS Kind, attributes AS Modifiers, span AS TextRange, position AS TextInterval, oFile AS XFile)
         SUPER(name, kind, attributes, span, position)
         SELF:_members     := List<XSourceMemberSymbol>{}
         SELF:_children    := List<XSourceTypeSymbol>{}
         SELF:_signature   := XTypeSignature{""}
         SELF:ClassType    := XSharpDialect.Core
         SELF:Namespace    := ""
         IF attributes:HasFlag(Modifiers.Static)
            SELF:IsStatic := TRUE
         ENDIF
         IF attributes:HasFlag(Modifiers.Partial)
            SELF:_isPartial := TRUE
         ENDIF
         SELF:File := oFile
         
         /// <summary>
            /// Duplicate the current Object, so we have the same properties in another object
            /// </summary>
         /// <returns></returns>
      CONSTRUCTOR( oOther AS XSourceTypeSymbol)
         SELF(oOther:Name, oOther:Kind, oOther:Attributes, oOther:Range, oOther:Interval, oOther:File)
         SELF:Parent    := oOther:Parent
         SELF:BaseType  := oOther:BaseType
         SELF:IsPartial := oOther:IsPartial
         SELF:IsStatic  := oOther:IsStatic
         SELF:Namespace := oOther:Namespace
         SELF:AddMembers(oOther:XMembers)
         SELF:_isClone  := TRUE
         RETURN
         
      METHOD AddChild(oChild AS XSourceTypeSymbol) AS VOID
         BEGIN LOCK SELF:_children
            SELF:_children:Add(oChild)
            oChild:Parent := SELF
         END LOCK
         
      METHOD AddMember(oMember AS XSourceMemberSymbol) AS VOID
         BEGIN LOCK SELF:_members
            SELF:_members:Add(oMember)
            oMember:Parent := SELF
             
         END LOCK
         
      METHOD AddMembers(members AS IEnumerable<XSourceMemberSymbol>) AS VOID
         BEGIN LOCK SELF:_members
            FOREACH VAR oMember IN members
               SELF:_members:Add(oMember)
               oMember:Parent := SELF
            NEXT
         END LOCK

      INTERNAL METHOD SetInterfaces (interfaces as IList<String>) AS VOID
         SELF:_signature:Interfaces:Clear()
         SELF:_signature:Interfaces:AddRange(interfaces)
         
      METHOD AddInterface(sInterface AS STRING) AS VOID
         SELF:_signature:AddInterface(sInterface)
         
      METHOD AddTypeParameter(name AS STRING) AS VOID
         SELF:_signature:TypeParameters:Add(name)
         
      METHOD AddConstraints(name AS STRING) AS VOID
         SELF:_signature:TypeParameterContraints:Add(name)
         
      PROPERTY Interfaces  AS IList<STRING>              GET SELF:_signature:Interfaces:ToArray()
      PROPERTY InterfaceList AS STRING                   GET SELF:_signature:InterfaceList
      PROPERTY IsGlobal    AS LOGIC                      GET SELF:Name == XLiterals.GlobalName
      PROPERTY TypeParameters as IList<STRING>           GET SELF:_signature:TypeParameters:ToArray()
      PROPERTY TypeParametersList AS STRING              GET SELF:_signature:TypeParametersList
      PROPERTY TypeParameterConstraints as IList<STRING> GET SELF:_signature:TypeParameterContraints:ToArray()
      PROPERTY TypeParameterConstraintsList  AS STRING   GET SELF:_signature:TypeParameterConstraintsList
      PROPERTY Location                      AS STRING   GET SELF:File:FullPath   
      PROPERTY OriginalTypeName              AS STRING   GET SELF:TypeName

      METHOD ClearMembers() AS VOID
         SELF:_members:Clear()

      PROPERTY Members AS IList<IXMemberSymbol>  
         GET
            BEGIN LOCK SELF:_members
               RETURN SELF:_members:ToArray()
            END LOCK
         END GET
      END PROPERTY
      
      PROPERTY XMembers AS IList<XSourceMemberSymbol>
         GET
            BEGIN LOCK SELF:_members
               RETURN SELF:_members:ToArray()
            END LOCK
         END GET
      END PROPERTY
      
      METHOD GetMembers(elementName AS STRING) AS IList<IXMemberSymbol>
         VAR tempMembers := List<IXMemberSymbol>{}
          IF elementName:StartsWith("@@")
                elementName := elementName:Substring(2)
          ENDIF
         if ! String.IsNullOrEmpty(elementName)
            tempMembers:AddRange(SELF:_members:Where({ m => m.Name:StartsWith(elementName, StringComparison.OrdinalIgnoreCase)} ))
         ELSE
            tempMembers:AddRange(SELF:_members)      
         ENDIF
         RETURN tempMembers

      METHOD GetMembers(elementName AS STRING, lExact as LOGIC) AS IList<IXMemberSymbol>
          IF elementName:StartsWith("@@")
                elementName := elementName:Substring(2)
          ENDIF
         IF lExact
            VAR result := List<IXMemberSymbol>{}
            result:AddRange(SELF:_members:Where ({ m => m.Name:Equals(elementName, StringComparison.OrdinalIgnoreCase)} ))
            RETURN result
         ELSE
            RETURN SELF:GetMembers(elementName)
         ENDIF

      METHOD ForceComplete as VOID
        IF SELF:Attributes:HasFlag(Modifiers.Partial) 
             // Find all other parts to find the base typename
             var oClone := SELF:Clone
             SELF:_signature:BaseType := oClone:BaseType
             var aIF := oClone:Interfaces:ToArray()
             SELF:SetInterfaces(aIF)
             
        ENDIF
        RETURN

      PROPERTY FullName  AS STRING   GET SELF:GetFullName()
      PROPERTY IsGeneric as LOGIC   GET SELF:TypeName:EndsWith(">")
      
      /// <summary>
         /// Merge two XSourceTypeSymbol Objects : Used to create the resulting  XSourceTypeSymbol from 2 or more partial classes
         /// </summary>
      /// <param name="otherType"></param>
      METHOD Merge(otherType AS XSourceTypeSymbol) AS XSourceTypeSymbol
         LOCAL clone AS XSourceTypeSymbol
         IF ! self:_isClone
            clone := XSourceTypeSymbol{SELF}
         ELSE
            clone := SELF
         ENDIF
         VAR otherFile := otherType:File:FullPath:ToLower()
         VAR thisFile  := SELF:File:FullPath:ToLower()
         IF otherFile != thisFile  
            SELF:IsPartial := TRUE
            IF otherType != NULL
               clone:AddMembers(otherType:XMembers)
               IF clone:Parent == NULL .AND. otherType:Parent != NULL
                  clone:Parent := otherType:Parent
               ELSE
                  IF String.IsNullOrEmpty(clone:BaseType) .AND. !String.IsNullOrEmpty(otherType:BaseType)
                     clone:BaseType := otherType:BaseType
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
         RETURN clone
         
      /// <summary>
      /// If this XSourceTypeSymbol is a Partial type, return a Copy of it, merged with all other informations
      /// coming from other files.
      /// </summary>
         
      PROPERTY Clone AS XSourceTypeSymbol
         GET
            IF SELF:IsPartial .AND. SELF:File != NULL
               RETURN SUPER:File:Project:Lookup(SELF:FullName, SELF:File:Usings:ToArray())
            ENDIF
            RETURN SELF
         END GET
      END PROPERTY
     
      PROPERTY BaseType          AS STRING GET SELF:_signature:BaseType SET SELF:_signature:BaseType := @@value
      PROPERTY ComboPrototype    AS STRING GET SELF:FullName
      PROPERTY Description       AS STRING GET SELF:GetDescription()
      PROPERTY IsPartial         AS LOGIC  GET SELF:_isPartial SET SELF:_isPartial := VALUE
      PROPERTY IsNested          AS LOGIC  GET SELF:Parent IS XSourceTypeSymbol
      PROPERTY ClassType         AS XSharpDialect AUTO
      
      STATIC METHOD CreateGlobalType(xfile AS XFile) AS XSourceTypeSymbol
         VAR globalType := XSourceTypeSymbol{XLiterals.GlobalName, Kind.Class, Modifiers.Public+Modifiers.Static, TextRange{0, 0, 0, 0}, TextInterval{}, xfile}
         globalType:IsPartial:=TRUE
         RETURN globalType
      
      STATIC METHOD IsGlobalType(type AS IXSymbol) AS LOGIC
         RETURN type != NULL .AND. type is IXTypeSymbol .and. type:Name == XLiterals.GlobalName
      
      PROPERTY Children   AS IList<IXTypeSymbol> 
         GET 
            BEGIN LOCK SELF:_children
               return SELF:_children:ToArray()
            END LOCK
         END GET
      END PROPERTY
      
      PROPERTY XChildren   AS IList<XSourceTypeSymbol>  
         GET 
            BEGIN LOCK SELF:_children
               return SELF:_children:ToArray()
            END LOCK
         END GET
      END PROPERTY
      PROPERTY XMLSignature   AS STRING GET SELF:GetXmlSignature()
   
 
      
   METHOD ToString() AS STRING
      var result := i"{Kind} {Name}"
      if SELF:_signature != NULL .and. SELF:_signature:TypeParameters:Count > 0
         result += self:_signature:ToString()
      ENDIF
      RETURN result
      
END CLASS

END NAMESPACE

