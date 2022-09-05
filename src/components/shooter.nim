import natu/[math, graphics, video, oam, utils, mgba]
import ../utils/[objs, labels]
import projectile

type Shooter* = object
  projectilesSeq: seq[Projectile]

proc initShooter*(): Shooter =
  result.projectilesSeq.setLen(0)

proc destroy*(self: var Shooter) =
  for projectile in self.projectilesSeq:
    freeObjTiles(projectile.tileId)
    releaseObjPal(projectile.graphic)

proc draw*(self: Shooter) =
  for projectile in self.projectilesSeq:
    if not projectile.finished:
      var projectileMut = projectile
      case projectile.kind:
      of pkBulletEnemy, pkBulletPlayer, pkEnemy:
        projectileMut.draw()
      of pkModifier:
        projectileMut.drawMod()

  # var i = 0

  # while i < self.projectilesSeq.len:
  #   if not self.projectilesSeq[i].finished:
  #     for bulletPlayer in mitems(bulletPlayerEntitiesInstances):
  #       bulletPlayer.draw()
  #     for modifier in mitems(modiferEntitiesInstances):
  #       modifier.drawMod()
  #   inc i


proc fire*(self: var Shooter, projectile: var Projectile, pos: Vec2f = vec2f(0,
    0), index = 0, angle: Angle = 0) =

  projectile.index = index
  projectile.pos = pos
  projectile.angle = angle
  projectile.finished = false

  case projectile.kind:
    of pkBulletPlayer:
      if not bulletPlayerEntitiesInstances.isFull:
        self.projectilesSeq.insert(projectile)
        bulletPlayerEntitiesInstances.add(projectile)
      # TODO(Kal): bullet else play sfx
    of pkBulletEnemy:
      if not bulletEnemyEntitiesInstances.isFull:
        self.projectilesSeq.insert(projectile)
        bulletEnemyEntitiesInstances.add(projectile)
    of pkEnemy:
      discard
    of pkModifier:
      if not modiferEntitiesInstances.isFull:
        self.projectilesSeq.insert(projectile)
        modiferEntitiesInstances.add(projectile)


proc update*(self: var Shooter) =
  var i = 0

  while i < self.projectilesSeq.len:
    self.projectilesSeq[i].update()

    for projectile in self.projectilesSeq:
      var projectileMut = projectile
      
      case projectile.kind:
      of pkBulletEnemy, pkBulletPlayer, pkEnemy:
        projectileMut.update()
      of pkModifier:
        projectileMut.update(bulletPlayerEntitiesInstances[i])
    
    # bulletPlayerEntitiesInstances[i].update()
    # modiferEntitiesInstances[i].update(bulletPlayerEntitiesInstances[i])

    if self.projectilesSeq[i].finished:
      case self.projectilesSeq[i].kind
      of pkBulletPlayer:
        bulletPlayerEntitiesInstances.del(i)
      of pkBulletEnemy:
        bulletEnemyEntitiesInstances.del(i)
      of pkEnemy:
        enemyEntitiesInstances.del(i)
      of pkModifier:
        modiferEntitiesInstances.del(i)

      self.projectilesSeq.delete(i)
    else:
      inc i

