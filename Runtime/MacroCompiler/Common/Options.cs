using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace XSharp.MacroCompiler
{
    public enum VariableResolution
    {
        Error,
        GenerateLocal,
        TreatAsField,
        TreatAsFieldOrMemvar,
    }

    public enum ParseMode
    {
        Expression,
        Statements,
        Entities,
    }

    public class MacroOptions
    {
        public static MacroOptions Default { get => new MacroOptions(); }

        public static MacroOptions VisualObjects { get => new MacroOptions() { AllowMemvarAlias = false, AllowDotAccess = false, Dialect = XSharpDialect.VO }; }

        public static MacroOptions FoxPro { get => new MacroOptions() { Dialect = XSharpDialect.FoxPro }; }

        public XSharpDialect Dialect = XSharpDialect.VO;

        public bool AllowFourLetterAbbreviations = false;
        public bool AllowOldStyleComments = true;
        public bool AllowSingleQuotedStrings = true;
        public bool AllowPackedDotOperators = true;
        public bool AllowMissingSyntax = true;
        public bool AllowExtraneousSyntax = true;

        public bool VOFloatConstants = true;
        public bool VODateConstants = true;

        public bool AllowMemvarAlias = true;
        public bool AllowDotAccess = true;

        public bool ArrayZero = false;
        public MacroCompilerResolveAmbiguousMatch Resolver = null;

        public bool AllowInexactComparisons {
            get { return Binding.HasFlag(BindOptions.AllowInexactComparisons); }
            set { Binding |= BindOptions.AllowInexactComparisons; }
        }

        public VariableResolution UndeclaredVariableResolution = VariableResolution.TreatAsFieldOrMemvar;

        public ParseMode ParseMode = ParseMode.Expression;
        internal bool ParseEntities { get => ParseMode == ParseMode.Entities; }
        internal bool ParseStatements { get => ParseMode == ParseMode.Statements || ParseMode == ParseMode.Entities; }

        internal BindOptions Binding { get; private set; } = BindOptions.Default;
        internal int ArrayBase => ArrayZero ? 0 : 1;
    }
}
