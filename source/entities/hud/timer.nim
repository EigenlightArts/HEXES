import natu/[math, graphics, video, tte, posprintf]
import utils/objs
import types/[hud, scenes]


proc initTimer*(valueSeconds: int, introSeconds: int, limitSeconds: int): Timer =
  result.initialised = true

  result.valueFrames = valueSeconds * 60
  result.introSeconds = introSeconds
  result.introSecondsInitial = result.introSeconds
  result.limitSeconds = limitSeconds

  result.label.init(vec2i(ScreenWidth div 2, ScreenHeight div 12), s8x16, count = 15)
  result.label.obj.pal = acquireObjPal(gfxShipPlayer)
  result.label.ink = 2 # set the ink colour index to use from the palette
  result.label.shadow = 0 # set the shadow colour (only relevant if the font actually has more than 1 colour)

proc getValueSeconds*(self: Timer): int = self.valueFrames div 60
proc setValueSeconds*(self: var Timer, valueSeconds: int) = self.valueFrames = valueSeconds * 60

proc update*(self: var Timer, gameStatus: var GameStatus) =
  dec self.valueFrames

  if self.valueFrames mod 60 == 0:
    if gameStatus == Intro:
      dec self.introSeconds

    if self.introSeconds <= 0:
      gameStatus = Play

  if timeScoreValue != 0:

    self.valueFrames += (timeScoreValue * 60)

    if self.valueFrames > (self.limitSeconds * 60):
      self.valueFrames = self.limitSeconds

    timeScoreValue = 0

  if self.valueFrames <= 0:
    gameStatus = GameOver


proc draw*(self: var Timer, target: int, gameStatus: GameStatus,
    eventLoopTimer: int) =
  if gameStatus != GameOver:
    if gameStatus == Play or gameStatus == Intro:
      self.label.draw()

    let size = tte.getTextSize(addr self.labelBuffer)
    self.label.pos = vec2i(ScreenWidth div 2 - size.x div 2,
      ScreenHeight div 12 - size.y div 2)

    if gameStatus == Paused:
      if (eventLoopTimer div 25) mod 2 == 0:
        self.label.draw()

        posprintf(addr self.labelBuffer, "PAUSED")
        self.label.put(addr self.labelBuffer)
    elif gameStatus == LevelUp:
      # gameStatus = Intro
      self.introSeconds = self.introSecondsInitial
    elif gameStatus == Intro:
      posprintf(addr self.labelBuffer, "Get to $%X!", target)
      self.label.put(addr self.labelBuffer)
    else:
      let seconds = self.getValueSeconds() mod 60
      let minutes = (self.getValueSeconds() div 60) mod 60

      posprintf(addr self.labelBuffer, "%02d:%02d", minutes, seconds)
      self.label.put(addr self.labelBuffer)
