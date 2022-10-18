import natu/[math, graphics, video, mgba]
import utils/[labels, body]

export labels, body, mgba

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


type EvilHexCenterNumber* = object
  initialised*: bool
  label*: Label

  update*: bool
  value*: int

proc `=destroy`*(self: var EvilHexCenterNumber) =
  if self.initialised:
    self.initialised = false
    releaseObjPal(gfxShipTemp)
    self.label.destroy()

proc `=copy`*(dest: var EvilHexCenterNumber;
    source: EvilHexCenterNumber) {.error: "Not implemented".}


type EvilHex* = object
  initialised*: bool
  centerNumber*: EvilHexCenterNumber

  tileId*, paletteId*: int
  hexBuffer*: array[9, char]
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


type Timer* = object
  initialised*: bool
  label*: Label

  updateFlag*: bool
  hexBuffer*: array[9, char]
  valueSeconds*: int
  valueFrames*: int

proc `=destroy`*(self: var Timer) =
  if self.initialised:
    self.initialised = false
    releaseObjPal(gfxShipTemp)
    self.label.destroy()

proc `=copy`*(dest: var Timer;
    source: Timer) {.error: "Not implemented".}
