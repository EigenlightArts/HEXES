import natu/[graphics, video]
import utils/[labels, audio]
import components/projectile/modifier

export labels

var timeScoreValue*: int
var timeScorePenalty*: int = -30

type ModifierSlots* = object
  initialised*: bool

  modifierOperator*: Modifier
  modifierNumber*: Modifier
  drawNumber*: bool
  drawOperator*: bool

proc `=destroy`*(self: var ModifierSlots) =
  if self.initialised:
    self.initialised = false

proc `=copy`*(dest: var ModifierSlots;
    source: ModifierSlots) {.error: "Not implemented".}

proc assignModifiers*(modifierSlots: var ModifierSlots;
    modifierStored: Modifier) =
  if modifierStored.kind == mkNumber:
    audio.playSound(sfxNumberChange)
    modifierSlots.modifierNumber = modifierStored
    modifierSlots.drawNumber = true
  if modifierStored.kind == mkOperator:
    audio.playSound(sfxOperatorChange)
    modifierSlots.modifierOperator = modifierStored
    modifierSlots.drawOperator = true

type CenterNumber* = object
  initialised*: bool
  label*: Label
  labelBuffer*: array[9, char]

  value*: int
  target*: int

proc `=destroy`*(self: var CenterNumber) =
  if self.initialised:
    self.initialised = false
    releaseObjPal(gfxShipPlayer)
    self.label.destroy()

proc `=copy`*(dest: var CenterNumber;
    source: CenterNumber) {.error: "Not implemented".}

proc inputModifierValue*(self: var CenterNumber;
    modifierSlots: var ModifierSlots) =
  if modifierSlots.modifierNumber.valueNumber != 0 and
      modifierSlots.modifierOperator.valueOperator != okNone:
    audio.playSound(sfxCenterNumberChange)
    case modifierSlots.modifierOperator.valueOperator:
    of okNone:
      discard
    of okAdd: self.value = self.value + modifierSlots.modifierNumber.valueNumber
    of okSub: self.value = self.value - modifierSlots.modifierNumber.valueNumber
    of okMul: self.value = self.value * modifierSlots.modifierNumber.valueNumber
    of okDiv: self.value = self.value div modifierSlots.modifierNumber.valueNumber

    modifierSlots.modifierNumber.valueNumber = 0
    modifierSlots.modifierOperator.valueOperator = okNone
  else:
    audio.playSound(sfxError)


type
  Timer* = object
    initialised*: bool
    label*: Label
    labelBuffer*: array[9, char]

    valueSeconds*: int
    valueFrames*: int
    introSeconds*: int
    introSecondsInitial*: int
    limitSeconds*: int

proc `=destroy`*(self: var Timer) =
  if self.initialised:
    self.initialised = false
    releaseObjPal(gfxShipPlayer)
    self.label.destroy()

proc `=copy`*(dest: var Timer;
    source: Timer) {.error: "Not implemented".}


type Target* = object
  initialised*: bool
  label*: Label
  labelBuffer*: array[9, char]

  target*: int

proc `=destroy`*(self: var Target) =
  if self.initialised:
    self.initialised = false
    releaseObjPal(gfxShipPlayer)
    self.label.destroy()

proc `=copy`*(dest: var Target;
    source: Target) {.error: "Not implemented".}
