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

using System;
using System.Diagnostics;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.Shell.Interop;
using IOleServiceProvider = Microsoft.VisualStudio.OLE.Interop.IServiceProvider;

namespace Microsoft.VisualStudio.Project
{
    class ProjectDesignerDocumentManager : DocumentManager
    {
        #region ctors
        public ProjectDesignerDocumentManager(ProjectNode node)
            : base(node)
        {
        }
        #endregion

        #region overriden methods

        public override int Open(ref Guid logicalView, IntPtr docDataExisting, out IVsWindowFrame windowFrame, WindowFrameShowAction windowFrameAction)
        {
            ThreadHelper.ThrowIfNotOnUIThread();
            Guid editorGuid = VSConstants.GUID_ProjectDesignerEditor;
            return this.OpenWithSpecific(0, ref editorGuid, String.Empty, ref logicalView, docDataExisting, out windowFrame, windowFrameAction);
        }

        public override int OpenWithSpecific(uint editorFlags, ref Guid editorType, string physicalView, ref Guid logicalView, IntPtr docDataExisting, out IVsWindowFrame frame, WindowFrameShowAction windowFrameAction)
        {
            frame = null;
            ThreadHelper.ThrowIfNotOnUIThread();
            Debug.Assert(editorType == VSConstants.GUID_ProjectDesignerEditor, "Cannot open project designer with guid " + editorType.ToString());


            if(this.Node == null || this.Node.ProjectMgr == null || this.Node.ProjectMgr.IsClosed)
            {
                return VSConstants.E_FAIL;
            }

            IVsUIShellOpenDocument uiShellOpenDocument = this.Node.ProjectMgr.Site.GetService(typeof(SVsUIShellOpenDocument)) as IVsUIShellOpenDocument;
            IOleServiceProvider serviceProvider = this.Node.ProjectMgr.Site.GetService(typeof(IOleServiceProvider)) as IOleServiceProvider;
            ThreadHelper.ThrowIfNotOnUIThread();

            if (serviceProvider != null && uiShellOpenDocument != null)
            {
                string fullPath = this.GetFullPathForDocument();
                string caption = this.GetOwnerCaption();

                IVsUIHierarchy parentHierarchy = this.Node.ProjectMgr.GetProperty((int)__VSHPROPID.VSHPROPID_ParentHierarchy) as IVsUIHierarchy;
                IntPtr parentHierarchyItemId;
                unchecked
                {
                    parentHierarchyItemId = (IntPtr)this.Node.ProjectMgr.GetProperty((int)__VSHPROPID.VSHPROPID_ParentHierarchyItemid);
                }
				ErrorHandler.ThrowOnFailure(uiShellOpenDocument.OpenSpecificEditor(editorFlags, fullPath, ref editorType, physicalView, ref logicalView, caption, parentHierarchy, (uint)(parentHierarchyItemId.ToInt32()), docDataExisting, serviceProvider, out frame));

                if(frame != null)
                {
                    if(windowFrameAction == WindowFrameShowAction.Show)
                    {
                        ErrorHandler.ThrowOnFailure(frame.Show());
                    }
                }
            }

            return VSConstants.S_OK;
        }
        #endregion

    }
}
