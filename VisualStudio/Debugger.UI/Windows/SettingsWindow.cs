﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
using Community.VisualStudio.Toolkit;
using Microsoft.VisualStudio.Imaging;
using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;

namespace XSharp.Debugger.UI
{
    public class SettingsWindow: BaseToolWindow<SettingsWindow>
    {
        public override string GetTitle(int toolWindowId) => "X# Settings";

        public override Type PaneType => typeof(Pane);
        public SettingsControl Control = null;


        public override async Task<FrameworkElement> CreateAsync(int toolWindowId, CancellationToken cancellationToken)
        {
            Support.RegisterWindow(this);
            Version _ = await VS.Shell.GetVsVersionAsync();
            Control = new SettingsControl() { DataContext = new SettingsView() };
            Control.Refresh();
            return Control;
        }

        internal void Refresh()
        {
            Control.Refresh();
        }
        internal void Clear()
        {
            Control.Clear();
        }


        [Guid("F7ED7826-137A-462D-8757-37A02BEF4DCF")]
        internal class Pane : ToolkitToolWindowPane
        {
            public Pane()
            {
                BitmapImageMoniker = KnownMonikers.Settings;
            }
            public override void OnToolWindowCreated()
            {
                base.OnToolWindowCreated();
                Support.RefreshWindows();
            }
            protected override void OnCreate()
            {
                base.OnCreate();
                Support.RefreshWindows();
            }

        }

    }
}
