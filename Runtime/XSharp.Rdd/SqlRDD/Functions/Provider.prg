﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//

USING XSharp.RDD.SqlRDD

/// <summary>
/// Set the default SqlDbProvider to use for the SqlDb Connections. The default SQLDbProvider is ODBC
/// </summary>
/// <param name="ProvideName">Name of the provider to use. This is case insensitive
/// Built in providers are:
/// <list type = "bullet">
/// <item><term>SQLServer</term></item>
/// <item><term>MySql</term></item>
/// <item><term>ODBC</term></item>
/// <item><term>OLEDB</term></item>
/// <item><term>SQLite</term></item>
/// </list>
/// </param>
/// <returns>TRUE when a provider was found matching the name.</returns>
/// <include file="SqlDbExamples.xml" path="doc/NorthWind1/*" />
FUNCTION SqlDbSetProvider(ProviderName as STRING) AS LOGIC
    SqlDbProvider.SetDefaultProvider(ProviderName)
    RETURN SqlDbProvider.Current != null


/// <summary>
/// Retrieve the default SqlDbProvider object
/// </summary>
/// <returns>The SqlDbProvider object or NULL when the ProviderName has not been registered.</returns>
FUNCTION SqlDbGetProvider() AS SqlDbProvider
    RETURN SqlDbProvider.Current


/// <summary>
/// Register a Custom SqlDbProvider with the SqlRDD system
/// </summary>
/// <param name="ProviderName">Name to use for the provider. </param>
/// <param name="ClassName">Fully qualified classname that implements the provider.
/// This class needs to inherit from the SqlDbProvider class
/// </param>
/// <returns></returns>
FUNCTION SqlDbRegisterProvider(ProviderName as string, ClassName as STRING) AS LOGIC
    RETURN FALSE


