import natu/[math, graphics, video, tte, posprintf]
import utils/[objs]
import types/[hud, scenes]
import components/timer


proc initStatus*(): Status =
  result.initialised = true

  result.label.init(vec2i(ScreenWidth div 2, ScreenHeight div 12), s8x16, count = 15)
  result.label.obj.pal = acquireObjPal(gfxShipPlayer)
  result.label.ink = 2 # set the ink colour index to use from the palette
  result.label.shadow = 0 # set the shadow colour (only relevant if the font actually has more than 1 colour)

proc draw*(self: var Status, timer: var Timer, gameState: GameState,
    target: int, eventLoopStatus: int) =
  if gameState != GameOver:
    if gameState == Play or gameState == Intro:
      self.label.draw()

    let size = tte.getTextSize(addr self.labelBuffer)
    self.label.pos = vec2i(ScreenWidth div 2 - size.x div 2,
      ScreenHeight div 12 - size.y div 2)

    if gameState == Paused:
      if (eventLoopStatus div 25) mod 2 == 0:
        self.label.draw()

        posprintf(addr self.labelBuffer, "PAUSED")
        self.label.put(addr self.labelBuffer)
    elif gameState == LevelUp:
      # gameState = Intro
      timer.introSeconds = timer.introSecondsInitial
    elif gameState == Intro:
      posprintf(addr self.labelBuffer, "Get to $%X!", target)
      self.label.put(addr self.labelBuffer)
    else:
      let seconds = timer.getValueSeconds() mod 60
      let minutes = (timer.getValueSeconds() div 60) mod 60

      posprintf(addr self.labelBuffer, "%02d:%02d", minutes, seconds)
      self.label.put(addr self.labelBuffer)
