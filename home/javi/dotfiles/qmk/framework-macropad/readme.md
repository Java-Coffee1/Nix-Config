Copyright 2026 javi

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

---

Custom keymap for the Framework Laptop 16 RGB Macropad. Lives in
Nix-Config at `home/javi/dotfiles/qmk/framework-macropad/`. The `macropad`
command (packaged in `lazy-scripts/fw/macropad.nix`, imported by
`modules/fw-modules.nix`) clones Framework's firmware fork to
`~/qmk_firmware` on first run (RGB matrix support for this board only
exists on their `fl16-2026-f9` branch, not `master`), symlinks this
keymap in, and builds:

    macropad build   # symlink this keymap in, compile, nothing else
    macropad flash   # same, then prompt + flash

To enter boot loader do this 
```
         col0  col1  col2  col3
row 0   [   ] [   ] [   ] [   ]
row 1   [   ] [   ] [   ] [   ]
row 2   [   ] [   ] [   ] [   ]
row 3   [   ] [   ] [ X ] [   ]   ← "6" = (2,3)
row 4   [   ] [ X ] [   ] [   ]   ← "2" = (1,4)
row 5   [   ] [   ] [   ] [   ]