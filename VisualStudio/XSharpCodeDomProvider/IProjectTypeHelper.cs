﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LanguageService.CodeAnalysis.XSharp;
namespace XSharp.CodeDom
{
    public interface IProjectTypeHelper
    {
        XSharpModel.XType ResolveXType(string name, IReadOnlyList<string> usings);
        XSharpModel.XType ResolveReferencedType(string name, IReadOnlyList<string> usings);

        XSharpParseOptions ParseOptions { get; }
        string SynchronizeKeywordCase(string code, string fileName);
    }
}
