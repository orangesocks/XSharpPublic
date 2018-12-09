﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;

namespace XSharp.MacroCompiler
{
    public enum ErrorCode
    {
        NoError,
        NotImplemented = 1,
        Expected = 100,
        Unexpected = 101,
        BadNumArgs = 102,
        UnterminatedString = 103,
        NotSupported = 104,
        UnexpectedValue = 200,
        NoConversion = 201,
        NoImplicitConversion = 202,
        TypeNotFound = 203,
        IdentifierNotFound = 204,
        NoSuitableOverload = 205,
        MemberNotMethod = 206,
        ArgumentsNotMatch = 207,
        MemberNotFound = 208,
        AmbiguousCall = 209,
        CtorNotFound = 210,
        ArgumentsNotMatchCtor = 211,
        NoSuitableCtor = 212,
        IndexerNotFound = 213,
        TypeNotFoundInNamespace = 214,
        MemberNotFoundInType = 215,
        NotTypeOrNamespace = 216,
        BinaryOperationNotFound = 217,
        UnaryOperationNotFound = 218,
    }

    internal class ErrorString
    {
        static private Dictionary<ErrorCode, string> _errorStrings = new Dictionary<ErrorCode, string>()
        {
            { ErrorCode.NoError, "No error" },
            { ErrorCode.NotImplemented, "Feature not implemented: {0}" },
            { ErrorCode.Expected, "Expected {0}" },
            { ErrorCode.Unexpected, "Unexpected {0}" },
            { ErrorCode.BadNumArgs, "Bad number of arguments (expected {0})" },
            { ErrorCode.UnterminatedString, "Unterminated string" },
            { ErrorCode.NotSupported, "Not supported: {0}" },
            { ErrorCode.UnexpectedValue, "Unexpected value" },
            { ErrorCode.NoConversion, "No conversion from {0} to {1}" },
            { ErrorCode.NoImplicitConversion, "No implicit conversion from {0} to {1} (explicit conversion exists)" },
            { ErrorCode.TypeNotFound, "Type not found: {0}" },
            { ErrorCode.IdentifierNotFound, "Not found: {0}" },
            { ErrorCode.NoSuitableOverload, "No suitable overload of {0}" },
            { ErrorCode.MemberNotMethod, "Member is not a method: {0}" },
            { ErrorCode.ArgumentsNotMatch, "Aruments do not match method {0}" },
            { ErrorCode.MemberNotFound, "No accessible member found" },
            { ErrorCode.AmbiguousCall, "Ambiguous call" },
            { ErrorCode.CtorNotFound, "No accessible constructor found" },
            { ErrorCode.ArgumentsNotMatchCtor, "Constructor aruments do not match" },
            { ErrorCode.NoSuitableCtor, "No suitable constructor" },
            { ErrorCode.IndexerNotFound, "No suitable indexer for {0}" },
            { ErrorCode.TypeNotFoundInNamespace, "Type {0} not found in namespace {1}" },
            { ErrorCode.MemberNotFoundInType, "No accessible member {0} found in type {1}" },
            { ErrorCode.NotTypeOrNamespace, "{0} is not a type or namespace" },
            { ErrorCode.BinaryOperationNotFound, "Operator {0} on types {1} and {2} could not be resolved" },
            { ErrorCode.UnaryOperationNotFound, "Operator {0} on type {1} could not be resolved" },
        };

        static internal string Get(ErrorCode e) { return _errorStrings[e]; }

        static internal string Format(ErrorCode e, params object[] args) { return String.Format(_errorStrings[e], args); }

#if DEBUG
        static ErrorString()
        {
            var errors = (ErrorCode[])Enum.GetValues(typeof(ErrorCode));
            Debug.Assert(errors.Length == _errorStrings.Count);
            foreach (var e in errors)
            {
                string v;
                _errorStrings.TryGetValue(e, out v);
                Debug.Assert(v != null);
            }
        }
#endif
    }

    public class InternalError : Exception
    {
        public InternalError() : base() { }
        public InternalError(string message) : base(message) { }
    }

    public class CompilationError : Exception
    {
        public readonly ErrorCode Code;
        public readonly SourceLocation Location;
        public string DiagnosticMessage
        {
            get
            {
                return Location.Valid ?
                      String.Format("({1},{2}): error XM{0:D4}: {3}", (int)Code, Location.Line, Location.Col, Message)
                    : String.Format("error XM{0:D4}: {1}", (int)Code, Message);
            }
        }
        internal CompilationError(ErrorCode e, params object[] args): base(ErrorString.Format(e, args)) { Code = e; Location = SourceLocation.None; }
        internal CompilationError(int offset, ErrorCode e, params object[] args) : base(ErrorString.Format(e, args)) { Code = e; Location = new SourceLocation(offset); }
        internal CompilationError(SourceLocation loc, ErrorCode e, params object[] args) : base(ErrorString.Format(e, args)) { Code = e; Location = loc; }
        internal CompilationError(CompilationError e, string source) : base(e.Message) { Code = e.Code; Location = new SourceLocation(source, e.Location); }
    }

    public static partial class Compilation
    {
        internal static CompilationError Error(ErrorCode e, params object[] args) { return new CompilationError(e, args); }
        internal static CompilationError Error(int offset, ErrorCode e, params object[] args) { return new CompilationError(offset, e, args); }
        internal static CompilationError Error(SourceLocation loc, ErrorCode e, params object[] args) { return new CompilationError(loc, e, args); }
        internal static CompilationError Error(Syntax.Token t, ErrorCode e, params object[] args) { return new CompilationError(t.start, e, args); }
    }
}
