import natu/[video, backgrounds, irq, math, utils]
import utils/[scene, log, audio, camera]
import entities/[playership, evilhex]
import entities/hud/[ecn, status, target, modifierslots]
import modules/[shooter, player, score, levels]
import components/timer
import components/projectile/[enemy, modifier]
import types/[scenes, entities, hud]

proc goToGameEndScene()

var game: Game

var ecnValue: int
var ecnTarget: int
var shootEnemy: int
var chooseModifierKind: int

var eventLoopTimer: int
var eventLevelUpTimer: int
var eventGameOverTimer: int
var eventModifierIndex: int
var eventModifierShoot: int
var eventEnemyShoot: int
var eventAllowedEnemies: EnemyKind
var eventAllowedOperators: OperatorKind

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


proc reset(game: var Game) =
  audio.stopMusic()

  game.state = Intro

  eventLevelUpTimer = timerLevelUpFrames
  eventGameOverTimer = timerGameOverFrames

  ecnValue = rand(selectTargetRange(game.level))
  ecnTarget = rand(selectTargetRange(game.level))

  while ecnValue == ecnTarget:
    ecnTarget = rand(selectTargetRange(game.level))

  game.isBoss = bossCheck(game.level)
  if game.isBoss:
    let levelEffects = getEffects(game.level)
    assert(levelEffects.len <= maxActiveBEs, "Too many boss effects in level config.")
    for (i, effect) in levelEffects.pairs:
      game.centerNumberInstance.activeBEs[i] = effect

  game.evilHexInstance = initEvilHex(game.isBoss)
  game.playerShipInstance = initPlayerShip(vec2f(75, 0))
  game.playerShipInstance.angle = 16500

  game.centerNumberInstance = initCenterNumber(ecnValue, ecnTarget, game.isBoss)
  game.timerInstance = initTimer(timerInitialSeconds, timerIntroSeconds, timerLimitSeconds)
  game.statusInstance = initStatus()
  game.targetInstance = initTarget(game.centerNumberInstance.target)
  game.modifierSlotsInstance = initModifierSlots()

  game.playGameMusic()

proc initGame(): Game = result.level = 1; result.reset()

proc levelUp(self: var Game) =
  audio.stopMusic()
  audio.playMusic(modCompletionLoop)
  display.layers = display.layers - {lBg2}

  if self.level < levelMax:
    inc self.level
    self.state = LevelUp
  elif self.level >= levelMax:
    goToGameEndScene()

proc startEventLoop() =
  eventLoopTimer = 0

  shootEnemy = rand(0..1)
  chooseModifierKind = rand(0..2)

  log "game.level: %d", game.level

  eventAllowedEnemies = selectEnemy(game.level)
  eventAllowedOperators = selectOperator(game.level)
  eventEnemyShoot = enemyShoot(game.level)
  eventModifierShoot = modifierShoot(game.level)

  # excludes 0 and $
  eventModifierIndex = if chooseModifierKind == 0: int(eventAllowedOperators) +
      15 else: rand(1..15)

proc onShow =
  game = initGame()

  # Use a BG Control register to select a charblock and screenblock:
  bgcnt[0].init(cbb = 1, sbb = 30)
  # Load the tiles, map and palette into memory:
  bgcnt[0].load(bgPlayingHUD)

  # background asset
  bgcnt[2].init(cbb = 2, sbb = 24)
  bgcnt[2].load(bgPlayingBG)

  display.layers = {lBg0, lBg2, lObj}
  display.obj1d = true

  # enable VBlank interrupt so we can wait for
  # the end of the frame without burning CPU cyclessize
  irq.enable(iiVBlank)

  startEventLoop()

proc onUpdate =
  updateCamera()

  # after 100 vblank units, restart event loop
  if eventLoopTimer == 100:
    startEventLoop()

  game.centerNumberInstance.update(game.timerInstance)

  player.controlsGame(game.playerShipInstance, game.centerNumberInstance,
      game.modifierSlotsInstance, game)

  game.modifierSlotsInstance.draw(game.state)
  # log("modifierNumber.valueNumber: %d", game.modifierSlotsInstance.modifierNumber.valueNumber)
  # log("modifierOperator.valueOperator: %s", $game.modifierSlotsInstance.modifierOperator.valueOperator)

  if game.state == Play or game.state == Intro:
    game.playerShipInstance.update()

    # fire the EvilHex projectiles
    if eventLoopTimer == eventModifierShoot:
      game.evilHexInstance.fireModifierHex(eventModifierIndex,
          game.playerShipInstance.body.pos)
    if eventLoopTimer == eventEnemyShoot and shootEnemy == 0:
      game.evilHexInstance.fireEnemyHex(eventAllowedEnemies,
          game.playerShipInstance.body.pos)

    game.evilHexInstance.update(game.timerInstance)
    game.timerInstance.update(game.state)
    shooter.update(game.playerShipInstance, game.evilHexInstance,
        game.modifierSlotsInstance)

    # if keyHit(kiSelect): # NOTE(Kal): Debug Only
    if game.centerNumberInstance.value == game.centerNumberInstance.target:
      game.levelUp()

  if game.state == LevelUp:
    discard rand() # introduce some nondeterminism to the RNG

    dec eventLevelUpTimer
    if eventLevelUpTimer <= 0:
      addScoreFromSeconds(game.timerInstance.getValueSeconds())
      shooter.destroy()
      display.layers = display.layers + {lBg2}

      game.reset()

  if game.state == GameOver:
    dec eventGameOverTimer
    if eventGameOverTimer <= 0:
      eventGameOverTimer = timerGameOverFrames
      goToGameEndScene()

  inc eventLoopTimer

proc onHide =
  display.layers = display.layers - {lBg0, lBg2, lObj}
  display.obj1d = false

proc onDraw =
  game.statusInstance.draw(game.timerInstance, game.state,
      game.centerNumberInstance.target, eventLoopTimer)
  game.targetInstance.draw(game.state)

  # draw the Shooter projectiles
  shooter.draw(game.state)

  game.evilHexInstance.draw(game.state)
  game.centerNumberInstance.draw(game.state)
  game.playerShipInstance.draw(game.state)
  game.modifierSlotsInstance.draw(game.state)


const GameScene* = Scene(
  show: onShow,
  hide: onHide,
  update: onUpdate,
  draw: onDraw,
)

import scenes/gameend

proc goToGameEndScene() =
  setScene(GameEndScene)
