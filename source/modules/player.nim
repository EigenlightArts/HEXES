import natu/[graphics, input]
import types/[scenes, entities, hud]
import utils/audio
import components/projectile/bulletplayer
import modules/shooter

# TODO(Kal): Need to experiment with this value
const playerSpeed = 400 

proc controlsGame*(playerShip: var PlayerShip; centerNumber: var CenterNumber;
    modifierSlots: var ModifierSlots; game: var Game) =
  if game.state != GameOver:
    if game.state == Play or game.state == Intro:
      if keyIsDown(kiLeft):
        playerShip.angle += playerSpeed
      if keyIsDown(kiRight):
        playerShip.angle -= playerSpeed
      if keyHit(kiLeft) or keyHit(kiRight):
        audio.playSound(sfxShipAccel)
      if keyHit(kiA):
        audio.playSound(sfxPlayerShoot)
        let bulPlayerProj = initProjectileBulletPlayer(gfxBulletPlayer,
            playerShip.body.pos)
        shooter.fireBulletPlayer(bulPlayerProj, playerShip.angle)
      if keyHit(kiB):
        centerNumber.inputModifierValue(modifierSlots)
    if keyHit(kiStart):
      audio.stopMusic()
      if game.state == Paused:
        game.playGameMusic()
        game.state = Play
      elif game.state == Play:
        audio.playMusic(modPause)
        game.state = Paused
  else:
    audio.playSound(sfxPlayerDeath)

