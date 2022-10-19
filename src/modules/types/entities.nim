import natu/[math, graphics, video, mgba]
import utils/body

export body, mgba

type PlayerShip* = object
  initialised*: bool
  tileId*, paletteId*: int
  orbitRadius*: Vec2i
  centerPoint*: Vec2i
  body*: Body
  angle*: Angle

# destructor - free the resources used by a ship object
proc `=destroy`*(self: var PlayerShip) =
  if self.initialised:
    self.initialised = false
    freeObjTiles(self.tileId)
    releaseObjPal(gfxShipTemp)

proc `=copy`*(dest: var PlayerShip; source: PlayerShip) {.error: "Not implemented".}


type EvilHex* = object
  initialised*: bool

  tileId*, paletteId*: int
  body*: Body

  orbitRadius*: Vec2i
  centerPoint*: Vec2i

# destructor - free the resources used by the hex object
proc `=destroy`*(self: var EvilHex) =
  if self.initialised:
    self.initialised = false
    freeObjTiles(self.tileId)
    releaseObjPal(gfxShipTemp)

proc `=copy`*(dest: var EvilHex; source: EvilHex) {.error: "Not implemented".}
