﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Runtime.Versioning;
using System.Windows.Forms;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.Shell.Interop;
using Microsoft.VisualStudio.Project;
using EnvDTE;
using EnvDTE80;
using System.ComponentModel;
using Microsoft.VisualStudio.OLE.Interop;

namespace XSharp.Project
{
    /// <summary>
    /// This class implements dialect property page for the project type.
    /// </summary>
    [ComVisible(true)]
    [Guid("2652FCA6-1C45-4D25-942D-4C5D5EDE9539")]
    [ClassInterface(ClassInterfaceType.AutoDual)]
    public class XSharpDialectPropertyPage : XSharpSettingsPage
    {
        #region Constants
        internal const string DialectCaption = "Dialect";
        internal const string VO1Caption = "Allow Init() and Axit() as aliases for Constructor/Destructor";
        internal const string VO2Caption = "Initialize strings";
        internal const string VO3Caption = "All instance methods virtual";
        internal const string VO4Caption = "Implicit signed/unsigned conversions";
        internal const string VO5Caption = "Implicit Clipper calling convention";
        internal const string VO6Caption = "Implicit pointer conversions";
        internal const string VO7Caption = "Implicit casts and conversions";
        internal const string VO8Caption = "Compatible preprocessor";
        internal const string VO9Caption = "Handle problems with incorrect or missing return statements";
        internal const string VO10Caption = "Compatible IIF Behavior";
        internal const string VO11Caption = "Compatible numeric conversions";
        internal const string VO12Caption = "Clipper Compatible integer divisions";
        internal const string VO13Caption = "Compatible string comparisons";
        internal const string VO14Caption = "Use FLOAT literals";
        internal const string VO15Caption = "Treat missing types as USUAL";
        internal const string VO16Caption = "Generate Clipper constructors";
        internal const string XPP1Caption = "Inherit from Abstract class";
        internal const string FOX1Caption = "Inherit from Custom class";
        internal const string FOX2Caption = "Locals visible to macrocompiler.";
        internal const string VO1Description = "Allow Init() and Axit() as aliases for Constructor/Destructor (/vo1)";
        internal const string VO2Description = "Initialize strings to empty string (String.Empty) ( /vo2). Please note that in .NET a NULL_STRING is not the same as a string with length 0. When enabled this will initialize local string variables regardless of the setting of 'initialize locals' setting from the Language page.";
        internal const string VO3Description = "Add the virtual modifier to all methods by default (which is the normal Visual Objects behavior) (/vo3)";
        internal const string VO4Description = "Implicit signed/unsigned integer conversions (/vo4)";
        internal const string VO5Description = "Methods without parameters and calling convention are compiled as Clipper calling convention (/vo5). \nPlease note that without this switch all methods without parameters will be seen as STRICT. Methods with untyped parameters are always seen as CLIPPER calling convention.";
        internal const string VO6Description = "Implicit conversions between typed function PTR and PTR (/vo6)";
        internal const string VO7Description = "Compatible implicit casts and Conversions (/vo7)";
        internal const string VO8Description = "Makes the preprocessor case insensitive and also controls how #ifdef inspects #defines (/vo8)";
        internal const string VO9Description = "Allow missing return statements or allow return statements with incorrect return values (/vo9)";
        internal const string VO10Description = "Compatible IIF Behavior, allow different types of return values in TRUE and FALSE expression (/vo10)";
        internal const string VO11Description = "Compatible arithmetic conversions  (/vo11)";
        internal const string VO12Description = "Compatible integer divisions, integer divisions may return a float  (/vo12)";
        internal const string VO13Description = "Compatible string comparisons, respects SetExact and collation table (/vo13)";
        internal const string VO14Description = "Store floating point literals as FLOAT and not as System.Double (REAL8)  (/vo14)";
        internal const string VO15Description = "Missing type clauses for locals, instance variables and parameters are treated as USUAL (VO and Vulcan dialect). The default = TRUE for the VO dialect and FALSE for the other dialects. We strongly recommend to set this to FALSE because this will help you to find problems in your code and non optimal code. If you have to use the USUAL type we recommend to explicitly declare variables and parameters as USUAL (/vo15)";
        internal const string VO16Description = "Automatically create clipper calling convention constructors for classes without constructor where the parent class has a Clipper Calling convention constructor.(/vo16)";
        internal const string XPP1Description = "All classes without parent class inherit from the XPP Abstract class.(/xpp1)";
        internal const string FOX1Description = "All classes are assumed to inherit from the Custom class. This also affects the way in which properties are processed by the compiler.(/fox1)";
        internal const string FOX2Description = "Make local variables visible to the macro compiler. This may be needed for SQL queries with embedded parameters or the ampersand (&) operator. Use with care because this will generate quite some extra code.";
        internal const string CatCompatibility = "All dialects";
        internal const string CatNotCore = "Not in Core dialect";
        internal const string XPPCompatibility = "Xbase++ Compatibility";
        internal const string FOXCompatibility = "Visual FoxPro Compatibility";

        #endregion
        #region Fields
        private bool saving;

        private bool vo1;
        private bool vo2;
        private bool vo3;
        private bool vo4;
        private bool vo5;
        private bool vo6;
        private bool vo7;
        private bool vo8;
        private bool vo9;
        private bool vo10;
        private bool vo11;
        private bool vo12;
        private bool vo13;
        private bool vo14;
        private bool vo15;
        private bool vo16;
        private bool xpp1;
        private bool fox1;
        private bool fox2;
        #endregion Fields

        #region Constructors
        /// <summary>
        /// Explicitly defined default constructor.
        /// </summary>
        public XSharpDialectPropertyPage()
        {
            this.Name = DialectCaption;
        }

        #endregion

        #region Properties


        [Category(CatCompatibility), DisplayName(VO1Caption), Description(VO1Description)]
        public bool VO1
        {
            get { return this.vo1; }
            set { this.vo1 = value; this.IsDirty = true; }
        }

        [Category(CatCompatibility), DisplayName(VO2Caption), Description(VO2Description)]
        public bool VO2
        {
            get { return this.vo2; }
            set { this.vo2 = value; this.IsDirty = true; }
        }

        [Category(CatCompatibility), DisplayName(VO3Caption), Description(VO3Description)]
        public bool VO3
        {
            get { return this.vo3; }
            set { this.vo3 = value; this.IsDirty = true; }
        }
        [Category(CatCompatibility), DisplayName(VO4Caption), Description(VO4Description)]
        public bool VO4
        {
            get { return this.vo4; }
            set { this.vo4 = value; this.IsDirty = true; }
        }

        [Category(CatNotCore), DisplayName(VO5Caption), Description(VO5Description)]
        public bool VO5
        {
            get { return this.vo5; }
            set { this.vo5 = value; this.IsDirty = true; }
        }
        [Category(CatNotCore), DisplayName(VO6Caption), Description(VO6Description)]
        public bool VO6
        {
            get { return this.vo6; }
            set { this.vo6 = value; this.IsDirty = true; }
        }
        [Category(CatNotCore), DisplayName(VO7Caption), Description(VO7Description)]
        public bool VO7
        {
            get { return this.vo7; }
            set { this.vo7 = value; this.IsDirty = true; }
        }

        [Category(CatCompatibility), DisplayName(VO8Caption), Description(VO8Description)]
        public bool VO8
        {
            get { return this.vo8; }
            set { this.vo8 = value; this.IsDirty = true; }
        }

        [Category(CatCompatibility), DisplayName(VO9Caption), Description(VO9Description)]
        public bool VO9
        {
            get { return this.vo9; }
            set { this.vo9 = value; this.IsDirty = true; }
        }

        [Category(CatCompatibility), DisplayName(VO10Caption), Description(VO10Description)]
        public bool VO10
        {
            get { return this.vo10; }
            set { this.vo10 = value; this.IsDirty = true; }
        }

        [Category(CatNotCore), DisplayName(VO11Caption), Description(VO11Description)]
        public bool VO11
        {
            get { return this.vo11; }
            set { this.vo11 = value; this.IsDirty = true; }
        }

        [Category(CatNotCore),DisplayName(VO12Caption), Description(VO12Description)]
        public bool VO12
        {
            get { return this.vo12; }
            set { this.vo12 = value; this.IsDirty = true; }
        }

        [Category(CatNotCore), DisplayName(VO13Caption), Description(VO13Description)]
        public bool VO13
        {
            get { return this.vo13; }
            set { this.vo13 = value; this.IsDirty = true; }
        }

        [Category(CatNotCore), DisplayName(VO14Caption), Description(VO14Description)]
        public bool VO14
        {
            get { return this.vo14; }
            set { this.vo14 = value; this.IsDirty = true; }
        }
        [Category(CatNotCore), DisplayName(VO15Caption), Description(VO15Description)]
        public bool VO15 {
            get { return this.vo15; }
            set { this.vo15 = value; this.IsDirty = true; }
        }
        [Category(CatNotCore), DisplayName(VO16Caption), Description(VO16Description)]
        public bool VO16
        {
            get { return this.vo16; }
            set { this.vo16 = value; this.IsDirty = true; }
        }

        [Category(XPPCompatibility), DisplayName(XPP1Caption), Description(XPP1Description)]
        [ReadOnly(true)]
        public bool XPP1
        {
            get { return this.xpp1; }
            set { this.xpp1 = value; this.IsDirty = true; }
        }
        [Category(FOXCompatibility), DisplayName(FOX1Caption), Description(FOX1Description)]
        [ReadOnly(true)]
        public bool FOX1
        {
            get { return this.fox1; }
            set { this.fox1 = value; this.IsDirty = true; }
        }

        [Category(FOXCompatibility), DisplayName(FOX2Caption), Description(FOX2Description)]
        [ReadOnly(true)]
        public bool FOX2
        {
            get { return this.fox2; }
            set { this.fox2 = value; this.IsDirty = true; }
        }


        #endregion
        #region Overriden Implementation
        private void EnableDialectOptions(string dialect)
        {
            SetFieldReadOnly(nameof(FOX1), true);
            SetFieldReadOnly(nameof(FOX2), true);
            SetFieldReadOnly(nameof(XPP1), true);
            switch (dialect.ToLower())
            {
                case "foxpro":
                    SetFieldReadOnly(nameof(FOX1), false);
                    SetFieldReadOnly(nameof(FOX2), false);
                    break;
                case "xpp":
                    SetFieldReadOnly(nameof(XPP1), false);
                    break;
            }
        }
        internal override void Project_OnProjectPropertyChanged(object sender, ProjectPropertyChangedArgs e)
        {
            if (!saving)
            {
                try
                {
                    if (e.PropertyName.ToLower() == "dialect")
                    {
                        if (e.NewValue.ToLower() == "foxpro")
                        {
                            fox1 = true;
                        }
                        else
                        {
                            fox1 = false;
                            fox2 = false;
                        }
                        Grid.Refresh();
                        EnableDialectOptions(e.NewValue);
                    }
                  }
                catch (Exception)
                {
                }
            }
        }
        /// <summary>
        /// Returns class FullName property value.
        /// </summary>
        public override string GetClassName()
        {
            return this.GetType().FullName;
        }
        /// <summary>
        /// Bind properties.
        /// </summary>
        ///
        protected override void BindProperties()
        {
            if (this.ProjectMgr == null)
            {
                return;
            }

            vo1 = getPrjLogic(nameof(VO1), false);
            vo2 = getPrjLogic(nameof(VO2), false);
            vo3 = getPrjLogic(nameof(VO3), false);
            vo4 = getPrjLogic(nameof(VO4), false);
            vo5 = getPrjLogic(nameof(VO5), false);
            vo6 = getPrjLogic(nameof(VO6), false);
            vo7 = getPrjLogic(nameof(VO7), false);
            vo8 = getPrjLogic(nameof(VO8), false);
            vo9 = getPrjLogic(nameof(VO9), false);
            vo10 = getPrjLogic(nameof(VO10), false);
            vo11 = getPrjLogic(nameof(VO11), false);
            vo12 = getPrjLogic(nameof(VO12), false);
            vo13 = getPrjLogic(nameof(VO13), false);
            vo14 = getPrjLogic(nameof(VO14), false);
            vo15 = getPrjLogic(nameof(VO15), true);
            vo16 = getPrjLogic(nameof(VO16), false);
			xpp1 = getPrjLogic(nameof(XPP1), false);
            fox1 = getPrjLogic(nameof(FOX1), false);
            fox2 = getPrjLogic(nameof(FOX2), false);
            EnableDialectOptions(this.ProjectMgr.GetProjectProperty("Dialect"));
        }

        /// <summary>
        /// Apply Changes on project node.
        /// </summary>
        /// <returns>E_INVALIDARG if internal ProjectMgr is null, otherwise applies changes and return S_OK.</returns>
        protected override int ApplyChanges()
        {
            if (this.ProjectMgr == null)
            {
                return VSConstants.E_INVALIDARG;
            }
            saving = true;

            this.ProjectMgr.SetProjectProperty(nameof(VO1), this.vo1.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO2), this.vo2.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO3), this.vo3.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO4), this.vo4.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO5), this.vo5.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO6), this.vo6.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO7), this.vo7.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO8), this.vo8.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO9), this.vo9.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO10), this.vo10.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO11), this.vo11.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO12), this.vo12.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO13), this.vo13.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO14), this.vo14.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO15), this.vo15.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(VO16), this.vo16.ToString().ToLower());
			this.ProjectMgr.SetProjectProperty(nameof(XPP1), this.xpp1.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(FOX1), this.fox1.ToString().ToLower());
            this.ProjectMgr.SetProjectProperty(nameof(FOX2), this.fox2.ToString().ToLower());

            this.IsDirty = false;
            saving = false;
            return VSConstants.S_OK;
        }
        #endregion
    }

}
