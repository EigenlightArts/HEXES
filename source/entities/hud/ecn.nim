import natu/[math, graphics, posprintf, video, tte]
import types/[hud, scenes]
import components/bosseffects

proc initCenterNumber*(value: sink int, target: sink int): CenterNumber =
  result.initialised = true

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
  # check if CenterNumber is overflowing or underflowing
  if self.value >= 256:
    self.value -= 256
  if self.value <= -1:
    self.value += 256

  # Only enabled if BossLevel with Sequence Patterns
  if self.boss.bseqActive:
    if self.boss.bseqPatternCurrent == high(self.boss.bseqPattern):
      self.boss.bseqPatternCurrent = 0

    self.boss.bseqPatternCurrent += 1

    if timer.getValueSeconds() mod self.boss.bseqChangeSec == 0:
      if self.boss.bseqSubract:
        self.value -= self.boss.bseqPattern[self.boss.bseqPatternCurrent]
      else:
        self.value += self.boss.bseqPattern[self.boss.bseqPatternCurrent]
