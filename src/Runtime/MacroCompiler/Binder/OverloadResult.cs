﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Reflection;

namespace XSharp.MacroCompiler
{
    using Syntax;

    internal class OverloadResult
    {
        internal int TotalCost = 0;
        internal int ExtraValid = 0;
        internal bool Valid = true;
        internal readonly MemberSymbol Symbol;
        internal readonly ParameterListSymbol Parameters;
        internal OverloadResult Equivalent = null;

        internal bool Exact { get { return Valid && TotalCost == 0; } }

        internal bool Unique { get { return Valid && ExtraValid == 0; } }

        internal readonly int FixedArgs;
        internal readonly int VarArgs;
        internal readonly int MissingArgs;
        internal ConversionSymbol[] Conversions;

        internal OverloadResult(MemberSymbol symbol, ParameterListSymbol paramList, int nFixedArgs, int nVarArgs, int nMissingArgs)
        {
            Symbol = symbol;
            Parameters = paramList;
            FixedArgs = nFixedArgs;
            VarArgs = nVarArgs;
            MissingArgs = nMissingArgs;
            Conversions = new ConversionSymbol[nFixedArgs+ nVarArgs + nMissingArgs];
        }

        internal void ArgConversion(int index, ConversionSymbol conv)
        {
            Conversions[index] = conv;
            TotalCost += conv.Cost;
            Valid &= conv.Exists;
        }

        internal static OverloadResult Create(MemberSymbol symbol, ParameterListSymbol paramList, int nFixedArgs, int nVarArgs, int nMissingArgs)
            { return new OverloadResult(symbol, paramList, nFixedArgs, nVarArgs, nMissingArgs); }

        bool HasMostDerivedArgs(OverloadResult other)
        {
            bool preferthis = false;
            for (int i = 0; i < Parameters.Parameters.Length; i++)
            {
                var pt = Binder.FindType(Parameters.Parameters[i].ParameterType);
                var po = Binder.FindType(other.Parameters.Parameters[i].ParameterType);
                if (pt.IsSubclassOf(po))
                    return true;
                // when the rest of the arguments do not make a difference
                // then prefer Int32 over UInt32
                if (pt == Compilation.Get(WellKnownTypes.System_Int32) &&
                    po == Compilation.Get(WellKnownTypes.System_UInt32) )
                { 
                    preferthis = true;
                }
                // when no preference then choose the one with a usual argument
                // over the one without usual.
                else if (pt == Compilation.Get(WellKnownTypes.XSharp___Usual) &&
                    po != Compilation.Get(WellKnownTypes.XSharp___Usual) &&
                    ! preferthis)
                { 
                    preferthis = true;
                }
            }
            return preferthis;
        }

        internal OverloadResult Better(OverloadResult other)
        {
            if (other?.Valid == true)
            {
                if (!Valid)
                    return other;
                else if (other.TotalCost < TotalCost)
                    return other;
                else if (other.TotalCost > TotalCost)
                    return this;
                else if (other.VarArgs < VarArgs)
                    return other;
                else if (other.VarArgs > VarArgs)
                    return this;
                else if (other.MissingArgs < MissingArgs)
                    return other;
                else if (other.MissingArgs > MissingArgs)
                    return this;
                else if (other.Parameters.Parameters.Length < Parameters.Parameters.Length)
                    return other;
                else if (other.Parameters.Parameters.Length > Parameters.Parameters.Length)
                    return this;
                else if (other.HasMostDerivedArgs(this))
                    return other;
                else if (HasMostDerivedArgs(other))
                    return this;
                else if (Symbol.DeclaringType.IsSubclassOf(other.Symbol.DeclaringType))
                    return this;
                else if (other.Symbol.DeclaringType.IsSubclassOf(Symbol.DeclaringType))
                    return other;
                else
                {
                    Equivalent = other;
                    ExtraValid += other.ExtraValid + 1;
                }
            }
            return this;
        }
    }
}
