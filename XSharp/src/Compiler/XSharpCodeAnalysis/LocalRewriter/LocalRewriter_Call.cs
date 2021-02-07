﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//

using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Diagnostics;
using LanguageService.CodeAnalysis.XSharp.SyntaxParser;
using Microsoft.CodeAnalysis.CSharp.Symbols;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.CodeAnalysis.PooledObjects;
using Roslyn.Utilities;

namespace Microsoft.CodeAnalysis.CSharp
{
    internal partial class LocalRewriter
    {
        private BoundExpression XsAdjustBoundCall(BoundExpression expression)
        {
            if (expression.Syntax is null || expression.SyntaxTree is null )
                return expression;
            var root = expression.SyntaxTree.GetRoot() as CompilationUnitSyntax;
            if (root is null)
                return expression;
            // check if MethodSymbol has the NeedAccessToLocals attribute combined with /fox2
            // if that is the case then the node is registered  in the FunctionsThatNeedAccessToLocals dictionary
            if (root.GetLocalsForFunction(expression.Syntax.CsNode, out var localsymbols))
            {
                // write prelude and after code
                // prelude code should register the locals
                /*
                 assume the following code:

                 LOCAL a := "Robert" AS STRING
                 LOCAL b := 42 AS LONG
                 ? Type(b")
                 RETURN
                 // This code gets generated by the compiler to allow the Type() function to access the locals

                 __LocalPut("a", a)
                 __LocalPut("b", b)
                 var temp := Type(b")
                 IF __LocalsUpdated()
                    a := __LocalGet("a")
                    b := __LocalGet("b")
                 ENDIF
                 __LocalsClear()
                 */
                var rtType = _compilation.RuntimeFunctionsType();
                var exprs = ImmutableArray.CreateBuilder<BoundExpression>();
                var block = ImmutableArray.CreateBuilder<BoundExpression>();
                var usual = _compilation.UsualType();
                foreach (var localsym in localsymbols)
                {
                    var name = localsym.Name;
                    if (name.IndexOf("$") >= 0)
                        continue;
                    var localvar = _factory.Local(localsym);
                    var localname = _factory.Literal(name);

                    // __LocalPut("name", (USUAL) localvar)
                    var value = MakeConversionNode(localvar, usual, false);
                    var mcall = _factory.StaticCall(rtType, ReservedNames.LocalPut, localname, value);
                    exprs.Add(mcall);

                    // create assignment expression for inside the block that is executed when locals are updated
                    // LocalVar := (CorrectType) __LocalGet("name")
                    mcall = _factory.StaticCall(rtType, ReservedNames.LocalGet, localname);
                    value = MakeConversionNode(mcall, localsym.Type, false);
                    var ass = _factory.AssignmentExpression(localvar, value);
                    block.Add(ass);
                }
                // we need an array of the local symbols for the sequence
                var locals = ImmutableArray.CreateBuilder<LocalSymbol>();
                var tempSym = _factory.SynthesizedLocal(expression.Type ?? _compilation.GetSpecialType(SpecialType.System_Object));
                locals.Add(tempSym);
                var tempLocal = _factory.Local(tempSym);

                // var temp := <original expression>
                var callorig = _factory.AssignmentExpression(tempLocal, expression);
                exprs.Add(callorig);

                // create condition  __LocalsUpdated()
                var cond = _factory.StaticCall(rtType, ReservedNames.LocalsUpdated);
                var t = _factory.Literal(true);
                var f = _factory.Literal(false);

                // create a sequence with the assignment expressions, return true (because the conditional expression needs a value)
                var assignmentsequence = _factory.Sequence(block.ToArray(), t);

                // iif ( __localupdated(), <assignmentsequence>, false)
                var condexpr = _factory.Conditional(cond, assignmentsequence, f, _compilation.GetSpecialType(SpecialType.System_Boolean));
                exprs.Add(condexpr);

                // __LocalsClear()
                var clear = _factory.StaticCall(rtType, ReservedNames.LocalsClear);
                exprs.Add(VisitExpression(clear));
                // create a sequence that returns the temp var.
                expression = _factory.Sequence(locals.ToImmutable(), exprs.ToImmutable(), tempLocal);

            }
            return expression;
        }


    }
}
