import natu/[math, graphics, video, mgba]
import utils/labels

export labels, mgba

type CenterNumber* = object
  initialised*: bool
  label*: Label
  hexBuffer*: array[9, char]

  value*: int
  target*: int
  updateFlag*: bool

proc `=destroy`*(self: var CenterNumber) =
  if self.initialised:
    self.initialised = false
    releaseObjPal(gfxShipTemp)
    self.label.destroy()

proc `=copy`*(dest: var CenterNumber;
    source: CenterNumber) {.error: "Not implemented".}


type Timer* = object
  initialised*: bool
  label*: Label
  hexBuffer*: array[9, char]

  updateFlag*: bool
  introFlag*: bool
  
  valueSeconds*: int
  valueFrames*: int
  introSeconds*: int

proc `=destroy`*(self: var Timer) =
  if self.initialised:
    self.initialised = false
    releaseObjPal(gfxShipTemp)
    self.label.destroy()

proc `=copy`*(dest: var Timer;
    source: Timer) {.error: "Not implemented".}
