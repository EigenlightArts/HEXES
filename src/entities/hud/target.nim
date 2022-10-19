import natu/[math, graphics, video, tte, posprintf]
import utils/objs
import modules/shooter
import modules/types/hud

# TODO(Kal): Maybe merge with timer?

proc initTarget*(target: int): Target =
  result.initialised = true
  result.target = target

  result.label.init(vec2i(ScreenWidth div 12, ScreenHeight - 16), s8x16, count = 16)
  result.label.obj.pal = acquireObjPal(gfxShipTemp)
  result.label.ink = 1 # set the ink colour index to use from the palette
  result.label.shadow = 2 # set the shadow colour (only relevant if the font actually has more than 1 colour)


proc draw*(self: var Target, introFlag: bool) =
  self.label.draw()

  let size = tte.getTextSize(addr self.hexBuffer)
  self.label.pos = vec2i(ScreenWidth div 12 - size.x div 2,
    ScreenHeight - 16 - size.y div 2)

  if not introFlag:
    posprintf(addr self.hexBuffer, "$%X", self.target)
    self.label.put(addr self.hexBuffer)
    printf("if self.introFlag")


