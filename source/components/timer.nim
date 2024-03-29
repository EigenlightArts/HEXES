import utils/audio
import types/[hud, scenes]

proc initTimer*(valueSeconds: int, introSeconds: int, limitSeconds: int): Timer =
  result.initialised = true

  result.valueFrames = valueSeconds * 60
  result.introSeconds = introSeconds
  result.introSecondsInitial = result.introSeconds
  result.limitSeconds = limitSeconds

proc update*(self: var Timer, gameState: var GameState) =
  dec self.valueFrames

  if self.valueFrames mod 60 == 0:
    if gameState == Intro:
      dec self.introSeconds

    if self.introSeconds <= 0:
      gameState = Play

  if timeScoreValue != 0:
    self.addValueSeconds(timeScoreValue)

    if self.valueFrames > (self.limitSeconds * 60):
      self.valueFrames = self.limitSeconds

    timeScoreValue = 0

  # Added some headstart to offset delay
  if self.getValueFrames() mod 3610 == 0:
    audio.playSound(sfxTimeAlertMin)

  if self.valueFrames <= 0:
    gameState = GameOver

