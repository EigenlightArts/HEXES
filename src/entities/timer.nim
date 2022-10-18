import natu/[math, graphics, video, tte, posprintf]
import utils/objs
import modules/[types, shooter]


proc initTimer*(valueSeconds: int): Timer =
  result.valueSeconds = valueSeconds
  result.valueFrames = result.valueSeconds * 60
  result.updateFlag = true

  result.label.init(vec2i(ScreenWidth div 2, ScreenHeight div 12), s8x16, count = 10)
  result.label.obj.pal = acquireObjPal(gfxShipTemp)
  result.label.ink = 1 # set the ink colour index to use from the palette
  result.label.shadow = 2 # set the shadow colour (only relevant if the font actually has more than 1 colour)

proc update*(self: var Timer) =
  dec self.valueFrames

  if self.valueFrames mod 60 == 0:
    dec self.valueSeconds
    self.updateFlag = true

  if timeScoreValue != 0:
    self.valueFrames += timeScoreValue * 60
    self.valueSeconds += timeScoreValue

    timeScoreValue = 0

proc draw*(self: var Timer) =
  self.label.draw()

  if self.updateFlag:
    let size = tte.getTextSize(addr self.hexBuffer)
    self.label.pos = vec2i(ScreenWidth div 2 - size.x div 2,
        ScreenHeight div 12 - size.y div 2)

    let seconds = self.valueSeconds mod 60
    let minutes = (self.valueSeconds div 60) mod 60

    posprintf(addr self.hexBuffer, "%02d:%02d", minutes, seconds)
    self.label.put(addr self.hexBuffer)
    self.updateFlag = false
