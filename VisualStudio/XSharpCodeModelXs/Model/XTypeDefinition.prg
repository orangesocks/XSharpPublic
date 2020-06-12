//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
USING System
USING System.Collections.Generic
USING LanguageService.CodeAnalysis.Text
USING LanguageService.CodeAnalysis.XSharp
USING System.Diagnostics

BEGIN NAMESPACE XSharpModel
   /// <summary>
      /// Model for Namespace, Class, Interface, Structure, Enum
   /// </summary>
   [DebuggerDisplay("{ToString(),nq}")];
   CLASS XTypeDefinition INHERIT XEntityDefinition IMPLEMENTS IXType
      PRIVATE _isPartial      AS LOGIC
      PRIVATE _members        AS XSortedDictionary<String,XMemberDefinition>
      PRIVATE _children       AS List<XTypeDefinition>
      PRIVATE _signature      AS XTypeSignature
      PRIVATE _isClone        AS LOGIC
      
      CONSTRUCTOR(name AS STRING, kind AS Kind, attributes AS Modifiers, span AS TextRange, position AS TextInterval, oFile AS XFile)
         SUPER(name, kind, attributes, span, position)
         SELF:_members     := XSortedDictionary<String,XMemberDefinition>{MemberNameComparer{}}
         SELF:_children    := List<XTypeDefinition>{}
         SELF:_signature   := XTypeSignature{""}
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
      CONSTRUCTOR( oOther AS XTypeDefinition)
         SELF(oOther:Name, oOther:Kind, oOther:Attributes, oOther:Range, oOther:Interval, oOther:File)
         SELF:Parent    := oOther:Parent
         SELF:BaseType  := oOther:BaseType
         SELF:IsPartial := oOther:IsPartial
         SELF:IsStatic  := oOther:IsStatic
         SELF:Namespace := oOther:Namespace
         SELF:AddMembers(oOther:XMembers)
         SELF:_isClone  := TRUE
         RETURN
         
      METHOD AddChild(oChild AS XTypeDefinition) AS VOID
         BEGIN LOCK SELF:_children
            SELF:_children:Add(oChild)
            oChild:Parent := SELF
         END LOCK
         
      METHOD AddMember(oMember AS XMemberDefinition) AS VOID
         BEGIN LOCK SELF:_members
            SELF:_members:Add(oMember:Name, oMember)
            oMember:Parent := SELF
             
         END LOCK
         
      METHOD AddMembers(members AS IEnumerable<XMemberDefinition>) AS VOID
         BEGIN LOCK SELF:_members
            FOREACH VAR oMember IN members
               SELF:_members:Add(oMember:Name, oMember)
               oMember:Parent := SELF
            NEXT
         END LOCK
       
         
      METHOD AddInterface(sInterface AS STRING) AS VOID
         SELF:_signature:AddInterface(sInterface)
         
      METHOD AddTypeParameter(name AS STRING) AS VOID
         SELF:_signature:TypeParameters:Add(name)
         
      METHOD AddConstraints(name AS STRING) AS VOID
         SELF:_signature:TypeParameterContraints:Add(name)
         
      PROPERTY Interfaces  AS IList<STRING>              GET SELF:_signature:Interfaces:ToArray()
      PROPERTY InterfaceList AS STRING                   GET SELF:_signature:InterfaceList
      PROPERTY TypeParameters as IList<STRING>           GET SELF:_signature:TypeParameters:ToArray()
      PROPERTY TypeParametersList AS STRING              GET SELF:_signature:TypeParametersList
      PROPERTY TypeParameterConstraints as IList<STRING> GET SELF:_signature:TypeParameterContraints:ToArray()
      PROPERTY TypeParameterConstraintsList AS STRING    GET SELF:_signature:TypeParameterConstraintsList
         
      PROPERTY OriginalTypeName  AS STRING GET SELF:TypeName

      METHOD ClearMembers() AS VOID
         SELF:_members:Clear()

      PROPERTY Members AS IList<IXMember>  
         GET
            
            BEGIN LOCK SELF:_members
               RETURN SELF:_members:Values
            END LOCK
         END GET
      END PROPERTY
      
      PROPERTY XMembers AS IList<XMemberDefinition>
         GET
            BEGIN LOCK SELF:_members
               RETURN SELF:_members:Values
            END LOCK
         END GET
      END PROPERTY
      
      METHOD GetMembers(elementName AS STRING) AS IList<IXMember>
         VAR tempMembers := List<IXMember>{}
         if ! String.IsNullOrEmpty(elementName)
            SELF:_members:Sort()
            var matching := SELF:_members:FindMatching(elementName)
            tempMembers:AddRange(matching)
         ELSE
            tempMembers:AddRange(SELF:XMembers)      
         ENDIF
         RETURN tempMembers

      METHOD GetMembers(elementName AS STRING, lExact as LOGIC) AS IList<IXMember>
         LOCAL result as IList<IXMember>
         IF lExact
            result := List<IXMember>{}
            FOREACH var xmember in SELF:GetMembers(elementName)
               IF String.Compare(xmember:Name, elementName, StringComparison.OrdinalIgnoreCase) == 0
                  result:Add(xmember)
               ENDIF
            NEXT
         ELSE
            result := SELF:GetMembers(elementName)
         ENDIF
         RETURN result

      
      PROPERTY FullName  AS STRING   GET SELF:GetFullName()
      PROPERTY IsGeneric as LOGIC   GET SELF:TypeName:EndsWith(">")
      
      /// <summary>
         /// Merge two XTypeDefinition Objects : Used to create the resulting  XTypeDefinition from 2 or more partial classes
         /// </summary>
      /// <param name="otherType"></param>
      METHOD Merge(otherType AS XTypeDefinition) AS XTypeDefinition
         LOCAL clone AS XTypeDefinition
         IF ! self:_isClone
            clone := XTypeDefinition{SELF}
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
      /// If this XTypeDefinition is a Partial type, return a Copy of it, merged with all other informations
      /// coming from other files.
      /// </summary>
         
      PROPERTY Clone AS XTypeDefinition
         GET
            IF SELF:IsPartial .AND. SELF:File != NULL
               RETURN SUPER:File:Project:Lookup(SELF:FullName, TRUE)
            ENDIF
            RETURN SELF
         END GET
      END PROPERTY
     
      PROPERTY BaseType          AS STRING GET SELF:_signature:BaseType SET SELF:_signature:BaseType := @@value
      PROPERTY ComboPrototype    AS STRING GET SELF:FullName
      PROPERTY Description       AS STRING GET SELF:GetDescription()
      PROPERTY IsPartial         AS LOGIC  GET SELF:_isPartial SET SELF:_isPartial := VALUE
      PROPERTY IsNested          AS LOGIC  GET SELF:Parent IS XTypeDefinition
      
      
      STATIC METHOD CreateGlobalType(xfile AS XFile) AS XTypeDefinition
         VAR globalType := XTypeDefinition{XLiterals.GlobalName, Kind.Class, Modifiers.Public+Modifiers.Static, TextRange{0, 0, 0, 0}, TextInterval{}, xfile}
         globalType:IsPartial:=TRUE
         RETURN globalType
      
      STATIC METHOD IsGlobalType(type AS IXEntity) AS LOGIC
         RETURN type != NULL .AND. type is IXType .and. type:Name == XLiterals.GlobalName
      
      PROPERTY Children   AS IList<IXType> 
         GET 
            BEGIN LOCK SELF:_children
               return SELF:_children:ToArray()
            END LOCK
         END GET
      END PROPERTY
      
      PROPERTY XChildren   AS IList<XTypeDefinition>  
         GET 
            BEGIN LOCK SELF:_children
               return SELF:_children:ToArray()
            END LOCK
         END GET
      END PROPERTY
      PROPERTY XMLSignature   AS STRING GET SELF:GetXmlSignature()
   
   PRIVATE CLASS MemberNameComparer IMPLEMENTS IComparer<STRING>
      METHOD Compare(x as String, y as String) AS LONG
         if x == NULL .or. y == NULL
            return 0
         endif
         return String.Compare(x, 0, y, 0, y:Length, TRUE)
      END CLASS
      
   METHOD ToString() AS STRING
      var result := i"{Kind} {Name}"
      if SELF:_signature != NULL .and. SELF:_signature:TypeParameters:Count > 0
         result += self:_signature:ToString()
      ENDIF
      RETURN result
      
   
   STATIC PROPERTY DbSelectClause as STRING GET ""
   
   STATIC METHOD FromDb(aValues as object[]) AS XTypeDefinition
      RETURN NULL
       
END CLASS

END NAMESPACE

