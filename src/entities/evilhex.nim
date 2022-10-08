import natu/[math, graphics, video, bios, tte, utils, posprintf, mgba]
import utils/[labels, objs]
import components/shared
import modules/shooter
import ecn

export ecn

type EvilHex* = object
  initialised: bool
  centerNumber*: EvilHexCenterNumber

  tileId, paletteId: int
  hexBuffer: array[9, char]

  orbitRadius: Vec2i
  centerPoint: Vec2i

# destructor - free the resources used by the hex object
proc `=destroy`*(self: var EvilHex) =
  if self.initialised:
    self.initialised = false
    freeObjTiles(self.tileId)
    releaseObjPal(gfxShipTemp)

proc `=copy`*(dest: var EvilHex; source: EvilHex) {.error: "Not implemented".}

proc initEvilHex*(centerNumber: sink EvilHexCenterNumber): var EvilHex =
  result.initialised = true
  result.orbitRadius = vec2i(15, 10)
  result.centerPoint = vec2i(ScreenWidth div 2, ScreenHeight div 2)

  result.tileId = allocObjTiles(gfxShipTemp)
  result.paletteId = acquireObjPal(gfxShipTemp)

  result.centerNumber = centerNumber
  posprintf(addr result.hexBuffer, "$%X", result.centerNumber.value)
  result.centerNumber.label.put(addr result.hexBuffer)

# draw evilhex and related parts
proc draw*(self: var EvilHex) =
  self.centerNumber.label.draw()

  if self.centerNumber.update:
    var size = tte.getTextSize(addr self.hexBuffer)
    self.centerNumber.label.pos = vec2i(ScreenWidth div 2 - size.x div 2,
        ScreenHeight div 2 - size.y div 2)

    self.centerNumber.label.put(addr self.hexBuffer)
    self.centerNumber.update = false


proc fireModifierHex*(self: var EvilHex; modifierIndex: int;
    playerShipPos: Vec2f) =
  # TODO(Kal): Implement Blue Noise RNG to select the modifier type and angle+position of bullets

  # WONTFIX(Kal): The broken ranged shoot, will be using blue noise instead
  # let angleVariance = 1
  # let anglePlayer = ArcTan2(int16(playerShipPos.x.toInt()), int16(playerShipPos.y.toInt()))
  # let angle = uint32(int(anglePlayer) + rand(-angleVariance..angleVariance))
  # printf("in evilhex.nim proc fire anglePlayer = %l, playerShipPos.x = %l, playerShipPos.y = %l, angle = %l", anglePlayer, -playerShipPos.x.toInt(), -playerShipPos.y.toInt(), angle.uint16)
  # printf("in evilhex.nim proc fire rand = %l", rand(-angleVariance..angleVariance))

  # let angle: Angle = rand(uint16)
  let angle: Angle = 45368 # for testing and debugging
  let pos: Vec2f = vec2f(
      self.centerPoint.x - fp(luCos(angle) * self.orbitRadius.x),
      self.centerPoint.y - fp(luSin(angle) * self.orbitRadius.y))

  let modifier = initProjectileModifier(gfxHwaveFont,
      objHwaveFont, modifierIndex, pos)

  shooter.fireModifier(modifier, angle)

proc update*(self: var EvilHex) =
  printf("valueNumberStored: %d", valueNumberStored)
  printf("valueOperatorStored: %d", valueOperatorStored)

proc inputModifierValue*(self: var EvilHex) =
  if valueNumberStored != 0 and valueOperatorStored != okNone:
    case valueOperatorStored:
    of okNone:
      # TODO(Kal): Play a beep
      printf("You don't have a stored number or operator!")
    of okAdd: self.centerNumber.value = self.centerNumber.value + valueNumberStored
    of okSub: self.centerNumber.value = self.centerNumber.value - valueNumberStored
    of okMul: self.centerNumber.value = self.centerNumber.value * valueNumberStored
    of okDiv: self.centerNumber.value = self.centerNumber.value div valueNumberStored
  else:
    # TODO(Kal): Play a beep
    printf("You don't have a stored number or operator!")
