// BuildNumber.h
#ifndef BUILDNUMBER_H
    #define BUILDNUMBER_H
    #define PRODUCT_NAME     "XSharp Bandol RC 3"
    #define PRODUCT			 "XSharp"
    #define COPYRIGHT_STR    "Copyright (c) XSharp BV 2015-2019."
    #define COMPANY_NAME     "XSharp BV"
    #define REG_COMPANY_NAME  "XSharpBV"

    // NOTE: DO NOT FORGET THE VERSION NUMBER IN THE CONSTANTS.CS FILE
    #define VERSION_NUMBER_STR     "2.0.3.0"
    #define VERSION_NUMBER			2,0,3,0
    #define FILEVERSION_NUMBER       2,0,3,0
    #define FILEVERSION_NUMBER_STR   "2.0.3.0"
    #define INFORMATIONAL_NUMBER_STR  "2.0 RC 3"

    #ifdef __DEBUG__
        #define ASSEMBLY_CONFIGURATION "Debug"
    #else
        #define ASSEMBLY_CONFIGURATION "Release"
    #endif
#endif


