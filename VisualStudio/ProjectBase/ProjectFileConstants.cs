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

using System.Diagnostics.CodeAnalysis;

namespace Microsoft.VisualStudio.Project
{
    /// <summary>
    /// Defines the constant strings for various msbuild targets
    /// </summary>
    [SuppressMessage("Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "Ms")]
    public static class MsBuildTarget
    {
        public const string ResolveProjectReferences = "ResolveProjectReferences";
        public const string ResolveAssemblyReferences = "ResolveAssemblyReferences";
        public const string ResolveComReferences = "ResolveComReferences";
        public const string Build = "Build";
        public const string Rebuild = "ReBuild";
        public const string Clean = "Clean";
    }

    [SuppressMessage("Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "Ms")]
    public static class MsBuildGeneratedItemType
    {
        public const string ReferenceCopyLocalPaths = "ReferenceCopyLocalPaths";
        public const string ComReferenceWrappers = "ComReferenceWrappers";
    }

    /// <summary>
    /// Defines the constant strings used with project files.
    /// </summary>
    [SuppressMessage("Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "COM")]
    public static class ProjectFileConstants
    {
        public const string Include = "Include";
        public const string Name = "Name";
        public const string HintPath = "HintPath";
        public const string AssemblyName = "AssemblyName";
        public const string FinalOutputPath = "FinalOutputPath";
        public const string Project = "Project";
        public const string LinkedIntoProjectAt = "LinkedIntoProjectAt";
		public const string Link = "Link";
        public const string TypeGuid = "TypeGuid";
        public const string InstanceGuid = "InstanceGuid";
        public const string Private = "Private";
        public const string EmbedInteropTypes = "EmbedInteropTypes";
        public const string ProjectReference = "ProjectReference";
        public const string Reference = "Reference";
        public const string WebPiReference = "WebPiReference";
        public const string WebReference = "WebReference";
        public const string WebReferenceFolder = "WebReferenceFolder";
        public const string Folder = "Folder";
        public const string Content = "Content";
		public const string None = "None";
        public const string EmbeddedResource = "EmbeddedResource";
        public const string RootNamespace = "RootNamespace";
        public const string OutputType = "OutputType";
        [SuppressMessage("Microsoft.Naming", "CA1702:CompoundWordsShouldBeCasedCorrectly", MessageId = "SubType")]
        public const string SubType = "SubType";
        public const string DependentUpon = "DependentUpon";
        public const string Compile = "Compile";
        public const string ReferencePath = "ReferencePath";
        public const string ResolvedProjectReferencePaths = "ResolvedProjectReferencePaths";
        public const string Configuration = "Configuration";
        public const string Platform = "Platform";
        public const string AvailablePlatforms = "AvailablePlatforms";
		public const string AvailableItemName = "AvailableItemName";
        public const string BuildVerbosity = "BuildVerbosity";
        public const string Template = "Template";
        [SuppressMessage("Microsoft.Naming", "CA1702:CompoundWordsShouldBeCasedCorrectly", MessageId = "SubProject")]
        public const string SubProject = "SubProject";
        public const string BuildAction = "BuildAction";
		public const string CopyToOutputDirectory = "CopyToOutputDirectory";
		public const string SpecificVersion = "SpecificVersion";
        [SuppressMessage("Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "COM")]
        public const string COMReference = "COMReference";
        public const string Guid = "Guid";
        public const string VersionMajor = "VersionMajor";
        public const string VersionMinor = "VersionMinor";
        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Lcid")]
        public const string Lcid = "Lcid";
        public const string Isolated = "Isolated";
        public const string WrapperTool = "WrapperTool";
        public const string BuildingInsideVisualStudio = "BuildingInsideVisualStudio";
        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Scc")]
        public const string SccProjectName = "SccProjectName";
        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Scc")]
        public const string SccLocalPath = "SccLocalPath";
        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Scc")]
        public const string SccAuxPath = "SccAuxPath";
        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Scc")]
        public const string SccProvider = "SccProvider";
        public const string ProjectGuid = "ProjectGuid";
        public const string ProjectTypeGuids = "ProjectTypeGuids";
        public const string Generator = "Generator";
        public const string CustomToolNamespace = "CustomToolNamespace";
        public const string FlavorProperties = "FlavorProperties";
        public const string VisualStudio = "VisualStudio";
        public const string User = "User";
		public const string StartURL = "StartURL";
		public const string StartArguments = "StartArguments";
		public const string StartWorkingDirectory = "StartWorkingDirectory";
		public const string StartProgram = "StartProgram";
		public const string StartAction = "StartAction";
		public const string OutputPath = "OutputPath";
		public const string OtherFlags = "OtherFlags";
		public const string PlatformTarget = "PlatformTarget";

        public const string ApplicationDefinition = "ApplicationDefinition";
        public const string Page = "Page";
        public const string Resource = "Resource";
        public const string ApplicationIcon = "ApplicationIcon";
        public const string StartupObject = "StartupObject";
        public const string TargetPlatform = "TargetPlatform";
	    public const string TargetPlatformLocation = "TargetPlatformLocation";
        public const string PlatformAware = "PlatformAware";
        public const string AppxPackage = "AppxPackage";
        public const string WindowsAppContainer = "WindowsAppContainer";
		public const string AllProjectOutputGroups = "AllProjectOutputGroups";
		public const string TargetPath = "TargetPath";
		public const string TargetDir = "TargetDir";
        public const string Aliases = "Aliases";
        public const string CurrentSolutionConfigurationContents = "CurrentSolutionConfigurationContents";

        // XSharp additions
        public const string NativeResource = "NativeResource";
        public const string VOBinary = "VOBinary";
        public const string Settings = "Settings";

    }

    public static class ProjectFileAttributeValue
    {
        public const string Code = "Code";
        public const string Form = "Form";
        public const string Component = "Component";
        public const string Designer = "Designer";
        public const string UserControl = "UserControl";
      	public const string Visible = "Visible";
    }

    internal static class ProjectFileValues
    {
        internal const string AnyCPU = "AnyCPU";
    }

    public enum WrapperToolAttributeValue
    {
        Primary,
        TlbImp,
		AxImp
    }

    /// <summary>
    /// A set of constants that specify the default sort order for different types of hierarchy nodes.
    /// </summary>
    public static class DefaultSortOrderNode
    {
        public const int ProjectProperties = 100;
        public const int NestedProjectNode = 200;
        public const int ReferenceContainerNode = 300;
        public const int FolderNode = 500;
        public const int VOBinaryNode = 750;
        public const int HierarchyNode = 1000;
    }
    public static class XSharpImageListIndex
    {
        public const int Project = 0;
        public const int Source = 1;
        public const int Form = 2;
        public const int Server = 3;
        public const int FieldSpec = 4;
        public const int Menu = 5;
        public const int VO = 6;
        public const int Grid = 7;
        public const int Test = 8;
        public const int Properties = 9;
        public const int Reference = 10;
        public const int DanglingReference = 11;

    }
}
