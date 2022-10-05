import natu/[math, graphics, video, bios, tte, utils, posprintf, mgba]
import ../utils/[labels, objs]
import ../components/[shared]

type EvilHexCenterNumber* = object
  initialised*: bool

  centerNumber*: uint8
  update*: bool
  label*: Label

proc initEvilHexCenterNumber*(centerNumber: uint8): EvilHexCenterNumber =
  result.centerNumber = centerNumber
  result.update = true

  result.label.init(vec2i(ScreenWidth div 2, ScreenHeight div 2), s8x16, count = 22)
  result.label.obj.pal = getPalId(gfxShipTemp)
  result.label.ink = 1 # set the ink colour index to use from the palette
  result.label.shadow = 2 # set the shadow colour (only relevant if the font actually has more than 1 colour)

proc `=destroy`*(self: var EvilHexCenterNumber) =
  if self.initialised:
    self.initialised = false
    self.label.destroy()

proc `=copy`*(dest: var EvilHexCenterNumber; source: EvilHexCenterNumber) {.error: "Not implemented".}