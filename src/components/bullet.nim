import natu/[math, graphics, video, bios]
import ../utils/objs

type
  Bullet* = object
    initialised: bool
    limit, tileId, paletteId: int
    angle: Angle
    centerPoint, pos: Vec2i

# constructor - create a bullet object
proc initBullet*(p: Vec2i): Bullet =
  result.initialised = true # you should add an extra field
  result.limit = 3
  result.pos = p
  result.angle = 0
  result.centerPoint = vec2i(120, 80)
  result.tileId = allocObjTiles(gfxBulletTemp)
  result.paletteId = acquireObjPal(gfxBulletTemp)

# destructor - free the resources used by a bullet object
proc `=destroy`(self: var Bullet) =
  if self.initialised:
    self.initialised = false
    freeObjTiles(self.tileId)
    releaseObjPal(gfxBulletTemp)

proc `=copy`(dest: var Bullet; source: Bullet) {.error: "Not implemented".}

# draw bullet sprite and all the affine snazziness
proc draw(self: Bullet) =
  copyFrame(addr objTileMem[self.tileId], gfxBulletTemp, 0)
  withObjAndAff:
    let delta = self.centerPoint - self.pos
    aff.setToRotationInv(ArcTan2(int16(delta.x), int16(delta.y)))
    obj.init:
      mode = omAff
      affId = affId
      pos = self.pos - vec2i(gfxBulletTemp.width div 2,
          gfxBulletTemp.height div 2)
      size = gfxBulletTemp.size
      tileId = self.tileId
      palId = self.paletteId

# calculate and update ship position
proc updatePos(self: var Bullet) =
  self.pos.x += toInt(luCos(
      self.angle))
  self.pos.y += toInt(luSin(
      self.angle))