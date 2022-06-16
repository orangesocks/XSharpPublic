#define DUMPTOKENS
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using XSharp.MacroCompiler.Syntax;

namespace XSharp.MacroCompiler
{
    public static partial class Compilation
    {    
        public static Compilation<T, Func<T[], T>> Create<T>(MacroOptions options = null)
        {
            if (options?.StrictTypedSignature == true)
                throw new InternalError("Invalid StrictTypedSignature option without delegate type");
            if (options?.ParseStatements == true)
                return new ScriptCompilation<T, Func<T[], T>>(options);
            return new Compilation<T, Func<T[], T>>(options ?? MacroOptions.Default);
        }

        public static Compilation<T, R> Create<T, R>(MacroOptions options = null) where R: Delegate
        {
            if (options?.StrictTypedSignature == true)
                return new TypedCompilation<T, R>(options);
            if (options?.ParseStatements == true)
                return new ScriptCompilation<T, R>(options);
            return new Compilation<T, R>(options ?? MacroOptions.Default);
        }
    }

    public partial class Compilation<T,R> where R: Delegate
    {
        public struct CompilationResult
        {
            public string Source;
            public R Macro;
            internal Binder<T, R> Binder;
            internal Syntax.Node SyntaxTree;
            public int ParamCount { get => Binder.ParamCount; }
            public bool CreatesAutoVars { get => Binder.CreatesAutoVars; }
            public CompilationError Diagnostic;
            internal CompilationResult(string source, R macro, Binder<T, R> binder)
            {
                Source = source;
                Macro = macro;
                SyntaxTree = null;
                Binder = binder;
                Diagnostic = null;
            }
            internal CompilationResult(string source, Syntax.Node syntaxTree, Binder<T, R> binder)
            {
                Source = source;
                Macro = null;
                SyntaxTree = syntaxTree;
                Binder = binder;
                Diagnostic = null;
            }
            internal CompilationResult(string source, CompilationError diagnostic)
            {
                Source = source;
                Macro = null;
                SyntaxTree = null;
                Binder = null;
                Diagnostic = diagnostic;
            }
        }

        internal MacroOptions options;

        internal Compilation(MacroOptions o = null)
        {
            options = o ?? MacroOptions.Default;
        }

        public static Compilation<T, R> Create(MacroOptions options = null) => Compilation.Create<T, R>(options);

        internal List<Tuple<string, Type>> ExternLocals;
        internal string[] ParamNames;
        public void AddExternLocal(string name, Type type)
        {
            if (ExternLocals == null)
                ExternLocals = new List<Tuple<string, Type>>();
            ExternLocals.Add(new Tuple<string, Type>(name, type));
        }
        public void SetParamNames(params string[] paramNames)
        {
            ParamNames = paramNames;
        }
        internal void AddLocalsToBinder(Binder binder)
        {
            // Add params
            if (ParamNames != null)
            {
                int a = 0;
                foreach (var p in binder.DelegateType.GetMethod("Invoke").GetParameters())
                {
                    if (a < ParamNames.Length)
                        binder.AddParam(ParamNames[a], Binder.FindType(p.ParameterType), a);
                    ++a;
                }
            }

            // Add Locals
            if (ExternLocals != null)
                foreach (var l in ExternLocals)
                    binder.AddLocal(l.Item1, Binder.FindType(l.Item2));
        }
        internal void DeclareLocals(Binder binder)
        {
            // Declare locals
            if (ExternLocals != null)
                foreach (var l in ExternLocals)
                    (binder.LocalCache[l.Item1] as LocalSymbol)?.Declare(binder.Method.GetILGenerator());
        }

        public CompilationResult Compile(string source)
        {
            try
            {
                var res = Bind(source, Parse(source));
                EmitInternal(ref res);
                return res;
            }
            catch (CompilationError e)
            {
                if (e.Location.Line == 0)
                    e = new CompilationError(e, source);
                return new CompilationResult(source, e);
            }
        }

        public CompilationResult Bind(string source)
        {
            try
            {
                return Bind(source, Parse(source));
            }
            catch (CompilationError e)
            {
                if (e.Location.Line == 0)
                    e = new CompilationError(e, source);
                return new CompilationResult(source, e);
            }
        }

        public R Emit(CompilationResult macro)
        {
            EmitInternal(ref macro);
            return macro.Macro;
        }

        internal virtual Syntax.Node Parse(string source)
        {
            var lexer = new Lexer(source, options);
            IList<Token> tokens = lexer.AllTokens();
            if (options.PreProcessor && options.ParseStatements)
            {
                var pp = new Preprocessor.XSharpPreprocessor(lexer, options, null, Encoding.Default);
                tokens = pp.PreProcess();
            }
            var parser = new Parser(tokens, options);
            return parser.ParseMacro();
        }
        internal virtual CompilationResult Bind(string source, Syntax.Node parseTree)
        {
            try
            {
                Binder<T, R> binder = CreateBinder();
                var ast = binder.Bind(parseTree);
                return new CompilationResult(source, ast, binder);
            }
            catch (CompilationError e)
            {
                if (e.Location.Line == 0)
                    e = new CompilationError(e, source);
                return new CompilationResult(source, e);
            }
        }
        internal virtual void EmitInternal(ref CompilationResult macro)
        {
            if (macro.Macro == null && macro.SyntaxTree != null)
            {
                macro.Binder.MakeDynamicMethod(macro.Source);
                DeclareLocals(macro.Binder);
                macro.Macro = macro.Binder.Emit(macro.SyntaxTree);
            }
        }
        internal virtual Binder<T, R> CreateBinder()
        {
            var binder = Binder.Create<T, R>(options);
            AddLocalsToBinder(binder);
            return binder;
        }
    }
    public class ScriptCompilation<T, R> : Compilation<T, R> where R : Delegate
    {
        internal ScriptCompilation(MacroOptions o = null): base(o)
        {
            options.ParseMode = ParseMode.Statements;
        }
        internal override Syntax.Node Parse(string source)
        {
            var lexer = new Lexer(source, options);
            IList<Token> tokens = lexer.AllTokens();
            if (options.PreProcessor && options.ParseStatements)
            {
                var pp = new Preprocessor.XSharpPreprocessor(lexer, options, "Macro", Encoding.Default);
                tokens = pp.PreProcess();
            }
            var parser = new Parser(tokens, options);
            return parser.ParseScript();
        }
    }
    public class TypedCompilation<T, R> : Compilation<T, R> where R : Delegate
    {
        internal TypedCompilation(MacroOptions o = null) : base(o)
        {
        }
        internal override CompilationResult Bind(string source, Syntax.Node parseTree)
        {
            try
            {
                Binder<T, R> binder = CreateBinder();
                var ast = TypedCodeblock.Bound(parseTree as Syntax.Codeblock, binder);
                return new CompilationResult(source, ast, binder);
            }
            catch (CompilationError e)
            {
                if (e.Location.Line == 0)
                    e = new CompilationError(e, source);
                return new CompilationResult(source, e);
            }
        }
    }
}
