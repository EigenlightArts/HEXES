import natu/[math, graphics, video]
import utils/objs
import modules/[types]


proc initEvilHexCenterNumber*(value: sink int): EvilHexCenterNumber =
  result.value = value
  result.update = true

  result.label.init(vec2i(ScreenWidth div 2, ScreenHeight div 2), s8x16, count = 5)
  result.label.obj.pal = acquireObjPal(gfxShipTemp)
  result.label.ink = 1 # set the ink colour index to use from the palette
  result.label.shadow = 2 # set the shadow colour (only relevant if the font actually has more than 1 colour)
