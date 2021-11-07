﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
using System.Collections.Generic;
using XSharp.MacroCompiler.Syntax;

namespace XSharp.MacroCompiler.Preprocessor
{
    using XSharpLexer = TokenType;
    using XSharpToken = Token;

    internal static class XSharpPPTokenExtensions
    {
        internal static void AddRange<T>(this IList<T> tokens, IList<T> toadd)
        {
            foreach (var token in toadd)
            {
                tokens.Add(token);
            }
        }
        internal static TokenType La(this XSharpToken[] tokens, int pos)
        {
            if (pos >= 0 && pos < tokens.Length)
                return tokens[pos].Type;
            return 0;
        }
        internal static bool IsName(this XSharpToken[] tokens, int pos)
        {
            if (pos >= 0 && pos < tokens.Length)
            {
                return tokens[pos].IsName();
            }
            return false;
        }

        internal static bool HasStopTokens(this PPTokenType value)
        {
            switch (value)
            {
                case PPTokenType.MatchList:
                case PPTokenType.MatchLike:
                case PPTokenType.MatchWild:
                    return true; ;
            }
            return false;
        }
       

        internal static void TrimLeadingSpaces(this IList<XSharpToken> tokens)
        {
            while (tokens.Count > 0 &&
                tokens[0].Channel == Channel.Hidden)
            {
                tokens.RemoveAt(0);
            }
        }
        internal static string AsTokenString( this IList<Token> tokens)
        {
            var sb = new System.Text.StringBuilder();
            int i = 0;
            foreach (var token in tokens)
            {
                if (token.Channel != Channel.Hidden)
                {
                    sb.Append(i);
                    sb.Append(" ");
                    sb.Append(token.ToString());
                    sb.AppendLine();
                    i++;
                }
            }
            return sb.ToString();
        }

        internal static string TrailingWs(this Token token)
        {
            if (token == null || token.Source == null)
                return "";
            var source = token.Source.SourceText;
            if (source == null)
                return "";
            var index = token.end;
            var result = "";
            while (index < source.Length)
            {
                var follow = source[index];
                if (follow == ' ' || follow == '\t')
                {
                    result += follow;
                }
                else
                {
                    break;
                }
                index += 1;
            }
            return result;
        }
        public static bool isWhiteSpace(char ch)
        {
            // this is surprisingly faster than the equivalent if statement
            switch (ch) {
                case '\u0009': case '\u000A': case '\u000B': case '\u000C': case '\u000D':
                case '\u0020': case '\u0085': case '\u00A0': case '\u1680': case '\u2000':
                case '\u2001': case '\u2002': case '\u2003': case '\u2004': case '\u2005':
                case '\u2006': case '\u2007': case '\u2008': case '\u2009': case '\u200A':
                case '\u2028': case '\u2029': case '\u202F': case '\u205F': case '\u3000':
                    return true;
                default:
                    return false;
            }
        }

        public static string TrimAllWithInplaceCharArray(this string str)
        {
            var src = str.ToCharArray();
            var len = str.Length;
            int idest = 0;
            bool instring = false;
            char stringEnd = ' ';
            bool lastIsWhiteSpace = false;
            for (int i = 0; i < len; i++)
            {
                bool lAdd = true;
                var ch = src[i];
                switch (ch)
                {
                    case '"':
                    case '\'':
                        if (instring && ch == stringEnd)
                        {
                           instring = false;
                            stringEnd = ' ';
                        }
                        else
                        {
                            stringEnd = ch;
                            instring = true;
                        }
                        break;
                    default:
                        if (!instring && lastIsWhiteSpace && isWhiteSpace(ch))
                        {
                            lAdd = false;
                        }
                        else
                            lAdd = true;
                        break;
                }
                if (lAdd)
                {
                    src[idest++] = ch;
                }
                lastIsWhiteSpace = isWhiteSpace(ch);
            }
            return new string(src, 0, idest);
        }

        internal static string AsString(this IList<XSharpToken> tokens)
        {
            string result = "";
            if (tokens != null)
            {
                foreach (var t in tokens)
                {
                    result = result + t.Text ;
                    if (!t.Text.EndsWith(" "))
                        result += " ";
                }

            }
            return TrimAllWithInplaceCharArray(result);
        }

        internal static IList<XSharpToken> CloneArray(this IList<XSharpToken> tokens)
        {
            var clone = new XSharpToken[tokens.Count];
            for (int i = 0; i < tokens.Count; i++)
            {
                clone[i] = new XSharpToken(tokens[i]);
            }
            return clone ;
        }
        internal static bool IsName(this XSharpToken token)
        {
            return token != null && (token.Type == XSharpLexer.ID  || token.IsKeyword());
        }
        internal static bool IsEOS(this XSharpToken token)
        {
            return token != null && (token.Type == XSharpLexer.NL || token.Type == XSharpLexer.EOS);
        }
        internal static string FileName(this XSharpToken token)
        {
            if (token == null)
                return "";
            return token?.Source?.SourceName;
        }

        internal static bool IsOptional(this PPTokenType type)
        {
            return type == PPTokenType.MatchOptional ||
                type == PPTokenType.ResultOptional ||
                type == PPTokenType.MatchWholeUDC;
        }

        internal static bool IsLiteral(this XSharpToken token)
        {
            if (token == null)
                return false;
            return token.Type > TokenType.FIRST_CONSTANT && token.Type < TokenType.LAST_CONSTANT;
        }

        public static bool IsOperator(this XSharpToken token)
        {
            return (token.Type > TokenType.FIRST_OPERATOR && token.Type < TokenType.LAST_OPERATOR);
        }
        public static bool IsComment(this XSharpToken token)
        {
            return (token.Type == TokenType.SL_COMMENT ||
                token.Type == TokenType.ML_COMMENT ||
                token.Type == TokenType.DOC_COMMENT);
        }

        public static bool IsKeyword(this XSharpToken token)
        {
            return (token.Type > TokenType.FIRST_KEYWORD && token.Type < TokenType.LAST_KEYWORD)
                || (token.Type > TokenType.FIRST_NULL && token.Type < TokenType.LAST_NULL);
        }
        public static bool IsIdentifier(this Token token)
        {
            return token.Type == TokenType.ID || token.SubType == TokenType.ID;
        }

        public static bool IsString(this Token token)
        {
            switch (token.Type)
            {
                case TokenType.CHAR_CONST:
                case TokenType.STRING_CONST:
                case TokenType.ESCAPED_STRING_CONST:
                case TokenType.INTERPOLATED_STRING_CONST:
                case TokenType.INCOMPLETE_STRING_CONST:
                case TokenType.TEXT_STRING_CONST:
// TODO nvk
// case TokenType.BRACKETED_STRING_CONST:
                    return true;
            }
            return false;
        }

        internal static bool NeedsLeft(this XSharpToken token)
        {
            if (token == null)
                return false;
            switch (token.Type)
            {
                case XSharpLexer.ASSIGN_ADD:
                case XSharpLexer.ASSIGN_BITAND:
                case XSharpLexer.ASSIGN_BITOR:
                case XSharpLexer.ASSIGN_DIV:
                case XSharpLexer.ASSIGN_EXP:
                case XSharpLexer.ASSIGN_LSHIFT:
                case XSharpLexer.ASSIGN_MOD:
                case XSharpLexer.ASSIGN_MUL:
                case XSharpLexer.ASSIGN_OP:
                case XSharpLexer.ASSIGN_RSHIFT:
                case XSharpLexer.ASSIGN_SUB:
                case XSharpLexer.ASSIGN_XOR:
                    return true;
                case XSharpLexer.COLON:
                case XSharpLexer.DOT:
                    return true;
            }
            if (token.IsPrefix())
                return false;
            return token.IsBinary();
        }
        internal static bool NeedsRight(this XSharpToken token)
        {
            return token.IsBinary() || token.IsPrefix();
        }
        internal static bool IsBinary(this XSharpToken token)
        {
            if (token == null)
                return false;
            // see xsharp.g4 binaryExpression
            // tokens in same order 
            switch (token.Type)
            {
                case XSharpLexer.EXP:
                case XSharpLexer.MULT:
                case XSharpLexer.DIV:
                case XSharpLexer.MOD:
                case XSharpLexer.PLUS:
                case XSharpLexer.MINUS:
                case XSharpLexer.LSHIFT:
                case XSharpLexer.RSHIFT:
                case XSharpLexer.LT:
                case XSharpLexer.LTE:
                case XSharpLexer.GT:
                case XSharpLexer.GTE:
                case XSharpLexer.EQ:
                case XSharpLexer.EEQ:
                case XSharpLexer.SUBSTR:
                case XSharpLexer.NEQ:
                case XSharpLexer.NEQ2:
                case XSharpLexer.AMP:
                case XSharpLexer.TILDE:
                case XSharpLexer.PIPE:
                case XSharpLexer.AND:
                case XSharpLexer.OR:
                case XSharpLexer.LOGIC_AND:
                case XSharpLexer.LOGIC_XOR:
                case XSharpLexer.LOGIC_OR:
                //case XSharpLexer.FOX_AND:
                //case XSharpLexer.FOX_OR:
                //case XSharpLexer.FOX_XOR:
                    return true;
                case XSharpLexer.COLON:
                case XSharpLexer.DOT:
                case XSharpLexer.ALIAS:
                    return true;
            }
            return false;
        }
        internal static bool IsPrefix(this XSharpToken token)
        {
            if (token == null)
                return false;
            switch (token.Type)
            {
                case XSharpLexer.PLUS:              // see xsharp.g4 prefixExpression
                case XSharpLexer.MINUS:
                case XSharpLexer.TILDE:
                case XSharpLexer.ADDROF:
                case XSharpLexer.DEC:
                case XSharpLexer.INC:
                case XSharpLexer.LOGIC_NOT:
                //case XSharpLexer.FOX_NOT:
                case XSharpLexer.NOT:
                    return true;
            }
            return false;
        }

        internal static bool IsPostFix(this XSharpToken token)
        {
            if (token == null)
                return false;
            switch (token.Type)
            {
                case XSharpLexer.DEC:           // see xsharp.g4 postfixExpression
                case XSharpLexer.INC:
                    return true;
            }
            return false;
        }
        internal static bool IsWildCard(this XSharpToken token)
        {
            switch (token.Type)
            {
                case XSharpLexer.QMARK:
                case XSharpLexer.MULT:
                    return true;
            }
            return false;
        }
        internal static bool IsOpen(this XSharpToken token, ref TokenType closeType)
        {
            if (token == null)
                return false;
            switch (token.Type)
            {
                case XSharpLexer.LBRKT:
                    closeType = XSharpLexer.RBRKT;
                    return true;
                case XSharpLexer.LCURLY:
                    closeType = XSharpLexer.RCURLY;
                    return true;
                case XSharpLexer.LPAREN:
                    closeType = XSharpLexer.RPAREN;
                    return true;
            }
            closeType = 0;
            return false;
        }
        internal static bool IsClose(this XSharpToken token)
        {
            if (token == null)
                return false;
            switch (token.Type)
            {
                case XSharpLexer.RBRKT:
                case XSharpLexer.RCURLY:
                case XSharpLexer.RPAREN:
                    return true;
            }
            return false;
        }

        internal static bool IsPrimary(this XSharpToken token)
        {
            if (token.IsName())
                return true;
            if (token.IsLiteral())
                return true;
            return false;
        }
        internal static bool IsPrimaryOrPrefix(this XSharpToken token)
        {
            if (token.IsPrimary())
                return true;
            if (token.IsPrefix())
                return true;
            return false;

        }



        internal static bool CanJoin(this XSharpToken token, XSharpToken nextToken)
        {
            if (token == null )
            {
                return nextToken.IsName() || nextToken.IsLiteral() || nextToken.IsPrefix() ;
            }
            if (token.IsPrefix() || token.IsBinary())          // we allow .and. .not. and even .not. .not.
                return (nextToken.IsPrimaryOrPrefix());
            if (nextToken.IsBinary() || nextToken.NeedsLeft() || nextToken.IsPostFix())
                return (token.IsPrimary() ||token.IsClose());

            return false;
        }
        internal static bool IsNeutral(this XSharpToken token)
        {
            if (token == null)
                return false;
            switch (token.Type)
            {
                case XSharpLexer.DEC:
                case XSharpLexer.INC:
                    return true;
            }
            return false;
        }

        internal static bool IsEndOfCommand(this XSharpToken token)
        {
            if (token == null)
                return false;
            return token.Type == XSharpLexer.SEMI;
        }
        internal static bool IsEndOfLine(this XSharpToken token)
        {
            if (token == null)
                return false;
            return token.Type == XSharpLexer.NL;
        }
    }

}

