# Windows Accent Layers

<p align="center">
  <img src="icon.ico" />
</p>

Windows Accent Layers enables macOS-style input of diacritics/accented characters and other special symbols on Windows, without the need for swapping your current keyboard layout. You can also easily customize or create new layouts with one-line definitions.

<p align="center">
  <img src="demo.gif" />
</p>

# Accent Layers
This tool is based on the concept of using a hotkey to activate a layer, then inputting a single character to generate an accented or special character. This is one of the methods for quickly typing such characters on macOS (see [[1]](https://support.apple.com/en-is/guide/mac-help/mh27474/mac)[[2]](https://www.reed.edu/it/help/diacritics.html) for more information).

For instance, to produce `é` on macOS, you would press `Option+e`, followed by `e`. To achieve the same with windows-accent-layers, you would press `Alt+e`, followed by `e`. Such definitions are completely customizable and easy to edit. A layer for acute accents (with `Alt+e` activation) can be defined as follows:
```
LAYER !e => aá eé ií oó uú AÁ EÉ IÍ OÓ UÚ
```

With `LAYER` definitions, typing a character after activating a layer will replace it by the character directly to its right. For example, `a` would be replaced by `á` in this layer. This operation is always case-sensitive. Space characters are always ignored.

# Keymaps
They keymap definition syntax is:
```
; Comment
COMMAND HOTKEY => DATA
```

## Commands
The available commands are:

### LAYER
Creates a `LAYER` with its activation set to `HOTKEY`. If a character present in `DATA` is typed before a timeout, it will be replaced by the character directly to its right. Example:

```
; macOS Umlaut/trema layer
LAYER !u => aä eë iï oö uü AÄ EË IÏ OÖ UÜ
```
Typing a character not present in the currently active layer deactivates the layer.

### MAP
Creates a normal hotkey without layers. You can send a single character or a string of any length. Examples:
```
; Maps Alt+S to ß
MAP !s => ß

; Maps Alt+Shift+/ to ¿
MAP !+/ => ¿

; Maps RightAlt+c to ç
MAP >!c => ç
```

### TIMEOUT
After a layer is activated, sends a character after a timer runs out (the default timeout is `0.8s`, and can be turned off). This command is optional. Example:

```
; Sets a TIMEOUT command for layer !u (sends ¨ after timeout)
TIMEOUT !u => ¨
```

### SPACE
Since spaces are always ignored, you can use the `SPACE` command to set a character to be sent when pressing the space key after activating a layer. This command is optional. Example:

```
; Sends a bullet point character for layer !u when pressing space
SPACE !u => •
```

## Hotkeys

This application uses AutoHotkey's [syntax](https://www.autohotkey.com/docs/v1/Hotkeys.htm#Symbols) for defining hotkeys. In case you are not familiar with it, here are the most important keys:

- `^` is `Ctrl`
- `#` is `Win`
- `!` is `Alt`
- `+` is `Shift`.
- `<` is a modifier for `left` (for instance, `<^` means `LeftCtrl`)
- `>` is a modifier for `right` (for instance, `>^` means `RightCtrl`)

# Options
The `options.ini` definition syntax is:

```
[Options]
; Active keymap (relative to /keymaps)
ACTIVE_KEYMAP=macOS.txt

; Layer timeout in seconds (use 0 to wait forever)
TIMEOUT=0.8

; Set to 1 to hide the tray icon
HIDE_TRAY_ICON=0

; Ignore apps (comma-separated, uncomment to enable)
IGNORE_WHEN_ACTIVE=notepad.exe,chrome.exe
```

# Installation and usage
You can either download and execute the script directly with [AutoHotkey v1](https://github.com/AutoHotkey/AutoHotkey/releases/tag/v1.1.37.01), or download and execute the pre-compiled binaries. This code was only tested with AutoHotkey v1.1.37.01, and will not run with AutoHotkey v2.

## As a script
- Download the source code.
- Open **windows-accent-layers.ahk** with [AutoHotkey v1](https://github.com/AutoHotkey/AutoHotkey/releases/tag/v1.1.37.01) (Unicode version).

## Compiled version
- Download and unzip the binaries.
- Open **windows-accent-layers.exe**.

## Usage
- Browse and select a keymap from the `/keymaps` directory, or make your own.
- Set your selected keymap and other options on `options.ini`.
- Activate a layer to type special characters.

# Troubleshooting
In case you encounter any issues with garbage characters after editing keymap definitions, make sure you are saving them with UTF-16 LE encoding. Other character encodings, such as UTF-8, UTF-8 with BOM and UTF-16 BE will most likely produce garbage characters. Make sure you are also using a Unicode version of AutoHotkey.

# Acknowledgements
This project is a generalization of Lexikos' original [script](https://autohotkey.com/board/topic/27801-special-characters-osx-style/?p=697602) for typing special characters on Windows, along with its very elegant data format. Icon art is provided by [kumakamu](https://flaticon.com/authors/kumakamu).
