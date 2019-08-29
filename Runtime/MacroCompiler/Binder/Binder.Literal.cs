﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Reflection;

namespace XSharp.MacroCompiler
{
    using Syntax;

    internal partial class Binder
    {
        internal Constant CreateLiteral(LiteralExpr expr, string Value)
        {
            switch (expr.Kind)
            {
                case TokenType.TRUE_CONST:
                    return Constant.Create(true);
                case TokenType.FALSE_CONST:
                    return Constant.Create(false);
                case TokenType.CHAR_CONST:
                    return Constant.Create(Literals.CharValue(Value));
                case TokenType.STRING_CONST:
                    return Constant.Create(Literals.StringValue(Value));
                case TokenType.ESCAPED_STRING_CONST:
                    return Constant.Create(Literals.EscapedStringValue(Value));
                case TokenType.INTERPOLATED_STRING_CONST:
                    return Constant.Create(Literals.StringValue(Value));
                case TokenType.SYMBOL_CONST:
                    return Constant.CreateSymbol(Value.StartsWith("#") ? Value.Substring(1).ToUpperInvariant() : Value.ToUpperInvariant());
                case TokenType.HEX_CONST:
                    switch (Value.Last())
                    {
                        case 'U':
                        case 'u':
                            if (Value.Length > 8 + 3)
                                return Constant.Create(unchecked((ulong)Literals.HexValue(Value.Substring(2))));
                            else
                                return Constant.Create(unchecked((uint)Literals.HexValue(Value.Substring(2))));
                        case 'L':
                        case 'l':
                            if (Value.Length > 8 + 3)
                                return Constant.Create(Literals.HexValue(Value.Substring(2)));
                            else
                                return Constant.Create(unchecked((int)Literals.HexValue(Value.Substring(2))));
                        default:
                            {
                                long l = Literals.HexValue(Value.Substring(2));
                                if (l < 0)
                                    return Constant.Create(unchecked((ulong)l));
                                else if (l > uint.MaxValue)
                                    return Constant.Create(l);
                                else if (l > int.MaxValue)
                                    return Constant.Create(unchecked((uint)l));
                                else
                                    return Constant.Create(unchecked((int)l));
                            }
                    }
                case TokenType.BIN_CONST:
                    switch (Value.Last())
                    {
                        case 'U':
                        case 'u':
                            if (Value.Length > 32 + 3)
                                return Constant.Create(unchecked((ulong)Literals.BinValue(Value.Substring(2))));
                            else
                                return Constant.Create(unchecked((uint)Literals.BinValue(Value.Substring(2))));
                        case 'L':
                        case 'l':
                            if (Value.Length > 32 + 3)
                                return Constant.Create(Literals.BinValue(Value.Substring(2)));
                            else
                                return Constant.Create(unchecked((int)Literals.BinValue(Value.Substring(2))));
                        default:
                            {
                                long l = Literals.BinValue(Value.Substring(2));
                                if (l < 0)
                                    return Constant.Create(unchecked((ulong)l));
                                else if (l > uint.MaxValue)
                                    return Constant.Create(l);
                                else if (l > int.MaxValue)
                                    return Constant.Create(unchecked((uint)l));
                                else
                                    return Constant.Create(unchecked((int)l));
                            }
                    }
                case TokenType.REAL_CONST:
                    switch (Value.Last())
                    {
                        case 'M':
                        case 'm':
                            try
                            {
                                return Constant.Create(decimal.Parse(Value.Substring(0, Value.Length - 1), System.Globalization.CultureInfo.InvariantCulture));
                            }
                            catch (OverflowException)
                            {
                                throw expr.Error(ErrorCode.LiteralFloatOverflow);
                            }
                        case 'S':
                        case 's':
                            try
                            {
                                return Constant.Create(float.Parse(Value.Substring(0, Value.Length - 1), System.Globalization.CultureInfo.InvariantCulture));
                            }
                            catch (OverflowException)
                            {
                                throw expr.Error(ErrorCode.LiteralFloatOverflow);
                            }
                        case 'D':
                        case 'd':
                            try
                            {
                                return Constant.Create(double.Parse(Value.Substring(0, Value.Length - 1), System.Globalization.CultureInfo.InvariantCulture));
                            }
                            catch (OverflowException)
                            {
                                throw expr.Error(ErrorCode.LiteralFloatOverflow);
                            }
                        default:
                            try
                            {
                                if (Options.VOFloatConstants)
                                {
                                    var args = Value.Split('.');
                                    if (args.Length == 2)
                                    {
                                        int dec = 0;
                                        while (args[1].Length > dec && Char.IsDigit(args[1][dec])) dec++;
                                        return Constant.Create(double.Parse(Value, System.Globalization.CultureInfo.InvariantCulture), 0, dec);
                                    }
                                    return Constant.Create(double.Parse(Value, System.Globalization.CultureInfo.InvariantCulture));
                                }
                                else
                                    return Constant.Create(double.Parse(Value, System.Globalization.CultureInfo.InvariantCulture));
                            }
                            catch (OverflowException)
                            {
                                throw expr.Error(ErrorCode.LiteralFloatOverflow);
                            }
                    }
                case TokenType.INT_CONST:
                    switch (Value.Last())
                    {
                        case 'U':
                        case 'u':
                            try
                            {
                                ulong ul = ulong.Parse(Value.Substring(0, Value.Length - 1), System.Globalization.CultureInfo.InvariantCulture);
                                if (ul > uint.MaxValue)
                                    return Constant.Create(ul);
                                else
                                    return Constant.Create(unchecked((uint)ul));
                            }
                            catch (OverflowException)
                            {
                                throw expr.Error(ErrorCode.LiteralIntegerOverflow);
                            }
                        case 'L':
                        case 'l':
                            try
                            {
                                long l = long.Parse(Value.Substring(0, Value.Length - 1), System.Globalization.CultureInfo.InvariantCulture);
                                if (l > int.MaxValue)
                                    return Constant.Create(l);
                                else
                                    return Constant.Create(unchecked((int)l));
                            }
                            catch (OverflowException)
                            {
                                throw expr.Error(ErrorCode.LiteralIntegerOverflow);
                            }
                        default:
                            try
                            {
                                ulong un = 0;
                                long n = 0;
                                if (Value.First() != '-')
                                {
                                    un = ulong.Parse(Value, System.Globalization.CultureInfo.InvariantCulture);
                                    if (un <= long.MaxValue)
                                        n = unchecked((long)un);
                                }
                                else
                                {
                                    n = long.Parse(Value, System.Globalization.CultureInfo.InvariantCulture);
                                }
                                if (un > long.MaxValue)
                                    return Constant.Create(un);
                                else if (n > uint.MaxValue)
                                    return Constant.Create(n);
                                else if (n > int.MaxValue)
                                    return Constant.Create(unchecked((uint)n));
                                else
                                    return Constant.Create(unchecked((int)n));
                            }
                            catch (OverflowException)
                            {
                                throw expr.Error(ErrorCode.LiteralIntegerOverflow);
                            }
                    }
                case TokenType.NULL:
                    return Constant.Create((object)null);
                case TokenType.NIL:
                    return Constant.CreateDefault(Compilation.Get(NativeType.Usual));
                case TokenType.DATE_CONST:
                    {
                        var args = Value.Split('.');
                        if (args.Length == 3)
                        {
                            int year, month, day;
                            if (Int32.TryParse(args[0], out year) &&
                                Int32.TryParse(args[1], out month) &&
                                Int32.TryParse(args[2], out day))
                            {
                                if (Options.VODateConstants)
                                    return Constant.CreateVODate(year, month, day);
                                else
                                    return Constant.Create(new DateTime(year, month, day));
                            }
                        }
                        throw new InternalError();
                    }
                case TokenType.NULL_ARRAY:
                    return Constant.CreateDefault(Compilation.Get(NativeType.Array));
                case TokenType.NULL_CODEBLOCK:
                    return Constant.CreateDefault(Compilation.Get(NativeType.Codeblock));
                case TokenType.NULL_DATE:
                    return Constant.CreateDefault(Compilation.Get(NativeType.VODate));
                case TokenType.NULL_OBJECT:
                    return Constant.CreateDefault(Compilation.Get(NativeType.Object));
                case TokenType.NULL_PSZ:
                    return Constant.CreateDefault(Compilation.Get(NativeType.Psz));
                case TokenType.NULL_PTR:
                    return Constant.CreateDefault(Compilation.Get(NativeType.Ptr));
                case TokenType.NULL_STRING:
                    return Constant.CreateDefault(Compilation.Get(NativeType.String));
                case TokenType.NULL_SYMBOL:
                    return Constant.CreateDefault(Compilation.Get(NativeType.Symbol));
                default:
                    throw new InternalError();
            }
        }
    }
}
