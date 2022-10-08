import natu/[math, graphics, video, utils, mgba]
import components/projectile/[bulletplayer, bulletenemy, enemy, modifier]
import components/shared
import utils/body

export bulletplayer, bulletenemy, enemy, modifier

var valueNumberStored*: int
var valueOperatorStored*: OperatorKind

proc destroy*() =
  bulletPlayerEntitiesInstances.clear()
  bulletEnemyEntitiesInstances.clear()
  enemyEntitiesInstances.clear()
  modifierEntitiesInstances.clear()

proc update*() =
  for modifier in mitems(modifierEntitiesInstances):
    if modifier.status == Active:
      modifier.update()

  for bullet in mitems(bulletPlayerEntitiesInstances):
    if bullet.status == Active:
      bullet.update(speed = 2)
      for modifierBullet in mitems(modifierEntitiesInstances):
        if modifierBullet.status == Active:
          if collide(modifierBullet.body, bullet.body):
            if modifierBullet.kind == mkNumber:
              valueNumberStored = modifierBullet.valueNumber
            if modifierBullet.kind == mkOperator:
              valueOperatorStored = modifierBullet.valueOperator
            bullet.status = Finished
            modifierBullet.status = Finished


  var indexFinishedBP = 0
  var indexFinishedMD = 0

  while indexFinishedBP < bulletPlayerEntitiesInstances.len:
    if bulletPlayerEntitiesInstances[indexFinishedBP].status == Finished:
      bulletPlayerEntitiesInstances.del(indexFinishedBP)
    else:
      inc indexFinishedBP

  while indexFinishedMD < modifierEntitiesInstances.len:
    if modifierEntitiesInstances[indexFinishedMD].status == Finished:
      modifierEntitiesInstances.delete(indexFinishedMD)
    else:
      inc indexFinishedMD


proc draw*() =
  for bulletPlayer in mitems(bulletPlayerEntitiesInstances):
    bulletPlayer.draw()
  for bulletEnemy in mitems(bulletEnemyEntitiesInstances):
    bulletEnemy.draw()
  # FIXME(Kal): Uncomment when Enemies get implemented 
  # for enemy in mitems(enemyEntitiesInstances):
  #   enemy.draw()
  for modifier in mitems(modifierEntitiesInstances):
    modifier.draw()
