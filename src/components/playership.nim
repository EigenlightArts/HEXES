import natu/[math, graphics, video, bios, input]
import ../utils/objs
import bullet

#TODO(Kal): Use the `Graphics` enum instead of calling gfxShipTemp, etc directly

type
  PlayerShip = object
    initialised: bool
    orbitRadius, tileId, paletteId: int
    angle: Angle
    centerPoint, pos: Vec2i

    shooter: Shooter

# constructor - create a ship object
proc initPlayerShip*(p: Vec2i): PlayerShip =
  result.initialised = true # you should add an extra field
  result.orbitRadius = 67
  result.pos = p
  result.angle = 0
  result.centerPoint = vec2i(120, 80)
  result.tileId = allocObjTiles(gfxShipTemp)
  result.paletteId = acquireObjPal(gfxShipTemp)

  result.shooter.initShooter()
  

# destructor - free the resources used by a ship object
proc `=destroy`*(self: var PlayerShip) =
  if self.initialised:
    self.initialised = false
    freeObjTiles(self.tileId)
    releaseObjPal(gfxShipTemp)
    self.shooter.destroy()

proc `=copy`*(dest: var PlayerShip; source: PlayerShip) {.error: "Not implemented".}

# draw ship sprite and all the affine snazziness
proc draw*(self: PlayerShip) =
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

# ship controls
proc controls*(self: var PlayerShip) =
  if keyIsDown(kiLeft):
    self.angle += 350
  if keyIsDown(kiRight):
    self.angle -= 350
  if keyIsDown(kiA):
    var bulletsFired: int

    if bulletsFired <= 3:
      self.shooter.addBullet(self.pos)

# calculate and update ship position
proc updatePos*(self: var PlayerShip) =
  self.pos.x = self.centerPoint.x + toInt(luCos(
      self.angle) * self.orbitRadius)
  self.pos.y = self.centerPoint.y + toInt(luSin(
      self.angle) * self.orbitRadius)