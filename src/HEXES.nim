import natu/[video, bios, irq, input, math, utils, graphics, oam]
import utils/objs

# background color, approximating eigengrau
# TODO(Kal): change this to rgb8() later
bgColorBuf[0] = rgb5(3, 3, 4) 

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
  result.initialised = true # you should add an extra field
  result.orbitRadius = 67
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

proc `=copy`(dest: var PlayerShip; source: PlayerShip) {.error: "Not implemented".}

# draw ship sprite and all the affine snazziness
proc draw(self: PlayerShip) =
  copyFrame(addr objTileMem[self.tileId], gfxShipTemp, 0)
  withObjAndAff:
    let delta = self.centerPoint - self.pos
    aff.setToRotationInv(ArcTan2(int16(delta.x), int16(delta.y)))
    obj.init:
      mode = omAff
      affId = affId
      pos = self.pos - vec2i(gfxShipTemp.width div 2, gfxShipTemp.height div 2)
      size = gfxShipTemp.size
      tileId = self.tileId
      palId = self.paletteId

# player control
proc controls(self: var PlayerShip) =
  if keyIsDown(kiLeft):
    self.angle += 350
  if keyIsDown(kiRight):
    self.angle -= 350
  # if keyIsDown(kiA): shoot()

# calculate and update sprite position
proc updatePos(self: var PlayerShip) =
  self.pos.x = self.centerPoint.x + toInt(luCos(
      self.angle) * self.orbitRadius)
  self.pos.y = self.centerPoint.y + toInt(luSin(
      self.angle) * self.orbitRadius)

# create a ship, 75 is orbitRadius:
var playerShipInstance = initPlayerShip(vec2i(75, 0))


while true:
  # update key states
  keyPoll()

  # ship controls
  playerShipInstance.controls()

  # wait for the end of the frame
  VBlankIntrWait()

  # update ship position
  playerShipInstance.updatePos()
  # draw the ship
  playerShipInstance.draw()

  # copy the PAL RAM buffer into the real PAL RAM.
  flushPals()
  # hide all the objects that weren't used
  oamUpdate()
