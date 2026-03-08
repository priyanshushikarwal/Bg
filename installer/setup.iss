; ============================================================
; BG Manager - Inno Setup Installer Script
; Bundles all Flutter runtime, DLLs, and VC++ Redistributable
; ============================================================

#define MyAppName "BG Manager"
#define MyAppVersion "1.0.9"
#define MyAppPublisher "BG Manager"
#define MyAppExeName "bg_manager.exe"
#define MyAppURL "https://bgmanager.app"

; Paths (relative to this .iss file location)
#define BuildDir "..\build\windows\x64\runner\Release"
#define IconFile "..\windows\runner\resources\app_icon.ico"

[Setup]
; Basic app info
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

; Install location
DefaultDirName={localappdata}\{#MyAppName}
DefaultGroupName={#MyAppName}

; Output installer settings
OutputDir=..\installer_output
OutputBaseFilename=BG_Manager_Setup_v{#MyAppVersion}

; Icon
SetupIconFile={#IconFile}
UninstallDisplayIcon={app}\{#MyAppExeName}

; Compression (maximum)
Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes

; Privileges
PrivilegesRequired=lowest

; UI
WizardStyle=modern
DisableProgramGroupPage=yes
DisableWelcomePage=no

; Misc
AllowNoIcons=yes
CloseApplications=yes
RestartApplications=no

; Min Windows version (Windows 10+)
MinVersion=10.0

; Architecture - 64-bit only
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "startmenuicon"; Description: "Create a Start Menu shortcut"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
; ---- Main Application EXE ----
Source: "{#BuildDir}\bg_manager.exe"; DestDir: "{app}"; Flags: ignoreversion

; ---- Flutter Engine DLL ----
Source: "{#BuildDir}\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion

; ---- Plugin DLLs & VC++ Runtime DLLs (wildcard handling everything) ----
Source: "{#BuildDir}\*.dll"; DestDir: "{app}"; Flags: ignoreversion

; ---- Data folder (icudtl.dat, app.so, flutter_assets) ----
Source: "{#BuildDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; IconFilename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
