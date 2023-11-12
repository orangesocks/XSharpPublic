﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
using System.Reflection
using System.Runtime.CompilerServices
//
// General Information about an assembly is controlled through the following
// set of attributes. Change these attribute values to modify the information
// associated with an assembly.
//
#ifndef NETNEXT
[assembly: AssemblyTitle("XSharp.RT")]
#endif
[assembly: AssemblyDescription("XSharp runtime DLL with xBase types and functions for all dialects")]
[assembly: ImplicitNamespace("XSharp")]

[assembly: InternalsVisibleTo("XSharp.XPP,"+Constants.PUBLICKEY)]
[assembly: InternalsVisibleTo("XSharp.VO,"+Constants.PUBLICKEY)]
[assembly: InternalsVisibleTo("XSharp.VFP,"+Constants.PUBLICKEY)]
