import natu/[math, graphics, video, oam, utils]
import utils/[objs, body]
import components/shared

type
  BossEffectsKind* = enum
    beSequence
    beShields