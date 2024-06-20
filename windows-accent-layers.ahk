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
IniRead, TIMEOUT, % OPTIONS_PATH, Options, TIMEOUT
IniRead, ACTIVE_KEYMAP, % OPTIONS_PATH, Options, ACTIVE_KEYMAP
IniRead, IGNORE_WHEN_ACTIVE, % OPTIONS_PATH, Options, IGNORE_WHEN_ACTIVE
IniRead, SUFFIX_CANCEL_MODE, % OPTIONS_PATH, Options, SUFFIX_CANCEL_MODE

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
global keyMap := { LAYER : {}, MAP : {}, TIMEOUT : {}, SPACE : {} }
KEYMAP_PATH := A_ScriptDir "\keymaps\" ACTIVE_KEYMAP

#UseHook On
HotKey, IfWinNotActive, ahk_group AccentLayersIgnore
Loop, Read, % KEYMAP_PATH
{
  if (A_LoopReadLine ~= "^\s*;") ; Comment line
    continue

  split := StrSplit(A_LoopReadLine, "=>", A_Space, 2)

  if (split.MaxIndex() = 2) {
    prefixSplit := StrSplit(split[1], A_Space, A_Space, 2)

    cmd := prefixSplit[1]
    key := prefixSplit[2]
    data := StrReplace(split[2], A_Space, "")

    if (cmd != "SUFFIX") {
      keyMap[cmd, key] := data
      HotKey, % key, % cmd == "MAP" ? "LabelCallMap" : "LabelCallAccentLayers"
    } else {
      doubleSuffixSubs := ""
      Loop, Parse, data
      {
        if (Mod(A_Index, 2) == 0) {
          trigger := SubStr(data, A_Index - 1, 1)
          subs := SubStr(data, A_Index, 1)
          Hotstring(":*?CR:" key trigger, subs)

          if (SUFFIX_CANCEL_MODE == 2) { ; Space to confirm
            Hotstring(":*?CXB0:" key " ", "LabelBackSpace") ; Hotstring(":*?CR:" key " ", key)
          } else if (SUFFIX_CANCEL_MODE == 3) { ; Double suffix to confirm
            Hotstring(":*?CR:" key key, key)
            if (key == trigger)
              doubleSuffixSubs := subs
          }
        }
      }

      if (doubleSuffixSubs)
        Hotstring(":*?CR:" key key, doubleSuffixSubs)
    }
  }
}
HotKey, IfWinNotActive

#If (not SUFFIX_CANCEL_MODE == 0)
  ~*Space::Hotstring("Reset")
#If

#UseHook Off
return

LabelCallAccentLayers:
  KeyWait, Alt
  KeyWait, LWin
  KeyWait, RWin
  Input, c, L1 T%TIMEOUT%, {LCtrl}{RCtrl}{LAlt}{RAlt}{LWin}{RWin}

  if (c == " ") {
    spaceChar := keyMap["SPACE", A_ThisHotkey]
    SendRaw, % spaceChar ? spaceChar : c
  } else if (ErrorLevel == "Timeout") {
    SendRaw, % keyMap["TIMEOUT", A_ThisHotkey]
  } else if (ErrorLevel != "Max") {
    return
  } else {
    layerMap := keyMap["LAYER", A_ThisHotkey]
    if (i := InStr(layerMap, c, true))
      c := SubStr(layerMap, i + 1, 1)

    SendInput, % c
  }
return

LabelCallMap:
  SendRaw, % keymap["MAP", A_ThisHotkey]
return

LabelBackSpace:
  Send, {BackSpace}
return