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
using System.Globalization;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.Shell.Interop;
using VsCommands = Microsoft.VisualStudio.VSConstants.VSStd97CmdID;
using System.Reflection;
namespace Microsoft.VisualStudio.Project
{
    [CLSCompliant(false), ComVisible(true)]
    public class ProjectReferenceNode : ReferenceNode
    {
        #region fields
        /// <summary>
        /// The name of the assembly this refernce represents
        /// </summary>
        private Guid referencedProjectGuid;

		protected string referencedProjectName = String.Empty;

        private string referencedProjectRelativePath = String.Empty;

        private string referencedProjectFullPath = String.Empty;

		private BuildDependency buildDependency = null;

        /// <summary>
        /// This is a reference to the automation object for the referenced project.
        /// </summary>
        private EnvDTE.Project referencedProject;

		/// <summary>
		/// Whether or not the referenced project is ready to be returned.
		/// </summary>
		private bool referencedProjectIsCached = false;

		/// <summary>
		/// This state is controlled by the solution events.
		/// The state is set to false by OnBeforeUnloadProject.
		/// The state is set to true by OnBeforeCloseProject event.
		/// </summary>
		private bool canRemoveReference = true;

        /// <summary>
        /// Possibility for solution listener to update the state on the dangling reference.
        /// It will be set in OnBeforeUnloadProject then the nopde is invalidated then it is reset to false.
        /// </summary>
		private bool isNodeValid = false;
#endregion

#region properties

        public override string Url
        {
            get
            {
                return this.referencedProjectFullPath;
            }
        }

        public override string Caption
        {
            get
            {
				return this.ReferencedProjectName;
            }
        }

        internal Guid ReferencedProjectGuid
        {
            get
            {
                return this.referencedProjectGuid;
            }
        }

        /// <summary>
        /// Possiblity to shortcut and set the dangling project reference icon.
        /// It is ussually manipulated by solution listsneres who handle reference updates.
        /// </summary>
        internal protected bool IsNodeValid
        {
            get
            {
                return this.isNodeValid;
            }
            set
            {
                this.isNodeValid = value;
            }
        }

        /// <summary>
        /// Controls the state whether this reference can be removed or not. Think of the project unload scenario where the project reference should not be deleted.
        /// </summary>
        internal bool CanRemoveReference
        {
            get
            {
                return this.canRemoveReference;
            }
            set
            {
                this.canRemoveReference = value;
            }
        }

		internal virtual string ReferencedProjectName
		{
			get
			{
				return this.referencedProjectName;
			}
			set
			{
                this.referencedProjectName = value;

                string currentName = this.ItemNode.GetMetadata(ProjectFileConstants.Name);
                if (!String.Equals(currentName, this.referencedProjectName, StringComparison.Ordinal))
                {
                    this.ItemNode.SetMetadata(ProjectFileConstants.Name, this.referencedProjectName);
                    this.ReDraw(UIHierarchyElement.Caption);
                }
            }
        }

		/// <summary>
		/// Searches the solution or project for a contained project with a given path.
		/// </summary>
		/// <param name="project">Project node to start the search from, or null to search the solution.</param>
		/// <param name="projectFilePath">Path of the project to be located.</param>
		/// <returns>Found project object, or null if the project was not found.</returns>
		private bool InitReferencedProjectFromProjectItems(System.Collections.IEnumerable /* of project or project items */ inners)
		{
			foreach (object obj in inners)
			{
				EnvDTE.Project prj = obj as EnvDTE.Project;
				if (prj == null)
				{
					EnvDTE.ProjectItem pi = obj as EnvDTE.ProjectItem;
					if (pi == null) continue;
					prj = pi.SubProject;
				}
				if (prj == null) continue;

				if (string.Compare(EnvDTE.Constants.vsProjectKindSolutionItems, prj.Kind, StringComparison.OrdinalIgnoreCase) == 0)
				{
					if (InitReferencedProjectFromProjectItems(prj.ProjectItems))
						return true;
					else
						continue;
				}

				//Skip this project if it is an unmodeled project (unloaded)
				if (string.Compare(EnvDTE.Constants.vsProjectKindUnmodeled, prj.Kind, StringComparison.OrdinalIgnoreCase) == 0)
				{
					continue;
				}

				// Skip if has no properties (e.g. "miscellaneous files")
				if (prj.Properties == null)
				{
					continue;
				}

                string prjPath = prj.FullName;

				// If the full path of this project is the same as the one of this
				// reference, then we have found the right project.
				if (NativeMethods.IsSamePath(prjPath, referencedProjectFullPath))
				{
					this.referencedProject = prj;
					return true;
				}
			}
			return false;
		}
        /// Gets the automation object for the referenced project.
        /// </summary>
        internal EnvDTE.Project ReferencedProjectObject
        {
            get
            {
				if (!this.referencedProjectIsCached)
				{

                    // Search for the project in the collection of the projects in the
                    // current solution.
                    EnvDTE.DTE dte = (EnvDTE.DTE)this.ProjectMgr.GetService(typeof(EnvDTE.DTE));
					if ((null == dte) || (null == dte.Solution))
					{
						return null;
					}
					InitReferencedProjectFromProjectItems(dte.Solution.Projects);
                    // this may fail if the project is not loaded yet. We want to try
                    // again later so do not set the IsCached flag !
                    if (referencedProject != null)
                    {
                        this.referencedProjectIsCached = true;
                    }
                }

                return this.referencedProject;
			}
		}

		/// <summary>
		/// Invalidates the referenced project cache.
		/// </summary>
		public void DropReferencedProjectCache()
		{
			referencedProjectIsCached = false;
		}


        EnvDTE.Property  GetPropertySave(string name, bool onConfig)
        {
            EnvDTE.Property property = null;
            EnvDTE.Properties props = null;
            try
            {

                if (onConfig)
                {
                    EnvDTE.ConfigurationManager confManager = this.ReferencedProjectObject.ConfigurationManager;
                    if (null != confManager)
                    {
                        // Get the active configuration.
                        EnvDTE.Configuration config = confManager.ActiveConfiguration;
                        if (null != config)
                        {
                            // Get the output path for the current configuration.
                            var obj = config.Properties;
                            EnvDTE.Properties props1 = obj;
                            if (null != props1)
                            {
                                property = props1.Item(name);
                            }
                        }
                    }
                }
                else
                {
                    // Most project types should implement the OutputPath property on their
                    // configuration-dependent Properties object above. But if it wasn't found
                    // there, check the project node Properties.
                    props = this.ReferencedProjectObject.Properties;
                    if (null != props)
                    {
                        property = props.Item(name);
                    }
                }
            }
            catch (COMException)
            {
            }
            catch (ArgumentException)
            {
            }
            return property;
        }

        /// <summary>
        /// Gets the full path to the assembly generated by this project.
        /// </summary>
        internal string ReferencedProjectOutputPath
        {
            get
            {
                // Make sure that the referenced project implements the automation object.
                if(null == this.ReferencedProjectObject)
                {
                    return null;
                }

                EnvDTE.Property outputPathProperty = GetPropertySave("OutputPath", true);

				if (outputPathProperty == null || outputPathProperty.Value == null)
				{
                    // Most project types should implement the OutputPath property on their
                    // configuration-dependent Properties object above. But if it wasn't found
                    // there, check the project node Properties.
                    outputPathProperty = GetPropertySave("OutputPath", false);
				}

                if(null == outputPathProperty || outputPathProperty.Value == null)
                {
                    return null;
                }

                string outputPath = outputPathProperty.Value.ToString();

                // Usually the output path is relative to the project path, but it is possible
                // to set it as an absolute path. If it is not absolute, then evaluate its value
                // based on the project directory.
                if(!System.IO.Path.IsPathRooted(outputPath))
                {
                    string projectDir = System.IO.Path.GetDirectoryName(referencedProjectFullPath);
                    outputPath = System.IO.Path.Combine(projectDir, outputPath);
                }

                // Now get the name of the assembly from the project.
                // Some project system throw if the property does not exist. We expect an ArgumentException.
                EnvDTE.Property assemblyNameProperty = null;
                assemblyNameProperty = this.GetPropertySave("OutputFileName",false);
                if(null == assemblyNameProperty || null == assemblyNameProperty.Value)
                {
                    assemblyNameProperty = this.GetPropertySave("AssemblyName", false);
                }
                if (null == assemblyNameProperty || null == assemblyNameProperty.Value)
                {
                    return null;
                }
                outputPath = System.IO.Path.Combine(outputPath, assemblyNameProperty.Value.ToString());
                if (!outputPath.EndsWith(".dll", StringComparison.OrdinalIgnoreCase) && !outputPath.EndsWith(".exe", StringComparison.OrdinalIgnoreCase))
                    outputPath += ".dll";
                return outputPath;
            }
        }

        private Automation.OAProjectReference projectReference;
        internal override object Object
        {
            get
            {
                if(null == projectReference)
                {
                    projectReference = new Automation.OAProjectReference(this);
                }
                return projectReference;
            }
        }
#endregion

#region ctors
        /// <summary>
        /// Constructor for the ReferenceNode. It is called when the project is reloaded, when the project element representing the refernce exists.
        /// </summary>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2234:PassSystemUriObjectsInsteadOfStrings")]
        public ProjectReferenceNode(ProjectNode root, ProjectElement element)
            : base(root, element)
        {
            this.referencedProjectRelativePath = this.ItemNode.GetMetadata(ProjectFileConstants.Include);
            Debug.Assert(!String.IsNullOrEmpty(this.referencedProjectRelativePath), "Could not retrive referenced project path form project file");

            string guidString = this.ItemNode.GetMetadata(ProjectFileConstants.Project);
            this.ReferencedProjectName = this.ItemNode.GetMetadata(ProjectFileConstants.Name);
            if (guidString == String.Empty)
            {
                // find guid in solution ?
            }

            // Continue even if project settings cannot be read.
            try
            {
                this.referencedProjectGuid = new Guid(guidString);

                this.buildDependency = new BuildDependency(this.ProjectMgr, this.referencedProjectGuid);
                this.ProjectMgr.AddBuildDependency(this.buildDependency);
            }
            finally
            {
                //Debug.Assert(this.referencedProjectGuid != Guid.Empty, "Could not retrieve referenced project guidproject file");

				this.ReferencedProjectName = this.ItemNode.GetMetadata(ProjectFileConstants.Name);

                //Debug.Assert(!String.IsNullOrEmpty(this.referencedProjectName), "Could not retrieve referenced project name form project file");
            }

            Uri uri = new Uri(this.ProjectMgr.BaseURI.Uri, this.referencedProjectRelativePath);

            if(uri != null)
            {
                this.referencedProjectFullPath = Microsoft.VisualStudio.Shell.Url.Unescape(uri.LocalPath, true);
            }
        }

        /// <summary>
        /// constructor for the ProjectReferenceNode
        /// </summary>
        internal ProjectReferenceNode(ProjectNode root, string referencedProjectName, string projectPath, string projectReference)
            : base(root)
        {
            Debug.Assert(root != null && !String.IsNullOrEmpty(referencedProjectName) && !String.IsNullOrEmpty(projectReference)
                && !String.IsNullOrEmpty(projectPath), "Can not add a reference because the input for adding one is invalid.");

            if (projectReference == null)
            {
                throw new ArgumentNullException("projectReference");
            }

			this.ReferencedProjectName = referencedProjectName;

            int indexOfSeparator = projectReference.IndexOf('|');


            string fileName = String.Empty;

            // Unfortunately we cannot use the path part of the projectReference string since it is not resolving correctly relative pathes.
            if(indexOfSeparator != -1)
            {
                string projectGuid = projectReference.Substring(0, indexOfSeparator);
                this.referencedProjectGuid = new Guid(projectGuid);
                if(indexOfSeparator + 1 < projectReference.Length)
                {
                    string remaining = projectReference.Substring(indexOfSeparator + 1);
                    indexOfSeparator = remaining.IndexOf('|');

                    if(indexOfSeparator == -1)
                    {
                        fileName = remaining;
                    }
                    else
                    {
                        fileName = remaining.Substring(0, indexOfSeparator);
                    }
                }
            }

            Debug.Assert(!String.IsNullOrEmpty(fileName), "Can not add a project reference because the input for adding one is invalid.");

            // Did we get just a file or a relative path?
            Uri uri = new Uri(projectPath);

            string referenceDir = PackageUtilities.GetPathDistance(this.ProjectMgr.BaseURI.Uri, uri);

            Debug.Assert(!String.IsNullOrEmpty(referenceDir), "Can not add a project reference because the input for adding one is invalid.");

            string justTheFileName = Path.GetFileName(fileName);
            this.referencedProjectRelativePath = Path.Combine(referenceDir, justTheFileName);

            this.referencedProjectFullPath = Path.Combine(projectPath, justTheFileName);

            this.buildDependency = new BuildDependency(this.ProjectMgr, this.referencedProjectGuid);

        }

        protected override void Dispose(bool disposing)
        {
            try
            {
                if (this.projectReference != null)
                {
                    this.projectReference.Dispose();
                }
            }
            finally
            {
                this.projectReference = null;
                base.Dispose(disposing);
            }
        }
        #endregion

        #region methods
        protected override NodeProperties CreatePropertiesObject()
        {
            return new ProjectReferencesProperties(this);
        }

        /// <summary>
        /// The node is added to the hierarchy and then updates the build dependency list.
        /// </summary>
        public override ReferenceNode AddReference()
		{
			if(this.ProjectMgr == null)
			{
				return null;
			}
			ReferenceNode node = base.AddReference();
			this.ProjectMgr.AddBuildDependency(this.buildDependency);
			return node;
		}

        /// <summary>
        /// Overridden method. The method updates the build dependency list before removing the node from the hierarchy.
        /// </summary>
        public override void Remove(bool removeFromStorage)
        {
            if(this.ProjectMgr == null || !this.CanRemoveReference)
            {
                return;
            }
            this.ProjectMgr.RemoveBuildDependency(this.buildDependency);
            base.Remove(removeFromStorage);

            return;
        }

        /// <summary>
        /// Links a reference node to the project file.
        /// </summary>
        protected override void BindReferenceData()
        {
            Debug.Assert(!String.IsNullOrEmpty(this.referencedProjectName), "The referencedProjectName field has not been initialized");
            Debug.Assert(this.referencedProjectGuid != Guid.Empty, "The referencedProjectName field has not been initialized");

            this.ItemNode = new ProjectElement(this.ProjectMgr, this.referencedProjectRelativePath, ProjectFileConstants.ProjectReference);

            this.ItemNode.SetMetadata(ProjectFileConstants.Name, this.referencedProjectName);
            this.ItemNode.SetMetadata(ProjectFileConstants.Project, this.referencedProjectGuid.ToString("B"));
            this.ItemNode.SetMetadata(ProjectFileConstants.Private, true.ToString());
        }

        /// <summary>
        /// Defines whether this node is valid node for painting the refererence icon.
        /// </summary>
        /// <returns></returns>
        protected override bool CanShowDefaultIcon()
        {
            if(this.referencedProjectGuid == Guid.Empty || this.ProjectMgr == null || this.ProjectMgr.IsClosed || this.isNodeValid)
            {
                return false;
            }

            IVsHierarchy hierarchy = null;

            hierarchy = VsShellUtilities.GetHierarchy(this.ProjectMgr.Site, this.referencedProjectGuid);

            if(hierarchy == null)
            {
                return false;
            }

            //If the Project is unloaded return false
            if(this.ReferencedProjectObject == null)
            {
                return false;
            }

            return (!String.IsNullOrEmpty(this.referencedProjectFullPath) && File.Exists(this.referencedProjectFullPath));
        }

        /// <summary>
        /// Checks if a project reference can be added to the hierarchy. It calls base to see if the reference is not already there, then checks for circular references.
        /// </summary>
        /// <param name="errorHandler">The error handler delegate to return</param>
        /// <returns></returns>
        protected override bool CanAddReference(out CannotAddReferenceErrorMessage errorHandler)
        {
            // When this method is called this refererence has not yet been added to the hierarchy, only instantiated.
            if(!base.CanAddReference(out errorHandler))
            {
                return false;
            }

            errorHandler = null;
            if(this.IsThisProjectReferenceInCycle())
            {
                errorHandler = new CannotAddReferenceErrorMessage(ShowCircularReferenceErrorMessage);
                return false;
            }

            return true;
        }
		protected override bool CanAddReference(out CannotAddReferenceErrorMessage errorHandler, out ReferenceNode existingNode )
		{
			// When this method is called this refererence has not yet been added to the hierarchy, only instantiated.
			if(!base.CanAddReference(out errorHandler, out existingNode ))
			{
				return false;
			}

			errorHandler = null;
			if(this.IsThisProjectReferenceInCycle())
			{
				errorHandler = new CannotAddReferenceErrorMessage(ShowCircularReferenceErrorMessage);
				return false;
			}

			return true;
		}

        private bool IsThisProjectReferenceInCycle()
        {
            return IsReferenceInCycle(this.referencedProjectGuid);
        }

        private void ShowCircularReferenceErrorMessage()
        {
            string message = String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.ProjectContainsCircularReferences, CultureInfo.CurrentUICulture), this.referencedProjectName);
			ShowReferenceErrorMessage(message);
        }

        /// <summary>
        /// Checks whether a reference added to a given project would introduce a circular dependency.
        /// </summary>
        private bool IsReferenceInCycle(Guid projectGuid)
        {
            IVsHierarchy referencedHierarchy = VsShellUtilities.GetHierarchy(this.ProjectMgr.Site, projectGuid);

            var solutionBuildManager = this.ProjectMgr.Site.GetService(typeof(SVsSolutionBuildManager)) as IVsSolutionBuildManager2;
            if (solutionBuildManager == null)
            {
                throw new InvalidOperationException("Cannot find the IVsSolutionBuildManager2 service.");
            }

            int circular;
            Marshal.ThrowExceptionForHR(solutionBuildManager.CalculateProjectDependencies());
            Marshal.ThrowExceptionForHR(solutionBuildManager.QueryProjectDependency(referencedHierarchy, this.ProjectMgr , out circular));

            return circular != 0;
        }
		protected override int QueryStatusOnNode(Guid cmdGroup, uint cmd, IntPtr pCmdText, ref QueryStatusResult result)
		{
			if (cmdGroup == VsMenus.guidStandardCommandSet97)
			{
				switch ((VsCommands)cmd)
				{
					case VsCommands.Rename:
						result |= QueryStatusResult.SUPPORTED | QueryStatusResult.ENABLED;
						return VSConstants.S_OK;
				}
			}

			return base.QueryStatusOnNode(cmdGroup, cmd, pCmdText, ref result);
		}

		/// <summary>
		/// Called by the shell to get the node caption when the user tries to rename from the GUI
		/// </summary>
		/// <returns>the node cation</returns>
		/// <remarks>Overridden to allow editing of project reference nodes.</remarks>
		public override string GetEditLabel()
		{
			return this.Caption;
		}

		/// <summary>
		/// Called by the shell when a node has been renamed from the GUI
		/// </summary>
		/// <param name="label"></param>
		/// <returns>E_NOTIMPL</returns>
		public override int SetEditLabel(string label)
		{
			HierarchyNode thisParentNode = this.Parent;
			this.ReferencedProjectName = label;
			this.OnInvalidateItems(thisParentNode);

			// select the reference node again
			IVsUIHierarchyWindow uiWindow = UIHierarchyUtilities.GetUIHierarchyWindow(this.ProjectMgr.Site, SolutionExplorer);
			uiWindow.ExpandItem(this.ProjectMgr, this.ID, EXPANDFLAGS.EXPF_SelectItem);

			return VSConstants.S_OK;
		}
#endregion
    }

}
