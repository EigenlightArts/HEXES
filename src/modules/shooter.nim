import natu/[math, graphics, video, utils, mgba]
import ../components/projectile

var bulletPlayerEntitiesInstances: List[5, Projectile]
var bulletEnemyEntitiesInstances: List[3, Projectile]
var enemyEntitiesInstances: List[5, Projectile]
var modiferEntitiesInstances: List[3, Projectile]

proc destroy*() =
  bulletPlayerEntitiesInstances.clear()
  bulletEnemyEntitiesInstances.clear()
  enemyEntitiesInstances.clear()
  modiferEntitiesInstances.clear()

proc fire*(projectile: var Projectile, pos: Vec2f = vec2f(0,
    0), angle: Angle = 0) =

  projectile.pos = pos
  projectile.angle = angle
  projectile.finished = false

  case projectile.kind:
    of pkBulletPlayer:
      if not bulletPlayerEntitiesInstances.isFull:
        bulletPlayerEntitiesInstances.add(projectile)
      # TODO(Kal): bullet else play sfx
    of pkBulletEnemy:
      if not bulletEnemyEntitiesInstances.isFull:
        bulletEnemyEntitiesInstances.add(projectile)
    of pkEnemy:
      discard
    of pkModifier:
      if not modiferEntitiesInstances.isFull:
        modiferEntitiesInstances.add(projectile)

proc update*() =

  for modifer in mitems(modiferEntitiesInstances):
    if not modifer.finished:
      modifer.update()

  for bullet in mitems(bulletPlayerEntitiesInstances):
    if not bullet.finished:
      bullet.update(speed=2)
      for modifierBullet in mitems(modiferEntitiesInstances):
        if not modifierBullet.finished:
          if isCollidingAABB(bullet.toRect(), modifierBullet.toRect()):
            bullet.finished = true
            modifierBullet.finished = true


  var indexFinishedBP = 0
  var indexFinishedMD = 0

  while indexFinishedBP < bulletPlayerEntitiesInstances.len:
    if bulletPlayerEntitiesInstances[indexFinishedBP].finished:
      bulletPlayerEntitiesInstances.del(indexFinishedBP)
    else:
      inc indexFinishedBP

  while indexFinishedMD < modiferEntitiesInstances.len:
    if modiferEntitiesInstances[indexFinishedMD].finished:
      modiferEntitiesInstances.del(indexFinishedMD)
    else:
      inc indexFinishedMD


proc draw*() =
  for bulletPlayer in mitems(bulletPlayerEntitiesInstances):
    bulletPlayer.draw()
  for bulletEnemy in mitems(bulletEnemyEntitiesInstances):
    bulletEnemy.draw()
  for enemy in mitems(enemyEntitiesInstances):
    enemy.draw()
  for modifier in mitems(modiferEntitiesInstances):
    modifier.drawModifier()
