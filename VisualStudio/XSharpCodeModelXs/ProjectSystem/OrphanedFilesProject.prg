//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
USING System
USING System.Collections.Generic
USING System.Linq
USING System.Text
USING System.Threading.Tasks
USING EnvDTE
USING LanguageService.CodeAnalysis
USING LanguageService.CodeAnalysis.XSharp
USING System.Collections.Concurrent
USING System.Collections.Immutable
//USING Microsoft.VisualStudio
//USING Microsoft.VisualStudio.Shell.Interop
USING System.Diagnostics

BEGIN NAMESPACE XSharpModel
	CLASS OrphanedFilesProject IMPLEMENTS IXSharpProject
	#region properties
		PROPERTY IntermediateOutputPath AS STRING GET ""
		PROPERTY IsVsBuilding AS LOGIC GET false
		PROPERTY OutputFile AS STRING GET ""
		PROPERTY ParseOptions AS XSharpParseOptions GET _parseOptions
		PROPERTY PrefixClassesWithDefaultNamespace AS LOGIC GET false
		PROPERTY Project AS XProject AUTO
		PROPERTY RootNameSpace AS STRING GET ""
		PROPERTY Url AS STRING GET ""
		PROPERTY DisableRegions AS LOGIC GET false
		PROPERTY DisableLexing AS LOGIC GET false
		PROPERTY DisableParsing AS LOGIC GET false
		PROPERTY KeywordsUppercase AS LOGIC GET TRUE
        PROPERTY Dialect AS XSharpDialect GET XSharpDialect.Core
	#endregion
        PRIVATE _parseOptions as XSharpParseOptions
		CONSTRUCTOR()
            var options := List<String>{}
             options.Add("dialect:Core")
            _parseOptions   := XSharpParseOptions.FromVsValues(options)

		METHOD AddFileNode(strFileName AS STRING) AS VOID
			RETURN

		METHOD AddIntellisenseError(file AS STRING, line AS LONG, column AS LONG, Length AS LONG, errCode AS STRING, message AS STRING, sev AS DiagnosticSeverity) AS VOID
			RETURN


		METHOD ClearIntellisenseErrors(file AS STRING) AS VOID
			RETURN


		METHOD DeleteFileNode(strFileName AS STRING) AS VOID
			RETURN


		METHOD DocumentGetText(file AS STRING, isOpen REF LOGIC) AS STRING
			//
			isOpen := false
			RETURN ""

		METHOD DocumentInsertLine(fileName AS STRING, line AS LONG, text AS STRING) AS LOGIC
			//
			RETURN false

		METHOD DocumentSetText(fileName AS STRING, text AS STRING) AS LOGIC
			//
			RETURN false

		METHOD FindProject(sProject AS STRING) AS Project
			//
			RETURN null

		METHOD GetIntellisenseErrorPos(fileName AS STRING) AS System.Collections.Generic.List<IXErrorPosition>
			RETURN List<IXErrorPosition>{}

		METHOD HasFileNode(strFileName AS STRING) AS LOGIC
			RETURN true

		METHOD IsDocumentOpen(file AS STRING) AS LOGIC
			RETURN true

		METHOD OpenElement(file AS STRING, line AS LONG, column AS LONG) AS VOID
			RETURN


		METHOD SetStatusBarAnimation(onoff AS LOGIC, id AS SHORT) AS VOID
			RETURN


		METHOD SetStatusBarText(message AS STRING) AS VOID
			RETURN


		METHOD ShowIntellisenseErrors() AS VOID
			RETURN

        METHOD SynchronizeKeywordCase(code AS STRING, fileName AS STRING) AS STRING
                RETURN code



	END CLASS

END NAMESPACE

