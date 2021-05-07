﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
namespace XSharp
{
    internal static class Constants
    {
        internal const string LanguageName = "XSharp";
        internal const string Company = "XSharp BV";
        internal const string RegCompany = "XSharpBV";
        internal const string ProductName = "XSharp Cahors";
        internal const string Product = "XSharp";
        // NOTE: DO NOT FORGET THE VERSION NUMBER IN THE BUILDNUMBER.H FILE
#if RUNTIME
        internal const string Version = "2.6.0.0";
#else
        internal const string Version = "2.8.0.0";
#endif
        internal const string FileVersion = "2.8.0.11";
        internal const string ProductVersion = "2.8 GA";
        internal const string PublicKey = "ed555a0467764586";
        internal const string Copyright = "Copyright © XSharp BV 2015-2021";

        internal const string RegistryKey = @"Software\" + RegCompany + @"\" + Product;
        internal const string RegistryKey64 = @"Software\WOW6432Node\" + RegCompany + @"\" + Product;
        internal const string RegistryValue = "XSharpPath";

        // Environment variable that points to the BIN folder where xsc.exe AND rc.exe are located
        internal const string EnvironmentXSharpBin = "XSHARPBINPATH";
        internal const string EnvironmentXSharp = "XSHARPPATH";
        // Environment variable on _developers_ machine to override location of xsc.exe. 
        // This also enables the "magic" button on the tools-options dialog
        // and adds CRLF to the response file between the various commands to make it easier to read.
        internal const string EnvironmentXSharpDev = "XSHARPDEV";       

    }
}
