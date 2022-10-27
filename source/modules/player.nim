import natu/[graphics, input]
import components/projectile/bulletplayer
import types/[scenes, entities, hud]
import modules/shooter

proc controlsGame*(playerShip: var PlayerShip; centerNumber: var CenterNumber;
    modifierSlots: var ModifierSlots; gameStatus: var GameStatus) =
  if gameStatus != GameOver:
    if gameStatus == Play or gameStatus == Intro:
      if keyIsDown(kiLeft):
        playerShip.angle += 350
      if keyIsDown(kiRight):
        playerShip.angle -= 350
      if keyHit(kiA):
        let bulPlayerProj = initProjectileBulletPlayer(gfxBulletTemp,
            playerShip.body.pos)
        shooter.fireBulletPlayer(bulPlayerProj, playerShip.angle)
      if keyHit(kiB):
        centerNumber.inputModifierValue(modifierSlots)
    if keyHit(kiStart):
      if gameStatus == Paused:
        gameStatus = Play
      elif gameStatus == Play:
        gameStatus = Paused

