import natu/[graphics, video]
import utils/[labels, audio]
import components/projectile/modifier

export labels

var timeScoreValue*: int
var timeScorePenaltyBul*: int = -10

type ModifierSlots* = object
  initialised*: bool

  modifierNumber*: Modifier
  modifierOperator*: Modifier
  drawNumber*: bool
  drawOperator*: bool

proc `=destroy`*(self: var ModifierSlots) =
  if self.initialised:
    self.initialised = false

proc `=copy`*(dest: var ModifierSlots;
    source: ModifierSlots) {.error: "Not implemented".}

proc storeModifier*(modifierSlots: var ModifierSlots;
    modifierStored: Modifier) =
  if modifierStored.kind == mkNumber:
    audio.playSound(sfxNumberChange)
    modifierSlots.modifierNumber = modifierStored
    modifierSlots.drawNumber = true
  elif modifierStored.kind == mkOperator:
    audio.playSound(sfxOperatorChange)
    modifierSlots.modifierOperator = modifierStored
    modifierSlots.drawOperator = true

const bseqPatternMax* = 6

type
  BossEffectKind* = enum
    beSequence
    beShields
  BossEffect* = object
    case kind*: BossEffectKind
    of beSequence:
      bseqActive*: bool
      bseqSubract*: bool
      bseqChangeFrames*: int
      bseqPatternCurrent*: int
      bseqPattern*: array[bseqPatternMax, int]
    of beShields:
      nil

import modules/levels

type CenterNumber* = object
  initialised*: bool
  isBoss*: bool

  label*: Label
  labelBuffer*: array[9, char]
  activeBEs*: array[maxActiveBEs, BossEffect]

  value*: int
  target*: int
  bossWarningFrames*: int

proc `=destroy`*(self: var CenterNumber) =
  if self.initialised:
    self.initialised = false
    releaseObjPal(gfxShipPlayer)
    self.label.destroy()

proc `=copy`*(dest: var CenterNumber;
    source: CenterNumber) {.error: "Not implemented".}

type
  Timer* = object
    initialised*: bool

    valueSeconds*: int
    valueFrames*: int
    introSeconds*: int
    introSecondsInitial*: int
    limitSeconds*: int

proc `=destroy`*(self: var Timer) =
  if self.initialised:
    self.initialised = false

proc `=copy`*(dest: var Timer;
    source: Timer) {.error: "Not implemented".}

proc getValueFrames*(self: Timer): int = self.valueFrames
proc getValueSeconds*(self: Timer): int = self.valueFrames div 60
proc setValueSeconds*(self: var Timer, valueSeconds: int) = self.valueFrames = valueSeconds * 60
proc addValueSeconds*(self: var Timer, valueSeconds: int) = self.valueFrames += valueSeconds * 60

type
  Status* = object
    isBoss*: bool
    initialised*: bool
    label*: Label
    labelBuffer*: array[9, char]

    timer*: Timer

proc `=destroy`*(self: var Status) =
  if self.initialised:
    self.initialised = false
    releaseObjPal(gfxShipPlayer)
    self.label.destroy()

proc `=copy`*(dest: var Status;
    source: Status) {.error: "Not implemented".}

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
