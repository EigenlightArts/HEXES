import natu/[math, graphics, video]
import ../utils/[objs, labels]

type
  EntityKind = enum
    ekBullet
    ekEnemy
    ekModifier
  Entity = object
    # fields that all have in common
    pos: Vec2f
    angle: Angle
    index: int
    finished: bool

    case kind: EntityKind
    of ekBullet:
      # fields that only bullets have
      damage: int
    of ekEnemy:
      # fields that only enemies have
      health: int
      doesItShoot: bool
    of ekModifier:
      # fields that only modifiers have
      # modifier: Modifier
      modLabel: Label
      modType: string

type Shooter* = object
  entity: seq[Entity]
  entityActive: int
  entityLimit: int
  entityTileId: int
  entityPalId: int

proc initShooter*(limit = 5, gfx = gfxBulletTemp, entityType: Entity): Shooter =
  result.entityTileId = allocObjTiles(gfx)
  copyFrame(addr objTileMem[result.entityTileId], gfx, 0)
  result.entityPalId = acquireObjPal(gfx)
  result.entityLimit = limit
  result.entity.setLen(0)

  # TODO(Kal): For Day 10, I feel awful today.
  # case entityType
  # of ekModifier:
  #   modLabel.init(vec2i(20, 10), s8x16, count=22)
  #   modLabel.obj.pal = getPalId(gfxShield)
  #   modLabel.ink = 1  # set the ink colour index to use from the palette
  #   modLabel.shadow = 2  # set the shadow colour (only relevant if the font actually has more than 1 colour)


proc destroy*(self: var Shooter, gfx = gfxBulletTemp) =
  freeObjTiles(self.entityTileId)
  releaseObjPal(gfx)

proc draw*(entity: Entity, shooter: Shooter, gfx = gfxBulletTemp) =
  withObjAndAff:
    # aff.setToScaleInv(fp 1, (fp entity.fadeTimer / entity.fadeTimerMax).clamp(fp 0, fp 1))
    obj.init(
      mode = omAff,
      aff = affId,
      pos = vec2i(entity.pos) - vec2i(gfx.width div 2,
          gfx.height div 2),
      tid = shooter.entityTileId + (entity.index),
      pal = shooter.entityPalId,
      size = gfx.size
    )
  # printf("in bullet.nim proc draw: x = %l, y = %l", entity.pos.x.toInt(), entity.pos.y.toInt())

proc fire*(self: var Shooter, pos: Vec2f = vec2f(0, 0), index = 0,
    angle: Angle = 0) =

  var entity: Entity

  entity.index = index
  entity.pos = pos
  entity.angle = angle
  # entity.showTimer = showTimer
  # entity.fadeTimer = fadeTimer
  # entity.fadeTimerMax = fadeTimer
  entity.finished = false

  if self.entityActive < self.entityLimit:
    self.entity.insert(entity)
    self.entityActive += 1
  # TODO(Kal): if playership bullet else play sfx

# Bullet spefific procedures

proc rect(bullet: Entity): Rect =
  result.left = bullet.pos.x.toInt() - 5
  result.top = bullet.pos.y.toInt() - 5
  result.right = bullet.pos.x.toInt() + 5
  result.bottom = bullet.pos.y.toInt() + 5

proc update*(bullet: var Entity) =

  # make sure the bullets go where they are supposed to go
  # the *2 is for speed reasons, without it, the bullets are very slow
  bullet.pos.x = bullet.pos.x - fp(luCos(
      bullet.angle)) * 2
  bullet.pos.y = bullet.pos.y - fp(luSin(
       bullet.angle)) * 2

  if (not onscreen(bullet.rect())):
    bullet.finished = true


proc update*(self: var Shooter) =
  var i = 0

  while i < self.entity.len:
    self.entity[i].update()
    if self.entity[i].finished:
      self.entity.delete(i)
      self.entityActive -= 1
    else:
      inc i


proc draw*(self: Shooter) =
  for entity in self.entity:
    entity.draw(self)
