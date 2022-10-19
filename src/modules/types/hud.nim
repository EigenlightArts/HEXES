import natu/[math, graphics, video, mgba]
import utils/labels
import components/projectile/modifier

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


type ModifierSlots* = object
  initialised*: bool

  modifier*: Modifier
  numberStoredValue*: int
  operatorStoredValue*: OperatorKind
  updateFlag*: bool

proc `=destroy`*(self: var ModifierSlots) =
  if self.initialised:
    self.initialised = false

proc `=copy`*(dest: var ModifierSlots;
    source: ModifierSlots) {.error: "Not implemented".}


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


type Target* = object
  initialised*: bool
  label*: Label
  hexBuffer*: array[9, char]
  
  target*: int

proc `=destroy`*(self: var Target) =
  if self.initialised:
    self.initialised = false
    releaseObjPal(gfxShipTemp)
    self.label.destroy()

proc `=copy`*(dest: var Target;
    source: Target) {.error: "Not implemented".}
