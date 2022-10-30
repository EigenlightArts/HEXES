import natu/[irq, oam, input, video, math, tte, posprintf]
import natu/[graphics, backgrounds]
import utils/[objs, labels, scene, audio]

proc goToGameScene()

# var menuItems: array[2, int]
# var menuCur: int

var startLabel: Label
var labelBuffer: array[9, char]

proc onShow =
  audio.stopMusic()

  # Use a BG Control register to select a charblock and screenblock:
  bgcnt[1].init(cbb = 0, sbb = 31)

  # Load the tiles, map and palette into memory:
  bgcnt[1].load(bgHexesSegments)

  # Show the background:
  dispcnt.init(layers = {lBg1})

  display.layers = {lBg1, lObj}
  display.obj1d = true

  startLabel.init(vec2i(ScreenWidth div 2, ScreenHeight - 32), s8x16, count = 15)
  startLabel.obj.pal = acquireObjPal(gfxShipPlayer)
  startLabel.ink = 2 # set the ink colour index to use from the palette
  startLabel.shadow = 0 # set the shadow colour (only relevant if the font actually has more than 1 colour)

  audio.playMusic(modTitle)

  # enable VBlank interrupt so we can wait for
  # the end of the frame without burning CPU cycles
  irq.enable(iiVBlank)

proc onHide =
  display.layers = display.layers - {lBg0, lObj}
  display.obj1d = false

  releaseObjPal(gfxShipPlayer)
  startLabel.destroy()

proc onUpdate =
  if keyIsDown(kiStart):
    goToGameScene()

proc onDraw =
  startLabel.draw()

  let size = tte.getTextSize(addr labelBuffer)
  startLabel.pos = vec2i(ScreenWidth div 2 - size.x div 2,
    (ScreenHeight - 32) - size.y div 2)

  posprintf(addr labelBuffer, "PRESS START")
  startLabel.put(addr labelBuffer)

const TitleScene* = Scene(
  show: onShow,
  hide: onHide,
  update: onUpdate,
  draw: onDraw,
)

import scenes/game

proc goToGameScene() =
  setScene(GameScene)
