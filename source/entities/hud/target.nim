import natu/[math, graphics, video, tte, posprintf]
import types/[hud, scenes]

proc initTarget*(target: int): Target =
  result.initialised = true
  result.target = target

  let labelPal = acquireObjPal(gfxShipPlayer)
  prepareLabel(result.label, vec2i(ScreenWidth div 12, ScreenHeight - 16), labelPal, 16, 2, 0)

proc draw*(self: var Target, gameState: GameState) =
  if gameState == Play or gameState == Intro:
    self.label.draw()

    let size = tte.getTextSize(addr self.labelBuffer)
    self.label.pos = vec2i(ScreenWidth div 12 - size.x div 2,
      ScreenHeight - 16 - size.y div 2)

    posprintf(addr self.labelBuffer, "$%X", self.target)
    self.label.put(addr self.labelBuffer)
