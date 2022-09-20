import natu/[video, bios, irq, input, math, graphics, utils]
import utils/objs
import entities/[playership, evilhex]
import modules/shooter

# TODO(Kal): change this to rgb8() later
# background color, approximating eigengrau
bgColorBuf[0] = rgb5(3, 3, 4)

# enable VBlank interrupt so we can wait for the end of the frame without burning CPU cycles
irq.enable(iiVBlank)

dispcnt = initDispCnt(obj = true, obj1d = true, bg0 = true)

irq.enable(iiVBlank)

var valueCHN: uint8 = 255
var eventLoopTimer: int
var eventModifierShoot: int
var eventModifierIndex: int

proc startEventLoop() =
  eventLoopTimer = 0
  eventModifierShoot = rand(40..90)
  eventModifierIndex = rand(0..21) # excludes $

var evilHexInstance = initEvilHex(valueCHN)
var playerShipInstance = initPlayerShip(vec2f(75, 0))

startEventLoop()

# NOTE(Kal): Resources about Game Engine Development:
# - https://gameprogrammingpatterns.com/
# - https://www.gameenginebook.com/

while true:
  # after 100 vblank units, restart event loop
  if eventLoopTimer == 100:
    startEventLoop()

  # update key states
  keyPoll()

  # ship controls
  playerShipInstance.controls()

  # update ship position
  playerShipInstance.update()

  # fire the EvilHex projectile
  if eventLoopTimer == eventModifierShoot:
    evilHexInstance.fire(eventModifierIndex, playerShipInstance.pos)

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
