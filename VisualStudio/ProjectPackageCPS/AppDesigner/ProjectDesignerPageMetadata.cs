﻿// Licensed to the .NET Foundation under one or more agreements. The .NET Foundation licenses this file to you under the MIT license. See the LICENSE.md file in the project root for more information.

using Microsoft.VisualStudio.ProjectSystem.VS.Properties;
using System;

namespace XSharp.ProjectSystem
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
