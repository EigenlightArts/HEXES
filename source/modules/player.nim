import natu/[math, graphics, video, bios, input]
import components/projectile/bulletplayer
import entities/playership
import types/[entities, hud]
import modules/shooter

proc controlsGame*(playerShip: var PlayerShip; centerNumber: var CenterNumber;
    modifierSlots: var ModifierSlots) =
  if not screenStopOn:
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
