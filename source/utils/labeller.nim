import utils/label
import natu/posprintf

type Labeller* = object
  labels: seq[Label]
  labelsTid: int
  labelsPalId: int
  gfx: Graphic
  indexOffset: int

# proc initLabeller*(gfx: Graphic, pos: Vec2i, count: int, ink: uint16, shadow: uint16): Labeller =
#   result.