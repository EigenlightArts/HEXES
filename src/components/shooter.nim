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

proc draw*(self: var Shooter) =
  for bulletPlayer in mitems(self.bulletPlayerEntitiesInstances):
    bulletPlayer.draw()
  for bulletEnemy in mitems(self.bulletEnemyEntitiesInstances):
    bulletEnemy.draw()
  for enemy in mitems(self.enemyEntitiesInstances):
    enemy.draw()
  for modifier in mitems(self.modiferEntitiesInstances):
    modifier.drawModifier()


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
  var indexBulletEnemy = 0
  var indexEnemy = 0
  var indexModifier = 0
  var indexModifierBulletPlayer = 0

  while indexBulletPlayer < (self.bulletPlayerEntitiesInstances.len):
    if not self.bulletPlayerEntitiesInstances[indexBulletPlayer].finished:
      self.bulletPlayerEntitiesInstances[indexBulletPlayer].update()
      printf("if not self.bulletPlayerEntitiesInstances[indexBulletPlayer].finished: ASSERT")

    if self.bulletPlayerEntitiesInstances[indexBulletPlayer].finished:
      self.bulletPlayerEntitiesInstances.del(indexBulletPlayer)
      printf("if self.bulletPlayerEntitiesInstances[indexBulletPlayer].finished: ASSERT")
    else:
      inc indexBulletPlayer
      # printf("else: inc indexBulletPlayer ASSERT")

  while indexBulletEnemy < (self.bulletEnemyEntitiesInstances.len):
    if not self.bulletEnemyEntitiesInstances[indexBulletEnemy].finished:
      self.bulletEnemyEntitiesInstances[indexBulletEnemy].update()
      printf("if not self.bulletEnemyEntitiesInstances[indexBulletEnemy].finished: ASSERT")

    if self.bulletEnemyEntitiesInstances[indexBulletEnemy].finished:
      self.bulletEnemyEntitiesInstances.del(indexBulletEnemy)
      printf("if self.bulletEnemyEntitiesInstances[indexBulletEnemy].finished: ASSERT")
    else:
      inc indexBulletEnemy
      printf("else: inc indexBulletEnemy ASSERT")

  while indexEnemy < (self.enemyEntitiesInstances.len):
    if not self.enemyEntitiesInstances[indexEnemy].finished:
      self.enemyEntitiesInstances[indexEnemy].update()
      printf("if not self.enemyEntitiesInstances[indexEnemy].finished: ASSERT")

    if self.enemyEntitiesInstances[indexEnemy].finished:
      self.enemyEntitiesInstances.del(indexEnemy)
      printf("if self.enemyEntitiesInstances[indexEnemy].finished: ASSERT")
    else:
      inc indexEnemy
      printf("else: inc indexEnemy ASSERT")

  while indexModifier < (self.modiferEntitiesInstances.len):
    if not self.modiferEntitiesInstances[indexModifier].finished:
      self.modiferEntitiesInstances[indexModifier].update(
          self.modiferEntitiesInstances[indexModifierBulletPlayer])
      # self.modiferEntitiesInstances[indexModifier].update()
      #[ while indexBulletPlayer < (
        self.bulletPlayerEntitiesInstances.len):
      self.modiferEntitiesInstances[indexModifier].update(
        self.modiferEntitiesInstances[indexBulletPlayer])
      # printf("in shooter.nim 1 (update) proc update x = %l, y = %l, angle = %l",
      #     self.modiferEntitiesInstances[indexModifier].pos.x.toInt(),
      #     self.modiferEntitiesInstances[indexModifier].pos.y.toInt(),
      #     self.modiferEntitiesInstances[indexModifier].angle.uint16) ]#

    if self.modiferEntitiesInstances[indexModifier].finished:
      self.modiferEntitiesInstances.del(indexModifier)
      printf("if self.modiferEntitiesInstances[indexModifier].finished: ASSERT")
    else:
      inc indexModifier
      inc indexModifierBulletPlayer
