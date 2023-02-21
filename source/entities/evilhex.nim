import natu/[math, graphics, video, utils]
import utils/objs
import components/shared
import components/projectile/[enemy, modifier]
import modules/shooter
import types/[entities, scenes]

proc initEvilHex*(): EvilHex =
  result.initialised = true

  result.body = initBody(vec2f(ScreenWidth div 2 - 10, ScreenHeight div 2 - 10), 20, 20)
  result.tid = allocObjTiles(gfxEvilHex)
  result.paletteId = acquireObjPal(gfxEvilHex)

  copyFrame(addr objTileMem[result.tid], gfxEvilHex, 0)

proc draw*(self: var EvilHex, gameState: GameState) =
  if gameState != LevelUp:
    withObj:
      obj.init(
        mode = omReg,
        pos = vec2i(self.body.pos) - vec2i(
            gfxEvilHex.width div 2 - 10, gfxEvilHex.height div 2 - 10),
        tid = self.tid,
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

proc fireEnemyHex*(self: var EvilHex; enemySelect: EnemyKind;
    playerShipPos: Vec2f) =
  let angle: Angle = rand(uint16)
  # let angle: Angle = 25368 # for testing and debugging
  let pos: Vec2f = vec2f(
      self.body.x - fp(luCos(angle) * self.body.w),
      self.body.y - fp(luSin(angle) * self.body.h))

  var gfxEnemy: Graphic
  var enemySpeed: SpeedKind
  var enemyHealth: int
  var enemyTimeScore: int
  case enemySelect:
  of ekNone:
    gfxEnemy = gfxShipPlayer
    enemyTimeScore = 0
    enemySpeed = skNone
    enemyHealth = 0
  of ekTriangle:
    gfxEnemy = gfxEnemyTriangle
    enemyTimeScore = 15
    enemySpeed = skMedium
    enemyHealth = 3
  of ekSquare:
    gfxEnemy = gfxEnemySquare
    enemyTimeScore = 15
    enemySpeed = skMedium
    enemyHealth = 2
  of ekLozenge:
    gfxEnemy = gfxEnemyLozenge
    enemyTimeScore = 30
    enemySpeed = skSlow
    enemyHealth = 2
  of ekCircle:
    gfxEnemy = gfxEnemyCircle
    enemyTimeScore = 30
    enemySpeed = skFast
    enemyHealth = 1
  of ekPentagon:
    gfxEnemy = gfxEnemyPentagon
    enemyTimeScore = 30
    enemySpeed = skMedium
    enemyHealth = 1

  let enemy = initEnemy(gfxEnemy, enemySelect, enemySpeed, enemyHealth,
      enemyTimeScore, pos)

  shooter.fireEnemy(enemy, angle)
