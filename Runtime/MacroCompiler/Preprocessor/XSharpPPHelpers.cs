﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
using System;
using System.Collections.Generic;
using System.Diagnostics;
using XSharp.MacroCompiler.Syntax;

namespace XSharp.MacroCompiler.Preprocessor
{
    using XSharpLexer = TokenType;
    using XSharpToken = Token;
    

    enum PPUDCType : byte
    {
        None,
        Define = 1,                 // #define
        Command = 2,                 // #command 
        Translate = 3,               // #translate 
        XCommand = 4,                // #xcommand
        XTranslate = 5,              // #xtranslate
    }
    enum PPTokenType : byte
    {
        None = 0,                          //                      
        // Normal Token, part of UDC but with no special meaning
        Token = 1,                         //                      
        MatchRegular = 2,                  // <idMarker>           
        MatchList = 3,                     // <idMarker,...>       
        MatchRestricted = 4,               // <idMarker:word list> 
        MatchWild = 5,                     // <*idMarker*>         
        MatchExtended = 6,                 // <(idMarker)>         
        MatchOptional = 7,                 // [......]             
        // Xbase++ addition
        MatchSingle = 8,                   // <#idMarker>
        // X# addition
        MatchLike = 9,                     // <%idMarker%>          
        MatchWholeUDC = 10,                // all tokens in the UDC. Is always added as last match marker with the key UDC

        ResultRegular = 0x81,                // <idMarker>           
        ResultDumbStringify = 0x82,          // #<idMarker>          
        ResultNormalStringify = 0x83,        // <"idMarker">         
        ResultSmartStringify = 0x84,         // <(idMarker)>         
        ResultBlockify = 0x85,               // <{idMarker}>         
        ResultLogify = 0x86,                 // <.idMarker.>
        ResultNotEmpty = 0x87,               // <!idMarker!>
        ResultOptional = 0x88,               // [....]               

    }
    internal class PPErrorMessages : List<PPErrorMessage>
    {

    }

    internal class PPErrorMessage
    {
        internal XSharpToken Token { get; private set; }
        internal string Message { get; private set; }
        internal PPErrorMessage(XSharpToken token, string message)
        {
            Token = token;
            Message = message;
        }
    }


    [DebuggerDisplay("{Key, nq}: {Count}")]
    internal class PPRules : List<PPRule>
    {
        internal string Key { get; private set; }
        internal PPRules(string key) : base()
        {
            Key = key;
        }
    }
    /// <summary>
    /// This class is a dictionary of 'First tokens' in a PP Rule with the matching rules
    /// New rules are inserted at the top of the list, so they get preference over existing
    /// rules.
    /// </summary>
    internal class PPRuleDictionary
    {
        Dictionary<string, PPRules> _rules;
        internal PPRuleDictionary()
        {
            _rules = new Dictionary<string, PPRules>(StringComparer.OrdinalIgnoreCase);
        }

        internal int Count
        {
            get
            {
                int result = 0;
                foreach (var r in _rules)
                {
                    result += r.Value.Count;
                }
                return result;
            }
        }

        internal void Add(PPRule rule)
        {
            // find element that matches the first token and insert at the front of the list
            // so rules defined later override rules defined first
            if (rule.hasMultiKeys)
            {
                foreach (var key in rule.Keys)
                {
                    addrule(key, rule);
                }
            }
            else
            {
                string key = rule.LookupKey;
                addrule(key, rule);
            }
        }

        private void addrule(string key, PPRule rule)
        {
            PPRules list;
            if (_rules.ContainsKey(key))
            {
                list = _rules[key];
            }
            else
            {
                list = new PPRules(key);
                _rules.Add(key, list);
            }
            list.Insert(0, rule);
        }


        internal PPRule FindMatchingRule(IList<XSharpToken> tokens, out PPMatchRange[] matchInfo)
        {
            matchInfo = null;
            if (tokens?.Count > 0)
            {
                var firsttoken = tokens[0];
                var key = firsttoken.Text;
                while (key != null)
                {
                    if (_rules.ContainsKey(key))
                    {
                        // try to find the first rule in the list that matches our tokens
                        var rules = _rules[key];
                        foreach (var rule in rules)
                        {
                            if (rule.Matches(tokens, out matchInfo))
                            {
                                return rule;
                            }
                        }
                    }
                    if (key.Length <= 4)
                        return null;
                    key = key.Substring(0, 4);
                }

            }
            return null;
        }
    }

    /// <summary>
    /// This struct holds the start and end location of the tokens in the source 
    /// that match a match marker in a UDC
    /// It may also hold a list of MatchRanges, which is the case for List markers
    /// or Repeated markers
    /// </summary>
    [DebuggerDisplay("{GetDebuggerDisplay(), nq}")]
    internal struct PPMatchRange
    {
        #region Fields
        private IList<PPMatchRange> _children;
        #endregion
        #region Properties
        internal bool IsList { get { return _children != null; } }
        internal int Start { get; private set; }
        internal int Length { get; private set; }
        internal int MatchCount
        {
            get
            {
                if (Empty)
                    return 0;
                if (_children == null)
                    return 1;
                else
                    return _children.Count;

            }
        }
        internal int End
        {
            get
            {
                if (_children?.Count > 0)
                    return _children[_children.Count - 1].End;
                else
                    return Start + Length - 1;
            }
        }
        internal IList<PPMatchRange> Children { get { return _children; } }

        internal bool Empty
        {
            get { return !IsToken && Length == 0; }
        }
        internal bool IsToken { get; private set; }

        internal void SetPos(int start, int end)
        {
            IsToken = false;
            if (Empty)
            {
                Start = start;
                Length = end - start + 1;
                _children = null;
            }
            else
            {
                if (start == this.End + 1)
                {
                    Length += (end - start) + 1;
                }
                else
                {
                    if (_children == null)
                    {
                        _children = new List<PPMatchRange>();
                        _children.Add(Create(Start, End));
                    }
                    _children.Add(Create(start, end));
                    Length = end - Start + 1;
                }
            }
        }
        internal void SetToken(int pos)
        {
            if (Empty)
            {
                IsToken = true;
                Start = pos;
                Length = 1;
                _children = null;
            }
            else if (Start != pos) // prevent adding duplicate
            { 
                IsToken = true;
                if (Children == null)
                {
                    _children = new List<PPMatchRange>();
                    _children.Add(Token(Start));
                }
                _children.Add(Token(pos));
            }
        }
        internal void SetSkipped()
        {
            Start = -1;
            Length = 0;
            IsToken = false;
            _children = null;
        }

        #endregion
        #region Constructors
        private static PPMatchRange Token(int pos)
        {
            return new PPMatchRange() { IsToken = true, Start = pos, Length = 1, _children = null };
        }
        private static PPMatchRange Create(int start, int end)
        {
            return new PPMatchRange() { Start = start, Length = end - start + 1, _children = null };
        }
        #endregion
        internal string GetDebuggerDisplay()
        {
            if (IsToken)
            {
                if (_children != null)
                    return $"Token ({Children.Count}) {Start},{End}";
                else
                    return $"Token ({Start})";
            }
            if (Start == 0 && Length == 0)
                return "Empty";
            if (Start == -1 && Length == 0)
                return "Skipped Optional marker";
            if (_children != null)
                return $"List ({Children.Count}) {Start},{End}";
            else
                return $"{Start},{End}";
        }
    }
    /// <summary>
    /// This class is used to monitor recursion for #Translate and #command in the Preprocessor
    /// </summary>
    internal class PPUsedRules
    {
        class PPUsedRule
        {
            readonly PPRule _rule;
            readonly IList<XSharpToken> _tokens;
            internal PPUsedRule(PPRule rule, IList<XSharpToken> tokens)
            {
                _rule = rule;
                _tokens = tokens;
            }
            internal bool isDuplicate(PPRule rule, IList<XSharpToken> tokens)
            {
                if (_rule == rule && _tokens.Count == tokens.Count)
                {
                    for (int i = 0; i < tokens.Count; i++)
                    {
                        var t1 = tokens[i];
                        var t2 = _tokens[i];
                        if (t1.Text != t2.Text)
                        {
                            return false;
                        }
                    }
                    return true;
                }
                return false;
            }
        }

        readonly List<PPUsedRule> _list;
        readonly XSharpPreprocessor _pp;
        readonly int _maxDepth;
        internal PPUsedRules(XSharpPreprocessor pp, int maxDepth)
        {
            _list = new List<PPUsedRule>();
            _pp = pp;
            _maxDepth = maxDepth;
        }
        /// <summary>
        /// Check for recursion, and add the rule to the list of rules that have been used
        /// </summary>
        /// <param name="rule"></param>
        /// <param name="tokens"></param>
        /// <returns>True when the rule with the same tokens list is found in the list</returns>
        internal bool HasRecursion(PPRule rule, IList<XSharpToken> tokens)
        {
            // check to see if this is already there
            if (_list.Count == _maxDepth)
            {
                _pp.Error(tokens[0], ErrorCode.ERR_PreProcessorRecursiveRule, rule.Name);
                return true;
            }
            foreach (var item in _list)
            {
                if (item.isDuplicate(rule, tokens))
                {
                    _pp.Error(tokens[0], ErrorCode.ERR_PreProcessorRecursiveRule, rule.Name);
                    return true;
                }
            }
            _list.Add(new PPUsedRule(rule, tokens));
            return false;
        }
        internal int Count => _list.Count;
    }
}

