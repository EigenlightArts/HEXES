import natu/[math, graphics, video, tte, utils, posprintf]
import components/shared
import entities/ecn
import modules/[types]

export ecn

proc initEvilHex*(centerNumber: sink EvilHexCenterNumber): EvilHex =
  result.initialised = true
  result.body = initBody(vec2f(ScreenWidth div 2, ScreenHeight div 2), 15, 10)

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

import modules/shooter

proc update*(self: var EvilHex) =
  printf("centerNumber.value: %X", self.centerNumber.value)
  printf("numberStoredValue: %d", numberStoredValue)
  printf("operatorStoredValue: %d", operatorStoredValue)

proc fireModifierHex*(self: var EvilHex; modifierIndex: int;
    playerShipPos: Vec2f) =
  # TODO(Kal): Implement Controlled RNG to select the modifier type and angle+position of bullets

  # let angle: Angle = rand(uint16)
  let angle: Angle = 45368 # for testing and debugging
  let pos: Vec2f = vec2f(
      self.body.x - fp(luCos(angle) * self.body.w),
      self.body.y - fp(luSin(angle) * self.body.h))

  let modifier = initProjectileModifier(gfxHwaveFont,
      objHwaveFont, modifierIndex, pos)

  shooter.fireModifier(modifier, angle)

proc fireEnemyHex*(self: var EvilHex; enemySelect: int;
    playerShipPos: Vec2f) =
  # TODO(Kal): Implement Controlled RNG to select the Enemy type and angle+position of bullets
  # With bias towards player postion

  # let angle: Angle = rand(uint16)
  let angle: Angle = 25368 # for testing and debugging
  let pos: Vec2f = vec2f(
      self.body.x - fp(luCos(angle) * self.body.w),
      self.body.y - fp(luSin(angle) * self.body.h))

  var gfxEnemy: Graphic
  var enemyTimeScore: int
  var enemySpeed: int
  case enemySelect:
  of 1:
    gfxEnemy = gfxEnemyTriangle
    enemyTimeScore = 20
    enemySpeed = 2
  of 2:
    gfxEnemy = gfxEnemySquare
    enemyTimeScore = 15
    enemySpeed = 2
  of 3:
    gfxEnemy = gfxEnemyLozenge
    enemyTimeScore = 30
    enemySpeed = 1
  of 4:
    gfxEnemy = gfxEnemyCircle
    enemyTimeScore = 20
    enemySpeed = 3
  else:
    gfxEnemy = gfxBulletTemp
    enemyTimeScore = 0
    enemySpeed = 0

  let enemy = initEnemy(gfxEnemy, enemySelect, enemySpeed, enemyTimeScore, pos)

  shooter.fireEnemy(enemy, angle)


proc inputModifierValue*(self: var EvilHex) =
  if numberStoredValue != 0:
    case operatorStoredValue:
    of okNone:
      # TODO(Kal): Play a beep
      printf("You don't have a stored operator!")
    of okAdd: self.centerNumber.value = self.centerNumber.value + numberStoredValue
    of okSub: self.centerNumber.value = self.centerNumber.value - numberStoredValue
    of okMul: self.centerNumber.value = self.centerNumber.value * numberStoredValue
    of okDiv: self.centerNumber.value = self.centerNumber.value div numberStoredValue

    self.centerNumber.update = true
    numberStoredValue = 0
    operatorStoredValue = okNone
  else:
    # TODO(Kal): Play a beep
    printf("You don't have a stored number and/or operator!")
