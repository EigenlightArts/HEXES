import utils/savedata

# TODO(Kal): Implement better save system

var totalScore*: uint
var highScore*: uint = getHighScore()
var newHighScore*: bool

const scoreLimit = 9999

proc addScoreFromSeconds*(seconds: int) =
  totalScore += uint(seconds div 3)

  if totalScore > scoreLimit:
    totalScore = scoreLimit

proc resetScore*() =
  totalScore = 0
  newHighScore = false

proc checkAndStoreIfNewHighScore*() =
  if totalScore > highScore:
    highScore = totalScore
    saveHighScore(totalScore)
    newHighScore = true
