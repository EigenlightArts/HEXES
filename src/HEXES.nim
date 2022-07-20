import natu/[video, bios, irq, input, math, utils, graphics, oam]
import utils/objs

# # Memory locations used by our sprite:
# const oid = 0 # OAM entry number




 # var angle: Angle = 0
 # var speed: Angle = 2
 # var velocity = vec2f()


# ship position vector
# var pos =

# enable VBlank interrupt so we can wait for the end of the frame without burning CPU cycles
irq.enable(iiVBlank)

dispcnt = initDispCnt(obj = true, obj1d = true)

irq.enable(iiVBlank)

# PlayerShip
type
  PlayerShip = object
    initialised: bool
    orbitRadius, tileId, paletteId: int
    angle: Angle
    centerPoint, pos: Vec2i

# constructor - create a ship object
proc initPlayerShip(p: Vec2i): PlayerShip =
  result.initialised = true   # you should add an extra field
  result.orbitRadius = 75
  result.tileId = allocObjTiles(gfxShipTemp)
  result.paletteId = acquireObjPal(gfxShipTemp)
  result.centerPoint = vec2i(120, 80)
  result.pos = p
  result.angle = 0

# destructor - free the resources used by a ship object
proc `=destroy`(self: var PlayerShip) =
  if self.initialised:
    self.initialised = false
    freeObjTiles(self.tileId)
    releaseObjPal(gfxShipTemp)

proc `=copy`(dest: var PlayerShip; source: PlayerShip) {.error:"Not implemented".}

proc draw(self: PlayerShip) =
  copyFrame(addr objTileMem[self.tileId], gfxShipTemp, 0)
  withObjAndAff:
    
# create a ship:
var playerShipInstance = initPlayerShip(vec2i(120, 80))



# # if you want to destroy the ship:
# reset(myShip)

# let pal = acquireObjPal(gfxShipTemp)
# let tid = allocObjTiles(gfxShipTemp)

# copyFrame(addr objTileMem[tid], gfxShipTemp, 0)


# var playerShip = PlayerShip(orbitRadius: orbitRadius, angle: 0,
#     centerPoint: screenCenter, pos: vec2i(orbitRadius, 0), tileId: tid,
#     paletteId: pal)



let shipPlayer = addr objMem[0]
shipPlayer[].init:
  mode = omAff
  pos = pos
  size = gfxShipTemp.size
  tid = tid
  pal = pal

while true:
  # update key states
  keyPoll()

  # ship controls
  if keyIsDown(kiLeft):
    angle += 350
  if keyIsDown(kiRight):
    angle -= 350
  pos.x = center.x + toInt(luCos(angle) * radius) - 8
  pos.y = center.y + toInt(luSin(angle) * radius) - 8
  # if keyIsDown(kiA): shoot()

  # wait for the end of the frame
  VBlankIntrWait()
  playerShipInstance.draw()
  flushPals()

  # update sprite position
  shipPlayer[].pos = pos
