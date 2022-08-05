import natu/[math, graphics, video, oam, utils]
import ../utils/[objs, labels]

type
  EntityKind* = enum
    ekBullet
    ekEnemy
    ekModifier
  Entity* = object
    # fields that all have in common
    pos*: Vec2f
    angle*: Angle
    index*: int
    entityActive*: int
    entityLimit*: int
    finished*: bool

    case kind*: EntityKind
    of ekBullet:
      # fields that only bullets have
      damage*: int
    of ekEnemy:
      # fields that only enemies have
      health*: int
      doesItShoot*: bool
    of ekModifier:
      # fields that only modifiers have
      # modifier: Modifier
      modLabel*: Label
      modType*: string

var sharedEntityInstances*: List[16, Entity]

proc initBulletEntity*(isPlayer: bool = false): Entity =
  result.kind = ekBullet
  result.entityLimit = if isPlayer: 5 else: 2

proc initEnemyEntity*(): Entity =
  result.kind = ekEnemy

proc initModifierEntity*(gfxText: Graphic = gfxShipTemp): Entity =
  result.kind = ekModifier

  result.modLabel.init(vec2i(20, 10), s8x16, count = 22)
  result.modLabel.obj.pal = getPalId(gfxText)
  result.modLabel.ink = 1 # set the ink colour index to use from the palette
  result.modLabel.shadow = 2 # set the shadow colour (only relevant if the font actually has more than 1 colour)
