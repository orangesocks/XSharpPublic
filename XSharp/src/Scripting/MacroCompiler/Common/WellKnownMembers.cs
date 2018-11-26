﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Reflection;
using System.Reflection.Emit;
using System.Diagnostics;

namespace XSharp.MacroCompiler
{
    internal enum WellKnownMembers
    {
        System_Decimal_Zero,
        System_String_Concat,
        System_String_Concat_Object,
        System_String_Equals,
        System_String_op_Equality,
        System_String_op_Inequality,
        System_Object_Equals,
    }

    public static partial class Compilation
    {
        static string[] MemberNames =
        {
            "System.Decimal.Zero",
            "System.String.Concat$(System.String,System.String)",
            "System.String.Concat$(System.Object,System.Object)",
            "System.String.Equals$(System.String,System.String)",
            "System.String.op_Equality$(System.String,System.String)",
            "System.String.op_Inequality$(System.String,System.String)",
            "System.Object.Equals$(System.Object,System.Object)",
        };

        static MemberSymbol[] WellKnownMemberSymbols;

        internal static void InitializeWellKnownMembers()
        {
            var memberSymbols = new MemberSymbol[MemberNames.Length];

            foreach (var m in (WellKnownMembers[])Enum.GetValues(typeof(WellKnownMembers)))
            {
                var names = MemberNames[(int)m];
                Debug.Assert(m.ToString().StartsWith(names.Replace('.', '_').Replace("`", "_T").Replace("$","").Split('|','(').First()));
                foreach (var proto in names.Split('|'))
                {
                    var name = proto.Replace("$", "").Split('(').First();
                    var s = Binder.LookupFullName(name);
                    if (s == null)
                        continue;
                    if (s is SymbolList)
                    {
                        var isStatic = proto.Contains('$');
                        var args = proto.Replace(")", "").Split('(').Last().Split(',');
                        var argTypes = args.Select(x => Binder.LookupFullName(x) as TypeSymbol).ToArray();
                        s = (s as SymbolList).Symbols.Find( x => (x as MethodSymbol)?.Method.GetParameters().Length == args.Length
                            && (x as MethodSymbol)?.Method.IsStatic == isStatic
                            && (x as MethodSymbol)?.Method.GetParameters().All( y => y.ParameterType == argTypes[y.Position].Type ) == true );
                        Debug.Assert(s is MethodSymbol);
                    }
                    Debug.Assert(s is MemberSymbol);
                    memberSymbols[(int)m] = s as MemberSymbol;
                    break;
                }
                Debug.Assert(memberSymbols[(int)m] != null);
            }

            Interlocked.CompareExchange(ref WellKnownMemberSymbols, memberSymbols, null);
        }

        internal static MemberSymbol Get(WellKnownMembers kind)
        {
            Debug.Assert(WellKnownMemberSymbols != null);
            return WellKnownMemberSymbols[(int)kind];
        }
    }
}