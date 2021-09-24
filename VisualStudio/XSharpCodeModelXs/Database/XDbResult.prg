﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
USING System.Collections.Generic
USING System.Diagnostics
USING XSharpModel
USING System.Linq
USING LanguageService.CodeAnalysis.XSharp
USING LanguageService.SyntaxTree
USING LanguageService.CodeAnalysis.XSharp.SyntaxParser

BEGIN NAMESPACE XSharpModel

   [DebuggerDisplay("{TypeName,nq} {MemberName,nq}")];
    CLASS XDbResult
      PROPERTY TypeName     AS STRING AUTO
      PROPERTY Namespace    AS STRING AUTO
      PROPERTY MemberName   AS STRING AUTO
      PROPERTY IsReference  AS LOGIC AUTO
      PROPERTY Kind         AS Kind AUTO
      PROPERTY Attributes   AS Modifiers AUTO
      PROPERTY ClassType    AS INT AUTO
      PROPERTY FileName     AS STRING AUTO
      PROPERTY Project      AS STRING AUTO
      PROPERTY StartLine    AS INT AUTO
      PROPERTY StartColumn  AS INT AUTO
      PROPERTY EndLine      AS INT AUTO
      PROPERTY EndColumn    AS INT AUTO
      PROPERTY Start        AS INT AUTO
      PROPERTY Stop         AS INT AUTO
      PROPERTY SourceCode   AS STRING AUTO
      PROPERTY ReturnType   AS STRING AUTO
      PROPERTY XmlComments  AS STRING AUTO
      PROPERTY IdFile       AS INT64 AUTO
      PROPERTY IdProject    AS INT64 AUTO
      PROPERTY IdType       AS INT64 AUTO
      PROPERTY BaseTypeName aS STRING GET MemberName SET MemberName := value
      PROPERTY FullName     AS STRING  GET FileName SET FileName := value
      PROPERTY Assembly     AS STRING  GET Project  SET Project := value
      PROPERTY IdAssembly   AS INT64   GET IdProject SET IdProject := value
      PROPERTY Priority     AS INT   GET Start SET Start := value
      PROPERTY Comment      AS STRING  GET SourceCode SET SourceCode := value
      PROPERTY Line         AS INT   GET StartLine    SET StartLine := value
      PROPERTY Column       AS INT   GET StartColumn  SET StartColumn := value
      PROPERTY Modifiers   AS Modifiers    GET _AND(Attributes, ~Modifiers.VisibilityMask)
      PROPERTY Visibility  AS Modifiers    GET _AND(Attributes, Modifiers.VisibilityMask)

    END CLASS
END NAMESPACE
