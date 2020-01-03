﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.Package;
using Microsoft.VisualStudio.TextManager.Interop;
using Microsoft.VisualStudio.OLE.Interop;

namespace XSharp.LanguageService
{
    class XSharpSource : Source
    {
        public XSharpSource(XSharpLanguageService service,
                        IVsTextLines textLines,
                        Colorizer colorizer)
            : base(service, textLines, colorizer)
        {

        }
        // This class is only used for commenting.
        // Once that has been moved to MEF we can remove the class
        public override TextSpan UncommentSpan(TextSpan span)
        {
            CommentInfo commentFormat = this.GetCommentFormat();
            var source = GetText(span.iStartLine, span.iStartIndex, span.iStartLine, span.iStartIndex + 2).Trim();
            if (source == commentFormat.BlockStart)
            {
                return this.UncommentBlock(span, commentFormat.BlockStart, commentFormat.BlockEnd);
            }
            //
            return this.xsUnCommentLines(span, commentFormat.LineStart);
            //
            //return base.UncommentLines(span, commentFormat.LineStart);
        }
        public override TextSpan CommentSpan(TextSpan span)
        {
            TextSpan span2 = span;
            CommentInfo commentFormat = this.GetCommentFormat();
            if (span.iStartLine == span.iEndLine )
            {
                if (span.iStartIndex != span.iEndIndex)
                    commentFormat.UseLineComments = false;
                else
                    commentFormat.UseLineComments = true;
            }
            else
            {
                // is the cursor in the middle of a line, iow is there non whitespace before the cursor ?
                var source = GetText(span.iStartLine, 0, span.iStartLine, span.iStartIndex).Trim();
                if (source.Length > 0)
                {
                    commentFormat.UseLineComments = false;
                }
            }
            using (new CompoundAction(this, "CommentSelection"))
            {
                if (commentFormat.UseLineComments && !string.IsNullOrEmpty(commentFormat.LineStart))
                {
                    if (span.iStartIndex == 0 && span.iEndIndex == 0)
                    {
                        if (span.iEndLine > span.iStartLine)
                        {
                            span.iEndLine--;
                        }
                    }
                    // Use our own to align comment
                    span2 = this.xsCommentLines(span, commentFormat.LineStart);
                    return span2;
                }
                if (!string.IsNullOrEmpty(commentFormat.BlockStart) && !string.IsNullOrEmpty(commentFormat.BlockEnd))
                {
                    span2 = this.CommentBlock(span, commentFormat.BlockStart, commentFormat.BlockEnd);
                }
            }
            return span2;
        }

        private TextSpan xsCommentLines(TextSpan span, string commentStart)
        {
            int commentpos = 0;
            // First Search the min position for comment
            for (int line = span.iStartLine; line <= span.iEndLine; line++)
            {
                int pos = ScanToNonWhitespaceChar(line);
                if (pos < GetLineLength(line))
                {
                    commentpos = Math.Min(commentpos, pos);
                }
            }
            // Apply
            for (int line = span.iStartLine; line <= span.iEndLine; line++)
            {
                SetText(line, commentpos, line, commentpos, commentStart);
            }
            return span;
        }

        private TextSpan xsUnCommentLines(TextSpan span, string commentStart)
        {
            // Empty selection ?
            if (span.iStartLine == span.iEndLine && span.iStartIndex == span.iEndIndex)
            {
                int len = commentStart.Length;
                int commentpos = ScanToNonWhitespaceChar(span.iStartLine);
                string text = GetLine(span.iStartLine);
                if (text.Substring(commentpos, len) == commentStart)
                {
                    using (new CompoundAction(this, "Uncomment Selection"))
                    {
                        SetText(span.iStartLine, commentpos, span.iStartLine, commentpos + len, "");
                    }
                }
            }
            else
            {
                using (new CompoundAction(this, "Uncomment Selection"))
                {
                    int len = commentStart.Length;
                    var spaces = new string(' ', len);
                    for (int line = span.iStartLine; line <= span.iEndLine; line++)
                    {
                        int commentpos = ScanToNonWhitespaceChar(line);
                        string text = GetLine(line);
                        if (text.Substring(commentpos, len) == commentStart)
                        {
                            if (text.Length > len )
                                SetText(line, commentpos, line, commentpos + len, "");
                            else
                                SetText(line, commentpos, line, commentpos + len, spaces);
                        }
                    }
                }
            }
            return span;
        }

    }
}
