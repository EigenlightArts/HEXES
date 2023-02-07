import natu/[video, utils, math]
import components/projectile/[bulletplayer, bulletenemy, enemy, modifier]
import components/shared
import utils/[body, audio, camera]
import types/[entities, hud, scenes]

export bulletplayer, bulletenemy, enemy, modifier

proc destroy*() =
  bulletPlayerEntitiesInstances.clear()
  bulletEnemyEntitiesInstances.clear()
  enemyEntitiesInstances.clear()
  modifierEntitiesInstances.clear()

proc draw*(gameState: GameState) =
  if gameState != LevelUp:
    for bulletPlayer in mitems(bulletPlayerEntitiesInstances):
      bulletPlayer.draw()
    for bulletEnemy in mitems(bulletEnemyEntitiesInstances):
      bulletEnemy.draw()
    for enemy in mitems(enemyEntitiesInstances):
      enemy.draw()
    for modifier in mitems(modifierEntitiesInstances):
      modifier.draw()

proc update*(playerShip: var PlayerShip, evilHex: var EvilHex,
    modifierSlots: var ModifierSlots) =
  # handle Active projectiles
  if not screenStopOn:
    for enemy in mitems(enemyEntitiesInstances):
      if enemy.status == Active:
        enemy.update()

        if collide(playerShip.body, enemy.body) and not invisibilityOn:
          audio.playSound(sfxPlayerHit)
          enemy.status = Finished
          timeScoreValue = -(enemy.timeScore)
          screenStopOn = true
          invisibilityOn = true

    for bulletEnemy in mitems(bulletEnemyEntitiesInstances):
      if bulletEnemy.status == Active:
        bulletEnemy.update(speed = 2)

        if collide(playerShip.body, bulletEnemy.body) and not invisibilityOn:
          cameraShake(fp(3),fp(0.25))
          audio.playSound(sfxPlayerHit)
          bulletEnemy.status = Finished
          timeScoreValue = timeScorePenaltyBul
          screenStopOn = true
          invisibilityOn = true

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

              modifierSlots.storeModifier(modifierBP)
        for enemyBP in mitems(enemyEntitiesInstances):
          if enemyBP.status == Active:
            if collide(enemyBP.body, bulletPlayer.body):
              audio.playSound(sfxEnemyHit)

              dec enemyBP.health
              bulletPlayer.status = Finished

              if enemyBP.health <= 0:
                let sfxChoice = rand(0..1)
                if sfxChoice == 0:
                  audio.playSound(sfxExplosion)
                else:
                  audio.playSound(sfxExplosion2)

                timeScoreValue = enemyBP.timeScore
                enemyBP.status = Finished
        if collide(evilHex.body, bulletPlayer.body):
          audio.playSound(sfxEnemyHit)
          bulletPlayer.status = Finished

  # handle Screen effects
  if screenStopOn:
    if screenStopFrames <= 0:
      audio.playSound(sfxPlayerHitFlashing)
      screenStopFrames = screenStopFramesConst
      screenStopOn = false

    dec screenStopFrames

  if invisibilityOn:
    if invisibilityFrames <= 0:
      invisibilityFrames = invisibilityFramesConst
      invisibilityOn = false

    dec invisibilityFrames

  # handle Finished projectiles

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

