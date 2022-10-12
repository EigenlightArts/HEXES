import natu/[math, graphics, video, bios, tte, utils, posprintf, mgba]
import utils/[labels, objs]
import components/shared
import modules/shooter
import entities/ecn

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

proc initEvilHex*(centerNumber: sink EvilHexCenterNumber): EvilHex =
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
    let size = tte.getTextSize(addr self.hexBuffer)
    self.centerNumber.label.pos = vec2i(ScreenWidth div 2 - size.x div 2,
        ScreenHeight div 2 - size.y div 2)

    posprintf(addr self.hexBuffer, "$%X", self.centerNumber.value)
    self.centerNumber.label.put(addr self.hexBuffer)
    self.centerNumber.update = false


proc fireModifierHex*(self: var EvilHex; modifierIndex: int;
    playerShipPos: Vec2f) =
  # TODO(Kal): Implement Blue Noise RNG to select the modifier type and angle+position of bullets

  # let angle: Angle = rand(uint16)
  let angle: Angle = 45368 # for testing and debugging
  let pos: Vec2f = vec2f(
      self.centerPoint.x - fp(luCos(angle) * self.orbitRadius.x),
      self.centerPoint.y - fp(luSin(angle) * self.orbitRadius.y))

  let modifier = initProjectileModifier(gfxHwaveFont,
      objHwaveFont, modifierIndex, pos)

  shooter.fireModifier(modifier, angle)

proc fireEnemyHex*(self: var EvilHex;
    playerShipPos: Vec2f) =
  # TODO(Kal): Implement Blue Noise RNG to select the Enemy type and angle+position of bullets
  # With bias towards player postion

  # let angle: Angle = rand(uint16)
  let angle: Angle = 25368 # for testing and debugging
  let pos: Vec2f = vec2f(
      self.centerPoint.x - fp(luCos(angle) * self.orbitRadius.x),
      self.centerPoint.y - fp(luSin(angle) * self.orbitRadius.y))

  let enemy = initEnemy(gfxEnemyA, pos)

  shooter.fireEnemy(enemy, angle)

proc update*(self: var EvilHex) =
  printf("centerNumber.value: %X", self.centerNumber.value)
  printf("valueNumberStored: %d", valueNumberStored)
  printf("valueOperatorStored: %d", valueOperatorStored)

proc inputModifierValue*(self: var EvilHex) =
  if valueNumberStored != 0:
    case valueOperatorStored:
    of okNone:
      # TODO(Kal): Play a beep
      printf("You don't have a stored operator!")
    of okAdd: self.centerNumber.value = self.centerNumber.value + valueNumberStored
    of okSub: self.centerNumber.value = self.centerNumber.value - valueNumberStored
    of okMul: self.centerNumber.value = self.centerNumber.value * valueNumberStored
    of okDiv: self.centerNumber.value = self.centerNumber.value div valueNumberStored

    self.centerNumber.update = true
    valueNumberStored = 0
    valueOperatorStored = okNone
  else:
    # TODO(Kal): Play a beep
    printf("You don't have a stored number and/or operator!")
