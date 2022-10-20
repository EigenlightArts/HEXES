import natu/[math, graphics, posprintf, video, tte, utils]
import components/shared
import utils/objs
import modules/shooter
import modules/types/hud

proc initCenterNumber*(value: sink int, target: sink int): CenterNumber =
  result.initialised = true

  result.value = value
  result.target = target
  result.updateFlag = true

  result.label.init(vec2i(ScreenWidth div 2, ScreenHeight div 2), s8x16, count = 5)
  result.label.obj.pal = acquireObjPal(gfxShipTemp)
  result.label.ink = 1 # set the ink colour index to use from the palette
  result.label.shadow = 2 # set the shadow colour (only relevant if the font actually has more than 1 colour)

  posprintf(addr result.hexBuffer, "$%X", result.value)
  result.label.put(addr result.hexBuffer)

proc draw*(self: var CenterNumber) =
  self.label.draw()

  if self.updateFlag:
    let size = tte.getTextSize(addr self.hexBuffer)
    self.label.pos = vec2i(ScreenWidth div 2 - size.x div 2,
        ScreenHeight div 2 - size.y div 2)

    posprintf(addr self.hexBuffer, "$%X", self.value)
    self.label.put(addr self.hexBuffer)
    self.updateFlag = false
