import natu/[math, graphics, video, tte, posprintf]
import utils/objs
import types/hud


proc initTimer*(valueSeconds: int, introSeconds: int): Timer =
  result.initialised = true

  result.valueSeconds = valueSeconds
  result.valueFrames = result.valueSeconds * 60
  result.introSeconds = introSeconds
  result.limitSeconds = result.introSeconds * 2
  result.updateFlag = false
  result.introFlag = true

  result.label.init(vec2i(ScreenWidth div 2, ScreenHeight div 12), s8x16, count = 15)
  result.label.obj.pal = acquireObjPal(gfxShipTemp)
  result.label.ink = 1 # set the ink colour index to use from the palette
  result.label.shadow = 0 # set the shadow colour (only relevant if the font actually has more than 1 colour)

proc update*(self: var Timer, gameOver: var bool) =
  dec self.valueFrames

  if self.valueFrames mod 60 == 0:
    dec self.valueSeconds
    if self.introFlag:
      dec self.introSeconds

    if self.introSeconds <= 0:
      self.introFlag = false
    if not self.introFlag:
      self.updateFlag = true

  if timeScoreValue != 0:
    if self.valueSeconds <= self.limitSeconds:
      self.valueFrames += timeScoreValue * 60
      self.valueSeconds += timeScoreValue

    timeScoreValue = 0

  if self.valueFrames <= 0:
    gameOver = true


proc draw*(self: var Timer, target: int, gameOver: bool, pause: bool,
    eventLoopTimer: int) =
  if not gameOver:
    if not pause:
      self.label.draw()

    let size = tte.getTextSize(addr self.hexBuffer)
    self.label.pos = vec2i(ScreenWidth div 2 - size.x div 2,
      ScreenHeight div 12 - size.y div 2)

    if pause:
      if (eventLoopTimer div 25) mod 2 == 0:
        self.label.draw()

        posprintf(addr self.hexBuffer, "PAUSED")
        self.label.put(addr self.hexBuffer)
    elif self.introFlag:
      posprintf(addr self.hexBuffer, "Get to $%X!", target)
      self.label.put(addr self.hexBuffer)
    elif self.updateFlag:
      let seconds = self.valueSeconds mod 60
      let minutes = (self.valueSeconds div 60) mod 60

      posprintf(addr self.hexBuffer, "%02d:%02d", minutes, seconds)
      self.label.put(addr self.hexBuffer)
      self.updateFlag = false


