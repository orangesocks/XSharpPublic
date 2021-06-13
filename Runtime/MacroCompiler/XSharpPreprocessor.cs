﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
#nullable disable
#define UDCSUPPORT
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using Microsoft.CodeAnalysis.Text;
using Roslyn.Utilities;
using Antlr4.Runtime;
using Antlr4.Runtime.Misc;
using LanguageService.CodeAnalysis.XSharp.SyntaxParser;
using System.Diagnostics;
using System.Collections.Immutable;
using System.Collections.Concurrent;
using Microsoft.CodeAnalysis;
using System.Reflection;
using System.Runtime;
using System.Collections;
using System.Threading;

namespace Microsoft.CodeAnalysis.CSharp.Syntax.InternalSyntax
{
    internal class XSharpPreprocessor
    {
        static Dictionary<string, string> embeddedHeaders = null;

        static void loadResources()
        {
            if (embeddedHeaders == null)
            {
                embeddedHeaders = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                var asm = typeof(XSharpPreprocessor).GetTypeInfo().Assembly;
#if VSPARSER
                var strm = asm.GetManifestResourceStream("XSharp.VSParser.Preprocessor.StandardHeaders.resources");
#else
                var strm = asm.GetManifestResourceStream("LanguageService.CodeAnalysis.XSharp.Preprocessor.StandardHeaders.resources");
#endif
                var rdr = new System.Resources.ResourceReader(strm);
                foreach (DictionaryEntry item in rdr)
                {
                    embeddedHeaders.Add((string)item.Key, (string)item.Value);
                }
            }
        }

        const string PPOPrefix = "//PP ";

        #region IncludeCache
        internal class PPIncludeFile
        {
            static readonly ConcurrentDictionary<String, PPIncludeFile> cache = new(StringComparer.OrdinalIgnoreCase);

            internal static void ClearOldIncludes()
            {
                // Remove old includes that have not been used in the last 1 minutes
                var oldkeys = new List<string>();
                var compare = DateTime.Now.Subtract(new TimeSpan(0, 1, 0));
                foreach (var include in cache.Values)
                {
                    if (include.LastUsed < compare)
                    {
                        oldkeys.Add(include.FileName);
                    }
                }
                foreach (var key in oldkeys)
                {
                    PPIncludeFile oldFile;
                    cache.TryRemove(key, out oldFile);
                }
            }

            internal static PPIncludeFile Get(string fileName)
            {
                PPIncludeFile file = null;
                if (cache.ContainsKey(fileName))
                {
                    if (cache.TryGetValue(fileName, out file))
                    {
                        DateTime timeStamp;
                        if (System.IO.File.Exists(fileName))
                            timeStamp = FileUtilities.GetFileTimeStamp(fileName);
                        else
                            timeStamp = DateTime.MinValue;
                        if (file.LastWritten != timeStamp)
                        {
                            cache.TryRemove(fileName, out file);
                            file = null;
                        }
                        else
                        {
                            file.LastUsed = DateTime.Now;
                            // Now clone the file so the tokens may be manipulated
                            file = file.Clone();
                        }
                    }
                }
                return file;
            }
            internal static PPIncludeFile Add(string fileName, IList<IToken> tokens, SourceText text, bool mustBeProcessed, ref bool newFile)
            {
                PPIncludeFile file;
                cache.TryGetValue(fileName, out file);
                if (file == null)
                {
                    newFile = true;
                    file = new PPIncludeFile(fileName, tokens, text, mustBeProcessed);
                    if (!cache.TryAdd(fileName, file))
                    {
                        PPIncludeFile oldFile;
                        if (cache.TryGetValue(fileName, out oldFile))
                        {
                            file = oldFile;
                            newFile = false;
                        }
                    }
                }
                else
                {
                    newFile = false;
                }
                return file;
            }
            internal DateTime LastWritten { get; private set; }
            internal string FileName { get; private set; }
            internal ImmutableArray<IToken> Tokens { get; private set; }
            internal SourceText Text { get; private set; }
            internal DateTime LastUsed { get; set; }
            internal bool MustBeProcessed { get; set; }

            internal PPIncludeFile(string name, IList<IToken> tokens, SourceText text, bool mustBeProcessed)
            {
                this.FileName = name;
                this.Text = text;
                this.LastUsed = DateTime.Now;
                if (File.Exists(this.FileName))
                {
                    this.LastWritten = FileUtilities.GetFileTimeStamp(this.FileName);
                }
                else
                {
                    this.LastWritten = DateTime.MinValue;
                }
                this.Tokens = tokens.ToImmutableArray();
                this.MustBeProcessed = mustBeProcessed;

            }
            internal PPIncludeFile Clone()
            {
                return new PPIncludeFile(FileName, Tokens, Text, MustBeProcessed); 
            }
        }

        #endregion

        class InputState
        {
            internal ITokenStream Tokens;
            internal int Index;
            internal string SourceFileName;
            internal int MappedLineDiff;
            internal bool isSymbol;
            internal string SymbolName;
            internal XSharpToken Symbol;
            internal InputState parent;
            //internal string MappedFileName;
            //internal PPRule udc;

            internal InputState(ITokenStream tokens)
            {
                Tokens = tokens;
                Index = 0;
                MappedLineDiff = 0;
                SourceFileName = null;
                parent = null;
                isSymbol = false;
            }

            internal int La()
            {
                if (Eof() && parent != null)
                    return parent.La();
                return Tokens.Get(Index).Type;
            }

            internal XSharpToken Lt()
            {
                if (Eof() && parent != null)
                    return parent.Lt();
                return (XSharpToken)Tokens.Get(Index);
            }

            internal bool Eof()
            {
                return Index >= Tokens.Size || Tokens.Get(Index).Type == IntStreamConstants.Eof;
            }

            internal bool Consume()
            {
                if (Eof())
                    return false;
                Index++;
                return true;
            }
        }

        XSharpLexer _lexer;
        readonly ITokenStream _lexerStream;
        CSharpParseOptions _options;

        Encoding _encoding;

        readonly SourceHashAlgorithm _checksumAlgorithm;

        IList<ParseErrorData> _parseErrors;
        bool _duplicateFile = false;

        IList<string> includeDirs;

        Dictionary<string, IList<XSharpToken>> symbolDefines;

        readonly Dictionary<string, Func<XSharpToken, XSharpToken>> macroDefines = new (XSharpString.Comparer);

        readonly Stack<bool> defStates = new();
        readonly Stack<XSharpToken> regions = new();
        readonly string _fileName = null;
        InputState inputs;
        IToken lastToken = null;

        readonly PPRuleDictionary cmdRules = new();
        readonly PPRuleDictionary transRules = new();
        bool _hasCommandrules = false;
        bool _hasTransrules = false;
        int rulesApplied = 0;
        readonly int defsApplied = 0;
        readonly HashSet<string> activeSymbols = new();

        readonly bool _preprocessorOutput = false;
        Stream _ppoStream;

        internal Dictionary<string, SourceText> IncludedFiles = new(CaseInsensitiveComparison.Comparer);

        public int MaxIncludeDepth { get; set; } = 16;

        public int MaxSymbolDepth { get; set; } = 16;

        public int MaxUDCDepth { get; set; } = 256;

        public string StdDefs { get; set; } = string.Empty;
        private void initStdDefines(CSharpParseOptions options, string fileName)
        {
            // Note Macros such as __ENTITY__ and  __SIG__ are handled in the transformation phase
            // Make sure you also update the MACROs in XSharpLexerCode.cs !
            macroDefines.Add("__ARRAYBASE__", (token) => new XSharpToken(XSharpLexer.INT_CONST, _options.HasOption(CompilerOption.ArrayZero, null, null) ? "0" : "1", token));
            if (_options.ClrVersion == 2)
                macroDefines.Add("__CLR2__", (token) => new XSharpToken(XSharpLexer.TRUE_CONST, token));
            if (_options.ClrVersion == 4)
                macroDefines.Add("__CLR4__", (token) => new XSharpToken(XSharpLexer.TRUE_CONST, token));
            macroDefines.Add("__CLRVERSION__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, "\"" + _options.ClrVersion.ToString() + ".0\"", token));
            macroDefines.Add("__DATE__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, '"' + DateTime.Now.Date.ToString("yyyyMMdd") + '"', token));
            macroDefines.Add("__DATETIME__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, '"' + DateTime.Now.ToString() + '"', token));
            bool debug = false;
#if VSPARSER
            if (options.PreprocessorSymbolsUpper.Contains("DEBUG"))
                debug = true;
            if (options.PreprocessorSymbolsUpper.Contains("NDEBUG"))
                debug = false;
#else
            if (options.PreprocessorSymbolNames.Contains((name) => name.ToUpper() == "DEBUG"))
                debug = true;
            if (options.PreprocessorSymbolNames.Contains((name) => name.ToUpper() == "NDEBUG"))
                debug = false;
#endif
            if (debug)
            {
                macroDefines.Add("__DEBUG__", (token) => new XSharpToken(XSharpLexer.TRUE_CONST, token));
            }
            macroDefines.Add("__DIALECT__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, '"' + options.Dialect.ToString() + '"', token));
            switch (_options.Dialect)
            {
                case XSharpDialect.Core:
                    macroDefines.Add("__DIALECT_CORE__", (token) => new XSharpToken(XSharpLexer.TRUE_CONST, token));
                    break;
                case XSharpDialect.VO:
                    macroDefines.Add("__DIALECT_VO__", (token) => new XSharpToken(XSharpLexer.TRUE_CONST, token));
                    macroDefines.Add("__VO__", (token) => new XSharpToken(XSharpLexer.TRUE_CONST, token));
                    break;
                case XSharpDialect.Vulcan:
                    macroDefines.Add("__DIALECT_VULCAN__", (token) => new XSharpToken(XSharpLexer.TRUE_CONST, token));
                    macroDefines.Add("__VULCAN__", (token) => new XSharpToken(XSharpLexer.TRUE_CONST, token));
                    break;
                case XSharpDialect.Harbour:
                    macroDefines.Add("__DIALECT_HARBOUR__", (token) => new XSharpToken(XSharpLexer.TRUE_CONST, token));
                    // Harbour always includes hbver.h . The macro is defined in that file.
                    //macroDefines.Add("__HARBOUR__", () => new XSharpToken(XSharpLexer.TRUE_CONST));
                    break;
                case XSharpDialect.XPP:
                    macroDefines.Add("__DIALECT_XBASEPP__", (token) => new XSharpToken(XSharpLexer.TRUE_CONST, token));
                    macroDefines.Add("__XPP__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, '"' + global::XSharp.Constants.FileVersion + '"', token));
                    break;
                case XSharpDialect.FoxPro:
                    macroDefines.Add("__DIALECT_FOXPRO__", (token) => new XSharpToken(XSharpLexer.TRUE_CONST, token));
                    break;
                default:
                    break;
            }
            macroDefines.Add("__ENTITY__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, "\"__ENTITY__\"", token));  // Handled later in Transformation phase
            macroDefines.Add("__FILE__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, '"' + (inputs.SourceFileName ?? fileName) + '"', token));
            macroDefines.Add("__LINE__", (token) => new XSharpToken(XSharpLexer.INT_CONST, token.Line.ToString(), token));
            macroDefines.Add("__MODULE__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, '"' + (inputs.SourceFileName ?? fileName) + '"', token));
            macroDefines.Add("__FUNCTION__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, "\"__FUNCTION__\"", token)); // Handled later in Transformation phase
            macroDefines.Add("__FUNCTIONS__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, "\"__FUNCTIONS__\"", token)); // Handled later in Transformation phase
            macroDefines.Add("__SIG__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, "\"__SIG__\"", token)); // Handled later in Transformation phase
            macroDefines.Add("__SRCLOC__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, '"' + (inputs.SourceFileName ?? fileName) + " line " + token.Line.ToString() + '"', token));
            macroDefines.Add("__SYSDIR__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, '"' + options.SystemDir + '"', token));
            macroDefines.Add("__TIME__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, '"' + DateTime.Now.ToString("HH:mm:ss") + '"', token));
            macroDefines.Add("__UTCTIME__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, '"' + DateTime.Now.ToUniversalTime().ToString("HH:mm:ss") + '"', token));
            macroDefines.Add("__VERSION__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, '"' + global::XSharp.Constants.FileVersion + '"', token));
            macroDefines.Add("__WINDIR__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, '"' + options.WindowsDir + '"', token));
            macroDefines.Add("__WINDRIVE__", (token) => new XSharpToken(XSharpLexer.STRING_CONST, '"' + options.WindowsDir?.Substring(0, 2) + '"', token));
            macroDefines.Add("__XSHARP__", (token) => new XSharpToken(XSharpLexer.TRUE_CONST, token));
            if (options.XSharpRuntime)
            {
                macroDefines.Add("__XSHARP_RT__", (token) => new XSharpToken(XSharpLexer.TRUE_CONST, token));
            }
            bool[] flags = { options.vo1,  options.vo2, options.vo3, options.vo4, options.vo5, options.vo6, options.vo7, options.vo8,
                                options.vo9, options.vo10, options.vo11, options.vo12, options.vo13, options.vo14, options.vo15, options.vo16 };
            for (int iOpt = 0; iOpt < flags.Length; iOpt++)
            {
                string flagName = string.Format("__VO{0}__", iOpt + 1);
                macroDefines.Add(flagName, (token) => new XSharpToken(flags[iOpt] ? XSharpLexer.TRUE_CONST : XSharpLexer.FALSE_CONST, token));
            }
            macroDefines.Add("__XPP1__", (token) => new XSharpToken(options.xpp1 ? XSharpLexer.TRUE_CONST : XSharpLexer.FALSE_CONST, token));
            macroDefines.Add("__XPP2__", (token) => new XSharpToken(options.xpp2 ? XSharpLexer.TRUE_CONST : XSharpLexer.FALSE_CONST, token));
            macroDefines.Add("__FOX1__", (token) => new XSharpToken(options.fox1 ? XSharpLexer.TRUE_CONST : XSharpLexer.FALSE_CONST, token));
            macroDefines.Add("__FOX2__", (token) => new XSharpToken(options.fox2 ? XSharpLexer.TRUE_CONST : XSharpLexer.FALSE_CONST, token));
            if (!options.NoStdDef)
            {
                // Todo: when the compiler option nostddefs is not set: read XSharpDefs.xh from the XSharp Include folder,//
                // and automatically include it.
                // read XsharpDefs.xh
                StdDefs = options.StdDefs;
                ProcessIncludeFile(StdDefs, null);
            }
        }

        internal void DumpStats()
        {
            DebugOutput("Preprocessor statistics");
            DebugOutput("-----------------------");
            DebugOutput("# of #defines    : {0}", this.symbolDefines.Count);
            DebugOutput("# of #translates : {0}", this.transRules.Count);
            DebugOutput("# of #commands   : {0}", this.cmdRules.Count);
            DebugOutput("# of macros      : {0}", this.macroDefines.Count);
            DebugOutput("# of defines used: {0}", this.defsApplied);
            DebugOutput("# of UDCs used   : {0}", this.rulesApplied);
        }

        private void _writeToPPO(String text, bool addCRLF)
        {
            // do not call t.Text when not needed.
            if (_preprocessorOutput)
            {
                var buffer = _encoding.GetBytes(text);
                _ppoStream.Write(buffer, 0, buffer.Length);
                if (addCRLF)
                {
                    buffer = _encoding.GetBytes("\r\n");
                    _ppoStream.Write(buffer, 0, buffer.Length);
                }
            }
        }

        private bool mustWriteToPPO()
        {
            return _preprocessorOutput && _ppoStream != null && inputs.parent == null;
        }

        internal void writeToPPO(string text, bool addCRLF = true)
        {
            if (mustWriteToPPO())
            {
                _writeToPPO(text, addCRLF);
            }
        }
        private void writeToPPO(IList<XSharpToken> tokens, bool prefix = false, bool prefixNewLines = false)
        {
            if (mustWriteToPPO())
            {
                if (tokens?.Count == 0)
                {
                    _writeToPPO("", true);
                    return;
                }
                // We cannot use the interval and fetch the text from the source stream,
                // because some tokens may come out of an include file or otherwise
                // so concatenate text on the fly
                var bld = new StringBuilder(1024);
                if (prefix)
                {
                    bld.Append(PPOPrefix);
                }
                bool first = !prefix;
                foreach (var t in tokens)
                {
                    // Copy the trivia from the original first symbol on the line so the UDC has the proper indentlevel
                    if (first && t.SourceSymbol != null && t.SourceSymbol.HasTrivia && t.SourceSymbol.Type == XSharpLexer.UDC_KEYWORD)
                    {
                        bld.Append(t.SourceSymbol.TriviaAsText);
                    }
                    bld.Append(t.Text);
                    first = false;
                }
                if (prefixNewLines)
                {
                    bld.Replace("\n", "\n" + PPOPrefix);
                }
                _writeToPPO(bld.ToString(), true);
            }
        }

        internal void Close()
        {
            if (_ppoStream != null)
            {
                _ppoStream.Flush();
                _ppoStream.Dispose();
            }
            _ppoStream = null;
        }
        internal void addParseError(ParseErrorData error)
        {
#if !VSPARSER
            // use the filter mechanism in the compiler to only add errors that are not suppressed.
            var d = Diagnostic.Create(new SyntaxDiagnosticInfo(error.Code));
            if (_options.CommandLineArguments != null)
            {
                d = _options.CommandLineArguments.CompilationOptions.FilterDiagnostic(d, CancellationToken.None);
            }
            if (d != null)
            {
               _parseErrors.Add(error);
            }
#else
            _parseErrors.Add(error);
#endif
        }
        internal XSharpPreprocessor(XSharpLexer lexer, ITokenStream lexerStream, CSharpParseOptions options, string fileName, Encoding encoding, SourceHashAlgorithm checksumAlgorithm, IList<ParseErrorData> parseErrors)
        {
            PPIncludeFile.ClearOldIncludes();
            _lexer = lexer;
            _lexerStream = lexerStream;
            _options = options;
            _fileName = fileName;
            if (_options.VOPreprocessorBehaviour)
            {
                symbolDefines = new Dictionary<string, IList<XSharpToken>>(XSharpString.Comparer);
            }
            else
            {
                symbolDefines = new Dictionary<string, IList<XSharpToken>>(/* case sensitive */);
            }
            _encoding = encoding;
            _checksumAlgorithm = checksumAlgorithm;
            _parseErrors = parseErrors;
            includeDirs = new List<string>(options.IncludePaths);
            if (!string.IsNullOrEmpty(fileName) && File.Exists(fileName))
            {
                includeDirs.Add(Path.GetDirectoryName(fileName));
                var ppoFile = FileNameUtilities.ChangeExtension(fileName, ".ppo");
                try
                {
                    _ppoStream = null;
                    _preprocessorOutput = _options.PreprocessorOutput;
                    if (FileNameUtilities.GetExtension(fileName).ToLower() == ".ppo")
                    {
                        _preprocessorOutput = false;
                    }
                    else
                    {
                        if (_preprocessorOutput)
                        {
                            _ppoStream = FileUtilities.CreateFileStreamChecked(File.Create, ppoFile, "PPO file");
                        }
                        else if (File.Exists(ppoFile))
                        {
                            File.Delete(ppoFile);
                        }
                    }
                }
                catch (Exception e)
                {
                    addParseError(new ParseErrorData(fileName, ErrorCode.ERR_PreProcessorError, "Error processing PPO file: " + e.Message));
                }
            }
            // Add default IncludeDirs;
            if (!string.IsNullOrEmpty(options.DefaultIncludeDir))
            {
                string[] paths = options.DefaultIncludeDir.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (var path in paths)
                {
                    includeDirs.Add(path);
                }
            }

            inputs = new InputState(lexerStream);
            // Add defines from the command line.
            foreach (var symbol in options.PreprocessorSymbols)
            {
                var tokens = new List<XSharpToken>();
                symbolDefines[symbol] = tokens;
            }

            initStdDefines(options, fileName);
        }

        internal void DebugOutput(string format, params object[] objects)
        {
            if (_options.ConsoleOutput != null)
            {
                _options.ConsoleOutput.WriteLine("PP: " + format, objects);
            }
        }

        /// <summary>
        /// Pre-processes the input stream. Reads #Include files, processes #ifdef commands and translations from #defines, macros and UDCs
        /// </summary>
        /// <returns>Translated input stream</returns>
        internal IList<IToken> PreProcess()
        {
            var result = new List<IToken>(); 
            XSharpToken t = Lt();
            List<XSharpToken> omitted = new List<XSharpToken>(); 
            while (t.Type != IntStreamConstants.Eof)
            {
                // read until the next EOS
                var line = ReadLine(omitted);
                t = Lt();   // CRLF or EOS. Must consume now, because #include may otherwise add a new inputs
                Consume();
                if (line.Count > 0)
                {
                    line = ProcessLine(line);
                    if (line != null && line.Count > 0)
                    {
                        result.AddRange(line);
                    }
                }
                else
                {
                    if (omitted.Count > 0)
                        writeToPPO(omitted, false);
                    else
                        writeToPPO("");
                }
                if (t.Channel == XSharpLexer.DefaultTokenChannel)
                    result.Add(t);
            }
            doEOFChecks();
            return result;
        }

        static int getFirstTokenType(IList<XSharpToken> line)
        {
            for (int i = 0; i < line.Count; i++)
            {
                switch (line[i].Channel)
                {
                    case XSharpLexer.DefaultTokenChannel:
                    case XSharpLexer.PREPROCESSORCHANNEL:
                        return line[i].Type;
                    default:
                        break;
                }
            }
            return XSharpLexer.Eof;
        }
        IList<XSharpToken> ProcessLine(IList<XSharpToken> line)
        {
            Debug.Assert(line.Count > 0);
            var nextType = getFirstTokenType(line);
            switch (nextType)
            {
                case XSharpLexer.PP_UNDEF:
                    doUnDefDirective(line);
                    line = null;
                    break;
                case XSharpLexer.PP_IFDEF:
                    doIfDefDirective(line, true);
                    line = null;
                    break;
                case XSharpLexer.PP_IFNDEF:
                    doIfDefDirective(line, false);
                    line = null;
                    break;
                case XSharpLexer.PP_ENDIF:
                    doEndifDirective(line);
                    line = null;
                    break;
                case XSharpLexer.PP_ELSE:
                    doElseDirective(line);
                    line = null;
                    break;
                case XSharpLexer.PP_LINE:
                    doLineDirective(line);
                    line = null;
                    break;
                case XSharpLexer.PP_ERROR:
                case XSharpLexer.PP_WARNING:
                    doErrorWarningDirective(line);
                    line = null;
                    break;
                case XSharpLexer.PP_INCLUDE:
                    doIncludeDirective(line);
                    line = null;
                    break;
                case XSharpLexer.PP_COMMAND:
                case XSharpLexer.PP_TRANSLATE:
                    doUDCDirective(line, true);
                    line = null;
                    break;
                case XSharpLexer.PP_DEFINE:
                    doDefineDirective(line);
                    line = null;
                    break;
                case XSharpLexer.PP_ENDREGION:
                    doEndRegionDirective(line);
                    line = null;
                    break;
                case XSharpLexer.PP_REGION:
                    doRegionDirective(line);
                    line = null;
                    break;
                case XSharpLexer.UDCSEP:
                    doUnexpectedUDCSeparator(line);
                    line = null;
                    break;
                default:
                    line = doNormalLine(line);
                    break;
            }
            return line;
        }

        /// <summary>
        /// Reads the a line from the input stream until the EOS token and skips hidden tokens
        /// </summary>
        /// <returns>List of tokens EXCLUDING the EOS but including statement separator char ;</returns>
        IList<XSharpToken> ReadLine(IList<XSharpToken> omitted)
        {
            Debug.Assert(omitted != null);
            var res = new List<XSharpToken>();
            omitted.Clear();
            XSharpToken t = Lt();
            while (t.Type != IntStreamConstants.Eof)
            {
                if (t.IsEOS() && t.Text != ";")
                    break;
                if (t.Channel != XSharpLexer.Hidden && t.Channel != XSharpLexer.XMLDOCCHANNEL)
                {
                    var nt = FixToken(t);
                    res.Add(nt);
                }
                else
                {
                    res.Add(t);
                }
                Consume();
                t = Lt();
            }
            return res;
        }

        /// <summary>
        /// Returns the name of the active source. Can be the main prg file, but also an active #include file
        /// </summary>
        string SourceName
        {
            get
            {
                return _fileName;
            }
        }

        XSharpToken GetSourceSymbol()
        {
            XSharpToken s = null;
            if (inputs.isSymbol)
            {
                var baseInputState = inputs;
                while (baseInputState.parent?.isSymbol == true)
                    baseInputState = baseInputState.parent;
                s = baseInputState.Symbol;
            }
            return s;
        }

        XSharpToken FixToken(XSharpToken token)
        {
            if (inputs.MappedLineDiff != 0)
                token.MappedLine = token.Line + inputs.MappedLineDiff;
            //if (!string.IsNullOrEmpty(inputs.MappedFileName))
            //    token.MappedFileName = inputs.MappedFileName;
            //if (!string.IsNullOrEmpty(inputs.SourceFileName))
            //    token.SourceFileName = inputs.SourceFileName;
            if (inputs.isSymbol)
            {
                token.SourceSymbol = GetSourceSymbol();
                //token.SourceFileName = (token.SourceSymbol as XSharpToken).SourceFileName;
            }
            return token;
        }

        XSharpToken Lt()
        {
            return inputs.Lt();
        }

        void Consume()
        {
            while (!inputs.Consume() && inputs.parent != null)
            {
                if (inputs.isSymbol)
                    activeSymbols.Remove(inputs.SymbolName);
                inputs = inputs.parent;
            }
        }

        void InsertStream(string filename, ITokenStream input, XSharpToken symbol )
        {
            if (_options.ShowDefs)
            {
                if (symbol != null)
                {
                    var tokens = new List<XSharpToken>();
                    for (int i = 0; i < input.Size - 1; i++)
                    {
                        tokens.Add(new XSharpToken(input.Get(i)));
                    }
                    string text = tokens.AsString();
                    //if (text.Length > 20)
                    //    text = text.Substring(0, 20) + "...";
                    DebugOutput("File {0} line {1}:", _fileName, symbol.Line);
                    DebugOutput("Input stack: Insert value of token Symbol {0}, {1} tokens => {2}", symbol.Text, input.Size - 1, text);
                }
                else
                    DebugOutput("Input stack: Insert Stream {0}, # of tokens {1}", filename, input.Size - 1);
            }
            // Detect recursion
            var x = inputs;
            while (x != null)
            {
                if (string.Compare(x.SourceFileName , filename, true) == 0)
                {
                    addParseError(new ParseErrorData(symbol, ErrorCode.ERR_PreProcessorError, "Recursive include file ("+filename+") detected",filename));
                    return;
                }
                x = x.parent;
            }
            InputState s = new InputState(input)
            {
                parent = inputs,
                SourceFileName = filename,
                SymbolName = symbol?.Text,
                Symbol = symbol,
                isSymbol = symbol != null
            };
            if (s.isSymbol)
            {
                activeSymbols.Add(s.SymbolName);
                s.MappedLineDiff = inputs.MappedLineDiff;
            }
            inputs = s;
        }

        bool IsActive()
        {
            return defStates.Count == 0 || defStates.Peek();
        }

        int IncludeDepth()
        {
            int d = 1;
            var o = inputs;
            while (o.parent != null)
            {
                if (!o.isSymbol)
                    d += 1;
                o = o.parent;
            }
            return d;
        }

        int SymbolDepth()
        {
            int d = 0;
            var o = inputs;
            while (o.parent != null && o.isSymbol)
            {
                d += 1;
                o = o.parent;
            }
            return d;
        }

        bool IsDefinedMacro(XSharpToken t)
        {
            return (t.Type == XSharpLexer.MACRO) ? macroDefines.ContainsKey(t.Text) : false;
        }
        static IList<XSharpToken> stripWs(IList<XSharpToken> line)
        {
            IList<XSharpToken> result = new List<XSharpToken>();
            foreach (var token in line)
            {
                if (token.Channel == XSharpLexer.DefaultTokenChannel || token.Channel == XSharpLexer.PREPROCESSORCHANNEL)
                {
                    result.Add(token);
                }
            }
            return result;
        }

        void addDefine(IList<XSharpToken> line, IList<XSharpToken> original)
        {
            // Check to see if the define contains a LPAREN, and there is no space in between them.
            // Then it is a pseudo function that we will store as a #xtranslate UDC
            // this returns a list that includes #define and the ID
            if (line.Count < 2)
            {
                var token = line[0];
                addParseError(new ParseErrorData(token, ErrorCode.ERR_PreProcessorError, "Identifier expected"));
                return;
            }
            // token 1 is the Identifier
            // other tokens are optional and may contain a value
            XSharpToken def = line[1];
            if (line.Count > 2)
            {
                var first = line[2];
                if (first.Type == XSharpLexer.LPAREN
                    && first.StartIndex == def.StopIndex + 1)
                {
                    doUDCDirective(original, false);
                    return;
                }
            }
            if (XSharpLexer.IsIdentifier(def.Type) || XSharpLexer.IsKeyword(def.Type))
            {
                line.RemoveAt(0);  // remove #define
                line.RemoveAt(0);  // remove ID
                if (symbolDefines.ContainsKey(def.Text))
                {
                    // check to see if this is a new definition or a duplicate definition
                    var oldtokens = symbolDefines[def.Text];
                    var cOld = oldtokens.AsString();
                    var cNew = line.AsString();
                    def.SourceSymbol = null;    // make sure we point to the location in the include file when this happens  (and not to the location where we were included)
                    if (cOld == cNew && oldtokens?.Count > 0)
                    {
                        // check to see if the same file has been added twice
                        var oldToken = oldtokens[0];
                        var newToken = line[0];
                        if (oldToken.TokenSource.SourceName != newToken.TokenSource.SourceName || oldToken.Line != newToken.Line)
                        {
                            addParseError(new ParseErrorData(def, ErrorCode.WRN_DuplicateDefineSame, def.Text));
                        }
                        else
                        {
                            if (! _duplicateFile)
                            {
                                _duplicateFile = true;
                                var includeName = newToken.SourceName;
                                var defText = def.Text;
                                if (inputs.Symbol != null)
                                {
                                    def = new XSharpToken(inputs.Symbol)
                                    {
                                        SourceSymbol = null
                                    };
                                }
                                addParseError(new ParseErrorData(def, ErrorCode.WRN_PreProcessorWarning, "Duplicate define (" + defText + ") found because include file \""+includeName+"\" was included twice"));
                            }
                        }
                    }
                    else
                    {
                        addParseError(new ParseErrorData(def, ErrorCode.WRN_DuplicateDefineDiff, def.Text, cOld, cNew));
                    }
                }
                symbolDefines[def.Text] = line;
                if (_options.ShowDefs)
                {
                    DebugOutput("{0}:{1} add DEFINE {2} => {3}", def.FileName(), def.Line, def.Text, line.AsString());
                }
            }
            else
            {
                addParseError(new ParseErrorData(def, ErrorCode.ERR_PreProcessorError, "Identifier expected"));
                return;
            }
        }

        void removeDefine(IList<XSharpToken> line)
        {
            var errToken = line[0];
            bool ok = true;
            line = stripWs(line);
            if (line.Count < 2)
            {
                ok = false;
            }
            XSharpToken def = line[1];
            if (XSharpLexer.IsIdentifier(def.Type) || XSharpLexer.IsKeyword(def.Type))
            {
                if (symbolDefines.ContainsKey(def.Text))
                    symbolDefines.Remove(def.Text);
            }
            else
            {
                errToken = def;
                ok = false;
            }
            if (!ok)
            {
                addParseError(new ParseErrorData(errToken, ErrorCode.ERR_PreProcessorError, "Identifier expected"));
            }
        }

        void doUDCDirective(IList<XSharpToken> udc, bool mustWrite)
        {
            Debug.Assert(udc?.Count > 0);
            if (!IsActive())
            {
                writeToPPO("");
                return;
            }
            if (mustWrite)
                writeToPPO(udc, true, true);
            udc = stripWs(udc);
            if (udc.Count < 3)
            {
                addParseError(new ParseErrorData(udc[0], ErrorCode.ERR_PreProcessorError, "Invalid UDC: '" + udc.AsString() + "'"));
                return;
            }
            var cmd = udc[0];
            PPErrorMessages errorMsgs;
            var rule = new PPRule(cmd, udc, out errorMsgs, _options);
            if (rule.Type == PPUDCType.None)
            {
                if (errorMsgs.Count > 0)
                {
                    foreach (var s in errorMsgs)
                    {
                        addParseError(new ParseErrorData(s.Token, ErrorCode.ERR_PreProcessorError, s.Message));
                    }
                }
                else
                {
                    addParseError(new ParseErrorData(cmd, ErrorCode.ERR_PreProcessorError, "Invalid directive '" + cmd.Text + "' (are you missing the => operator?)"));
                }
            }
            else
            {
                if (cmd.Type == XSharpLexer.PP_COMMAND)
                {
                    // COMMAND and XCOMMAND can only match from beginning of line
                    cmdRules.Add(rule);
                    _hasCommandrules = true;
                }
                else
                {
                    // TRANSLATE and XTRANSLATE can also match from beginning of line
                    transRules.Add(rule);
                    _hasTransrules = true;
                    if (cmd.Type == XSharpLexer.PP_DEFINE)
                    {
                        rule.CaseInsensitive = _options.VOPreprocessorBehaviour;
                    }
                }
                if (_options.ShowDefs)
                {
                    DebugOutput("{0}:{1} add {2} {3}", cmd.FileName(), cmd.Line, cmd.Type == XSharpLexer.PP_DEFINE ? "DEFINE" : "UDC", rule.Name);
                }
            }
        }
#if !VSPARSER
        private Exception readFileContents( string fp, out string nfp, out SourceText text)
        {
            Exception ex = null;
            nfp = null;
            text = null;
            try
            {
                using (var data = new FileStream(fp, FileMode.Open, FileAccess.Read, FileShare.ReadWrite, bufferSize: 1, options: FileOptions.None))
                {
                    nfp = data.Name;
                    try
                    {
                        text = EncodedStringText.Create(data, _encoding, _checksumAlgorithm);
                    }
                    catch (Exception)
                    {
                        text = null;
                    }
                    if (text == null)
                    {
                        // Encoding problem ?
                        text = EncodedStringText.Create(data);
                    }
                }
            }
            catch (Exception e)
            {
                nfp = null;
                ex = e;
            }
            return ex;
        }
#endif
        private bool isObsoleteIncludeFile(string includeFileName, XSharpToken token)
        {
            string file = PathUtilities.GetFileName(includeFileName, true).ToLower();
            bool obsolete = false;
            string assemblyName ;
            bool sdkdefs = _options.RuntimeAssemblies.HasFlag(RuntimeAssemblies.SdkDefines);
            switch (file)
            {
                case "errorcodes.vh":
                case "set.vh":
                case "set.ch":
                case "directry.ch":
                case "vosystemlibrary.vh":
                    obsolete = sdkdefs || _options.RuntimeAssemblies.HasFlag(RuntimeAssemblies.XSharpCore);
                    assemblyName = sdkdefs ? XSharpAssemblyNames.SdkDefines : XSharpAssemblyNames.XSharpCore;
                    break;
                case "voguiclasses.vh":
                    obsolete = sdkdefs || _options.RuntimeAssemblies.HasFlag(RuntimeAssemblies.VoGui);
                    assemblyName = sdkdefs ? XSharpAssemblyNames.SdkDefines : XSharpAssemblyNames.VoGui;
                    break;
                case "vointernetclasses.vh":
                    obsolete = sdkdefs || _options.RuntimeAssemblies.HasFlag(RuntimeAssemblies.VoInet);
                    assemblyName = sdkdefs ? XSharpAssemblyNames.SdkDefines : XSharpAssemblyNames.VoInet;
                    break;
                case "vorddclasses.vh":
                    obsolete = sdkdefs || _options.RuntimeAssemblies.HasFlag(RuntimeAssemblies.VoRdd);
                    assemblyName = sdkdefs ? XSharpAssemblyNames.SdkDefines : XSharpAssemblyNames.VoRdd;
                    break;
                case "voreportclasses.vh":
                    obsolete = sdkdefs || _options.RuntimeAssemblies.HasFlag(RuntimeAssemblies.VoReport);
                    assemblyName = sdkdefs ? XSharpAssemblyNames.SdkDefines : XSharpAssemblyNames.VoReport;
                    break;
                case "vosqlclasses.vh":
                    obsolete = sdkdefs || _options.RuntimeAssemblies.HasFlag(RuntimeAssemblies.VoSql);
                    assemblyName = sdkdefs ? XSharpAssemblyNames.SdkDefines : XSharpAssemblyNames.VoSql;
                    break;
                case "vosystemclasses.vh":
                    obsolete = sdkdefs || _options.RuntimeAssemblies.HasFlag(RuntimeAssemblies.VoSystem);
                    assemblyName = sdkdefs ? XSharpAssemblyNames.SdkDefines : XSharpAssemblyNames.VoSystem;
                    break;
                case "vowin32apilibrary.vh":
                    obsolete = sdkdefs || _options.RuntimeAssemblies.HasFlag(RuntimeAssemblies.VoWin32);
                    assemblyName = sdkdefs ? XSharpAssemblyNames.SdkDefines : XSharpAssemblyNames.VoWin32;
                    break;
                case "class.ch":
                    obsolete = _options.RuntimeAssemblies.HasFlag(RuntimeAssemblies.XSharpXPP);
                    assemblyName = XSharpAssemblyNames.XSharpXPP;
                    break;
                default:
                    obsolete = false;
                    assemblyName = "";
                   break;
            }
            if (obsolete)
            {
                addParseError(new ParseErrorData(token, ErrorCode.WRN_ObsoleteInclude, includeFileName, assemblyName+".dll"));
            }
            return obsolete;
        }

        private bool ProcessIncludeFile(string includeFileName, XSharpToken fileNameToken)
        {
            string nfp = null;
            SourceText text = null;
            Exception fileReadException = null;
            PPIncludeFile includeFile = null;
            if (isObsoleteIncludeFile(includeFileName,fileNameToken))
            {
                return true;
            }
            List<string> dirs = new List<string>() { PathUtilities.GetDirectoryName(_fileName) };
            foreach (var p in includeDirs)
            {
                dirs.Add(p);
            }
            if (fileNameToken != null)
            { 
                var path = PathUtilities.GetDirectoryName(fileNameToken.SourceName);
                if (! String.IsNullOrEmpty(path) && !dirs.Contains(path))
                    dirs.Add(path);
            }
            if (_options.Verbose)
            {
                DebugOutput("Process include file: {0}", includeFileName);
            }
            foreach (var p in dirs)
            {
                bool rooted = Path.IsPathRooted(includeFileName);
                string fp;
                try
                {
                    fp = rooted || p == null ? includeFileName : Path.Combine(p, includeFileName);
                }
                catch (Exception e)
                {
                    addParseError(new ParseErrorData(fileNameToken, ErrorCode.ERR_PreProcessorError, "Error combining path " + p + " and filename  " + includeFileName + " " + e.Message));
                    continue;
                }
                if (File.Exists(fp))
                {
                    if (_options.Verbose)
                    {
                        DebugOutput("Found include file on disk: {0}", fp);
                    }
                    includeFile = PPIncludeFile.Get(fp);
                    if (includeFile != null)
                    {
                        nfp = fp;
                        text = includeFile.Text;
                        if (_options.Verbose)
                        {
                            DebugOutput("Include file retrieved from cache: {0}", fp);
                        }
                        break;
                    }
                    else
                    {
#if !VSPARSER
                        var ex = readFileContents(fp, out nfp, out text);
                        if (ex != null && fileReadException == null)
                        {
                            fileReadException = ex;
                        }
#else
                        Exception ex;
                        try
                        {
                            var contents = System.IO.File.ReadAllText(fp);
                            text = SourceText.From(contents);
                            nfp = fp;
                        }
                        catch (Exception e)
                        {
                            ex = e;
                        }
#endif
                    }
                    if (rooted || nfp != null)
                        break;

                }
            }
            if (nfp == null)
            {
                loadResources();
                var baseName = Path.GetFileNameWithoutExtension(includeFileName).ToLower();
                if (embeddedHeaders.TryGetValue(baseName, out var source))
                {
                    text = SourceText.From(source);
                    nfp = includeFileName;
                }
            }
            if (nfp == null)
            {
                if (fileReadException != null)
                {
                    addParseError(new ParseErrorData(fileNameToken, ErrorCode.ERR_PreProcessorError, "Error Reading include file '" + includeFileName + "': " + fileReadException.Message));
                }
                else
                {
                    addParseError(new ParseErrorData(fileNameToken, ErrorCode.ERR_PreProcessorError, "Include file not found: '" + includeFileName + "'"));
                }

                return false;
            }
            else
            {
                if (!IncludedFiles.ContainsKey(nfp))
                {
                    IncludedFiles.Add(nfp, text);
                }
            }
            if (_options.ShowIncludes )
            {
                var fname = PathUtilities.GetFileName(this.SourceName);
                if (fileNameToken != null)
                {
                    fname = PathUtilities.GetFileName(fileNameToken.InputStream.SourceName);
                    DebugOutput("{0} line {1} Include {2}", fname, fileNameToken.Line, nfp);
                }
                else
                {
                    // Most likely the Standard Header file. Report for Line 0
                    DebugOutput("{0} line {1} Include {2}", fname, 0, nfp);
                }
            }

            if (includeFile == null)
            {
                // we have nfp and text with the file contents
                // now parse the stuff and insert in the cache
                var startTime = DateTime.Now;

                var stream = new AntlrInputStream(text.ToString()) { name = nfp };
                var lexer = new XSharpLexer(stream){ TokenFactory = XSharpTokenFactory.Default };
                lexer.Options = _options;
                var ct = new CommonTokenStream(lexer);
                ct.Fill();
                foreach (var e in lexer.LexErrors)
                {
                    addParseError(e);
                }
                var endTime = DateTime.Now;
                if (_options.Verbose)
                {
                    DebugOutput("Lexed include file {0} milliseconds", (endTime - startTime).Milliseconds);
                }
                bool newFile = false;
                includeFile = PPIncludeFile.Add(nfp, ct.GetTokens(), text, lexer.MustBeProcessed, ref newFile);
                if (_options.Verbose)
                {
                    if (newFile)
                    {
                        DebugOutput("Added include file to cache {0}", nfp);
                    }
                    else
                    {
                        DebugOutput("Bummer: include file was already added to cache by another thread {0}", nfp);
                    }
                }
            }
            nfp = includeFile.FileName;
            if (_options.ParseLevel == ParseLevel.Complete || includeFile.MustBeProcessed || _lexer.HasPPIfdefs)
            {
                var clone = includeFile.Tokens.CloneArray();
                var tokenSource = new XSharpListTokenSource(_lexer, clone, nfp);
                var tokenStream = new BufferedTokenStream(tokenSource);
                tokenStream.Fill();
                InsertStream(nfp, tokenStream, fileNameToken);
            }
            else
            {
                if (_options.Verbose)
                {
                    DebugOutput("Skipping Include File in Parse Mode {0} line {1}:", nfp, fileNameToken.Line);
                }
            }
            return true;

        }

        private bool IsDefined(string define, XSharpToken token)
        {
            // Handle /VO8 compiler option:
            // When /VO8 is active and the variable is defined and has a value of FALSE or a numeric value = 0
            // Then #ifdef is FALSE
            // otherwise #ifdef is TRUE
            // and when there is more than one token, then #ifdef is also TRUE
            bool isdefined= symbolDefines.ContainsKey(define);
            if (isdefined )
            {
                if ( _options.VOPreprocessorBehaviour)
                {
                    var value = symbolDefines[define];
                    if (value?.Count == 1)
                    {
                        var deftoken = value[0];
                        if (deftoken.Type == XSharpLexer.FALSE_CONST)
                        {
                            isdefined = false;
                        }
                        else if (deftoken.Type == XSharpLexer.INT_CONST)
                        {
                            isdefined = Convert.ToInt64(deftoken.Text) != 0;
                        }
                    }
                }
            }
            else
            {
                isdefined = macroDefines.ContainsKey(define);
                if (isdefined )
                {
                    if (_options.VOPreprocessorBehaviour)
                    {
                        var value = macroDefines[define](token);
                        if (value != null)
                        {
                            if (value.Type == XSharpLexer.FALSE_CONST)
                            {
                                isdefined = false;
                            }
                            else if (value.Type == XSharpLexer.INT_CONST)
                            {
                                isdefined = Convert.ToInt64(value.Text) != 0;
                            }
                        }
                    }
                }
            }
            return isdefined;
        }

        private bool isDefineAllowed(IList<XSharpToken> line, int iPos)
        {
            // DEFINE will not be accepted immediately after or before a DOT
            // So this will not be recognized:
            // #define Console
            // System.Console.WriteLine("zxc")
            // But this will , since there are spaces around the token
            // System. Console .WriteLine("zxc")
            Debug.Assert(line?.Count > 0);
            if (iPos > 0 && line[iPos-1].Type == XSharpLexer.DOT )
            {
                return false;
            }
            if (iPos < line.Count-1)
            {
                var token = line[iPos + 1];
                if (token.Type == XSharpParser.DOT )
                    return false;
            }
            return true;
        }
        #region Preprocessor Directives

        private void checkForUnexpectedPPInput(IList<XSharpToken> line, int nMax)
        {
            if (line.Count > nMax)
            {
                addParseError(new ParseErrorData(line[nMax], ErrorCode.ERR_EndOfPPLineExpected));
            }
        }
        private void doRegionDirective(IList<XSharpToken> original)
        {
            var line = stripWs(original);
            if (line.Count < 2)
            {
                addParseError(new ParseErrorData(line[0], ErrorCode.WRN_PreProcessorWarning, "Region name expected"));
            }
            if (IsActive())
            {
                var token = line[0];
                regions.Push(token);
                writeToPPO(original,  true);
            }
            else
            {
                writeToPPO("");
            }
        }

        private void doEndRegionDirective(IList<XSharpToken> original)
        {
            var line = stripWs(original);
            Debug.Assert(line?.Count > 0);
            if (IsActive())
            {
                var token = line[0];
                if (regions.Count > 0)
                    regions.Pop();
                else
                    addParseError(new ParseErrorData(token, ErrorCode.ERR_PreProcessorError, "#endregion directive without matching #region found"));
                writeToPPO(original, true);
            }
            else
            {
                writeToPPO("");
            }
            // ignore comments after #endregion
            //checkForUnexpectedPPInput(line, 1);
        }

        private void doDefineDirective(IList<XSharpToken> original)
        {
            var line = stripWs(original);
            if (line.Count < 2)
            {
                addParseError(new ParseErrorData(line[0], ErrorCode.ERR_PreProcessorError, "Identifier expected"));
                return;
            }
            if (IsActive())
            {
                writeToPPO(original, true);
                addDefine(line, original);
            }
            else
            {
                writeToPPO("");
            }
        }

        private void doUnDefDirective(IList<XSharpToken> original)
        {
            var line = stripWs(original);
            if (line.Count < 2)
            {
                addParseError(new ParseErrorData(line[0], ErrorCode.ERR_PreProcessorError, "Identifier expected"));
                return;
            }
            if (IsActive())
            {
                removeDefine(line);
                writeToPPO(original, true);
            }
            else
            {
                writeToPPO("");
            }
            checkForUnexpectedPPInput(line, 2);
        }

        private void doErrorWarningDirective(IList<XSharpToken> original)
        {
            var line = stripWs(original);
            int nextType = line[0].Type;
            if (IsActive())
            {
                string text;
                XSharpToken ln;
                ln = line[0];
                if (line.Count < 2)
                {
                    text = "<Empty message>";
                }
                else
                {

                    writeToPPO(original, true);
                    int start = line[1].StartIndex;
                    int end = line[line.Count - 1].StopIndex;
                    text = line[1].TokenSource.InputStream.GetText(new Interval(start, end));
                }
                if (ln.SourceSymbol != null)
                    ln = ln.SourceSymbol;
                if (nextType == XSharpLexer.PP_WARNING)
                    addParseError(new ParseErrorData(ln, ErrorCode.WRN_WarningDirective, text));
                else
                    addParseError(new ParseErrorData(ln, ErrorCode.ERR_ErrorDirective, text));
                lastToken = ln;
            }
            else
            {
                writeToPPO( "");
            }
        }

        private void doIfDefDirective(IList<XSharpToken> original, bool isIfDef)
        {
            var line = stripWs(original);
            if (line.Count < 2)
            {
                addParseError(new ParseErrorData(line[0], ErrorCode.ERR_PreProcessorError, "Identifier expected"));
                return;
            }
            if (IsActive())
            {
                var def = line[1];
                if (XSharpLexer.IsIdentifier(def.Type) || XSharpLexer.IsKeyword(def.Type))
                {
                    if (isIfDef)
                        defStates.Push(IsDefined(def.Text,def));
                    else
                        defStates.Push(!IsDefined(def.Text, def));
                }
                else if (def.Type == XSharpLexer.MACRO)
                {
                    if (isIfDef)
                        defStates.Push(IsDefinedMacro(def));
                    else
                        defStates.Push(!IsDefinedMacro(def));
                }
                else
                {
                    addParseError(new ParseErrorData(def, ErrorCode.ERR_PreProcessorError, "Identifier expected"));
                }
                writeToPPO(original,  true);

            }
            else
            {
                defStates.Push(false);
                writeToPPO( "");
            }
            checkForUnexpectedPPInput(line, 2);
        }

        private void doElseDirective(IList<XSharpToken> original)
        {
            var line = stripWs(original);
            Debug.Assert(line?.Count > 0);
            writeToPPO(original, true);
            if (defStates.Count > 0)
            {
                bool a = defStates.Pop();
                if (IsActive())
                {
                    defStates.Push(!a);
                }
                else
                    defStates.Push(false);
            }
            else
            {
                addParseError(new ParseErrorData(Lt(), ErrorCode.ERR_PreProcessorError, "Unexpected #else"));
            }
            checkForUnexpectedPPInput(line, 1);
        }

        private void doEndifDirective(IList<XSharpToken> original)
        {
            var line = stripWs(original);
            Debug.Assert(line?.Count > 0);
            if (defStates.Count > 0)
            {
                defStates.Pop();
                if (IsActive())
                {
                    writeToPPO(original, true);
                }
                else
                {
                    writeToPPO("");
                }
            }
            else
            {
                addParseError(new ParseErrorData(Lt(), ErrorCode.ERR_PreProcessorError, "Unexpected #endif"));
                writeToPPO(line, true);
            }
            checkForUnexpectedPPInput(line, 1);
        }

        private void doIncludeDirective(IList<XSharpToken> original)
        {
            var line = stripWs(original);
            if (line.Count < 2)
            {
                addParseError(new ParseErrorData(line[0], ErrorCode.ERR_PreProcessorError, "Filename expected"));
                return;
            }
            if (IsActive())
            {
                writeToPPO(original, true);
                if (IncludeDepth() == MaxIncludeDepth)
                {
                    addParseError(new ParseErrorData(line[0], ErrorCode.ERR_PreProcessorError, "Reached max include depth: " + MaxIncludeDepth));
                }
                else
                {
                    var token = line[1];
                    if (token.Type == XSharpLexer.STRING_CONST)
                    {
                        string fileName = token.Text.Substring(1, token.Text.Length - 2);
                        ProcessIncludeFile(fileName, token);

                    }
                    else
                    {
                        addParseError(new ParseErrorData(token, ErrorCode.ERR_PreProcessorError, "String literal expected"));
                    }
                }
            }
            else
            {
                writeToPPO("");
            }
            checkForUnexpectedPPInput(line, 2);
        }

        private void doLineDirective(IList<XSharpToken> original)
        {
            var line = stripWs(original);
            Debug.Assert(line?.Count > 0);
            if (IsActive())
            {
                writeToPPO(original, true);
                var ln = line[1];
                if (ln.Type == XSharpLexer.INT_CONST)
                {
#if !VSPARSER
                    inputs.MappedLineDiff = (int)ln.SyntaxLiteralValue(_options,null, null).Value - (ln.Line + 1);
#else
                    if (Int32.TryParse(ln.Text, out var temp))
                    { 
                        inputs.MappedLineDiff = temp- (ln.Line + 1);
                    }
#endif

                    if (line.Count > 2)
                    {
                        ln = line[2];
                    }
                    if (ln.Type == XSharpLexer.STRING_CONST)
                    {
                        inputs.SourceFileName = ln.Text.Substring(1, ln.Text.Length - 2);
                    }
                    else
                    {
                        addParseError(new ParseErrorData(ln, ErrorCode.ERR_PreProcessorError, "String literal expected"));
                    }
                }
                else
                {
                    addParseError(new ParseErrorData(ln, ErrorCode.ERR_PreProcessorError, "Integer literal expected"));
                }
            }
            else
            {
                writeToPPO("");
            }
            checkForUnexpectedPPInput(line, 3);
        }

        private void doUnexpectedUDCSeparator(IList<XSharpToken> line)
        {
            Debug.Assert(line?.Count > 0);
            var ln = line[0];
            writeToPPO(line, true);
            addParseError(new ParseErrorData(ln, ErrorCode.ERR_PreProcessorError, "Unexpected UDC separator character found"));
        }

        private IList<XSharpToken> doNormalLine(IList<XSharpToken> line, bool write2PPO = true)
        {
            // Process the whole line in one go and apply the defines, macros and udcs
            // This is modeled after the way it is done in Harbour
            // 1) Look for and replace defines
            // 2) Look for and replace Macros (combined with 1) for performance)
            // 3) look for and replace (x)translates
            // 4) look for and replace (x)commands
            if (IsActive())
            {
                Debug.Assert(line?.Count > 0);
                IList<XSharpToken> result = null;
                bool changed = true;
                // repeat this loop as long as there are matches
                while (changed)
                {
                    changed = false;
                    if (line.Count > 0)
                    {
                        if (doProcessDefinesAndMacros(line, out result))
                        {
                            changed = true;
                            line = result;
                        }
                    }
                    if (_hasTransrules && line.Count > 0)
                    {
                        if (doProcessTranslates(line, out result))
                        {
                            changed = true;
                            line = result;
                        }
                    }
                    if (_hasCommandrules && line.Count > 0)
                    {
                        if (doProcessCommands(line, out result))
                        {
                            changed = true;
                            line = result;
                        }
                    }
                    if (changed && result != null)
                    {
                        result = _lexer.ReclassifyTokens(result);
                    }
                }
            }
            else
            {
                for (int i = 0; i < line.Count; i++)
                {
                    var t = line[i];
                    t.Original.Channel = XSharpLexer.DEFOUTCHANNEL;
                }
                line.Clear();
            }
            if (write2PPO)
            {
                if (line.Count > 0)
                    writeToPPO(line, false);
                else
                    writeToPPO("");
            }
            return line;
        }

        private static IList<XSharpToken> copySource(IList<XSharpToken> line, int nCount)
        {
            var result = new List<XSharpToken>(line.Count);
            var temp = new XSharpToken[nCount];
            for (int i = 0; i < nCount; i++)
            {
                temp[i] = line[i];
            }
            result.AddRange(temp);
            return result;
        }
        private bool doProcessDefinesAndMacros(IList<XSharpToken> line, out IList<XSharpToken> result)
        {
            Debug.Assert(line?.Count > 0);
            // we loop in here because one define may add tokens that are defined by another
            // such as:
            // #define FOO 1
            // #define BAR FOO + 1
            // when the code is "? BAR" then we need to translate this to "? 1 + 1"
            // For performance reasons we assume there is nothing to do, so we only
            // start allocating a result collection when a define is detected
            // otherwise we will simply return the original string
            bool hasChanged = false;
            IList<XSharpToken> tempResult = line;
            result = null;
            while (tempResult != null)
            {
                tempResult = null;
                // in a second iteration line will be the changed line
                for (int i = 0; i < line.Count; i++)
                {
                    var token = line[i];
                    IList<XSharpToken> deflist = null;
                    if (isDefineAllowed(line, i) && token.Text != null && symbolDefines.TryGetValue(token.Text, out deflist))
                    {
                        if (tempResult == null)
                        {
                            // this is the first define in the list
                            // allocate a result and copy the items 0 .. i-1 to the result
                            tempResult = copySource(line, i);
                        }
                        if (deflist != null)
                        {
                            foreach (var t in deflist)
                            {
                                var t2 = new XSharpToken(t)
                                {
                                    Channel = XSharpLexer.DefaultTokenChannel,
                                    SourceSymbol = token
                                };
                                tempResult.Add(t2);
                            }
                        }
                        else
                        {
                            // add a space so error messages look proper
                            var t2 = new XSharpToken(XSharpLexer.WS, " <RemovedToken> ")
                            {
                                Channel = XSharpLexer.Hidden,
                                SourceSymbol = token
                            };
                            tempResult.Add(t2);
                        }
                    }
                    else if (token.Type == XSharpLexer.MACRO)
                    {
                        // Macros that cannot be found are changed to ID
                        Func<XSharpToken, XSharpToken> ft;
                        if (macroDefines.TryGetValue(token.Text, out ft))
                        {
                            var nt = ft(token);
                            if (nt != null)
                            {
                                if (tempResult == null)
                                {
                                    // this is the first macro in the list
                                    // allocate a result and copy the items 0 .. i-1 to the result
                                    tempResult = copySource(line, i);
                                }
                                tempResult.Add(nt);
                            }
                        }
                    }
                    else if (tempResult != null)
                    {
                        tempResult.Add(token);
                    }
                }
                if (tempResult != null)
                {
                    // copy temporary result to line for next iteration
                    line = tempResult;
                    result = line;
                    hasChanged = true;
                }
            }
            return hasChanged; 
        }

        private bool doProcessTranslates(IList<XSharpToken> line, out IList<XSharpToken> result)
        {
            Debug.Assert(line?.Count > 0);
            var temp = new List<XSharpToken>();
            temp.AddRange(line);
            result = new List<XSharpToken>();
            var usedRules = new PPUsedRules(this, MaxUDCDepth);
            while (temp.Count > 0)
            {
                PPMatchRange[] matchInfo = null;
                var rule = transRules.FindMatchingRule(temp, out matchInfo);
                if (rule != null)
                {
                    temp = doReplace(temp, rule, matchInfo);
                    if (usedRules.HasRecursion(rule, temp))
                    {
                        // duplicate, so exit now
                        result.Clear();
                        return false;
                    }
                    // note that we do not add the result of the replacement to processed
                    // because it will processed further
                }
                else
                {
                    // first token of temp is not start of a #(x)translate. So add it to the result
                    // and try from second token etc
                    result.Add(temp[0]);
                    temp.RemoveAt(0);
                }
            }
            if (usedRules.Count > 0)
            {
                result.TrimLeadingSpaces();
                return true;
            }
            result = null;
            return false;
        }

        private List<IList<XSharpToken>> splitCommands(IList<XSharpToken> tokens, out IList<XSharpToken> separators)
        {
            var result = new List<IList<XSharpToken>>(10);
            var current = new List<XSharpToken>(tokens.Count);
            separators = new List<XSharpToken>();
            foreach (var t in tokens)
            {
                if (t.Type == XSharpLexer.EOS)
                {
                    current.TrimLeadingSpaces();
                    result.Add(current);
                    current = new List<XSharpToken>();
                    separators.Add(t);
                }
                else
                {
                    current.Add(t);
                }
            }
            result.Add(current);
            return result;
        }
        private bool doProcessCommands(IList<XSharpToken> line, out IList<XSharpToken>  result)
        {
            Debug.Assert(line?.Count > 0);
            line = stripWs(line);
            result = null;
            if (line.Count == 0)
                return false;
            result = line;
            var usedRules = new PPUsedRules(this, MaxUDCDepth);
            while (true)
            {
                PPMatchRange[] matchInfo = null;
                var rule = cmdRules.FindMatchingRule(result, out matchInfo);
                if (rule == null)
                {
                    // nothing to do, so exit. Leave changed the way it is. This does not have to be the first iteration
                    break;
                }
                result = doReplace(result, rule, matchInfo);
                if (usedRules.HasRecursion(rule, result))
                {
                    // duplicate so exit now
                    result.Clear();
                    return false;
                }
                // the UDC may have introduced a new semi colon and created more than one sub statement
                // so check to see and then process every statement
                IList<XSharpToken> separators;
                var cmds = splitCommands(result, out separators);
                Debug.Assert(cmds.Count == separators.Count + 1);
                if (cmds.Count <= 1)
                {
                    // single statement result. Try again to see if the new statement matches another UDC rule
                    continue;
                }
                else
                {
                    // multi statement result. Process each statement separately (recursively) as a 'normal line'
                    // the replacement may have introduced the usage of a define, translate or macro
                    result.Clear();
                    for (int i = 0; i < cmds.Count; i++)
                    {
                        if (cmds[i].Count > 0)
                        {
						    var res = ProcessLine(cmds[i]);
							if (res == null)
	                            cmds[i].Clear();
							else
								cmds[i] = res;

                            foreach (var token in cmds[i])
                            {
                                result.Add(token);
                            }
                            if (i < cmds.Count - 1)
                            {
                                result.Add(separators[i]);
                            }
                        }
                    }
                }
            }
            if (usedRules.Count > 0)
            {
                // somerule => #Error 
                result.TrimLeadingSpaces();
                if (result[0].Channel == XSharpLexer.PREPROCESSORCHANNEL)
                { 
                    result = ProcessLine(result);
                    if (result == null)
                    {
                        result = new List<XSharpToken>();
                    }
                }
                return true;
            }
            result = null;
            return false;
        }

        private void doEOFChecks()
        {
            if (defStates.Count > 0)
            {
                addParseError(new ParseErrorData(Lt(), ErrorCode.ERR_EndifDirectiveExpected));
            }
            while (regions.Count > 0)
            {
                var token = regions.Pop();
                addParseError(new ParseErrorData(token, ErrorCode.ERR_EndRegionDirectiveExpected));
            }
        }

        #endregion

        private List<XSharpToken> doReplace(IList<XSharpToken> line, PPRule rule, PPMatchRange[] matchInfo)
        {
            Debug.Assert(line?.Count > 0);
            var res = rule.Replace(line, matchInfo);
            rulesApplied += 1;
            var result = new List<XSharpToken>();
            result.AddRange(res);
            if (_options.Verbose)
            {
                int lineNo;
                if (line[0].SourceSymbol != null)
                    lineNo = line[0].SourceSymbol.Line;
                else
                    lineNo = line[0].Line;
                DebugOutput("----------------------");
                DebugOutput("File {0} line {1}:", _fileName, lineNo);
                DebugOutput("   UDC   : {0}", rule.GetDebuggerDisplay());
                DebugOutput("   Input : {0}", line.AsString());
                DebugOutput("   Output: {0}", res.AsString());
            }
            return result;
        }
    }
}
