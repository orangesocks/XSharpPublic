﻿/*
   Copyright 2016 XSharp B.V.

Licensed under the X# compiler source code License, Version 1.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.xsharp.info/licenses

Unless required by applicable law or agreed to in writing, software
Distributed under the License is distributed on an "as is" basis,
without warranties or conditions of any kind, either express or implied.
See the License for the specific language governing permissions and   
limitations under the License.
*/

[assembly: System.Runtime.CompilerServices.InternalsVisibleTo("xsc,PublicKey=0024000004800000940000000602000000240000525341310004000001000100b16a35b62bb33ce476c595e75bcc83fe4566c0a7cb9c093ce23e7add61fe1fc8a6edca2e542f0dc9ce41ec6b4260a73dda598c81f61a6f9522653ebfeae098a3bdb641020e843cbab825afe1c3910d42d17a1dcf211abb1cba4fc5e19569307c67a11c92b848d2df23f454d5ed1ab8b479afa4ece799445292b11012225aee96")]
[assembly: System.Runtime.CompilerServices.InternalsVisibleTo("XSCompiler,PublicKey=0024000004800000940000000602000000240000525341310004000001000100b16a35b62bb33ce476c595e75bcc83fe4566c0a7cb9c093ce23e7add61fe1fc8a6edca2e542f0dc9ce41ec6b4260a73dda598c81f61a6f9522653ebfeae098a3bdb641020e843cbab825afe1c3910d42d17a1dcf211abb1cba4fc5e19569307c67a11c92b848d2df23f454d5ed1ab8b479afa4ece799445292b11012225aee96")]
[assembly: System.Runtime.CompilerServices.InternalsVisibleTo("XSTestCodeAnalysis,PublicKey=0024000004800000940000000602000000240000525341310004000001000100b16a35b62bb33ce476c595e75bcc83fe4566c0a7cb9c093ce23e7add61fe1fc8a6edca2e542f0dc9ce41ec6b4260a73dda598c81f61a6f9522653ebfeae098a3bdb641020e843cbab825afe1c3910d42d17a1dcf211abb1cba4fc5e19569307c67a11c92b848d2df23f454d5ed1ab8b479afa4ece799445292b11012225aee96")]

// THIS IS A HACK to prevent errors from showing up in the IDE
#if !XSHARP_RUNTIME
namespace Microsoft.CodeAnalysis
{
    internal class CodeAnalysisResources : LanguageService.CodeAnalysis.CodeAnalysisResources { }
}

namespace Microsoft.CodeAnalysis.CSharp
{
    internal class CSharpResources : LanguageService.CodeAnalysis.XSharpResources { }
}
#endif
// HACK ENDS HERE