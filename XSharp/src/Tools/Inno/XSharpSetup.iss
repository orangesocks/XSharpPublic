; Please note that the "deregistering" of the XSharp association is done in a script step at the end of this file

#define Product         "XSharp"
#define ProdVer         "XSharp 0.2.4.1"
#define ProdBuild       "XSharp Beta 4"
#define Company         "XSharp BV"
#define RegCompany      "XSharpBV"
#define XSharpURL       "http://www.xsharp.info"
#define CopyRight       "Copyright � 2015-2016 XSharp B.V."
#define VIVersion       "0.2.4.2401"
#define VITextVersion   "0.2.4.2401 (Beta 4)"
#define TouchDate       "2016-05-04"
#define TouchTime       "02:04:01"
#define SetupExeName    "XSharpSetup0241"
#define InstallPath     "XSharpPath"

;Folders
#define BinFolder       "D:\Xsharp\Dev\XSharp\Binaries\Debug\"
#define BinPFolder      "D:\Xsharp\DevPublic\Binaries\Debug\"
#define CommonFolder    "D:\Xsharp\Dev\XSharp\src\Common\"
#define ToolsFolder     "d:\Xsharp\Dev\XSharp\src\Tools\"
#define VSProjectFolder "d:\Xsharp\Dev\XSharp\src\VisualStudio\XSharp.ProjectType\"
#define ExamplesFolder  "D:\Xsharp\DevPublic\Samples\"
#define OutPutFolder    "D:\XSharp\Dev\XSharp\Binaries\Setup"
#define DocFolder       "D:\Xsharp\Dev\XSharp\Binaries\Help\"
#define XIDEFolder      "D:\Xsharp\Dev\XSharp\Xide\"
#define XIDESetup       "XIDE_Set_up_1.03.exe"

#define StdFlags        "ignoreversion overwritereadonly sortfilesbyextension sortfilesbyname"
#define GACInstall      "gacinstall sharedfile uninsnosharedfileprompt uninsrestartdelete"
#define ProviderVersion "XSharp.CodeDom.XSharpCodeDomProvider, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31c59c566fa38f21"
#define ImmutableVersion "System.Collections.Immutable, Version=1.1.37.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
#define MetadataVersion  "System.Reflection.Metadata, Version=1.1.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
;#define Compression     "lzma2/ultra64"
#define Compression     "none"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{32EB192A-B120-4055-800E-74B48B80DA06}
DisableWelcomePage=no
DisableStartupPrompt=yes
DisableReadyMemo=yes
DisableFinishedPage=no
InfoBeforeFile=Baggage\ReadmeShort.rtf
AppName={#Product}
AppVersion={#VIVersion}
AppCopyright={# CopyRight}
AppVerName={#ProdVer}
AppPublisher={#Company}
AppPublisherURL={#XSharpURL}
AppSupportURL={#XSharpURL}
AppUpdatesURL={#XSharpURL}
DefaultDirName={pf}\{#Product}
DefaultGroupName={#Product}
LicenseFile=Baggage\License.rtf
OutputDir={#OutPutFolder} 
OutputBaseFilename={#SetupExeName}
OutputManifestFile=Setup-Manifest.txt
SetupIconFile=Baggage\XSharp.ico
Compression={#Compression}
SolidCompression=yes
SetupLogging=yes

; Version Info for Installer and uninstaller
VersionInfoVersion={#= VIVersion}
VersionInfoDescription={# ProdBuild}
VersionInfoCompany={# Company}
VersionInfoTextVersion={#= VITextVersion}
VersionInfoCopyRight={# CopyRight}
VersionInfoProductName={# Product}
VersionInfoProductVersion={# VIVersion}
Wizardsmallimagefile=Baggage\XSharp_Bmp_Banner.bmp 
WizardImagefile=Baggage\XSharp_Bmp_Dialog.bmp

;Uninstaller
UninstallFilesDir={app}\uninst
UninstallDisplayName={#=ProdBuild}
UninstallDisplayIcon={app}\Images\XSharp.ico;
UninstallLogMode=overwrite


TouchDate={#=TouchDate}
TouchTime={#=TouchTime}




; Make sure they are admins
PrivilegesRequired=admin
; Make sure they are running on Windows 2000 Or Higher
Minversion=6.0.600


[Components]
Name: "main";   Description: "The XSharp Compiler and Build System";  Types: full compact custom; Flags: fixed; 
Name: "vs2015"; Description: "Visual Studio 2015 Integration";        Types: full custom;                  Check: Vs2015IsInstalled;
Name: "vs2015\vulcanprg"; Description: "Keep Vulcan associated with PRG files"; Types: full custom;                  Check: VulcanPrgAssociated;
Name: "vsnext"; Description: "Visual Studio 15 Preview Integration";  Types: full custom;                  Check: VsNextIsInstalled;
Name: "xide";   Description: "Include the XIDE files";                Types: full custom;                  


[Dirs]
Name: "{app}\Assemblies"
Name: "{app}\Bin"
Name: "{app}\Help"
Name: "{app}\Images"
Name: "{app}\Include"
Name: "{app}\ProjectSystem"
Name: "{app}\Redist"
Name: "{app}\Tools"
Name: "{app}\Uninst"
Name: "{app}\Xide"
Name: "{code:GetVs2015IdeDir}\Extensions\XSharp"; Components: vs2015; 
Name: "{code:GetVsNextIdeDir}\Extensions\XSharp"; Components: vsNext; 


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "{#BinFolder}xsc.exe";                            DestDir: "{app}\bin"; Flags: {#StdFlags}; Components: main
Source: "{#BinFolder}xsc.rsp";                            DestDir: "{app}\bin"; Flags: {#StdFlags}; Components: main
Source: "{#BinFolder}XSCompiler.exe";                     DestDir: "{app}\bin"; Flags: {#StdFlags}; Components: main
Source: "{#BinFolder}XSharp.CodeAnalysis.dll";            DestDir: "{app}\bin"; Flags: {#StdFlags}; Components: main

; PDB files
Source: "{#BinFolder}XSharp.CodeAnalysis.pdb";            DestDir: "{app}\bin"; Flags: {#StdFlags}; Components: main
Source: "{#BinFolder}xsc.pdb";                            DestDir: "{app}\bin"; Flags: {#StdFlags}; Components: main
Source: "{#BinFolder}XSCompiler.pdb";                     DestDir: "{app}\bin"; Flags: {#StdFlags}; Components: main

; GAC files in Bin folder
Source: "{#BinFolder}System.Collections.Immutable.dll";   DestDir: "{app}\bin"; StrongAssemblyName: "{#ImmutableVersion}"; Flags: {#StdFlags} {#GACInstall}; components: main
Source: "{#BinFolder}System.Reflection.Metadata.dll";     DestDir: "{app}\bin"; StrongAssemblyName: "{#MetadataVersion}";    Flags: {#StdFlags} {#GACInstall}; components: main

; Support files
Source: "Baggage\Readme.rtf";                             DestDir: "{app}"    ; Flags: isreadme {#StdFlags}; Components: main
Source: "Baggage\XSharp.ico";                             DestDir: "{app}\Images"; Flags: touch {#StdFlags}; Components: main
Source: "Baggage\License.rtf";                            DestDir: "{app}";        Flags: touch {#StdFlags}; Components: main
Source: "Baggage\License.txt";                            DestDir: "{app}";        Flags: touch {#StdFlags}; Components: main

; Include Files
Source: "{#CommonFolder}*.xh";                            DestDir: "{app}\Include"; Flags: touch {#StdFlags}; Components: main

;MsBuild Files
Source: "{#BinPFolder}Xaml\*.*";                          DestDir: "{pf}\MsBuild\{#Product}\Rules";  Flags: {#StdFlags} uninsneveruninstall; Components: main
Source: "{#BinPFolder}Targets\*.*";                       DestDir: "{pf}\MsBuild\{#Product}";        Flags: {#StdFlags} uninsneveruninstall; Components: main
Source: "{#BinPFolder}XSharp.Build.dll";                  DestDir: "{pf}\MsBuild\{#Product}";        Flags: {#StdFlags} uninsneveruninstall; Components: main

;Documentation
Source: "{#DocFolder}\XSharp.pdf";                        DestDir: "{app}\Help";        Flags: touch {#StdFlags}; Components: main
Source: "{#DocFolder}\XSharp.chm";                        DestDir: "{app}\Help";        Flags: touch {#StdFlags}; Components: main

;XIDE
Source: "{#XIDEFolder}{#XIDESetup}";                      DestDir: "{app}\Xide";        Flags: touch {#StdFlags}; Components: Xide

;VsProjectSystem
Source: "{#BinPFolder}XSharpProject2015.vsix";            DestDir: "{app}\ProjectSystem"; Flags: {#StdFlags}; Components: vs2015 or vsnext

Source: "{#BinFolder}XSharp.CodeAnalysis.dll";            DestDir: "{code:GetVs2015IdeDir}\PrivateAssemblies"; Flags: {#StdFlags}; Components: vs2015
Source: "{#BinFolder}XSharp.CodeAnalysis.pdb";            DestDir: "{code:GetVs2015IdeDir}\PrivateAssemblies"; Flags: {#StdFlags}; Components: vs2015
Source: "{#BinPFolder}XSharpCodeDomProvider.dll";         DestDir: "{code:GetVs2015IdeDir}\PrivateAssemblies"; Flags: {#StdFlags} {#GACInstall}; StrongAssemblyName: "{#ProviderVersion}"; Components: vs2015
Source: "{#BinPFolder}XSharpCodeDomProvider.pdb";         DestDir: "{code:GetVs2015IdeDir}\PrivateAssemblies"; Flags: {#StdFlags}; Components: vs2015
Source: "{#BinPFolder}XSharpColorizer2015.dll";           DestDir: "{code:GetVs2015IdeDir}\Extensions\XSharp"; Flags: {#StdFlags}; Components: vs2015
Source: "{#BinPFolder}XSharpColorizer2015.pdb";           DestDir: "{code:GetVs2015IdeDir}\Extensions\XSharp"; Flags: {#StdFlags}; Components: vs2015

Source: "{#BinPFolder}Itemtemplates\*.*";                 DestDir: "{code:GetVs2015IdeDir}\Extensions\XSharp\ItemTemplates";     Flags: recursesubdirs {#StdFlags}; Components: vs2015
Source: "{#BinPFolder}ProjectTemplates\*.*";              DestDir: "{code:GetVs2015IdeDir}\Extensions\XSharp\ProjectTemplates";  Flags: recursesubdirs {#StdFlags}; Components: vs2015

Source: "{#BinPFolder}XSharpProject2015.dll";             DestDir: "{code:GetVs2015IdeDir}\Extensions\XSharp"; Flags: {#StdFlags}; Components: vs2015
Source: "{#BinPFolder}XSharpProject2015.dll.config";      DestDir: "{code:GetVs2015IdeDir}\Extensions\XSharp"; Flags: {#StdFlags}; Components: vs2015
Source: "{#BinPFolder}XSharpProject2015.pdb";             DestDir: "{code:GetVs2015IdeDir}\Extensions\XSharp"; Flags: {#StdFlags}; Components: vs2015
Source: "{#BinPFolder}XSharpProject2015.pkgdef";          DestDir: "{code:GetVs2015IdeDir}\Extensions\XSharp"; Flags: {#StdFlags}; Components: vs2015; AfterInstall: AdjustPkgDef;
Source: "{#BinPFolder}extension.vsixmanifest";            DestDir: "{code:GetVs2015IdeDir}\Extensions\XSharp"; Flags: {#StdFlags}; Components: vs2015

Source: "{#BinPFolder}XSharp.ico ";                              DestDir: "{code:GetVs2015IdeDir}\Extensions\XSharp";        Flags: {#StdFlags}; Components: vs2015
Source: "{#VsProjectFolder}Images\XSharpImages.imagemanifest";  DestDir: "{code:GetVs2015IdeDir}\Extensions\XSharp\Images";  Flags: {#StdFlags}; Components: vs2015
Source: "{#BinFolder}XSharp.CodeAnalysis.dll";                  DestDir: "{code:GetVs2015IdeDir}\Extensions\XSharp";         Flags: {#StdFlags}; Components: vs2015 

; VsNext
Source: "{#BinFolder}XSharp.CodeAnalysis.dll";            DestDir: "{code:GetVsNextIdeDir}\PrivateAssemblies"; Flags: {#StdFlags}; Components: vsnext
Source: "{#BinFolder}XSharp.CodeAnalysis.pdb";            DestDir: "{code:GetVsNextIdeDir}\PrivateAssemblies"; Flags: {#StdFlags}; Components: vsnext
Source: "{#BinPFolder}XSharpCodeDomProvider.dll";         DestDir: "{code:GetVsNextIdeDir}\PrivateAssemblies"; Flags: {#StdFlags} {#GACInstall}; StrongAssemblyName: "{#ProviderVersion}"; Components: vsnext
Source: "{#BinPFolder}XSharpCodeDomProvider.pdb";         DestDir: "{code:GetVsNextIdeDir}\PrivateAssemblies"; Flags: {#StdFlags}; Components: vsnext
Source: "{#BinPFolder}XSharpColorizer2015.dll";           DestDir: "{code:GetVsNextIdeDir}\Extensions\XSharp"; Flags: {#StdFlags}; Components: vsnext
Source: "{#BinPFolder}XSharpColorizer2015.pdb";           DestDir: "{code:GetVsNextIdeDir}\Extensions\XSharp"; Flags: {#StdFlags}; Components: vsnext

Source: "{#BinPFolder}Itemtemplates\*.*";                 DestDir: "{code:GetVsNextIdeDir}\Extensions\XSharp\ItemTemplates";     Flags: recursesubdirs {#StdFlags}; Components: vsnext
Source: "{#BinPFolder}ProjectTemplates\*.*";              DestDir: "{code:GetVsNextIdeDir}\Extensions\XSharp\ProjectTemplates";  Flags: recursesubdirs {#StdFlags}; Components: vsnext

Source: "{#BinPFolder}XSharpProject2015.dll";             DestDir: "{code:GetVsNextIdeDir}\Extensions\XSharp";  Flags: {#StdFlags}; Components: vsnext
Source: "{#BinPFolder}XSharpProject2015.dll.config";      DestDir: "{code:GetVsNextIdeDir}\Extensions\XSharp";  Flags: {#StdFlags}; Components: vsnext
Source: "{#BinPFolder}XSharpProject2015.pdb";             DestDir: "{code:GetVsNextIdeDir}\Extensions\XSharp";  Flags: {#StdFlags}; Components: vsnext
Source: "{#BinPFolder}XSharpProject2015.pkgdef";          DestDir: "{code:GetVsNextIdeDir}\Extensions\XSharp";  Flags: {#StdFlags}; Components: vsnext
Source: "{#BinPFolder}extension.vsixmanifest";            DestDir: "{code:GetVsNextIdeDir}\Extensions\XSharp";  Flags: {#StdFlags}; Components: vsnext

Source: "{#BinPFolder}XSharp.ico ";                             DestDir: "{code:GetVsNextIdeDir}\Extensions\XSharp";       Flags: {#StdFlags}; Components: vsnext
Source: "{#VsProjectFolder}Images\XSharpImages.imagemanifest";  DestDir: "{code:GetVsNextIdeDir}\Extensions\XSharp\Images"; Flags: {#StdFlags}; Components: vsnext
Source: "{#BinFolder}XSharp.CodeAnalysis.dll";                  DestDir: "{code:GetVsNextIdeDir}\Extensions\XSharp";        Flags: {#StdFlags}; Components: vsnext 

; Examples
Source: "{#ExamplesFolder}*.prg";                             DestDir: "{commondocs}\XSharp\Examples";    Flags: recursesubdirs {#StdFlags};
Source: "{#ExamplesFolder}*.txt";                             DestDir: "{commondocs}\XSharp\Examples";    Flags: recursesubdirs {#StdFlags};
Source: "{#ExamplesFolder}*.vh";                              DestDir: "{commondocs}\XSharp\Examples";    Flags: recursesubdirs {#StdFlags};
Source: "{#ExamplesFolder}*.sln";                             DestDir: "{commondocs}\XSharp\Examples";    Flags: recursesubdirs {#StdFlags};
Source: "{#ExamplesFolder}*.xsproj";                          DestDir: "{commondocs}\XSharp\Examples";    Flags: recursesubdirs {#StdFlags};


; update machine.config
Source:"{#ToolsFolder}Various\RegisterProvider.exe";          DestDir: "{app}\Tools";                     Flags: {#StdFlags}

[Icons]
Name: "{group}\{cm:ProgramOnTheWeb,{#Product}}"; Filename: "{#XSharpURL}";IconFilename:{app}\Images\XSharp.ico;
Name: "{group}\{cm:UninstallProgram,{#Product}}"; Filename: "{uninstallexe}"; 
Name: "{group}\{#Product} Documenation (CHM)"; Filename: "{app}\Help\XSharp.chm"; 
Name: "{group}\{#Product} Documenation (PDF)"; Filename: "{app}\Help\XSharp.pdf"; 
Name: "{group}\{cm:UninstallProgram,{#Product}}"; Filename: "{uninstallexe}"; 
Name: "{group}\{#Product} Examples"; Filename: "{commondocs}\XSharp\Examples";
Name: "{app}\Examples";  Filename: "{commondocs}\XSharp\Examples";


[Registry]
Root: HKLM; Subkey: "Software\{#RegCompany}"; Flags: uninsdeletekeyifempty 
Root: HKLM; Subkey: "Software\{#RegCompany}\{#Product}"; Flags: uninsdeletekey 
Root: HKLM; Subkey: "Software\{#RegCompany}\{#Product}"; ValueName: "{#InstallPath}"; ValueType: string; ValueData: "{app}" ;

[Ini]
Filename: "{code:GetVs2015IdeDir}\Extensions\extensions.configurationchanged"; Section:"XSharp"; Key: "Installed"; String: "{#VIVersion}"; Flags: uninsdeletesection; Components: vs2015;
Filename: "{code:GetVsNextIdeDir}\Extensions\extensions.configurationchanged"; Section:"XSharp"; Key: "Installed"; String: "{#VIVersion}"; Flags: uninsdeletesection; Components: vsnext;

[Run]
Filename: "{app}\Tools\RegisterProvider.exe";
Filename:  "{app}\Xide\{#XIDESetup}"; Description:"Run XIDE Installer"; Flags: postInstall;  Components: XIDE;

[UninstallRun]
; This XSharp program deletes the templates cache folder and the extensionmanager key in the registry
;Filename: "{app}\uninst\XsVsUnInst.exe"; Flags: runhidden;  Components: vs2015 ;

[InstallDelete]
; Template cache, component cache and previous installation of our project system
; vs2015
Type: filesandordirs; Name: "{localappdata}\Microsoft\VisualStudio\14.0\vtc"    ; Components: vs2015
Type: filesandordirs; Name: "{localappdata}\Microsoft\VisualStudio\14.0\ComponentModelCache"    ; Components: vs2015
Type: filesandordirs; Name: "{code:GetVs2015IdeDir}\Extensions\XSharp";       Components: vs2015
Type: files;          Name: "{code:GetVs2015IdeDir}\XSharp.CodeAnalysis.dll"; Components: vs2015
Type: files;          Name: "{code:GetVs2015IdeDir}\XSharp.CodeAnalysis.pdb"; Components: vs2015
; vsnext
Type: filesandordirs; Name: "{localappdata}\Microsoft\VisualStudio\15.0\vtc"    ; Components: vsnext
Type: filesandordirs; Name: "{localappdata}\Microsoft\VisualStudio\15.0\ComponentModelCache"    ; Components: vsnext
Type: filesandordirs; Name: "{code:GetVsNextIdeDir}\Extensions\XSharp";       Components: vsnext
Type: files;          Name: "{code:GetVsNextIdeDir}\XSharp.CodeAnalysis.dll"; Components: vsnext
Type: files;          Name: "{code:GetVsNextIdeDir}\XSharp.CodeAnalysis.pdb"; Components: vsnext

; remove the old uninstaller because the uninstall file format has changed
Type: filesandordirs; Name: "{app}\Uninst"

[UninstallDelete]
Type: filesandordirs; Name: "{app}\Assemblies"                    ; Components: main
Type: filesandordirs; Name: "{app}\Bin"                           ; Components: main
Type: filesandordirs; Name: "{app}\Help"                          ; Components: main
Type: filesandordirs; Name: "{app}\Images"                        ; Components: main
Type: filesandordirs; Name: "{app}\ProjectSystem"                 ; Components: main
Type: filesandordirs; Name: "{app}\Redist"                        ; Components: main
Type: filesandordirs; Name: "{app}\Uninst"                        ; Components: main
Type: filesandordirs; Name: "{pf}\MsBuild\{#Product}"             ; Components: main
Type: filesandordirs; Name: "{code:GetVs2015IdeDir}\Extensions\XSharp"; Components: vs2015;  
Type: filesandordirs; Name: "{code:GetVsNextIdeDir}\Extensions\XSharp"; Components: vsnext;  
Type: filesandordirs; Name: "{commondocs}\XSharp\Examples";
Type: dirifempty;     Name: "{app}"; 
Type: dirifempty;     Name: "{commondocs}\XSharp"; 

; Template cache and component cache
;vs2015
Type: filesandordirs; Name: "{localappdata}\Microsoft\VisualStudio\14.0\vtc"; 			Components: vs2015
Type: filesandordirs; Name: "{localappdata}\Microsoft\VisualStudio\14.0\ComponentModelCache"; 	Components: vs2015
;vsnext
Type: filesandordirs; Name: "{localappdata}\Microsoft\VisualStudio\15.0\vtc"; 			Components: vsnext
Type: filesandordirs; Name: "{localappdata}\Microsoft\VisualStudio\15.0\ComponentModelCache"; 	Components: vsnext

[Messages]
WelcomeLabel1=Welcome to {# Product} (X#)
WelcomeLabel2=This installer will install {#ProdBuild} on your computer.%n%nIt is recommended that you close all other applications before continuing, especially all running copies of Visual Studio.
WizardInfoBefore=Warning
InfoBeforeLabel=You are about to install Beta software
InfoBeforeClickLabel=Only continue the installation if you are aware of the following:


[Code]
Program setup;
var
  Vs2015Path : String;
  Vs2015Installed: Boolean;
  Vs2015BaseDir: String;
  VsNextPath : String;
  VsNextInstalled: Boolean;
  VsNextBaseDir: String;
  VulcanPrgAssociation: Boolean;
  VulcanGuid : String;

procedure DetectVS();
begin
  Vs2015Installed := RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\VisualStudio\SxS\VS7','14.0',Vs2015BaseDir) ;
  if Vs2015Installed then Vs2015Path := Vs2015BaseDir+'\Common7\Ide\';
  VsNextInstalled := RegQueryStringValue(HKEY_LOCAL_MACHINE,'SOFTWARE\Microsoft\VisualStudio\SxS\VS7','15.0',VsNextBaseDir) ;
  if VsNextInstalled then VsNextPath := VsNextBaseDir+'\Common7\Ide\';
  VulcanPrgAssociation := false;
  if Vs2015Installed then
  begin
  VulcanPrgAssociation := RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\Languages\File Extensions\.prg', '', VulcanGuid) ;
  if VulcanPrgAssociation then 
      begin
      VulcanPrgAssociation := (UpperCase(VulcanGuid) = '{8D3F6D25-C81C-4FD8-9599-2F72B5D4B0C9}');
      end
  end

end;


{function ResetExtensionManager: Boolean;
begin
  RegDeleteKeyIncludingSubKeys(HKEY_CURRENT_USER,'SOFTWARE\Microsoft\VisualStudio\14.0\ExtensionManager');
  result := True;
end;
}

function VulcanPrgAssociated: Boolean;
begin
  result := Vs2015Installed and VulcanPrgAssociation;
end;


function Vs2015IsInstalled: Boolean;
begin
  result := Vs2015Installed;
end;

function VsNextIsInstalled: Boolean;
begin
  result := VsNextInstalled;
end;

function GetVs2015IdeDir(Param: String): String;
begin
  result := Vs2015Path;
end;

function GetVsNextIdeDir(Param: String): String;
begin
  result := VsNextPath;
end;



function InitializeSetup(): Boolean;
var
  ErrorCode: Integer;
begin
  DetectVS();
  result := true;
  if not Vs2015Installed and not VsNextInstalled then
  begin
    if MsgBox('Visual Studio 2015 has not been detected, do you want to download the free Visual Studio Community Edition ?', mbConfirmation, MB_YESNO) = IDYES then
    begin
    ShellExec('open','https://www.visualstudio.com/en-us/downloads/download-visual-studio-vs.aspx','','',SW_SHOW,ewWaitUntilIdle, ErrorCode);
    result := false;
    end
  end;
  
end;

procedure AdjustPkgDef();
var pkgdeffile: String;
var section: String;
begin
  if IsComponentSelected('vs2015\vulcanprg') then
  begin
        pkgdeffile := Vs2015Path+'\Extensions\XSharp\XSharpProject2015.pkgdef'
        section    := '$RootKey$\Languages\File Extensions\';
        DeleteIniSection(section+'.prg', pkgdeffile);
        DeleteIniSection(section+'.ppo', pkgdeffile);
        DeleteIniSection(section+'.vh',  pkgdeffile);
        { There are duplicate sections in the file. We want to delete the 1st 3 sections for the extensions prg, ppo and vh}
        section := '$RootKey$\Editors\{b4829761-2bfa-44b7-8f8f-d2625ebcf218}\Extensions';
        DeleteIniSection(section,pkgdeffile);
        DeleteIniSection(section,pkgdeffile);
        DeleteIniSection(section,pkgdeffile);
        { Another section is in there 5 times. We can remove 4 of them }
        section := '$RootKey$\Editors\{b4829761-2bfa-44b7-8f8f-d2625ebcf218}';
        {DeleteIniSection(section,pkgdeffile);
        DeleteIniSection(section,pkgdeffile);
        DeleteIniSection(section,pkgdeffile);
        DeleteIniSection(section,pkgdeffile);}

  end;
end;

#expr SaveToFile(AddBackslash(SourcePath) + "Preprocessed.iss")