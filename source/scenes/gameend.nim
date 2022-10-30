import natu/[irq, oam, video, math, tte, posprintf]
import natu/graphics
import utils/[objs, labels, scene]
import modules/score

proc backToTitle()

# var menuItems: array[2, int]
# var menuCur: int
var thanksLabel: Label
var scoreLabel: Label
var highScoreLabel: Label
var labelBufferT: array[30, char]
var labelBufferS: array[12, char]
var labelBufferH: array[20, char]

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
  thanksLabel.obj.pal = acquireObjPal(gfxShipPlayer)
  thanksLabel.ink = 2 # set the ink colour index to use from the palette
  thanksLabel.shadow = 0 # set the shadow colour (only relevant if the font actually has more than 1 colour)

  scoreLabel.init(vec2i(ScreenWidth div 2, ScreenHeight div 2), s8x16, count = 15)
  scoreLabel.obj.pal = acquireObjPal(gfxShipPlayer)
  scoreLabel.ink = 2 # set the ink colour index to use from the palette
  scoreLabel.shadow = 0 # set the shadow colour (only relevant if the font actually has more than 1 colour)

  highScoreLabel.init(vec2i(ScreenWidth div 2, ScreenHeight div 2 + 32), s8x16, count = 25)
  highScoreLabel.obj.pal = acquireObjPal(gfxShipPlayer)
  highScoreLabel.ink = 2 # set the ink colour index to use from the palette
  highScoreLabel.shadow = 0 # set the shadow colour (only relevant if the font actually has more than 1 colour)

  # enable VBlank interrupt so we can wait for
  # the end of the frame without burning CPU cycles
  irq.enable(iiVBlank)

proc onHide =
  display.layers = display.layers - {lBg0, lObj}
  display.obj1d = false

  releaseObjPal(gfxShipPlayer)
  thanksLabel.destroy()

proc onUpdate =
  dec eventEndGameTimer
  if eventEndGameTimer <= 0:
    eventEndGameTimer = timerEndGameFrames
    resetScore()
    backToTitle()

proc onDraw =
  thanksLabel.draw()
  scoreLabel.draw()
  highScoreLabel.draw()

  let sizeT = tte.getTextSize(addr labelBufferT)
  thanksLabel.pos = vec2i(ScreenWidth div 2 - sizeT.x div 2,
    (ScreenHeight div 2 - 32) - sizeT.y div 2)

  posprintf(addr labelBufferT, "THANKS FOR PLAYING THIS DEMO")
  thanksLabel.put(addr labelBufferT)

  let sizeS = tte.getTextSize(addr labelBufferS)
  scoreLabel.pos = vec2i(ScreenWidth div 2 - sizeS.x div 2,
    (ScreenHeight div 2) - sizeS.y div 2)

  posprintf(addr labelBufferS, "SCORE: %d", totalScore)
  scoreLabel.put(addr labelBufferS)

  let sizeH = tte.getTextSize(addr labelBufferH)
  highScoreLabel.pos = vec2i(ScreenWidth div 2 - sizeH.x div 2,
    (ScreenHeight div 2 + 32) - sizeH.y div 2)

  checkAndStoreIfNewHighScore()

  if newHighScore:
    posprintf(addr labelBufferH, "NEW HIGHSCORE: %d", highScore)
    highScoreLabel.put(addr labelBufferH)
  else:
    posprintf(addr labelBufferH, "HIGHSCORE: %d", highScore)
    highScoreLabel.put(addr labelBufferH)

const GameEndScene* = Scene(
  show: onShow,
  hide: onHide,
  update: onUpdate,
  draw: onDraw,
)

import scenes/title

proc backToTitle() =
  setScene(TitleScene)
