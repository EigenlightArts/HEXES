import natu/[math, graphics, video, bios, tte, utils, posprintf, mgba]
import utils/[labels, objs]
import components/shared
import modules/shooter

type Timer* = object
  initialised*: bool
  label*: Label

  updateFlag*: bool
  hexBuffer: array[9, char]
  valueSeconds*: int
  valueFrames*: int

proc `=destroy`*(self: var Timer) =
  if self.initialised:
    self.initialised = false
    releaseObjPal(gfxShipTemp)
    self.label.destroy()

proc `=copy`*(dest: var Timer;
    source: Timer) {.error: "Not implemented".}

proc initTimer*(valueSeconds: sink int): Timer =
  result.valueSeconds = valueSeconds
  result.valueFrames = result.valueSeconds * 60
  result.updateFlag = true

  result.label.init(vec2i(ScreenWidth div 2, ScreenHeight div 12), s8x16, count = 22)
  result.label.obj.pal = acquireObjPal(gfxShipTemp)
  result.label.ink = 1 # set the ink colour index to use from the palette
  result.label.shadow = 2 # set the shadow colour (only relevant if the font actually has more than 1 colour)

proc update*(self: var Timer) =
  dec self.valueFrames

  if self.valueFrames mod 60 == 0:
    dec self.valueSeconds
    self.updateFlag = true

  if valueTimeScore != 0:
    self.valueFrames += valueTimeScore * 60
    self.valueSeconds += valueTimeScore

    valueTimeScore = 0

proc draw*(self: var Timer) =
  self.label.draw()

  if self.updateFlag:
    let size = tte.getTextSize(addr self.hexBuffer)
    self.label.pos = vec2i(ScreenWidth div 2 - size.x div 2,
        ScreenHeight div 12 - size.y div 2)

    posprintf(addr self.hexBuffer, "S: %d", self.valueSeconds)
    self.label.put(addr self.hexBuffer)
    self.updateFlag = false
