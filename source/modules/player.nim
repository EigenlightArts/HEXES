import natu/[graphics, input]
import types/[scenes, entities, hud]
import utils/audio
import components/projectile/bulletplayer
import modules/[shooter, levels]

# TODO(Kal): Need to experiment with this value
const playerSpeed = 400

proc resetModifierValue(modifierSlots: var ModifierSlots) =
  modifierSlots.modifierNumber.valueNumber = 0
  modifierSlots.modifierOperator.valueOperator = okNone

proc inputModifierValue(self: var CenterNumber;
    modifierSlots: var ModifierSlots) =
  if modifierSlots.modifierNumber.valueNumber == 0:
    audio.playSound(sfxError)
  else:
    case modifierSlots.modifierOperator.valueOperator:
    of okNone: audio.playSound(sfxError)
    of okAdd:
      self.value = self.value + modifierSlots.modifierNumber.valueNumber
      audio.playSound(sfxCenterNumberChange)
      modifierSlots.resetModifierValue()
    of okSub:
      self.value = self.value - modifierSlots.modifierNumber.valueNumber
      audio.playSound(sfxCenterNumberChange)
      modifierSlots.resetModifierValue()
    of okMul:
      self.value = self.value * modifierSlots.modifierNumber.valueNumber
      audio.playSound(sfxCenterNumberChange)
      modifierSlots.resetModifierValue()
    of okDiv:
      self.value = self.value div modifierSlots.modifierNumber.valueNumber
      audio.playSound(sfxCenterNumberChange)
      modifierSlots.resetModifierValue()
    of okMod:
      self.value = self.value mod modifierSlots.modifierNumber.valueNumber
      audio.playSound(sfxCenterNumberChange)
      modifierSlots.resetModifierValue()

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
        audio.playMusic(getLevelMusic(game.level))
        game.state = Play
      elif game.state == Play:
        audio.playMusic(modPause)
        game.state = Paused
  else:
    audio.playSound(sfxPlayerDeath)
