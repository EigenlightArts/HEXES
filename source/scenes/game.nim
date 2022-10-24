import natu/[video, graphics, input, irq, math, utils]
import utils/scene
import entities/[playership, evilhex]
import entities/hud/[ecn, timer, target, modifierslots]
import modules/[shooter, player]
import types/[entities, hud]

type Game = ref object
  ecnValue: int
  ecnTarget: int
  timerInitial: int
  gameOverFlag: bool

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
  shootEnemy = rand(0..1)
  chooseModifierKind = rand(0..4)

  eventLoopTimer = 0
  eventEnemyShoot = rand(10..40)
  eventEnemySelect = rand(1..4)
  eventModifierShoot = rand(30..80)
  # excludes 0 and $
  eventModifierIndex = if chooseModifierKind == 4: rand(16..19) else: rand(
      1..15)

proc onShow =
  new(game)

  # background color, approximating eigengrau
  bgColorBuf[0] = rgb8(22, 22, 29)

  game.ecnValue = rand(0..255)
  game.ecnTarget = rand(0..255)
  game.timerInitial = timerInitialConst
  game.gameOverFlag = false

  while game.ecnValue == game.ecnTarget:
    game.ecnTarget = rand(0..255)

  playerShipInstance = initPlayerShip(vec2f(75, 0))
  evilHexInstance = initEvilHex()

  centerNumberInstance = initCenterNumber(game.ecnValue, game.ecnTarget)
  timerInstance = initTimer(game.timerInitial, 5)
  targetInstance = initTarget(centerNumberInstance.target)
  modifierSlotsInstance = initModifierSlots()

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

  player.controlsGame(playerShipInstance, centerNumberInstance, modifierSlotsInstance, game.gameOverFlag)

  playerShipInstance.update()

  # fire the EvilHex projectiles
  if eventLoopTimer == eventModifierShoot and shootEnemy == 1:
    evilHexInstance.fireModifierHex(eventModifierIndex,
        playerShipInstance.body.pos)
  if eventLoopTimer == eventEnemyShoot:
    evilHexInstance.fireEnemyHex(eventEnemySelect, playerShipInstance.body.pos)

  # evilHexInstance.update()
  timerInstance.update(game.gameOverFlag)
  shooter.update(playerShipInstance, evilHexInstance, modifierSlotsInstance)

  inc eventLoopTimer

proc onHide =
  game = nil

proc onDraw =
  timerInstance.draw(centerNumberInstance.target, game.gameOverFlag)

  # If it's no longer the intro, add a target label
  targetInstance.draw(timerInstance.introFlag)

  # draw the Shooter projectiles
  shooter.draw()

  centerNumberInstance.draw(game.gameOverFlag)
  playerShipInstance.draw(game.gameOverFlag)
  modifierSlotsInstance.draw(game.gameOverFlag)


const GameScene* = Scene(
  show: onShow,
  hide: onHide,
  update: onUpdate,
  draw: onDraw,
)
