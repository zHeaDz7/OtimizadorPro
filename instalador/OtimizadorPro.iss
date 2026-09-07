; Instalador do OtimizadorPro (Inno Setup -- https://jrsoftware.org/isinfo.php)
;
; IMPORTANTE: isso NAO compila nem ofusca os scripts. Ele so copia os
; arquivos .ps1/.bat exatamente como estao (continuam abriveis no bloco
; de notas) pra uma pasta em Programas, cria atalho no Menu Iniciar e
; um desinstalador -- conveniencia de instalacao, sem comprometer a
; transparencia que e o diferencial do produto.
;
; Como gerar o instalador:
;   1. Instale o Inno Setup (gratuito): jrsoftware.org/isdl.php
;   2. Abra este arquivo .iss nele
;   3. Build > Compile (ou F9)
;   4. O instalador .exe sai em instalador\Output\

#define MyAppName "OtimizadorPro"
#define MyAppVersion "1.0"
#define MyAppPublisher "OtimizadorPro"
#define MyAppExeName "Otimizar.bat"

[Setup]
AppId={{B4C1E9F0-6E3A-4B2D-9C1A-OTIMIZADORPRO}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=Output
OutputBaseFilename=OtimizadorPro-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Files]
; Copia TUDO da pasta do projeto (scripts .ps1 continuam texto puro,
; nada aqui e compilado ou empacotado num binario)
Source: "..\Otimizar.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LEIA-ME.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\README-EN.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\scripts\*"; DestDir: "{app}\scripts"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{group}\Desinstalar {#MyAppName}"; Filename: "{uninstallexe}"

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na Area de Trabalho"; GroupDescription: "Atalhos:"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Abrir o OtimizadorPro agora"; Flags: postinstall nowait skipifsilent shellexec
