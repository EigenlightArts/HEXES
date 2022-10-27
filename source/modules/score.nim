import natu/[bios, irq, oam, input, video, mgba, math, memory]
import utils/savedata

var totalScore*: uint
var highScore*: uint = getHighScore()
var newHighScore*: bool

proc addScoreFromSeconds*(seconds: int) =
  totalScore += uint(seconds div 3)

proc resetScore*() =
  totalScore = 0
  newHighScore = false

proc checkAndStoreIfNewHighScore*() =
  if totalScore > highScore:
    highScore = totalScore
    saveHighScore(totalScore)
    newHighScore = true
