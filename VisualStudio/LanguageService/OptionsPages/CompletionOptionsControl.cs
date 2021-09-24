﻿using System;
namespace XSharp.LanguageService.OptionsPages
{
    public partial class CompletionOptionsControl : XSUserControl
    {
        public CompletionOptionsControl()
        {
            InitializeComponent();
            chkFields.Tag = nameof(CompletionOptionsPage.CompleteSelf);
            chkLocals.Tag = nameof(CompletionOptionsPage.CompleteLocals);
            chkInherited.Tag = nameof(CompletionOptionsPage.CompleteParent);
            chkNamespaces.Tag = nameof(CompletionOptionsPage.CompleteNamespaces);
            chkTypes.Tag = nameof(CompletionOptionsPage.CompleteTypes);
            chkKeywords.Tag = nameof(CompletionOptionsPage.CompleteKeywords);
            chkSnippets.Tag = nameof(CompletionOptionsPage.CompleteSnippets);
            chkGlobalsProject.Tag = nameof(CompletionOptionsPage.CompleteGlobals);
            chkGlobalsSource.Tag = nameof(CompletionOptionsPage.CompleteGlobalsP);
            chkGlobalsExtern.Tag = nameof(CompletionOptionsPage.CompleteGlobalsA);
            chkFunctions.Tag = nameof(CompletionOptionsPage.CompleteFunctions);
            chkFunctionsSource.Tag = nameof(CompletionOptionsPage.CompleteFunctionsP);
            chkFunctionsExternal.Tag = nameof(CompletionOptionsPage.CompleteFunctionsA);
            tbChars.Tag = nameof(CompletionOptionsPage.CompleteNumChars);
            this.rtfDescription.Text = String.Join(Environment.NewLine,
                new string[] {
                "Code Completion is triggered by special characters such as '.' and ':'",
                "The editor can also perform code completion at other locations such as:",
                "•\tafter certain keywords, such as AS, INHERIT, IMPLEMENTS, USING ",
                "•\tat the start of an expression, such as at the start of a line or after an",
                "\topening '(', '{' or '[' or after :=",
                "The filling of these last \"generic\" completion lists will be started after",
                "you have typed a few characters, but these lists could still be long",
                "and filling the list could be time consuming.",
                "",
                "On this page you can control where the editor will look for completion." });
        }
        

        private void btnAll_Click(object sender, EventArgs e)
        {
            checkbuttons(true);
        }

        private void btnNothing_Click(object sender, EventArgs e)
        {
            checkbuttons(false);
        }
    }
}
