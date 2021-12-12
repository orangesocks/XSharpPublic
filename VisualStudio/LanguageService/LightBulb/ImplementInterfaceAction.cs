﻿using Microsoft.VisualStudio.Language.Intellisense;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.VisualStudio.Imaging.Interop;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using Microsoft.VisualStudio.Text;
using System.Threading;
using XSharpModel;
using System.Reflection;
using Microsoft.VisualStudio.Text.Editor;
using XSharp.LanguageService;
using System.Collections.Immutable;
using Microsoft.VisualStudio.Text.Adornments;
using System.Text;
using System.Linq;

namespace XSharp.Project.Editors.LightBulb
{
    internal class ImplementInterfaceSuggestedAction : ISuggestedAction
    {
        private string m_interface;
        private ITextSnapshot m_snapshot;
        private ITextView m_textView;
        private IXTypeSymbol _classEntity;
        private List<XSourceMemberSymbol> _members;
        private XSharpModel.TextRange _range;

        public ImplementInterfaceSuggestedAction(ITextView textView, ITextBuffer m_textBuffer, string intface, IXTypeSymbol entity, List<XSourceMemberSymbol> memberstoAdd, XSharpModel.TextRange range)
        {
            m_snapshot = m_textBuffer.CurrentSnapshot;
            m_interface = intface;
            m_textView = textView;
            _classEntity = entity;
            _members = memberstoAdd;
            _range = range;
        }

        public Task<object> GetPreviewAsync(CancellationToken cancellationToken)
        {
            int count = 0;
            List<Inline> content = new List<Inline>();
            int max = _members.Count;
            foreach (IXMemberSymbol mbr in _members)
            {
                Run temp = new Run(mbr.Description + Environment.NewLine);
                content.Add(temp);
                count++;
                if ((count >= 3) && (max > 3))
                {
                    temp = new Run("..." + Environment.NewLine);
                    content.Add(temp);
                    temp = new Run(max.ToString() + " total members." + Environment.NewLine);
                    content.Add(temp);
                    break;
                }
            }
            // Create a "simple" list... Would be cool to have Colors...
            var textBlock = new TextBlock();
            textBlock.Padding = new Thickness(5);
            textBlock.Inlines.AddRange(content);
            return Task.FromResult<object>(textBlock);
        }

        public Task<IEnumerable<SuggestedActionSet>> GetActionSetsAsync(CancellationToken cancellationToken)
        {
            return Task.FromResult<IEnumerable<SuggestedActionSet>>(null);
        }

        public bool HasActionSets
        {
            get { return false; }
        }
        public string DisplayText
        {
            get { return "Implement " + m_interface; }
        }
        public ImageMoniker IconMoniker
        {
            get { return default(ImageMoniker); }
        }
        public string IconAutomationText
        {
            get
            {
                return null;
            }
        }
        public string InputGestureText
        {
            get
            {
                return null;
            }
        }
        public bool HasPreview
        {
            get { return true; }
        }

        public void Dispose()
        {
        }

        public bool TryGetTelemetryId(out Guid telemetryId)
        {
            // This is a sample action and doesn't participate in LightBulb telemetry  
            telemetryId = Guid.Empty;
            return false;
        }

        // The job is done here !!
        public void Invoke(CancellationToken cancellationToken)
        {
            var settings = m_textView.TextBuffer.Properties.GetProperty<SourceCodeEditorSettings>(typeof(SourceCodeEditorSettings));
            //m_span.TextBuffer.Replace(m_span.GetSpan(m_snapshot), ");
            StringBuilder insertText;
            // First line of the Entity
            ITextSnapshotLine firstLine = m_snapshot.GetLineFromLineNumber(_range.EndLine);
            // Retrieve the text
            string lineText = firstLine.GetText();
            // and count how many spaces we have before
            int count = lineText.TakeWhile(Char.IsWhiteSpace).Count();
            // Get these plus one as prefix
            string prefix = lineText.Substring(0, count) + new String(' ', settings.IndentSize);
            ITextSnapshotLine lastLine = m_snapshot.GetLineFromLineNumber(_range.EndLine);
            List<Inline> content = new List<Inline>();
            // Add a comment with the Interface name ??
            insertText = new StringBuilder();
            insertText.AppendLine();
            insertText.Append(prefix);
            insertText.AppendLine("#region Implement " + m_interface);
            insertText.AppendLine();
            foreach (XSourceMemberSymbol mbr in _members)
            {
                // Todo : Check these
                // Add XML doc on top of generated member ? <- Could be a Setting ?
                // Add a return with default value ? <- Could be a Setting ?
                // Add a THROW NotImplementedException ? <- Could be a Setting ?
                insertText.Append(prefix);
                insertText.AppendLine(mbr.Description);
                //                if (Kind.IsMethod(mbr.Kind))
                if ( mbr.Kind.IsMethod() )
                {
                    insertText.Append(prefix);
                    insertText.Append(' ', settings.IndentSize);
                    insertText.AppendLine("THROW NotImplementedException{}");
                    insertText.Append(prefix);
                    insertText.Append(' ', settings.IndentSize);
                    insertText.Append("RETURN ");
                    if (mbr.Kind.HasReturnType())
                    {
                        if ((string.Compare(mbr.ReturnType, "void", true) != 0))
                        {
                            insertText.Append(poorManDefaultValue(mbr.ReturnType));
                            insertText.AppendLine();
                        }
                    }
                }
                insertText.AppendLine();
            }
            insertText.Append(prefix);
            insertText.AppendLine("#endregion");
            // Create an Edit Session
            var editSession = m_textView.TextBuffer.CreateEdit();
            try
            {
                // Inject code
                editSession.Insert(lastLine.Start.Position, insertText.ToString());
            }
            catch (Exception e)
            {
                WriteOutputMessage("editSession : error " + e.Message);
            }
            finally
            {
                // Validate the Edit Session ?
                if (editSession.HasEffectiveChanges)
                {
                    editSession.Apply();

                }
                else
                {
                    editSession.Cancel();
                }
                //
            }
        }

        /// <summary>
        /// Try to infer a default value
        /// </summary>
        /// <param name="returnType"></param>
        /// <returns></returns>
        private string poorManDefaultValue(string returnType)
        {
            string ret = "";
            returnType = returnType.ToLower();
            switch (returnType)
            {
                case "int":
                case "long":
                case "float":
                case "double":
                    ret = "0";
                    break;
                case "boolean":
                case "logic":
                    ret = "false";
                    break;
                default:
                    ret = "null";
                    break;
            }
            return ret;
        }


        internal void WriteOutputMessage(string strMessage)
        {
            if (XSettings.EnableParameterLog && XSettings.EnableLogging)
            {
                XSettings.DisplayOutputMessage("ImplementInterfaceSuggestedAction:" + strMessage);
            }
        }


    }






}
