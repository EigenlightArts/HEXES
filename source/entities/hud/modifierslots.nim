import natu/[math, graphics, video]
import components/projectile/modifier
import utils/objs
import modules/shooter
import types/hud

proc initModifierSlots*(): ModifierSlots =
  result.initialised = true
  # result.updateFlag = true

proc draw*(modifierSlots: var ModifierSlots) =
  if modifierSlots.drawOperator:
    if modifierSlots.modifierOperator.valueOperator != okNone:
      withObj:
        obj.init(
          mode = omReg,
          pos = vec2i(ScreenWidth - 26, ScreenHeight - 16) - vec2i(
              modifierSlots.modifierOperator.graphic.width div 2,
              modifierSlots.modifierOperator.graphic.height div 2),
          tid = modifierSlots.modifierOperator.modifierObj.tid +
          (modifierSlots.modifierOperator.index * 4),
          pal = modifierSlots.modifierOperator.modifierObj.palId,
          size = modifierSlots.modifierOperator.graphic.size
        )
  if modifierSlots.drawNumber:
    if modifierSlots.modifierNumber.valueNumber != 0:
      withObj:
        obj.init(
          mode = omReg,
          pos = vec2i(ScreenWidth - 10, ScreenHeight - 16) - vec2i(
              modifierSlots.modifierNumber.graphic.width div 2,
              modifierSlots.modifierNumber.graphic.height div 2),
          tid = modifierSlots.modifierNumber.modifierObj.tid +
          (modifierSlots.modifierNumber.index * 4),
          pal = modifierSlots.modifierNumber.modifierObj.palId,
          size = modifierSlots.modifierNumber.graphic.size
        )
