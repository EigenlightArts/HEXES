import natu/[math, graphics, video, oam, utils, mgba]
import ../utils/[objs, labels]
import projectile

type Shooter* = object
  projectile: seq[Projectile]
  projectileTileId: int
  projectilePalId: int

proc initShooter*(gfx: Graphic): Shooter =
  result.projectileTileId = allocObjTiles(gfx)
  copyFrame(addr objTileMem[result.projectileTileId], gfx, 0)
  result.projectilePalId = acquireObjPal(gfx)
  result.projectile.setLen(0)

proc destroy*(self: var Shooter, gfx: Graphic) =
  freeObjTiles(self.projectileTileId)
  releaseObjPal(gfx)

proc draw*(shooter: Shooter, projectile: Projectile,
    gfx: Graphic) =
  withObjAndAff:
    aff.setToRotationInv(projectile.angle.uint16)
    obj.init(
      mode = omAff,
      aff = affId,
      pos = vec2i(projectile.pos) - vec2i(gfx.width div 2,
          gfx.height div 2),
      tid = shooter.projectileTileId + (projectile.index),
      pal = shooter.projectilePalId,
      size = gfx.size
    )
  # printf("in shooter.nim proc draw: x = %l, y = %l", projectile.pos.x.toInt(),
  #    projectile.pos.y.toInt())

  # `mitems` makes `modiferEntitiesInstances` mutable
  for modifierInstance in mitems(modiferEntitiesInstances):
    modifierInstance.modLabel.draw()


proc fire*(self: var Shooter, projectile: var Projectile, pos: Vec2f = vec2f(0, 0),
    index = 0, angle: Angle = 0) =

  projectile.index = index

  # printf("in shooter.nim proc fire1 x = %l, y = %l", pos.x.toInt(), pos.y.toInt())

  projectile.pos = pos

  # printf("in shooter.nim proc fire2 x = %l, y = %l", projectile.pos.x.toInt(),
  #    projectile.pos.y.toInt())

  projectile.angle = angle
  projectile.finished = false

  # var bulPlayerInstance: Projectile = initBulletProjectile(isPlayer = true)
  # var enmInstace: Projectile = initEnemyProjectile()
  # var modInstance: Projectile = initModifierProjectile()

  case projectile.kind:
    of pkBulletPlayer:
      if not bulletPlayerEntitiesInstances.isFull:
        self.projectile.insert(projectile)
        bulletPlayerEntitiesInstances.add(projectile)
      # TODO(Kal): bullet else play sfx
    of pkBulletEnemy:
      discard
    of pkEnemy:
      discard
    of pkModifier:
      if not modiferEntitiesInstances.isFull:
        self.projectile.insert(projectile)
        modiferEntitiesInstances.add(projectile)


proc update*(self: var Shooter) =
  var i = 0

  while i < self.projectile.len:
    self.projectile[i].update()
    if self.projectile[i].finished:
      case self.projectile[i].kind
      of pkBulletPlayer:
        bulletPlayerEntitiesInstances.del(i)
      of pkBulletEnemy:
        bulletEnemyEntitiesInstances.del(i)
      of pkEnemy:
        enemyEntitiesInstances.del(i)
      of pkModifier:
        modiferEntitiesInstances.del(i)
      
      self.projectile.delete(i)
    else:
      inc i


proc draw*(self: Shooter) =
  for projectile in self.projectile:
    self.draw(projectile)
