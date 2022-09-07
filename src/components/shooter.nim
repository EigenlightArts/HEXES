import natu/[math, graphics, video, utils, mgba]
# import ../utils/[objs, labels]
import projectile

type Shooter* = object
  projectilesSeq: seq[Projectile]

proc initShooter*(): Shooter =
  result.projectilesSeq.setLen(0)

proc destroy*(self: var Shooter) =
  for projectile in self.projectilesSeq:
    freeObjTiles(projectile.tileId)
    releaseObjPal(projectile.graphic)

proc draw*(self: var Shooter) =
  for projectile in mitems(self.projectilesSeq):
    if not projectile.finished:
      case projectile.kind:
      of pkBulletEnemy, pkBulletPlayer, pkEnemy:
        projectile.draw()
      of pkModifier:
        # printf("in shooter.nim 1, before drawMod projectile")
        projectile.drawMod()
        printf("in shooter.nim 2, after drawMod projectile")


proc fire*(self: var Shooter, projectile: var Projectile, pos: Vec2f = vec2f(0,
    0), angle: Angle = 0) =

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
  # for projectile in mitems(self.projectilesSeq):
  #   case projectile.kind:
  #   of pkBulletEnemy, pkBulletPlayer, pkEnemy:
  #     projectile.update()
  #   of pkModifier:
  #     projectile.update(bulletPlayerEntitiesInstances[projectile.index])
  #   if projectile.finished:
  #     case projectile.kind:
  #     of pkBulletPlayer:
  #       # printf("in shooter.nim 1, before del bulletPlayerEntitiesInstances")
  #       bulletPlayerEntitiesInstances.del(projectile.index)
  #       printf("in shooter.nim 2, after del bulletPlayerEntitiesInstances")
  #     of pkBulletEnemy:
  #       bulletEnemyEntitiesInstances.del(projectile.index)
  #     of pkEnemy:
  #       enemyEntitiesInstances.del(projectile.index)
  #     of pkModifier:
  #       modiferEntitiesInstances.del(projectile.index)


  var i = 0

  while i < self.projectilesSeq.len:
    case self.projectilesSeq[i].kind:
    of pkBulletEnemy, pkBulletPlayer, pkEnemy:
      if not self.projectilesSeq[i].finished:
        self.projectilesSeq[i].update()
    of pkModifier:
      if not self.projectilesSeq[i].finished: 
        # printf("in shooter.nim 1, before update bulletPlayerEntitiesInstances")
        self.projectilesSeq[i].update(bulletPlayerEntitiesInstances[i])
        printf("in shooter.nim 2, after update bulletPlayerEntitiesInstances")

    if self.projectilesSeq[i].finished:
      case self.projectilesSeq[i].kind:
      of pkBulletPlayer:
        # printf("in shooter.nim 1, before del bulletPlayerEntitiesInstances")
        bulletPlayerEntitiesInstances.del(i)
        printf("in shooter.nim 2, after del bulletPlayerEntitiesInstances")
      of pkBulletEnemy:
        bulletEnemyEntitiesInstances.del(i)
      of pkEnemy:
        enemyEntitiesInstances.del(i)
      of pkModifier:
        modiferEntitiesInstances.del(i)

      self.projectilesSeq.delete(i)
    else:
      inc i
