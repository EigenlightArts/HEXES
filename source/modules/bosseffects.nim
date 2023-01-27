import natu/[math, graphics, video, oam, utils]
import utils/[objs, body]
import components/shared

type
  BossEffectsKind* = enum
    beSequence
    beShields
  BossEffects* = object
    case kind*: BossEffectsKind
    of beSequence:
      bseqActive*: bool
      bseqSubract*: bool
      bseqChangeSec*: int
      bseqPatternCurrent*: int
      bseqPattern*: array[6, int]
    of beShields:
      nil

