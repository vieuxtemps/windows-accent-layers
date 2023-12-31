#Persistent
#SingleInstance Force
#MaxHotkeysPerInterval 300
SetKeyDelay, -1

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
IniRead, PREFIX_CANCEL_MODE, % OPTIONS_PATH, Options, PREFIX_CANCEL_MODE
IniRead, PREFIX_TIMEOUT, % OPTIONS_PATH, Options, PREFIX_TIMEOUT
PREFIX_TIMEOUT *= 1000

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
global keyMap := { LAYER : {}, MAP : {}, TIMEOUT : {}, SPACE : {}, PREFIX: {} }
global pressTime := {}
global prefix := ""
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

    data := cmd == "PREFIXMAP" ? split[2] : StrReplace(split[2], A_Space, "")

    keyMap[cmd, key] := data

    if (cmd == "LAYER") {
      HotKey, % key, LabelCallAccentLayers
    } else if (cmd == "MAP") {
      HotKey, % key, LabelCallMap
    } else if (cmd == "PREFIXMAP") {
      Hotstring(":*?CR:" key, data)
    } else if (cmd == "PREFIX") {
      Loop, Parse, data ; Loop PREFIX's data line
      {
        if (Mod(A_Index, 2) == 1)
          continue

        trigger := SubStr(data, A_Index - 1, 1)
        subs := SubStr(data, A_Index, 1)

        if (PREFIX_CANCEL_MODE < 4) ; If PREFIX cancel mode has no timeout
          Hotstring(":*?CR:" key trigger, subs) ; Registers default activation

        if (PREFIX_CANCEL_MODE == 2) { ; Space to confirm
          Hotstring(":*?CXB0:" key " ", "LabelBackSpace") ; BackSpace (right-to-left)
          ; Hotstring(":*?CR:" key " ", key) ; BackSpace (left-to-right)
        } else if (PREFIX_CANCEL_MODE == 3) { ; Double prefix to confirm
          Hotstring(":*?CR:" key key, key)
          if (key == trigger) ; Replacing with 'subs' has higher priority over confirming prefix
            forcedDoublePrefixSubs := subs
        } else if (PREFIX_CANCEL_MODE == 4) { ; Prefix timeout
          Hotstring(":*?CRXB0:" key trigger, "LabelPrefixCheckTimeout")

          if (StrLen(key) == 1)
            HotKey, % "~" key, % "LabelSetPrefixTimeout"
          else
            Hotstring(":*?CRXB0:" key, "LabelSetPrefixTimeoutMulti")
        }
      } ; END Loop PREFIX's data line

      ; For cancel mode 3 (double prefix): sends a substitution instead of confirming the prefix
      if (forcedDoublePrefixSubs) {
        Hotstring(":*?CR:" key key, forcedDoublePrefixSubs)
        Hotstring(":*?CR:" key " ", key) ; Makes it instantly cancellable with Space
      }
      ; END PREFIX
    }
  }
}
HotKey, IfWinNotActive

#If (not PREFIX_CANCEL_MODE == 0)
  ~*Space::Hotstring("Reset")
#If

#UseHook Off
return

Translate(map, char) {
  pos := InStr(map, char, true)
  return pos > 0 ? SubStr(map, pos + 1, 1) : char
}

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
    SendInput, % Translate(keyMap["LAYER", A_ThisHotkey], c)
  }
return

LabelCallMap:
  SendRaw, % keymap["MAP", A_ThisHotkey]
return

LabelBackSpace:
  SendInput, {BackSpace}
return

LabelPrefixCheckTimeout:
  if (A_TickCount - pressTime[prefix] <= PREFIX_TIMEOUT) {
    rhs := StrSplit(A_ThisHotkey, ":")[3]
    key := SubStr(rhs, 1, StrLen(rhs) - 1)
    trigger := SubStr(rhs, StrLen(rhs), 1)
    SendInput, % "{BackSpace " StrLen(rhs) "}"
    SendRaw, % Translate(keyMap["PREFIX", key], trigger)
  }
return

LabelSetPrefixTimeout:
  prefix := SubStr(A_ThisHotkey, 2)
  pressTime[prefix] := A_TickCount
return

LabelSetPrefixTimeoutMulti:
  prefix := StrSplit(A_ThisHotkey, ":", A_Space)[3]
  pressTime[prefix] := A_TickCount
return
