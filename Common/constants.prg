//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
#include "buildnumber.h"
BEGIN NAMESPACE XSharp

    STATIC INTERNAL CLASS Constants 
    
        INTERNAL CONST Company              := COMPANY_NAME			    AS STRING
        INTERNAL CONST RegCompany           := REG_COMPANY_NAME		    AS STRING
        INTERNAL CONST Product              := PRODUCT				    AS STRING
        INTERNAL CONST ProductName          := PRODUCT_NAME			    AS STRING
        INTERNAL CONST Version              := VERSION_NUMBER_STR		AS STRING
        INTERNAL CONST FileVersion          := FILEVERSION_NUMBER_STR	AS STRING
        INTERNAL CONST InformationalVersion := INFORMATIONAL_NUMBER_STR	AS STRING
        INTERNAL CONST Copyright            := COPYRIGHT_STR			AS STRING
        
        INTERNAL CONST RegistryKey := "Software\" + RegCompany + "\" + Product			AS STRING
        INTERNAL CONST RegistryKey64 := "Software\WOW6432Node\" + RegCompany + "\" + Product AS STRING
        INTERNAL CONST RegistryValue := "XSharpPath"											AS STRING
    END CLASS
    
END NAMESPACE    
