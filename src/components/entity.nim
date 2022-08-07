import natu/[math, graphics, video, oam, utils, mgba]
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

# Bullet spefific procedures

proc rect(bullet: Entity): Rect =
  printf("in entity.nim proc rect1: x = %l, y = %l", bullet.pos.x.toInt(), bullet.pos.y.toInt())
  result.left = bullet.pos.x.toInt() - 5
  result.top = bullet.pos.y.toInt() - 5
  result.right = bullet.pos.x.toInt() + 5
  result.bottom = bullet.pos.y.toInt() + 5
  printf("in entity.nim proc rect2: x = %l, y = %l", bullet.pos.x.toInt(), bullet.pos.y.toInt())

proc update*(bullet: var Entity) =

  printf("in entity.nim proc update: x = %l, y = %l", bullet.pos.x.toInt(), bullet.pos.y.toInt())


  # make sure the bullets go where they are supposed to go
  # the *2 is for speed reasons, without it, the bullets are very slow
  # bullet.pos.x = bullet.pos.x - fp(luCos(
  #     bullet.angle)) * 2
  # bullet.pos.y = bullet.pos.y - fp(luSin(
  #      bullet.angle)) * 2

  if (not onscreen(bullet.rect())):
    bullet.finished = true
    bullet.entityActive = bullet.entityActive - 1