import natu/[math, graphics, video, tte, posprintf]
import utils/objs
import modules/shooter
import modules/types/hud


proc initTimer*(valueSeconds: int): Timer =
  result.valueSeconds = valueSeconds
  result.valueFrames = result.valueSeconds * 60
  result.introSeconds = 5
  result.updateFlag = false
  result.introFlag = true

  result.label.init(vec2i(ScreenWidth div 2, ScreenHeight div 12), s8x16, count = 10)
  result.label.obj.pal = acquireObjPal(gfxShipTemp)
  result.label.ink = 1 # set the ink colour index to use from the palette
  result.label.shadow = 2 # set the shadow colour (only relevant if the font actually has more than 1 colour)

proc update*(self: var Timer) =
  dec self.valueFrames

  if self.valueFrames mod 60 == 0:
    dec self.valueSeconds
    if self.introFlag:
      dec self.introSeconds

    printf("ASSERT self.introSeconds is %d", self.introSeconds)
    printf("ASSERT self.valueSeconds is %d", self.valueSeconds)

    printf("ASSERT self.introFlag is %d", self.introFlag)
    printf("ASSERT self.updateFlag is %d", self.updateFlag)

    if self.introSeconds == 0:
      self.introFlag = false
    else:
      self.updateFlag = true

  if timeScoreValue != 0:
    self.valueFrames += timeScoreValue * 60
    self.valueSeconds += timeScoreValue

    timeScoreValue = 0


proc draw*(self: var Timer, centerNumber: CenterNumber) =
  self.label.draw()

  let size = tte.getTextSize(addr self.hexBuffer)
  self.label.pos = vec2i(ScreenWidth div 2 - size.x div 2,
    ScreenHeight div 12 - size.y div 2)

  if self.introFlag:
    posprintf(addr self.hexBuffer, "Get to %X!", centerNumber.target)
    self.label.put(addr self.hexBuffer)
    printf("if self.introFlag")

  elif self.updateFlag:
    let seconds = self.valueSeconds mod 60
    let minutes = (self.valueSeconds div 60) mod 60

    posprintf(addr self.hexBuffer, "%02d:%02d", minutes, seconds)
    self.label.put(addr self.hexBuffer)
    self.updateFlag = false

    printf("elif self.updateFlag")    

