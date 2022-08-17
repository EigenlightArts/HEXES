import natu/[video, bios, irq, input, math, graphics]
import utils/objs
import entity/[playership, evilhex]

# TODO(Kal): change this to rgb8() later
# background color, approximating eigengrau
bgColorBuf[0] = rgb5(3, 3, 4)

# enable VBlank interrupt so we can wait for the end of the frame without burning CPU cycles
irq.enable(iiVBlank)

dispcnt = initDispCnt(obj = true, obj1d = true, bg0 = true)

irq.enable(iiVBlank)

var evilHexInstance = initEvilHex(255)
var playerShipInstance = initPlayerShip(vec2f(75, 0))

var testHexLoop = true

var orckFont = initObj(
  pos = vec2i(100, 50),
  tileId = allocObjTiles(gfxOrckFont.allTiles),  # Allocate tiles for a single frame of animation.
  palId = acquireObjPal(gfxOrckFont),   # Obtain palette.
  size = gfxOrckNumbers.size,              # Set to correct size.
)

while true:
  # update key states
  keyPoll()

  # ship controls
  playerShipInstance.controls()

  if testHexLoop:
    evilHexInstance.hexLoop()
    testHexLoop = false

  # wait for the end of the frame
  VBlankIntrWait()

  # update ship position
  playerShipInstance.updatePos()
  # draw the ship
  playerShipInstance.draw()

  # draw the evil hex
  evilHexInstance.draw()

  # copy the PAL RAM buffer into the real PAL RAM.
  flushPals()
  # hide all the objects that weren't used
  oamUpdate()
