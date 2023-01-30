import natu/[math, graphics, video]
import components/projectile/modifier
import utils/objs
import modules/shooter
import types/[hud, scenes]

proc initModifierSlots*(): ModifierSlots =
  result.initialised = true
  result.modifierNumber = Modifier(kind: mkNumber)
  result.modifierOperator = Modifier(kind: mkOperator)

proc draw*(self: var ModifierSlots, gameState: GameState) =
  if gameState == Play or gameState == Intro or gameState == Paused:
    if self.drawOperator:
      if self.modifierOperator.valueOperator != okNone:
        withObj:
          obj.init(
            mode = omReg,
            pos = vec2i(ScreenWidth - 30, ScreenHeight - 16) - vec2i(
                self.modifierOperator.graphic.width div 2,
                self.modifierOperator.graphic.height div 2),
            tid = self.modifierOperator.modifierObj.tid +
            (self.modifierOperator.index * 4),
            pal = self.modifierOperator.modifierObj.pal,
            size = self.modifierOperator.graphic.size
          )
    if self.drawNumber:
      if self.modifierNumber.valueNumber != 0:
        withObj:
          obj.init(
            mode = omReg,
            pos = vec2i(ScreenWidth - 12, ScreenHeight - 16) - vec2i(
                self.modifierNumber.graphic.width div 2,
                self.modifierNumber.graphic.height div 2),
            tid = self.modifierNumber.modifierObj.tid +
            (self.modifierNumber.index * 4),
            pal = self.modifierNumber.modifierObj.pal,
            size = self.modifierNumber.graphic.size
          )

