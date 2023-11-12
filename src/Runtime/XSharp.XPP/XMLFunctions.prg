//
// Copyright (c) XSharp B.V.  All Rights Reserved.
// Licensed under the Apache License, Version 2.0.
// See License.txt in the project root for license information.
//


USING System
USING System.Collections.Generic
USING System.Text
USING XSharp.XPP


/// <summary>Open an XML document. </summary>
/// <param name="cFileName">Name of an XML file to be parsed.</param>
/// <returns>Returns a non-zero numeric handle for the document, or 0 if there are not enough system resources
/// for the parser, or when the file cannot be opened, read or parsed. The handle returned by this function must be used in subsequent calls to other XMLDoc..() functions. </returns>
/// <remarks>XMLDocOpenFile() opens a new XML document. It allocates system resources for the parser, opens and reads the file and parses it contents.
/// While parsing a document, a tree is build by the parsing engine. </remarks>
FUNCTION XMLDocOpenFile( cFileName AS STRING) AS INT64
    LOCAL nErrHandle AS USUAL
    VAR nResult := XMLDocOpenFile(cFileName, OUT nErrHandle)
    XDocument.RegisterError(nErrHandle)
    RETURN nResult


/// <summary>Open an XML document. </summary>
/// <param name="cFileName">Name of an XML file to be parsed.</param>
/// <param name="nErrHandle">Pass a variable by reference which receives an error handle if errors were recorded.</param>
/// <returns>Returns a non-zero numeric handle for the document, or 0 if there are not enough system resources
/// for the parser, or when the file cannot be opened, read or parsed. The handle returned by this function must be used in subsequent calls to other XMLDoc..() functions. </returns>
/// <remarks>XMLDocOpenFile() opens a new XML document. It allocates system resources for the parser, opens and reads the file and parses it contents.
/// While parsing a document, a tree is build by the parsing engine. </remarks>
FUNCTION XMLDocOpenFile( cFileName AS STRING, nErrHandle OUT USUAL) AS INT64
    LOCAL oDoc AS XDocument
    LOCAL nResult AS INT64
    nResult := 0

    oDoc := XDocument{}
    oDoc:OpenFile(cFileName)
    nResult := oDoc:DocHandle
    IF nResult == 0
        nErrHandle := oDoc:LastError
    ELSE
        nErrHandle := NIL
    ENDIF
    RETURN nResult


/// <summary>Set action code blocks for specific tags.</summary>
/// <param name="nDocHandle">Numeric handle of the XML document.</param>
/// <param name="cNode">A character string defining one or more nodes in the XML document. See description below.</param>
/// <param name="bCallback">A code block to be associated with the nodes in an XML document specified with <paramref name="cNode" />.</param>
/// <returns>The function returns the number of tags, or nodes, matching the string <paramref name="cNode" />.</returns>
/// <remarks></remarks>

FUNCTION XMLDocSetAction( nDocHandle AS INT64, cNode AS STRING, bCallback AS CODEBLOCK) AS LONG
    LOCAL oDoc      AS XDocument
    LOCAL nActions  AS LONG
    oDoc := XDocument.GetDocument(nDocHandle)
    IF oDoc != NULL_OBJECT
        nActions := oDoc:SetAction(cNode, bCallback)
    ELSE
        nActions := 0
    ENDIF
RETURN nActions

/// <summary>Releases the action code blocks defined with XMLDocSetAction(). </summary>
/// <param name="nDocHandle">Numeric handle of an XML document.</param>
/// <returns>Returns .T. (true) if the document handle is a valid and .F. (false) otherwise.</returns>
/// <remarks>This function is used to release all action code blocks defined for all nodes of an XML document</remarks>
FUNCTION XMLDocResetAction( nDocHandle AS INT64 ) AS LOGIC
    LOCAL oDoc    AS XDocument
    LOCAL lOk     AS LOGIC
    oDoc := XDocument.GetDocument(nDocHandle)
    IF oDoc != NULL_OBJECT
        oDoc:ClearActions()
        lOk := TRUE
    ELSE
        lOk := FALSE
    ENDIF
RETURN lOk

/// <summary>Execute action code blocks for all tags. </summary>
/// <param name="nDocHandle">Numeric handle for an XML document. </param>
/// <returns>Returns .T. (true) if all action code blocks have been executed successfully or .F. (false) otherwise.</returns>
/// <remarks>This function executes all action code blocks registered for an XML document using XMLDocSetAction().</remarks>
FUNCTION XMLDocProcess(nDocHandle AS INT64) AS LOGIC
    LOCAL oDoc    AS XDocument
    LOCAL lOk     AS LOGIC
    oDoc := XDocument.GetDocument(nDocHandle)
    IF oDoc != NULL_OBJECT
        lOk := oDoc:ProcessNodes()
    ELSE
        lOk := FALSE
    ENDIF
RETURN lOk

/// <summary>Close an XML document. </summary>
/// <param name="nDocHandle"></param>
/// <returns>Returns .T. (true) if the document is successfully closed and .F. (false) otherwise.</returns>
/// <remarks>Closes XML document and releases system resources.</remarks>
FUNCTION XMLDocClose(nDocHandle AS INT64) AS LOGIC
    LOCAL oDoc  AS XDocument
    LOCAL lOk := FALSE AS LOGIC
    oDoc := XDocument.GetDocument(nDocHandle)
    IF oDoc != NULL_OBJECT
        lOk := oDoc:Close()
    ENDIF
RETURN lOk

/// <summary>Close all open XML documents.</summary>
/// <returns>Allways returns .T. (true).</returns>
/// <remarks>Closes all XML documents, clears all errors and releases system resources.</remarks>
FUNCTION XMLDocCloseAll() AS LOGIC
    RETURN XDocument.CloseAllDocuments()


/// <summary>Clear all global XML Errors.</summary>
/// <returns>Allways returns .T. (true).</returns>
/// <remarks>Closes all XML errors that are not linked to a XML document.</remarks>
FUNCTION XMLDocClearErrors() AS LOGIC
    RETURN XDocument.ClearAllErrors()

/// <summary>Get array of error descriptions. </summary>
/// <param name="nDocHandle">Numeric handle of an XML document. Use this handle if a valid document handle was returned by an doc open function. </param>
/// <param name="nErrHandle">Numeric error handle returned XMLOpenDocFile() or XMLOpenDocString(). Use this handle to retrieve errors produced by an open function, where an invalid document handle was returned. </param>
/// <returns>Returns a two-dimensional array holding error information, or NULL_ARRAY if no error occurred.</returns>
/// <remarks></remarks>

FUNCTION XMLDocGetErrorList( nDocHandle := -1 AS INT64, nErrHandle := -1 AS INT64 ) AS ARRAY
IF nDocHandle != -1
    VAR errors := XDocument.GetErrorsForDocument(nDocHandle)
    VAR aResult := {}
    FOREACH VAR error IN errors
        AAdd(aResult, error:ToArray())
    NEXT
    RETURN aResult
ELSEIF nErrHandle != -1
    LOCAL oError AS XError
    oError := XDocument.FindError(nErrHandle)
    IF oError != NULL
        RETURN { oError:ToArray() }
    ENDIF
ELSE
    VAR errors := XDocument.GetErrors()
    VAR aResult := {}
    FOREACH VAR error IN errors
        AAdd(aResult, error:ToArray())
    NEXT
    RETURN aResult
ENDIF
RETURN NULL_ARRAY

/// <summary>Get the root tag of an XML document. </summary>
/// <param name="nDocHandle">Numeric handle of an XML document. </param>
/// <returns>The function returns the numeric handle of an XML document. </returns>
/// <remarks>This function returns the root tag of an XML document.
/// The root tag is a tag that is created by the parser as the root node of the XML document tree.
/// i.e. a document has always a root tag, even if the XML file (or string) is empty.
/// This function provides for the starting point when traversing a document tree.
/// See function XMLGetTag() for more information about an XML tag. </remarks>

FUNCTION XMLDocGetRootTag( nDocHandle AS INT64 ) AS INT64
    LOCAL oDoc  AS XDocument
    LOCAL nTag  := 0 AS INT64
    oDoc := XDocument.GetDocument(nDocHandle)
    IF oDoc != NULL_OBJECT
        nTag := oDoc:RootId
    ENDIF
RETURN nTag

/// <summary>Create XML document from a string. </summary>
/// <param name="cXMLString">Character string representing a valid XML document. </param>
/// <param name="nErrHandle">Pass a variable by reference which receives an error handle if errors were recorded.</param>
/// <returns>Returns a non-zero handle for the passed string or 0 if there are not enough system resources for the parser,
/// or when the string does not contain valid XML code. The handle returned by this function must be used in subsequent
/// calls to other XMLDoc..() functions. <br/>
/// If the function returns 0, more information can be obtained by calling XMLDocGetErrorList(, <paramref name="nErrHandle" /> ). </returns>
/// <remarks>Invokes the XML parser engine which parsed the passed string and builds the internal tree structure. </remarks>
FUNCTION XMLDocOpenString( cXMLString AS STRING ,  nErrHandle OUT USUAL ) AS INT64
    LOCAL oDoc AS XDocument
    LOCAL nResult AS INT64
    nResult := 0

    oDoc := XDocument{}
    oDoc:OpenText(cXMLString)
    nResult := oDoc:DocHandle
    IF nResult == 0
        nErrHandle := oDoc:LastError
    ELSE
        nErrHandle := NIL
    ENDIF
    RETURN nResult

/// <summary>Create XML document from a string. </summary>
/// <param name="cXMLString">Character string representing a valid XML document. </param>
/// <param name="nErrHandle">Pass a variable by reference which receives an error handle if errors were recorded.</param>
/// <returns>Returns a non-zero handle for the passed string or 0 if there are not enough system resources for the parser,
/// or when the string does not contain valid XML code. The handle returned by this function must be used in subsequent
/// calls to other XMLDoc..() functions. <br/>
/// If the function returns 0, more information can be obtained by calling XMLDocGetErrorList(,<paramref name="nErrHandle" />). </returns>
/// <remarks>Invokes the XML parser engine which parsed the passed string and builds the internal tree structure. </remarks>
FUNCTION XMLDocOpenString( cXMLString AS STRING  ) AS INT64
    LOCAL nErrHandle AS USUAL
    VAR nResult := XMLDocOpenString(cXMLString, OUT nErrHandle)
    XDocument.RegisterError(nErrHandle)
    RETURN nResult

/// <summary>Get attribute value of an XML tag. </summary>
/// <param name="nTagHandle">Numeric handle of the XML tag. </param>
/// <param name="cAttributeName">Character string containing the name of the tag attribute whose value is searched.</param>
/// <returns>Returns a string representing the value of a tag attribute or NULL_STRING if no attribute with the given name exists. </returns>
/// <remarks>This function is used to obtain values of individual XML tag attributes by attribute name. </remarks>

FUNCTION XMLGetAttribute( nTagHandle AS INT64, cAttributeName AS STRING ) AS STRING
    LOCAL aTag := NIL AS USUAL
    LOCAL aAttributes AS ARRAY
    IF XMLGetTag(nTagHandle, OUT aTag)
        IF IsArray(aTag)
            IF ALen(aTag) >= XMLTAG_ATTRIB .AND. IsArray(aTag[XMLTAG_ATTRIB])
                aAttributes := aTag[XMLTAG_ATTRIB]
                FOREACH element AS ARRAY IN aAttributes
                    IF String.Compare(element[TAGATTR_NAME], cAttributeName, TRUE) == 0
                        RETURN element[TAGATTR_VALUE]
                    ENDIF
                NEXT
            ENDIF
        ENDIF
    ENDIF
RETURN NULL_STRING

/// <summary>Get child of XML tag. </summary>
/// <param name="nTagHandle">Numeric handle for the XML tag. </param>
/// <param name="cChildTagName">The tag name of the child to search.</param>
/// <returns>Returns the numeric handle of the first child matching the specified name, or 0 if no child with the given name exists. </returns>
/// <remarks>This function is used to retrieve the first child tag of an XML tag matching the name
/// specified with the second parameter. The XMLGetChildren() function can be used to obtain ALL child tags having a specific name. </remarks>

FUNCTION XMLGetChild( nTagHandle AS INT64, cChildTagName AS STRING) AS INT64
    RETURN XDocument.FindFirstChildTag(nTagHandle, cChildTagName)

/// <summary>Get array of children of an XML tag. </summary>
/// <param name="nTagHandle">Numeric handle for the XML tag. </param>
/// <param name="cChildTagName">The tag name of the child tags to search.</param>
/// <returns>Returns an array of child handles matching the name specified as second parameter, or 0 if no child with the given name exists.</returns>
/// <remarks>This function is used to retrieve all child tags having the tag name specified with the second parameter.</remarks>
FUNCTION XMLGetChildren( nTagHandle AS INT64, cChildTagName AS STRING) AS ARRAY
    RETURN XDocument.FindAllChildTags(nTagHandle, cChildTagName)

/// <summary>Get parent of XML tag.</summary>
/// <param name="nTagHandle">Numeric handle for the XML tag.</param>
/// <returns>Returns the numeric handle of the parent tag or 0 if <paramref name="nTagHandle" /> doesn't have a parent tag. </returns>
/// <remarks>This function is used to retrieve the parent tag of an XML tag. Every tag has only one parent, except the document root tag which has no parent tag. </remarks>
FUNCTION XMLGetParent( nTagHandle AS INT64) AS INT64
    RETURN XDocument.FindParent(nTagHandle)

/// <summary>Get members of an XML tag node. </summary>
/// <param name="nTagHandle">Numeric handle of an XML tag. </param>
/// <param name="aTagMember">If the function returns successfully, this parameter contains an array with all members of the tag.
/// The parameter must be passed by reference. Single elements of the array can be accessed using constants listed below.</param>
/// <returns>Returns .T. (true) if the tag is a valid tag and .F. (false) otherwise.</returns>
/// <remarks>This function is used to retrieve all members of an XML tag node.
/// The elements are the same as in Xbase++, and an extra 6th element has been added that contains the XmlNode object. </remarks>
FUNCTION XMLGetTag( nTagHandle AS INT64, aTagMember OUT USUAL ) AS LOGIC
    LOCAL aResult AS ARRAY
    aResult := XDocument.FindTag(nTagHandle)
    IF aResult != NULL_ARRAY
        aTagMember := aResult
    ELSE
        aTagMember := NULL_ARRAY
    ENDIF

RETURN aResult != NULL_ARRAY

/// <summary>Select specific nodes via xpath. </summary>
/// <param name="nDocHandle">Numeric handle for an XML document. </param>
/// <param name="cSelect">XPath select statement. </param>
/// <param name="aTagHandles">Output array </param>
/// <returns>Returns .T. (true) nDocHandle is recognized or .F. (false) otherwise.</returns>

FUNCTION XMLSelectNodes(nDocHandle AS INT64, cSelect AS STRING, aTagHandles OUT USUAL) AS LOGIC
    LOCAL oDoc    AS XDocument
    LOCAL lOk     AS LOGIC
    oDoc := XDocument.GetDocument(nDocHandle)
    IF oDoc != NULL_OBJECT
        aTagHandles := oDoc:SelectNodes(cSelect)
        lOk := TRUE
    ELSE
        aTagHandles := null_array
        lOk := FALSE
    ENDIF
    RETURN lOk


FUNCTION XmlDocExplainErrorMessage(nId AS LONG) AS STRING
SWITCH nId

CASE  XMLDOC_ERROR_NO_ERROR         ; RETURN "no error"
CASE  XMLDOC_ERROR_OUT_OF_MEMORY    ; RETURN "not enough memory "
CASE  XMLDOC_ERROR_INVALID_DTD_DECL ; RETURN "invalid DTD declaration"
CASE  XMLDOC_ERROR_INVALID_XML      ; RETURN "content outside XML tags"
CASE  XMLDOC_ERROR_ROOTTAG_EMPTY    ; RETURN "document has no root tag"
CASE  XMLDOC_ERROR_ENDTAG_MISSING   ; RETURN "invalid endtag or no endtag found"
CASE  XMLDOC_ERROR_EXPECT_DELIMIT   ; RETURN "expecting string delimiter"
CASE  XMLDOC_ERROR_UNTERM_STRING    ; RETURN "unterminated string"
CASE  XMLDOC_ERROR_FILE_NOT_FOUND   ; RETURN "file cannot be found"
CASE  XMLDOC_ERROR_READING_FILE     ; RETURN "file cannot be read"
CASE  XMLDOC_ERROR_NO_FILENAME      ; RETURN "no filename has been provided"
CASE  XMLDOC_ERROR_DUPLICATE_ATTR   ; RETURN "duplicate attribute"
CASE  XMLDOC_ERROR_MALFORMED_ATTR   ; RETURN "malformed attribute"
CASE  XMLDOC_ERROR_INVALID_ATTRNAME ; RETURN "invalid name for attribute"
CASE  XMLDOC_ERROR_PROCESS          ; RETURN "error WHILE processing action codeblocks"
END SWITCH
RETURN "unknown error"
