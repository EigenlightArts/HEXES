import natu/[math, graphics, posprintf, video, tte]
import types/[hud, scenes]

proc initCenterNumber*(value: sink int, target: sink int, isBoss: bool): CenterNumber =
  result.initialised = true
  result.isBoss = isBoss
  
  result.value = value
  result.target = target

  let labelPal = acquireObjPal(gfxShipPlayer)
  prepareLabel(result.label, vec2i(ScreenWidth div 2, ScreenHeight div 2),
      labelPal, 10, 2, 1)

  posprintf(cast[cstring](addr result.labelBuffer), "$%X", result.value)
  result.label.put(cast[cstring](addr result.labelBuffer))

proc draw*(self: var CenterNumber; gameState: GameState) =
  self.label.draw()

  if gameState == GameOver:
    let size = tte.getTextSize((cast[cstring](addr self.labelBuffer)))
    self.label.pos = vec2i(ScreenWidth div 2 - size.x div 2,
      ScreenHeight div 2 - size.y div 2)

    posprintf((cast[cstring](addr self.labelBuffer)), "GAME OVER")
    self.label.put((cast[cstring](addr self.labelBuffer)))
  elif gameState == LevelUp:
    let size = tte.getTextSize((cast[cstring](addr self.labelBuffer)))
    self.label.pos = vec2i(ScreenWidth div 2 - size.x div 2,
      ScreenHeight div 2 - size.y div 2)

    posprintf((cast[cstring](addr self.labelBuffer)), "YOU WON")
    self.label.put((cast[cstring](addr self.labelBuffer)))
  else:
    let size = tte.getTextSize((cast[cstring](addr self.labelBuffer)))
    self.label.pos = vec2i(ScreenWidth div 2 - size.x div 2,
      ScreenHeight div 2 - size.y div 2)

    posprintf((cast[cstring](addr self.labelBuffer)), "$%X", self.value)
    self.label.put((cast[cstring](addr self.labelBuffer)))


proc update*(self: var CenterNumber, timer: Timer) =
  # Prevent CenterNumber from overflowing or underflowing
  self.value = self.value and 255

  if self.isBoss:
    # if BossLevel with Sequence Patterns
    for effect in mitems(self.activeBEs):
      if effect.bseqActive:
        if effect.bseqPatternCurrent == bseqPatternMax:
          effect.bseqPatternCurrent = 0

        effect.bseqPatternCurrent += 1

        if timer.getValueFrames() mod effect.bseqChangeFrames == 0:
          if effect.bseqSubract:
            self.value -= effect.bseqPattern[effect.bseqPatternCurrent]
          else:
            self.value += effect.bseqPattern[effect.bseqPatternCurrent]
