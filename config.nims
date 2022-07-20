import os, strutils
import natu/config

const main = "./src/HEXES.nim"         # path to project file
const name = splitFile(main).name      # name of ROM

put "natu.gameTitle", "HEXES"          # max 12 chars, uppercase
put "natu.gameCode", "HEXS"            # 4 chars, see GBATEK for info

if projectPath() == thisDir() / main:
  # This runs only when compiling the project file:
  gbaCfg()                             # set C compiler + linker options for GBA target
  switch "os", "standalone"
  switch "gc", "none"
  switch "checks", "off"               # toggle assertions, bounds checking, etc.
  switch "path", projectDir()          # allow imports relative to the main file
  switch "header"                      # output "{project}.h"
  switch "nimcache", "nimcache"        # output C sources to local directory
  switch "cincludes", nimcacheDir()    # allow external C files to include "{project}.h"
  switch "linedir", "on"               # get Nim stack traces instead of C 

task graphics, "convert spritesheets":
  gfxConvert "graphics.nims"

task build, "builds the GBA rom":
  let args = commandLineParams()[1..^1].join(" ")
  graphicsTask()
  selfExec "c " & args & " -o:" & name & ".elf " & thisDir() / main
  gbaStrip name & ".elf", name & ".gba"
  gbaFix name & ".gba"

task clean, "removes build files":
  rmDir "nimcache"
  rmFile name & ".gba"
  rmFile name & ".elf"
  rmFile name & ".elf.map"
