import natu/[math, graphics, video, oam, utils]
import ../utils/[objs, labels]
import entity

type Shooter* = object
  entity: seq[Entity]
  entityTileId: int
  entityPalId: int

proc initShooter*(limit = 5, gfx: Graphic = gfxBulletTemp,
    entityKind: EntityKind): Shooter =
  result.entityTileId = allocObjTiles(gfx)
  copyFrame(addr objTileMem[result.entityTileId], gfx, 0)
  result.entityPalId = acquireObjPal(gfx)
  result.entity.setLen(0)

  # let bulEnemyInstance = initBulletEntity() # NOTE(alt): Will be unused for a while


  # case entityKind
  # of ekBullet:
  #   let bulInstance = Entity(kind: ekBullet)
  #   bulInstance.entityLimit = 5
  # of ekEnemy:
  #   let enmInstance = Entity(kind: ekEnemy)
  # of ekModifier:
  #   let modInstance = Entity(kind: ekModifier)
  #   modInstance.modLabel.init(vec2i(20, 10), s8x16, count = 22)
  #   modInstance.modLabel.obj.pal = getPalId(gfx)
  #   modInstance.modLabel.ink = 1 # set the ink colour index to use from the palette
  #   modInstance.modLabel.shadow = 2 # set the shadow colour (only relevant if the font actually has more than 1 colour)



proc destroy*(self: var Shooter, gfx: Graphic = gfxBulletTemp) =
  freeObjTiles(self.entityTileId)
  releaseObjPal(gfx)

proc draw*(shooter: Shooter, entity: Entity,
    gfx: Graphic = gfxBulletTemp) =
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
  for entityInstance in sharedEntityInstances:
    case entityInstance.kind
    of ekBullet:
      discard
    of ekEnemy:
      discard
    of ekModifier:
      entityInstance.modLabel.draw()


proc fire*(self: var Shooter, pos: Vec2f = vec2f(0, 0),
    index = 0, angle: Angle = 0) =

  var entity: Entity

  entity.index = index
  entity.pos = pos
  entity.angle = angle
  # entity.showTimer = showTimer
  # entity.fadeTimer = fadeTimer
  # entity.fadeTimerMax = fadeTimer
  entity.finished = false

  let bulPlayerInstance: Entity = initBulletEntity(isPlayer = true)
  # NOTE(Kal): this will be unused for a bit
  # let enmInstace: Entity = initEnemyEntity()
  let modInstance: Entity = initModifierEntity()


  if bulPlayerInstance.entityActive < bulPlayerInstance.entityLimit:
    self.entity.insert(bulPlayerInstance)
    bulPlayerInstance.entityActive += 1
    sharedEntityInstances.add(bulPlayerInstance)

  if modInstance.entityActive < modInstance.entityLimit:
    modInstance.modLabel("$100")
    modInstance.entityActive += 1
    sharedEntityInstances.add(modInstance)


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


proc update*(self: var Shooter, entity: Entity) =
  var i = 0

  while i < self.entity.len:
    self.entity[i].update()
    if self.entity[i].finished:
      self.entity.delete(i)
      entity.entityActive -= 1
    else:
      inc i


proc draw*(self: Shooter) =
  for entity in self.entity:
    entity.draw(self)
