/* ****************************************************************************
 *
 * Copyright (c) Microsoft Corporation.
 *
 * This source code is subject to terms and conditions of the Apache License, Version 2.0. A
 * copy of the license can be found in the License.txt file at the root of this distribution.
 *
 * You must not remove this notice, or any other, from this software.
 *
 * ***************************************************************************/

using Microsoft.VisualStudio.Shell;
using System;
using System.Diagnostics.CodeAnalysis;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using VSLangProj;

namespace Microsoft.VisualStudio.Project.Automation
{
    [SuppressMessage("Microsoft.Interoperability", "CA1405:ComVisibleTypeBaseTypesShouldBeComVisible")]
    [CLSCompliant(false), ComVisible(true)]
    public class OAAssemblyReference : OAReferenceBase<AssemblyReferenceNode>
    {
        public OAAssemblyReference(AssemblyReferenceNode assemblyReference) :
            base(assemblyReference)
        {
        }

        #region Reference override
        public override int BuildNumber
        {
            get
            {
                if((null == BaseReferenceNode.ResolvedAssembly) ||
                    (null == BaseReferenceNode.ResolvedAssembly.Version))
                {
                    return 0;
                }
                return BaseReferenceNode.ResolvedAssembly.Version.Build;
            }
        }
        public override bool CopyLocal
        {
            get
            {
                return ThreadHelper.JoinableTaskFactory.Run(async delegate
                {
                    await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();
                    var props = this.BaseReferenceNode.NodeProperties as ReferenceNodeProperties;
                    if (props != null)
                        return props.CopyToLocal;
                    return false;
                });
            }
        }
        public override string Culture
        {
            get
            {
                if((null == BaseReferenceNode.ResolvedAssembly) ||
                    (null == BaseReferenceNode.ResolvedAssembly.CultureInfo))
                {
                    return string.Empty;
                }
                return BaseReferenceNode.ResolvedAssembly.CultureInfo.Name;
            }
        }
        public override string Identity
        {
            get
            {
                // Note that in this function we use the assembly name instead of the resolved one
                // because the identity of this reference is the assembly name needed by the project,
                // not the specific instance found in this machine / environment.
                if(null == BaseReferenceNode.AssemblyName)
                {
                    return null;
                }
                // changed from MPFProj, http://mpfproj10.codeplex.com/workitem/11274
                return BaseReferenceNode.AssemblyName.Name;
            }
        }
        public override int MajorVersion
        {
            get
            {
                if((null == BaseReferenceNode.ResolvedAssembly) ||
                    (null == BaseReferenceNode.ResolvedAssembly.Version))
                {
                    return 0;
                }
                return BaseReferenceNode.ResolvedAssembly.Version.Major;
            }
        }
        public override int MinorVersion
        {
            get
            {
                if((null == BaseReferenceNode.ResolvedAssembly) ||
                    (null == BaseReferenceNode.ResolvedAssembly.Version))
                {
                    return 0;
                }
                return BaseReferenceNode.ResolvedAssembly.Version.Minor;
            }
        }

        public override string PublicKeyToken
        {
            get
            {
                if((null == BaseReferenceNode.ResolvedAssembly) ||
                (null == BaseReferenceNode.ResolvedAssembly.GetPublicKeyToken()))
                {
                    return null;
                }
                StringBuilder builder = new StringBuilder();
                byte[] publicKeyToken = BaseReferenceNode.ResolvedAssembly.GetPublicKeyToken();
                for(int i = 0; i < publicKeyToken.Length; i++)
				{
                    // changed from MPFProj:
                    // http://mpfproj10.codeplex.com/WorkItem/View.aspx?WorkItemId=8257
                    builder.AppendFormat("{0:x2}", publicKeyToken[i]);
                }
                return builder.ToString();
            }
        }

        public override string Name
        {
            get
            {
                if(null != BaseReferenceNode.ResolvedAssembly)
                {
                    return BaseReferenceNode.ResolvedAssembly.Name;
                }
                if(null != BaseReferenceNode.AssemblyName)
                {
                    return BaseReferenceNode.AssemblyName.Name;
                }
                return BaseReferenceNode.Caption;
            }
        }
        public override int RevisionNumber
        {
            get
            {
                if((null == BaseReferenceNode.ResolvedAssembly) ||
                    (null == BaseReferenceNode.ResolvedAssembly.Version))
                {
                    return 0;
                }
                return BaseReferenceNode.ResolvedAssembly.Version.Revision;
            }
        }
        public override bool StrongName
        {
            get
            {
                if((null == BaseReferenceNode.ResolvedAssembly) ||
                    (0 == (BaseReferenceNode.ResolvedAssembly.Flags & AssemblyNameFlags.PublicKey)))
                {
                    return false;
                }
                return true;
            }
        }
        public override prjReferenceType Type
        {
            get
            {
                return prjReferenceType.prjReferenceTypeAssembly;
            }
        }
        public override string Version
        {
            get
            {
                if((null == BaseReferenceNode.ResolvedAssembly) ||
                    (null == BaseReferenceNode.ResolvedAssembly.Version))
                {
                    return string.Empty;
                }
                return BaseReferenceNode.ResolvedAssembly.Version.ToString();
            }
        }

        public override bool SpecificVersion
        {
            get
            {
                var data = this.BaseReferenceNode.ItemNode.GetMetadata(nameof(SpecificVersion));
                if (String.IsNullOrEmpty(data))
                    return false;
                return string.Compare(data, "True", true) == 0;

            }
        }
        public override string RuntimeVersion
        {
            get
            {
                var asm = BaseReferenceNode as AssemblyReferenceNode;
                return asm.GetMsBuildProperty("imageruntime");
            }
        }
        public override string Aliases
        {
            get
            {
                var asm = BaseReferenceNode as AssemblyReferenceNode;
                return asm.GetMsBuildProperty("Aliases");
            }
        }

        #endregion
    }
}
