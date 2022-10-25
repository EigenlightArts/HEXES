import natu/[graphics, video, mgba]
import utils/labels
import components/projectile/modifier

export labels, mgba

var timeScoreValue*: int
var timeScorePenalty*: int = -30

type ModifierSlots* = object
  initialised*: bool

  modifierOperator*: Modifier
  modifierNumber*: Modifier
  drawNumber*: bool
  drawOperator*: bool
  updateFlag*: bool

proc `=destroy`*(self: var ModifierSlots) =
  if self.initialised:
    self.initialised = false

proc `=copy`*(dest: var ModifierSlots;
    source: ModifierSlots) {.error: "Not implemented".}

proc assignModifiers*(modifierSlots: var ModifierSlots;
    modifierStored: Modifier) =
  if modifierStored.kind == mkNumber:
    modifierSlots.modifierNumber = modifierStored
    modifierSlots.drawNumber = true
  if modifierStored.kind == mkOperator:
    modifierSlots.modifierOperator = modifierStored
    modifierSlots.drawOperator = true

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

proc inputModifierValue*(self: var CenterNumber;
    modifierSlots: var ModifierSlots) =
  if modifierSlots.modifierNumber.valueNumber != 0:
    case modifierSlots.modifierOperator.valueOperator:
    of okNone:
      # TODO(Kal): Play a beep
      printf("You don't have a stored operator!")
    of okAdd: self.value = self.value + modifierSlots.modifierNumber.valueNumber
    of okSub: self.value = self.value - modifierSlots.modifierNumber.valueNumber
    of okMul: self.value = self.value * modifierSlots.modifierNumber.valueNumber
    of okDiv: self.value = self.value div modifierSlots.modifierNumber.valueNumber

    self.updateFlag = true
    modifierSlots.modifierNumber.valueNumber = 0
    modifierSlots.modifierOperator.valueOperator = okNone
  else:
    # TODO(Kal): Play a beep
    printf("You don't have a stored number and/or operator!")


type Timer* = object
  initialised*: bool
  label*: Label
  hexBuffer*: array[9, char]

  updateFlag*: bool
  introFlag*: bool

  valueSeconds*: int
  valueFrames*: int
  introSeconds*: int
  limitSeconds*: int

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
