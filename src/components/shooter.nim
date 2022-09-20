import natu/[math, graphics, video, utils, mgba]
# import ../utils/[objs, labels]
import projectile

type Shooter* = object
  initialised: bool

var bulletPlayerEntitiesInstances: List[5, Projectile]
var bulletEnemyEntitiesInstances: List[3, Projectile]
var enemyEntitiesInstances: List[5, Projectile]
var modiferEntitiesInstances: List[3, Projectile]

proc initShooter*(): Shooter =
  result.initialised = true

proc destroy*(self: var Shooter) =
  for bulletPlayer in bulletPlayerEntitiesInstances:
    freeObjTiles(bulletPlayer.tileId)
    releaseObjPal(bulletPlayer.graphic)
  for bulletEnemy in bulletEnemyEntitiesInstances:
    freeObjTiles(bulletEnemy.tileId)
    releaseObjPal(bulletEnemy.graphic)
  for enemy in enemyEntitiesInstances:
    freeObjTiles(enemy.tileId)
    releaseObjPal(enemy.graphic)
  for modifier in modiferEntitiesInstances:
    freeObjTiles(modifier.tileId)
    releaseObjPal(modifier.graphic)

proc fire*(self: var Shooter, projectile: var Projectile, pos: Vec2f = vec2f(0,
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

proc update*(self: var Shooter) =
  # var indexModifier = 0
  # var indexEnemy = 0
  # var indexBulletEnemy = 0
  # var indexBulletPlayer = 0

  # while indexModifier < (modiferEntitiesInstances.len) and
  #     indexModifier <= modiferEntitiesInstances.cap:
  #   printf("while indexModifier modiferEntitiesInstances.len: %d",
  #       modiferEntitiesInstances.len) #

  #   if not modiferEntitiesInstances[indexModifier].finished:
  #     modiferEntitiesInstances[indexModifier].update()

  #   inc indexModifier

  for modifer in mitems(modiferEntitiesInstances):
    if not modifer.finished:
      modifer.update()
  

#[
  while indexEnemy < (enemyEntitiesInstances.len):
    if not enemyEntitiesInstances[indexEnemy].finished:
      enemyEntitiesInstances[indexEnemy].update()

    if enemyEntitiesInstances[indexEnemy].finished:
      enemyEntitiesInstances.del(indexEnemy)
    else:
      inc indexEnemy

    while indexBulletEnemy < (bulletEnemyEntitiesInstances.len):
      if not bulletEnemyEntitiesInstances[indexBulletEnemy].finished:
        bulletEnemyEntitiesInstances[indexBulletEnemy].update()

      if bulletEnemyEntitiesInstances[indexBulletEnemy].finished:
        bulletEnemyEntitiesInstances.del(indexBulletEnemy)
      else:
        inc indexBulletEnemy
]#

  for bullet in mitems(bulletPlayerEntitiesInstances):
    if not bullet.finished:
      bullet.update()
      for modifierBullet in mitems(modiferEntitiesInstances):
        if not modifierBullet.finished:
          if isCollidingAABB(bullet.toRect(), modifierBullet.toRect()):
            bullet.finished = true
            modifierBullet.finished = true
          
  #[ while indexBulletPlayer < bulletPlayerEntitiesInstances.len and
      indexBulletPlayer <= bulletPlayerEntitiesInstances.cap:
    var indexBPModifier = 0

    bulletPlayerEntitiesInstances[indexBulletPlayer].update()

    printf("out while modiferEntitiesInstances.len: %d",
        modiferEntitiesInstances.len) # Prints 0

    while indexBPModifier < modiferEntitiesInstances.len:

      printf("in while modiferEntitiesInstances.len: %d",
          modiferEntitiesInstances.len) # Doesn't print anything


      if isCollidingAABB(
          bulletPlayerEntitiesInstances[indexBulletPlayer].toRect(),
          modiferEntitiesInstances[indexBPModifier].toRect()):
        printf("ASSERT SHOOTER AFTER COLLIDER CHECK")
        bulletPlayerEntitiesInstances[indexBulletPlayer].finished = true
        modiferEntitiesInstances[indexBPModifier].finished = true

      inc indexBPModifier

    inc indexBulletPlayer ]#

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


proc draw*(self: var Shooter) =
  for bulletPlayer in mitems(bulletPlayerEntitiesInstances):
    bulletPlayer.draw()
  for bulletEnemy in mitems(bulletEnemyEntitiesInstances):
    bulletEnemy.draw()
  for enemy in mitems(enemyEntitiesInstances):
    enemy.draw()
  for modifier in mitems(modiferEntitiesInstances):
    modifier.drawModifier()
