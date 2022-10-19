import natu/[math, graphics, video, bios, input]
import components/projectile/bulletplayer
import entities/hud/ecn
import entities/playership
import modules/types/[entities, hud]
import modules/shooter

proc controlsGame*(playerShip: var PlayerShip; centerNumber: var CenterNumber) =
  if keyIsDown(kiLeft):
    playerShip.angle += 350
  if keyIsDown(kiRight):
    playerShip.angle -= 350
  if keyHit(kiA):
    let bulPlayerProj = initProjectileBulletPlayer(gfxBulletTemp, playerShip.body.pos)
    shooter.fireBulletPlayer(bulPlayerProj, playerShip.angle)
  if keyHit(kiB):
    centerNumber.inputModifierValue()

    # printf("in playership.nim proc controls x = %l, y = %l", self.pos.x.toInt(),
    #     self.pos.y.toInt())
