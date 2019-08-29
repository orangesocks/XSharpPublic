﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Reflection;

namespace XSharp.MacroCompiler
{
    using Syntax;

    internal partial class Binder
    {
        internal UnaryOperatorSymbol BindUnaryLogicOperation(UnaryExpr expr, UnaryOperatorKind kind)
        {
            return BindUnaryOperation(expr, kind, Options.Binding | BindOptions.Logic);
        }

        internal UnaryOperatorSymbol BindUnaryOperation(UnaryExpr expr, UnaryOperatorKind kind)
        {
            return BindUnaryOperation(expr, kind, Options.Binding);
        }

        internal static UnaryOperatorSymbol BindUnaryOperation(UnaryExpr expr, UnaryOperatorKind kind, BindOptions options)
        {
            if (options.HasFlag(BindOptions.Logic))
            {
                Convert(ref expr.Expr, Compilation.Get(NativeType.Boolean), options);
            }

            var res = UnaryOperation(kind, ref expr.Expr, options);

            if (res != null)
                return res;

            throw UnaryOperationError(expr, kind, options);
        }

        internal static UnaryOperatorSymbol UnaryOperation(UnaryOperatorKind kind, ref Expr expr, BindOptions options)
        {
            var sym = UnaryOperatorEasyOut.ClassifyOperation(kind, expr.Datatype);
            if (sym != null)
            {
                Convert(ref expr, sym.Type, options);
                return sym;
            }

            // User-defined operators
            {
                var op = UserDefinedUnaryOperator(kind, ref expr, options);
                if (op != null)
                    return op;
            }

            // Dynamic with usual
            if (options.HasFlag(BindOptions.AllowDynamic))
            {
                var op = DynamicUnaryOperator(kind, ref expr, options);
                if (op != null)
                    return op;
            }

            // Enum operations
            {
                var op = EnumUnaryOperator(kind, ref expr, options);
                if (op != null)
                    return op;
            }

            return null;
        }

        internal static UnaryOperatorSymbol UserDefinedUnaryOperator(UnaryOperatorKind kind, ref Expr expr, BindOptions options)
        {
            var name = UnaryOperatorSymbol.OperatorName(kind);
            if (name != null)
            {
                MethodSymbol mop = null;
                ConversionSymbol conv = null;
                ResolveUserDefinedUnaryOperator(expr, expr.Datatype.Lookup(name), ref mop, ref conv, options);
                if (mop != null)
                {
                    var op = UnaryOperatorSymbol.Create(kind, mop, conv);
                    ApplyUnaryOperator(ref expr, op);
                    return op;
                }
            }
            return null;
        }

        internal static void ResolveUserDefinedUnaryOperator(Expr expr, Symbol ops,
            ref MethodSymbol op, ref ConversionSymbol conv, BindOptions options)
        {
            if (ops != null)
                ResolveUnaryOperator(expr, ops, ref op, ref conv, options);
        }

        internal static void ResolveUnaryOperator(Expr expr, Symbol ops,
            ref MethodSymbol op, ref ConversionSymbol conv, BindOptions options)
        {
            if (ops is MethodSymbol)
            {
                if (CheckUnaryOperator(expr, (MethodSymbol)ops, ref conv, options))
                    op = (MethodSymbol)ops;
            }
            else if ((ops as SymbolList)?.SymbolTypes.HasFlag(MemberTypes.Method) == true)
            {
                foreach (MethodSymbol m in ((SymbolList)ops).Symbols)
                    if (m != null)
                    {
                        if (CheckUnaryOperator(expr, m, ref conv, options))
                            op = m;
                    }
            }
        }

        internal static bool CheckUnaryOperator(Expr expr, MethodSymbol m, ref ConversionSymbol conv, BindOptions options, bool needSpecialName = true)
        {
            var method = m.Method;
            if (!m.Method.IsStatic || (needSpecialName && !m.Method.IsSpecialName))
                return false;
            var parameters = method.GetParameters();
            if (parameters.Length != 1)
                return false;
            var type = FindType(parameters[0].ParameterType);
            if (TypesMatch(type, expr.Datatype))
            {
                conv = ConversionSymbol.Create(ConversionKind.Identity);
                return true;
            }
            var _conv = Conversion(expr, type, options);

            if (_conv.IsImplicit)
            {
                if (conv == null)
                {
                    conv = _conv;
                    return true;
                }
                var cost = conv?.Cost;
                var _cost = _conv.Cost;
                if (_cost < cost)
                {
                    conv = _conv;
                    return true;
                }
            }
            return false;
        }

        static void ApplyUnaryOperator(ref Expr expr, UnaryOperatorSymbol op)
        {
            if (op is UnaryOperatorSymbolWithMethod)
            {
                var mop = (UnaryOperatorSymbolWithMethod)op;
                var parameters = mop.Method.Method.GetParameters();
                var conv = mop.Conv;
                if (conv != null && conv.Kind != ConversionKind.Identity)
                    Convert(ref expr, FindType(parameters[0].ParameterType), conv);
            }
        }

        static UnaryOperatorSymbol DynamicUnaryOperator(UnaryOperatorKind kind, ref Expr expr, BindOptions options)
        {
            var e = expr;

            if (e.Datatype.NativeType == NativeType.Object)
                Convert(ref e, Compilation.Get(NativeType.Usual), options);

            var op = UserDefinedUnaryOperator(kind, ref e, options);

            if (op != null)
            {
                expr = e;
            }

            return op;
        }

        static UnaryOperatorSymbol EnumUnaryOperator(UnaryOperatorKind kind, ref Expr expr, BindOptions options)
        {
            var e = expr;
            var dt = expr.Datatype;

            if (dt.IsEnum)
            {
                Convert(ref e, dt.EnumUnderlyingType, options);
                var op = UnaryOperation(kind, ref e, options);
                if (op != null)
                {
                    expr = e;
                    return op.AsEnum(dt) ?? op;
                }
            }

            return null;
        }
    }
}
