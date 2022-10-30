# Magic string for emulators and flashcards to auto-detect save type.
asm """
.balign 4
.string "SRAM_V100"
.balign 4
"""

import natu/[bios, irq, input, graphics, utils, memory]
import utils/[objs, scene, audio, savedata]
import scenes/title


# NOTE(Kal): Resources about Game Engine Development and Programming:
# - https://www.gameprogrammingpatterns.com/
# - https://www.gameenginebook.com/
# - https://caseymuratori.com/blog_0015
# - https://www.dataorienteddesign.com/dodbook/dodmain.html

var canRedraw = false

proc onVBlank =
  audio.vblank()
  if canRedraw:
    canRedraw = false
    flushPals()
    drawScene()
    oamUpdate() # clear unused entries, reset allocation counters
  audio.frame()

proc main =
  # Recommended waitstate configuration
  waitcnt.init(
    sram = WsSram.N8_S8, # 8 cycles to access SRAM.
    rom0 = WsRom0.N3_S1, # 3 cycles to access ROM, or 1 cycle for sequential access.
    rom2 = WsRom2.N8_S8, # 8 cycles to access ROM (mirror #2) which may be used for flash storage.
    prefetch = true # prefetch buffer enabled.
  )

  savedata.load()
  audio.init()

  irq.init()
  irq.put(iiVBlank, onVBlank)


  setScene(TitleScene)
  # setScene(GameScene)

  while true:
    discard rand() # introduce some nondeterminism to the RNG
    keyPoll()
    updateScene()
    canRedraw = true
    VBlankIntrWait()

main()
