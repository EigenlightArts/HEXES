import natu/[math, graphics, video, utils]
import utils/objs
import components/shared
import modules/shooter
import types/[entities, scenes]

proc initEvilHex*(): EvilHex =
  result.initialised = true
  result.body = initBody(vec2f(ScreenWidth div 2 - 10, ScreenHeight div 2 - 10), 20, 20)

  result.tileId = allocObjTiles(gfxEvilHex)
  result.paletteId = acquireObjPal(gfxEvilHex)

  copyFrame(addr objTileMem[result.tileId], gfxEvilHex, 0)

# proc update*(self: var EvilHex) =
# TODO(Kal): Add slowly rotating EvilHex

proc draw*(self: var EvilHex, gameState: GameState) =
  if gameState != LevelUp:
    withObj:
      obj.init(
        mode = omReg,
        pos = vec2i(self.body.pos) - vec2i(
            gfxEvilHex.width div 2 - 10, gfxEvilHex.height div 2 - 10),
        tid = self.tileId,
        pal = self.paletteId,
        size = gfxEvilHex.size
      )

proc fireModifierHex*(self: var EvilHex; modifierIndex: int;
    playerShipPos: Vec2f) =
  # TODO(Kal): Implement Controlled RNG to select the modifier type and angle+position of bullets

  let angle: Angle = rand(uint16)
  # let angle: Angle = 45368 # for testing and debugging
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

  let angle: Angle = rand(uint16)
  # let angle: Angle = 25368 # for testing and debugging
  let pos: Vec2f = vec2f(
      self.body.x - fp(luCos(angle) * self.body.w),
      self.body.y - fp(luSin(angle) * self.body.h))

  var gfxEnemy: Graphic
  var enemyTimeScore: int
  var enemySpeed: int
  var enemyHealth: int
  case enemySelect:
  of 1:
    gfxEnemy = gfxEnemyTriangle
    enemyTimeScore = 20
    enemySpeed = 2
    enemyHealth = 2
  of 2:
    gfxEnemy = gfxEnemySquare
    enemyTimeScore = 15
    enemySpeed = 2
    enemyHealth = 3
  of 3:
    gfxEnemy = gfxEnemyLozenge
    enemyTimeScore = 30
    enemySpeed = 1
    enemyHealth = 2
  of 4:
    gfxEnemy = gfxEnemyCircle
    enemyTimeScore = 20
    enemySpeed = 3
    enemyHealth = 1
  else:
    gfxEnemy = gfxShipPlayer
    enemyTimeScore = 0
    enemySpeed = 0
    enemyHealth = 0

  let enemy = initEnemy(gfxEnemy, enemySelect, enemySpeed, enemyHealth,
      enemyTimeScore, pos)

  shooter.fireEnemy(enemy, angle)
