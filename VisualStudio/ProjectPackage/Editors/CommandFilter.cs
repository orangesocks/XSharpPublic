﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
using System;
using System.ComponentModel.Composition;
using System.Diagnostics;
using Microsoft.VisualStudio.OLE.Interop;
using Microsoft.VisualStudio.Text;
using Microsoft.VisualStudio.Text.Editor;
using Microsoft.VisualStudio.TextManager.Interop;
using Microsoft.VisualStudio.Utilities;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.Package;
using System.Runtime.InteropServices;
using Microsoft.VisualStudio.Editor;
using Microsoft.VisualStudio.Language.Intellisense;
using LanguageService.SyntaxTree;
using LanguageService.CodeAnalysis.XSharp.SyntaxParser;
using System.Collections.Generic;
using System.Reflection;
using Microsoft.VisualStudio.Text.Operations;
using Microsoft.VisualStudio.Text.Classification;
using Microsoft.VisualStudio.Text.Tagging;
using Microsoft.VisualStudio.Text.Editor.OptionsExtensionMethods;
using XSharpColorizer;
using XSharpModel;
using XSharpLanguage;
using System.Linq;
using Microsoft.VisualStudio.Shell.Interop;
using Microsoft.VisualStudio.Project;
using LanguageService.CodeAnalysis.XSharp;
using Microsoft;

namespace XSharp.Project
{
    internal sealed partial class CommandFilter : IOleCommandTarget
    {
        public ITextView TextView { get; private set; }
        public IOleCommandTarget Next { get; set; }

        ICompletionBroker _completionBroker;
        ICompletionSession _completionSession;
        XSharpClassifier _classifier;
        XFile _file;
        ISignatureHelpBroker _signatureBroker;
        ISignatureHelpSession _signatureSession;
        Stack<ISignatureHelpSession> _signatureStack;

        ITextStructureNavigator m_navigator;
        IBufferTagAggregatorFactoryService _aggregator;
        OptionsPages.IntellisenseOptionsPage _optionsPage;
        List<int> _linesToSync;
        bool _suspendSync = false;


        private bool getTagAggregator()
        {
            try
            {
                if (_tagAggregator == null)
                {
                    _tagAggregator = _aggregator.CreateTagAggregator<IClassificationTag>(_buffer);
                }
            }
            catch (Exception e)
            {
                System.Diagnostics.Debug.WriteLine(e.Message);
            }
            return _tagAggregator != null;
        }

        private void registerClassifier()
        {
            if (_buffer.Properties.ContainsProperty(typeof(XSharpClassifier)))
            {
                if (_classifier == null)
                {
                    _classifier = (XSharpClassifier)_buffer.Properties.GetProperty(typeof(XSharpClassifier));
                    _classifier.ClassificationChanged += _classifier_ClassificationChanged;
                }
            }
            else
            {
                _classifier = null;
            }

        }

        private int currentLine
        {
            get
            {
                SnapshotPoint caret = this.TextView.Caret.Position.BufferPosition;
                ITextSnapshotLine line = caret.GetContainingLine();
                return line.LineNumber;
            }
        }
        private void _classifier_ClassificationChanged(object sender, ClassificationChangedEventArgs e)
        {
            XSharpProjectPackage.Instance.DisplayOutPutMessage("CommandFilter.ClassificationChanged()");
            if (_suspendSync)
                return;
            if (_keywordCase == KeywordCase.None)
            {
                return;
            }
            // do not update buffer from background thread
            if (!_buffer.CheckEditAccess())
            {
                return;
            }

            if (_linesToSync.Count > 0)
            {
                int[] lines;
                lock (_linesToSync)
                {
                    lines = _linesToSync.ToArray();
                    _linesToSync.Clear();
                    _linesToSync.Add(this.currentLine);
                    Array.Sort(lines);
                }

                // wait until we can work
                while (_buffer.EditInProgress)
                {
                    System.Threading.Thread.Sleep(100);
                }

                UIThread.DoOnUIThread(delegate ()
                    {
                        var editSession = _buffer.CreateEdit();
                        var snapshot = editSession.Snapshot;
                        try
                        {
                            var end = DateTime.Now + new TimeSpan(0, 0, 2);
                            int counter = 0;
                            foreach (int nLine in lines)
                            {
                                ITextSnapshotLine line = snapshot.GetLineFromLineNumber(nLine);
                                formatLineCase(editSession, line);
                                // when it takes longer than 2 seconds, then abort
                                if (++counter > 100 && DateTime.Now > end)
                                    break;
                            }
                        }
                        catch (Exception)
                        {
                            ;
                        }
                        finally
                        {
                            if (editSession.HasEffectiveChanges)
                            {
                                editSession.Apply();
                            }
                            else
                            {
                                editSession.Cancel();
                            }
                        }
                    });


            }
        }
        public CommandFilter(IWpfTextView textView, ICompletionBroker completionBroker, ITextStructureNavigator nav, ISignatureHelpBroker signatureBroker, IBufferTagAggregatorFactoryService aggregator, VsTextViewCreationListener provider)
        {
            m_navigator = nav;

            m_provider = provider;

            _completionSession = null;
            _signatureSession = null;
            _signatureStack = new Stack<ISignatureHelpSession>();

            TextView = textView;
            _completionBroker = completionBroker;
            _signatureBroker = signatureBroker;
            _aggregator = aggregator;
            _linesToSync = new List<int>();
            var package = XSharpProjectPackage.Instance;
            _optionsPage = package.GetIntellisenseOptionsPage();
            //
            _buffer = TextView.TextBuffer;
            if (_buffer != null)
            {
                _buffer.ChangedLowPriority += Textbuffer_Changed;
                _buffer.Changing += Textbuffer_Changing;
                _file = _buffer.GetFile();

                if (_buffer.CheckEditAccess())
                {
                    //formatCaseForWholeBuffer();
                }
            }
        }

        private void Textbuffer_Changing(object sender, TextContentChangingEventArgs e)
        {
            bool debugging = XSharpProjectPackage.Instance.DebuggerIsRunning;
            if (debugging)
            {
                XSharpProjectPackage.Instance.ShowMessageBox("Cannot edit source code while debugging");
                e.Cancel();
            }
        }


        /// <summary>
        /// Format the Keywords and Identifiers in the Line, using the EditSession
        /// </summary>
        /// <param name="editSession"></param>
        /// <param name="line"></param>
        private string FormatKeyword(string keyword)
        {
            return _optionsPage.SyncKeyword(keyword);
        }


        private void formatToken(ITextEdit editSession, int offSet, IToken token)
        {
            if (token.Channel == XSharpLexer.Hidden ||
                token.Channel == XSharpLexer.PREPROCESSORCHANNEL ||
                token.Type == XSharpLexer.TEXT_STRING_CONST)
                return;
            bool syncKeyword = false;
            // Some exceptions are (pseudo) functions. These should not be formatted
            switch (token.Type)
            {
                case XSharpLexer.NAMEOF:
                case XSharpLexer.SIZEOF:
                case XSharpLexer.TYPEOF:
                    // these are keywords but should be excluded I think
                    syncKeyword = false;
                    break;
                case XSharpLexer.TRUE_CONST:
                case XSharpLexer.FALSE_CONST:
                case XSharpLexer.MACRO:
                case XSharpLexer.LOGIC_AND:
                case XSharpLexer.LOGIC_OR:
                case XSharpLexer.LOGIC_NOT:
                case XSharpLexer.LOGIC_XOR:
                case XSharpLexer.VO_AND:
                case XSharpLexer.VO_OR:
                case XSharpLexer.VO_NOT:
                case XSharpLexer.VO_XOR:
                    syncKeyword = true;
                    break;
                default:
                    if (token.Type >= XSharpLexer.FIRST_NULL && token.Type <= XSharpLexer.LAST_NULL)
                    {
                        syncKeyword = true;
                    }
                    else if (XSharpLexer.IsKeyword(token.Type))
                    {
                        syncKeyword = token.Text[0] != '#';
                    }
                    break;
            }
            if (syncKeyword)
            {
                var keyword = token.Text;
                var transform = FormatKeyword(keyword);
                if (String.Compare(transform, keyword) != 0)
                {
                    int startpos = offSet + token.StartIndex;
                    editSession.Replace(startpos, transform.Length, transform);
                }
            }
            if (token.Type == XSharpLexer.ID && IdentifierCase)
            {
                var identifier = token.Text;
                // Remove the @@ marker
                if (identifier.StartsWith("@@"))
                    identifier = identifier.Substring(2);
                var lineNumber = currentLine;
                XTypeMember currentMember = XSharpTokenTools.FindMember(lineNumber, _file);
                //
                if (currentMember == null)
                    return;
                CompletionType cType = null;
                XSharpLanguage.CompletionElement foundElement = null;
                XVariable element = null;
                // Search in Parameters
                if (currentMember.Parameters != null)
                {
                    element = (XVariable)currentMember.Parameters.Where(x => XSharpTokenTools.StringEquals(x.Name, identifier)).FirstOrDefault();
                }
                if (element == null)
                {
                    // then Locals
                    var locals = currentMember.GetLocals(TextView.TextSnapshot, lineNumber, _file.Project.Dialect);
                    if (locals != null)
                    {
                        element = locals.Where(x => XSharpTokenTools.StringEquals(x.Name, identifier)).FirstOrDefault();
                    }
                    if (element == null)
                    {
                        if (currentMember.Parent != null)
                        {
                            // Context Type....
                            cType = new CompletionType(currentMember.Parent.Clone);
                            // We can have a Property/Field of the current CompletionType
                            if (!cType.IsEmpty())
                            {
                                cType = XSharpTokenTools.SearchPropertyOrFieldIn(cType, identifier, Modifiers.Private, out foundElement);
                            }
                            // Not found ? It might be a Global !?
                            if (foundElement == null)
                            {

                            }
                        }
                    }
                }
                if (element != null)
                {
                    cType = new CompletionType((XVariable)element, "");
                    foundElement = new XSharpLanguage.CompletionElement(element);
                }
                // got it !
                if (foundElement != null)
                {
                    if ((String.Compare(foundElement.Name, identifier) != 0))
                    {
                        int startpos = offSet + token.StartIndex;
                        editSession.Replace(startpos, foundElement.Name.Length, foundElement.Name);

                    }
                }

            }
        }
        private bool canIndentLine(ITextSnapshotLine line)
        {
            var ss = new SnapshotSpan(line.Snapshot, line.Extent);

            var spans = _classifier.GetClassificationSpans(ss);
            if (spans.Count > 0)
            {
                var type = spans[0].ClassificationType;
                if (type.Classification.ToLower() == "comment")
                    return false;
                if (type.Classification.ToLower() == "xsharp.text")
                {
                    if (spans.Count == 1)
                        return false;
                    // endtext line starts with token with type "xsharp.text" when it starts with spaces
                    return spans[1].ClassificationType.Classification == "keyword";
                }
            }
            return true;

        }
        private bool canFormatLine(ITextSnapshotLine line)
        {
            // get first token on line
            // when comment: do not format
            // when xsharp.text and only one token: do not format
            // when xsharp.text and second token = keyword, then endtext line, so format
            if (line.Length == 0)
                return false;
            return canIndentLine(line);
        }
        private bool IsCommentOrString(string classification)
        {
            if (string.IsNullOrEmpty(classification))
                return false;
            switch (classification.ToLower())
            {
                case "comment":
                case "string":
                case "xsharp.text":
                    return true;
            }
            return false;
        }


        private void formatLineCase(ITextEdit editSession, ITextSnapshotLine line)
        {
            if (XSharpProjectPackage.Instance.DebuggerIsRunning)
            {
                return;
            }
            if (!canFormatLine(line))
            {
                return;
            }

            getEditorPreferences(TextView);
            if (_keywordCase == KeywordCase.None)
            {
                return;
            }
            XSharpProjectPackage.Instance.DisplayOutPutMessage($"CommandFilter.formatLineCase({line.LineNumber + 1})");
            // get classification of the line.
            // when the line is part of a multi line comment then do nothing
            // to detect that we take the start of the line and check if it is in
            int lineStart = line.Start.Position;
            if (line.Length == 0)
                return;
            var tokens = getTokensInLine(line);
            foreach (var token in tokens)
            {
                if (currentLine == line.LineNumber)
                {
                    // do not update tokens touching or after the caret
                    // after typing String it was already uppercasing even when I wanted to type StringComparer
                    // now we wait until the user has typed an extra character. That will trigger another session.
                    // (in this case the C, but it could also be a ' ' or tab and then it would match the STRING keyword)
                    int caretPos = this.TextView.Caret.Position.BufferPosition.Position;
                    if (lineStart + token.StopIndex < caretPos - 1)
                    {
                        formatToken(editSession, lineStart, token);
                    }
                    else
                    {
                        // Come back later.
                        registerLineForCaseSync(line.LineNumber);
                        break;
                    }
                }
                else
                {
                    formatToken(editSession, lineStart, token);
                }
            }
        }

        private void registerLineForCaseSync(int line)
        {
            if (!_suspendSync && _keywordCase != KeywordCase.None)
            {
                lock (_linesToSync)
                {
                    if (!_linesToSync.Contains(line))
                        _linesToSync.Add(line);
                }
            }
        }
        private void Textbuffer_Changed(object sender, TextContentChangedEventArgs e)
        {
            var snapshot = e.After;
            var changes = e.Changes;
            if (changes != null)
            {
                foreach (var change in changes)
                {
                    int iStart = change.NewSpan.Start;
                    int iEnd = change.NewSpan.End;
                    iStart = snapshot.GetLineFromPosition(iStart).LineNumber;
                    iEnd = snapshot.GetLineFromPosition(iEnd).LineNumber;
                    for (int iline = iStart; iline <= iEnd; iline++)
                    {
                        registerLineForCaseSync(iline);
                    }
                }
            }

        }
        private void formatCaseForWholeBuffer()
        {
            if (XSharpProjectPackage.Instance.DebuggerIsRunning)
            {
                return;
            }
            getEditorPreferences(TextView);
            if (_optionsPage.KeywordCase != 0)
            {
                XSharpProjectPackage.Instance.DisplayOutPutMessage("--> CommandFilter.formatCaseForBuffer()");
                /*
                bool changed = false;
                // wait until we can work
                while (_buffer.EditInProgress)
                {
                    System.Threading.Thread.Sleep(100);
                }
                var edit = _buffer.CreateEdit(EditOptions.DefaultMinimalChange, null, null);
                try
                {
                    string text = _buffer.CurrentSnapshot.GetText();
                    var tokens = getTokens(text);
                    foreach (var token in tokens)
                    {
                        formatToken(edit, 0, token);
                    }
                }
                finally
                {
                    if (edit.HasEffectiveChanges)
                    {
                        edit.Apply();
                        changed = true;
                    }
                    else
                    {
                        edit.Cancel();
                    }
                }
                if (changed && _buffer.Properties.ContainsProperty(typeof(XSharpClassifier)))
                */
                if (_buffer.Properties.ContainsProperty(typeof(XSharpClassifier)))
                {
                    var classify = _buffer.Properties.GetProperty<XSharpClassifier>(typeof(XSharpClassifier));
                    classify.Classify();
                }
                XSharpProjectPackage.Instance.DisplayOutPutMessage("<-- CommandFilter.formatCaseForBuffer()");
            }
            return;
        }

        private char GetTypeChar(IntPtr pvaIn)
        {
            return (char)(ushort)Marshal.GetObjectForNativeVariant(pvaIn);
        }

        bool completionWasSelected = false;
        CompletionSelectionStatus completionWas;
        private VsTextViewCreationListener m_provider;

        public int Exec(ref Guid pguidCmdGroup, uint nCmdID, uint nCmdexecopt, IntPtr pvaIn, IntPtr pvaOut)
        {
            if (Microsoft.VisualStudio.Shell.VsShellUtilities.IsInAutomationFunction(m_provider.ServiceProvider))
            {
                return Next.Exec(ref pguidCmdGroup, nCmdID, nCmdexecopt, pvaIn, pvaOut);
            }
            //
            bool handled = false;
            if (_classifier == null)
                registerClassifier();
            int hresult = VSConstants.S_OK;
            bool returnClosedCompletionList = false;

            // 1. Pre-process
            if (pguidCmdGroup == VSConstants.VSStd2K)
            {
                switch ((VSConstants.VSStd2KCmdID)nCmdID)
                {
                    case VSConstants.VSStd2KCmdID.AUTOCOMPLETE:
                    case VSConstants.VSStd2KCmdID.COMPLETEWORD:
                    case VSConstants.VSStd2KCmdID.SHOWMEMBERLIST:
                        CancelSignatureSession();
                        handled = StartCompletionSession(nCmdID, '\0');
                        break;
                    case VSConstants.VSStd2KCmdID.RETURN:
                        handled = CompleteCompletionSession();
                        if (handled)
                        {
                            returnClosedCompletionList = true;
                        }
                        break;
                    case VSConstants.VSStd2KCmdID.TAB:
                        handled = CompleteCompletionSession();
                        break;
                    case VSConstants.VSStd2KCmdID.CANCEL:
                        handled = CancelCompletionSession();
                        break;
                    case VSConstants.VSStd2KCmdID.PARAMINFO:
                        StartSignatureSession(false);
                        break;
                    case VSConstants.VSStd2KCmdID.BACKSPACE:
                        if (_signatureSession != null)
                        {
                            int pos = TextView.Caret.Position.BufferPosition;
                            if (pos > 0)
                            {
                                // get previous char
                                var previous = TextView.TextBuffer.CurrentSnapshot.GetText().Substring(pos - 1, 1);
                                if (previous == "(" || previous == "{")
                                {
                                    _signatureSession.Dismiss();
                                }
                            }

                        }
                        break;
                }
            }
            else if (pguidCmdGroup == VSConstants.GUID_VSStandardCommandSet97)
            {
                switch ((VSConstants.VSStd97CmdID)nCmdID)
                {
                    case VSConstants.VSStd97CmdID.GotoDefn:
                        GotoDefn();
                        return VSConstants.S_OK;
                    case VSConstants.VSStd97CmdID.Undo:
                    case VSConstants.VSStd97CmdID.Redo:
                        CancelSignatureSession();
                        CancelCompletionSession();
                        break;
                }
            }

            // Let others do their thing
            if (!handled)
            {
                if (_completionSession != null)
                {
                    if (_completionSession.SelectedCompletionSet != null)
                    {
                        completionWasSelected = _completionSession.SelectedCompletionSet.SelectionStatus.IsSelected;
                        if (completionWasSelected)
                        {
                            completionWas = _completionSession.SelectedCompletionSet.SelectionStatus;
                        }
                        else
                            completionWas = null;
                    }
                }
                hresult = Next.Exec(pguidCmdGroup, nCmdID, nCmdexecopt, pvaIn, pvaOut);
            }

            if (ErrorHandler.Succeeded(hresult))
            {
                // 3. Post process
                if (pguidCmdGroup == Microsoft.VisualStudio.VSConstants.VSStd2K)
                {
                    switch ((VSConstants.VSStd2KCmdID)nCmdID)
                    {
                        case VSConstants.VSStd2KCmdID.TYPECHAR:
                            char ch = GetTypeChar(pvaIn);
                            if (_completionSession != null)
                            {
                                if (char.IsLetterOrDigit(ch) || ch == '_')
                                    FilterCompletionSession(ch);
                                else
                                {
                                    if (completionWasSelected && (_optionsPage.CommitChars.Contains(ch)))
                                    {
                                        CompleteCompletionSession(true, ch);
                                    }
                                    else
                                    {
                                        CancelCompletionSession();
                                    }
                                    if ((ch == ':') || (ch == '.'))
                                    {
                                        StartCompletionSession(nCmdID, ch);
                                    }
                                }
                                //
                            }
                            else
                            {
                                switch (ch)
                                {
                                    case ':':
                                    case '.':
                                        CancelSignatureSession();
                                        StartCompletionSession(nCmdID, ch);
                                        break;
                                    case '(':
                                    case '{':
                                        StartSignatureSession(false);
                                        break;
                                    case ')':
                                    case '}':
                                        CancelSignatureSession();
                                        break;
                                    case ',':
                                        StartSignatureSession(true);
                                        break;
                                    default:
                                        completeCurrentToken(nCmdID, ch);
                                        break;
                                }
                            }
                            break;
                        case VSConstants.VSStd2KCmdID.HELP:
                        case VSConstants.VSStd2KCmdID.HELPKEYWORD:
                            break;
                        case VSConstants.VSStd2KCmdID.BACKSPACE:
                            FilterCompletionSession('\0');
                            break;
#if SMARTINDENT
                        case VSConstants.VSStd2KCmdID.FORMATDOCUMENT:
                            try
                            {
                                lock (_linesToSync)
                                {
                                    _suspendSync = true;
                                    _linesToSync.Clear();
                                }
                                FormatDocument();
                            }
                            finally
                            {
                                lock (_linesToSync)
                                {
                                    _linesToSync.Clear();
                                    _suspendSync = false;
                                }
                            }
                            break;
#endif
                        case VSConstants.VSStd2KCmdID.RETURN:
                            CancelSignatureSession();
                            if (!returnClosedCompletionList)
                                FormatLine();
                            handled = true;
                            break;
                        case VSConstants.VSStd2KCmdID.COMPLETEWORD:
                            break;
                        case VSConstants.VSStd2KCmdID.LEFT:
                        case VSConstants.VSStd2KCmdID.RIGHT:
                            MoveSignature();
                            break;
                    }
                    //
                    if (handled) return VSConstants.S_OK;
                }
            }

            return hresult;
        }



        #region Goto Definition

        private void GotoDefn()
        {
            try
            {
                if (_noGotoDefinition)
                    return;
                XSharpProjectPackage.Instance.DisplayOutPutMessage("CommandFilter.GotoDefn()");
                XSharpModel.ModelWalker.Suspend();
                // First, where are we ?
                int caretPos = this.TextView.Caret.Position.BufferPosition.Position;
                int lineNumber = this.TextView.Caret.Position.BufferPosition.GetContainingLine().LineNumber;
                var snapshot = this.TextView.TextBuffer.CurrentSnapshot;
                XSharpModel.XFile file = this.TextView.TextBuffer.GetFile();
                if (file == null)
                    return;
                // Check if we can get the member where we are
                XTypeMember member = XSharpTokenTools.FindMember(lineNumber, file);
                XType currentNamespace = XSharpTokenTools.FindNamespace(caretPos, file);

                // Then, the corresponding Type/Element if possible
                IToken stopToken;
                //ITokenStream tokenStream;
                List<String> tokenList = XSharpTokenTools.GetTokenList(caretPos, lineNumber, snapshot, out stopToken, true, file, false, member);

                // LookUp for the BaseType, reading the TokenList (From left to right)
                CompletionElement gotoElement;
                String currentNS = "";
                if (currentNamespace != null)
                {
                    currentNS = currentNamespace.Name;
                }
                //
                CompletionType cType = XSharpTokenTools.RetrieveType(file, tokenList, member, currentNS, stopToken, out gotoElement, snapshot, lineNumber, file.Project.Dialect);
                //
                if (gotoElement != null)
                {
                    if (gotoElement.XSharpElement != null)
                    {
                        if (gotoElement.XSharpElement is XTypeMember)
                        {
                            if (((XTypeMember)gotoElement.XSharpElement).Namesake().Count > 1)
                            {
                                ObjectBrowserHelper.FindSymbols(gotoElement.XSharpElement.Name);
                                return;
                            }
                        }
                        // Ok, find it ! Let's go ;)
                        gotoElement.XSharpElement.OpenEditor();
                        return;
                    }
                    else if (gotoElement.SystemElement != null)
                    {
                        //gotoObjectBrowser(gotoElement.SystemElement);
                        return;
                    }
                }
                //
                if (tokenList.Count > 1)
                {
                    // try again with just the last element in the list
                    tokenList.RemoveRange(0, tokenList.Count - 1);
                    cType = XSharpTokenTools.RetrieveType(file, tokenList, member, currentNS, stopToken, out gotoElement, snapshot, lineNumber, file.Project.Dialect);
                }
                if ((gotoElement != null) && (gotoElement.XSharpElement != null))
                {
                    // Ok, find it ! Let's go ;)
                    gotoElement.XSharpElement.OpenEditor();
                }

            }
            catch (Exception ex)
            {
                XSharpProjectPackage.Instance.DisplayOutPutMessage("Goto failed: ");
                XSharpProjectPackage.Instance.DisplayException(ex);
            }
            finally
            {
                XSharpModel.ModelWalker.Resume();
            }
        }


        private void gotoObjectBrowser(MemberInfo mbrInfo)
        {
            ObjectBrowserHelper.GotoMemberDefinition(mbrInfo.Name);
        }
        #endregion

        #region Completion Session
        private void completeCurrentToken(uint nCmdID, char ch)
        {
            if (!_optionsPage.ShowAfterChar)
                return;
            SnapshotPoint caret = TextView.Caret.Position.BufferPosition;
            if (cursorIsInStringorComment(caret))
            {
                return;
            }
            if (Char.IsLetterOrDigit(ch) || ch == '_')
            {
                var line = caret.GetContainingLine();

                var lineText = line.GetText();
                var pos = caret.Position - line.Start.Position;
                int chars = 0;
                bool done = false;
                // count the number of characters in the current word. When > 2 then trigger completion
                for (int i = pos - 1; i >= 0; i--)
                {
                    switch (lineText[i])
                    {
                        case ' ':
                        case '\t':
                            done = true;
                            break;
                    }
                    if (done)
                        break;
                    chars++;
                    if (chars > 2)
                        break;
                }
                if (chars > 2)
                {
                    StartCompletionSession(nCmdID, '\0');
                }
            }
        }

        private void FilterCompletionSession(char ch)
        {
            XSharpProjectPackage.Instance.DisplayOutPutMessage("CommandFilter.FilterCompletionSession()");
            if (_completionSession == null)
                return;

            XSharpProjectPackage.Instance.DisplayOutPutMessage(" --> in Filter");
            if (_completionSession.SelectedCompletionSet != null)
            {
                XSharpProjectPackage.Instance.DisplayOutPutMessage(" --> Filtering ?");
                _completionSession.SelectedCompletionSet.Filter();
                if (_completionSession.SelectedCompletionSet.Completions.Count == 0)
                {
                    CancelCompletionSession();
                }
                else
                {
                    XSharpProjectPackage.Instance.DisplayOutPutMessage(" --> Selecting ");
                    _completionSession.SelectedCompletionSet.SelectBestMatch();
                    _completionSession.SelectedCompletionSet.Recalculate();
                }
            }

        }


        bool CancelCompletionSession()
        {
            if (_completionSession == null)
            {
                return false;
            }

            _completionSession.Dismiss();

            return true;
        }

        void formatKeyword(Completion completion, char nextChar)
        {
            completion.InsertionText = _optionsPage.SyncKeyword(completion.InsertionText);
            if (nextChar != ' ' && nextChar != '\t' && nextChar != '\0')
            {
                completion.InsertionText += " ";
            }
        }

        bool CompleteCompletionSession(bool force = false, char ch = ' ')
        {
            if (_completionSession == null)
            {
                return false;
            }
            bool commit = false;
            bool moveBack = false;
            ITextCaret caret = null;
            XSharpProjectPackage.Instance.DisplayOutPutMessage("CommandFilter.CompleteCompletionSession()");
            if (_completionSession.SelectedCompletionSet != null)
            {
                if ((_completionSession.SelectedCompletionSet.Completions.Count > 0) && (_completionSession.SelectedCompletionSet.SelectionStatus.IsSelected))
                {
                    if (_optionsPage.AutoPairs)
                    {
                        caret = _completionSession.TextView.Caret;
                        Kind kind = Kind.Unknown;
                        var completion = _completionSession.SelectedCompletionSet.SelectionStatus.Completion;
                        if (completion is XSCompletion)
                        {
                            kind = ((XSCompletion)completion).Kind;
                        }
                        if (kind == Kind.Keyword)
                        {
                            formatKeyword(completion, '\0');
                        }
                        XSharpProjectPackage.Instance.DisplayOutPutMessage(" --> select " + completion.InsertionText);
                        if (completion.InsertionText.EndsWith("("))
                        {
                            moveBack = true;
                            completion.InsertionText += ")";
                        }
                        else if (completion.InsertionText.EndsWith("{"))
                        {
                            moveBack = true;
                            completion.InsertionText += "}";
                        }
                        else if (completion.InsertionText.EndsWith("["))
                        {
                            moveBack = true;
                            completion.InsertionText += "]";
                        }
                        else
                        {
                            switch (kind)
                            {
                                case Kind.Method:
                                case Kind.Function:
                                case Kind.Procedure:
                                case Kind.VODLL:
                                    moveBack = true;
                                    completion.InsertionText += "()";
                                    break;
                                case Kind.Constructor:
                                    moveBack = true;
                                    completion.InsertionText += "{}";
                                    break;
                            }
                        }
                    }
                    commit = true;
                }
                else if (force)
                {
                    if (completionWas != null)
                    {
                        _completionSession.SelectedCompletionSet.SelectionStatus = completionWas;
                    }
                    //
                    if (_completionSession.SelectedCompletionSet.SelectionStatus.Completion != null)
                    {
                        var completion = _completionSession.SelectedCompletionSet.SelectionStatus.Completion;
                        if (completion is XSCompletion && ((XSCompletion)completion).Kind == Kind.Keyword)
                        {
                            formatKeyword(completion, ch);
                        }
                        // Push the completion char into the InsertionText if needed
                        if (!completion.InsertionText.EndsWith(ch.ToString()))
                        {
                            completion.InsertionText += ch;
                        }
                        if (_optionsPage.AutoPairs)
                        {
                            caret = _completionSession.TextView.Caret;
                            if (ch == '(')
                            {
                                completion.InsertionText += ')';
                                moveBack = true;
                            }
                            else if (ch == '{')
                            {
                                completion.InsertionText += '}';
                                moveBack = true;
                            }
                            else if (ch == '[')
                            {
                                completion.InsertionText += ']';
                                moveBack = true;
                            }
                        }
                    }
                    commit = true;
                }
            }
            if (commit)
            {
                XSharpProjectPackage.Instance.DisplayOutPutMessage(" --> Commit");
                _completionSession.Commit();
                if (moveBack && (caret != null))
                {
                    caret.MoveToPreviousCaretPosition();
                    StartSignatureSession(false);
                }
                return true;
            }

            XSharpProjectPackage.Instance.DisplayOutPutMessage(" --> Dismiss");
            _completionSession.Dismiss();
            return false;
        }

        private string getClassification(SnapshotPoint caret)
        {
            var line = caret.GetContainingLine();
            SnapshotSpan lineSpan = new SnapshotSpan(line.Start, caret.Position - line.Start);
            var tagAggregator = _aggregator.CreateTagAggregator<IClassificationTag>(this.TextView.TextBuffer);
            var tags = tagAggregator.GetTags(lineSpan);
            var tag = tags.LastOrDefault();
            return tag?.Tag?.ClassificationType?.Classification;
        }
        private bool cursorIsInStringorComment(SnapshotPoint caret)
        {
            var classification = getClassification(caret);
            return IsCommentOrString(classification);
        }
        private bool cursorIsAfterSLComment(SnapshotPoint caret)
        {

            var classification = getClassification(caret);
            return classification != null && classification.ToLower() == "comment";
        }


        bool StartCompletionSession(uint nCmdId, char typedChar)
        {
            XSharpProjectPackage.Instance.DisplayOutPutMessage("CommandFilter.StartCompletionSession()");

            if (_completionSession != null)
            {
                if (!_completionSession.IsDismissed)
                    return false;
            }

            SnapshotPoint caret = TextView.Caret.Position.BufferPosition;
            if (cursorIsAfterSLComment(caret))
                return false;

            ITextSnapshot snapshot = caret.Snapshot;

            if (!_completionBroker.IsCompletionActive(TextView))
            {
                _completionSession = _completionBroker.CreateCompletionSession(TextView, snapshot.CreateTrackingPoint(caret, PointTrackingMode.Positive), true);
            }
            else
            {
                _completionSession = _completionBroker.GetSessions(TextView)[0];
            }

            _completionSession.Dismissed += OnCompletionSessionDismiss;
            _completionSession.Committed += OnCompletionSessionCommitted;
            _completionSession.SelectedCompletionSetChanged += _completionSession_SelectedCompletionSetChanged;

            _completionSession.Properties["Command"] = nCmdId;
            _completionSession.Properties["Char"] = typedChar;
            _completionSession.Properties["Type"] = null;
            try
            {
                _completionSession.Start();
            }
            catch (Exception e)
            {
                XSharpProjectPackage.Instance.DisplayOutPutMessage("Startcompletion failed");
                XSharpProjectPackage.Instance.DisplayException(e);
            }
            return true;
        }

        private void _completionSession_SelectedCompletionSetChanged(object sender, ValueChangedEventArgs<Microsoft.VisualStudio.Language.Intellisense.CompletionSet> e)
        {
            if (e.NewValue.SelectionStatus.IsSelected == false)
            {
                int x = 0;
                x++;
            }
        }

        private void OnCompletionSessionCommitted(object sender, EventArgs e)
        {
            // it MUST be the case....
            XSharpProjectPackage.Instance.DisplayOutPutMessage("CommandFilter.OnCompletionSessionCommitted()");

            if (_completionSession.SelectedCompletionSet.SelectionStatus.Completion != null)
            {
                if (_completionSession.SelectedCompletionSet.SelectionStatus.Completion.InsertionText.EndsWith("("))
                {
                    XSharpModel.CompletionType cType = null;
                    if (_completionSession.Properties["Type"] != null)
                    {
                        cType = (XSharpModel.CompletionType)_completionSession.Properties["Type"];
                    }
                    string method = _completionSession.SelectedCompletionSet.SelectionStatus.Completion.InsertionText;
                    method = method.Substring(0, method.Length - 1);
                    _completionSession.Dismiss();

                    StartSignatureSession(false, cType, method);
                }
            }
            //
        }

        private void OnCompletionSessionDismiss(object sender, EventArgs e)
        {
            if (_completionSession.SelectedCompletionSet != null)
            {
                _completionSession.SelectedCompletionSet.Filter();
            }
            //
            _completionSession.Dismissed -= OnCompletionSessionDismiss;
            _completionSession.Committed -= OnCompletionSessionCommitted;
            _completionSession.SelectedCompletionSetChanged -= _completionSession_SelectedCompletionSetChanged;
            _completionSession = null;
        }
        #endregion


        #region Signature Session

        bool StartSignatureSession(bool comma, XSharpModel.CompletionType cType = null, string methodName = null)
        {
            XSharpProjectPackage.Instance.DisplayOutPutMessage("CommandFilter.StartSignatureSession()");

            if (_signatureSession != null)
                return false;
            int startLineNumber = this.TextView.Caret.Position.BufferPosition.GetContainingLine().LineNumber;
            SnapshotPoint ssp = this.TextView.Caret.Position.BufferPosition;
            // when coming from the completion list then there is no need to check a lot of stuff
            // we can then simply lookup the method and that is it.
            // Also no need to filter on visibility since that has been done in the completionlist already !
            XSharpLanguage.CompletionElement gotoElement = null;
            // First, where are we ?
            int caretPos;
            int lineNumber = startLineNumber;
            //
            do
            {
                if (ssp.Position == 0)
                    break;
                ssp = ssp - 1;
                char leftCh = ssp.GetChar();
                if ((leftCh == '(') || (leftCh == '{'))
                    break;
                lineNumber = ssp.GetContainingLine().LineNumber;
            } while (startLineNumber == lineNumber);
            //
            caretPos = ssp.Position;
            var snapshot = this.TextView.TextBuffer.CurrentSnapshot;
            XSharpModel.XFile file = this.TextView.TextBuffer.GetFile();
            if (file == null)
                return false;
            //
            if (cType != null && methodName != null)
            {
                XSharpLanguage.XSharpTokenTools.SearchMethodTypeIn(cType, methodName, XSharpModel.Modifiers.Private, false, out gotoElement, file.Project.Dialect);
            }
            else
            {

                // Then, the corresponding Type/Element if possible
                IToken stopToken;
                // Check if we can get the member where we are

                XTypeMember member = XSharpLanguage.XSharpTokenTools.FindMember(lineNumber, file);
                XType currentNamespace = XSharpLanguage.XSharpTokenTools.FindNamespace(caretPos, file);
                List<String> tokenList = XSharpLanguage.XSharpTokenTools.GetTokenList(caretPos, lineNumber, snapshot, out stopToken, true, file, false, member);
                // LookUp for the BaseType, reading the TokenList (From left to right)
                string currentNS = "";
                if (currentNamespace != null)
                {
                    currentNS = currentNamespace.Name;
                }
                // We don't care of the corresponding Type, we are looking for the gotoElement
                XSharpTokenTools.RetrieveType(file, tokenList, member, currentNS, stopToken, out gotoElement, snapshot, startLineNumber, file.Project.Dialect);
            }
            //
            if ((gotoElement != null) && (gotoElement.IsInitialized))
            {
                // Not sure that this if() is still necessary ...
                //if (gotoElement.XSharpElement?.Kind == Kind.Class)
                //{
                //    XType xType = gotoElement.XSharpElement as XType;
                //    if (xType != null)
                //    {
                //        foreach (XTypeMember mbr in xType.Members)
                //        {
                //            if (string.Compare(mbr.Name, "constructor", true) == 0)
                //            {
                //                gotoElement = new CompletionElement(mbr);
                //                break;
                //            }
                //        }
                //    }
                //}

                SnapshotPoint caret = TextView.Caret.Position.BufferPosition;
                ITextSnapshot caretsnapshot = caret.Snapshot;
                //
                if (!_signatureBroker.IsSignatureHelpActive(TextView))
                {
                    _signatureSession = _signatureBroker.CreateSignatureHelpSession(TextView, caretsnapshot.CreateTrackingPoint(caret, PointTrackingMode.Positive), true);
                }
                else
                {
                    _signatureSession = _signatureBroker.GetSessions(TextView)[0];
                }

                _signatureSession.Dismissed += OnSignatureSessionDismiss;
                if (gotoElement.XSharpElement != null)
                {
                    _signatureSession.Properties["Element"] = gotoElement.XSharpElement;
                }
                else if (gotoElement.SystemElement != null)
                {
                    _signatureSession.Properties["Element"] = gotoElement.SystemElement;
                }
                _signatureSession.Properties["Line"] = startLineNumber;
                _signatureSession.Properties["Start"] = ssp.Position;
                _signatureSession.Properties["Length"] = TextView.Caret.Position.BufferPosition.Position - ssp.Position;
                _signatureSession.Properties["Comma"] = comma;
                _signatureSession.Properties["File"] = file;

                try
                {
                    _signatureSession.Start();
                }
                catch (Exception e)
                {
                    XSharpProjectPackage.Instance.DisplayOutPutMessage("Start Signature session failed:");
                    XSharpProjectPackage.Instance.DisplayException(e);
                }
            }
            //
            return true;
        }

        bool CancelSignatureSession()
        {
            if (_signatureSession == null)
                return false;

            _signatureSession.Dismiss();
            return true;
        }

        private void OnSignatureSessionDismiss(object sender, EventArgs e)
        {
            _signatureSession.Dismissed -= OnSignatureSessionDismiss;
            _signatureSession = null;
        }

        bool MoveSignature()
        {
            if (_signatureSession == null)
                return false;

            int start = (int)_signatureSession.Properties["Start"];
            int pos = this.TextView.Caret.Position.BufferPosition.Position;

            ((XSharpSignature)_signatureSession.SelectedSignature).ComputeCurrentParameter(pos - start - 1);


            return true;
        }


        #endregion

        public int QueryStatus(ref Guid pguidCmdGroup, uint cCmds, OLECMD[] prgCmds, IntPtr pCmdText)
        {
            if (pguidCmdGroup == VSConstants.VSStd2K)
            {
                switch ((VSConstants.VSStd2KCmdID)prgCmds[0].cmdID)
                {
                    case VSConstants.VSStd2KCmdID.AUTOCOMPLETE:
                    case VSConstants.VSStd2KCmdID.COMPLETEWORD:
                        prgCmds[0].cmdf = (uint)OLECMDF.OLECMDF_ENABLED | (uint)OLECMDF.OLECMDF_SUPPORTED;
                        return VSConstants.S_OK;
                }
            }
            else if (pguidCmdGroup == VSConstants.GUID_VSStandardCommandSet97)
            {
                switch ((VSConstants.VSStd97CmdID)prgCmds[0].cmdID)
                {
                    case VSConstants.VSStd97CmdID.GotoDefn:
                        prgCmds[0].cmdf = (uint)OLECMDF.OLECMDF_ENABLED | (uint)OLECMDF.OLECMDF_SUPPORTED;
                        return VSConstants.S_OK;
                }
            }
            return Next.QueryStatus(pguidCmdGroup, cCmds, prgCmds, pCmdText);
        }

    }

    static class CommandFilterHelper
    {
        /// <summary>
        /// Format the Keywords and Identifiers in the Line, using the EditSession
        /// </summary>
        /// <param name="editSession"></param>
        /// <param name="line"></param>
        static public void FormatLineIndent(ITextView TextView, ITextEdit editSession, ITextSnapshotLine line, int desiredIndentation)
        {
            XSharpProjectPackage.Instance.DisplayOutPutMessage($"CommandFilterHelper.FormatLineIndent({line.LineNumber + 1})");
            int tabSize = TextView.Options.GetTabSize();
            int indentSize = TextView.Options.GetIndentSize();
            bool useSpaces = TextView.Options.IsConvertTabsToSpacesEnabled();
            int lineLength = line.Length;

            int originalIndentLength = lineLength - line.GetText().TrimStart().Length;
            if (desiredIndentation < 0)
            {
                ; //do nothing
            }
            else if (desiredIndentation == 0)
            {
                // remove indentation
                if (originalIndentLength != 0)
                {
                    Span indentSpan = new Span(line.Start.Position, originalIndentLength);
                    editSession.Replace(indentSpan, "");
                }
            }
            else
            {
                string newIndent;
                if (useSpaces)
                {
                    newIndent = new String(' ', desiredIndentation);
                }
                else
                {
                    // fill indent room with tabs and optionally also with one or more spaces
                    // if the indentsize is not the same as the tabsize
                    int numTabs = desiredIndentation / tabSize;
                    int numSpaces = desiredIndentation % tabSize;
                    newIndent = new String('\t', numTabs);
                    if (numSpaces != 0)
                    {
                        newIndent += new String(' ', numSpaces);
                    }
                }
                if (originalIndentLength == 0)
                {
                    editSession.Insert(line.Start.Position, newIndent);
                }
                else
                {
                    Span indentSpan = new Span(line.Start.Position, originalIndentLength);
                    editSession.Replace(indentSpan, newIndent);
                }
            }
        }
    }


    internal static class ObjectBrowserHelper
    {
        private static Guid GUID_VsSymbolScope_All = new Guid(0xa5a527ea, 0xcf0a, 0x4abf, 0xb5, 0x1, 0xea, 0xfe, 0x6b, 0x3b, 0xa5, 0xc6);
        private static Guid GUID_VsSymbolScope_Solution = new Guid(0xb1ba9461, 0xfc54, 0x45b3, 0xa4, 0x84, 0xcb, 0x6d, 0xd0, 0xb9, 0x5c, 0x94);
        private static Guid GUID_VsSymbolScope_Frameworks = new Guid(0x3168518c, 0xb7c9, 0x4e0c, 0xbd, 0x51, 0xe3, 0x32, 0x1c, 0xa7, 0xb4, 0xd8);

        /*
        DEFINE_GUID(GUID_VsSymbolScope_All, 0xa5a527ea, 0xcf0a, 0x4abf, 0xb5, 0x1, 0xea, 0xfe, 0x6b, 0x3b, 0xa5, 0xc6);
        DEFINE_GUID(GUID_VsSymbolScope_OBSelectedComponents, 0x41fd0b24, 0x8d2b, 0x48c1, 0xb1, 0xda, 0xaa, 0xcf, 0x13, 0xa5, 0x57, 0xf);
        DEFINE_GUID(GUID_VsSymbolScope_FSSelectedComponents, 0xc2146638, 0xc2fe, 0x4c1e, 0xa4, 0x9d, 0x64, 0xae, 0x97, 0x1e, 0xef, 0x39);
        DEFINE_GUID(GUID_VsSymbolScope_Frameworks, 0x3168518c, 0xb7c9, 0x4e0c, 0xbd, 0x51, 0xe3, 0x32, 0x1c, 0xa7, 0xb4, 0xd8);
        DEFINE_GUID(GUID_VsSymbolScope_Solution, 0xb1ba9461, 0xfc54, 0x45b3, 0xa4, 0x84, 0xcb, 0x6d, 0xd0, 0xb9, 0x5c, 0x94);
        */

        /// <summary>
        ///     If Visual Studio's recognizes the given member and knows where its source code is, goes to the source code.
        ///     Otherwise, opens the "Find Symbols" ToolWindow.
        /// </summary>
        public static void GotoMemberDefinition(string memberName, uint searchOptions = (uint)_VSOBSEARCHOPTIONS.VSOBSO_LOOKINREFS)
        {
            gotoDefinition(memberName, _LIB_LISTTYPE.LLT_MEMBERS, searchOptions);
        }

        public static void GotoClassDefinition(string typeName, uint searchOptions = (uint)_VSOBSEARCHOPTIONS.VSOBSO_LOOKINREFS)
        {
            gotoDefinition(typeName, _LIB_LISTTYPE.LLT_CLASSES, searchOptions);
        }

        public static void FindSymbols(string memberName)
        {
            ObjectBrowserHelper.canFindSymbols(memberName, (uint)_VSOBSEARCHOPTIONS.VSOBSO_LOOKINREFS);
        }


        private static void gotoDefinition(string memberName, _LIB_LISTTYPE libListtype, uint searchOptions)
        {
            if (gotoDefinitionInternal(memberName, libListtype, searchOptions) == false)
            {
                // There was an ambiguity (more than one item found) or no items found at all.
                if (ObjectBrowserHelper.canFindAllSymbols(memberName, searchOptions) == false)
                {
                    Debug.WriteLine("Failed to FindSymbol for symbol " + memberName);
                }
            }
        }

        private static bool gotoDefinitionInternal(string typeOrMemberName, _LIB_LISTTYPE symbolType, uint searchOptions)
        {
            IVsSimpleObjectList2 list;
            if (ObjectBrowserHelper.tryFindSymbol(typeOrMemberName, out list, symbolType, searchOptions))
            {
                int ok;
                const VSOBJGOTOSRCTYPE whereToGo = VSOBJGOTOSRCTYPE.GS_DEFINITION;
                //
                return HResult.Succeeded(list.CanGoToSource(0, whereToGo, out ok)) &&
                       HResult.Succeeded(ok) &&
                       HResult.Succeeded(list.GoToSource(0, whereToGo));
            }

            return false;
        }

        // Searching in the XSharp Library (Current Solution)
        private static IVsSimpleLibrary2 GetXSharpLibrary()
        {
            Guid guid = new Guid(XSharpConstants.Library);
            IVsLibrary2 _library;
            IVsSimpleLibrary2 simpleLibrary = null;
            //
            System.IServiceProvider provider = XSharpProjectPackage.Instance;
            // ProjectPackage already switches to UI thread inside GetService
            IVsObjectManager2 mgr = provider.GetService(typeof(SVsObjectManager)) as IVsObjectManager2;
            if (mgr != null)
            {
                ErrorHandler.ThrowOnFailure(mgr.FindLibrary(ref guid, out _library));
                simpleLibrary = _library as IVsSimpleLibrary2;
            }
            return simpleLibrary;
        }

        private static bool tryGetSourceLocation(string memberName, out string fileName, out uint line, uint searchOptions)
        {
            IVsSimpleObjectList2 list;
            if (ObjectBrowserHelper.tryFindSymbol(memberName, out list, _LIB_LISTTYPE.LLT_MEMBERS, searchOptions))
            {
                return HResult.Succeeded(list.GetSourceContextWithOwnership(0, out fileName, out line));
            }

            fileName = null;
            line = 0;
            return false;
        }

        /// <summary>
        ///     Tries to find a member (field/property/event/methods/etc).
        /// </summary>
        /// <param name="typeOrMemberName">The type or member we are searching for</param>
        /// <param name="resultList">An IVsSimpleObjectList2 which contains a single result.</param>
        /// <param name="symbolType">The type of symbol we are looking for (member/class/etc)</param>
        /// <returns>
        ///     True if a unique match was found. False if the member does not exist or there was an ambiguity
        ///     (more than one member matched the search term).
        /// </returns>
        private static bool tryFindSymbol(string typeOrMemberName,
            out IVsSimpleObjectList2 resultList,
            _LIB_LISTTYPE symbolType,
            uint searchOptions)
        {
            try
            {
                // The Visual Studio API we're using here breaks with superfulous spaces
                typeOrMemberName = typeOrMemberName.Replace(" ", "");
                var library = ObjectBrowserHelper.GetXSharpLibrary();
                IVsSimpleObjectList2 list;
                var searchSucceed = HResult.Succeeded(library.GetList2((uint)symbolType,
                    (uint)_LIB_LISTFLAGS.LLF_USESEARCHFILTER,
                    createSearchCriteria(typeOrMemberName, searchOptions),
                    out list));
                if (searchSucceed && list != null)
                {
                    // Check if there is an ambiguity (where there is more than one symbol that matches)
                    if (getSymbolNames(list).Distinct().Count() == 1)
                    {
                        uint count;
                        list.GetItemCount(out count);
                        if (count > 1)
                        {
                            int ok;
                            list.CanDelete((uint)1, out ok);
                        }
                        resultList = list;
                        return true;
                    }
                }
            }
            catch (AccessViolationException e)
            {
                /* eat this type of exception (ripped from original implementation) */
                Debug.WriteLine(e.Message);
            }

            resultList = null;
            return false;
        }

        private static bool canFindSymbols(string memberName, uint searchOptions)
        {
            System.IServiceProvider provider = XSharpProjectPackage.Instance;
            bool result = true;
            // ProjectPackage already switches to UI thread inside GetService
            IVsFindSymbol searcher = provider.GetService(typeof(SVsObjectSearch)) as IVsFindSymbol;
            Assumes.Present(searcher);
            var guidSymbolScope = new Guid(XSharpConstants.Library);
            result = HResult.Succeeded(searcher.DoSearch(ref guidSymbolScope, createSearchCriteria(memberName, searchOptions)));
            return result;
        }

        private static bool canFindAllSymbols(string memberName, uint searchOptions)
        {
            System.IServiceProvider provider = XSharpProjectPackage.Instance;
            bool result= true;
            // ProjectPackage already switches to UI thread inside GetService
            IVsFindSymbol searcher = provider.GetService(typeof(SVsObjectSearch)) as IVsFindSymbol;
            Assumes.Present(searcher);
            var guidSymbolScope = ObjectBrowserHelper.GUID_VsSymbolScope_All;
            //
            result = HResult.Succeeded(searcher.DoSearch(ref guidSymbolScope, createSearchCriteria(memberName, searchOptions)));
            return result;
        }

        private static VSOBSEARCHCRITERIA2[] createSearchCriteria(string typeOrMemberName, uint searchOptions)
        {
            return new[]
            {
                new VSOBSEARCHCRITERIA2
                {
                    eSrchType = VSOBSEARCHTYPE.SO_ENTIREWORD,
                    //eSrchType = VSOBSEARCHTYPE.SO_PRESTRING,
                    //grfOptions = (uint)_VSOBSEARCHOPTIONS.VSOBSO_LOOKINREFS,
                    grfOptions = searchOptions,
                    szName = typeOrMemberName
                }
            };
        }

        private static IEnumerable<string> getSymbolNames(IVsSimpleObjectList2 list)
        {
            uint count;
            if (HResult.Succeeded(list.GetItemCount(out count)))
            {
                for (uint i = 0; i < count; i++)
                {
                    object symbol;

                    if (HResult.Succeeded(list.GetProperty(i,
                        (int)_VSOBJLISTELEMPROPID.VSOBJLISTELEMPROPID_FULLNAME,
                        out symbol)))
                    {
                        yield return (string)symbol;
                    }
                }
            }
        }
    }

    internal static class HResult
    {
        internal static bool Succeeded(int v)
        {
            return (v == VSConstants.S_OK);
        }
    }

}
