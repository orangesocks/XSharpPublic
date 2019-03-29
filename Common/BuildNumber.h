// BuildNumber.h
#ifndef BUILDNUMBER_H
    #define BUILDNUMBER_H
    #define PRODUCT_NAME     "XSharp Bandol Beta 9"
    #define PRODUCT			 "XSharp"
    #define COPYRIGHT_STR    "Copyright (c) XSharp BV 2015-2019."
    #define COMPANY_NAME     "XSharp BV"
    #define REG_COMPANY_NAME  "XSharpBV"

    // This is used for the assembly version number, which the CLR uses to determine binding
    // This generally changes when we release a new full build
    // NOTE: DO NOT FORGET THE VERSION NUMBER IN THE CONSTANTS.CS FILE
    #define VERSION_NUMBER_STR     "2.0.0.9"
    #define VERSION_NUMBER			2,0,0,9

    // This is the file version number, which is ignored by .NET but used by Windows installer to determine
    // whether one file is newer than another.
    // This typically would change if we're generating a patch, otherwise it should be the same as VERSION_NUMBER
    #ifndef FILEVERSION_NUMBER
        #define FILEVERSION_NUMBER       VERSION_NUMBER
        #define FILEVERSION_NUMBER_STR   VERSION_NUMBER_STR
    #endif
    #ifdef __DEBUG__
        #define ASSEMBLY_CONFIGURATION "Debug"
    #else
        #define ASSEMBLY_CONFIGURATION "Release"
    #endif
    #define XSHARP_CORE_FUNCTIONS "XSharp.Core.Functions"
#endif


