﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//

using Microsoft.VisualStudio.ProjectSystem.VS.Properties;
using System;

namespace XSharp.VisualStudio.ProjectSystem
{
    /// <summary>
    ///     Concrete implementation of <see cref="IPageMetadata"/>.
    /// </summary>
    internal class ProjectDesignerPageMetadata : IPageMetadata
    {
        public ProjectDesignerPageMetadata(Guid pageGuid, int pageOrder, bool hasConfigurationCondition)
        {
            if (pageGuid == Guid.Empty)
                throw new ArgumentException(null, nameof(pageGuid));

            PageGuid = pageGuid;
            PageOrder = pageOrder;
            HasConfigurationCondition = hasConfigurationCondition;
        }

        // TODO remove suppression once CPS annotation corrected
#pragma warning disable CS8613 // Nullability of reference types in return type doesn't match implicitly implemented member.
        public string Name => null;
#pragma warning restore CS8613 // Nullability of reference types in return type doesn't match implicitly implemented member.

        public bool HasConfigurationCondition { get; }

        public Guid PageGuid { get; }

        public int PageOrder { get; }
    }
}
