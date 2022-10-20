import natu/[video, utils, mgba]
import components/projectile/[bulletplayer, bulletenemy, enemy, modifier]
import components/shared
import utils/body
import modules/types/[entities, hud]

export bulletplayer, bulletenemy, enemy, modifier

var invisibilityFrames: int = 400
var invisibilityOn: bool = false

var timeScoreValue*: int
var timeScorePenalty*: int = -30

proc destroy*() =
  bulletPlayerEntitiesInstances.clear()
  bulletEnemyEntitiesInstances.clear()
  enemyEntitiesInstances.clear()
  modifierEntitiesInstances.clear()

proc draw*() =
  for bulletPlayer in mitems(bulletPlayerEntitiesInstances):
    bulletPlayer.draw()
  for bulletEnemy in mitems(bulletEnemyEntitiesInstances):
    bulletEnemy.draw()
  for enemy in mitems(enemyEntitiesInstances):
    enemy.draw()
  for modifier in mitems(modifierEntitiesInstances):
    modifier.draw()

proc update*(playerShip: var PlayerShip, evilHex: var EvilHex, modifierSlots: var ModifierSlots) =
  for enemy in mitems(enemyEntitiesInstances):
    if enemy.status == Active:
      enemy.update()
      
      if collide(playerShip.body, enemy.body) and not invisibilityOn:
        enemy.status = Finished
        timeScoreValue = timeScorePenalty
        invisibilityOn = true

  for bulletEnemy in mitems(bulletEnemyEntitiesInstances):
    if bulletEnemy.status == Active:
      bulletEnemy.update(speed = 2)
      
      if collide(playerShip.body, bulletEnemy.body):
        bulletEnemy.status = Finished
        timeScoreValue = timeScorePenalty

  if invisibilityOn:
    if invisibilityFrames >= 0:
      invisibilityFrames = 400
      invisibilityOn = false
    
    dec invisibilityFrames

  for modifier in mitems(modifierEntitiesInstances):
    if modifier.status == Active:
      modifier.update()

  for bulletPlayer in mitems(bulletPlayerEntitiesInstances):
    if bulletPlayer.status == Active:
      bulletPlayer.update(speed = 2)
      for modifierBP in mitems(modifierEntitiesInstances):
        if modifierBP.status == Active:
          if collide(modifierBP.body, bulletPlayer.body):
            bulletPlayer.status = Finished
            modifierBP.status = Finished

            modifierSlots.assignModifiers(modifierBP)
      for enemyBP in mitems(enemyEntitiesInstances):
        if enemyBP.status == Active:
          if collide(enemyBP.body, bulletPlayer.body):
            timeScoreValue = enemyBP.timeScore
            bulletPlayer.status = Finished
            enemyBP.status = Finished
      if collide(evilHex.body, bulletPlayer.body):
        bulletPlayer.status = Finished

  var indexFinishedMD = 0
  var indexFinishedEN = 0
  var indexFinishedBP = 0
  var indexFinishedBE = 0

  while indexFinishedMD < modifierEntitiesInstances.len:
    if modifierEntitiesInstances[indexFinishedMD].status == Finished:
      modifierEntitiesInstances.delete(indexFinishedMD)
    else:
      inc indexFinishedMD

  while indexFinishedEN < enemyEntitiesInstances.len:
    if enemyEntitiesInstances[indexFinishedEN].status == Finished:
      enemyEntitiesInstances.delete(indexFinishedEN)
    else:
      inc indexFinishedEN

  while indexFinishedBP < bulletPlayerEntitiesInstances.len:
    if bulletPlayerEntitiesInstances[indexFinishedBP].status == Finished:
      bulletPlayerEntitiesInstances.del(indexFinishedBP)
    else:
      inc indexFinishedBP

  while indexFinishedBE < bulletEnemyEntitiesInstances.len:
    if bulletEnemyEntitiesInstances[indexFinishedBE].status == Finished:
      bulletEnemyEntitiesInstances.del(indexFinishedBE)
    else:
      inc indexFinishedBE

