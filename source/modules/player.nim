import natu/[graphics, input]
import components/projectile/bulletplayer
import types/[entities, hud]
import modules/shooter

proc controlsGame*(playerShip: var PlayerShip; centerNumber: var CenterNumber;
    modifierSlots: var ModifierSlots; gameOver: bool) =
  if not screenStopOn or not gameOver:
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
