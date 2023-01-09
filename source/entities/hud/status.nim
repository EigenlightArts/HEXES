import natu/[math, graphics, video, tte, posprintf]
import types/[hud, scenes]
import components/timer

proc initStatus*(): Status =
  result.initialised = true

  let labelPal = acquireObjPal(gfxShipPlayer)
  prepareLabel(result.label, vec2i(ScreenWidth div 2, ScreenHeight div 12), labelPal, 15, 2, 0)

proc draw*(self: var Status, timer: var Timer, gameState: GameState,
    target: int, eventLoopStatus: int) =
  if gameState != GameOver:
    if gameState == Play or gameState == Intro:
      self.label.draw()

    let size = tte.getTextSize((cast[cstring](addr self.labelBuffer)))
    self.label.pos = vec2i(ScreenWidth div 2 - size.x div 2,
      ScreenHeight div 12 - size.y div 2)

    if gameState == Paused:
      if (eventLoopStatus div 25) mod 2 == 0:
        self.label.draw()

        posprintf((cast[cstring](addr self.labelBuffer)), "PAUSED")
        self.label.put((cast[cstring](addr self.labelBuffer)))
    elif gameState == LevelUp:
      # gameState = Intro
      timer.introSeconds = timer.introSecondsInitial
    elif gameState == Intro:
      posprintf((cast[cstring](addr self.labelBuffer)), "Get to $%X!", target)
      self.label.put((cast[cstring](addr self.labelBuffer)))
    else:
      let seconds = timer.getValueSeconds() mod 60
      let minutes = (timer.getValueSeconds() div 60) mod 60

      posprintf((cast[cstring](addr self.labelBuffer)), "%02d:%02d", minutes, seconds)
      self.label.put((cast[cstring](addr self.labelBuffer)))
