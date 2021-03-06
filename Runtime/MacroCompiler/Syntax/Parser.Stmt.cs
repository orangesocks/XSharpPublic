﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Diagnostics;
using System.Text;
using System.Threading.Tasks;

namespace XSharp.MacroCompiler
{
    using Syntax;
    using static Compilation;

    partial class Parser
    {
        internal StmtBlock ParseStatementBlock(bool returnsValue = false)
        {
            var t = Lt();
            List<Stmt> l = new List<Stmt>();
            while (ParseStatement() is Stmt s)
                l.Add(s);
            if (returnsValue && l.Count > 0)
            {
                var i = l.Count - 1;
                while (i > 0 && l[i] is EmptyStmt)
                    i -= 1;
                if (l[i] is ExprStmt last)
                    l[i] = new ExprResultStmt(last.Expr);
            }
            return new StmtBlock(t, l.ToArray());
        }

        internal Stmt ParseStatement()
        {
            switch (La())
            {
                case TokenType.MEMVAR:
                    return ParseXBaseDeclarationStmt(TokenType.MEMVAR);
                case TokenType.PARAMETERS:
                    return ParseXBaseDeclarationStmt(TokenType.PARAMETERS, parseType: true);
                case TokenType.LPARAMETERS:
                    return ParseXBaseDeclarationStmt(TokenType.LPARAMETERS, parseType: true);
                case TokenType.PRIVATE:
                    return ParseXBaseDeclarationStmt(TokenType.PRIVATE, parseArraySub: true, parseInit: true);
                case TokenType.PUBLIC:
                    return ParseXBaseDeclarationStmt(TokenType.PUBLIC, parseArraySub: true, parseInit: true, parseType: true);
                case TokenType.LOCAL:
                case TokenType.STATIC:
                case TokenType.VAR:
                    return ParseLocalDeclarationStmt();
                case TokenType.DECLARE:
                case TokenType.DIMENSION:
                    return ParseFoxDimensionStmt();
                case TokenType.FIELD:
                    return ParseFieldDeclStmt();
                case TokenType.NOP:
                    return ParseNopStmt();
                case TokenType.WHILE:
                    return ParseWhileStmt();
                case TokenType.REPEAT:
                    return ParseRepeatStmt();
                case TokenType.FOR:
                    if (La(2) == TokenType.EACH)
                        return ParseForeachStmt();
                    return ParseForStmt();
                case TokenType.IF:
                    return ParseIfStmt();
                case TokenType.DO:
                    switch(La(2))
                    {
                        case TokenType.WHILE:
                            return ParseWhileStmt();
                        case TokenType.CASE:
                            return ParseDoCaseStmt();
                        case TokenType.SWITCH:
                            return ParseSwitchStmt();
                        default:
                            throw Error(Lt(), ErrorCode.Expected, "WHILE or CASE");
                    }
                case TokenType.FOREACH:
                    return ParseForeachStmt();
                case TokenType.EXIT:
                    {
                        var s = new ExitStmt(ConsumeAndGet());
                        Require(TokenType.EOS);
                        return s;
                    }
                case TokenType.LOOP:
                    {
                        var s = new LoopStmt(ConsumeAndGet());
                        Require(TokenType.EOS);
                        return s;
                    }
                case TokenType.BREAK:
                    {
                        Token t = ConsumeAndGet();
                        var e = ParseExpression();
                        Require(TokenType.EOS);
                        return new BreakStmt(t, e);
                    }
                case TokenType.RETURN:
                    {
                        Token t = ConsumeAndGet();
                        if (Expect(TokenType.VOID))
                        {
                            Require(TokenType.EOS);
                            return new ReturnStmt(t, null);
                        }
                        var e = ParseExpression();
                        Require(TokenType.EOS);
                        return new ReturnStmt(t, e);
                    }
                case TokenType.QMARK:
                    {
                        Token t = ConsumeAndGet();
                        var args = new List<Expr>();
                        if (ParseExpression() is Expr e)
                        {
                            args.Add(e);
                            while (Expect(TokenType.COMMA))
                                args.Add(RequireExpression());
                        }
                        Require(TokenType.EOS);
                        return new QMarkStmt(t, args.ToArray());
                    }
                case TokenType.QQMARK:
                    {
                        Token t = ConsumeAndGet();
                        var args = new List<Expr>();
                        if (ParseExpression() is Expr e)
                        {
                            args.Add(e);
                            while (Expect(TokenType.COMMA))
                                args.Add(RequireExpression());
                        }
                        Require(TokenType.EOS);
                        return new QQMarkStmt(t, args.ToArray());
                    }
                case TokenType.THROW:
                    {
                        Token t = ConsumeAndGet();
                        var e = ParseExpression();
                        Require(TokenType.EOS);
                        return new ThrowStmt(t, e);
                    }
                case TokenType.TRY:
                    return ParseTryStmt();
                case TokenType.BEGIN:
                    switch (La(2))
                    {
                        case TokenType.SWITCH:
                            return ParseSwitchStmt();
                        case TokenType.SEQUENCE:
                            return ParseSequenceStmt();
                        case TokenType.LOCK:
                            return ParseLockStmt();
                        case TokenType.SCOPE:
                            return ParseScopeStmt();
                        case TokenType.USING:
                            return ParseUsingStmt();
                        case TokenType.UNSAFE:
                            return ParseScopeStmt(TokenType.UNSAFE);
                        case TokenType.CHECKED:
                            return ParseScopeStmt(TokenType.CHECKED);
                        case TokenType.UNCHECKED:
                            return ParseScopeStmt(TokenType.UNCHECKED);
                        case TokenType.FIXED:
                            return ParseFixedStmt();
                        default:
                            throw Error(Lt(), ErrorCode.Unexpected, Lt());
                    }
                case TokenType.UNTIL:
                    return null; // Prevent parsing as expression stmt!
                case TokenType.WITH:
                    throw Error(Lt(), ErrorCode.NotSupported, "WITH statement");
                case TokenType.YIELD:
                    throw Error(Lt(), ErrorCode.NotSupported, "YIELD statement");
                case TokenType.TEXT:
                    if (_options.Dialect == XSharpDialect.FoxPro)
                    {
                        ParseFoxText();
                    }
                    else
                        goto default;
                    break;
                default:
                    var l = ParseExprList();
                    if (l?.Exprs.Count > 0)
                    {
                        Require(TokenType.EOS);
                        return new ExprStmt(l);
                    }
                    break;
            }
            return null;
        }

        internal Token ParseVarIdName()
        {
            if (La() == TokenType.ID)
                return ConsumeAndGet();
            else if (La() == TokenType.M && La(2) == TokenType.DOT && (La(3) == TokenType.ID || TokenAttr.IsSoftKeyword(La(3))))
            {
                Consume(2);
                return ConsumeAndGet();
            }
            else if (TokenAttr.IsSoftKeyword(La()))
                return ConsumeAndGet();
            return null;
        }
        internal Token ParseIdName()
        {
            Token n = null;
            if (La() == TokenType.ID || TokenAttr.IsSoftKeyword(La()))
                n = ConsumeAndGet();
            return n;
        }

        internal Token RequireVarIdName()
        {
            return Require(ParseVarIdName(), ErrorCode.Expected, "identifier");
        }
        internal Token RequireIdName()
        {
            return Require(ParseIdName(), ErrorCode.Expected, "identifier");
        }

        internal DeclStmt ParseXBaseDeclarationStmt(TokenType kind, bool parseArraySub = false, bool parseInit = false, bool parseType = false)
        {
            Token t;
            Require(ExpectAndGet(kind, out t), ErrorCode.Expected, kind);
            var vl = new List<VarDecl>();
            do
            {
                if (ParseXBaseVarDecl(local: kind == TokenType.LPARAMETERS, parseArraySub: parseArraySub, parseInit: parseInit, parseType: parseType) is VarDecl v)
                    vl.Add(v);
            } while (Expect(TokenType.COMMA));
            Require(vl.Count > 0, ErrorCode.Expected, "variable declaration");
            Require(TokenType.EOS);
            return new DeclStmt(t, vl.ToArray());
        }

        internal VarDecl ParseXBaseVarDecl(bool local = false, bool parseArraySub = false, bool parseInit = false, bool parseType = false)
        {
            // Parse variable name
            Token n = RequireVarIdName();

            // Parse array sub indices
            List<Expr> asub = null;
            if (parseArraySub && Expect(TokenType.LBRKT))
            {
                asub = new List<Expr>();
                do
                {
                    asub.Add(RequireExpression());
                    if (Expect(TokenType.COMMA))
                        continue;
                    if (La() == TokenType.RBRKT && La(2) == TokenType.LBRKT)
                    {
                        Consume(2);
                        continue;
                    }
                    break;
                } while (true);
                Require(Expect(TokenType.RBRKT), ErrorCode.Expected, TokenType.RBRKT);
            }

            // Parse initializer
            Expr init = null;
            if (parseInit && Expect(TokenType.ASSIGN_OP))
            {
                init = ParseExpression();
            }

            // Parse type
            TypeExpr type = null;
            if (parseType && Expect(TokenType.AS)) // type parsed but ignored
            {
                Require(ParseType(), ErrorCode.Expected, "type");
                if (Expect(TokenType.OF))
                {
                    Require(ParseId(), ErrorCode.Expected, "identifier");
                }
            }

            return local ? new VarDecl(n, asub?.ToArray(), type, init)
                : new MemVarDecl(n, asub?.ToArray(), type, init);
        }

        internal DeclStmt ParseLocalDeclarationStmt()
        {
            Token t = null;
            if (ExpectAndGet(TokenType.LOCAL, out t))
            {
                if (La() == TokenType.STATIC)
                    t = ConsumeAndGet();
                if (t.Type == TokenType.STATIC)
                    Require(La() != TokenType.VAR && La() != TokenType.IMPLIED, ErrorCode.NotSupported, "static implied variable");
                if (La() == TokenType.IMPLIED)
                    t = ConsumeAndGet();
            }
            else if (ExpectAndGet(TokenType.STATIC, out t))
            {
                if (La() == TokenType.LOCAL)
                    Consume();
                Require(La() != TokenType.VAR && La() != TokenType.IMPLIED, ErrorCode.NotSupported, "static implied variable");
            }
            else if (ExpectAndGet(TokenType.VAR, out t))
            {
                Require(La() != TokenType.STATIC, ErrorCode.NotSupported, "static implied variable");
            }
            Require(t, ErrorCode.Expected, TokenType.LOCAL);
            bool implied = t.Type == TokenType.VAR || t.Type == TokenType.IMPLIED;


            var vl = new List<VarDecl>();
            do
            {
                if (ParseVarDecl(implied) is VarDecl v)
                    vl.Add(v);
            } while (Expect(TokenType.COMMA));
            Require(vl.Count > 0, ErrorCode.Expected, "variable declaration");

            Require(TokenType.EOS);
            return new DeclStmt(t, vl.ToArray());
        }
        internal VarDecl ParseVarDecl(bool implied)
        {
            // Parse modifiers
            bool isConst = Expect(TokenType.CONST);
            bool isDim = !implied && Expect(TokenType.DIM);

            // Parse variable name
            Token n = RequireVarIdName();

            // Parse array sub indices
            List<Expr> asub = null;
            if (!implied && Expect(TokenType.LBRKT))
            {
                asub = new List<Expr>();
                do
                {
                    asub.Add(RequireExpression());
                    if (Expect(TokenType.COMMA))
                        continue;
                    if (La() == TokenType.RBRKT && La(2) == TokenType.LBRKT)
                    {
                        Consume(2);
                        continue;
                    }
                    break;
                } while (true);
                Require(Expect(TokenType.RBRKT), ErrorCode.Expected, TokenType.RBRKT);
            }

            // Parse initializer
            Expr init = null;
            if (Expect(TokenType.ASSIGN_OP))
            {
                init = ParseExpression();
            }
            if (implied) Require(init, ErrorCode.Expected, "initializer");

            // Parse type
            TypeExpr type = null;
            bool isIsType = false;
            if (!implied && ExpectAndGetAny(TokenType.AS, TokenType.IS) is Token t)
            {
                isIsType = t.Type == TokenType.IS;
                type = Require(ParseType(), ErrorCode.Expected, "type");
            }

            return implied ? new ImpliedVarDecl(n, init) { IsConst = isConst }
                : new VarDecl(n, asub?.ToArray(), type, init) { IsConst = isConst, IsDim = isDim, IsIsType = isIsType };
        }

        internal DeclStmt ParseFoxDimensionStmt()
        {
            Token t = Require(ExpectAndGetAny(TokenType.DIMENSION, TokenType.DECLARE), ErrorCode.Expected, TokenType.DIMENSION);
            var vl = new List<VarDecl>();
            do
            {
                if (ParseFoxDimVarDecl() is VarDecl v)
                    vl.Add(v);
            } while (Expect(TokenType.COMMA));
            Require(vl.Count > 0, ErrorCode.Expected, "variable declaration");
            Require(TokenType.EOS);
            return new DeclStmt(t, vl.ToArray());
        }
        internal VarDecl ParseFoxDimVarDecl()
        {
            // Parse variable name
            Token n = RequireIdName();

            // Parse array sub indices
            List<Expr> asub = null;
            if (ExpectAndGetAny(TokenType.LBRKT,TokenType.LPAREN) is Token lp)
            {
                asub = new List<Expr>();
                do
                {
                    asub.Add(RequireExpression());
                    if (Expect(TokenType.COMMA))
                        continue;
                    if (La() == TokenType.RBRKT && La(2) == TokenType.LBRKT)
                    {
                        Consume(2);
                        continue;
                    }
                    break;
                } while (true);
                var rp = Expect(lp.Type == TokenType.LBRKT ? TokenType.RBRKT : TokenType.RPAREN);
                Require(rp, ErrorCode.Expected, rp);
            }

            // Parse type
            TypeExpr type = null;
            if (Expect(TokenType.AS)) // type parsed byt ignored
            {
                Require(ParseType(), ErrorCode.Expected, "type");
                if (Expect(TokenType.OF))
                {
                    Require(ParseId(), ErrorCode.Expected, "identifier");
                }
            }

            return new VarDecl(n, asub?.ToArray(), type, null);
        }

        internal FieldDeclStmt ParseFieldDeclStmt()
        {
            Token t;
            Require(ExpectAndGet(TokenType.FIELD, out t), ErrorCode.Expected, TokenType.FIELD);
            var fl = new List<Token>();
            do
            {
                fl.Add(RequireId());
            } while (Expect(TokenType.COMMA));

            Token alias = null;
            if (Expect(TokenType.IN))
            {
                alias = RequireId();
            }

            Require(TokenType.EOS);
            return new FieldDeclStmt(fl.ToArray(), alias);
        }

        internal EmptyStmt ParseNopStmt()
        {
            Token t;
            ExpectAndGet(TokenType.NOP, out t);
            if (Expect(TokenType.LPAREN))
                Require(TokenType.RPAREN);
            Require(TokenType.EOS);
            return new EmptyStmt(t);
        }

        internal WhileStmt ParseWhileStmt()
        {
            Expect(TokenType.DO);
            Token w;
            Require(ExpectAndGet(TokenType.WHILE, out w),ErrorCode.Expected, TokenType.WHILE);
            var cond = RequireExpression();
            Require(TokenType.EOS);
            var s = ParseStatementBlock();
            if (!Expect(TokenType.ENDDO))
            {
                Require(TokenType.END);
                ExpectAny(TokenType.DO, TokenType.WHILE);
            }
            Require(TokenType.EOS);
            return new WhileStmt(w, cond, s);
        }

        internal ForStmt ParseForStmt()
        {
            Token t;
            ExpectAndGet(TokenType.FOR, out t);
            VarDecl d = null;
            AssignExpr a = null;
            if (ExpectAny(TokenType.IMPLIED, TokenType.VAR) || (La(2) == TokenType.IMPLIED && Expect(TokenType.LOCAL) && Expect(TokenType.IMPLIED)))
            {
                d = ParseForDecl(true);
            }
            else if (Expect(TokenType.LOCAL))
            {
                d = ParseForDecl(false);
            }
            else
            {
                a = ParseExpression() as AssignExpr;
                Require(a?.Left is IdExpr, ErrorCode.Expected, "variable assignemnt expression");
            }
            var dir = Require(ExpectAndGetAny(TokenType.UPTO, TokenType.DOWNTO, TokenType.TO), ErrorCode.Expected, TokenType.TO);
            Expr final = RequireExpression();
            Expr step = null;
            if (Expect(TokenType.STEP))
            {
                step = RequireExpression();
            }
            Require(TokenType.EOS);
            var s = ParseStatementBlock();
            if (Expect(TokenType.END))
            {
                Expect(TokenType.FOR);
            }
            else
                Require(Expect(TokenType.NEXT), ErrorCode.Expected, "END FOR");
            Require(TokenType.EOS);
            return a != null ? new ForStmt(t, a, dir, final, step, s)
                : new ForStmt(t, d, dir, final, step, s);
        }
        internal VarDecl ParseForDecl(bool implied)
        {
            Token n = null;
            if (La() == TokenType.ID || TokenAttr.IsSoftKeyword(La()))
                n = ConsumeAndGet();
            Require(n, ErrorCode.Expected, "identifier");

            Expr init = null;
            if (Require(TokenType.ASSIGN_OP))
            {
                init = ParseExpression();
            }

            TypeExpr type = null;
            if (!implied && Expect(TokenType.AS))
            {
                type = Require(ParseType(), ErrorCode.Expected, "type");
            }

            return implied ? new ImpliedVarDecl(n, init)
                : new VarDecl(n, null, type, init);
        }

        internal IfStmt ParseIfStmt()
        {
            var t = RequireAndGet(TokenType.IF);
            var cond = RequireExpression();
            Expect(TokenType.THEN);
            Require(TokenType.EOS);
            var si = ParseStatementBlock();
            Stmt se = null;
            if (Expect(TokenType.ELSE))
            {
                Require(TokenType.EOS);
                se = ParseStatementBlock();
            }
            if (Expect(TokenType.END))
            {
                Expect(TokenType.IF);
            }
            else
                Require(Expect(TokenType.ENDIF), ErrorCode.Expected, "END IF");
            Require(TokenType.EOS);
            return new IfStmt(t, cond, si, se);
        }

        internal DoCaseStmt ParseDoCaseStmt()
        {
            var t = RequireAndGet(TokenType.DO);
            Require(TokenType.CASE);
            Require(TokenType.EOS);

            var cases = new List<CaseBlock>();
            Token c;
            while (ExpectAndGet(TokenType.CASE, out c))
            {
                var cond = ParseExpression();
                Require(TokenType.EOS);
                var s = ParseStatementBlock();
                cases.Add(new CaseBlock(c, cond, s));
            }

            Stmt o = null;
            if (Expect(TokenType.OTHERWISE))
            {
                Require(TokenType.EOS);
                o = ParseStatementBlock();
            }

            Require(cases.Count > 0 || o != null, ErrorCode.Expected, "CASE or OTHERWISE");

            if (Expect(TokenType.END))
                Expect(TokenType.CASE);
            else
                Require(TokenType.ENDCASE);
            Require(TokenType.EOS);

            return new DoCaseStmt(t, cases.ToArray(), o);
        }

        internal TryStmt ParseTryStmt()
        {

            Token t = RequireAndGet(TokenType.TRY);
            Require(TokenType.EOS);
            var s = ParseStatementBlock();

            var cb = new List<CatchBlock>();
            while (La() == TokenType.CATCH)
                cb.Add(ParseCatchBlock());

            FinallyBlock fb = null;
            if (La() == TokenType.FINALLY)
            {
                var ft = ConsumeAndGet();
                Require(TokenType.EOS);
                fb = new FinallyBlock(ft, ParseStatementBlock());
            }

            Require(TokenType.END);
            Expect(TokenType.TRY);
            Require(TokenType.EOS);

            return new TryStmt(t, s, cb.ToArray(), fb);

            CatchBlock ParseCatchBlock()
            {
                Token ct = RequireAndGet(TokenType.CATCH);
                Expect(TokenType.TO);

                Token n = ParseVarIdName();

                TypeExpr type = null;
                if (Expect(TokenType.AS))
                    Require(type = ParseType(), ErrorCode.Expected, "type");

                Expr when = null;
                if (Expect(TokenType.WHEN))
                    when = RequireExpression();

                Expect(TokenType.EOS);
                var cs = ParseStatementBlock();

                return new CatchBlock(ct, n, type, when, cs);
            }
        }

        internal RepeatStmt ParseRepeatStmt()
        {
            Token r = RequireAndGet(TokenType.REPEAT);
            Require(TokenType.EOS);
            var s = ParseStatementBlock();
            Require(TokenType.UNTIL);
            var cond = RequireExpression();
            Require(TokenType.EOS);
            return new RepeatStmt(r, cond, s);
        }

        internal ForeachStmt ParseForeachStmt()
        {
            Token r = ExpectToken(TokenType.FOR) ?? RequireAndGet(TokenType.FOREACH);
            if (r.Type == TokenType.FOR)
                Require(TokenType.EACH);

            VarDecl v = null;
            if (Expect(TokenType.IMPLIED) || Expect(TokenType.VAR))
            {
                Token n = RequireVarIdName();
                v = new ImpliedVarDecl(n, null);
            }
            else
            {
                Token n = RequireVarIdName();
                Require(TokenType.AS);
                TypeExpr type = Require(ParseType(), ErrorCode.Expected, "type");
                v = new VarDecl(n, type);
            }

            Require(TokenType.IN);
            var e = RequireExpression();

            Require(TokenType.EOS);

            var s = ParseStatementBlock();

            if (!Expect(TokenType.NEXT))
            {
                Require(TokenType.END);
                ExpectAny(TokenType.FOR, TokenType.FOREACH);
            }
            Require(TokenType.EOS);

            return new ForeachStmt(r, v, e, s);
        }

        internal SwitchStmt ParseSwitchStmt()
        {
            ExpectAny(TokenType.BEGIN, TokenType.DO);
            var t = RequireAndGet(TokenType.SWITCH);
            var e = RequireExpression();
            Require(TokenType.EOS);
            var sbs = new List<SwitchBlock>();
            sbs.Add(Require(ParseSwitchBlock(), ErrorCode.Expected, "CASE"));
            while (ParseSwitchBlock() is SwitchBlock sb)
                sbs.Add(sb);
            Require(TokenType.END);
            Expect(TokenType.SWITCH);
            Require(TokenType.EOS);
            return new SwitchStmt(t, e, sbs.ToArray());

            SwitchBlock ParseSwitchBlock()
            {
                if (La() == TokenType.CASE && (
                    (La(2) == TokenType.M && La(3) == TokenType.DOT && (La(4) == TokenType.ID || TokenAttr.IsSoftKeyword(La(4))) && La(5) == TokenType.AS) ||
                    ((La(2) == TokenType.ID || TokenAttr.IsSoftKeyword(La(2))) && La(3) == TokenType.AS)
                    ))
                {
                    var st = ConsumeAndGet();
                    var n = RequireVarIdName();
                    Require(TokenType.AS);
                    var ty = Require(ParseType(), ErrorCode.Expected, "type");
                    Expr wh = null;
                    if (Expect(TokenType.WHEN))
                        wh = ParseExpression();
                    Require(TokenType.EOS);
                    var s = ParseStatementBlock();
                    return new SwitchBlockType(st, n, ty, wh, s.StmtList.Length>0 ? s : null);
                }
                else if (La() == TokenType.CASE)
                {
                    var st = ConsumeAndGet();
                    var se = RequireExpression();
                    Require(se is LiteralExpr, ErrorCode.Expected, "literal value");
                    Expr wh = null;
                    if (Expect(TokenType.WHEN))
                        wh = ParseExpression();
                    Require(TokenType.EOS);
                    var s = ParseStatementBlock();
                    return new SwitchBlockExpr(st, se, wh, s.StmtList.Length > 0 ? s : null);
                }
                else if (La() == TokenType.OTHERWISE)
                {
                    var st = ConsumeAndGet();
                    Require(TokenType.EOS);
                    var s = ParseStatementBlock();
                    return new SwitchBlock(st, s.StmtList.Length > 0 ? s : null);
                }
                else
                    return null;
            }
        }

        internal SequenceStmt ParseSequenceStmt()
        {
            Require(TokenType.BEGIN);
            var t = RequireAndGet(TokenType.SEQUENCE);
            Require(TokenType.EOS);
            var s = ParseStatementBlock();

            Token n = null;
            StmtBlock r = null;
            if (Expect(TokenType.RECOVER))
            {
                Require(TokenType.USING);
                n = RequireIdName();
                Require(TokenType.EOS);
                r = ParseStatementBlock();
            }

            StmtBlock f = null;
            if (Expect(TokenType.FINALLY))
            {
                Require(TokenType.EOS);
                f = ParseStatementBlock();
            }
            Require(TokenType.END);
            Expect(TokenType.SEQUENCE);
            Require(TokenType.EOS);

            return new SequenceStmt(t, s, n, r, f);
        }

        internal LockStmt ParseLockStmt()
        {
            Require(TokenType.BEGIN);
            var t = RequireAndGet(TokenType.LOCK);
            var key = RequireExpression();
            Require(TokenType.EOS);
            var s = ParseStatementBlock();
            Require(TokenType.END);
            Expect(TokenType.LOCK);
            Require(TokenType.EOS);
            return new LockStmt(t, key, s);
        }

        internal Stmt ParseScopeStmt(TokenType kind = TokenType.SCOPE)
        {
            Require(TokenType.BEGIN);
            var t = RequireAndGet(kind);
            Require(TokenType.EOS);
            var s = ParseStatementBlock();
            Require(TokenType.END);
            Expect(kind);
            Require(TokenType.EOS);
            return kind == TokenType.SCOPE ? (Stmt)s : new ScopeStmt(t, s);
        }

        internal DeclStmt ParseInnerDeclStmt()
        {
            Token t = null;
            if (ExpectAndGet(TokenType.LOCAL, out t) && La() != TokenType.IMPLIED && La() != TokenType.VAR)
            {
                var decl = new List<VarDecl>();
                do
                {
                    var n = RequireIdName();
                    Require(TokenType.ASSIGN_OP);
                    var e = RequireExpression();
                    decl.Add(new VarDecl(n, null, null, e));
                } while (Expect(TokenType.COMMA));
                if (Expect(TokenType.AS))
                {
                    var type = Require(ParseType(), ErrorCode.Expected, "type");
                    decl.ForEach(x => x.Type = type);
                }
                return new DeclStmt(t, decl.ToArray());
            }
            if (ExpectAndGet(TokenType.IMPLIED, out t) || ExpectAndGet(TokenType.VAR, out t))
            {
                var decl = new List<ImpliedVarDecl>();
                do
                {
                    var n = RequireIdName();
                    Require(TokenType.ASSIGN_OP);
                    var e = RequireExpression();
                    decl.Add(new ImpliedVarDecl(n, e));
                } while (Expect(TokenType.COMMA));
                return new DeclStmt(t, decl.ToArray());
            }
            return null;
        }
        internal UsingStmt ParseUsingStmt()
        {
            Require(TokenType.BEGIN);
            var t = RequireAndGet(TokenType.USING);
            var d = ParseInnerDeclStmt();
            var e = d == null ? RequireExpression() : null;
            Require(TokenType.EOS);
            var s = ParseStatementBlock();
            Require(TokenType.END);
            Expect(TokenType.USING);
            Require(TokenType.EOS);
            return d != null ? new UsingStmt(t, d, s) : new UsingStmt(t, e, s);
        }
        internal UsingStmt ParseFixedStmt()
        {
            Require(TokenType.BEGIN);
            var t = RequireAndGet(TokenType.FIXED);
            var d = ParseInnerDeclStmt();
            Require(TokenType.EOS);
            var s = ParseStatementBlock();
            Require(TokenType.END);
            Expect(TokenType.FIXED);
            Require(TokenType.EOS);
            return new UsingStmt(t, d, s);
        }

        internal void ParseFoxText()
        {
            var t = RequireAndGet(TokenType.TEXT);
            if (Expect(TokenType.TO))
            {
                var n = RequireVarIdName();
                var add = Expect(TokenType.ADDITIVE);
                var merge = Expect(TokenType.TEXTMERGE);
                var noshow = Expect(TokenType.NOSHOW);
                Expr flags = null;
                if (Expect(TokenType.FLAGS))
                    flags = RequireExpression();
                Expr pretext = null;
                if (Expect(TokenType.PRETEXT))
                    pretext = RequireExpression();
            }
            Require(TokenType.EOS);
            if (La() == TokenType.INCOMPLETE_STRING_CONST)
                throw Error(Lt(), ErrorCode.UnterminatedString);
            Token s;
            ExpectAndGet(TokenType.TEXT_STRING_CONST, out s);
            Require(TokenType.ENDTEXT);
        }
    }
}
