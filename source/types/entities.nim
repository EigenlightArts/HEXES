import natu/[math, graphics, video]
import utils/body

export body

const invisibilityFramesConst* = 300
const screenStopFramesConst* = 60

var invisibilityOn*: bool = false
var invisibilityFrames*: int = invisibilityFramesConst

var screenStopOn*: bool = false
var screenStopFrames*: int = screenStopFramesConst

type PlayerShip* = object
  initialised*: bool
  tid*, paletteId*: int
  orbitRadius*: Vec2i
  centerPoint*: Vec2i
  body*: Body
  angle*: Angle

# destructor - free the resources used by a ship object
proc `=destroy`*(self: var PlayerShip) =
  if self.initialised:
    self.initialised = false
    freeObjTiles(self.tid)
    releaseObjPal(gfxShipPlayer)

proc `=copy`*(dest: var PlayerShip; source: PlayerShip) {.error: "Not implemented".}


type EvilHex* = object
  initialised*: bool
  isBoss*: bool

  tid*, paletteId*: int
  body*: Body
  angle*: Angle

  orbitRadius*: Vec2i
  centerPoint*: Vec2i

# destructor - free the resources used by the hex object
proc `=destroy`*(self: var EvilHex) =
  if self.initialised:
    self.initialised = false
    freeObjTiles(self.tid)
    releaseObjPal(gfxShipPlayer)

proc `=copy`*(dest: var EvilHex; source: EvilHex) {.error: "Not implemented".}
