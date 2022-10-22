import natu/[input, math, utils]
import utils/scene
import entities/[playership, evilhex]
import entities/hud/[ecn, timer, target, modifierslots]
import modules/[shooter, player]
import types/[entities, hud]

type Game = ref object
  ecnValue: int
  ecnTarget: int
  timerInitial: int

var game: Game

var playerShipInstance: PlayerShip
var evilHexInstance: EvilHex

var centerNumberInstance: CenterNumber
var timerInstance: Timer
var targetInstance: Target
var modifierSlotsInstance: ModifierSlots

var eventLoopTimer: int
var eventLoopRand: int
var eventModifierShoot: int
var eventModifierIndex: int
var eventEnemyShoot: int
var eventEnemySelect: int

const timerInitialConst = 300

# TODO(Kal): Implement Controlled RNG for game events
# See:
# - C:\Users\Kaleidosium\Documents\School Shiz\Project Documentation\HEXES\Visual Journal\handmade-help-1.txt
# - https://probablydance.com/2019/08/28/a-new-algorithm-for-controlled-randomness/

proc startEventLoop() =
  eventLoopTimer = 0
  eventLoopRand = rand(1..10)
  eventEnemyShoot = rand(1..4)
  eventEnemySelect = rand(1..4)
  eventModifierShoot = rand(3..8)
  # TODO(Kal): Probably a good idea to make operators more common
  eventModifierIndex = rand(1..19) # excludes 0 and $

proc onShow =
  game.ecnValue = rand(0..255)
  game.ecnTarget = rand(0..255)
  game.timerInitial = timerInitialConst

  while game.ecnValue == game.ecnTarget:
    game.ecnTarget = rand(0..255)
  
  playerShipInstance = initPlayerShip(vec2f(75, 0))
  evilHexInstance = initEvilHex()

  centerNumberInstance = initCenterNumber(game.ecnValue, game.ecnTarget)
  timerInstance = initTimer(game.timerInitial, 5)
  targetInstance = initTarget(centerNumberInstance.target)
  modifierSlotsInstance = initModifierSlots()

  startEventLoop()

proc onUpdate =
  # after 120 vblank units, restart event loop
  if eventLoopTimer == 120:
    startEventLoop()

  # update key states
  keyPoll()

  # player controls
  player.controlsGame(playerShipInstance, centerNumberInstance, modifierSlotsInstance)

  # update ship position
  playerShipInstance.update()

  # fire the EvilHex projectile
  if eventLoopRand == eventModifierShoot:
    evilHexInstance.fireModifierHex(eventModifierIndex,
        playerShipInstance.body.pos)
  if eventLoopRand == eventEnemyShoot:
    evilHexInstance.fireEnemyHex(eventEnemySelect, playerShipInstance.body.pos)

  # update timer
  timerInstance.update()

  # update EvilHex subroutines
  # evilHexInstance.update()

  # update shooter
  shooter.update(playerShipInstance, evilHexInstance, modifierSlotsInstance)

  inc eventLoopTimer

proc onHide =
  game = nil

proc onDraw =
  # draw the timer label
  timerInstance.draw(centerNumberInstance.target)

  # If it's no longer the intro, add a target label 
  targetInstance.draw(timerInstance.introFlag)

  # draw the Shooter projectiles
  shooter.draw()

  # draw the ship
  playerShipInstance.draw()

  # draw the CenterNumber
  centerNumberInstance.draw()

  modifierSlotsInstance.draw()


const GameScene* = Scene(
  show: onShow,
  hide: onHide,
  update: onUpdate,
  draw: onDraw,
)