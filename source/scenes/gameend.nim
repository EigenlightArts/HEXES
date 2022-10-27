import natu/[bios, irq, oam, input, video, mgba, math, tte, posprintf]
import natu/[graphics, backgrounds]
import utils/[objs, labels, levels, scene]
import modules/score

proc backToTitle()

# var menuItems: array[2, int]
# var menuCur: int
var thanksLabel: Label
var scoreLabel: Label
var highScoreLabel: Label
var hexBuffer: array[9, char]

var eventEndGameTimer: int

const timerEndGameFrames = 200


proc onShow =
  # background color, approximating eigengrau
  bgColorBuf[0] = rgb8(22, 22, 29)

  # Show the background:
  # dispcnt.init(layers = {lBg0})

  display.layers = {lBg0, lObj}
  display.obj1d = true

  eventEndGameTimer = timerEndGameFrames

  thanksLabel.init(vec2i(ScreenWidth div 2, ScreenHeight div 2 - 32), s8x16, count = 30)
  thanksLabel.obj.pal = acquireObjPal(gfxShipTemp)
  thanksLabel.ink = 1 # set the ink colour index to use from the palette
  thanksLabel.shadow = 0 # set the shadow colour (only relevant if the font actually has more than 1 colour)

  scoreLabel.init(vec2i(ScreenWidth div 2, ScreenHeight div 2), s8x16, count = 15)
  scoreLabel.obj.pal = acquireObjPal(gfxShipTemp)
  scoreLabel.ink = 1 # set the ink colour index to use from the palette
  scoreLabel.shadow = 0 # set the shadow colour (only relevant if the font actually has more than 1 colour)

  highScoreLabel.init(vec2i(ScreenWidth div 2, ScreenHeight div 2 + 32), s8x16, count = 20)
  highScoreLabel.obj.pal = acquireObjPal(gfxShipTemp)
  highScoreLabel.ink = 1 # set the ink colour index to use from the palette
  highScoreLabel.shadow = 0 # set the shadow colour (only relevant if the font actually has more than 1 colour)

  # enable VBlank interrupt so we can wait for
  # the end of the frame without burning CPU cycles
  irq.enable(iiVBlank)

proc onHide =
  display.layers = display.layers - {lBg0, lObj}
  display.obj1d = false

  releaseObjPal(gfxShipTemp)
  thanksLabel.destroy()

proc onUpdate =
  dec eventEndGameTimer
  if eventEndGameTimer <= 0:
    eventEndGameTimer = timerEndGameFrames
    backToTitle()

proc onDraw =
  thanksLabel.draw()
  scoreLabel.draw()
  highScoreLabel.draw()

  let sizeT = tte.getTextSize(addr hexBuffer)
  thanksLabel.pos = vec2i(ScreenWidth div 2 - sizeT.x div 2,
    (ScreenHeight div 2 - 32) - sizeT.y div 2)

  posprintf(addr hexBuffer, "THANKS FOR PLAYING THIS DEMO")
  thanksLabel.put(addr hexBuffer)

  let sizeS = tte.getTextSize(addr hexBuffer)
  scoreLabel.pos = vec2i(ScreenWidth div 2 - sizeS.x div 2,
    (ScreenHeight div 2) - sizeS.y div 2)

  posprintf(addr hexBuffer, "SCORE: %d", totalScore)
  scoreLabel.put(addr hexBuffer)

  let sizeH = tte.getTextSize(addr hexBuffer)
  highScoreLabel.pos = vec2i(ScreenWidth div 2 - sizeH.x div 2,
    (ScreenHeight div 2) - sizeH.y div 2)

  checkAndStoreIfNewHighScore()

  if newHighScore:
    posprintf(addr hexBuffer, "NEW HIGHSCORE: %d", highScore)
    highScoreLabel.put(addr hexBuffer)
  else:
    posprintf(addr hexBuffer, "HIGHSCORE: %d", highScore)
    highScoreLabel.put(addr hexBuffer)

const GameEndScene* = Scene(
  show: onShow,
  hide: onHide,
  update: onUpdate,
  draw: onDraw,
)

import scenes/title

proc backToTitle() =
  setScene(TitleScene)
