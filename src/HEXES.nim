import natu/[video, bios, irq, input, math, graphics, utils]
import utils/objs
import entities/[playership, evilhex]
import entities/hud/[ecn, timer, target, modifierslots]
import modules/[shooter, player]

# TODO(Kal): change this to rgb8() later
# background color, approximating eigengrau
bgColorBuf[0] = rgb5(3, 3, 4)

# enable VBlank interrupt so we can wait for the end of the frame without burning CPU cycles
irq.enable(iiVBlank)

dispcnt = initDispCnt(obj = true, obj1d = true, bg0 = true)

irq.enable(iiVBlank)

# TODO(Kal): move these to Module Types?
var ecnValue: int = rand(0..255)
var ecnTarget: int = rand(0..255)

# prevent ecnValue to be the same as the target
while ecnValue == ecnTarget:
  ecnTarget = rand(0..255)

var timerInitial: int = 300

var playerShipInstance = initPlayerShip(vec2f(75, 0))
var evilHexInstance = initEvilHex()

var centerNumberInstance = initCenterNumber(ecnValue, ecnTarget)
var timerInstance = initTimer(timerInitial, 5)
var targetInstance = initTarget(centerNumberInstance.target)
var modifierSlotsInstance = initModifierSlots()

var eventLoopTimer: int
var eventModifierShoot: int
var eventModifierIndex: int
var eventEnemyShoot: int
var eventEnemySelect: int

# TODO(Kal): Would be better to use fractions of probability instead
proc startEventLoop() =
  eventLoopTimer = 0
  eventModifierShoot = rand(40..90)
  eventEnemyShoot = rand(30..65)
  eventEnemySelect = rand(1..4)
  # TODO(Kal): Probably a good idea to make operators more common
  eventModifierIndex = rand(1..19) # excludes 0 and $

startEventLoop()

# NOTE(Kal): Resources about Game Engine Development:
# - https://www.gameprogrammingpatterns.com/
# - https://www.gameenginebook.com/

while true:
  # TODO(Kal): Implement Controlled RNG for game events
  # See:
  # - C:\Users\Kaleidosium\Documents\School Shiz\Project Documentation\HEXES\Visual Journal\handmade-help-1.txt
  # - https://probablydance.com/2019/08/28/a-new-algorithm-for-controlled-randomness/

  # after 100 vblank units, restart event loop
  if eventLoopTimer == 100:
    startEventLoop()

  # update key states
  keyPoll()

  # player controls
  player.controlsGame(playerShipInstance, centerNumberInstance, modifierSlotsInstance)

  # update ship position
  playerShipInstance.update()

  # fire the EvilHex projectile
  if eventLoopTimer == eventModifierShoot:
    evilHexInstance.fireModifierHex(eventModifierIndex,
        playerShipInstance.body.pos)
  if eventLoopTimer == eventEnemyShoot:
    evilHexInstance.fireEnemyHex(eventEnemySelect, playerShipInstance.body.pos)

  # update timer
  timerInstance.update()

  # update EvilHex subroutines
  # evilHexInstance.update()

  # update shooter
  shooter.update(playerShipInstance, evilHexInstance, modifierSlotsInstance)

  # wait for the end of the frame
  VBlankIntrWait()

  inc eventLoopTimer

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

  # copy the PAL RAM buffer into the real PAL RAM.
  flushPals()
  # hide all the objects that weren't used
  oamUpdate()
