import natu/[math, graphics, video, utils, mgba]
import ../components/projectile

export projectile

proc destroy*() =
  bulletPlayerEntitiesInstances.clear()
  bulletEnemyEntitiesInstances.clear()
  enemyEntitiesInstances.clear()
  modiferEntitiesInstances.clear()

proc update*() =

  for modifer in mitems(modiferEntitiesInstances):
    if modifer.status == Active:
      modifer.update()

  for bullet in mitems(bulletPlayerEntitiesInstances):
    if bullet.status == Active:
      bullet.update(speed=2)
      for modifierBullet in mitems(modiferEntitiesInstances):
        if modifierBullet.status == Active:
          if isCollidingAABB(bullet.toRect(), modifierBullet.toRect()):
            modifierBullet.status = Finished
            modifierBullet.status = Finished


  var indexFinishedBP = 0
  var indexFinishedMD = 0

  while indexFinishedBP < bulletPlayerEntitiesInstances.len:
    if bulletPlayerEntitiesInstances[indexFinishedBP].status == Finished:
      bulletPlayerEntitiesInstances.del(indexFinishedBP)
    else:
      inc indexFinishedBP

  while indexFinishedMD < modiferEntitiesInstances.len:
    if modiferEntitiesInstances[indexFinishedMD].status == Finished:
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
