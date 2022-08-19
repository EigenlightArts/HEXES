import natu/[math, graphics, video, oam, utils, mgba]
import ../utils/[objs, labels]
import projectile

type Shooter* = object  
  projectilesSeq: seq[Projectile]

proc initShooter*(): Shooter =
  result.projectilesSeq.setLen(0)

proc destroy*(self: var Shooter) =
  for projectileShooter in self.projectilesSeq:
    case projectileShooter.kind:
    of pkBulletPlayer, pkBulletEnemy:
      freeObjTiles(projectileShooter.tileId)
      releaseObjPal(projectileShooter.graphic)
    else:
      discard
  

proc draw*(self: Shooter, projectile: Projectile) =
  for projectileShooter in self.projectilesSeq:
    withObjAndAff:
      aff.setToRotationInv(projectile.angle.uint16)
      obj.init(
        mode = omAff,
        aff = affId,
        pos = vec2i(projectile.pos) - vec2i(projectileShooter.graphic.width div 2,
            projectileShooter.graphic.height div 2),
        tid = projectileShooter.tileId + (projectile.index),
        pal = projectileShooter.palId,
        size = projectileShooter.graphic.size
      )
  # printf("in self.nim proc draw: x = %l, y = %l", projectile.pos.x.toInt(),
  #    projectile.pos.y.toInt())

  # `mitems` makes `modiferEntitiesInstances` mutable
  # for modifierInstance in mitems(modiferEntitiesInstances):
  #   modifierInstance.modLabel.draw()


proc fire*(self: var Shooter, projectile: var Projectile, pos: Vec2f = vec2f(0, 0),
    index = 0, angle: Angle = 0) =

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
      discard
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


proc draw*(self: Shooter) =
  for projectile in self.projectilesSeq:
    self.draw(projectile)
