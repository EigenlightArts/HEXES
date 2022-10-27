import natu/[video, graphics, input, irq, math, utils]
import utils/[scene, levels]
import entities/[playership, evilhex]
import entities/hud/[ecn, timer, target, modifierslots]
import modules/[shooter, player, score]
import types/[scenes, entities, hud]

proc goToGameEndScene()

var game: Game

var playerShipInstance: PlayerShip
var evilHexInstance: EvilHex

var centerNumberInstance: CenterNumber
var timerInstance: Timer
var targetInstance: Target
var modifierSlotsInstance: ModifierSlots

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

proc levelUp(self: var Game) =
  if self.level < levelMax:
    self.timer = timerInitialSeconds
    inc self.level
    self.status = LevelUp
  elif self.level >= levelMax:
    goToGameEndScene()

proc startEventLoop() =
  eventLoopTimer = 0

  shootEnemy = rand(0..1)
  chooseModifierKind = rand(0..4)

  eventEnemySelect = selectEnemy(game.level)
  eventEnemyShoot = enemyShoot(game.level)
  eventModifierShoot = enemyModifier(game.level)

  # excludes 0 and $
  eventModifierIndex = if chooseModifierKind == 4: rand(16..19) else: rand(
      1..15)

proc onShow =
  new(game)

  game.ecnValue = rand(0..255)
  game.ecnTarget = rand(0..255)
  game.timer = timerInitialSeconds
  game.status = Intro
  game.level = 1

  while game.ecnValue == game.ecnTarget:
    game.ecnTarget = rand(0..255)

  # background color, approximating eigengrau
  bgColorBuf[0] = rgb8(22, 22, 29)

  playerShipInstance = initPlayerShip(vec2f(75, 0))
  evilHexInstance = initEvilHex()

  centerNumberInstance = initCenterNumber(game.ecnValue, game.ecnTarget)
  timerInstance = initTimer(game.timer, timerIntroSeconds, timerLimitSeconds)
  targetInstance = initTarget(centerNumberInstance.target)
  modifierSlotsInstance = initModifierSlots()

  eventLevelUpTimer = timerLevelUpFrames
  eventGameOverTimer = timerGameOverFrames

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

  centerNumberInstance.update()

  player.controlsGame(playerShipInstance, centerNumberInstance,
      modifierSlotsInstance, game.status)

  if game.status == Play or game.status == Intro:
    playerShipInstance.update()

    # fire the EvilHex projectiles
    if eventLoopTimer == eventModifierShoot:
      evilHexInstance.fireModifierHex(eventModifierIndex,
          playerShipInstance.body.pos)
    if eventLoopTimer == eventEnemyShoot and shootEnemy == 1:
      evilHexInstance.fireEnemyHex(eventEnemySelect,
          playerShipInstance.body.pos)

    # evilHexInstance.update()
    timerInstance.update(game.status)
    shooter.update(playerShipInstance, evilHexInstance, modifierSlotsInstance)

    if keyHit(kiSelect): # FIXME(Kal): Debug Only
    # if game.ecnValue == game.ecnTarget:
      game.levelUp()

  if game.status == LevelUp:
    dec eventLevelUpTimer
    if eventLevelUpTimer <= 0:
      addScoreFromSeconds(game.timer)
      eventLevelUpTimer = timerLevelUpFrames
      game.status = Intro
  
  if game.status == GameOver:
    dec eventGameOverTimer
    if eventGameOverTimer <= 0:
      eventGameOverTimer = timerGameOverFrames
      goToGameEndScene()

  inc eventLoopTimer

proc onHide =
  game = nil

  display.layers = display.layers - {lBg0, lObj}
  display.obj1d = false

proc onDraw =
  timerInstance.draw(centerNumberInstance.target, game.status, eventLoopTimer)

  # If it's no longer the intro, add a target label
  targetInstance.draw(game.status)

  # draw the Shooter projectiles
  shooter.draw(game.status)

  centerNumberInstance.draw(game.status)
  playerShipInstance.draw(game.status)
  modifierSlotsInstance.draw(game.status)


const GameScene* = Scene(
  show: onShow,
  hide: onHide,
  update: onUpdate,
  draw: onDraw,
)

import scenes/gameend

proc goToGameEndScene() =
  setScene(GameEndScene)
