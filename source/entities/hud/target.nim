import natu/[math, graphics, video, tte, posprintf]
import types/[hud, scenes]

proc initTarget*(target: int): Target =
  result.initialised = true
  result.target = target

  let labelPal = acquireObjPal(gfxShipPlayer)
  prepareLabel(result.label, vec2i(ScreenWidth div 12, ScreenHeight - 16), labelPal, 16, 2, 0)

proc draw*(self: var Target, gameState: GameState) =
  if gameState == Play or gameState == Intro or gameState == Paused:
    self.label.draw()

    let size = tte.getTextSize((cast[cstring](addr self.labelBuffer)))
    self.label.pos = vec2i(ScreenWidth div 12 - size.x div 2,
      ScreenHeight - 16 - size.y div 2)

    posprintf((cast[cstring](addr self.labelBuffer)), "$%X", self.target)
    self.label.put((cast[cstring](addr self.labelBuffer)))
