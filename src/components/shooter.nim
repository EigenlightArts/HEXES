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

  while indexBulletPlayer < (self.bulletPlayerEntitiesInstances.len):
    if not self.bulletPlayerEntitiesInstances[indexBulletPlayer].finished:
      self.bulletPlayerEntitiesInstances[indexBulletPlayer].update()
      printf("if not self.bulletPlayerEntitiesInstances[indexBulletPlayer].finished: ASSERT")

    if self.bulletPlayerEntitiesInstances[indexBulletPlayer].finished:
      self.bulletPlayerEntitiesInstances.del(indexBulletPlayer)
      printf("if self.bulletPlayerEntitiesInstances[indexBulletPlayer].finished: ASSERT")
    else:
      inc indexBulletPlayer
      printf("else: inc indexBulletPlayer ASSERT")

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
          self.bulletPlayerEntitiesInstances[indexBulletPlayer])
      printf("if not self.modiferEntitiesInstances[indexModifier].finished: ASSERT")

    if self.modiferEntitiesInstances[indexModifier].finished:
      self.modiferEntitiesInstances.del(indexModifier)
      printf("if self.modiferEntitiesInstances[indexModifier].finished: ASSERT")
    else:
      inc indexModifier
      printf("else: inc indexModifier ASSERT")

  #[
    while i < (self.bulletPlayerEntitiesInstances.len + self.bulletEnemyEntitiesInstances.len + self.enemyEntitiesInstances.len + self.modiferEntitiesInstances.len):
      if not self.bulletPlayerEntitiesInstances[i].finished:
        self.bulletPlayerEntitiesInstances[i].update()
        printf("if not self.bulletPlayerEntitiesInstances[i].finished: ASSERT")
      if not self.bulletEnemyEntitiesInstances[i].finished:
        self.bulletEnemyEntitiesInstances[i].update()
        printf("if not self.bulletEnemyEntitiesInstances[i].finished: ASSERT")
      if not self.enemyEntitiesInstances[i].finished:
        self.enemyEntitiesInstances[i].update()
        printf("if not self.enemyEntitiesInstances[i].finished: ASSERT")
      if not self.modiferEntitiesInstances[i].finished:
        self.modiferEntitiesInstances[i].update(self.bulletPlayerEntitiesInstances[i])
        printf("if not self.modiferEntitiesInstances[i].finished: ASSERT")

      if self.bulletPlayerEntitiesInstances[i].finished:
        self.bulletPlayerEntitiesInstances.del(i)
        printf("if self.bulletPlayerEntitiesInstances[i].finished: ASSERT")
      elif self.bulletEnemyEntitiesInstances[i].finished:
        self.bulletEnemyEntitiesInstances.del(i)
        printf("elif self.bulletEnemyEntitiesInstances[i].finished: ASSERT")
      elif self.enemyEntitiesInstances[i].finished:
        self.enemyEntitiesInstances.del(i)
        printf("elif self.enemyEntitiesInstances[i].finished: ASSERT")
      elif self.modiferEntitiesInstances[i].finished:
        self.modiferEntitiesInstances.del(i)
        printf("elif self.modiferEntitiesInstances[i].finished: ASSERT")
      else:
        inc i
        printf("else: inc i ASSERT")
      ]#
