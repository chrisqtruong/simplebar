# SimpleBar

A dead-simple menu bar icon hider for macOS. Like Hidden Bar, minus everything extra.

> **⚠️ Doesn't work on macOS 27 (Golden Gate).** Apple changed how the menu bar is drawn in macOS 27, and the trick SimpleBar uses (the same one Hidden Bar and Ice use) no longer hides anything. The arrow still flips, but your icons stay put. On macOS 27, try [Thaw](https://github.com/stonerl/Thaw) instead. SimpleBar works on macOS 13 through 26.

- **`|`** is the divider. Every icon to its **left** gets hidden.
- **`‹` / `›`** is the button. `‹` means icons are hidden (click to show them). `›` means they're showing (click to hide them).

## Install

1. Download **SimpleBar.zip** from the [latest release](../../releases/latest).
2. Unzip it and drag **SimpleBar.app** into **Applications**.
3. Open it. The app isn't notarized by Apple, so the first launch gets blocked. To allow it, either:
   - go to **System Settings → Privacy & Security**, scroll down, and click **Open Anyway**, or
   - run this in Terminal: `xattr -cr /Applications/SimpleBar.app`

Works on macOS 13 (Ventura) through macOS 26 (Tahoe), on Apple Silicon and Intel. **Not macOS 27**, see above.

## Use

1. Hold **⌘** and drag the menu bar icons you want hidden so they sit **left of the `|`**.
2. Click the arrow to hide or show them.
3. Right-click the arrow to turn on **Start at Login** or to quit.

## Troubleshooting

- **Icons don't appear at all?** On macOS 26 (Tahoe) and later, check **System Settings → Menu Bar** and make sure SimpleBar is allowed there.
- **Arrow won't hide anything?** The divider has to be left of the arrow. ⌘-drag it back.
- **Running Hidden Bar or Bartender?** Quit them first. They fight over the same icons.

## Build it yourself

```bash
xcode-select --install   # only if you don't have the command line tools
./build.sh
```

## License

MIT
