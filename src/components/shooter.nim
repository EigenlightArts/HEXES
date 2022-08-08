import natu/[math, graphics, video, oam, utils, mgba]
import ../utils/[objs, labels]
import entity

type Shooter* = object
  entity: seq[Entity]
  entityTileId: int
  entityPalId: int

proc initShooter*(limit = 5, gfx: Graphic = gfxBulletTemp): Shooter =
  result.entityTileId = allocObjTiles(gfx)
  copyFrame(addr objTileMem[result.entityTileId], gfx, 0)
  result.entityPalId = acquireObjPal(gfx)
  result.entity.setLen(0)

proc destroy*(self: var Shooter, gfx: Graphic = gfxBulletTemp) =
  freeObjTiles(self.entityTileId)
  releaseObjPal(gfx)

proc draw*(shooter: Shooter, entity: Entity,
    gfx: Graphic = gfxBulletTemp) =
  withObjAndAff:
    aff.setToRotationInv(entity.angle.uint16)
    obj.init(
      mode = omAff,
      aff = affId,
      pos = vec2i(entity.pos) - vec2i(gfx.width div 2,
          gfx.height div 2),
      tid = shooter.entityTileId + (entity.index),
      pal = shooter.entityPalId,
      size = gfx.size
    )
  # printf("in shooter.nim proc draw: x = %l, y = %l", entity.pos.x.toInt(),
  #    entity.pos.y.toInt())

  # `mitems` makes `modiferEntitiesInstances` mutable
  for modifierInstance in mitems(modiferEntitiesInstances):
    modifierInstance.modLabel.draw()


proc fire*(self: var Shooter, entity: var Entity, pos: Vec2f = vec2f(0, 0),
    index = 0, angle: Angle = 0) =

  entity.index = index

  # printf("in shooter.nim proc fire1 x = %l, y = %l", pos.x.toInt(), pos.y.toInt())

  entity.pos = pos

  # printf("in shooter.nim proc fire2 x = %l, y = %l", entity.pos.x.toInt(),
  #    entity.pos.y.toInt())

  entity.angle = angle
  entity.finished = false

  # var bulPlayerInstance: Entity = initBulletEntity(isPlayer = true)
  # var enmInstace: Entity = initEnemyEntity()
  # var modInstance: Entity = initModifierEntity()

  case entity.kind:
    of ekBulletPlayer:
      if not bulletPlayerEntitiesInstances.isFull:
        self.entity.insert(entity)
        bulletPlayerEntitiesInstances.add(entity)
      # TODO(Kal): bullet else play sfx
    of ekBulletEnemy:
      discard
    of ekEnemy:
      discard
    of ekModifier:
      if not modiferEntitiesInstances.isFull:
        entity.modLabel.put("$100")
        self.entity.insert(entity)
        modiferEntitiesInstances.add(entity)


proc update*(self: var Shooter) =
  var i = 0

  while i < self.entity.len:
    self.entity[i].update()
    if self.entity[i].finished:
      case self.entity[i].kind
      of ekBulletPlayer:
        bulletPlayerEntitiesInstances.del(i)
      of ekBulletEnemy:
        bulletEnemyEntitiesInstances.del(i)
      of ekEnemy:
        enemyEntitiesInstances.del(i)
      of ekModifier:
        modiferEntitiesInstances.del(i)
      
      self.entity.delete(i)
    else:
      inc i


proc draw*(self: Shooter) =
  for entity in self.entity:
    self.draw(entity)
