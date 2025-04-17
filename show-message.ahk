global TaskbarHeight := 0
WinGetPos,,, TaskbarWidth, TaskbarHeight, ahk_class Shell_TrayWnd
global xPos := LAYOUT_SWITCH_X_OFFSET

global yPos := A_ScreenHeight - TaskbarHeight + 8 + LAYOUT_SWITCH_Y_OFFSET

; Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow
Gui, +LastFound -Caption +ToolWindow
Gui, Color, 000000

Gui, Font, s10 cWhite w700 q3, Verdana

WinSet, ExStyle, +0x20 ; Make the GUI window click-through
WinSet, Transparent, 215

WinSet, TransColor, 000000 215

Gui, Add, Text, vMode Center w%A_ScreenWidth% h18, 0

ShowMessage(message, color := "White", timer := false) {
  if (not message) {
    Gui, Show, Hide
    return
  }

  GuiControl,, Mode, %message%
  Gui, Font, c%color%
  GuiControl, Font, Mode
  try {
    Gui, Show, X%xPos% Y%yPos% NA
  }
  SetTimer, DisableMessage, Delete
  if (timer)
    SetTimer, DisableMessage, -%timer%
  return
  DisableMessage:
    Gui, Show, Hide
  return
}
