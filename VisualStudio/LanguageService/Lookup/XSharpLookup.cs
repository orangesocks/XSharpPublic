﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using XSharpModel;
using LanguageService.SyntaxTree;
using LanguageService.CodeAnalysis.XSharp.SyntaxParser;
using System.Collections.Immutable;
using System.Diagnostics;
using Microsoft.VisualStudio.Shell.Interop;

namespace XSharp.LanguageService
{
    internal static class XSharpLookup
    {

        internal static bool StringEquals(string lhs, string rhs)
        {
            if (string.Equals(lhs, rhs, StringComparison.OrdinalIgnoreCase))
                return true;
            return false;
        }
        static readonly List<string> nestedSearches = new List<string>();
        static public IEnumerable<IXSymbol> FindIdentifier(XSharpSearchLocation location, string name, IXTypeSymbol currentType, Modifiers visibility)
        {
            var result = new List<IXSymbol>();
            if (nestedSearches.Contains(name, StringComparer.OrdinalIgnoreCase))
            {
                return null;
            }
            int nestedLevel = nestedSearches.Count();
            try
            {
                nestedSearches.Add(name);
                if (currentType == null)
                {
                    currentType = location.Member.ParentType;
                }
                // we search in the order:
                // 1) Parameters (for entities with parameters)
                // 2) Locals (for entities with locals)
                // 3) Properties or Fields
                // 4) Globals and Defines
                if (XSettings.EnableTypelookupLog)
                    WriteOutputMessage($"--> FindIdentifier in {currentType.FullName}, '{name}' ");
                var member = location.Member;
                if (member.Kind.HasParameters())
                {
                    result.AddRange(member.Parameters.Where(x => StringEquals(x.Name, name)));
                }
                if (result.Count == 0)
                {
                    // then Locals
                    // line numbers in the range are 1 based. currentLine = 0 based !
                    if (member.Kind.HasBody())
                    {
                        var local = member.GetLocals(location).Where(x => StringEquals(x.Name, name) && x.Range.StartLine - 1 <= location.LineNumber).LastOrDefault();
                        if (local != null)
                        {
                            result.Add(local);
                        }
                    }
                }
                foreach (XSourceVariableSymbol variable in result)
                {
                    if (variable.File == null)
                        variable.File = member.File;
                }
                if (result.Count == 0)
                {
                    // We can have a Property/Field of the current CompletionType
                    if (currentType != null)
                    {
                        result.AddRange(SearchPropertyOrField(location, currentType, name, visibility));
                    }
                    if (result.Count == 0)
                    {
                        var glob = location.File.Project.FindGlobalOrDefine(name);
                        if (glob != null)
                        {
                            result.Add(glob);
                        }
                    }
                    if (result.Count == 0)
                    {
                        // Now, search for a Global in external Assemblies
                        //
                        result.AddRange(SearchGlobalField(location, name));
                    }
                }
                if (result.Count > 0)
                {
                    var element = result[0];
                    if (element is XSourceImpliedVariableSymbol xVar)
                    {
                        var type = ResolveImpliedType(location, xVar, currentType, visibility);
                        if (type != null)
                        {
                            xVar.TypeName = type.FullName.GetXSharpTypeName();
                        }

                    }
                }
            }
            catch (Exception ex)
            {
                XSettings.DisplayOutputMessage("FindIdentifier failed: ");
                XSettings.DisplayException(ex);
            }
            finally
            {
                while (nestedSearches.Count > nestedLevel)
                {
                    nestedSearches.Remove(nestedSearches.Last());
                }
            }
            return result;
        }

        public static XSourceMemberSymbol FindMemberAtPosition(int nPosition, XFile file)
        {
            if (file == null || file.EntityList == null)
            {
                return null;
            }
            var member = file.FindMemberAtPosition(nPosition);
            if (member is XSourceMemberSymbol)
            {
                return member as XSourceMemberSymbol;
            }
            // if we can't find a member then look for the global type in the file
            // and return its last member
            var xType = file.TypeList.FirstOrDefault();
            if (xType.Value != null)
            {
                return xType.Value.XMembers.LastOrDefault();
            }
            if (XSettings.EnableTypelookupLog)
                WriteOutputMessage(string.Format("Cannot find member at 0 based position {0} in file {0} .", nPosition, file.FullPath));
            return null;

        }

        public static XSourceMemberSymbol FindMember(int nLine, XFile file)
        {
            if (file == null || file.EntityList == null)
            {
                return null;
            }
            var member = file.FindMemberAtRow(nLine);
            if (member is XSourceMemberSymbol)
            {
                return member as XSourceMemberSymbol;
            }
            if (member is XSourceTypeSymbol xtype)
            {
                if (xtype.Members.Count > 0)
                {
                    return xtype.Members.LastOrDefault() as XSourceMemberSymbol;
                }
            }
            // try a few rows before
            member = file.FindMemberAtRow(Math.Max(nLine - 10, 1));
            if (member is XSourceMemberSymbol)
            {
                return member as XSourceMemberSymbol;
            }
            if (member is XSourceTypeSymbol xtype1)
            {
                if (xtype1.XMembers.Count > 0)
                {
                    return xtype1.XMembers.LastOrDefault();
                }
            }

            // if we can't find a member then look for the global type in the file
            // and return its last member
            var ent = file.EntityList.LastOrDefault();
            if (ent is XSourceMemberSymbol)
                return ent as XSourceMemberSymbol;
            if (ent is XSourceTypeSymbol symbol)
            {
                return symbol.XMembers.LastOrDefault();
            }


#if DEBUG
            if (XSettings.EnableTypelookupLog)
                WriteOutputMessage(string.Format("Cannot find member at 0 based line {0} in file {0} .", nLine, file.FullPath));
#endif
            return null;
        }

        private static string GetTypeNameFromSymbol(XSharpSearchLocation location, IXSymbol symbol)
        {
            if (symbol is IXTypeSymbol ts)
                return ts.FullName;
            string name = null;
            if (symbol is IXMemberSymbol mem)
            {
                if (mem.Kind is Kind.Constructor)
                {
                    name = mem.ParentType.FullName;
                }
                else
                {
                    name = mem.OriginalTypeName;
                }
            }
            if (symbol is IXVariableSymbol)
            {
                name = symbol.TypeName;
            }
            return name;
        }


        private static IXTypeSymbol GetTypeFromSymbol(XSharpSearchLocation location, IXSymbol symbol)
        {
            if (symbol is IXTypeSymbol ts)
                return ts;
            var name = GetTypeNameFromSymbol(location, symbol);
            if (name == null)
                return null;
            if (name.EndsWith("[]"))
            {
                name = "System.Array";
            }
            return SearchType(location, name).FirstOrDefault();
        }

        private static IXTypeSymbol ResolveImpliedLoop(XSharpSearchLocation location, XSourceImpliedVariableSymbol xVar, IXTypeSymbol currentType, Modifiers visibility)
        {
            //  Resolve the type of a loop variable. To do so we split the line in the part before and after the TO/UPTO/DOWNTO
            Debug.Assert(xVar.ImpliedKind == ImpliedKind.LoopCounter);
            var start = new List<XSharpToken>();
            var end = new List<XSharpToken>();
            bool seento = false;
            foreach (var t in xVar.Expression)
            {
                switch (t.Type)
                {
                    case XSharpLexer.TO:
                    case XSharpLexer.UPTO:
                    case XSharpLexer.DOWNTO:
                        seento = true;
                        break;
                    default:
                        if (seento)
                            end.Add(t);
                        else
                            start.Add(t);
                        break;
                }
            }
            if (start.Count > 0 && end.Count > 0)
            {
                if (start.Count == 1 && end.Count == 1)
                {
                    var startType = start[0].Type;
                    var endType = end[0].Type;
                    // when one of the 2 is an ID then we resolve to the type of the Id. First is leading
                    if (startType == XSharpLexer.ID)
                    {
                        var id = FindIdentifier(location, start[0].Text, currentType, visibility);
                        return GetTypeFromSymbol(location, id.FirstOrDefault());
                    }
                    else if (endType == XSharpLexer.ID)
                    {
                        var id = FindIdentifier(location, end[0].Text, currentType, visibility);
                        return GetTypeFromSymbol(location, id.FirstOrDefault());
                    }
                    // if the one of the two is constant we take the type of the constant.
                    else if (XSharpLexer.IsConstant(startType))
                    {
                        return GetConstantType(start[0], location.File);
                    }

                    else if (XSharpLexer.IsConstant(endType))
                    {
                        return GetConstantType(end[0], location.File);
                    }
                    //todo what else ?
                    return null;
                }
                string notProcessed;
                if (end.Count > 1)  // prefer type of end over type of start
                {
                    var res = RetrieveElement(location, end, CompletionState.General, out notProcessed);
                    return GetTypeFromSymbol(location, res.FirstOrDefault());
                }
                // start must be > 1
                var result = RetrieveElement(location, start, CompletionState.General, out notProcessed);
                return GetTypeFromSymbol(location, result.FirstOrDefault());
            }
            return null;
        }
        private static IXTypeSymbol ResolveImpliedCollection(XSharpSearchLocation location, XSourceImpliedVariableSymbol xVar, IXTypeSymbol currentType, Modifiers visibility)
        {
            // Resolve the VAR type of an element in a collection
            var tokenList = xVar.Expression;
            var result = RetrieveElement(location, tokenList, CompletionState.General, out var notProcessed);
            var element = result.FirstOrDefault();
            if (element == null)
                return null;
            xVar.Collection = element;
            var elementType = GetTypeNameFromSymbol(location, element);
            if (elementType.EndsWith("[]"))
            {
                return SearchType(location, elementType.Substring(0, elementType.Length - 2)).FirstOrDefault();
            }
            var type = GetTypeFromSymbol(location, element);
            var etype = getElementType(type, location, element);

            return etype;
        }

        private static IXTypeSymbol getElementType(IXTypeSymbol type, XSharpSearchLocation location, IXSymbol element)
        {
            string elementType;
            type.ForceComplete();
            if (type.IsArray)
            {
                elementType = type.ElementType;
                var p = location.FindType(elementType);
                if (p != null)
                    return p;
            }
            var prop = type.GetProperties().Where((p) => p.Parameters.Count > 0).FirstOrDefault();
            if (prop != null)
            {
                var typeName = prop.TypeName;
                if (type.IsGeneric)
                {
                    var typeparams = type.TypeParameters;
                    if (typeparams.Count > 0 && element is XSourceEntity xse)
                    {
                        var genargs = xse.GenericArgs;
                        var index = typeparams.IndexOf(typeName);
                        if (index > -1 && index < genargs.Length)
                        {
                            typeName = genargs[index];
                        }
                    }
                }
                var p = location.FindType(typeName);
                if (p != null)
                    return p;

            }
            if (type.HasEnumerator())
            {
                var member = type.GetMembers("GetEnumerator").FirstOrDefault();
                var enumtype = SearchType(location, member.OriginalTypeName).FirstOrDefault();
                var current = enumtype.GetProperties("Current").FirstOrDefault();
                elementType = current?.OriginalTypeName;
                if (type.IsGeneric)
                {
                    var p = location.FindType(elementType);
                    if (p != null)
                        return p;
                }
            }
            return null;
        }

        private static IXTypeSymbol ResolveImpliedOutParam(XSharpSearchLocation location, XSourceImpliedVariableSymbol xVar, IXTypeSymbol currentType, Modifiers visibility)
        {
            // TODO: Resolve type lookup Out Parameters
            Debug.Assert(xVar.ImpliedKind == ImpliedKind.OutParam);
            return null;
        }
        private static IXTypeSymbol ResolveImpliedAssign(XSharpSearchLocation location, XSourceImpliedVariableSymbol xVar, IXTypeSymbol currentType, Modifiers visibility)
        {
            Debug.Assert(xVar.ImpliedKind == ImpliedKind.Assignment || xVar.ImpliedKind == ImpliedKind.Using);
            var tokenList = xVar.Expression;
            var result = RetrieveElement(location, tokenList, CompletionState.General, out var notProcessed);
            var element = result.FirstOrDefault();
            return GetTypeFromSymbol(location, element);
        }
        private static IXTypeSymbol ResolveImpliedType(XSharpSearchLocation location, XSourceImpliedVariableSymbol xVar, IXTypeSymbol currentType, Modifiers visibility)
        {
            // the following Implied Kinds are followed by a := and should return the type of the expression in the ExpressionList
            switch (xVar.ImpliedKind)
            {
                case ImpliedKind.Assignment:
                case ImpliedKind.Using:
                    return ResolveImpliedAssign(location, xVar, currentType, visibility);
                case ImpliedKind.TypeCheck:
                    return SearchType(location, xVar.TypeName).FirstOrDefault();
                case ImpliedKind.InCollection:
                    return ResolveImpliedCollection(location, xVar, currentType, visibility);
                case ImpliedKind.LoopCounter:
                    return ResolveImpliedLoop(location, xVar, currentType, visibility);
                case ImpliedKind.OutParam:
                    return ResolveImpliedOutParam(location, xVar, currentType, visibility);
                case ImpliedKind.None:
                    break;
            }
            return null;
        }


        /// <summary>
        /// Retrieve the CompletionType based on :
        ///  The Token list returned by GetTokenList()
        ///  The Token that stops the building of the Token List.
        /// </summary>
        /// <param name="location"></param>
        /// <param name="tokenList"></param>
        /// <param name="state"></param>
        /// <param name="foundElement"></param>
        /// <param name="stopAtOpenToken"></param>
        /// <returns></returns>
        public static IList<IXSymbol> RetrieveElement(XSharpSearchLocation location, IList<XSharpToken> tokenList,
            CompletionState state, out string notProcessed, bool stopAtOpenToken = false )
        {
            //
            notProcessed = "";
            var result = new List<IXSymbol>();
            if (tokenList == null || tokenList.Count == 0)
                return result;
            var symbols = new Stack<IXSymbol>();
            IXTypeSymbol currentType = null;
            int currentPos = 0;
            var startOfExpression = true;
            var findConstructor = false;
            XSharpToken currentToken = null;
            IXTypeSymbol startType = null;
            //
            if (location.Member == null)
            {
                // This is a lookup outside code.
                // Could be USING or USING STATIC statement.
                // We allow the lookup of Namespaces or Types
                // 
                if (!state.HasFlag(CompletionState.Namespaces) && !state.HasFlag(CompletionState.Types))
                    return result;
                StringBuilder sb = new StringBuilder();
                foreach (var token in tokenList)
                {
                    sb.Append(token.Text);
                }
                if (state.HasFlag(CompletionState.Namespaces))
                    result.AddRange(SearchNamespaces(location, sb.ToString()));
                if (state.HasFlag(CompletionState.Types))
                    result.AddRange(SearchType(location, sb.ToString()));

                return result;
            }
            // Context Type....
            if (location.Member.Kind.IsClassMember(location.Dialect))
            {
                currentType = location.Member.ParentType;
                symbols.Push(currentType);
            }
            else if (location.Member.Kind == Kind.EnumMember)
            {
                currentType = location.Member.ParentType;
                symbols.Push(currentType);

            }
            Modifiers visibility = Modifiers.Private;
            int lastopentoken = tokenList.Count - 1;
            if (stopAtOpenToken)
            {
                for (int i = 0; i < tokenList.Count; i++)
                {
                    var token = tokenList[i];
                    switch (token.Type)
                    {
                        case XSharpLexer.LPAREN:
                        case XSharpLexer.LCURLY:
                        case XSharpLexer.LBRKT:
                            lastopentoken = i;
                            break;
                    }
                }
            }
            string namespacePrefix = "";
            int stopAt = 0;
            var hasBracket = false;
            int count = -1;
            startType = currentType;
            bool resetState = false;
            while (currentPos <= lastopentoken)
            {
                result.Clear();
                notProcessed = "";
                if (symbols.Count > 0 && symbols.Count != count)
                {
                    var top = symbols.Peek();
                    currentType = GetTypeFromSymbol(location, top);
                    top.ResolvedType = currentType;
                    count = symbols.Count;
                    if (top.Kind == Kind.Namespace)
                    {
                        namespacePrefix = top.Name+".";
                    }
                }
                if (resetState)
                    state = CompletionState.General;
                if (startOfExpression)
                    currentType = startType;
                currentToken = tokenList[currentPos];
                if (stopAt != 0 && currentToken.Type != stopAt)
                {
                    currentPos += 1;
                    continue;
                }
                stopAt = 0;
                var currentName = currentToken.CleanText();
                var lastToken = currentToken;
                var nextType = 0;
                if (currentPos < lastopentoken)
                {
                    nextType = tokenList[currentPos + 1].Type;
                }
                switch (currentToken.Type)
                {
                    case XSharpLexer.LPAREN:
                        currentPos += 1;
                        if (hasToken(tokenList, currentPos + 1, XSharpLexer.RPAREN))
                        {
                            stopAt = XSharpLexer.RPAREN;
                        }
                        startOfExpression = true;
                        continue;
                    case XSharpLexer.LCURLY:
                        currentPos += 1;
                        if (hasToken(tokenList, currentPos + 1, XSharpLexer.RCURLY))
                        {
                            stopAt = XSharpLexer.RCURLY;
                        }
                        startOfExpression = true;
                        continue;
                    case XSharpLexer.LBRKT:
                        currentPos += 1;
                        if (hasToken(tokenList, currentPos + 1, XSharpLexer.RBRKT))
                        {
                            stopAt = XSharpLexer.RBRKT;
                        }
                        hasBracket = true;
                        startOfExpression = true;
                        continue;
                    case XSharpLexer.RPAREN:
                    case XSharpLexer.RCURLY:
                    case XSharpLexer.RBRKT:
                        currentPos += 1;
                        hasBracket = (currentToken.Type == XSharpLexer.RBRKT);
                        if (symbols.Count > 0 && hasBracket )
                        {
                            if (nextType == XSharpLexer.LCURLY)
                            {
                                // [] is followed by a ctor as in 
                                // var aValue := string[]{
                                var top = symbols.Peek();
                                var typeName = top.FullName + "[]";
                                var type = SearchType(location, typeName).FirstOrDefault();
                                if (type != null)
                                    symbols.Push(type);
                                state = CompletionState.Constructors;
                                resetState = false;
                            }
                            else
                            {
                                var top = symbols.Peek();
                                var type = findElementType(top, location);
                                if (type != null)
                                    symbols.Push(type);
                            }
                        }
                        continue;
                    case XSharpLexer.DOT:
                    case XSharpLexer.COLON:
                    default:
                        hasBracket = false;
                        break;
                }
                var isId = currentToken.Type == XSharpLexer.ID ||
                                  currentToken.Type == XSharpLexer.KWID ||
                                  currentToken.Type == XSharpLexer.COLONCOLON ||
                                  XSharpLexer.IsKeyword(currentToken.Type);
                if (isId && currentPos < lastopentoken && tokenList[currentPos + 1].Type == XSharpLexer.LT)
                {
                    currentPos += 1;
                    while (currentPos <= lastopentoken)
                    {
                        var nextToken = tokenList[currentPos];
                        currentName += nextToken.Text;
                        currentPos += 1;
                        if (nextToken.Type == XSharpLexer.GT)
                            break;
                    }
                }
                var qualifiedName = false;
                var findMethod = false;
                var findType = state.HasFlag(CompletionState.Types) || state.HasFlag(CompletionState.General);
                var literal = XSharpLexer.IsConstant(currentToken.Type);
                if (isId)
                {
                    qualifiedName = nextType == XSharpLexer.DOT;
                    findMethod = nextType == XSharpLexer.LPAREN;
                    findConstructor = nextType == XSharpLexer.LCURLY;
                }
                if (state.HasFlag(CompletionState.StaticMembers) && ! findMethod && result.Count == 0)
                {
                    var props = SearchPropertyOrField(location, currentType, namespacePrefix+currentName, visibility).Where(m => m.IsStatic);
                    result.AddRange(props);
                }
                if (state.HasFlag(CompletionState.InstanceMembers) && !findMethod && result.Count == 0)
                {
                    var props = SearchPropertyOrField(location, currentType, namespacePrefix + currentName, visibility).Where(m => !m.IsStatic);
                    result.AddRange(props);
                }

                if (literal)
                {
                    currentType = GetConstantType(currentToken, location.File);
                    symbols.Push(currentType);
                }
                else if (findMethod)
                {
                    // Do we already know in which Type we are ?
                    if (currentToken.Type == XSharpLexer.SELF)  // SELF(..)
                    {
                        result.AddRange(SearchConstructor(currentType, visibility, location));
                    }
                    else if (currentToken.Type == XSharpLexer.SUPER) // SUPER(..)
                    {
                        if (currentType is XSourceTypeSymbol source)
                        {
                            var p = source.File.FindType(source.BaseTypeName, source.Namespace);
                            result.AddRange(SearchConstructor(p, visibility, location));
                        }
                        else
                        {
                            var p = location.FindType(currentType.BaseTypeName);
                            result.AddRange(SearchConstructor(p, visibility, location));
                        }
                    }
                    else if (startOfExpression)
                    {
                        // The first token in the list can be a Function or a Procedure
                        // Except if we already have a Type
                        result.AddRange(SearchFunction(location, currentName));
                        if (currentType != null)
                        {
                            result.AddRange(SearchMethod(location, currentType, currentName, visibility, false));
                        }
                        result.AddRange(SearchMethodStatic(location, currentName));
                        if (result.Count == 0)
                        {
                            // Foo() could be a delegate call where Foo is a local or Field
                            result.AddRange(SearchDelegateCall(location, currentName, currentType, visibility));
                        }
                        if (result.Count == 0)
                        {
                            // Foo() can be a method call inside the current class
                            var type = location?.Member?.ParentType ?? currentType;
                            result.AddRange(SearchMethod(location, type, currentName, visibility, false));
                        }

                        if (currentPos == lastopentoken || currentPos == lastopentoken - 1)
                        {
                            return result;
                        }
                        if (result.Count > 0)
                        {
                            symbols.Push(result[0]);
                        }

                    }
                    else if (currentType != null)
                    {
                        // Now, search for a Method. this will search the whole hierarchy
                        // Respect the StaticMembers and InstanceMembers states
                        if (state.HasFlag(CompletionState.StaticMembers))
                        {
                            result.AddRange(SearchMethod(location, currentType, currentName, visibility, true));
                        }
                        if (state.HasFlag(CompletionState.InstanceMembers))
                        {
                            result.AddRange(SearchMethod(location, currentType, currentName, visibility, false));
                        }
                    }
                    if (result.Count > 0)
                    {
                        symbols.Push(result[0]);
                    }
                    if (result.Count == 0)
                    {
                        // Could it be Static Method with "Using Static"
                        result.AddRange(SearchMethodStatic(location, currentName));
                        if (result.Count > 0)
                        {
                            symbols.Push(result[0]);
                        }
                    }
                }
                else if (isId)
                {
                    // Order:
                    // 1) Locals and Parameters (only at start)
                    // 2) Properties and Fields (only at start)
                    // 3) Types
                    // 4) Namespaces
                    // Types first because when we have a nested type then the parent is also registered as a namespace
                    // but we want to find the type of course
                    if (startOfExpression)
                    {
                        // Search in Parameters, Locals, Field and Properties
                        if (currentName == "::" || currentName.ToLower() == "this")
                        {
                            currentName = "SELF";
                        }
                        // 1) Locals and Parameters
                        result.AddRange(FindIdentifier(location, currentName, currentType, Modifiers.Private));
                        if (result.Count == 0)
                        {
                            // 2) Properties and Fields
                            result.AddRange(SearchPropertyOrField(location, currentType, currentName, visibility));
                        }
                    }
                    if (result.Count == 0 && (startOfExpression || findType || findConstructor || qualifiedName))
                    {
                        // 3) Types
                        result.AddRange(SearchType(location, namespacePrefix + currentName));
                        if (result.Count == 0)
                        {
                            // 4) Namespaces
                            result.AddRange(SearchNamespaces(location, namespacePrefix + currentName));
                        }
                    }
                    if (result.Count > 0)
                    {
                        symbols.Push(result[0]);
                    }
                    else
                    {
                        notProcessed = namespacePrefix + currentName;
                    }
                }
                // We have it
                if (hasBracket && symbols.Count > 0)
                {
                    var type = currentType;
                    var symbol = symbols.Peek();

                }
                currentPos += 1;
                if (currentPos >= tokenList.Count)
                {
                    break;
                }
                currentToken = tokenList[currentPos];
                resetState = true;
                switch (currentToken.Type)
                {
                    case XSharpLexer.DOT:
                       currentPos += 1;
                        state = CompletionState.StaticMembers| CompletionState.Namespaces | CompletionState.Types;
                        if (location.Project.ParseOptions.AllowDotForInstanceMembers)
                            state |= CompletionState.InstanceMembers;
                        resetState = false;
                        break;

                    case XSharpLexer.COLON:
                        state = CompletionState.InstanceMembers;
                        resetState = false;
                        currentPos += 1;
                        break;

                    case XSharpLexer.COLONCOLON:
                        currentPos += 1;
                        break;
                }
                switch (lastToken.Type)
                {
                    case XSharpLexer.LPAREN:
                    case XSharpLexer.LCURLY:
                    case XSharpLexer.LBRKT:
                    case XSharpLexer.COMMA:
                    case XSharpLexer.PLUS:
                    case XSharpLexer.MINUS:
                    case XSharpLexer.MULT:
                    case XSharpLexer.DIV:
                    case XSharpLexer.EQ:
                    case XSharpLexer.LT:
                    case XSharpLexer.GT:
                        startOfExpression = true;
                        break;
                    case XSharpLexer.COLON:
                    case XSharpLexer.DOT:
                        startOfExpression = false;
                        break;
                    default:
                        if (XSharpLexer.IsOperator(lastToken.Type))
                        { 
                            startOfExpression = true;
                            symbols.Clear();
                        }
                        else
                            startOfExpression = false;
                        break;
                }
            }
            result.Clear();
            if (symbols.Count > 0)
            {
                result.Add(symbols.Pop());
                if (result[0] is IXMemberSymbol xmember && xmember.ParentType != null && xmember.ParentType.IsGeneric && symbols.Count > 0)
                {
                    result.Clear();
                    result.Add(AdjustGenericMember(xmember, symbols.Peek()));
                }
            }
            if (result.Count > 0 && result[0] is IXTypeSymbol xtype && state == CompletionState.Constructors)
            {
                result.Clear();
                result.AddRange(xtype.GetMembers(".ctor"));
            }
            if (result.Count == 0)
            {
                var namespaces = location.Project.AllNamespaces.Where(n => n == namespacePrefix);
                if (namespaces.Count() > 0)
                {
                    var ns = namespaces.First();
                    result.Add(new XSymbol(ns, Kind.Namespace, Modifiers.Public));
                }
                

            }
            if (result.Count > 0)
            {
                var res = result[0];
                if (res.Kind.IsClassMember(location.Project.Dialect))
                {
                    var member = res as IXMemberSymbol;
                    var type = res.Parent as IXTypeSymbol;
                    if (type != null && type.IsGeneric)
                    {
                        // find element on the stack that has this type
                        IXSymbol symbol = null;
                        foreach (var item in symbols)
                        {
                            if (item.ResolvedType == type)
                            { 
                                symbol = item;
                                break;
                            }
                        }
                        string[] elements = null;
                        if (symbol is XSourceEntity xse && xse.GenericArgs != null)
                        {
                            elements = xse.GenericArgs.ToArray();
                        }
                        if (elements != null)
                        {
                            member = member.Clone();
                            var typeParams = type.TypeParameters;
                            // check to see if parameters or return value is one of the type parameters
                            // if so, then check the symbols to see where the type is used and with which
                            // concrete parameters
                            int pos;
                            foreach (var param in member.Parameters)
                            {
                                pos = typeParams.IndexOf(param.TypeName);
                                if (pos >= 0)
                                {
                                    param.TypeName = elements[pos];
                                }
                            }
                            pos = typeParams.IndexOf(member.TypeName);
                            if (pos >= 0)
                            {
                                member.TypeName = elements[pos ];
                            }
                            result[0] = member;
                        }
                    }
                }
            }
            return result;
        }

        private static IXTypeSymbol findElementType(IXSymbol symbol, XSharpSearchLocation location)
        {
            if (symbol.IsArray)
            {
                var elementType = symbol.ElementType;
                var p = location.FindType(elementType);
                if (p != null)
                    return p;
            }
            if (symbol.TypeName != null && symbol.TypeName.EndsWith("[]"))
            {
                return SearchType(location, symbol.TypeName.Substring(0, symbol.TypeName.Length - 2)).FirstOrDefault();
            }
            else
            {
                var type = symbol.ResolvedType;
                if (type != null)
                {
                    var prop = type.GetProperties().Where((p) => p.Parameters.Count > 0).FirstOrDefault();
                    if (prop != null)
                    {
                        var tn = prop.TypeName;
                        if (type.IsGeneric && symbol is XSourceEntity xse)
                        {
                            var realargs = xse.GenericArgs;
                            tn = ReplaceTypeParameters(tn, type.TypeParameters, realargs);

                        }
                        var p = location.FindType(tn);
                        if (p != null)
                            return p;
                    }
                }
            }
            return null;
        }
        private static bool hasToken(IList<XSharpToken> tokens, int start, int lookfor)
        {
            for (int i = start; i < tokens.Count; i++)
            {
                if (tokens[i].Type == lookfor)
                    return true;
            }
            return false;
        }
        private static IXMemberSymbol AdjustGenericMember(IXMemberSymbol xmember, IXSymbol memberdefinition)
        {
            /*
             * This code was added to solve the following
             * LOCAL coll as Dictionary<STRING, LONG>
             * FOREACH var item in coll
             *   ? Item:Key: // should return members of STRING
             *   ? Item:Value: // should return members of LONG
             * NEXT
             * Item:Key is defined as TKey
             * Item:Value is defined as TValue
             * We will probably have to get the next element on the stack, and extract its generic args
             * and then find the correct argument and resolve TKey to STRING and TValue to LONG
             * 
             * We should also fix the parameter types for
             * LOCAL coll as Dictionary<STRING, LONG>
             * coll:Add()           // types are TKey and TValue and should become STRING and INT
             * coll:ContainsKey()   // param type = TKey and should be changed to STRING
            */
            var type = xmember.ParentType;
            var typeParameters = type.TypeParameters;
            var resultType = xmember.TypeName;
            var pos = typeParameters.IndexOf(resultType);
            if (pos == -1)
            {
                foreach (var param in xmember.Parameters)
                {
                    pos = typeParameters.IndexOf(param.TypeName);
                    if (pos >= 0)
                    {
                        break;
                    }
                }
            }
            if (pos >= 0 )       // return type or parameter type of member is one of the generic arguments
            {
                xmember = xmember.Clone();
                if (memberdefinition is XSourceVariableSymbol xvar)
                {
                    var realargs = xvar.GenericArgs;
                    if (!xvar.IsGeneric && xvar is XSourceImpliedVariableSymbol impvar)
                    {
                        if (impvar.Collection != null && impvar.Collection is XSourceVariableSymbol xvar2)
                        {
                            xvar = xvar2;
                            realargs = xvar.GenericArgs;
                        }
                    }
                    if (xvar.IsGeneric  && realargs.Length == typeParameters.Count)
                    {
                        pos = typeParameters.IndexOf(xmember.TypeName);
                        if (pos >=0)
                            xmember.TypeName = realargs[pos];
                        foreach (var param in xmember.Parameters)
                        {
                            pos = typeParameters.IndexOf(param.TypeName);
                            if (pos >= 0)
                            {
                                param.TypeName = realargs[pos];
                            }
                        }
                    }
                }
            }
            return xmember;
        }

        private static string[] GetRealTypeParameters(string typeName)
        {
            var pos = typeName.IndexOf('<');
            if (pos > 0)
            {
                var args = typeName.Substring(pos);
                var elements = args.Split(new char[] { '<', '>', ',' }, StringSplitOptions.RemoveEmptyEntries);
                return elements;
            }
            return new string[] { };
        }
        private static string ReplaceTypeParameters(string typeName, IList<String> genericParameters, IList<String> realParameters)
        {
            if (genericParameters.Count == realParameters.Count)
            {
                for (int i = 0; i < genericParameters.Count; i++)
                {
                    typeName = typeName.Replace(genericParameters[i], realParameters[i]);
                }
            }
            return typeName;
        }

        /// <summary>
        /// Search for the Constructor in the corresponding Type,
        /// no return value, the constructor is returned by foundElement
        /// </summary>
        /// <param name="cType"></param>
        /// <param name="minVisibility"></param>
        /// <param name="foundElement"></param>
        private static IList<IXMemberSymbol> SearchConstructor(IXTypeSymbol type, Modifiers minVisibility, XSharpSearchLocation location)
        {
            if (XSettings.EnableTypelookupLog)
                WriteOutputMessage($"--> SearchConstructorIn {type?.FullName}");
            var result = new List<IXMemberSymbol>();
            if (type != null)
            {
                //
                var xMethod = type.Members.Where(x => x.Kind == Kind.Constructor).FirstOrDefault();
                if (xMethod != null )
                {
                    if (!xMethod.IsVisible(minVisibility))
                    {
                        xMethod = null;
                    }
                }
                if (xMethod != null)
                {
                    result.Add(xMethod);
                }
            }
            return result;
        }

        internal static IXTypeSymbol GetConstantType(XSharpToken token, XFile file)
        {
            IXTypeSymbol result;
            var project = file.Project;
            var xusings = new string[] { "XSharp", "Vulcan" };
            var susings = new string[] { };
            switch (token.Type)
            {
                case XSharpLexer.FALSE_CONST:
                case XSharpLexer.TRUE_CONST:
                    result = project.FindSystemType("System.Boolean", susings);
                    break;
                case XSharpLexer.HEX_CONST:
                case XSharpLexer.BIN_CONST:
                case XSharpLexer.INT_CONST:
                    if (token.Text.ToUpper().EndsWith("L"))
                    {
                        result = project.FindSystemType("System.Int32", susings);
                    }
                    else if (token.Text.ToUpper().EndsWith("U"))
                    {
                        result = project.FindSystemType("System.UInt32", susings);
                    }
                    else
                    {
                        result = project.FindSystemType("System.Int32", susings);
                    }
                    break;
                case XSharpLexer.DATE_CONST:
                case XSharpLexer.NULL_DATE:
                    result = project.FindSystemType("__Date", xusings);
                    break;
                case XSharpLexer.DATETIME_CONST:
                    result = project.FindSystemType("System.DateTime", susings);
                    break;
                case XSharpLexer.REAL_CONST:
                    if (token.Text.ToUpper().EndsWith("M"))
                    {
                        result = project.FindSystemType("System.Decimal", susings);
                    }
                    else if (token.Text.ToUpper().EndsWith("S"))
                    {
                        result = project.FindSystemType("System.Single", susings);
                    }
                    else // if (token.Text.ToUpper().EndsWith("D"))
                    {
                        result = project.FindSystemType("System.Double", susings);
                    }
                    break;
                case XSharpLexer.SYMBOL_CONST:
                case XSharpLexer.NULL_SYMBOL:
                    result = project.FindSystemType("__Symbol", xusings);
                    break;
                case XSharpLexer.CHAR_CONST:
                    result = project.FindSystemType("System.Char", susings);
                    break;
                case XSharpLexer.STRING_CONST:
                case XSharpLexer.ESCAPED_STRING_CONST:
                case XSharpLexer.INTERPOLATED_STRING_CONST:
                case XSharpLexer.INCOMPLETE_STRING_CONST:
                case XSharpLexer.TEXT_STRING_CONST:
                case XSharpLexer.BRACKETED_STRING_CONST:
                case XSharpLexer.NULL_STRING:
                case XSharpLexer.MACRO:
                    result = project.FindSystemType("System.String", susings);
                    break;
                case XSharpLexer.BINARY_CONST:
                    result = project.FindSystemType("__Binary", xusings);
                    break;

                case XSharpLexer.NULL_ARRAY:
                    result = project.FindSystemType("__Array", xusings);
                    break;
                case XSharpLexer.NULL_CODEBLOCK:
                    result = project.FindSystemType("CodeBlock", xusings);
                    break;
                case XSharpLexer.NULL_PSZ:
                    result = project.FindSystemType("__Psz", xusings);
                    break;
                case XSharpLexer.NULL_PTR:
                    result = project.FindSystemType("System.IntPtr", susings);
                    break;
                case XSharpLexer.NULL_OBJECT:
                default:
                    result = project.FindSystemType("System.Object", susings);
                    break;
            }
            return result;
        }

        /// <summary>
        /// Search for a Property or a Field, in a CompletionType, based on the Visibility.
        /// A Completion can have a XSourceTypeSymbol (XSharp parsed type) or a SType (A System type or a Type found inside a library Reference)
        /// </summary>
        /// <param name="location"></param>
        /// <param name="cType">The CompletionType to look into</param>
        /// <param name="name">The Property we are searching</param>
        /// <param name="minVisibility"></param>
        /// <param name="foundElement"></param>
        /// <returns>The CompletionType of the Property (If found).
        /// If not found, the CompletionType.IsInitialized is false
        /// </returns>
        internal static IEnumerable<IXMemberSymbol> SearchPropertyOrField(XSharpSearchLocation location, IXTypeSymbol type, string name, Modifiers minVisibility)
        {
            return SearchMembers(location, type, name, minVisibility).Where((m) => m.Kind.IsProperty() || m.Kind == Kind.Field || m.Kind == Kind.Event || m.Kind == Kind.EnumMember);
        }

        private static IEnumerable<IXSymbol> SearchDelegateCall(XSharpSearchLocation location, string currentName, IXTypeSymbol currentType, Modifiers visibility)
        {
            var result = new List<IXSymbol>();
            if (XSettings.EnableTypelookupLog)
                WriteOutputMessage($"SearchDelegateCall in file {location.File.SourcePath} {currentName}");

            result.AddRange(FindIdentifier(location, currentName, currentType, visibility));
            if (result.Count > 0)
            {
                var first = result[0];
                var name = first.TypeName;
                var type = location.FindType(name);
                result.Clear();
                if (type != null && type.Kind is Kind.Delegate)
                {
                    var temp = type.Members.Where((m) => m.Name == "Invoke");
                    var member = temp.FirstOrDefault();
                    if (member != null)
                    {
                        member = member.WithName(type.ShortName);
                        //if (first is XSourceEntity src && src.IsGeneric )
                        //{
                        //    member = member.WithGenericArgs(src.GenericArgs);
                        //}
                        result.Add(member);
                    }
                }
            }
            return result;
        }

        private static IEnumerable<IXSymbol> SearchNestedTypes(XSharpSearchLocation location, string name)
        {
            var result = new List<IXSymbol>();
            var parent = SearchType(location, name).FirstOrDefault();
            if (parent != null)
            {
                result.AddRange(parent.Children);
            }
            return result;
        }


        private static IEnumerable<IXSymbol> SearchNamespaces(XSharpSearchLocation location, string name)
        {
            if (XSettings.EnableTypelookupLog)
                WriteOutputMessage($"SearchNamespaces in file {location.File.SourcePath} '{name}'");
            var result = new List<IXSymbol>();
            var namespaces = location.Project.AllNamespaces;
            foreach (var ns in namespaces)
            {
                if (ns.StartsWith(name, StringComparison.OrdinalIgnoreCase))
                {
                    result.Add(new XSymbol(name, Kind.Namespace, Modifiers.Public));
                    break;
                }
            }
            if (XSettings.EnableTypelookupLog)
                WriteOutputMessage($"SearchNamespaces in file {location.File.SourcePath} '{name}' returns {result.Count} items");
            return result;
        }

        private static IEnumerable<IXTypeSymbol> SearchType(XSharpSearchLocation location, string name)
        {
            if (XSettings.EnableTypelookupLog)
                WriteOutputMessage($"SearchType in file {location.File.SourcePath} '{name}'");
            var result = new List<IXTypeSymbol>();
            // translate out type names to system type names
            name = name.GetSystemTypeName(location.Project.ParseOptions.XSharpRuntime);

            var type = location.FindType(name);
            if (type != null)
                result.Add(type);
            if (XSettings.EnableTypelookupLog)
                WriteOutputMessage($"SearchType in file {location.File.SourcePath} '{name}' returns {result.Count} items");
            return result;
        }

        private static IXTypeSymbol EnsureComplete(IXTypeSymbol type, XSharpSearchLocation location)
        {
            if (type is XSourceTypeSymbol srcType && srcType.IsPartial)
            {

                var newtype = location.FindType(type.Name);
                if (newtype != null)
                    return newtype;
            }
            return type;
        }

        private static IEnumerable<IXMemberSymbol> SearchMembers(XSharpSearchLocation location, IXTypeSymbol type, string name, Modifiers minVisibility)
        {
            var result = new List<IXMemberSymbol>();
            if (type != null)
            {
                if (type is XSourceTypeSymbol)
                {
                    type = EnsureComplete(type, location);
                }
                if (XSettings.EnableTypelookupLog)
                    WriteOutputMessage($" SearchMembers {type?.FullName} , '{name}'");
                result.AddRange(type.GetMembers(name, true).Where((m) => m.IsVisible(minVisibility)));
                if (result.Count() == 0 && !string.IsNullOrEmpty(type.BaseTypeName))
                {
                    if (minVisibility == Modifiers.Private)
                        minVisibility = Modifiers.Protected;
                    IXTypeSymbol baseType;
                    if (type is XSourceTypeSymbol sourceType)
                    {
                        baseType = sourceType.File.FindType(type.BaseTypeName, type.Namespace);
                    }
                    else
                    {
                        baseType = location.FindType(type.BaseTypeName);
                    }
                    result.AddRange(SearchMembers(location, baseType, name, minVisibility));
                }
                if (XSettings.EnableTypelookupLog)
                    WriteOutputMessage($" SearchMembers {type?.FullName} , '{name}' returns {result.Count} items");

            }

            return result;
        }
        /// <summary>
        /// Search for a Method, in a CompletionType, based on the Visibility.
        /// </summary>
        /// <param name="cType">The CompletionType to look into</param>
        /// <param name="currentToken">The Method we are searching</param>
        /// <param name="minVisibility"></param>
        /// <returns>The CompletionType that the Method will return (If found).
        /// If not found, the CompletionType.IsInitialized is false
        /// and FoundElement is null
        /// </returns>
        internal static IEnumerable<IXMemberSymbol> SearchMethod(XSharpSearchLocation location, IXTypeSymbol type, string name, Modifiers minVisibility, bool staticOnly)
        {
            var result = new List<IXMemberSymbol>();
            if (type != null)
            {
                if (type is XSourceTypeSymbol )
                {
                    type = EnsureComplete(type, location);
                }

                if (XSettings.EnableTypelookupLog)
                    WriteOutputMessage($" SearchMethodTypeIn {type.FullName} , '{name}'");
                var tmp = type.GetMembers(name, true).Where(x => x.Kind.IsClassMethod(location.Dialect));
                foreach (var m in tmp)
                {
                    var add = true;
                    if (staticOnly && !m.IsStatic)
                        add = false;
                    if (add && (m.Visibility == Modifiers.Internal || m.Visibility == Modifiers.ProtectedInternal))
                    {
                        if (m is IXSourceSymbol source && source.File.Project == location.Project)
                            add = true;
                        else if (!m.IsVisible(minVisibility))
                            add = false;
                    }
                    if (add)
                    {
                        result.Add(m);
                    }
                }

                if (result.Count == 0 && type.FullName != "System.Object")
                {
                    var baseTypeName = type.BaseTypeName ?? "System.Object";
                    if (minVisibility == Modifiers.Private)
                        minVisibility = Modifiers.Protected;
                    IXTypeSymbol baseType;
                    if (type is XSourceTypeSymbol sourceType)
                    {
                        baseType = sourceType.File.FindType(baseTypeName, sourceType.Namespace);
                    }
                    else
                    {
                        baseType = location.FindType(baseTypeName);
                    }
                    result.AddRange(SearchMethod(location, baseType, name, minVisibility, staticOnly));
                }
                if (result.Count == 0 && type.Interfaces.Count > 0)
                {
                    foreach (var ifname in type.Interfaces)
                    {
                        IXTypeSymbol baseType;
                        if (type is XSourceTypeSymbol sourceType)
                        {
                            baseType = sourceType.File.FindType(ifname);
                        }
                        else
                        {
                            baseType = location.FindType(ifname);
                        }
                        result.AddRange(SearchMethod(location, baseType, name, minVisibility, staticOnly));
                    }
                }
                if (XSettings.EnableTypelookupLog)
                    WriteOutputMessage($" SearchMethodTypeIn {type.FullName} , '{name}' returns {result.Count} items");
            }
            return result;

        }

        /// <summary>
        /// Search for a static Method in a File
        /// </summary>
        /// <param name="xFile">The File to search in</param>
        /// <param name="currentToken">The Toekn to look after</param>
        /// <param name="foundElement">The Found Element</param>
        /// <returns>The CompletionType that contains the Element</returns>
        private static IEnumerable<IXMemberSymbol> SearchMethodStatic(XSharpSearchLocation location, string name)
        {
            var result = new List<IXMemberSymbol>();
            if (location.File == null || location.Project == null)
            {
                return result;
            }
            if (XSettings.EnableTypelookupLog)
                WriteOutputMessage($" SearchMethodStaticIn {location.File.SourcePath}, '{name}' ");
            //
            var emptyusing = new string[] { };
            foreach (string staticUsing in location.File.AllUsingStatics)
            {
                // Provide an Empty Using list, so we are looking for FullyQualified-name only
                var temp = location.Project.FindType(staticUsing, emptyusing);
                //
                if (temp!= null)
                {
                    var found = SearchMethod(location, temp, name, Modifiers.Public, true);
                    result.AddRange(found);
                }
                if (result.Count > 0)
                {
                    break;
                }
            }
            if (XSettings.EnableTypelookupLog)
                WriteOutputMessage($" SearchMethodStaticIn {location.File.SourcePath}, '{name}' returns {result.Count} items");
            return result;
        }

        private static IEnumerable<IXMemberSymbol> SearchGlobalField(XSharpSearchLocation location, string name)
        {
            var result = new List<IXMemberSymbol>();
            if (location.File == null || location.Project == null)
            {
                return result;
            }
            if (XSettings.EnableTypelookupLog)
                WriteOutputMessage($" SearchGlobalField {location.File.SourcePath},'{name}' ");
            if (location.Project.AssemblyReferences == null)
            {
                return result;
            }
            //
            var global = location.Project.FindGlobalOrDefine(name);
            if (global != null)
            {
                result.Add(global);
            }
            else
            {
                List<string> emptyUsings = new List<string>();
                var found = location.Project.FindGlobalMembersInAssemblyReferences(name).Where(m => m.Kind.IsField()).ToArray();
                result.AddRange(found);
            }
            if (XSettings.EnableTypelookupLog)
                WriteOutputMessage($" SearchGlobalField {location.File.SourcePath},'{name}' returns {result.Count} items");
            return result;
        }

        private static IEnumerable<IXMemberSymbol> SearchFunction(XSharpSearchLocation location, string name)
        {

            var result = new List<IXMemberSymbol>();
            if (location.File == null || location.Project == null)
            {
                return result;
            }
            if (XSettings.EnableTypelookupLog)
                WriteOutputMessage($" SearchFunction {location.File.SourcePath}, '{name}' ");
            IXMemberSymbol xMethod = location.File.Project.FindFunction(name);
            if (xMethod != null)
            {
                result.Add(xMethod);
            }
            else
            {
                var found = location.Project.FindGlobalMembersInAssemblyReferences(name).Where(m => m.Kind.IsMethod()).ToArray();
                result.AddRange(found);
            }
            if (XSettings.EnableTypelookupLog)
                WriteOutputMessage($" SearchFunction {location.File.SourcePath}, '{name}' returns {result.Count} items");
            return result;
        }

        static void WriteOutputMessage(string message)
        {
            if (XSettings.EnableTypelookupLog)
            {
                XSettings.DisplayOutputMessage("XSharp.Lookup :" + message);
            }
        }
    }


}
