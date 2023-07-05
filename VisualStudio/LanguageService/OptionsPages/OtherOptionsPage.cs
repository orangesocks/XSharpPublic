﻿using Microsoft.VisualStudio.Shell;
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
using XSharpModel;
using XSharp.Settings;
namespace XSharp.LanguageService.OptionsPages
{

    [Guid(XSharpConstants.OtherOptionsPageGuidString)]
    [SharedSettings("TextEditor.XSharp", false)]
    [ComVisible(true)]
    class OtherOptionsPage : XSDialogPage<OtherOptionsControl, OtherOptions>
    {
        // The base class exposes the AutomationObject that contains the values
    }
    public class OtherOptions : OptionsBase
    {
        #region Properties
        public bool AutoPairs { get; set; }
        public bool AutoOpen { get; set; }
        public bool ShowDividers { get; set; }
        public bool ShowSingleLineDividers { get; set; }
        public bool FormEditorMakeBackupFiles { get; set; }
        public bool EnableHighlightWord { get; set; }
        public bool EnableBraceMatching { get; set; }
        public bool EnableKeywordmatching { get; set; }
        public bool EnableLightBulbs { get; set; }
        public bool EnableQuickInfo { get; set; }
        public bool EnableParameterInfo { get; set; }
        public bool EnableRegions { get; set; }
        public bool EnableCodeCompletion { get; set; }

        #endregion
        public OtherOptions()
        {
            AutoPairs = true;
            AutoOpen = true;
            EnableHighlightWord = true;
            EnableBraceMatching = true;
            EnableKeywordmatching = true;
            EnableLightBulbs = true;
            EnableQuickInfo = true;
            EnableParameterInfo = true;
            EnableCodeCompletion = true;
            EnableRegions = true;
            ShowDividers = true;
            ShowSingleLineDividers = true;
            FormEditorMakeBackupFiles = true;
        }
        public override void WriteToSettings()
        {
            // Other
            XEditorSettings.ShowDividers = ShowDividers;
            XEditorSettings.CompletionAutoPairs = AutoPairs;
            XEditorSettings.ShowSingleLineDividers = ShowSingleLineDividers;
            XEditorSettings.DisableAutoOpen = !AutoOpen;
            XEditorSettings.DisableHighLightWord = !EnableHighlightWord;
            XEditorSettings.DisableBraceMatching = !EnableBraceMatching;
            XEditorSettings.DisableKeywordMatching = !EnableKeywordmatching;
            XEditorSettings.DisableCodeCompletion = !EnableCodeCompletion;
            XEditorSettings.DisableLightBulb = !EnableLightBulbs;
            XEditorSettings.DisableParameterInfo = !EnableParameterInfo;
            XEditorSettings.DisableQuickInfo = !EnableQuickInfo;
            XEditorSettings.DisableRegions = !EnableRegions;

        }

    }
}
