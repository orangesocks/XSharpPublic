﻿/*
   Copyright 2016-2017 XSharp B.V.

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

namespace Microsoft.CodeAnalysis.CSharp
{

    internal static class VulcanSpecialNames
    {
        internal const string ClipperArgs = "$args";
    }
    internal static class OurTypeNames
    {
        internal const string CodeBlockType = "Codeblock";
        internal const string UsualType = "__Usual";
        internal const string VOStructAttribute = "VOStructAttribute";
        internal const string DefaultParameterAttribute = "DefaultParameterValueAttribute";
        internal const string ActualTypeAttribute = "ActualTypeAttribute";
        internal const string ClipperCallingConventionAttribute = "ClipperCallingConventionAttribute";
    }
    internal static class VulcanQualifiedTypeNames
    {
        internal const string Usual = "global::Vulcan.__Usual";
        internal const string Float = "global::Vulcan.__VOFloat";
        internal const string Date = "global::Vulcan.__VODate";
        internal const string Array = "global::Vulcan.__Array";
        internal const string Symbol = "global::Vulcan.__Symbol";
        internal const string Psz = "global::Vulcan.__Psz";
        internal const string Codeblock = "global::Vulcan.Codeblock";
        internal const string WinBool = "global::Vulcan.__WinBool";
        internal const string RuntimeState = "global::Vulcan.Runtime.State";
        internal const string ClipperCallingConvention = "global::Vulcan.Internal.ClipperCallingConventionAttribute";
        internal const string WrappedException = "global::Vulcan.Internal.VulcanWrappedException";
        internal const string DefaultParameter = "global::Vulcan.Internal.DefaultParameterValueAttribute";
        internal const string ActualType = "global::Vulcan.Internal.ActualTypeAttribute";
        internal const string Error = "global::Vulcan.Error";
        internal const string ClassLibrary = "global::Vulcan.Internal.VulcanClassLibraryAttribute";
        internal const string CompilerVersion = "global::Vulcan.Internal.VulcanCompilerVersion";
    }

    internal static class XSharpQualifiedTypeNames
    {
        internal const string Usual = "global::XSharp.__Usual";
        internal const string Float = "global::XSharp.__VOFloat";
        internal const string Date = "global::XSharp.__VODate";
        internal const string Array = "global::XSharp.__Array";
        internal const string Symbol = "global::XSharp.__Symbol";
        internal const string Psz = "global::XSharp.__Psz";
        internal const string Codeblock = "global::XSharp.Codeblock";
        internal const string WinBool = "global::XSharp.__WinBool";
        internal const string RuntimeState = "global::XSharp.Runtime.State";
        internal const string ClipperCallingConvention = "global::XSharp.Internal.ClipperCallingConventionAttribute";
        internal const string WrappedException = "global::XSharp.Internal.WrappedException";
        internal const string DefaultParameter = "global::XSharp.Internal.DefaultParameterValueAttribute";
        internal const string ActualType = "global::XSharp.Internal.ActualTypeAttribute";
        internal const string Error = "global::XSharp.Error";
        internal const string ClassLibrary = "global::XSharp.Internal.ClassLibraryAttribute";
        internal const string CompilerVersion = "global::XSharp.Internal.CompilerVersion";
    }
    internal static class XSharpSpecialNames
    {
        internal const string ImpliedTypeName = "Xs$var";
        internal const string ScriptDummy = "XS$dummy";                      
        internal const string StaticLocalFieldNamePrefix = "Xs$StaticLocal$";
        internal const string StaticLocalInitFieldNameSuffix = "$init";
        internal const string StaticLocalLockFieldNameSuffix = "$lock";
        internal const string EventFieldNamePrefix = "Xs$Event$";
        internal const string AccessSuffix = "$Access";
        internal const string AssignSuffix = "$Assign";

        internal const string DelegateNameSpace = "Xs$Delegates";
        internal const string PCallPrefix = "$PCall";
        internal const string PCallNativePrefix = "$PCallNative";
        internal const string AppInit = "$AppInit";
        internal const string AppExit = "$AppExit";
        internal const string InitProc1 = "$Init1";
        internal const string InitProc2 = "$Init2";
        internal const string InitProc3 = "$Init3";
        internal const string ExitProc = "$Exit";
        internal const string PCallProc = "$PCallGetDelegate";
        internal const string SymbolTable = "Xs$SymbolTable";

        internal const string VoPszList = "Xs$PszList";
        internal const string ClipperArgs = "Xs$Args";
        internal const string RecoverVarName = "Xs$Obj";
        internal const string ExVarName = "Xs$Exception";
        internal const string ReturnName = "Xs$Return";

        internal const string CoreFunctionsClass = XSharpFunctionNames.FunctionsClass;
        internal const string VOExeFunctionsClass = ".Exe.Functions";
        internal const string XSharpCoreFunctionsClass = "Functions";
        internal const string XSharpRDDFunctionsClass = "XSharp.RDD.Functions";
        internal const string XSharpVOFunctionsClass = "XSharp.VO.Functions";
        internal const string VODllFunctionsClass = ".Functions";
        internal const string ModuleName = "<Module>";


    }

    internal static class XSharpFunctionNames
    {
        internal const string StringCompare = "__StringCompare";
        internal const string StringEquals = "__StringEquals";
        internal const string StringSubtract = "StringSubtract";
        internal const string InExactEquals = "__InexactEquals";
        internal const string InExactNotEquals = "__InexactNotEquals";
        internal const string ToObject = "ToObject";
        internal const string IVarGet = "IVarGet";
        internal const string IVarPut = "IVarPut";
        internal const string Send = "__InternalSend";
        internal const string ASend = "ASend";
        internal const string Eval = "Eval";
        internal const string FunctionsClass = "Functions";
        internal const string RunInitProcs = "RunInitProcs";
        internal const string GetElement = "__GetElement";
        internal const string SetElement = "__SetElement";
    }
    internal static class VulcanQualifiedFunctionNames
    {
        internal const string FieldGet = "global::VulcanRTFuncs.Functions.__FieldGet";
        internal const string FieldGetWa = "global::VulcanRTFuncs.Functions.__FieldGetWa";
        internal const string FieldSet = "global::VulcanRTFuncs.Functions.__FieldSet";
        internal const string FieldSetWa = "global::VulcanRTFuncs.Functions.__FieldSetWa";
        internal const string NullDate = "global::Vulcan.__VODate.NullDate";
        internal const string PszRelease = "global::Vulcan.Internal.CompilerServices.String2PszRelease";
        internal const string String2Psz = "global::Vulcan.Internal.CompilerServices.String2Psz";
        internal const string ArrayNew = "global::Vulcan.__Array.__ArrayNew";
        internal const string InStr = "global::VulcanRTFuncs.Functions.Instr";
        internal const string EnterSequence = "global::Vulcan.Internal.CompilerServices.EnterBeginSequence";
        internal const string ExitSequence = "global::Vulcan.Internal.CompilerServices.ExitBeginSequence";
        internal const string WrapException = "global::Vulcan.Error._WrapRawException";
        internal const string QQout = "global::VulcanRTFuncs.Functions.QQOut";
        internal const string Qout = "global::VulcanRTFuncs.Functions.QOut";
        internal const string Chr = "global::VulcanRTFuncs.Functions.Chr";
        internal const string PushWorkarea = "global::VulcanRTFuncs.Functions.__pushWorkarea";
        internal const string PopWorkarea = "global::VulcanRTFuncs.Functions.__popWorkarea";
        internal const string Evaluate = "global::VulcanRTFuncs.Functions.Evaluate";
    }

    internal static class XSharpQualifiedFunctionNames
    {
        internal const string FieldGet = "global::XSharp.Functions.__FieldGet";
        internal const string FieldGetWa = "global::XSharp.Functions.__FieldGetWa";
        internal const string FieldSet = "global::XSharp.Functions.__FieldSet";
        internal const string FieldSetWa = "global::XSharp.Functions.__FieldSetWa";
        internal const string MemVarGet = "global::XSharp.Functions.__MemVarGet";
        internal const string MemVarPut = "global::XSharp.Functions.__MemVarPut";
        internal const string NullDate = "global::XSharp.__VODate.NullDate";
        internal const string PszRelease = "global::XSharp.Internal.CompilerServices.String2PszRelease";
        internal const string String2Psz = "global::XSharp.Internal.CompilerServices.String2Psz";
        internal const string ArrayNew = "global::XSharp.__Array.__ArrayNew";
        internal const string InStr = "global::XSharp.Functions.Instr";
        internal const string EnterSequence = "global::XSharp.Internal.CompilerServices.EnterBeginSequence";
        internal const string ExitSequence = "global::XSharp.Internal.CompilerServices.ExitBeginSequence";
        internal const string WrapException = "global::XSharp.Error._WrapRawException";
        internal const string QQout = "global::XSharp.Functions.QQOut";
        internal const string Qout = "global::XSharp.Functions.QOut";
        internal const string Chr = "global::XSharp.Functions.Chr";
        internal const string PushWorkarea = "global::XSharp.Functions.__pushWorkarea";
        internal const string PopWorkarea = "global::XSharp.Functions.__popWorkarea";
        internal const string Evaluate = "global::XSharp.Functions.Evaluate";
    }

    internal static class OurAssemblyNames
    {
        // please note that these MUST be lowercase !
        internal const string VulcanRT = "vulcanrt";
        internal const string VulcanRTFuncs = "vulcanrtfuncs";
        internal const string XSharpBase = "xsharp.base";
        internal const string XSharpCore = "xsharp.core";
        internal const string XSharpVO = "xsharp.vo";
    }

    internal static class OurNameSpaces
    {
        internal const string Vulcan = "Vulcan";
        internal const string XSharp = "XSharp";
    }

    internal static class SystemQualifiedNames
    {
        internal const string Cdecl = "global::System.Runtime.InteropServices.CallingConvention.Cdecl";
        internal const string ThisCall = "global::System.Runtime.InteropServices.CallingConvention.ThisCall";
        internal const string CompilerGenerated = "global::System.Runtime.CompilerServices.CompilerGenerated";
        internal const string CompilerGlobalScope = "global::System.Runtime.CompilerServices.CompilerGlobalScope";
        internal const string IntPtr = "global::System.IntPtr";
        internal const string DllImport = "global::System.Runtime.InteropServices.DllImportAttribute";
        internal const string CharSet = "global::System.Runtime.InteropServices.CharSet";
        internal const string WriteLine = "global::System.Console.WriteLine";
        internal const string Write = "global::System.Console.Write";
        internal const string Pow = "global::System.Math.Pow";
        internal const string DebuggerBreak = "global::System.Diagnostics.Debugger.Break";
        internal const string Debugger = "global::System.Diagnostics.Debugger";
        internal const string GetHInstance = "global::System.Runtime.InteropServices.Marshal.GetHINSTANCE";
        internal const string Exception = "global::System.Exception";
        internal const string StructLayout = "global::System.Runtime.InteropServices.StructLayout";
        internal const string LayoutExplicit = "global::System.Runtime.InteropServices.LayoutKind.Explicit";
        internal const string LayoutSequential = "global::System.Runtime.InteropServices.LayoutKind.Sequential";
        internal const string FieldOffset = "global::System.Runtime.InteropServices.FieldOffset";
        internal const string GetDelegate = "global::System.Runtime.InteropServices.Marshal.GetDelegateForFunctionPointer";
        internal const string GcCollect = "global::System.Gc.Collect";
        internal const string GcWait = "global::System.Gc.WaitForPendingFinalizers";
        internal const string Void1 = "System.Void";
        internal const string Void2 = "global::System.Void";
        internal const string CollectionsGeneric = "global::System.Collections.Generic";
    }
}
