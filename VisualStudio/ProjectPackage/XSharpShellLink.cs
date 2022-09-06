﻿using System;
using XSharpModel;
using Community.VisualStudio.Toolkit;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.TextManager.Interop;

namespace XSharp.Project
{
    internal class XSharpShellLink : IXVsShellLink
    {

        bool building;
        bool success;


        internal XSharpShellLink()
        {
            ThreadHelper.JoinableTaskFactory.Run(async delegate
           {
               await ThreadHelper.JoinableTaskFactory.SwitchToMainThreadAsync();
               VS.Events.SolutionEvents.OnBeforeOpenSolution += SolutionEvents_OnBeforeOpenSolution;
               VS.Events.SolutionEvents.OnAfterOpenSolution += SolutionEvents_OnAfterOpenSolution;
               VS.Events.SolutionEvents.OnAfterCloseSolution += SolutionEvents_OnAfterCloseSolution;
               VS.Events.SolutionEvents.OnBeforeCloseSolution += SolutionEvents_OnBeforeCloseSolution;
               VS.Events.SolutionEvents.OnBeforeOpenProject += SolutionEvents_OnBeforeOpenProject;
               VS.Events.SolutionEvents.OnAfterOpenProject += SolutionEvents_OnAfterOpenProject;
               VS.Events.SolutionEvents.OnBeforeCloseProject += SolutionEvents_OnBeforeCloseProject;
               VS.Events.SolutionEvents.OnAfterRenameProject += SolutionEvents_OnAfterRenameProject;
               VS.Events.BuildEvents.SolutionBuildStarted += BuildEvents_SolutionBuildStarted;
               VS.Events.BuildEvents.SolutionBuildDone += BuildEvents_SolutionBuildDone;
               VS.Events.BuildEvents.SolutionBuildCancelled += BuildEvents_SolutionBuildCancelled;
           });

        }

        private void SolutionEvents_OnAfterRenameProject(Community.VisualStudio.Toolkit.Project obj)
        {
            Logger.SingleLine();
            Logger.Information("Renamed project: " + obj?.FullPath ?? "");
            Logger.SingleLine();
        }

        private void SolutionEvents_OnBeforeCloseProject(Community.VisualStudio.Toolkit.Project obj)
        {
            Logger.SingleLine();
            Logger.Information("Closing project: " + obj?.FullPath ?? "");
            Logger.SingleLine();

        }

        private void SolutionEvents_OnAfterOpenProject(Community.VisualStudio.Toolkit.Project obj)
        {
            Logger.SingleLine();
            Logger.Information("Opened project: " + obj?.FullPath ?? "");
            Logger.SingleLine();
        }

        private void SolutionEvents_OnBeforeOpenProject(string obj)
        {
            Logger.SingleLine();
            Logger.Information("Opening project: " + obj ?? "");
            Logger.SingleLine();
        }

        string solutionName = "";
        private void SolutionEvents_OnBeforeCloseSolution()
        {
            Logger.SingleLine();
            Logger.Information("Closing solution: " + solutionName);
            Logger.SingleLine();
        }

        private void SolutionEvents_OnAfterCloseSolution()
        {

            Logger.SingleLine();
            Logger.Information("Closed solution: " + solutionName);
            Logger.SingleLine();
            solutionName = "";
        }

        private void SolutionEvents_OnAfterOpenSolution(Solution obj)
        {
            Logger.SingleLine();
            Logger.Information("Opened Solution: " + obj?.FullPath ?? "");
            Logger.SingleLine();
            solutionName = obj?.FullPath;
        }

        private void SolutionEvents_OnBeforeOpenSolution(string obj)
        {
            Logger.SingleLine();
            Logger.Information("Opening Solution: " + obj ?? "");
            Logger.SingleLine();
            solutionName = obj;
        }

        private void BuildEvents_SolutionBuildCancelled()
        {
            building = false;
            // Start or Resume the model walker
            XSharpModel.ModelWalker.Start();
        }

        private void BuildEvents_SolutionBuildDone(bool result)
        {
            building = false;
            success = result;
            // Start or Resume the model walker
            XSharpModel.ModelWalker.Start();
        }

        private void BuildEvents_SolutionBuildStarted(object sender, EventArgs e)
        {
            building = true;
            if (XSharpModel.ModelWalker.IsRunning)
            {
                // Do not walk while building
                XSharpModel.ModelWalker.Suspend();
            }
        }

        public void SetStatusBarAnimation(bool onOff, short id)
        {
            if (onOff)
                VS.StatusBar.StartAnimationAsync((StatusAnimation)id).FireAndForget();
            else
                VS.StatusBar.EndAnimationAsync((StatusAnimation)id).FireAndForget();

        }

        public void SetStatusBarProgress(string cMessage, int nItem, int nTotal)
        {
            VS.StatusBar.ShowProgressAsync(cMessage, nItem, nTotal).FireAndForget();
        }

        public void SetStatusBarText(string cText)
        {
            VS.StatusBar.ShowMessageAsync(cText).FireAndForget();
        }

        public int ShowMessageBox(string message)
        {
            string title = string.Empty;
            return (int)VS.MessageBox.Show(title, message);
        }

        public void LogException(Exception ex, string msg)
        {
            Logger.Exception(ex, msg);
            XSharpOutputPane.DisplayException(ex);
        }

        public void LogMessage(string message)
        {
            Logger.Information(message);
            XSharpOutputPane.DisplayOutputMessage(message);
        }

        /// <summary>
        /// Open a document with 0 based line numbers
        /// </summary>
        /// <param name="file"></param>
        /// <param name="line"></param>
        /// <param name="column"></param>
        /// <param name="preview"></param>
        /// <returns></returns>
        private async System.Threading.Tasks.Task OpenDocumentAsync(string file, int line, int column, bool preview)
        {
            try
            {
                DocumentView view;
                if (preview)
                {
                    view = await VS.Documents.OpenInPreviewTabAsync(file);
                }
                else
                {
                    view = await VS.Documents.OpenViaProjectAsync(file);
                    if (view == null)
                    {
                        view = await VS.Documents.OpenAsync(file);
                    }
                }
                IVsTextView textView = null;
                if (view != null)
                {
                    textView = await view.TextView.ToIVsTextViewAsync();
                }
                if (textView != null)
                {
                    //
                    TextSpan span = new TextSpan();
                    span.iStartLine = line ;
                    span.iStartIndex = column;
                    span.iEndLine = line ;
                    span.iEndIndex = column;
                    //
                    textView.SetCaretPos(span.iStartLine, span.iStartIndex);
                    textView.EnsureSpanVisible(span);
                    if (span.iStartLine > 5)
                        textView.SetTopLine(span.iStartLine - 5);
                    else
                        textView.SetTopLine(0);
                    textView.SetCaretPos(line, column);
                }
                if (preview)
                    await VS.Documents.OpenInPreviewTabAsync(file);
                else
                    await VS.Documents.OpenAsync(file);
            }
            catch (Exception)
            {

                throw;
            }

        }

        public bool IsDocumentOpen(string file)
        {
            return ThreadHelper.JoinableTaskFactory.Run(async delegate
            {
                return await VS.Documents.IsOpenAsync(file);
            });
        }
        /// <summary>
        /// OPen a document with 0 based line/column numbers
        /// </summary>
        /// <param name="file"></param>
        /// <param name="line"></param>
        /// <param name="column"></param>
        /// <param name="preview"></param>
        public void OpenDocument(string file, int line, int column, bool preview)
        {
            OpenDocumentAsync(file, line, column, preview).FireAndForget();
        }

        public bool IsVsBuilding => building;
        public bool LastBuildResult => success;


    }
}
