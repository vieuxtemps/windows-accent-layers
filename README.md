# Windows Accent Layers

<p align="center">
  <img src="icon.ico" />
</p>

Windows Accent Layers enables macOS-style input of diacritics/accented characters and other special symbols on Windows, without the need for swapping your current keyboard layout. You can also easily customize or create new layouts with simple, single-line definitions.

With [suffix layers](#suffix), an alternative typing method not available in either Windows or macOS by default, you can achieve maximum typing speed in multiple languages while not having to switch out of the US layout at all, and without having to press Alt keys. It works similarly to the US-International layout on Windows, but with the advantage of being completely customizable and not blocking input when modifiers are pressed.

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

There are two sub-commands for layers:

#### TIMEOUT
After a layer is activated, sends a character after a timer runs out (the default timeout is `0.8s`, and can be turned off). This command is optional. Example:

```
; Sets a TIMEOUT command for layer !u (sends ¨ after timeout)
TIMEOUT !u => ¨
```

#### SPACE
Since spaces are always ignored, you can use the `SPACE` command to set a character to be sent when pressing the space key after activating a layer. This command is optional. Example:

```
; Sends a bullet point character for layer !u when pressing space
SPACE !u => •
```

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

### SUFFIX
<a name="suffix"></a>
This command effectively works like modifiers in the US-International layout on Windows, but the advantage of immediately sending the suffix key.

For instance, typing `'` with US-International would lock input until the next character is sent. However, if you wanted to simply type `'` into a text document, you would then have to input `Space`, which is highly undesirable in many situations. This is specially useful if you use any application that requires the modifier keys to be immediately sent to preserve normal functionality (e.g. vim).

Example definition for an acute suffix layer with trigger/suffix `'`:

```
SUFFIX ' => aá eé ií oó uú AÁ EÉ IÍ OÓ UÚ
```

You can then type `'a` to produce `á`, or `'e` to produce `é`, and so forth.

Notes:
- For suffix definitions, prefer using single character suffixes instead of Shift combinations (for example, use `{` instead of `+[`, even though they technically mean the same thing if using the US layout).
- This is implemented using [hotstrings](https://www.autohotkey.com/docs/v1/Hotstrings.htm), which means that a backspace is sent to delete the suffix character.
- Since a backspace is sent, keep in mind that this can lead to unexpected behaviors in some applications. As an example, if you were inside a directory in Windows Explorer and typed `[a` while not editing text, a backspace character would be sent, placing you in the previous directory.
- Despite its drawbacks, the `SUFFIX` command can lead to the fastest typing speed for some languages, without the need for swapping layouts, and is the recommended input mode for maximum speed. If you are not comfortable with auto replacements and backspacing, stick with layers and maps.

Here is a demonstration of how this looks like in practice (using a clone of the US-International layout, `us-international-suffix.txt`):

<p align="center">
  <img src="demo-suffix.gif" />
</p>

Inside a text editor, the result is visually similar to using `Option` layers in macOS, but with less keypresses.

You can also get creative with suffixes:

```
SUFFIX $ => e€ p£
```

In this case, typing `$e` would produce `€`, and `$p` would produce `£`. Another example with dashes:

```
SUFFIX - => _– -— =―
```

In this case, typing `-_` would produce `–` (en-dash), typing `--` would produce `—` (em-dash), and typing `-=` would produce `―` (horizontal bar).

### Suffix confirmation/cancellation modes

Suffix substitutions are automatically cancelled if there is not a corresponding suffix layer definition for the next character that is typed. However, if the character is defined within the layer, there are 4 different ways to set cancellation behavior, listed below:

- `0`: Don't cancel — This will replace suffixes even if you press Space many times and go back to the same position with Backspace.
- `1`: Cancel on Space — This will cancel the last suffix whenever you press Space. For instance, if you wanted to type the string `'a'` (with quotes) while having a suffix acute layer active (which would replace `'a` with `á`), you could type `'`, then `Space`, then `Backspace`, then a.
- `2`: Space to confirm suffix character — To accomplish the same thing as in the previous example, you could type `'`, then `Space`, then `a`.
- `3`: Double suffix to confirm suffix (default, recommended) — Press the suffix twice to confirm the suffix (you would press `""` in the example above). You don't need to press the suffix twice if the next character typed is not present in the layer (in the demo above, you can notice that `"quotes"` is typed without any Space input, while `"input"` required `"` to be pressed twice). If a double suffix is present in the suffix layer definition (e.g. double dash for em-dash), the definition within the layer has higher priority. This is the most intuitive option and is the recommended option for new users.

Although you may use the above documentation for reference, keep in mind that the easiest way to understand suffix cancellation behavior is trying to use one of the options for your daily typing and see what fits your needs.

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
This project was initially developed as a generalization of Lexikos' original [script](https://autohotkey.com/board/topic/27801-special-characters-osx-style/?p=697602) for typing special characters on Windows, along with its very elegant data format. Icon art is provided by [kumakamu](https://flaticon.com/authors/kumakamu).
