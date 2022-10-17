import natu/[video, bios, irq, input, math, graphics, utils]
import utils/objs
import entities/[playership, evilhex, ecn]
import modules/shooter

# TODO(Kal): change this to rgb8() later
# background color, approximating eigengrau
bgColorBuf[0] = rgb5(3, 3, 4)

# enable VBlank interrupt so we can wait for the end of the frame without burning CPU cycles
irq.enable(iiVBlank)

dispcnt = initDispCnt(obj = true, obj1d = true, bg0 = true)

irq.enable(iiVBlank)


var ecnValue: int = 255
# TODO(Kal): Implement Seconds from frames passed (1 Second/60 Frames)
var globalFramesPassed: int
var eventLoopTimer: int
var eventModifierShoot: int
var eventModifierIndex: int
var eventEnemyShoot: int
var eventEnemySelect: int

var playerShipInstance = initPlayerShip(vec2f(75, 0))
var evilHexInstance = initEvilHex(initEvilHexCenterNumber(ecnValue))

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
# - https://gameprogrammingpatterns.com/
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

  # ship controls
  playerShipInstance.controls(evilHexInstance)

  # update ship position
  playerShipInstance.update()

  # fire the EvilHex projectile
  if eventLoopTimer == eventModifierShoot:
    evilHexInstance.fireModifierHex(eventModifierIndex, playerShipInstance.body.pos)
  if eventLoopTimer == eventEnemyShoot:
    evilHexInstance.fireEnemyHex(eventEnemySelect, playerShipInstance.body.pos)

  # update EvilHex subroutines
  # evilHexInstance.update()

  # update Shooter
  shooter.update()

  # wait for the end of the frame
  VBlankIntrWait()

  eventLoopTimer += 1

  # draw the ship
  playerShipInstance.draw()

  # draw the EvilHex
  evilHexInstance.draw()

  # draw the Shooter projectiles
  shooter.draw()

  # copy the PAL RAM buffer into the real PAL RAM.
  flushPals()
  # hide all the objects that weren't used
  oamUpdate()
