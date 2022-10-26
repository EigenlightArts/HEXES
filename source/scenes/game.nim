import natu/[video, graphics, input, irq, math, utils]
import utils/[scene, levels]
import entities/[playership, evilhex]
import entities/hud/[ecn, timer, target, modifierslots]
import modules/[shooter, player]
import types/[scenes, entities, hud]

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
var eventModifierIndex: int
var eventModifierShoot: int
var eventEnemyShoot: int
var eventEnemySelect: int

const timerInitial = 300
const timerLevelUp = 120

# TODO(Kal): Implement Controlled RNG for game events
# See:
# - C:\Users\Kaleidosium\Documents\School Shiz\Project Documentation\HEXES\Visual Journal\handmade-help-1.txt
# - https://probablydance.com/2019/08/28/a-new-algorithm-for-controlled-randomness/
# - https://stackoverflow.com/a/28933315/10916748
# - https://www.geeksforgeeks.org/random-number-generator-in-arbitrary-probability-distribution-fashion/

# TODO(Kal): Remaining things for Game Jam
# - Kick player back to TitleScreen if GameOver
# - Go to endGameScene if Player finishes all levels 

proc levelUp(self: var Game) =
  if self.level < levelMax:
    inc self.level
    self.timer = timerInitial
  # elif endGameScene

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
  game.timer = timerInitial
  game.status = Play
  game.level = 1

  while game.ecnValue == game.ecnTarget:
    game.ecnTarget = rand(0..255)

  # background color, approximating eigengrau
  bgColorBuf[0] = rgb8(22, 22, 29)

  playerShipInstance = initPlayerShip(vec2f(75, 0))
  evilHexInstance = initEvilHex()

  centerNumberInstance = initCenterNumber(game.ecnValue, game.ecnTarget)
  timerInstance = initTimer(game.timer, 5)
  targetInstance = initTarget(centerNumberInstance.target)
  modifierSlotsInstance = initModifierSlots()

  eventLevelUpTimer = timerLevelUp

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

  if game.status == Play:
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

    # if keyHit(kiSelect): # Debug Only
    if game.ecnValue == game.ecnTarget:
      game.levelUp()
      game.status = LevelUp

  if game.status == LevelUp:
    dec eventLevelUpTimer
    if eventLevelUpTimer <= 0:
      game.status = Play

  inc eventLoopTimer

proc onHide =
  game = nil

proc onDraw =
  timerInstance.draw(centerNumberInstance.target, game.status, eventLoopTimer)

  # If it's no longer the intro, add a target label
  targetInstance.draw(timerInstance.flag)

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
