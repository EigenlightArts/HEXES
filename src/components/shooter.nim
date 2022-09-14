import natu/[math, graphics, video, utils, mgba]
# import ../utils/[objs, labels]
import projectile

type Shooter* = object
  initialised: bool

  bulletPlayerEntitiesInstances*: List[5, Projectile]
  bulletEnemyEntitiesInstances*: List[3, Projectile]
  enemyEntitiesInstances*: List[5, Projectile]
  modiferEntitiesInstances*: List[3, Projectile]


proc initShooter*(): Shooter =
  result.initialised = true

proc destroy*(self: var Shooter) =
  for bulletPlayer in self.bulletPlayerEntitiesInstances:
    freeObjTiles(bulletPlayer.tileId)
    releaseObjPal(bulletPlayer.graphic)
  for bulletEnemy in self.bulletEnemyEntitiesInstances:
    freeObjTiles(bulletEnemy.tileId)
    releaseObjPal(bulletEnemy.graphic)
  for enemy in self.enemyEntitiesInstances:
    freeObjTiles(enemy.tileId)
    releaseObjPal(enemy.graphic)
  for modifier in self.modiferEntitiesInstances:
    freeObjTiles(modifier.tileId)
    releaseObjPal(modifier.graphic)

proc fire*(self: var Shooter, projectile: var Projectile, pos: Vec2f = vec2f(0,
    0), angle: Angle = 0) =

  projectile.pos = pos
  projectile.angle = angle
  projectile.finished = false

  case projectile.kind:
    of pkBulletPlayer:
      if not self.bulletPlayerEntitiesInstances.isFull:
        self.bulletPlayerEntitiesInstances.add(projectile)
      # TODO(Kal): bullet else play sfx
    of pkBulletEnemy:
      if not self.bulletEnemyEntitiesInstances.isFull:
        self.bulletEnemyEntitiesInstances.add(projectile)
    of pkEnemy:
      discard
    of pkModifier:
      if not self.modiferEntitiesInstances.isFull:
        self.modiferEntitiesInstances.add(projectile)

proc update*(self: var Shooter) =
  var indexBulletPlayer = 0
  var indexModifier = 0
  var indexEnemy = 0
  var indexBulletEnemy = 0

  while indexBulletPlayer < self.bulletPlayerEntitiesInstances.len and
      indexBulletPlayer <= self.bulletPlayerEntitiesInstances.cap:
    var indexBPModifier = 0

    while indexBPModifier < self.modiferEntitiesInstances.len:
      self.bulletPlayerEntitiesInstances[indexBulletPlayer].update()

      if isCollidingAABB(
          self.bulletPlayerEntitiesInstances[indexBulletPlayer].toRect(),
          self.modiferEntitiesInstances[indexBPModifier].toRect()):
        printf("ASSERT SHOOTER AFTER COLLIDER CHECK")
        self.bulletPlayerEntitiesInstances[indexBulletPlayer].finished = true
        self.modiferEntitiesInstances[indexBPModifier].finished = true

      inc indexBPModifier

    inc indexBulletPlayer

  while indexModifier < (self.modiferEntitiesInstances.len) and
      indexModifier <= self.modiferEntitiesInstances.cap:
    if not self.modiferEntitiesInstances[indexModifier].finished:
      self.modiferEntitiesInstances[indexModifier].update()

    if indexModifier < self.modiferEntitiesInstances.len:
      inc indexModifier

#[
  while indexEnemy < (self.enemyEntitiesInstances.len):
    if not self.enemyEntitiesInstances[indexEnemy].finished:
      self.enemyEntitiesInstances[indexEnemy].update()

    if self.enemyEntitiesInstances[indexEnemy].finished:
      self.enemyEntitiesInstances.del(indexEnemy)
    else:
      inc indexEnemy

    while indexBulletEnemy < (self.bulletEnemyEntitiesInstances.len):
      if not self.bulletEnemyEntitiesInstances[indexBulletEnemy].finished:
        self.bulletEnemyEntitiesInstances[indexBulletEnemy].update()

      if self.bulletEnemyEntitiesInstances[indexBulletEnemy].finished:
        self.bulletEnemyEntitiesInstances.del(indexBulletEnemy)
      else:
        inc indexBulletEnemy
]#

  var indexBPFinished = 0
  var indexMDFinished = 0

  while indexBPFinished < self.bulletPlayerEntitiesInstances.len:
    if self.bulletPlayerEntitiesInstances[indexBPFinished].finished:
      self.bulletPlayerEntitiesInstances.del(indexBPFinished)
    else:
      inc indexBPFinished

  while indexMDFinished < self.modiferEntitiesInstances.len:
    if self.modiferEntitiesInstances[indexMDFinished].finished:
      self.modiferEntitiesInstances.del(indexMDFinished)
    else:
      inc indexMDFinished


proc draw*(self: var Shooter) =
  for bulletPlayer in mitems(self.bulletPlayerEntitiesInstances):
    bulletPlayer.draw()
  for bulletEnemy in mitems(self.bulletEnemyEntitiesInstances):
    bulletEnemy.draw()
  for enemy in mitems(self.enemyEntitiesInstances):
    enemy.draw()
  for modifier in mitems(self.modiferEntitiesInstances):
    modifier.drawModifier()
