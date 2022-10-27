import natu/[video, graphics, input, irq, math, utils]
import utils/[scene, log]
import entities/[playership, evilhex]
import entities/hud/[ecn, timer, target, modifierslots]
import modules/[shooter, player, score, levels]
import types/[scenes, entities, hud]

proc goToGameEndScene()

var game: Game

var shootEnemy: int
var chooseModifierKind: int

var eventLoopTimer: int
var eventLevelUpTimer: int
var eventGameOverTimer: int
var eventModifierIndex: int
var eventModifierShoot: int
var eventEnemyShoot: int
var eventEnemySelect: int

const timerInitialSeconds = 300
const timerIntroSeconds = 5
const timerLimitSeconds = 600
const timerLevelUpFrames = 120
const timerGameOverFrames = 170

# TODO(Kal): Implement Controlled RNG for game events
# See:
# - C:\Users\Kaleidosium\Documents\School Shiz\Project Documentation\HEXES\Visual Journal\handmade-help-1.txt
# - https://probablydance.com/2019/08/28/a-new-algorithm-for-controlled-randomness/
# - https://stackoverflow.com/a/28933315/10916748
# - https://www.geeksforgeeks.org/random-number-generator-in-arbitrary-probability-distribution-fashion/

# TODO(Kal): Remaining things for Game Jam
# - Go to endGameScene if Player finishes all levels
# - Add score system calculated from remaining time in the timer
# - Add rudimentary save system for High Scores

proc initGame*(): Game =
  result.status = Intro

  result.ecnValue = rand(0..255)
  result.ecnTarget = rand(0..255)

  while result.ecnValue == result.ecnTarget:
    result.ecnTarget = rand(0..255)

  result.playerShipInstance = initPlayerShip(vec2f(75, 0))
  result.evilHexInstance = initEvilHex()

  result.centerNumberInstance = initCenterNumber(result.ecnValue, result.ecnTarget)
  result.timerInstance = initTimer(timerInitialSeconds, timerIntroSeconds, timerLimitSeconds)
  result.targetInstance = initTarget(result.centerNumberInstance.target)
  result.modifierSlotsInstance = initModifierSlots()

  eventLevelUpTimer = timerLevelUpFrames
  eventGameOverTimer = timerGameOverFrames

proc levelUp(self: var Game) =
  if self.level < levelMax:
    inc self.level
    self.status = LevelUp
  elif self.level >= levelMax:
    goToGameEndScene()

proc startEventLoop() =
  eventLoopTimer = 0

  shootEnemy = rand(0..1)
  chooseModifierKind = rand(1..4)

  log "game.level: %d", game.level

  eventEnemySelect = selectEnemy(game.level)
  eventEnemyShoot = enemyShoot(game.level)
  eventModifierShoot = enemyModifier(game.level)

  # excludes 0 and $
  eventModifierIndex = if chooseModifierKind == 4: rand(16..19) else: rand(
      1..15)

proc onShow =
  game = initGame()

  game.level = 1

  # background color, approximating eigengrau
  bgColorBuf[0] = rgb8(22, 22, 29)

  display.layers = {lBg0, lObj}
  display.obj1d = true

  # enable VBlank interrupt so we can wait for
  # the end of the frame without burning CPU cycles
  irq.enable(iiVBlank)

  startEventLoop()

proc onUpdate =
  # after 100 vblank units, restart event loop
  if eventLoopTimer == 100:
    startEventLoop()

  game.centerNumberInstance.update()

  player.controlsGame(game.playerShipInstance, game.centerNumberInstance,
      game.modifierSlotsInstance, game.status)

  game.modifierSlotsInstance.draw(game.status)

  if game.status == Play or game.status == Intro:
    game.playerShipInstance.update()

    # fire the EvilHex projectiles
    if eventLoopTimer == eventModifierShoot:
      game.evilHexInstance.fireModifierHex(eventModifierIndex,
          game.playerShipInstance.body.pos)
    if eventLoopTimer == eventEnemyShoot and shootEnemy == 1:
      game.evilHexInstance.fireEnemyHex(eventEnemySelect,
          game.playerShipInstance.body.pos)

    # game.evilHexInstance.update()
    game.timerInstance.update(game.status)
    shooter.update(game.playerShipInstance, game.evilHexInstance, game.modifierSlotsInstance)

    if keyHit(kiSelect): # FIXME(Kal): Debug Only
    # if game.ecnValue == game.ecnTarget:
      game.levelUp()

  if game.status == LevelUp:
    discard rand() # introduce some nondeterminism to the RNG

    dec eventLevelUpTimer
    if eventLevelUpTimer <= 0:
      addScoreFromSeconds(game.timerInstance.getValueSeconds())

      game = initGame()
  
  if game.status == GameOver:
    dec eventGameOverTimer
    if eventGameOverTimer <= 0:
      eventGameOverTimer = timerGameOverFrames
      goToGameEndScene()

  inc eventLoopTimer

proc onHide =
  display.layers = display.layers - {lBg0, lObj}
  display.obj1d = false

proc onDraw =
  game.timerInstance.draw(game.centerNumberInstance.target, game.status, eventLoopTimer)

  # If it's no longer the intro, add a target label
  game.targetInstance.draw(game.status)

  # draw the Shooter projectiles
  shooter.draw(game.status)

  game.centerNumberInstance.draw(game.status)
  game.playerShipInstance.draw(game.status)
  game.modifierSlotsInstance.draw(game.status)


const GameScene* = Scene(
  show: onShow,
  hide: onHide,
  update: onUpdate,
  draw: onDraw,
)

import scenes/gameend

proc goToGameEndScene() =
  setScene(GameEndScene)
