﻿This assembly is used for 2 purposes:

1) To Convert X# source code to a CodeModel representation of that code. 
   This mainly happens in the Windows Forms editor.
2) To generate code from a CodeModel. This is also used by the Windows Forms
   editor, but also for WPF code, Code behind Settings, Resources etc.


Normally a source file is translated to a CodeCompileUnit.
For the windows forms editor we have created a Merged CodeCompileUnit that
contains the code from the Form.Prg and Form.Designer.prg in one virtual CompileUnit.
The XMergedCompileUnit object has properties for the 2 compileunits for the form.prg and the form.designer.prg
A new CodeTypeDeclaration object is created in this compile unit that holds the members of the
CodeTypeDeclaration that was found in each of the 2 files.


Inside the project package we have a special class VSXSharpCodeDomProvider 
that takes care of splitting the code
This class implements the "normal" GenerateCodeFromCompileUnit() method.
This method recognizes that the compile unit was merged from 2 files.

We have created derived classes for many classes in the System.CodeDom namespace.
Some of these classes have extra properties. All of these classes implement IXCodeObject,
an empty interfaces, that serves as a marker that the class is ours.

When working with the form editor upon saving we may see objects that we created ourselves
when reading the source and objects that were created by the editor.


We can check the type of the objects to see the difference.
When deciding where members of the main class should go we can derive that from the type:
- When the object is a IXCodeObject then we have set a property (in the UserData) that holds
  the original location
- When the object is NOT an IXCodeObject then it is a new object generated by the FOrm Editor
  we move the methods into the form file and the fields into the Form.Designer file.
  That part of the logic is not in the CodeDomProvider assembly but in the ProjectPackage 
  (at least for now)

