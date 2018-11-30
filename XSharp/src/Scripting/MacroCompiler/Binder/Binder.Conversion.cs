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
        internal static void Convert(ref Expr e, TypeSymbol type, ConversionSymbol conv)
        {
            switch (conv.Kind)
            {
                case ConversionKind.Identity:
                    break;
                case ConversionKind.ConstantReduction:
                    e = LiteralExpr.Bound(((ConversionSymbolToConstant)conv).Constant);
                    break;
                default:
                    e = TypeConversion.Bound(e, type, conv);
                    break;
            }
        }

        internal static void Convert(ref Expr e, TypeSymbol type)
        {
            Convert(ref e, type, Conversion(e, type));
        }

        internal static ConversionSymbol Conversion(Expr expr, TypeSymbol type, bool allowDynamic = true)
        {
            var conversion = ConversionEasyOut.ClassifyConversion(expr.Datatype, type);

            if (conversion != ConversionKind.NoConversion)
                return ConversionSymbol.Create(conversion);

            if (TypesMatch(expr.Datatype, type))
                return ConversionSymbol.Create(ConversionKind.Identity);

            MethodSymbol converter = null;

            ResolveUserDefinedConversion(expr, type, expr.Datatype.Lookup(OperatorNames.Implicit), type.Lookup(OperatorNames.Implicit), ref converter);

            if (converter != null)
                return ConversionSymbol.Create(ConversionKind.ImplicitUserDefined, converter);

            ResolveUserDefinedConversion(expr, type, expr.Datatype.Lookup(OperatorNames.Explicit), type.Lookup(OperatorNames.Explicit), ref converter);

            if (converter != null)
                return ConversionSymbol.Create(ConversionKind.ExplicitUserDefined, converter);

            conversion = ResolveUsualConversion(expr, type);
            if (conversion != ConversionKind.NoConversion)
                return ConversionSymbol.Create(conversion);

            if (type.IsByRef != expr.Datatype.IsByRef)
            {
                var conv = ResolveByRefConversion(expr, type);
                if (conv != null)
                    return conv;
            }

            if (type.NativeType == NativeType.Object)
            {
                if (expr.Datatype.Type.IsValueType)
                    return ConversionSymbol.Create(ConversionKind.Boxing);
                else
                    return ConversionSymbol.Create(ConversionKind.ImplicitReference);
            }

            if (allowDynamic)
            {
                var conv = ResolveDynamicConversion(expr, type);
                if (conv != null)
                    return conv;
            }

            return ConversionSymbol.Create(ConversionKind.NoConversion);
        }

        internal static void ResolveUserDefinedConversion(Expr expr, TypeSymbol type, Symbol src_conv, Symbol dest_conv, ref MethodSymbol converter)
        {
            if (src_conv != null)
                ResolveConversionMethod(expr, type, src_conv, ref converter);
            if (dest_conv != null)
                ResolveConversionMethod(expr, type, dest_conv, ref converter);
        }

        internal static void ResolveConversionMethod(Expr expr, TypeSymbol type, Symbol conv, ref MethodSymbol converter)
        {
            if (conv is MethodSymbol)
            {
                if (CheckConversionMethod(expr, type, (MethodSymbol)conv))
                    converter = (MethodSymbol)conv;
            }
            else if ((conv as SymbolList)?.SymbolTypes.HasFlag(MemberTypes.Method) == true)
            {
                foreach (MethodSymbol m in ((SymbolList)conv).Symbols)
                    if (m != null)
                {
                        if (CheckConversionMethod(expr, type, m))
                            converter = m;
                    }
            }
        }

        static bool CheckConversionMethod(Expr expr, TypeSymbol type, MethodSymbol m)
        {
            var method = m.Method;
            if (!m.Method.IsStatic || !m.Method.IsSpecialName)
                return false;
            if (!TypesMatch(FindType(m.Method.ReturnType), type))
                return false;
            var parameters = method.GetParameters();
            if (parameters.Length != 1)
                return false;
            if (!TypesMatch(FindType(parameters[0].ParameterType), expr.Datatype))
                return false;
            return true;
        }

        internal static ConversionKind ResolveUsualConversion(Expr expr, TypeSymbol type)
        {
            if (expr.Datatype.NativeType == NativeType.Usual && type.NativeType == NativeType.Object)
                return ConversionKind.Boxing;
            return ConversionKind.NoConversion;
        }

        internal static ConversionSymbol ResolveByRefConversion(Expr expr, TypeSymbol type)
        {
            if (type.IsByRef && TypesMatch(expr.Datatype, type.ElementType))
            {
                return ConversionSymbol.Create(ConversionKind.Refer);
            }
            else
            {
                var inner = ConversionSymbol.Create(ConversionKind.Deref);
                var outer = Conversion(TypeConversion.Bound(expr, expr.Datatype.ElementType, inner), type);
                if (outer.Kind != ConversionKind.NoConversion)
                {
                    return ConversionSymbol.Create(outer, inner);
                }
            }
            return null;
        }
        internal static ConversionSymbol ResolveDynamicConversion(Expr expr, TypeSymbol type)
        {
            if (expr.Datatype.NativeType == NativeType.Object)
            {
                var inner = Conversion(expr, Compilation.Get(NativeType.Usual));
                var outer = Conversion(TypeConversion.Bound(expr, Compilation.Get(NativeType.Usual), inner), type);
                if (outer.Kind != ConversionKind.NoConversion)
                {
                    return ConversionSymbol.Create(outer, inner);
                }
            }
            return null;
        }
    }
}