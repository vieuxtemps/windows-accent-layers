#Persistent
#SingleInstance Force

;@Ahk2Exe-SetMainIcon icon.ico
;@Ahk2Exe-Obey U_Version, FileRead U_Version`, version
;@Ahk2Exe-SetFileVersion %U_Version%
;@Ahk2Exe-SetProductVersion Build v%U_Version% AutoHotkey v%A_AhkVersion%

Menu, Tray, Tip, Windows Accent Layers

OPTIONS_PATH := A_ScriptDir "\options.ini"

; Read options.ini
IniRead, HIDE_TRAY_ICON, % OPTIONS_PATH, Options, HIDE_TRAY_ICON, 0
IniRead, DELIMITER, % OPTIONS_PATH, Options, DELIMITER, =
IniRead, TIMEOUT, % OPTIONS_PATH, Options, TIMEOUT
IniRead, ACTIVE_KEYMAP, % OPTIONS_PATH, Options, ACTIVE_KEYMAP
IniRead, IGNORE_WHEN_ACTIVE, % OPTIONS_PATH, Options, IGNORE_WHEN_ACTIVE

if (HIDE_TRAY_ICON)
  Menu, Tray, NoIcon
else if (not A_IsCompiled)
  Menu, Tray, Icon, icon.ico, , 1

; Read ignored apps and add it to the ignore group
for index, element in StrSplit(IGNORE_WHEN_ACTIVE, ",", A_Space) {
  if (element and element != "ERROR")
    GroupAdd, AccentLayersIgnore, ahk_exe %element%
}

; Read [ACTIVE_KEYMAP]
global layerMap := []
global spaceMap := []
global timeoutMap := []
KEYMAP_PATH := A_ScriptDir "\keymaps\" ACTIVE_KEYMAP

#UseHook On
HotKey, IfWinNotActive, ahk_group AccentLayersIgnore
Loop, Read, % KEYMAP_PATH
{
  line := StrSplit(A_LoopReadLine, DELIMITER, A_Space, 2)

  if (line.MaxIndex() > 1) {
    key := line[1]
    value := line[2]

    if (key ~= "\(") { ; Comment line
      continue
    } else if (key ~= "^SPACE") {
      key := StrSplit(key, "SPACE", A_Space)[2]
      spaceMap[key] := value
      continue
    } else if (key ~= "^TIMEOUT") {
      key := StrSplit(key, "TIMEOUT", A_Space)[2]
      timeoutMap[key] := value
      continue
    }

    layerMap[key] := value
    HotKey, % key, LabelCallAccentLayers
  }
}
HotKey, IfWinNotActive
#UseHook Off

LabelCallAccentLayers:
  map := layerMap[A_ThisHotkey]
  if (not map)
    return

  KeyWait, Alt
  Input, c, L1 T%TIMEOUT%, {LCtrl}{RCtrl}{LAlt}{RAlt}{LWin}{RWin}

  if (c = " ") {
    spaceChar := spaceMap[A_ThisHotkey]
    SendInput, % spaceChar ? spaceChar : c
    return
  } else if (ErrorLevel = "Timeout") {
    c := timeoutMap[A_ThisHotkey]
    SendInput, % c
    return
  } else if (ErrorLevel != "Max")
    return

  if (i := InStr(map, c, true))
    c := SubStr(map, i + 1, 1)

  SendInput, % c
return
